unit JSONRPC.User.BitcoinTypes;

interface

uses
  JSONRPC.RIO, JSONRPC.Common.Types, JSONRPC.User.Types.MemoryInfo,
  JSONRPC.User.Types.WalletInfo, JSONRPC.User.Types.BlockchainInfo,
  JSONRPC.User.Types.BestBlockHash, JSONRPC.User.Types.BlockDefaultInfo;

type
  BlockHash = string;
{$SCOPEDENUMS ON}
  TVerbosity = (HexEncodedData, JSONObject, JSONObjectWithTransactionData);

  IBitcoinJSONRPC = interface(IJSONRPCMethods)
    ['{EA7B1DAB-1301-401C-82F5-7A903EA8D898}']

    // Control RPC

    [JSONMethodName('getblock')]
    function getblockJSONObject(const ABlockHash: BlockHash; Verbosity: Word = 1): BlockDefaultResult; overload;

    function getblock(const ABlockHash: BlockHash;
      [JSONMarshalAsNumber]
      Verbosity: TVerbosity = TVerbosity.JSONObject): BlockDefaultResult; overload;

    function getmemoryinfo: MemoryInfoResult;

    // Wallet RPC
    function getwalletinfo: WalletInfoResult;

    // Blockchain RPCs
    function getbestblockhash: BestBlockHashResult;
    function getblockcount: UInt64;
    function getblockchaininfo: BlockchainInfoResult;

    property BestBlockHash: BestBlockHashResult read getbestblockhash;
    property BlockchainInfo: BlockchainInfoResult read getblockchaininfo;
    property BlockCount: UInt64 read getblockcount;
    property MemoryInfo: MemoryInfoResult read getmemoryinfo;
    property WalletInfo: WalletInfoResult read getwalletinfo;
  end;

implementation

end.
