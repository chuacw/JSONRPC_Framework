program WSDL_Client;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  IEmployee1 in 'IEmployee1.pas',
  JSONRPC.RIO in 'JSONRPC.RIO.pas',
  JSONRPC.Consts in 'JSONRPC.Consts.pas';

{$R *.res}

/// This project is created to examine how WSDL Client is implemented and to
/// implement a similar client in JSON RPC
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
