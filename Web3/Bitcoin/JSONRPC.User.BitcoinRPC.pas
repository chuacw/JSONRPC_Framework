unit JSONRPC.User.BitcoinRPC;

{$ALIGN 16}
{$CODEALIGN 16}

interface

uses
  JSONRPC.Common.Types, System.Classes, System.JSON.Serializers,
  JSONRPC.RIO, JSONRPC.User.BitcoinTypes;

/// <summary>
///  Returns an interface to the Bitcoin JSON RPC
/// </summary>
function GetBitcoinJSONRPC(
  const AServerURL: string = '';
  const AUserName: string = '';
  const APassword: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil
): IBitcoinJSONRPC;

implementation

uses
{$IF DEFINED(TEST) OR DEFINED(DEBUG)}
  Winapi.Windows,
{$ENDIF}
  System.JSON, System.Rtti, JSONRPC.InvokeRegistry, System.TypInfo,
  JSONRPC.JsonUtils, System.SysUtils, System.NetEncoding;

function GetBitcoinJSONRPC(
  const AServerURL: string = '';
  const AUserName: string = '';
  const APassword: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil
): IBitcoinJSONRPC;
begin
  RegisterJSONRPCWrapper(TypeInfo(IBitcoinJSONRPC));

  var LJSONRPCWrapper := TJSONRPCWrapper.Create(nil);
  LJSONRPCWrapper.ServerURL := AServerURL;
  LJSONRPCWrapper.PassParamsByPos := True;

  if (AUserName <> '') or (APassword <> '') then
    begin
      LJSONRPCWrapper.OnBeforeInitializeHeaders := procedure (var VNetHeaders: TNetHeaders)
      begin
        var LUserNamePassword := Format('%s:%s', [AUserName, APassword]);
        VNetHeaders := [TNameValuePair.Create('Authorization', 'Basic ' +
          TNetEncoding.Base64String.Encode(LUserNamePassword))];
      end;
    end;

  LJSONRPCWrapper.OnParseEnum := function (const ARttiContext: TRttiContext;
    const AMethMD: TIntfMethEntry; AParamIndex: Integer;
    AParamTypeInfo: PTypeInfo; AParamValuePtr: Pointer; AParamsObj: TJSONObject;
    AParamsArray: TJSONArray): Boolean
  var
    LMethods: TArray<TRttiMethod>;
    LIntfType: TRttiType;
    LMethType: TRttiMethod;
    LParams: TArray<TRttiParameter>;
  begin
    LIntfType := ARttiContext.GetType(AMethMD.SelfInfo) as TRttiInterfaceType;
    LMethods := LIntfType.GetDeclaredMethods;
    LMethType := LMethods[AMethMD.Pos-3];
    LParams := LMethType.GetParameters;
    Result := LParams[AParamIndex-1].HasAttribute<JSONMarshalAsNumber>;
  end;

  LJSONRPCWrapper.OnLogOutgoingJSONRequest := AOnLoggingOutgoingJSONRequest;
  LJSONRPCWrapper.OnLogIncomingJSONResponse := AOnLoggingIncomingJSONResponse;

  Result := LJSONRPCWrapper as IBitcoinJSONRPC;

{$IF DECLARED(IsDebuggerPresent)}
  if IsDebuggerPresent then
    begin
      var LTimeout := 10*60*1000;
      LJSONRPCWrapper.SendTimeout := LTimeout;
      LJSONRPCWrapper.ResponseTimeout := LTimeout;
      LJSONRPCWrapper.ConnectionTimeout := LTimeout;
    end;
{$ENDIF}

end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IBitcoinJSONRPC));
end.
