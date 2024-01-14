program Build_JSONRPC_Framework;

{$APPTYPE CONSOLE}
{$WARN DUPLICATE_CTOR_DTOR OFF}
{$R *.res}

uses
  System.SysUtils,
  JSONRPC.TransportWrapper.HTTP in '..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  JSONRPC.RIO in '..\Common\JSONRPC.RIO.pas',
  JSONRPC.JsonUtils in '..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.InvokeRegistry in '..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.Common.Types in '..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.Common.RecordHandlers in '..\Common\JSONRPC.Common.RecordHandlers.pas',
  JSONRPC.Common.Consts in '..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.ServerBase.Runner in '..\Server\JSONRPC.ServerBase.Runner.pas',
  JSONRPC.Server.JSONRPCHTTPServer in '..\Server\JSONRPC.Server.JSONRPCHTTPServer.pas',
  JSONRPC.Server.Consts in '..\Server\JSONRPC.Server.Consts.pas',
  JSONRPC.CustomServerIdHTTP.Runner in '..\Server\JSONRPC.CustomServerIdHTTP.Runner.pas',
  JSONRPC.Common.FixBuggyNativeTypes in '..\Common\JSONRPC.Common.FixBuggyNativeTypes.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
