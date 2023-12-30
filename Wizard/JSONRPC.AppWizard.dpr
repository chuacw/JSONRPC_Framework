program JSONRPC.AppWizard;

uses
  Vcl.Forms,
  System.Net.URLClient,
  JSONRPC.App.Form in 'JSONRPC.App.Form.pas' {FormInterfaceGeneration},
  JSONRPC.App.Wizard in 'JSONRPC.App.Wizard.pas' {frmWizard: TFrame},
  JSONRPC.Wizard.Consts in 'JSONRPC.Wizard.Consts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormInterfaceGeneration, FormInterfaceGeneration);
  Application.Run;
end.
