program JSONRPC.EthereumClient;

{$APPTYPE CONSOLE}
{$WARN DUPLICATE_CTOR_DTOR OFF}
{$R *.res}

uses
  System.Variants,
  JSONRPC.RIO in '..\..\Common\JSONRPC.RIO.pas',
  System.Classes,
  System.Rtti,
  System.JSON,
  System.SysUtils,
  System.TypInfo,
  Winapi.Windows,
  System.DateUtils,
  System.JSON.Writers,
  JSONRPC.Common.Consts in '..\..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.InvokeRegistry in '..\..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.User.SomeTypes in '..\..\Common\JSONRPC.User.SomeTypes.pas',
  JSONRPC.Common.Types in '..\..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.JsonUtils in '..\..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.TransportWrapper.HTTP in '..\..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  System.Net.ClientSocket in '..\..\..\NetSocket\Client\System.Net.ClientSocket.pas',
  System.Net.Socket.Common in '..\..\..\NetSocket\Common\System.Net.Socket.Common.pas',
  Web3.Common.Types in '..\Web3.Common.Types.pas',
  Web3.Serializers in '..\Web3.Serializers.pas',
  Web3.JsonUtils in '..\Web3.JsonUtils.pas',
  JSONRPC.Common.RecordHandlers in '..\..\Common\JSONRPC.Common.RecordHandlers.pas',
  JSONRPC.Web3.Ethereum.Types in 'JSONRPC.Web3.Ethereum.Types.pas',
  JSONRPC.Web3.EthereumAPI in 'JSONRPC.Web3.EthereumAPI.pas',
  JSONRPC.Web3.Ethereum.RIO in 'JSONRPC.Web3.Ethereum.RIO.pas',
  JSONRPC.Web3.Ethereum.Serializers in 'JSONRPC.Web3.Ethereum.Serializers.pas';

procedure AssignSafeCallException(const AJSONRPC: IEthereumJSONRPC);
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

procedure Main;
begin

  var EthereumJSONRPC := GetEthereumJSONRPC('https://rpc.ankr.com/eth_goerli');
  AssignSafeCallException(EthereumJSONRPC);
  var LEthSyncing := EthereumJSONRPC.eth_syncing;
  var LgetBlockByHashResult := EthereumJSONRPC.eth_getBlockByHash('0x7c081ccbb9fa8db1fd68d093389391c72c649e26a77ae7a2c5b92546c8782ad3', false);

//  var Signature := EthereumJSONRPC.eth_sign(
//    '0x9b2055d370f73ec7d8a03e965129118dc8f5bf83',
//    '0xdeadbeaf'
//  );
//  var blockNumber := EthereumJSONRPC.eth_blockNumber;
//  var LBytes: TBytes := [$68, $65, $6c, $6c, $6f, $20, $77, $6f, $72, $6c, $64];
  var Lweb3_sha3Hash := EthereumJSONRPC.web3_sha3('0x68656c6c6f20776f726c64');
  var Lweb3_clientVersion := EthereumJSONRPC.web3_clientVersion;
  var Lnetversion := EthereumJSONRPC.net_version;
  var Lnetlistening := EthereumJSONRPC.net_listening;
//  var LnetPeerCount := EthereumJSONRPC.net_peerCount; // doesn't exist
  var LProtocolVersion := EthereumJSONRPC.eth_protocolVersion;
  var transactionReceipt := EthereumJSONRPC.eth_getTransactionReceipt('0x85d995eba9763907fdf35cd2034144dd9d53ce32cbec21349d4b12823c6860c5');

  var balance := EthereumJSONRPC.eth_getBalance('0x407d73d8a49eeb85d32cf465507dd71d507100c1',
    TBlockNumber.latest);
  var tranObj: TransactionObject;
  tranObj.from := '0xb60e8dd61c5d32be8058bb8eb970870f07233155';
  tranObj.&to := '0xd46e8dd67c5d32be8058bb8eb970870f07244567';
  tranObj.gas := '0x76c0';
  tranObj.gasPrice := '0x9184e72a000';
  tranObj.value := '0x9184e72a';
  tranObj.data := '0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675';
  var tranObjHash := EthereumJSONRPC.eth_sendTransaction(tranObj);
  EthereumJSONRPC := nil;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    Main;
  finally
    Write('Press enter to terminate...');
    ReadLn;
  end;
end.
