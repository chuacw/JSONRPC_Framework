program JSONRPC.PolkadotClient;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  JSONRPC.Web3.Polkadot.Types in 'JSONRPC.Web3.Polkadot.Types.pas',
  JSONRPC.Web3.PolkadotAPI in 'JSONRPC.Web3.PolkadotAPI.pas',
  JSONRPC.RIO in '..\..\Common\JSONRPC.RIO.pas',
  JSONRPC.Common.Types in '..\..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.InvokeRegistry in '..\..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.Common.Consts in '..\..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.JsonUtils in '..\..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.Web3.Common.Types in '..\JSONRPC.Web3.Common.Types.pas',
  JSONRPC.TransportWrapper.HTTP in '..\..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  JSONRPC.Common.RecordHandlers in '..\..\Common\JSONRPC.Common.RecordHandlers.pas',
  JSONRPC.Web3.Common.Types in '..\JSONRPC.Web3.Common.Types.pas',
  JSONRPC.TransportWrapper.HTTP in '..\..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  JSONRPC.Web3.Polkadot.Types in 'JSONRPC.Web3.Polkadot.Types.pas',
  JSONRPC.Web3.PolkadotAPI in 'JSONRPC.Web3.PolkadotAPI.pas';

function GetPolkadotClient: IPolkadotJSONRPC;
begin
  Result := GetPolkadotJSONRPC('https://apps-rpc.polkadot.io/',
    procedure(const AJSONRPCRequest: string)
    begin
      WriteLn('--- Outgoing JSON request ---');
      WriteLn(AJSONRPCRequest);
    end,
    procedure(const AJSONRPCResponse: string)
    begin
      WriteLn('--- Incoming JSON response ---');
      WriteLn(AJSONRPCResponse);
    end
  );
  AssignJSONRPCSafeCallExceptionHandler(Result,
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

procedure TestPolkadotClient;
begin
  var LPolkadotClient := GetPolkadotClient;

  var LSystemHealth := LPolkadotClient.system_health;
  var LBlockHash := LPolkadotClient.chain_getBlockHash(19518865);
  Assert(LBlockHash = '0x66722d90a8fec09cb410fed0292b397d5d3cbd1bca376b1fd0c1bb8caee3e6d4');
  WriteLn(LBlockHash);

  var LMethods := LPolkadotClient.rpc_methods;
  var LKey: StorageKey := '0x26aa394eea5630e07c48ae0c9558cef7f9cce9c888469bb1a0dceaa129672ef8';
  var LAt: TBlockHash := '0x841a21ab1aa402aca5185e1b9d72f85e181de28e8f68e279c4f7a25f06e63d23';

  LBlockHash := LPolkadotClient.state_getStorage(LKey, LAt);
end;

begin
  TestPolkadotClient;
end.
