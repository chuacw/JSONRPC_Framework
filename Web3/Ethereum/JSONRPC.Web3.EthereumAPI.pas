unit JSONRPC.Web3.EthereumAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Web3.Common.Types, JSONRPC.Common.Types, Web3.Ethereum.Types,
  System.SysUtils, System.JSON, Velthuis.BigIntegers;

type

  HexBytes = BigInteger;

  IEthereumJSONRPC = interface(IJSONRPCMethods)
    ['{BC41AE33-10B1-4969-BA60-D2581EA21613}']
    function web3_clientVersion: string;
    function web3_sha3(const Data: HexBytes): Hash; overload;
    function net_version: HexNumber;
    function net_listening: Boolean;
    function net_peerCount: HexNumber; deprecated 'This might not exist!';
    function eth_protocolVersion: HexNumber;
    function eth_syncing: TJSONObject;
    function eth_coinbase: HexNumber;
    function eth_chainId: HexNumber;
    function eth_mining: Boolean;
    function eth_hashrate: HexNumber;
    function eth_gasPrice: HexNumber;
    function eth_accounts: TArray<Web3Address>;
    function eth_blockNumber: HexNumber;

    function eth_getBalance(const AAddress: Web3Address; const ABlockNumber: HexNumber): HexNumber; overload;
    function eth_getBalance(const AAddress: Web3Address; const ABlockNumber: TBlockNumber): HexNumber; overload;
    function eth_getStorageAt(const AAddress: Web3Address; const Position: HexNumber;
      const AQuantity: HexNumber): HexNumber; overload;
    function eth_getStorageAt(const AAddress: Web3Address; const Position: HexNumber;
      const AQuantity: TBlockNumber): HexNumber; overload;
    function eth_getTransactionCount(const AAddress: Web3Address;
      const AQuantity: HexNumber): HexNumber; overload;
    function eth_getTransactionCount(const AAddress: Web3Address;
      const AQuantity: TBlockNumber): HexNumber; overload;
    function eth_getBlockTransactionCountByHash(const AHash: Hash): HexNumber;
    function eth_getBlockTransactionCountByNumber(const ABlockNumber: HexNumber): HexNumber; overload;
    function eth_getBlockTransactionCountByNumber(const ABlockNumber: TBlockNumber): HexNumber; overload;
    function eth_getUncleCountByBlockHash(const AHash: Hash): HexNumber;
    function eth_getUncleCountByBlockNumber(const ABlockNumber: HexNumber): HexNumber; overload;
    function eth_getUncleCountByBlockNumber(const ABlockNumber: TBlockNumber): HexNumber; overload;
    function eth_getCode(const AAddress: Web3Address; const ABlockNumber: HexNumber): HexNumber; overload;
    function eth_getCode(const AAddress: Web3Address; const ABlockNumber: TBlockNumber): HexNumber; overload;
    function eth_sign(const AAddress: Web3Address; const Data: string): HexNumber;
    // TODO : Complete eth_signTransaction
//    function eth_signTransaction(
    function eth_sendTransaction(const ATranObj: TransactionObject): Hash; safecall;
    function eth_sendRawTransaction(const ASignedTransactionData: HexNumber): Hash;
    function eth_call(const ATranObj: TransactionObject): HexNumber;
    function eth_estimateGas: HexNumber;
    function eth_getBlockByHash(const AHash: Hash;
      ReturnFullTransactions: Boolean): getBlockByHashReturn;
    function eth_getTransactionReceipt(const AAddress: Web3Address): TransactionReceiptObject;

  end;

function GetEthereumJSONRPC(const AServerURL: string = '';
  const AWrapperType: TTransportWrapperType = twtHTTP;
  const UseDefaultProcs: Boolean = True;
  const AOnSyncProc: TOnSyncEvent = nil;
  const AOnBeforeParse: TOnBeforeParseEvent = nil): IEthereumJSONRPC;

implementation

uses
  JSONRPC.InvokeRegistry, Web3.Ethereum.RIO;

function GetEthereumJSONRPC(const AServerURL: string = '';
  const AWrapperType: TTransportWrapperType = twtHTTP;
  const UseDefaultProcs: Boolean = True;
  const AOnSyncProc: TOnSyncEvent = nil;
  const AOnBeforeParse: TOnBeforeParseEvent = nil): IEthereumJSONRPC;
begin
  RegisterJSONRPCWrapper(TypeInfo(IEthereumJSONRPC));
  var LJSONRPCWrapper := TWeb3EthereumJSONRPCWrapper.Create(nil);
  LJSONRPCWrapper.PassParamsByPos := True;
  LJSONRPCWrapper.ServerURL := AServerURL;
  Result := LJSONRPCWrapper as IEthereumJSONRPC;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IEthereumJSONRPC));
end.
