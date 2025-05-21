unit JSONRPC.Web3.EthereumAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Web3.Common.Types, JSONRPC.Common.Types,
  JSONRPC.Web3.Ethereum.Types, System.SysUtils, System.JSON, Velthuis.BigIntegers,
  JSONRPC.Web3.Ethereum.Converters, System.JSON.Serializers;

type

  HexBytes = BigInteger;

  [JsonConverter(TJSONFalseBlockInfoConverter)]
  TJSONFalseBlockInfo = record
  public
    startingBlock, currentBlock, highestBlock: UInt64; // encoded as hex
    class operator Assign(var Dest: TJSONFalseBlockInfo; const [ref] Src: TJSONFalseBlockInfo);
    class operator Implicit(const Value: TJSONFalseBlockInfo): Boolean;
    class operator Initialize(out Dest: TJSONFalseBlockInfo);
  end;

  IEthereumJSONRPC = interface(IJSONRPCMethods)
    ['{BC41AE33-10B1-4969-BA60-D2581EA21613}']
    function web3_clientVersion: string;
    function web3_sha3(const Data: HexBytes): Hash; overload;
    function net_version: HexNumber;
    function net_listening: Boolean;
    function net_peerCount: HexNumber; deprecated 'This might not exist!';
    function eth_protocolVersion: HexNumber;
    function eth_syncing: TJSONFalseBlockInfo;
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

implementation

uses
  JSONRPC.InvokeRegistry;

{ TJSONFalseBlockInfo }

class operator TJSONFalseBlockInfo.Assign(
  var Dest: TJSONFalseBlockInfo;
  const [ref] Src: TJSONFalseBlockInfo);
begin
  Dest.currentBlock  := Src.currentBlock;
  Dest.highestBlock  := Src.highestBlock;
  Dest.startingBlock := Src.highestBlock;
end;

class operator TJSONFalseBlockInfo.Implicit(
  const Value: TJSONFalseBlockInfo): Boolean;
begin
  if (Value.currentBlock = 0) and (Value.highestBlock = 0) and
    (Value.startingBlock = 0) then
    Result := False else
    Result := True;
end;

class operator TJSONFalseBlockInfo.Initialize(out Dest: TJSONFalseBlockInfo);
begin
  Dest.currentBlock  := 0;
  Dest.highestBlock  := 0;
  Dest.startingBlock := 0;
end;

initialization
  InvokableRegistry.RegisterInterface(TypeInfo(IEthereumJSONRPC));
end.
