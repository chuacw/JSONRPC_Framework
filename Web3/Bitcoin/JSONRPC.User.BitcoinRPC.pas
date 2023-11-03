unit JSONRPC.User.BitcoinRPC;

{$CODEALIGN 16}

interface

uses
  JSONRPC.Common.Types, System.Classes, System.JSON.Serializers,
  JSONRPC.RIO, JSONRPC.User.BitcoinTypes;

function GetBitcoinJSONRPC(
  const AServerURL: string = '';
  const AUserName: string = '';
  const APassword: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil;
  const AWrapperType: TTransportWrapperType = twtHTTP;
  const AOnBeforeParse: TOnBeforeParseEvent = nil;
  const AOnSyncProc: TOnSyncEvent = nil;
  const AUseDefaultProcs: Boolean = True
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
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil;
  const AWrapperType: TTransportWrapperType = twtHTTP;
  const AOnBeforeParse: TOnBeforeParseEvent = nil;
  const AOnSyncProc: TOnSyncEvent = nil;
  const AUseDefaultProcs: Boolean = True
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
    const AMethMD: TIntfMethEntry;
    AParamIndex: Integer;
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
      LJSONRPCWrapper.SendTimeout := 10*60*1000;
      LJSONRPCWrapper.ResponseTimeout := LJSONRPCWrapper.SendTimeout;
      LJSONRPCWrapper.ConnectionTimeout := LJSONRPCWrapper.SendTimeout;
    end;
{$ENDIF}

{$IF DEFINED(TEST)}
  // OnSync is typically not used, unless you're testing something,
  // in this case, just copy the request into the response
  if ServerURL = '' then
    begin
      if UseDefaultProcs then
        begin
          LJSONRPCWrapper.OnSync := procedure (ARequest, AResponse: TStream)
          begin
            AResponse.CopyFrom(ARequest);
          end;

          LJSONRPCWrapper.OnBeforeParse := procedure (const AContext: TInvContext;
            AMethNum: Integer; const AMethMD: TIntfMethEntry; const AMethodID: Int64;
            AJSONResponse: TStream)
          begin
            // This is where the client can pretend to be a server, look at the response,
            // which is actually the request, and then clear the response stream and
            // write its actual response into it...
            if (AJSONResponse.Size <> 0) and (AMethMD.Name = 'AddSomeXY') then
              begin
                AJSONResponse.Position := 0;

                var LBytes: TArray<Byte>;
                SetLength(LBytes, AJSONResponse.Size);
                AJSONResponse.Read(LBytes[0], AJSONResponse.Size);
        //        var LJSONResponseStr := TEncoding.UTF8.GetString(LBytes);

        // THIS BUG WILL KILL / HANG THE DEBUGGER, on exit of this method
        //       var LJSONResponseStr := '';
        //       AJSONResponse.Read(LJSONResponseStr, AJSONResponse.Size);

                var LJSONObj := TJSONObject.ParseJSONValue(LBytes, 0);
                try
                  var LX: Integer := LJSONObj.GetValue<Integer>('params.X');
                  var LY: Integer := LJSONObj.GetValue<Integer>('params.Y');
                  var LValue: TValue := LX + LY;
                  AJSONResponse.Size := 0;
                  WriteJSONResult(AMethNum, AMethMD.ResultInfo, AMethodID, LValue, AJSONResponse);
                finally
                  LJSONObj.Free;
                end;
              end;
          end;

        end else
        begin
          LJSONRPCWrapper.OnSync := AOnSyncProc;
          LJSONRPCWrapper.OnBeforeParse := AOnBeforeParse;
        end;

// Do anything to the JSON response stream, before parsing starts...
// Since there's no server, write response data into the server response, so that it can be parsed

    end;
{$ENDIF}

end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IBitcoinJSONRPC));
{$IF DEFINED(TEST)}
  // Developed to send rubbish data to check server tolerance
  InvRegistry.RegisterInterface(TypeInfo(ISomeExtendedJSONRPC));
{$ENDIF}
end.
