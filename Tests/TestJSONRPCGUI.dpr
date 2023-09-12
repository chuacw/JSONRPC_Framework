program TestJSONRPCGUI;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitX.TestRunner,
  TestJSONRPC.Client in 'TestJSONRPC.Client.pas',
  JSONRPC.User.SomeTypes in '..\Common\JSONRPC.User.SomeTypes.pas',
  JSONRPC.RIO in '..\Common\JSONRPC.RIO.pas',
  JSONRPC.JsonUtils in '..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.InvokeRegistry in '..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.Common.Types in '..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.Common.Consts in '..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.ServerIdHTTP.Runner in '..\Server\JSONRPC.ServerIdHTTP.Runner.pas',
  JSONRPC.ServerBase.Runner in '..\Server\JSONRPC.ServerBase.Runner.pas',
  JSONRPC.User.SomeTypes.Impl in '..\Client\JSONRPC.User.SomeTypes.Impl.pas';

{$R *.RES}

begin
end.

