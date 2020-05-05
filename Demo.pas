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
  Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls;

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
    btnTestA: TBitBtn;
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
    tsTests: TTabSheet;
    lbl1: TLabel;
    spl1: TSplitter;
    statBar: TStatusBar;
    tmr1: TTimer;
    btnTestB: TBitBtn;
    btnTestC: TBitBtn;
    mmoLog: TMemo;
    procedure btnConnectClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure btnTestAClick(Sender: TObject);
    procedure btnTestBClick(Sender: TObject);
    procedure btnTestCClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure metaqryTablesAfterScroll(DataSet: TDataSet);
    procedure tmr1Timer(Sender: TObject);
  private
    flTableName: string;
  protected
    function GenerateCode(): string;
    procedure Log(const aStr : string); overload;
    procedure Log(const aStr : string; const aArgs : array of const); overload;
    procedure LogSeparator();
  end;

  IEmployees = interface(ItransfORMEntity)
    /// <summary>INTEGER type field </summary>
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

  TFieldTypeHelper = record helper for TFieldType
    function AsString(): string;
  end;
var
  frmMain: TfrmMain;

implementation

uses
  FastMM4,
  Spring;

{$R *.dfm}


procedure TfrmMain.btnConnectClick(Sender: TObject);
begin
  conSQLite.Params.Database := edtDB.Text;
  metaqryTables.Open;
end;

procedure TfrmMain.btnGenerateClick(Sender: TObject);
begin
  mmoCode.Lines.Text := GenerateCode();
end;

procedure TfrmMain.btnTestAClick(Sender: TObject);
var
  lORM : TTransfORM;
  Employee: IEmployees;
  lEmployeeID: Integer;
begin
  lORM := TTransfORM.Create();
  try
  lEmployeeID := 3;
  Employee := lORM.GetInstance<IEmployees, Integer>(lEmployeeID, conSQLite);

  Log('Test A');
  Log('Employee.EmployeeID: %s ==> FieldType : %s, variant type: %s', [Employee.EmployeeID.Value,
                                                              Employee.EmployeeID.DataType.AsString,
                                                              VarTypeAsText(VarType(Employee.EmployeeID.Value))]);
  Log('Employee.FirstName: %s ==> FieldType : %s, variant type: %s', [Employee.FirstName.Value,
                                                                     Employee.FirstName.DataType.AsString,
                                                                     VarTypeAsText(VarType(Employee.FirstName.Value))]);
  Log('Employee.LastName: %s ==> FieldType : %s, variant type: %s', [Employee.LastName.Value,
                                                                    Employee.LastName.DataType.AsString,
                                                                    VarTypeAsText(VarType(Employee.LastName.Value))]);
  Log('Employee.City: %s ==> FieldType : %s, variant type: %s', [Employee.City.Value,
                                                                Employee.City.DataType.AsString,
                                                                VarTypeAsText(VarType(Employee.City.Value))]);
  Log('Employee.Country: %s ==> FieldType : %s, variant type: %s', [Employee.Country.Value,
                                                                   Employee.Country.DataType.AsString,
                                                                   VarTypeAsText(VarType(Employee.Country.Value))]);
  LogSeparator();
  finally
  lORM.Free;
  end;
end;

procedure TfrmMain.btnTestBClick(Sender: TObject);
var
  lORM : TTransfORM;
  Employee: IEmployees;
  lEmployeeID: Integer;
begin
  lORM := TTransfORM.Create();
  try
  lEmployeeID := 5;
  Employee := lORM.GetInstance<IEmployees, Integer>(lEmployeeID, conSQLite);
  Log('Test B');
  Log('Employee.EmployeeID: %s ==> FieldType : %s, variant type: %s', [Employee.EmployeeID.Value,
                                                              Employee.EmployeeID.DataType.AsString,
                                                              VarTypeAsText(VarType(Employee.EmployeeID.Value))]);
  Log('Employee.Country: %s ==> FieldType : %s, variant type: %s', [Employee.Country.Value,
                                                                   Employee.Country.DataType.AsString,
                                                                   VarTypeAsText(VarType(Employee.Country.Value))]);

  Log('Employee.City: %s ==> FieldType : %s, variant type: %s', [Employee.City.Value,
                                                                Employee.City.DataType.AsString,
                                                                VarTypeAsText(VarType(Employee.City.Value))]);
  Log('Employee.HasChanges(): %s', [BoolToStr(Employee.HasChanges, True)]);

  Employee.City.Value := Employee.City.Value + Random(1000).ToString;
  Log('Employee.City.Value := Employee.City.Value + Random(1000).ToString;');
  Log('Employee.HasChanges(): %s', [BoolToStr(Employee.HasChanges, True)]);
  Log('Employee City: %s ==> FieldType : %s, variant type: %s', [Employee.City.Value,
                                                                Employee.City.DataType.AsString,
                                                                VarTypeAsText(VarType(Employee.City.Value))]);
  Employee.Commit();
  Log('Employee.HasChanges(): %s', [BoolToStr(Employee.HasChanges, True)]);
  LogSeparator();
  finally
  lORM.Free;
  end;
end;

procedure TfrmMain.btnTestCClick(Sender: TObject);
var
  b: Boolean;
  lORM : TTransfORM;
  i: Integer;
  s: string;
  Employee: IEmployees;
begin
  lORM := TTransfORM.Create();
  try
  Employee := lORM.NewInstance<IEmployees, Integer>(conSQLite);
  Employee.FirstName.Value := 'Łucjan';
  Employee.LastName.Value := 'Brzęczyszczyński';
  Employee.City.Value := 'Miasteczko';
  Employee.Region.Value := 'Mazowieckie';
  Employee.Country.Value := 'Polska';
  Log('Test C');
  Log('Employee.EmployeeID: %s ==> FieldType : %s, variant type: %s', [Employee.EmployeeID.Value,
                                                              Employee.EmployeeID.DataType.AsString,
                                                              VarTypeAsText(VarType(Employee.EmployeeID.Value))]);
  Log('Employee.FirstName: %s ==> FieldType : %s, variant type: %s', [Employee.FirstName.Value,
                                                                     Employee.FirstName.DataType.AsString,
                                                                     VarTypeAsText(VarType(Employee.FirstName.Value))]);
  Log('Employee.LastName: %s ==> FieldType : %s, variant type: %s', [Employee.LastName.Value,
                                                                    Employee.LastName.DataType.AsString,
                                                                    VarTypeAsText(VarType(Employee.LastName.Value))]);
  Log('Employee.Country: %s ==> FieldType : %s, variant type: %s', [Employee.Country.Value,
                                                                   Employee.Country.DataType.AsString,
                                                                   VarTypeAsText(VarType(Employee.Country.Value))]);
  Log('Employee.Region: %s ==> FieldType : %s, variant type: %s', [Employee.Region.Value,
                                                                  Employee.Region.DataType.AsString,
                                                                  VarTypeAsText(VarType(Employee.Region.Value))]);
  Log('Employee.City: %s ==> FieldType : %s, variant type: %s', [Employee.City.Value,
                                                                Employee.City.DataType.AsString,
                                                                VarTypeAsText(VarType(Employee.City.Value))]);
  Log('Employee.HasChanges(): %s', [BoolToStr(Employee.HasChanges, True)]);

  Employee.City.Value := Employee.City.Value + Random(1000).ToString;

  Log('Employee City: %s ==> FieldType : %s, variant type: %s', [Employee.City.Value,
                                                                Employee.City.DataType.AsString,
                                                                VarTypeAsText(VarType(Employee.City.Value))]);

  Employee.Commit();
  Log('Employee.Commit()');
  Log('Employee.HasChanges(): %s', [BoolToStr(Employee.HasChanges, True)]);
  Log('Employee.Region.Value := ''Podkarpackie'';');
  Employee.Region.Value := 'Podkarpackie';
  Log('Employee.HasChanges(): %s', [BoolToStr(Employee.HasChanges, True)]);
  Log('Employee.EmployeeID: %s ==> FieldType : %s, variant type: %s', [Employee.EmployeeID.Value,
                                                              Employee.EmployeeID.DataType.AsString,
                                                              VarTypeAsText(VarType(Employee.EmployeeID.Value))]);
  Log('Employee.FirstName: %s ==> FieldType : %s, variant type: %s', [Employee.FirstName.Value,
                                                                     Employee.FirstName.DataType.AsString,
                                                                     VarTypeAsText(VarType(Employee.FirstName.Value))]);
  Log('Employee.LastName: %s ==> FieldType : %s, variant type: %s', [Employee.LastName.Value,
                                                                    Employee.LastName.DataType.AsString,
                                                                    VarTypeAsText(VarType(Employee.LastName.Value))]);
  Log('Employee.Country: %s ==> FieldType : %s, variant type: %s', [Employee.Country.Value,
                                                                   Employee.Country.DataType.AsString,
                                                                   VarTypeAsText(VarType(Employee.Country.Value))]);
  Log('Employee.Region: %s ==> FieldType : %s, variant type: %s', [Employee.Region.Value,
                                                                  Employee.Region.DataType.AsString,
                                                                  VarTypeAsText(VarType(Employee.Region.Value))]);
  Log('Employee.City: %s ==> FieldType : %s, variant type: %s', [Employee.City.Value,
                                                                Employee.City.DataType.AsString,
                                                                VarTypeAsText(VarType(Employee.City.Value))]);
  Employee.Commit();
  Log('Employee.Commit()');
  Log('Employee.HasChanges(): %s', [BoolToStr(Employee.HasChanges, True)]);
  LogSeparator();
  finally
  lORM.Free;
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  pgcMain.ActivePageIndex := 0;
end;

function TfrmMain.GenerateCode(): string;
const
  cIntf = '  I%s = interface(ItransfORMEntity)' + sLineBreak +
          '%s' + sLineBreak +
          '  end;';
  cMeth = '    /// <summary>%s type field</summary>' + sLineBreak +
          '    function %s(): TransfORMField;';
var
  s: string;
begin
  metaqryFields.DisableControls;
  try
  s := '';
  metaqryFields.First;
  while not metaqryFields.Eof do
  begin
    s := s + Format(cMeth, [metaqryFields.FieldByName('COLUMN_TYPENAME').AsString, metaqryFields.FieldByName('COLUMN_NAME').AsString]);
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

procedure TfrmMain.Log(const aStr : string);
begin
  mmoLog.Lines.Add(aStr);
end;

procedure TfrmMain.Log(const aStr : string; const aArgs : array of const);
begin
  mmoLog.Lines.Add(Format(aStr, aArgs));
end;

procedure TfrmMain.LogSeparator();
begin
  mmoLog.Lines.Add('---------------------');
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

  //ConfGrid(dbgrd2);
//  FireDAC.Stan.Intf.TFDDataAttributes
// COLUMN_ATTRIBUTES z fieldów
//
//  TFDDataAttribute = (caSearchable, caAllowNull, caFixedLen,
//    caBlobData, caReadOnly, caAutoInc, caROWID, caDefault,
//    caRowVersion, caInternal, caCalculated, caVolatile, caUnnamed,
//    caVirtual, caBase, caExpr);
//  TFDDataAttributes = set of TFDDataAttribute;
end;

procedure TfrmMain.tmr1Timer(Sender: TObject);
var
  lAllocated: Extended;
  lMem: TMemoryManagerUsageSummary;
begin
  GetMemoryManagerUsageSummary(lMem);
  lAllocated := (lMem.AllocatedBytes + lMem.OverheadBytes)  / 1024;
  statBar.Panels[1].Text := FloatToStrF(lAllocated, ffFixed, 8, 2);
end;

function TFieldTypeHelper.AsString(): string;
begin
  Result := TEnum.GetName<TFieldType>(self);
end;

end.

