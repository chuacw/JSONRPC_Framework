unit JSONRPC.Web3.SolanaClient;

{$ALIGN 16}
{$CODEALIGN 16}

interface

uses
  JSONRPC.Common.Types, System.Classes, System.JSON.Serializers,
  JSONRPC.RIO, JSONRPC.Web3.SolanaAPI;

function GetSolanaJSONRPC(const ServerURL: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil;
  const AOnLogServerURL: TOnLogServerURL = nil
): ISolanaJSONRPC;

implementation

uses
{$IF DEFINED(TEST) OR DEFINED(DEBUG)}
  Winapi.Windows,
{$ENDIF}
  JSONRPC.Common.Consts,
  System.JSON, System.Rtti, JSONRPC.InvokeRegistry,
  JSONRPC.JsonUtils;

function GetSolanaJSONRPC(const ServerURL: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil;
  const AOnLogServerURL: TOnLogServerURL = nil
): ISolanaJSONRPC;
begin
  var LJSONRPCWrapper := TJSONRPCWrapper.Create(nil);
  LJSONRPCWrapper.ServerURL := ServerURL;
  LJSONRPCWrapper.PassParamsByPos := True; // !! IMPT !!

  LJSONRPCWrapper.OnLogOutgoingJSONRequest := AOnLoggingOutgoingJSONRequest;
  LJSONRPCWrapper.OnLogIncomingJSONResponse := AOnLoggingIncomingJSONResponse;
  LJSONRPCWrapper.OnLogServerURL := AOnLogServerURL;

  Result := LJSONRPCWrapper as ISolanaJSONRPC;

{$IF DECLARED(IsDebuggerPresent)}
  if IsDebuggerPresent then
    begin
      LJSONRPCWrapper.SendTimeout := 10*60*1000;
      LJSONRPCWrapper.ResponseTimeout := LJSONRPCWrapper.SendTimeout;
      {$IF RTLVersion >= TRTLVersion.Delphi120 }
      LJSONRPCWrapper.ConnectionTimeout := LJSONRPCWrapper.SendTimeout;
      {$ENDIF}
    end;
{$ENDIF}

end;


end.
