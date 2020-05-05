program DemoProj;

uses
  FastMM4,
  Vcl.Forms,
  Demo in 'Demo.pas' {frmMain},
  transfORM.Main in 'transfORM.Main.pas',
  transfORM.Impl in 'transfORM.Impl.pas',
  transfORM.DB in 'transfORM.DB.pas',
  transfORM.Entity in 'transfORM.Entity.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

