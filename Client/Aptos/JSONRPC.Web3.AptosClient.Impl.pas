unit JSONRPC.Web3.AptosClient.Impl;

{$CODEALIGN 16}

interface

uses
  JSONRPC.Common.Types, System.Classes, System.JSON.Serializers,
  JSONRPC.RIO, JSONRPC.Web3.AptosAPI;

function GetAptosJSONRPC(const ServerURL: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil
): IAptosJSONRPC;

implementation

uses
{$IF DEFINED(TEST) OR DEFINED(DEBUG)}
  Winapi.Windows,
{$ENDIF}
  System.JSON, System.Rtti, JSONRPC.InvokeRegistry,
  JSONRPC.JsonUtils, Web3.Aptos.RIO;

function GetAptosJSONRPC(const ServerURL: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil
): IAptosJSONRPC;
begin
  RegisterJSONRPCWrapper(TypeInfo(IAptosJSONRPC));

  var LJSONRPCWrapper := TWeb3AptosJSONRPCWrapper.Create(nil);
  LJSONRPCWrapper.ServerURL := ServerURL;

  LJSONRPCWrapper.OnLogOutgoingJSONRequest := AOnLoggingOutgoingJSONRequest;
  LJSONRPCWrapper.OnLogIncomingJSONResponse := AOnLoggingIncomingJSONResponse;

  Result := LJSONRPCWrapper as IAptosJSONRPC;

{$IF DECLARED(IsDebuggerPresent)}
  if IsDebuggerPresent then
    begin
      LJSONRPCWrapper.SendTimeout := 10*60*1000;
      LJSONRPCWrapper.ResponseTimeout := LJSONRPCWrapper.SendTimeout;
      LJSONRPCWrapper.ConnectionTimeout := LJSONRPCWrapper.SendTimeout;
//      LJSONRPCWrapper.ResponseTimeout := 150;
//      LJSONRPCWrapper.SendTimeout := 150;
    end;
{$ENDIF}

end;

end.
