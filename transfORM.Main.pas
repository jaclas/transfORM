unit TransfORM.Main;

interface

uses
  Spring,

  Data.DB,

  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,

  Spring.Collections,

  System.Generics.Defaults,
  System.Rtti,
  System.SyncObjs,
  System.SysUtils,
  System.TypInfo,

  TransfORM.DB,
  TransfORM.Entity;

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

  TransfORMField = class;

  ItransfORMEntity = interface(IInvokable) ['{F0568FB5-F855-4240-B68A-16FE01D68E07}']
    function GetConnection(): TFDConnection;
    function GetImmediateCommit(): Boolean;
    function HasChanges() : Boolean;
    function PrimaryKeyField() : TransfORMField;
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
    fCommitAction : TAction<TransfORMField>;
    fPrimaryKey : Boolean;
    fColumnAttributes: TFDDataAttributes;
  protected
    function GetOldValue(): Variant; virtual; abstract;
    function GetValue(): Variant; virtual; abstract;
    procedure SetValue(const aValue: Variant); virtual; abstract;
    procedure ApplyChanges(); virtual; abstract;
  public
    constructor Create(const aCommitAction : TAction<TransfORMField>; const aFieldName: string; aDataType: TFieldType; aColumnAttributes:
        TFDDataAttributes; aPrimaryKey: Boolean);
    property ColumnAttributes: TFDDataAttributes read fColumnAttributes;
    property Changed: Boolean read fChanged;
    property FieldName: string read fFieldName;
    property DataType: TFieldType read fDataType;
    property OldValue: Variant read GetOldValue;
    property PrimaryKey: Boolean read fPrimaryKey;
    property Value: Variant read GetValue write SetValue;
  end;

  TransfORMField<T> = class(TransfORMField)
  private
    fData : T;
    fOldData : T;
    fComparer: IEqualityComparer<T>;
  protected
    function GetAsVariant(const AValue: T): Variant;
    procedure SetFromVariant(const aValue : Variant);
    function GetOldValue(): Variant; override;
    function GetValue(): Variant; override;
    procedure SetValue(const aValue: Variant); override;
    procedure ApplyChanges(); override;
  public
    constructor Create(const aCommitAction : TAction<TransfORMField>; const aFieldName: string; aDataType: TFieldType; aColumnAttributes:
        TFDDataAttributes; aPrimaryKey: Boolean; const aValue: T);
    property OldValue: Variant read GetOldValue;
    property Value: Variant read GetValue write SetValue;
  end;

  TransfORMEntityVirtualInterface<K> = class(TVirtualInterface, ItransfORMEntity)
  private
    fFields : IDictionary<string, TransfORMField>;
    fConnection : TFDConnection;
    fImmediateCommit : Boolean;
    fInsertMode : Boolean;
    fPrimaryKeyInFields : Boolean;
    fPrimaryKeyName : string;
    fPrimaryKeyValue : K;
    fTableName: string;
    fCS : TCriticalSection;
    function CreateORMField(const aDBColumnName: string; const aValueField: TField; aColumnAttributes: TFDDataAttributes): TransfORMField;
    function ClonePKFieldWithValue(const aORMField: TransfORMField; aValue: K): TransfORMField;
    procedure CreateAndFillORMFields(const aEntity: TInterfaceEntity);
    procedure CreateORMFields(const aEntity: TInterfaceEntity);
    procedure UpdatePrimaryKeyFieldValue();
    procedure ImmediateCommitField(const aField : TransfORMField);
    procedure InternalCommit();
    procedure InsertData();
    procedure UpdateData();
  protected
    function GetAsVariant(const AValue: K): Variant;
    procedure Init(aTypeInfo: PTypeInfo; const aEntity: TInterfaceEntity; const aConnection: TFDConnection);
    procedure DoInvoke(aMethod: TRttiMethod; const aArgs: TArray<TValue>; out oResult: TValue);
  public
    constructor Create(aTypeInfo: PTypeInfo; const aEntity: TInterfaceEntity; const aConnection: TFDConnection; const aPrimaryKeyValue: K;
        aImmediateCommit : Boolean = True); overload;
    constructor Create(aTypeInfo: PTypeInfo; const aEntity: TInterfaceEntity; const aConnection: TFDConnection; aImmediateCommit : Boolean =
        True); overload;
    destructor Destroy(); override;
    function PrimaryKeyField(): TransfORMField;
    function GetConnection(): TFDConnection;
    function GetImmediateCommit(): Boolean;
    function HasChanges() : Boolean;
    procedure SetImmediateCommit(const aValue: Boolean);
    procedure Commit(aInSubthread : Boolean = False);
    property ImmediateCommit: Boolean read GetImmediateCommit write SetImmediateCommit;
    property Connection: TFDConnection read GetConnection;
  end;

  TTransfORM = class
  private
    fTypes : IDictionary<PTypeInfo, TInterfaceEntity>;
    fTables : IDictionary<string, TDBTableInfo>;
  protected
    function BuildDBTableInfo(const aTableName : string; const aConnection: TFDConnection): TDBTableInfo;
    function GetDBTableInfo(const aTableName : string; const aConnection: TFDConnection): TDBTableInfo;
    function ParseInterface(const aTypeInfo : PTypeInfo; const aConnection: TFDConnection): TInterfaceEntity;
    function GetInterfaceEntity(const aTypeInfo : PTypeInfo; const aConnection: TFDConnection): TInterfaceEntity;
  public
    constructor Create();
    destructor Destroy(); override;
    function GetInstance<I: IInvokable; K>(const aPrimaryKeyValue: K; const aConnection: TFDConnection; aImmediateCommit : Boolean = False): I;
    function NewInstance<I: IInvokable; K>(const aConnection: TFDConnection; aImmediateCommit : Boolean = False): I;
  end;


implementation

uses
  Data.SqlTimSt,

  FireDAC.Comp.DataSet,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Option,

  Spring.Reflection,

  System.Classes,
  System.Generics.Collections;


constructor TTransfORM.Create();
begin
  inherited Create();
  fTypes := TCollections.CreateDictionary<PTypeInfo, TInterfaceEntity>([doOwnsValues]);
  fTables := TCollections.CreateDictionary<string, TDBTableInfo>([doOwnsValues]);
end;

destructor TTransfORM.Destroy();
begin
  inherited;
  fTypes := nil;
  fTables := nil;
end;

function TTransfORM.GetDBTableInfo(const aTableName : string; const aConnection: TFDConnection): TDBTableInfo;
begin
  if not fTables.TryGetValue(aTableName, Result) then
  begin
    Result := BuildDBTableInfo(aTableName, aConnection);
    fTables.Add(aTableName, Result);
  end;
end;

function TTransfORM.GetInstance<I, K>(const aPrimaryKeyValue: K; const aConnection: TFDConnection; aImmediateCommit : Boolean = False): I;
var
  lEntity: TInterfaceEntity;
  lTypeInfo : PTypeInfo;
begin
  Assert(Assigned(aConnection), 'Missing connection');
  lTypeInfo := TypeInfo(I);
  lEntity := GetInterfaceEntity(lTypeInfo, aConnection);
  TransfORMEntityVirtualInterface<K>.Create(lTypeInfo, lEntity, aConnection, aPrimaryKeyValue, aImmediateCommit)
                                    .QueryInterface(lTypeInfo.TypeData.GUID, Result);
end;

function TTransfORM.NewInstance<I, K>(const aConnection: TFDConnection; aImmediateCommit : Boolean = False): I;
var
  lEntity: TInterfaceEntity;
  lTypeInfo : PTypeInfo;
begin
  Assert(Assigned(aConnection), 'Missing connection');
  lTypeInfo := TypeInfo(I);
  lEntity := GetInterfaceEntity(lTypeInfo, aConnection);
  TransfORMEntityVirtualInterface<K>.Create(lTypeInfo, lEntity, aConnection, aImmediateCommit)
                                    .QueryInterface(lTypeInfo.TypeData.GUID, Result);
end;

function TTransfORM.GetInterfaceEntity(const aTypeInfo : PTypeInfo; const aConnection: TFDConnection): TInterfaceEntity;
begin
  if not fTypes.TryGetValue(aTypeInfo, Result) then
  begin
    Result := ParseInterface(aTypeInfo, aConnection);
    fTypes.AddOrSetValue(aTypeInfo, Result);
  end;
end;

function TTransfORM.ParseInterface(const aTypeInfo : PTypeInfo; const aConnection: TFDConnection): TInterfaceEntity;
var
  lCtx : TRttiContext;
  lDBColumnInfo: TDBColumnInfo;
  lMethods: TArray<TRttiMethod>;
  lTableName: string;
  lType: TRttiType;
  lMethod: TRttiMethod;

  lDBTableInfo: TDBTableInfo;
  //lIndex: Integer;
  lMapTo: string;
  lMapToAttr: MapToAttribute;
  lMethodName: string;
begin
  lCtx := TRttiContext.Create;
  lType := lCtx.GetType(aTypeInfo);
  lMethods := lType.GetDeclaredMethods();

  lMapToAttr := lType.GetCustomAttribute<MapToAttribute>();
  if Assigned(lMapToAttr) then
  begin
    lTableName := lMapToAttr.MapToName;
  end else
  begin
    lTableName := Copy(aTypeInfo.Name, 2);
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
    //lIndex := lMethod.VirtualIndex;
    lDBColumnInfo := lDBTableInfo.Column[lMapTo];
    Result.AddField(lMethodName, lMapTo, lDBColumnInfo.PrimaryKey, lDBColumnInfo.ColumnAttributes);
  end;
end;

function TTransfORM.BuildDBTableInfo(const aTableName : string; const aConnection: TFDConnection): TDBTableInfo;
var
  lAttrInt: Integer;
  lColumn: TDBColumnInfo;
  lColumnAttributes: TFDDataAttributes;
  lColumnDataType: TFDDataType;
  lColumnName: string;
  lPKName: string;
  lMetaQryGetInfo: TFDMetaInfoQuery;
begin
  lMetaQryGetInfo := TFDMetaInfoQuery.Create(nil);
  try
  lMetaQryGetInfo.Connection := aConnection;

  lMetaQryGetInfo.TableKinds := [tkTable];
  lMetaQryGetInfo.BaseObjectName := aTableName;
  lMetaQryGetInfo.ObjectName := aTableName;
  lMetaQryGetInfo.MetaInfoKind := mkPrimaryKeyFields;
  lMetaQryGetInfo.Open;
  lPKName := lMetaQryGetInfo.FieldByName('COLUMN_NAME').AsString;
  lMetaQryGetInfo.Close;
  lMetaQryGetInfo.MetaInfoKind := mkTableFields;
  lMetaQryGetInfo.Open;
  Result := TDBTableInfo.Create(aTableName);
  while not lMetaQryGetInfo.Eof do
  begin
//      COLUMN_TYPENAME (VARCHAR, INTEGER, ITD.)
//      COLUMN_LENGTH
    lColumnName := lMetaQryGetInfo.FieldByName('COLUMN_NAME').AsString;
    lColumnDataType := TFDDataType(lMetaQryGetInfo.FieldByName('COLUMN_DATATYPE').AsInteger);
    lAttrInt := lMetaQryGetInfo.FieldByName('COLUMN_ATTRIBUTES').AsInteger;
    lColumnAttributes := TFDDataAttributes(Pointer(@lAttrInt)^);
    lColumn := Result.AddColumnInfo(UpperCase(lColumnName.ToUpper), lColumnDataType, lColumnAttributes);
    if SameText(lColumnName, lPKName) then
    begin
      lColumn.PrimaryKey := True;
    end;
    lMetaQryGetInfo.Next;
  end;
  finally
  lMetaQryGetInfo.Free;
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

constructor TransfORMField.Create(const aCommitAction : TAction<TransfORMField>; const aFieldName: string; aDataType: TFieldType;
    aColumnAttributes: TFDDataAttributes; aPrimaryKey: Boolean);
begin
  inherited Create();
  fPrimaryKey := aPrimaryKey;
  fFieldName := aFieldName;
  fDataType := aDataType;
  fColumnAttributes := aColumnAttributes;
  fCommitAction := aCommitAction;
end;

constructor TransfORMField<T>.Create(const aCommitAction : TAction<TransfORMField>; const aFieldName: string; aDataType: TFieldType;
    aColumnAttributes: TFDDataAttributes; aPrimaryKey: Boolean; const aValue: T);
begin
  inherited Create(aCommitAction, aFieldName, aDataType, aColumnAttributes, aPrimaryKey);
  fComparer := TEqualityComparer<T>.Default;
  fData := aValue;
end;

procedure TransfORMField<T>.ApplyChanges();
begin
  if not fChanged then Exit;
  fOldData := Default(T);
  fChanged := False;
end;

function TransfORMField<T>.GetAsVariant(const AValue: T): Variant;
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
    Result := GetAsVariant(fOldData);
  end else
  begin
    Result := GetAsVariant(fData)
  end;
end;

function TransfORMField<T>.GetValue(): Variant;
begin
  Result := GetAsVariant(fData);
end;

procedure TransfORMField<T>.SetFromVariant(const aValue : Variant);
var
  lValue: TValue;
begin
  lValue := TValue.FromVariant(aValue);
  fData := lValue.AsType<T>;
end;

procedure TransfORMField<T>.SetValue(const aValue: Variant);
begin
  if fPrimaryKey then
  begin
    raise Exception.Create('The value of the primary key field can''t be changed!');
  end;
  fOldData := fData;
  SetFromVariant(aValue);
  if not fComparer.Equals(fOldData, fData) then
  begin
    fChanged := True;
    fCommitAction(self);
  end;
end;

constructor TransfORMEntityVirtualInterface<K>.Create(aTypeInfo: PTypeInfo; const aEntity: TInterfaceEntity; const aConnection:
    TFDConnection; const aPrimaryKeyValue: K; aImmediateCommit : Boolean = True);
begin
  inherited Create(aTypeInfo, DoInvoke);
  fInsertMode := False;
  fPrimaryKeyValue := aPrimaryKeyValue;
  Init(aTypeInfo, aEntity, aConnection);
  fImmediateCommit := aImmediateCommit;
  CreateAndFillORMFields(aEntity);
end;

constructor TransfORMEntityVirtualInterface<K>.Create(aTypeInfo: PTypeInfo; const aEntity: TInterfaceEntity; const aConnection: TFDConnection; aImmediateCommit : Boolean = True);
begin
  inherited Create(aTypeInfo, DoInvoke);
  fInsertMode := True;
  fPrimaryKeyValue := Default(K);
  Init(aTypeInfo, aEntity, aConnection);
  fImmediateCommit := aImmediateCommit;
  CreateORMFields(aEntity);
end;

destructor TransfORMEntityVirtualInterface<K>.Destroy();
begin
  inherited;
  fCS.Free;
end;

function TransfORMEntityVirtualInterface<K>.ClonePKFieldWithValue(const aORMField: TransfORMField; aValue: K): TransfORMField;
begin
  if aORMField.PrimaryKey then
  begin
    Result := TransfORMField<K>.Create(ImmediateCommitField, aORMField.FieldName, aORMField.DataType, aORMField.ColumnAttributes, True, aValue);
  end else
  begin
    raise Exception.Create('This is not a PK field!');
  end;
end;

procedure TransfORMEntityVirtualInterface<K>.Commit(aInSubthread : Boolean = False);
begin
  if aInSubthread then
  begin
    fCS.Enter;
    try
      TThread.CreateAnonymousThread(procedure
                                    begin
                                      try
                                        InternalCommit();
                                      finally
                                        fCS.Leave;
                                      end;
                                    end).Start;
    except
      fCS.Leave;
    end;
  end else
  begin
    fCS.Enter;
    try
    InternalCommit();
    finally
    fCS.Leave;
    end;
  end;
end;

function TransfORMEntityVirtualInterface<K>.CreateORMField(const aDBColumnName: string; const aValueField: TField; aColumnAttributes:
    TFDDataAttributes): TransfORMField;
var
  lPrimaryKey: Boolean;
begin
  lPrimaryKey := SameText(aDBColumnName, fPrimaryKeyName);
  case aValueField.DataType of
  // as ItransfORMEntity
  ftSmallint : Result := TransfORMField<SmallInt>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsInteger);
  ftShortint : Result := TransfORMField<ShortInt>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsInteger);
  ftByte : Result := TransfORMField<Byte>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsInteger);
  ftWord : Result := TransfORMField<Word>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsInteger);
  ftAutoInc,
  ftInteger : Result := TransfORMField<Integer>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsInteger);
  ftLargeint : Result := TransfORMField<Int64>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsLargeInt);
  ftLongWord : Result := TransfORMField<LongWord>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsLongWord);
  ftBCD,
  ftFMTBcd: Result := TransfORMField<Currency>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsCurrency);
  ftCurrency : Result := TransfORMField<Currency>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsCurrency);
  TFieldType.ftSingle : Result := TransfORMField<Single>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsSingle);
  ftFloat : Result := TransfORMField<Double>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsFloat);
  ftDateTime,
  ftDate,
  ftTime : Result := TransfORMField<TDate>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsDateTime);
  ftTimeStamp,
  ftTimeStampOffset : Result := TransfORMField<TSQLTimeStamp>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsSQLTimeStamp);
  ftBoolean : Result := TransfORMField<Boolean>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsBoolean);
  ftString,
  ftMemo,
  ftBlob,
  ftWideMemo,
  ftFixedChar,
  ftFixedWideChar,
  ftWideString: Result := TransfORMField<string>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsString);
  ftVariant : Result := TransfORMField<Variant>.Create(ImmediateCommitField, aDBColumnName, aValueField.DataType, aColumnAttributes, lPrimaryKey, aValueField.AsVariant);
  else
    begin
      raise Exception.CreateFmt('Unknown data type: %s for column: %s', [Spring.TEnum.GetName<TFieldType>(aValueField.DataType), aDBColumnName]);
    end;
  end;
end;

procedure TransfORMEntityVirtualInterface<K>.CreateAndFillORMFields(const aEntity: TInterfaceEntity);
var
  lField : TPair<string, TInterfaceField>;
  lFields: string;
  lORMField: TransfORMField;
  lQuery: TFDQuery;
  lSelect: string;
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
  lQuery.ParamByName('KEY').Value := GetAsVariant(fPrimaryKeyValue);
  lQuery.Open;
  if lQuery.IsEmpty then
  begin
    raise Exception.CreateFmt('The primary key value %s does not exist in the table: %s', [lQuery.ParamByName('KEY').Value, fTableName]);
  end;
  fPrimaryKeyInFields := False;
  for lField in aEntity.Fields do
  begin
    lORMField := CreateORMField(lField.Value.MappedToColumn, lQuery.FieldByName(lField.Value.MappedToColumn), lField.Value.ColumnAttributes);
    fFields.Add(lField.Value.FieldName, lORMField);
    fPrimaryKeyInFields := fPrimaryKeyInFields or lORMField.PrimaryKey;
  end;
  finally
  lQuery.Free;
  end;
end;

procedure TransfORMEntityVirtualInterface<K>.CreateORMFields(const aEntity: TInterfaceEntity);
var
  lField : TPair<string, TInterfaceField>;
  lFields: string;
  lORMField: TransfORMField;
  lQuery: TFDQuery;
  lSelect: string;
begin
  lSelect := 'SELECT %s FROM %s WHERE 1 = 0';
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
  lQuery.Open;
  fPrimaryKeyInFields := False;
  for lField in aEntity.Fields do
  begin
    lORMField := CreateORMField(lField.Value.MappedToColumn, lQuery.FieldByName(lField.Value.MappedToColumn), lField.Value.ColumnAttributes);
    fFields.Add(lField.Value.FieldName, lORMField);
    fPrimaryKeyInFields := fPrimaryKeyInFields or lORMField.PrimaryKey;
  end;
  finally
  lQuery.Free;
  end;
end;

procedure TransfORMEntityVirtualInterface<K>.DoInvoke(aMethod: TRttiMethod; const aArgs: TArray<TValue>; out oResult: TValue);
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
  if s = 'PRIMARYKEYFIELD' then
  begin
    oResult := TValue.From<TransfORMField>(PrimaryKeyField());
  end else
  begin
    fFields.TryGetValue(s, lField);
    oResult := TValue.From(lField, TransfORMField);// lField.ClassType);
  end;
end;

function TransfORMEntityVirtualInterface<K>.GetAsVariant(const AValue: K): Variant;
var
  lValue: TValue;
begin
  lValue := TValue.From<K>(AValue);
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

function TransfORMEntityVirtualInterface<K>.GetConnection(): TFDConnection;
begin
  Result := fConnection;
end;

function TransfORMEntityVirtualInterface<K>.GetImmediateCommit(): Boolean;
begin
  Result := fImmediateCommit;
end;

function TransfORMEntityVirtualInterface<K>.HasChanges(): Boolean;
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

procedure TransfORMEntityVirtualInterface<K>.ImmediateCommitField(const aField : TransfORMField);
begin
  if fImmediateCommit then
  begin
    if fInsertMode then
    begin
      InsertData();
    end else
    begin
      UpdateData();
    end;
  end;
end;

procedure TransfORMEntityVirtualInterface<K>.Init(aTypeInfo: PTypeInfo; const aEntity: TInterfaceEntity; const aConnection: TFDConnection);
begin
  fCS := TCriticalSection.Create;
  fFields := TCollections.CreateDictionary<string, TransfORMField>([doOwnsValues]);
  fTableName := UpperCase(aEntity.TableName);
  fPrimaryKeyName := aEntity.PrimaryKeyName;
  fConnection := aConnection;
end;

procedure TransfORMEntityVirtualInterface<K>.InsertData();
var
  lQry: TFDQuery;
  lField: TransfORMField;
  lFields: string;
  lPKey: string;
  lSQL: string;
  lValue: TValue;
begin
  lSQL := 'SELECT %s FROM %s WHERE 0 = 1';
  lFields := fPrimaryKeyName + ',';
  for lField in fFields.Values do
  begin
    if lField.Changed then
    begin
      lFields := lFields + lField.FieldName + ',';
    end;
  end;
  lFields := Copy(lFields, 1, Length(lFields) - 1);
  lPKey := fPrimaryKeyName + '=:' + fPrimaryKeyName;
  lSQL := Format(lSQL, [lFields, fTableName]);
  lQry := TFDQuery.Create(nil);
  try
  lQry.Connection := fConnection;
  lQry.UpdateOptions.KeyFields := fPrimaryKeyName;
  lQry.UpdateOptions.UpdateTableName := fTableName;
  lQry.UpdateOptions.FetchGeneratorsPoint := gpImmediate;
  lQry.SQL.Text := lSQL;
  lQry.Open;
  lQry.Append;
  for lField in fFields.Values do
  begin
    {
    caSearchable, caAllowNull, caFixedLen,
    caBlobData, caReadOnly, caAutoInc, caROWID, caDefault,
    caRowVersion, caInternal, caCalculated, caVolatile, caUnnamed,
    caVirtual, caBase, caExpr
    }
    if lField.Changed then
    begin
      lQry.FieldByName(lField.FieldName).Value := lField.Value;
      lField.ApplyChanges();
    end;
  end;
  lQry.Post;
  lValue := TValue.FromVariant(lQry.FieldByName(fPrimaryKeyName).AsVariant);
  fPrimaryKeyValue := lValue.AsType<K>();
  UpdatePrimaryKeyFieldValue();
  fConnection.Commit;
  fInsertMode := False;
  finally
  lQry.Free;
  end;
end;

procedure TransfORMEntityVirtualInterface<K>.InternalCommit();
begin
  if not HasChanges() then Exit;
  if fInsertMode then
  begin
    InsertData();
  end else
  begin
    UpdateData();
  end;
end;

function TransfORMEntityVirtualInterface<K>.PrimaryKeyField(): TransfORMField;
begin
  if not fFields.TryGetValue(fPrimaryKeyName, Result) then
  begin
    Result := Nil;
  end;
end;

procedure TransfORMEntityVirtualInterface<K>.SetImmediateCommit(const aValue: Boolean);
begin
  fImmediateCommit := aValue;
  if fImmediateCommit then
  begin
    Commit();
  end;
end;

procedure TransfORMEntityVirtualInterface<K>.UpdateData();
var
  lQry: TFDQuery;
  lField: TransfORMField;
  lFields: string;
  lPKey: string;
  lSQL: string;
begin
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
  lQry.ParamByName(fPrimaryKeyName).Value := GetAsVariant(fPrimaryKeyValue);
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

procedure TransfORMEntityVirtualInterface<K>.UpdatePrimaryKeyFieldValue();
var
  lPKField: TransfORMField;
begin
  if fFields.TryGetValue(fPrimaryKeyName, lPKField) then
  begin
    fFields.AddOrSetValue(fPrimaryKeyName, ClonePKFieldWithValue(lPKField, fPrimaryKeyValue));
  end;
end;

end.


