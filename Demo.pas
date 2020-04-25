unit Demo;

interface

uses
  refORM,

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
  Vcl.Buttons;

type
  TfrmMain = class(TForm)
    conSQLite: TFDConnection;
    dbgrdData: TDBGrid;
    fdqryData: TFDQuery;
    metaqryInfo: TFDMetaInfoQuery;
    dtsrcData: TDataSource;
    dtsrcInfo: TDataSource;
    dbgrdInfo: TDBGrid;
    mmoCode: TMemo;
    btnTest: TBitBtn;
    metaqryFields: TFDMetaInfoQuery;
    dtsrcFields: TDataSource;
    dbgrdFields: TDBGrid;
    btnGenerate: TBitBtn;
    procedure btnGenerateClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure metaqryInfoAfterScroll(DataSet: TDataSet);
  private
    flTableName: string;
  protected
    function GenerateCode(): string;
  end;

  ICustomers = interface(ItransfORMEntity)
    function CustomerID(): TransfORMField;
    function CompanyName(): TransfORMField;
    function ContactName(): TransfORMField;
    function ContactTitle(): TransfORMField;
    function Address(): TransfORMField;
    function City(): TransfORMField;
    function Region(): TransfORMField;
    function PostalCode(): TransfORMField;
    function Country(): TransfORMField;
    function Phone(): TransfORMField;
    function Fax(): TransfORMField;
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

procedure TfrmMain.btnGenerateClick(Sender: TObject);
begin
  mmoCode.Lines.Text := GenerateCode();
end;

procedure TfrmMain.btnTestClick(Sender: TObject);
var
  b: Boolean;
  lORM : TransfORM;
  i: Integer;
  s: string;
  lCustomer: ICustomers;
begin
  lORM := TransfORM.Create();
  lCustomer := lORM.GetInstance<ICustomers, string>('BOLID', conSQLite);
  s := lCustomer.CustomerID.Value;
  s := lCustomer.ContactTitle.Value;
  s := lCustomer.CompanyName.Value;
  lCustomer.ImmediateCommit := False;
  lCustomer.CompanyName.Value := 'Embarcadero';
  b := lCustomer.HasChanges;
  lCustomer.Commit();
  b := lCustomer.HasChanges;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  metaqryInfo.Open;
end;

function TfrmMain.GenerateCode(): string;
const
  cIntf = '  I%s = interface(ItransfORMEntity)' + sLineBreak +
          '%s' + sLineBreak +
          '  end;';
  cMeth = '    function %s(): TransfORMField;';
var
  s: string;

begin
  metaqryFields.DisableControls;
  try
  s := '';
  metaqryFields.First;
  while not metaqryFields.Eof do
  begin
    s := s + Format(cMeth, [metaqryFields.FieldByName('COLUMN_NAME').AsString]);
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

procedure TfrmMain.metaqryInfoAfterScroll(DataSet: TDataSet);
begin
  fdqryData.Close;
  flTableName := metaqryInfo.FieldByName('TABLE_NAME').AsString;
  fdqryData.MacroByName('TableName').AsRaw := flTableName;
  fdqryData.Open;
  metaqryFields.Close;
  metaqryFields.ObjectName := flTableName;
  metaqryFields.Open;
end;


end.

