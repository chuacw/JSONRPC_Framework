{---------------------------------------------------------------------------}
{                                                                           }
{ File:      JSONRPC.User.SomeTypes.pas                                     }
{ Function:  Example client implementation of getting JSON RPC interface    }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit JSONRPC.User.SomeTypes.Impl;

{$ALIGN 16}
{$CODEALIGN 16}

interface

uses
  JSONRPC.Common.Types, System.Classes, System.JSON.Serializers,
  JSONRPC.RIO, JSONRPC.User.SomeTypes;

function GetSomeJSONRPC(const ServerURL: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil;
  const AWrapperType: TTransportWrapperType = twtHTTP;
  const AOnBeforeParse: TOnBeforeParseEvent = nil;
  const AOnSyncProc: TOnSyncEvent = nil;
  const AUseDefaultProcs: Boolean = True
): ISomeJSONRPC;

implementation

uses
{$IF (DEFINED(TEST) OR DEFINED(DEBUG)) AND DEFINED(MSWINDOWS)}
  Winapi.Windows,
{$ENDIF}
  JSONRPC.Common.Consts,
  System.JSON, System.Rtti, JSONRPC.InvokeRegistry,
  JSONRPC.JsonUtils;

function GetSomeJSONRPC(
  const ServerURL: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil;
  const AWrapperType: TTransportWrapperType = twtHTTP;
  const AOnBeforeParse: TOnBeforeParseEvent = nil;
  const AOnSyncProc: TOnSyncEvent = nil;
  const AUseDefaultProcs: Boolean = True
): ISomeJSONRPC;
begin
{$IF DEFINED(TEST)}
  // Developed to send rubbish data to check server tolerance
  RegisterJSONRPCWrapper(TypeInfo(ISomeExtendedJSONRPC));
{$ENDIF}

  RegisterJSONRPCWrapper(TypeInfo(ISomeJSONRPC));

  var LJSONRPCWrapper := TJSONRPCWrapper.Create(nil);
  LJSONRPCWrapper.ServerURL := ServerURL;

  LJSONRPCWrapper.OnLogOutgoingJSONRequest := AOnLoggingOutgoingJSONRequest;
  LJSONRPCWrapper.OnLogIncomingJSONResponse := AOnLoggingIncomingJSONResponse;

  Result := LJSONRPCWrapper as ISomeJSONRPC;

{$IF DECLARED(IsDebuggerPresent)}
  if IsDebuggerPresent then
    begin
      var LTimeout := 10*60*1000;
      LJSONRPCWrapper.SendTimeout := LTimeout;
      LJSONRPCWrapper.ResponseTimeout := LTimeout;
      {$IF RTLVersion >= TRTLVersion.Delphi120 }
      LJSONRPCWrapper.ConnectionTimeout := LTimeout;
      {$ENDIF}
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
  InvRegistry.RegisterInterface(TypeInfo(ISomeJSONRPC));
{$IF DEFINED(TEST)}
  // Developed to send rubbish data to check server tolerance
  InvRegistry.RegisterInterface(TypeInfo(ISomeExtendedJSONRPC));
{$ENDIF}
end.
