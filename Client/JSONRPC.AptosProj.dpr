program JSONRPC.AptosProj;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  JSONRPC.TransportWrapper.HTTP in '..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  JSONRPC.RIO in '..\Common\JSONRPC.RIO.pas',
  JSONRPC.JsonUtils in '..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.InvokeRegistry in '..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.Common.Types in '..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.Common.Consts in '..\Common\JSONRPC.Common.Consts.pas',
  Web3.AptosAPI in '..\Web3\Aptos\Web3.AptosAPI.pas';

procedure AssignSafeCallException(const AJSONRPC: IAptosJSONRPC);
begin
  AssignJSONRPCSafeCallExceptionHandler(AJSONRPC,
    function (ExceptObject: TObject; ExceptAddr: Pointer): HResult
    var
      LExc: EJSONRPCException;
      LExcMethod: EJSONRPCMethodException absolute LExc;
    begin
      if ExceptObject is EJSONRPCException then
        begin
          LExc := ExceptObject as EJSONRPCException;
          WriteLn('Intercepted safecall exception...');
          Write(Format('message: "%s", code: %d', [LExc.Message, LExc.Code]));
          if LExc is EJSONRPCMethodException then
            begin
              Write(Format(', method: "%s"', [LExcMethod.MethodName]));
            end;
          WriteLn;
          WriteLn(StringOfChar('-', 90));
        end else
      if ExceptObject is Exception then
        begin
          var LExcObj := ExceptObject as Exception;
          WriteLn('Intercepted safecall exception...');
          WriteLn(Format('message: "%s"', [LExcObj.Message]));
        end;
      Result := S_OK; // Clear the error otherwise, CheckAutoResult will raise error
    end
  );
end;

begin
end.
