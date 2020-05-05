unit transfORM.DB;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,

  Spring.Collections;

type

  TDBColumnInfo = class
  private
    fDataType: TFDDataType;
    fPrimaryKey: Boolean;
    fColumnAttributes : TFDDataAttributes;
    fColumnName: string;
  protected
  public
    constructor Create(const aColumnName: string; const aDataType: TFDDataType; aColumnAttributes: TFDDataAttributes);
    property ColumnAttributes: TFDDataAttributes read fColumnAttributes;
    property ColumnName: string read fColumnName;
    property DataType: TFDDataType read fDataType;
    property PrimaryKey: Boolean read fPrimaryKey write fPrimaryKey;
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
    function AddColumnInfo(const aColumnName: string; const aDataType: TFDDataType; aColumnAttributes: TFDDataAttributes): TDBColumnInfo;
    property Column[const aColumnName : string]: TDBColumnInfo read GetColumn; default;
    property Columns: IReadOnlyCollection<TDBColumnInfo> read GetColumns;
    property TableName: string read GetTableName write SetTableName;
  end;

implementation

uses
  System.SysUtils;

constructor TDBTableInfo.Create(const aTableName : string);
begin
  inherited Create();
  fTableName := aTableName;
  fColumns := TCollections.CreateDictionary<string, TDBColumnInfo>([doOwnsValues]);
end;

function TDBTableInfo.AddColumnInfo(const aColumnName: string; const aDataType: TFDDataType; aColumnAttributes: TFDDataAttributes):
    TDBColumnInfo;
begin
  Result := TDBColumnInfo.Create(aColumnName, aDataType, aColumnAttributes);
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

constructor TDBColumnInfo.Create(const aColumnName: string; const aDataType: TFDDataType; aColumnAttributes: TFDDataAttributes);
begin
  inherited Create();
  fColumnName := aColumnName;
  fDataType := aDataType;
  fColumnAttributes := aColumnAttributes;
  fPrimaryKey := False;
end;

end.

