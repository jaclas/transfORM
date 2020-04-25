program DemoProj;

uses
  Vcl.Forms,
  Demo in 'Demo.pas' {frmMain},
  refORM in 'refORM.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

