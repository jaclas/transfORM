unit transfORM.Entity;

interface

uses
  FireDAC.Stan.Intf,

  Spring.Collections;

type

  TInterfaceField = class
  private
    fFieldName : string;
    fMappedToColumn : string;
    fPK : Boolean;
    fColumnAttributes: TFDDataAttributes;
  public
    constructor Create(const aFieldName : string; const aMappedToColumn : string; aPK : Boolean; aColumnAttributes: TFDDataAttributes);
    property FieldName: string read fFieldName;
    property MappedToColumn: string read fMappedToColumn;
    property PK: Boolean read fPK;
    property ColumnAttributes: TFDDataAttributes read fColumnAttributes;
  end;

  TInterfaceEntity = class
  private
    fFields : IDictionary<string, TInterfaceField>;
    fPrimaryKeyName : string;
    fTableName: string;
  public
    constructor Create(const aTableName : string);
    function AddField(const aFieldName : string; const aMappedToColumn : string; aPK : Boolean; aColumnAttributes: TFDDataAttributes):
        TInterfaceField;
    property Fields: IDictionary<string, TInterfaceField> read fFields;
    property PrimaryKeyName: string read fPrimaryKeyName;
    property TableName: string read fTableName;
  end;

implementation

constructor TInterfaceField.Create(const aFieldName : string; const aMappedToColumn : string; aPK : Boolean; aColumnAttributes:
    TFDDataAttributes);
begin
  inherited Create();
  fFieldName := aFieldName;
  fMappedToColumn := aMappedToColumn;
  fPK := aPK;
  fColumnAttributes := aColumnAttributes;
end;

constructor TInterfaceEntity.Create(const aTableName : string);
begin
  inherited Create();
  fPrimaryKeyName := '';
  fTableName := aTableName;
  fFields := TCollections.CreateDictionary<string, TInterfaceField>([doOwnsValues]);
end;

function TInterfaceEntity.AddField(const aFieldName : string; const aMappedToColumn : string; aPK : Boolean; aColumnAttributes:
    TFDDataAttributes): TInterfaceField;
begin
  Result := TInterfaceField.Create(aFieldName, aMappedToColumn, aPK, aColumnAttributes);
  fFields.AddOrSetValue(aFieldName, Result);
  if aPK then
  begin
    fPrimaryKeyName := aMappedToColumn;
  end;
end;

end.

