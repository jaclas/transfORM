unit refORM;

interface

uses
  Spring,

  Data.DB,

  FireDAC.Comp.Client,

  Spring.Collections,

  System.Generics.Defaults,
  System.Rtti,
  System.SyncObjs,
  System.TypInfo;

type

  MapToAttribute = class(TCustomAttribute)
  private
    fMapToColumnName : string;
  protected
    function GetMapToColumnName(): string;
  public
    constructor Create(const aMapToColumnName : string);
    property MapToName: string read GetMapToColumnName;
  end;

  ItransfORMEntity = interface(IInvokable) ['{F0568FB5-F855-4240-B68A-16FE01D68E07}']
    function GetConnection(): TFDConnection;
    function GetImmediateCommit(): Boolean;
    function HasChanges() : Boolean;
    procedure Commit(aInSubthread : Boolean = False);
    procedure SetImmediateCommit(const aValue: Boolean);
    property ImmediateCommit: Boolean read GetImmediateCommit write SetImmediateCommit;
    property Connection: TFDConnection read GetConnection;
  end;

  TransfORMField = class
  private
    fChanged : Boolean;
    fFieldName: string;
    fDataType : TFieldType;
    formEntity : ItransfORMEntity;
  protected
    function ormEntity(): ItransfORMEntity;
    function GetOldValue(): Variant; virtual; abstract;
    function GetValue(): Variant; virtual; abstract;
    procedure SetValue(const aValue: Variant); virtual; abstract;
    procedure ApplyChanges(); virtual; abstract;
  public
    constructor Create(const ormEntity : ItransfORMEntity; const aFieldName : string; aDataType : TFieldType);
    property Changed: Boolean read fChanged;
    property FieldName: string read fFieldName;
    property DataType: TFieldType read fDataType;
    property OldValue: Variant read GetOldValue;
    property Value: Variant read GetValue write SetValue;
  end;

  TransfORMField<T> = class(TransfORMField)
  private
    fData : T;
    fOldData : T;
    fComparer: IEqualityComparer<T>;
  protected
    function GetAsVariant<T>(const AValue: T): Variant;
    procedure SetFromVariant(const aValue : Variant);
    function GetOldValue(): Variant; override;
    function GetValue(): Variant; override;
    procedure SetValue(const aValue: Variant); override;
    procedure ApplyChanges(); override;
  public
    constructor Create(const ormEntity : ItransfORMEntity; const aFieldName : string; aDataType : TFieldType; const aValue : Variant);
    property Changed: Boolean read fChanged;
    property FieldName: string read fFieldName;
    property DataType: TFieldType read fDataType;
    property OldValue: Variant read GetOldValue;
    property Value: Variant read GetValue write SetValue;
  end;


  TDBColumnInfo = class
  private
    fColumnName : string;
    fDataType : TFieldType;
    fPrimaryKey: Boolean;
  protected
    function GetColumnName(): string;
    function GetDataType(): TFieldType;
    function GetPrimaryKey(): Boolean;
    procedure SetColumnName(const aValue: string);
    procedure SetDataType(const aValue: TFieldType);
    procedure SetPrimaryKey(const aValue: Boolean);
  public
    constructor Create(const aColumnName: string; const aDataType: TFieldType);
    property ColumnName: string read GetColumnName write SetColumnName;
    property DataType: TFieldType read GetDataType write SetDataType;
    property PrimaryKey: Boolean read GetPrimaryKey write SetPrimaryKey;
  end;

  TDBTableInfo = class
  private
    fColumns : IDictionary<string, TDBColumnInfo>;
    fTableName: string;
  protected
    function GetColumn(const aColumnName : string): TDBColumnInfo;
    function GetColumns(): IReadOnlyCollection<TDBColumnInfo>;
    function GetTableName(): string;
    procedure SetTableName(const aValue: string);
  public
    constructor Create(const aTableName : string);
    function AddColumnInfo(const aColumnName : string; const aColumnType : TFieldType): TDBColumnInfo;
    property Column[const aColumnName : string]: TDBColumnInfo read GetColumn; default;
    property Columns: IReadOnlyCollection<TDBColumnInfo> read GetColumns;
    property TableName: string read GetTableName write SetTableName;
  end;

  TInterfaceField = class
  private
    fFieldName : string;
    fMappedToColumn : string;
    fPK : Boolean;
  public
    constructor Create(const aFieldName : string; const aMappedToColumn : string; aPK : Boolean);
    property FieldName: string read fFieldName;
    property MappedToColumn: string read fMappedToColumn;
    property PK: Boolean read fPK;
  end;

  TInterfaceEntity = class
  private
    fFields : IDictionary<string, TInterfaceField>;
    fPrimaryKeyName : string;
    fTableName: string;
  public
    constructor Create(const aTableName : string);
    function AddField(const aFieldName : string; const aMappedToColumn : string; aPK : Boolean): TInterfaceField;
    property Fields: IDictionary<string, TInterfaceField> read fFields;
    property PrimaryKeyName: string read fPrimaryKeyName;
    property TableName: string read fTableName;
  end;

  TransfORMEntityVirtualInterface = class(TVirtualInterface, ItransfORMEntity)
  private
    fFields : IDictionary<string, TransfORMField>;
    fConnection : TFDConnection;
    fImmediateCommit : Boolean;
    fPrimaryKeyName : string;
    fPrimaryKeyValue : Int64;
    fTableName: string;
    fCritical : TCriticalSection;
    function CreateField(const aDBColumnName: string; const aDataType: TFieldType; const aValue : Variant): TransfORMField;
    procedure CreateFields(const aEntity: TInterfaceEntity);
    procedure InternalCommit();
  protected
    function GetConnection(): TFDConnection;
    function GetImmediateCommit(): Boolean;
    function HasChanges() : Boolean;
    procedure SetImmediateCommit(const aValue: Boolean);
    procedure Commit(aInSubthread : Boolean = False);
  public
    constructor Create(aTypeInfo: PTypeInfo; const aEntity: TInterfaceEntity; const aConnection: TFDConnection; const aPrimaryKeyValue: Int64);
    destructor Destroy(); override;
    procedure DoInvoke(aMethod: TRttiMethod; const aArgs: TArray<TValue>; out oResult: TValue);

    property ImmediateCommit: Boolean read GetImmediateCommit write SetImmediateCommit;
    property Connection: TFDConnection read GetConnection;
  end;


  TransfORM = class
  private
    fConnection: TFDConnection;
    fConnectionDefName : string;
    fTypes : IDictionary<PTypeInfo, TInterfaceEntity>;
    fTables : IDictionary<string, TDBTableInfo>;
  protected
    function ImportDBTableInfo(const aTableName : string; const aConnection: TFDConnection): TDBTableInfo;
    function ParseInterface(const aTypeInfo : PTypeInfo; const aConnection: TFDConnection): TInterfaceEntity;

    function GetDBTableInfo(const aTableName : string; const aConnection: TFDConnection): TDBTableInfo;
    function GetInterfaceEntity(const aTypeInfo : PTypeInfo; const aConnection: TFDConnection): TInterfaceEntity;
  public
    constructor Create(const aDBConnectionDefName : string);
    destructor Destroy(); override;
    function GetInstance<I: IInvokable>(const aPrimaryKeyValue: Int64; const aConnection: TFDConnection = nil): I;
  end;

implementation

uses
  FireDAC.Phys.Intf,
  FireDAC.Stan.Option,

  Spring.Reflection,

  System.Classes,
  System.Generics.Collections,
  System.SysUtils;


constructor TransfORMEntityVirtualInterface.Create(aTypeInfo: PTypeInfo; const aEntity: TInterfaceEntity; const aConnection: TFDConnection; const
    aPrimaryKeyValue: Int64);
begin
  inherited Create(aTypeInfo, DoInvoke);
  fCritical := TCriticalSection.Create;
  fTableName := UpperCase(aEntity.TableName);
  fPrimaryKeyName := aEntity.PrimaryKeyName;
  fPrimaryKeyValue := aPrimaryKeyValue;
  fImmediateCommit := True;
  fConnection := aConnection;
  CreateFields(aEntity);
end;

destructor TransfORMEntityVirtualInterface.Destroy();
begin
  inherited;
  fCritical.Free;
end;

procedure TransfORMEntityVirtualInterface.Commit(aInSubthread : Boolean = False);
begin
  if aInSubthread then
  begin
    fCritical.Enter;
    try
      TThread.CreateAnonymousThread(procedure
                                    begin
                                      try
                                        InternalCommit();
                                      finally
                                        fCritical.Leave;
                                      end;
                                    end).Start;
    except
      fCritical.Leave;
    end;
  end else
  begin
    fCritical.Enter;
    try
    InternalCommit();
    finally
    fCritical.Leave;
    end;
  end;
end;

function TransfORMEntityVirtualInterface.CreateField(const aDBColumnName: string; const aDataType: TFieldType; const aValue : Variant): TransfORMField;
begin
  case aDataType of
  ftSmallint : Result := TransfORMField<SmallInt>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftShortint : Result := TransfORMField<ShortInt>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftByte : Result := TransfORMField<Byte>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftWord : Result := TransfORMField<Word>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftInteger : Result := TransfORMField<Integer>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftLargeint : Result := TransfORMField<Int64>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftLongWord : Result := TransfORMField<LongWord>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftBCD,
  ftCurrency : Result := TransfORMField<Currency>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  TFieldType.ftSingle : Result := TransfORMField<Single>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftFloat : Result := TransfORMField<Double>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftDate : Result := TransfORMField<TDate>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftDateTime,
  ftTimeStamp : Result := TransfORMField<TDateTime>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftTime : Result := TransfORMField<TTime>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftBoolean : Result := TransfORMField<Boolean>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftString,
  ftMemo,
  ftBlob,
  ftWideMemo,
  ftFixedChar,
  ftFixedWideChar,
  ftWideString: Result := TransfORMField<string>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  ftVariant : Result := TransfORMField<Variant>.Create(self as ItransfORMEntity, aDBColumnName, aDataType, aValue);
  else
    begin
      raise Exception.CreateFmt('Unknown data type: %s for column: %s', [Spring.TEnum.GetName<TFieldType>(aDataType), aDBColumnName]);
    end;
  end;
end;

procedure TransfORMEntityVirtualInterface.CreateFields(const aEntity: TInterfaceEntity);
var
  i: Integer;
  lColumn: TDBColumnInfo;
  lDataType: TFieldType;
  lField : TPair<string, TInterfaceField>;
  lFields: string;
  lormField: TransfORMField;
  lPrimaryKeyName: string;
  lQuery: TFDQuery;
  lSelect: string;
  lvar: Variant;
begin
  lSelect := 'SELECT %s FROM %s WHERE %s = :KEY';
  lQuery := TFDQuery.Create(nil);
  try
  lQuery.FetchOptions.Items := [fiBlobs];
  lQuery.Connection := fConnection;
  lFields := '';
  for lField in aEntity.Fields do
  begin
    lFields := lFields + lField.Value.MappedToColumn + ',';
  end;
  lFields := Copy(lFields, 1, Length(lFields) - 1);
  lQuery.SQL.Text := Format(lSelect, [lFields, aEntity.TableName, aEntity.PrimaryKeyName]);
  fFields := TCollections.CreateDictionary<string, TransfORMField>([doOwnsValues]);
  lQuery.ParamByName('KEY').AsLargeInt := fPrimaryKeyValue;
  lQuery.Open;
  for lField in aEntity.Fields do
  begin
    lDataType := lQuery.FieldByName(lField.Value.MappedToColumn).DataType;
    lormField := CreateField(lField.Value.MappedToColumn, lDataType, lQuery.FieldByName(lField.Value.MappedToColumn).Value);
    fFields.Add(lField.Value.FieldName, lormField);
  end;
  finally
  lQuery.Free;
  end;
end;

procedure TransfORMEntityVirtualInterface.DoInvoke(aMethod: TRttiMethod; const aArgs: TArray<TValue>; out oResult: TValue);
var
  lBool: Boolean;
  lField: TransfORMField;
  lIntf: IInterface;
  lObj: TObject;
  s: string;
begin
  s := UpperCase(aMethod.Name);
  if s = 'HASCHANGES' then
  begin
    lBool := HasChanges();
    oResult := TValue.From<Boolean>(lBool);
  end else
  if s = 'GETCONNECTION' then
  begin
    oResult := TValue.From<TFDConnection>(fConnection);
  end else
  if s = 'GETIMMEDIATECOMMIT' then
  begin
    oResult := TValue.From<Boolean>(fImmediateCommit);
  end else
  if s = 'SETIMMEDIATECOMMIT' then
  begin
    fImmediateCommit := aArgs[1].AsBoolean;
  end else
  if s = 'COMMIT' then
  begin
    lBool := aArgs[1].AsBoolean;
    Commit(lBool);
  end else
  begin
    fFields.TryGetValue(s, lField);
    oResult := TValue.From(lField, TransfORMField);// lField.ClassType);
  end;
end;

function TransfORMEntityVirtualInterface.GetConnection(): TFDConnection;
begin
  Result := fConnection;
end;

function TransfORMEntityVirtualInterface.GetImmediateCommit(): Boolean;
begin
  Result := fImmediateCommit;
end;

function TransfORMEntityVirtualInterface.HasChanges(): Boolean;
var
  i: Integer;
  lField: TransfORMField;
begin
  i := 0;
  for lField in fFields.Values do
  begin
    if lField.Changed then Exit(True);
  end;
  Result := False;
end;

procedure TransfORMEntityVirtualInterface.InternalCommit();
var
  lQry: TFDQuery;
  lField: TransfORMField;
  lFields: string;
  lPKey: string;
  lSQL: string;
begin
  if not HasChanges() then Exit;
  lSQL := 'UPDATE %s SET %s WHERE %s';
  lFields := '';
  for lField in fFields.Values do
  begin
    if lField.Changed then
    begin
      lFields := lFields + lField.FieldName + '=:' + lField.FieldName + ',';
    end;
  end;
  lFields := Copy(lFields, 1, Length(lFields) - 1);
  lPKey := fPrimaryKeyName + '=:' + fPrimaryKeyName;
  lSQL := Format(lSQL, [fTableName, lFields, lPKey]);
  lQry := TFDQuery.Create(nil);
  try
  lQry.Connection := fConnection;
  lQry.SQL.Text := lSQL;
  lQry.ParamByName(fPrimaryKeyName).AsLargeInt := fPrimaryKeyValue;
  for lField in fFields.Values do
  begin
    if lField.Changed then
    begin
      lQry.ParamByName(lField.FieldName).Value := lField.Value;
      lField.ApplyChanges();
    end;
  end;
  lQry.ExecSQL;
  fConnection.Commit;
  finally
  lQry.Free;
  end;
end;

procedure TransfORMEntityVirtualInterface.SetImmediateCommit(const aValue: Boolean);
begin
  fImmediateCommit := aValue;
  if fImmediateCommit then
  begin
    Commit();
  end;
end;

constructor TransfORM.Create(const aDBConnectionDefName : string);
begin
  inherited Create();
  fTypes := TCollections.CreateDictionary<PTypeInfo, TInterfaceEntity>([doOwnsValues]);
  fTables := TCollections.CreateDictionary<string, TDBTableInfo>([doOwnsValues]);
  fConnectionDefName := aDBConnectionDefName;
end;

destructor TransfORM.Destroy();
begin
  inherited;
  fTypes := nil;
  fTables := nil;
end;

function TransfORM.GetDBTableInfo(const aTableName : string; const aConnection: TFDConnection): TDBTableInfo;
begin
  if not fTables.TryGetValue(aTableName, Result) then
  begin
    Result := ImportDBTableInfo(aTableName, aConnection);
    fTables.Add(aTableName, Result);
  end;
end;

function TransfORM.GetInstance<I>(const aPrimaryKeyValue: Int64; const aConnection: TFDConnection = nil): I;
var
  lConnection: TFDConnection;
  lEntity: TInterfaceEntity;
  lTypeInfo : PTypeInfo;
begin
  lTypeInfo := TypeInfo(I);
  if Assigned(aConnection) then
  begin
    lConnection := aConnection;
  end else
  begin
    if not Assigned(fConnection) then
    begin
      fConnection := TFDConnection.Create(nil);
      fConnection.ConnectionDefName := fConnectionDefName;
    end;
    lConnection := fConnection;
  end;
  lEntity := GetInterfaceEntity(lTypeInfo, lConnection);
  TransfORMEntityVirtualInterface.Create(lTypeInfo, lEntity, lConnection, aPrimaryKeyValue).QueryInterface(lTypeInfo.TypeData.GUID, Result);
end;

function TransfORM.GetInterfaceEntity(const aTypeInfo : PTypeInfo; const aConnection: TFDConnection): TInterfaceEntity;
begin
  if not fTypes.TryGetValue(aTypeInfo, Result) then
  begin
    Result := ParseInterface(aTypeInfo, aConnection);
    fTypes.AddOrSetValue(aTypeInfo, Result);
  end;
end;

function TransfORM.ParseInterface(const aTypeInfo : PTypeInfo; const aConnection: TFDConnection): TInterfaceEntity;
var
  cntx : TRttiContext;
  lDBColumnInfo: TDBColumnInfo;
  lIntfField: TInterfaceField;
  lMethods: TArray<TRttiMethod>;
  lTableName: string;
  lType: TRttiType;
  lMethod: TRttiMethod;

  lDBTableInfo: TDBTableInfo;
  lIndex: Integer;
  lMapTo: string;
  lMapToAttr: MapToAttribute;
  lMethodName: string;
begin
  cntx := TRttiContext.Create;
  lType := cntx.GetType(aTypeInfo);
  lMethods := lType.GetDeclaredMethods();

  lMapToAttr := lType.GetCustomAttribute<MapToAttribute>();
  if Assigned(lMapToAttr) then
  begin
    lTableName := lMapToAttr.MapToName;
  end else
  begin
    lTableName := Copy(aTypeInfo.Name, 2, MaxInt);
  end;
  lDBTableInfo := GetDBTableInfo(lTableName, aConnection);
  Result := TInterfaceEntity.Create(lTableName);
  for lMethod in lMethods do
  begin
    lMethodName := UpperCase(lMethod.Name);
    lMapToAttr := lMethod.GetCustomAttribute<MapToAttribute>();
    if Assigned(lMapToAttr) then
    begin
      lMapTo := UpperCase(lMapToAttr.MapToName);
    end else
    begin
      lMapTo := lMethodName;
    end;
    lIndex := lMethod.VirtualIndex;
    lDBColumnInfo := lDBTableInfo.Column[lMapTo];
    Result.AddField(lMethodName, lMapTo, lDBColumnInfo.PrimaryKey);
  end;
end;

function TransfORM.ImportDBTableInfo(const aTableName : string; const aConnection: TFDConnection): TDBTableInfo;
var
  i: Integer;
  lColumn: TDBColumnInfo;
  lPKName: string;
  lQuery : TFDQuery;
  lMetaQryGetInfo: TFDMetaInfoQuery;
begin
  lMetaQryGetInfo := TFDMetaInfoQuery.Create(nil);
  lQuery := TFDQuery.Create(nil);
  try
  lQuery.Connection := aConnection;
  lQuery.FetchOptions.Items := [fiMeta];
  lMetaQryGetInfo.Connection := aConnection;

  lMetaQryGetInfo.MetaInfoKind := mkTableFields;
  lMetaQryGetInfo.TableKinds := [tkTable];
  lMetaQryGetInfo.BaseObjectName := aTableName;
  lMetaQryGetInfo.ObjectName := aTableName;
  lMetaQryGetInfo.MetaInfoKind := mkPrimaryKeyFields;
  lMetaQryGetInfo.Open;
  lPKName := lMetaQryGetInfo.FieldByName('COLUMN_NAME').AsString;
  lMetaQryGetInfo.Close;

  Result := TDBTableInfo.Create(aTableName);
  lQuery.SQL.Text := 'SELECT * FROM &TableName WHERE 0 = 1';
  lQuery.MacroByName('TableName').AsRaw := aTableName;
  lQuery.Open;
  for i := 0 to Pred(lQuery.FieldCount) do
  begin
    lColumn := Result.AddColumnInfo(UpperCase(lQuery.Fields[i].FieldName), lQuery.Fields[i].DataType);
    if SameText(lQuery.Fields[i].FieldName, lPKName) then
    begin
      lColumn.PrimaryKey := True;
    end;
  end;
  finally
  lMetaQryGetInfo.Free;
  lQuery.Free;
  end;
end;

constructor MapToAttribute.Create(const aMapToColumnName : string);
begin
  inherited Create();
  fMapToColumnName := aMapToColumnName;
end;

function MapToAttribute.GetMapToColumnName(): string;
begin
  Result := fMapToColumnName;
end;

constructor TransfORMField<T>.Create(const ormEntity : ItransfORMEntity; const aFieldName : string; aDataType : TFieldType; const aValue : Variant);
begin
  inherited Create(ormEntity, aFieldName, aDataType);
  fComparer := TEqualityComparer<T>.Default;
  SetFromVariant(aValue);
end;

procedure TransfORMField<T>.ApplyChanges();
begin
  if not fChanged then Exit;
  fOldData := Default(T);
  fChanged := False;
end;

function TransfORMField<T>.GetAsVariant<T>(const AValue: T): Variant;
var
  lValue: TValue;
begin
  lValue := TValue.From<T>(AValue);
  case lValue.Kind of
    tkEnumeration:
    begin
      if lValue.TypeInfo = TypeInfo(Boolean) then
        Result := lValue.AsBoolean
      else
        Result := lValue.AsOrdinal;
    end
    else
    begin
      Result := lValue.AsVariant;
    end;
  end;
end;

function TransfORMField<T>.GetOldValue(): Variant;
begin
  if fChanged then
  begin
    Result := GetAsVariant<T>(fOldData);
  end else
  begin
    Result := GetAsVariant<T>(fData)
  end;
end;

function TransfORMField<T>.GetValue(): Variant;
begin
  Result := GetAsVariant<T>(fData);
end;

procedure TransfORMField<T>.SetFromVariant(const aValue : Variant);
var
  val: TValue;
begin
  val := TValue.FromVariant(aValue);
  fData := val.AsType<T>;
end;

procedure TransfORMField<T>.SetValue(const aValue: Variant);
begin
  fOldData := fData;
  SetFromVariant(aValue);
  if not fComparer.Equals(fOldData, fData) then
  begin
    fChanged := True;
    if ormEntity.ImmediateCommit then
    begin
      ormEntity.Commit;
    end;
  end;
end;

constructor TransfORMField.Create(const ormEntity : ItransfORMEntity; const aFieldName : string; aDataType : TFieldType);
begin
  inherited Create();
  formEntity := ormEntity;
  fFieldName := aFieldName;
  fDataType := aDataType;
end;

function TransfORMField.ormEntity(): ItransfORMEntity;
begin
  Result := formEntity;
end;

constructor TDBColumnInfo.Create(const aColumnName: string; const aDataType: TFieldType);
begin
  inherited Create();
  fColumnName := aColumnName;
  fDataType := aDataType;
  fPrimaryKey := False;
end;

function TDBColumnInfo.GetColumnName(): string;
begin
  Result := fColumnName;
end;

function TDBColumnInfo.GetDataType(): TFieldType;
begin
  Result := fDataType;
end;

function TDBColumnInfo.GetPrimaryKey(): Boolean;
begin
  Result := fPrimaryKey;
end;

procedure TDBColumnInfo.SetColumnName(const aValue: string);
begin
  fColumnName := aValue;
end;

procedure TDBColumnInfo.SetDataType(const aValue: TFieldType);
begin
  fDataType := aValue;
end;

procedure TDBColumnInfo.SetPrimaryKey(const aValue: Boolean);
begin
  fPrimaryKey := aValue;
end;

constructor TDBTableInfo.Create(const aTableName : string);
begin
  inherited Create();
  fTableName := aTableName;
  fColumns := TCollections.CreateDictionary<string, TDBColumnInfo>([doOwnsValues]);
end;

function TDBTableInfo.AddColumnInfo(const aColumnName : string; const aColumnType : TFieldType): TDBColumnInfo;
begin
  Result := TDBColumnInfo.Create(aColumnName, aColumnType);
  fColumns.Add(aColumnName, Result);
end;

function TDBTableInfo.GetColumn(const aColumnName : string): TDBColumnInfo;
begin
  if not fColumns.TryGetValue(aColumnName, Result) then
  begin
    raise Exception.CreateFmt('Column %s not exists in table %s', [aColumnName, fTableName]);
  end;
end;

function TDBTableInfo.GetColumns(): IReadOnlyCollection<TDBColumnInfo>;
begin
  Result := fColumns.Values;
end;

function TDBTableInfo.GetTableName(): string;
begin
  Result := fTableName;
end;

procedure TDBTableInfo.SetTableName(const aValue: string);
begin
  fTableName := aValue;
end;

constructor TInterfaceEntity.Create(const aTableName : string);
begin
  inherited Create();
  fPrimaryKeyName := '';
  fTableName := aTableName;
  fFields := TCollections.CreateDictionary<string, TInterfaceField>([doOwnsValues]);
end;

function TInterfaceEntity.AddField(const aFieldName : string; const aMappedToColumn : string; aPK : Boolean): TInterfaceField;
begin
  Result := TInterfaceField.Create(aFieldName, aMappedToColumn, aPK);
  fFields.AddOrSetValue(aFieldName, Result);
  if aPK then
  begin
    fPrimaryKeyName := aMappedToColumn;
  end;
end;

constructor TInterfaceField.Create(const aFieldName : string; const aMappedToColumn : string; aPK : Boolean);
begin
  inherited Create();
  fFieldName := aFieldName;
  fMappedToColumn := aMappedToColumn;
  fPK := aPK;
end;

end.


