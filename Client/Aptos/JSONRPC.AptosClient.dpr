program JSONRPC.AptosClient;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.JSON,
  JSONRPC.TransportWrapper.HTTP in '..\..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  JSONRPC.RIO in '..\..\Common\JSONRPC.RIO.pas',
  JSONRPC.JsonUtils in '..\..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.InvokeRegistry in '..\..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.Common.Types in '..\..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.Common.Consts in '..\..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.Common.RecordHandlers in '..\..\Common\JSONRPC.Common.RecordHandlers.pas',
  JSONRPC.Web3.AptosClient.Impl in 'JSONRPC.Web3.AptosClient.Impl.pas',
  JSONRPC.Web3.AptosAPI in '..\..\Web3\Aptos\JSONRPC.Web3.AptosAPI.pas',
  JSONRPC.TransportWrapper.AptosHTTP in 'JSONRPC.TransportWrapper.AptosHTTP.pas',
  JSONRPC.Web3.Aptos.Common.Types in '..\..\Web3\Aptos\JSONRPC.Web3.Aptos.Common.Types.pas',
  Web3.Aptos.RIO in '..\..\Web3\Aptos\Web3.Aptos.RIO.pas';

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

function GetAptosClient(const AURL: string): IAptosJSONRPC;
begin
  Result := GetAptosJSONRPC('https://fullnode.devnet.aptoslabs.com/',
    procedure(const AJSONRPCRequest: string)
    begin
      WriteLn('Sending outgoing request: ', AJSONRPCRequest);
    end,
    procedure(const AJSONRPCResponse: string)
    begin
      WriteLn('Received incoming response: ', AJSONRPCResponse);
      WriteLn(StringOfChar('-', 80));
      WriteLn;
    end,
    procedure(const AServerURL: string)
    begin
      WriteLn('Sending request to ', AServerURL);
      WriteLn(StringOfChar('-', 80));
      WriteLn;
    end
  );
end;

procedure RunAptosClient;
begin
  var LAptosClient := GetAptosClient('https://fullnode.devnet.aptoslabs.com/');
  // LAptosClient.GetAccount()
  var LJSONObject := LAptosClient.GetBlocksByHeight(1075502);
  var LJSONGetBlocksByVersion := LAptosClient.GetBlocksByVersion(2309044);
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    RunAptosClient;
  except
    on E: Exception do
      WriteLn('Ran into some exception: ', E.Message);
  end;
end.
