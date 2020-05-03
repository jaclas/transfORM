unit Demo;

interface

uses
  transfORM.Main,

  Data.DB,

  FireDAC.Comp.Client,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Error,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Pool,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,

  System.Classes,
  System.SysUtils,
  System.Variants,

  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Graphics,

  Winapi.Messages,
  Winapi.Windows, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ComCtrls;

type
  TfrmMain = class(TForm)
    conSQLite: TFDConnection;
    dbgrdData: TDBGrid;
    fdqryData: TFDQuery;
    metaqryTables: TFDMetaInfoQuery;
    dtsrcData: TDataSource;
    dtsrcTables: TDataSource;
    dbgrdInfo: TDBGrid;
    mmoCode: TMemo;
    btnTest: TBitBtn;
    metaqryFields: TFDMetaInfoQuery;
    dtsrcFields: TDataSource;
    dbgrdFields: TDBGrid;
    btnGenerate: TBitBtn;
    pgcMain: TPageControl;
    tsMeta: TTabSheet;
    tsData: TTabSheet;
    tsCode: TTabSheet;
    dbgrd2: TDBGrid;
    dtsrcPK: TDataSource;
    metaqryPK: TFDMetaInfoQuery;
    edtDB: TEdit;
    btnConnect: TBitBtn;
    procedure btnConnectClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure metaqryTablesAfterScroll(DataSet: TDataSet);
  private
    flTableName: string;
  protected
    function GenerateCode(): string;
  end;

  IEmployees = interface(ItransfORMEntity)
    function EmployeeID(): TransfORMField;
    function LastName(): TransfORMField;
    function FirstName(): TransfORMField;
    function Title(): TransfORMField;
    function TitleOfCourtesy(): TransfORMField;
    function BirthDate(): TransfORMField;
    function HireDate(): TransfORMField;
    function Address(): TransfORMField;
    function City(): TransfORMField;
    function Region(): TransfORMField;
    function PostalCode(): TransfORMField;
    function Country(): TransfORMField;
    function HomePhone(): TransfORMField;
    function Extension(): TransfORMField;
    function Photo(): TransfORMField;
    function Notes(): TransfORMField;
    function ReportsTo(): TransfORMField;
    function PhotoPath(): TransfORMField;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

type

  TVar = record
  private
    fData : Variant;
    fOldData : Variant;
    fChanged : Boolean;
  public
    constructor Create(const aValue : Integer); overload;
    constructor Create(const aValue : string); overload;
    function Changed(): Boolean;
    class operator Implicit(const value: string): TVar;
    class operator Implicit(const value: Integer): TVar;
    class operator Implicit(const value: Variant): TVar;
    class operator Implicit(const value: TVar): string;
    class operator Implicit(const value: TVar): Integer;
    class operator Implicit(const value: TVar): Variant;
  end;

function TVar.Changed(): Boolean;
begin
  Result := fChanged;
end;

class operator TVar.Implicit(const value: TVar): Variant;
begin
  Result := value.fData;
end;

class operator TVar.Implicit(const value: TVar): Integer;
begin
  Result := value.fData;
end;

class operator TVar.Implicit(const value: TVar): string;
begin
  Result := value.fData;
end;

class operator TVar.Implicit(const value: Variant): TVar;
begin
  Result.fOldData := Result.fData;
  Result.fData := value;
  Result.fChanged := True;
end;

class operator TVar.Implicit(const value: Integer): TVar;
begin
  Result.fOldData := Result.fData;
  Result.fData := value;
  Result.fChanged := True;
end;

class operator TVar.Implicit(const value: string): TVar;
begin
  Result.fOldData := Result.fData;
  Result.fData := value;
  Result.fChanged := True;
end;

constructor TVar.Create(const aValue: string);
begin
  fChanged := False;
  fData := aValue;
end;

constructor TVar.Create(const aValue: Integer);
begin
  fChanged := False;
  fData := aValue;
end;

procedure TfrmMain.btnConnectClick(Sender: TObject);
begin
  conSQLite.Params.Database := edtDB.Text;
  metaqryTables.Open;
end;

procedure TfrmMain.btnGenerateClick(Sender: TObject);
begin
  mmoCode.Lines.Text := GenerateCode();
end;

procedure TfrmMain.btnTestClick(Sender: TObject);
var
  b: Boolean;
  lORM : TTransfORM;
  i: Integer;
  s: string;
  Employee: IEmployees;
begin
  lORM := TTransfORM.Create();
  Employee := lORM.NewInstance<IEmployees, Integer>(conSQLite);
  Employee.ImmediateCommit := False;
  Employee.FirstName.Value := 'Józef';
  Employee.LastName.Value := 'Pampkin';
  Employee.City.Value := 'Miasteczko';
  Employee.Country.Value := 'Polska';
  Employee.Commit();
  Employee.Region.Value := 'Podkarpackie';
  Employee.Commit();

  Employee := lORM.GetInstance<IEmployees, Integer>(3, conSQLite);
  i := Employee.EmployeeID.Value;
  s := Employee.Country.Value;
  s := Employee.City.Value;
  Employee.ImmediateCommit := False;
  Employee.LastName.Value := Employee.LastName.Value + '_test';
  b := Employee.HasChanges;
  Employee.Commit();
  b := Employee.HasChanges;
end;

function TfrmMain.GenerateCode(): string;
const
  cIntf = '  I%s = interface(ItransfORMEntity)' + sLineBreak +
          '%s' + sLineBreak +
          '  end;';
  cMeth = '    function %s(): TransfORMField; //type %s';
var
  s: string;

begin
  metaqryFields.DisableControls;
  try
  s := '';
  metaqryFields.First;
  while not metaqryFields.Eof do
  begin
    s := s + Format(cMeth, [metaqryFields.FieldByName('COLUMN_NAME').AsString, metaqryFields.FieldByName('COLUMN_TYPENAME').AsString]);
    metaqryFields.Next;
    if not metaqryFields.Eof then
    begin
      s := s + sLineBreak;
    end;
  end;
  Result := Format(cIntf, [flTableName, s]);
  finally
  metaqryFields.EnableControls;
  end;
end;

procedure TfrmMain.metaqryTablesAfterScroll(DataSet: TDataSet);

  procedure ConfGrid(dbGrid : TDBGrid);
  var
    i : Integer;
  begin
    for i := 0 to Pred(dbGrid.Columns.Count) do
    begin
      dbGrid.Columns[i].Width := 150;
    end;
  end;

begin
  fdqryData.Close;
  flTableName := metaqryTables.FieldByName('TABLE_NAME').AsString;
  fdqryData.MacroByName('TableName').AsRaw := flTableName;
  fdqryData.Open;

  metaqryFields.Close;
  metaqryFields.BaseObjectName := flTableName;
  metaqryFields.ObjectName := flTableName;
  metaqryFields.Open;

  metaqryPK.Close;
  metaqryPK.BaseObjectName := flTableName;
  metaqryPK.ObjectName := flTableName;
  metaqryPK.Open;

  ConfGrid(dbgrd2);
//  FireDAC.Stan.Intf.TFDDataAttributes
// COLUMN_ATTRIBUTES z fieldów
//
//  TFDDataAttribute = (caSearchable, caAllowNull, caFixedLen,
//    caBlobData, caReadOnly, caAutoInc, caROWID, caDefault,
//    caRowVersion, caInternal, caCalculated, caVolatile, caUnnamed,
//    caVirtual, caBase, caExpr);
//  TFDDataAttributes = set of TFDDataAttribute;
end;

end.

