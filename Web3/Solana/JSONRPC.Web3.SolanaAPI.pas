unit JSONRPC.Web3.SolanaAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Common.Types, System.JSON, JSONRPC.Web3.SolanaTypes,
  JSONRPC.Web3.Solana.Attributes;
  // System.JSON.Converters;

type

  RPCResponse<T> = record
    context: record
      slot: UInt64;
    end;
    value: T;
  end;

  ISolanaJSONRPC = interface(IJSONRPCMethods)
    ['{D03B9695-4452-4FE2-9354-34175017E9A1}']

    function getAccountInfo(const pubKeyAccount: string;
      [JsonConverter(TEncodingEnumConverter)]
      encoding: TEncoding = base58): TJSONObject;

    procedure getBalance;
    procedure getBlock;
    procedure getBlockCommitment;
    function getBlockHeight: UInt64;
    procedure getBlockProduction;
    procedure getBlocks;
    procedure getBlocksWithLimit;
    procedure getBlockTime;
    procedure getClusterNodes;
    procedure getEpochInfo;
    procedure getEpochSchedule;
    procedure getFeeForMessage;
    procedure getFirstAvailableBlock;
    procedure getGenesisHash;
    function getHealth: TJSONObject;
    procedure getHighestSnapshotSlot;
    procedure getIdentity;
    procedure getInflationGovenor;
    procedure getInflationRate;
    procedure getInflationReward;
    procedure getLargestAccounts;
    procedure getLatestBlockhash;
    procedure getLeaderSchedule;
    procedure getMaxRetransmitSlot;
    procedure getMaxShredInsertSlot;
    procedure getMinimumBalanceForRentExemption;
    procedure getMultipleAccounts;
    procedure getProgramAccounts;
    procedure getRecentPerformanceSamples;
    procedure getRecentPrioritizationFees;
    procedure getSignaturesForAddress;
    procedure getSignatureStatuses;
    procedure getSlot;
    procedure getSlotLeader;
    procedure getSlotLeaders;
    procedure getStakeActivation;
    procedure getStakeMinimumDelegation;
    procedure getSupply;
    procedure getTokenAccountBalance;
    procedure getTokenAccountsByDelegate;
    procedure getTokenAccountsByOwner;
    procedure getTokenLargestAccounts;
    procedure getTokenSupply;
    procedure getTransaction;
    procedure getTransactionCount;
    procedure getVersion;
    procedure getVoteAccounts;
    function isBlockhashValid(const blockhash: string): RPCResponse<UInt64>;
    procedure minimumLedgerSlot;
    procedure requestAirdrop;
    procedure sendTransaction;
    procedure simulateTransaction;
  end;

implementation

initialization
  RegisterJSONRPCWrapper(TypeInfo(ISolanaJSONRPC));
end.
