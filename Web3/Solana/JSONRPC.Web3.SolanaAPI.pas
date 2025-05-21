unit JSONRPC.Web3.SolanaAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Common.Types, System.JSON, JSONRPC.Web3.SolanaTypes,
//  JSONRPC.Web3.Solana.Attributes, // JSONRPC.Web3.Solana.Common.Types,
//  JSONRPC.Web3.SolanaTypes.getAccountInfoResultsType,
  System.JSON.Serializers,
//  JSONRPC.Web3.SolanaTypes.getBlockResultType,
  System.Generics.Collections;

type

//  RPCResponseU64 = RPCResponse<UInt64>;
//
//  TTransactionDetails = (full, accounts, signatures, none);
//
//  commitmentConfigObject = record
//    commitment: TCommitment;
//    constructor Create(ACommitment: TCommitment);
//  end;
//
//  CommitmentContextSlotObj = record
//    commitment: TCommitment;
//    minContextSlot: UInt64;
//    constructor Create(ACommitment: TCommitment; AMinContextSlot: UInt64); overload;
//    constructor Create(AMinContextSlot: UInt64; ACommitment: TCommitment = finalized); overload;
//  end;
//
//  getBalanceConfigObject = CommitmentContextSlotObj;
//
//  getBlockHeightConfigObject = CommitmentContextSlotObj;
//
////  getBlockHeightConfigObject = record
////    commitment: TCommitment;
////    minContextSlot: UInt64;
////    constructor Create(AMinContextSlot: UInt64; ACommitment: TCommitment = finalized);
////  end;
//
//  getBlockConfigObject = record
//    encoding: TEncoding;
//    maxSupportedTransactionVersion: Integer;
//    transactionDetails: TTransactionDetails;
//    rewards: Boolean;
//    constructor Create(ACommitment: TCommitment;
//      AEncoding: TEncoding = TEncoding.json;
//      ATransactionDetails: TTransactionDetails = full;
//      AMaxSupportedTransactionVersion: Integer = 0;
//      ARewards: Boolean = True
//    );
//  end;
//
//  getBlockProductionConfigObjectRange = record
//    firstSlot: UInt64;
//    lastSlot: UInt64;
//  end;
//
//  getBlockProductionConfigObject = record
//    commitment: TCommitment;
//    identity: string;
//    range: getBlockProductionConfigObjectRange;
//  end;
//
//  getBlockResultTransactionMetaloadedAddresses = record
//    // readonly: [];
//    // writable: [];
//  end;
//
//  getBlockResultTransactionMetainnerInstructionsinstructions = record
//    accounts: TArray<UInt64>;
//    data: string;
//    programIdIndex: UInt64;
//    stackHeight: UInt64;
//  end;
//
//  getBlockResultTransactionMetainnerInstructions = record
//    index: UInt64;
//    instructions: TArray<getBlockResultTransactionMetainnerInstructionsinstructions>;
//  end;
//
//  TokenAmount = record
//    amount: string;
//    decimals: Integer;
//    uiAmount: Float64;
//    uiAmountString: string;
//  end;
//
//  uiTokenAmount = TokenAmount;
//
//  TokenBalances = record
//    accountIndex: UInt64;
//    mint: string;
//    owner: string;
//    programId: string;
//    uiTokenAmount: TokenAmount;
//  end;
//
//  getBlockResultTransactionMeta = record
//    computeUnitsConsumed: UInt64;
//    // err: null; // how to translate?
//    fee: UInt64;
//    innerInstructions: TArray<getBlockResultTransactionMetainnerInstructions>;
//    loadedAddresses: getBlockResultTransactionMetaloadedAddresses;
//    logMessages: TArray<string>;
//    postBalances: TArray<UInt64>;
//    preTokenBalances: TArray<TokenBalances>; // ???
//    postTokenBalances: TArray<TokenBalances>;
//    // rewards: array
//    // status:
//  end;
//
//  getBlockResultTransactionTransactionInstruction = record
//    accounts: TArray<UInt64>;
//    data: string;
//    programIdIndex: UInt64;
//    stackHeight: UInt64;
//  end;
//
//  getBlockResultTransactionTransaction = record
//    message: record
//      accountKeys: TArray<string>;
//    end;
//    // addressTableLookups: [];
//    header: record
//      numReadonlySignedAccounts: UInt64;
//      numReadonlyUnsignedAccounts: UInt64;
//      numRequiredSignatures: UInt64;
//    end;
//    instructions: TArray<getBlockResultTransactionTransactionInstruction>;
//  end;
//
//  getBlockResultTransaction = record
//    meta: getBlockResultTransactionMeta;
//    transaction: getBlockResultTransactionTransaction;
//  end;
//
//  getBlockResultRewards = record
//    // commission: null // How to translate?
//    lamports: UInt64;
//    postBalance: UInt64;
//    pubKey: string;
//    rewardType: string;
//  end;
//
////  getBlockResult = record
////    blockHash: string;
////    previousBlockhash: string;
////    parentSlot: UInt64;
////    transactions: TArray<getBlockResultTransaction>;
////    blockTime: Int64;
////    blockHeight: UInt64;
////    rewards: TArray<getBlockResultRewards>;
////  end;
//
//  getBlockCommitmentResult = record
//    commitment: TArray<UInt64>;
//    totalStake: Integer;
//  end;
//
//  getVersionResult = record
//    [JsonName('solana-core')]
//    solana_core: string;
//    [JsonName('feature-set')]
//    feature_set: UInt32;
//  end;
//
//  votePubkey = record
//    votePubkey: string;
//    constructor Create(const AVotePubKey: string);
//  end;
//  getVoteAccountsConfigObject = record
//    commitment: TCommitment;
//    votePubkey: string;
//    keepUnstakedDelinquents: Boolean;
//    delinquentSlotDistance: UInt64;
//    constructor Create(ACommitment: TCommitment; const AVotePubkey: string;
//     AkeepUnstakedDelinquents: Boolean;
//     AdelinquentSlotDistance: UInt64);
//  end;
//  getVoteAccountsResultCurrentItem = record
//    votePubkey: string;
//    nodePubkey: string;
//    activatedStake: UInt64;
//    epochVoteAccount: Boolean;
//    commission: Float64;
//    lastVote: UInt64;
//    epochCredits: TArray<TArray<UInt64>>; // [epoch, credits, previousCredits]
//    rootSlot: UInt64;
//  end;
//  getVoteAccountsResult = record
//    current: TArray<getVoteAccountsResultCurrentItem>;
//    delinquent: TArray<getVoteAccountsResultCurrentItem>;
//  end;
//
//  isBlockhashValidResult = RPCResponseContext<Boolean>;
//
//  requestAirDropCommitment = record
//    commitment: TCommitment;
//    constructor Create(ACommitment: TCommitment);
//  end;
//
//  getEpochInfoResult = record
//    absoluteSlot: UInt64;
//    blockHeight: UInt64;
//    epoch: UInt64;
//    slotIndex: UInt64;
//    slotsInEpoch: UInt64;
//    transactionCount: UInt64;
//  end;
//
//  getEpochInfoConfigObject = record
//    commitment: TCommitment;
//    minContextSlot: UInt64;
//  end;
//
//  getEpochScheduleResult = record
//    slotsPerEpoch: UInt64;
//    leaderScheduleSlotOffset: UInt64;
//    warmup: Boolean;
//    firstNormalEpoch: UInt64;
//    firstNormalSlot: UInt64;
//  end;
//
//  getFeeForMessageResult = record
//  end;
//
//  getFeeForMessageConfigObject = getEpochInfoConfigObject;
//
//  getHighestSnapshotSlotResult = record
//    full: UInt64;
//    incremental: UInt64;
//  end;
//
//  getIdentityResult = record
//    identity: string;
//  end;
//
//  getInflationGovernorConfigObject = TCommitment;
//
//  getInflationGovernorResult = record
//    foundation: Float64;
//    foundationTerm: Float64;
//    initial: Float64;
//    taper: Float64;
//    terminal: Float64;
//  end;
//
//  getBlocksConfigObject = record
//    commitment: TCommitment;
//    constructor Create(ACommitment: TCommitment);
//  end;
//  getBlocksResult = TArray<UInt64>;
//
//  getBlocksWithLimitConfigObject = getBlocksConfigObject;
//  getBlocksWithLimitResult = TArray<UInt64>;
//
//  getClusterNodesResultItem = record
//    pubkey: string;
//    gossip: string;
//    pubsub: string;
//    rpc: string;
//    tpu: string;
//    featureSet: UInt32;
//    shredVersion: UInt16;
//    serveRepair: string;
//    tpuForwards: string;
//    tpuForwardsQuic: string;
//    tpuQuic: string;
//    tpuVote: string;
//    tvu: string;
//    version: string;
//  end;
//
//  getClusterNodesResult = TArray<getClusterNodesResultItem>;
//
//  getInflationRateResult = record
//    total: Float64;
//    validator: Float64;
//    foundation: Float64;
//    epoch: UInt64;
//  end;
//
//  getInflationRewardResult = record
//  end;
//
//  getLargestAccountsConfigObject = record
//    commitment: TCommitment;
//    filter: string;
//  end;
//
//  getLargestAccountsResultItem = record
//    address: string;
//    lamports: UInt64;
//  end;
//  getLargestAccountsResult = RPCResponse<TArray<getLargestAccountsResultItem>>;
//
//  getLatestBlockhashResultItem = record
//    blockhash: string;
//    lastValidBlockHeight: UInt64;
//  end;
//  getLatestBlockhashResult = RPCResponseContext<getLatestBlockhashResultItem>;
//  getLeaderScheduleResult = TDictionary<string, TArray<UInt64>>;
//
//  getMinimumBalanceForRentExemptionConfigObject = getBlocksConfigObject;
//
//  getMultipleAccountsConfigObject = record
//    commitment: TCommitment;
//    minContextSlot: UInt64;
//    /// <summary>
//    /// Only available to base58, base64 or base64+zstd encodings
//    /// </summary>
//    dataSlice: TdataSlice;
//    encoding: TEncoding;
//  end;
//
//  getMultipleAccountsResultItem = record
//    data: TArray<string>;
//    lamports: UInt64;
//    owner: string;
//    executable: Boolean;
//    rentEpoch: UInt64;
//    space: UInt64;
//  end;
//
//  getMultipleAccountsResult = RPCResponseContext<TArray<getMultipleAccountsResultItem>>;
//  getProgramAccountsResult = record
//  end;
//
//  getRecentPerformanceSamplesResultItem = record
//    slot: UInt64;
//    numTransactions: UInt64;
//    numSlots: UInt64;
//    samplePeriodSecs: UInt16;
//    numNonVoteTransactions: UInt64;
//  end;
//  getRecentPerformanceSamplesResult = TArray<getRecentPerformanceSamplesResultItem>;
//
//  getRecentPrioritizationFeesResultItem = record
//    slot: UInt64;
//    prioritizationFee: UInt64;
//  end;
//  getRecentPrioritizationFeesResult = TArray<getRecentPrioritizationFeesResultItem>;
//
//  getSignaturesForAddressResultItem = record
//    signature: string;
//    slot: UInt64;
//    err: record // TODO -ochuacw -cInvestigate: What are the fields for err?
//    end;
//    memo: string;
//    blockTime: Int64;
//    confirmationStatus: TCommitment; // TODO -ochuacw -cInvestigate: is this TCommitment?
//  end;
//  getSignaturesForAddressResult = TArray<getSignaturesForAddressResultItem>;
//
//  getSignatureStatusesResultItem = record
//    slot: UInt64;
//    confirmations: NativeUInt;
//    err: record
//    end;
//    confirmationStatus: TCommitment;
//    // status: TDictionary<string, >;
//  end;
//  getSignatureStatusesResult = RPCResponseContext<TArray<getSignatureStatusesResultItem>>;
//  searchTransactionHistoryObj = record
//    searchTransactionHistory: Boolean;
//    constructor Create(ASearchTransactionHistory: Boolean);
//  end;
//
//  getSlotConfigObject = getBalanceConfigObject;
//  getSlotLeaderConfigObject = getBalanceConfigObject;
//  getStakeMinimumDelegationConfigObject = getBlocksConfigObject;
//
//  getSupplyConfigObject = record
//    commitment: TCommitment;
//    excludeNonCirculatingAccountsList: Boolean;
//    constructor Create(ACommitment: TCommitment;
//      AexcludeNonCirculatingAccountsList: Boolean);
//  end;
//  getSupplyResultItem = record
//    total: UInt64;
//    circulating: UInt64;
//    nonCirculating: UInt64;
//    nonCirculatingAccounts: TArray<string>;
//  end;
//  getSupplyResult = RPCResponseContext<getSupplyResultItem>;
//
//  getTokenAccountBalanceConfigObject = commitmentConfigObject;
//  getTokenAccountBalanceResultItem = record
//    amount: string;
//    decimals: UInt8;
//    uiAmount: Float64;
//    uiAmountString: string;
//  end;
//  getTokenAccountBalanceResult = RPCResponse<getTokenAccountBalanceResultItem>;
//
//  MintObj = record
//    mint: string;
//    constructor Create(const AMint: string);
//  end;
//  ProgramIdObj = record
//    programId: string;
//    constructor Create(const AProgramId: string);
//  end;
//
//  EncodingObj = record
//    encoding: TEncoding;
//    constructor Create(AEncoding: TEncoding);
//  end;
//  getTokenAccountsByDelegateConfigObject_2 = record
//    commitment: TCommitment;
//    minContextSlot: UInt64;
//    dataSlice: TDataSliceOffset;
//    encoding: TEncoding;
//  end;
//  getTokenAccountsByDelegateConfigObject = record
//    class function Create(
//      ACommitment: TCommitment;
//      AEncoding: TEncoding;
//      AMinContextSlot: UInt64;
//      ADataSlice: TDataSliceOffset
//    ): getTokenAccountsByDelegateConfigObject_2; overload; static;
//  end;
//
//  getTokenAccountsByDelegateResultItem = record
//  end;
//  getTokenAccountsByDelegateResult = RPCResponse<getTokenAccountsByDelegateResultItem>;
//
//  getTokenAccountsByOwnerResultItem = record
//    account: record
//      data: record
//        parsed: record
//          info: record
//            isNative: Boolean;
//            mint: string;
//            owner: string;
//            state: string;
//            tokenAmount: TokenAmount;
//          end;
//          [JsonName('type')]
//          &type: string;
//        end;
//        [JsonName('program')]
//        &program: string;
//      end;
//      executable: Boolean;
//      lamports: UInt64;
//      owner: string;
//      rentEpoch: UInt64;
//      space: UInt64;
//    end;
//    pubkey: string;
//  end;
//  getTokenAccountsByOwnerResultArray = TArray<getTokenAccountsByOwnerResultItem>;
//  getTokenAccountsByOwnerResult = RPCResponseContext<getTokenAccountsByOwnerResultArray>;
//
//  getTokenLargestAccountsResultItem = record
//    address: string;
//    amount: string;
//    decimals: Integer;
//    uiAmount: Float64;
//    uiAmountString: string;
//  end;
//  getTokenLargestAccountsResultArray = TArray<getTokenLargestAccountsResultItem>;
//  getTokenLargestAccountsResult = RPCResponseContext<getTokenLargestAccountsResultArray>;
//
//  getTokenSupplyResult = RPCResponseContext<TokenAmount>;
//
//  // TODO -ochuacw -cInvestigate: This is incomplete
//  getTransactionResult = record
//    blockTime: Int64;
//  end;
//
//  sendTransactionConfigObject = record
//    Encoding: TEncoding;
//    skipPreflight: Boolean;
//    preflightCommitment: TCommitment;
//    maxRetries: NativeUInt;
//    minContextSlot: UInt64;
//    constructor Create(AEncoding: TEncoding; ASkipPreflight: Boolean;
//      APreflightCommitment: TCommitment; AMaxRetries: NativeUInt;
//      AMinContextSlot: UInt64);
//  end;
//
//  simulateTransactionConfigObjectAccounts = record
//    addresses: TArray<string>; // base-58 encoded string
//    encoding: TEncoding;
//    constructor Create(const AAddresses: TArray<string>; AEncoding: TEncoding);
//  end;
//  simulateTransactionConfigObject = record
//    commitment: TCommitment;
//    sigVerify: Boolean;
//    replaceRecentBlockhash: Boolean;
//    minContextSlot: UInt64;
//    encoding: TEncoding;
//    innerInstructions: Boolean;
//    accounts: simulateTransactionConfigObjectAccounts;
//    constructor Create(
//      ACommitment: TCommitment; ASigVerify: Boolean;
//      AReplaceRecentBlockHash: Boolean;
//      AMinContextSlot: UInt64;
//      AEncoding: TEncoding;
//      AInnerInstructions: Boolean;
//      const AAccounts: simulateTransactionConfigObjectAccounts);
//  end;
//
//  // TODO -ochuacw -cInvestigate: This is incomplete
//  simulateTransactionResult = record
//  end;

  /// <summary>
  /// Implements the Solana JSON RPC API as documented at https://docs.solana.com/api/http
  /// </summary>
  ISolanaJSONRPC = interface(IJSONRPCMethods)
    ['{D03B9695-4452-4FE2-9354-34175017E9A1}']

    /// <summary>
    /// Returns all information associated with the account of provided Pubkey
    /// </summary>
    /// <param name="pubKeyAccount">
    /// </param>
    /// <param name="config">
    /// </param>
    /// <returns>
    /// Returns all information associated with the account of provided Pubkey
    /// </returns>
    function getAccountInfo(const pubKeyAccount: string): getAccountInfoResult_2; overload;

    /// <summary>
    /// Returns all information associated with the account of provided Pubkey
    /// </summary>
    /// <param name="pubKeyAccount">
    /// </param>
    /// <param name="config">
    /// </param>
    /// <returns>
    /// Returns all information associated with the account of provided Pubkey
    /// </returns>
    function getAccountInfo(
      const pubKeyAccount: string;
      const config: getAccountInfoConfigObject_1): getAccountInfoResult; overload;

    /// <summary>
    /// Returns all information associated with the account of provided Pubkey
    /// </summary>
    /// <param name="pubKeyAccount">
    /// </param>
    /// <param name="config">
    /// </param>
    /// <returns>
    /// Returns all information associated with the account of provided Pubkey
    /// </returns>
    function getAccountInfo(
      const pubKeyAccount: string;
      const config: getAccountInfoConfigObject_2
    ): getAccountInfoResult; overload;

    /// <summary>
    /// Returns all information associated with the account of provided Pubkey
    /// </summary>
    /// <param name="pubKeyAccount">
    /// </param>
    /// <param name="config">
    /// </param>
    /// <returns>
    /// Returns all information associated with the account of provided Pubkey
    /// </returns>
    function getAccountInfo(
      const pubKeyAccount: string;
      const config: getAccountInfoConfigObject_3
    ): getAccountInfoResult; overload;

    /// <summary>
    /// Returns the lamport balance of the account of provided Pubkey
    /// </summary>
    /// <param name="pubKeyAccount">
    /// </param>
    /// <returns>
    /// lamport balance of the account of provided Pubkey
    /// </returns>
    function getBalance(const pubKeyAccount: string): RPCResponseU64; overload;

    /// <summary>
    /// Returns the lamport balance of the account of provided Pubkey
    /// </summary>
    /// <param name="pubKeyAccount">
    /// </param>
    /// <returns>
    /// lamport balance of the account of provided Pubkey
    /// </returns>
    function getBalance(
      const pubKeyAccount: string; const config: getBalanceConfigObject
    ): RPCResponseU64; overload;

    /// <summary>
    /// Returns identity and transaction information about a confirmed block in the ledger
    /// </summary>
    /// <param name="Block">
    /// </param>
    /// <returns>
    /// identity and transaction information about a confirmed block in the ledger
    /// </returns>
    function getBlock(const Block: UInt64): getBlockResult; overload;
    /// <summary>
    /// Returns identity and transaction information about a confirmed block in the ledger
    /// </summary>
    /// <param name="Block">
    /// </param>
    /// <param name="config">
    /// Configuration object
    /// </param>
    /// <returns>
    /// identity and transaction information about a confirmed block in the ledger
    /// </returns>
    function getBlock(
      const Block: UInt64;
      const config: getBlockConfigObject
    ): getBlockResult; overload;
    function getBlockCommitment(const blockNumber: UInt64): getBlockCommitmentResult;

    function getBlockHeight: UInt64; overload;
    function getBlockHeight(AConfigObj: getBlockHeightConfigObject): UInt64; overload;

    /// <summary>
    /// </summary>
    /// <returns>
    /// Returns recent block production information from the current or previous epoch.
    /// </returns>
    function getBlockProduction: TgetBlockProductionResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="configObj">
    /// </param>
    /// <returns>
    /// Returns recent block production information from the current or previous epoch.
    /// </returns>
    function getBlockProduction(
      const configObj: getBlockProductionConfigObject
    ): TgetBlockProductionResult; overload;

    function getBlocks(startSlot: UInt64; endSlot: UInt64): getBlocksResult; overload;
    function getBlocks(
      startSlot: UInt64; endSlot: UInt64;
      const configObject: getBlocksConfigObject
    ): getBlocksResult; overload;

    function getBlocksWithLimit(
      startSlot: UInt64; limit: UInt64
    ): getBlocksWithLimitResult; overload;
    function getBlocksWithLimit(
      startSlot: UInt64; limit: UInt64;
      configObject: getBlocksWithLimitConfigObject
    ): getBlocksWithLimitResult; overload;

    function getBlockTime(blockNumber: UInt64): Int64;
    /// <summary>
    /// Returns information about all the nodes participating in the cluster
    /// </summary>
    /// <returns>
    /// Returns information about all the nodes participating in the cluster
    /// </returns>
    function getClusterNodes: getClusterNodesResult;

    function getEpochInfo: getEpochInfoResult; overload;
    function getEpochInfo(
      const configObject: getEpochInfoConfigObject
    ): getEpochInfoResult; overload;

    function getEpochSchedule: getEpochScheduleResult;
    function getFeeForMessage(const msg: string): getFeeForMessageResult; overload;
    function getFeeForMessage(
      const msg: string; const configObject: getFeeForMessageConfigObject
    ): getFeeForMessageResult; overload;

    /// <summary>
    /// Returns the slot of the lowest confirmed block that has not been purged from the ledger
    /// </summary>
    /// <returns>
    /// slot of the lowest confirmed block that has not been purged from the ledger
    /// </returns>
    function getFirstAvailableBlock: UInt64;

    /// <summary>
    /// Returns the genesis hash
    /// </summary>
    /// <returns>
    /// genesis hash
    /// </returns>
    function getGenesisHash: string;

    /// <summary>
    /// Returns the current health of the node. A healthy node is one that is within HEALTH_CHECK_SLOT_DISTANCE slots of the latest cluster confirmed slot.
    /// </summary>
    /// <returns>
    /// </returns>
    function getHealth: string;

    /// <summary>
    /// Returns the highest slot information that the node has snapshots for.
    /// <para />This will find the highest full snapshot slot, and the highest incremental snapshot slot based on the full snapshot slot, if there is one.
    /// </summary>
    /// <returns>
    /// </returns>
    function getHighestSnapshotSlot: getHighestSnapshotSlotResult;

    /// <summary>
    /// Returns the identity pubkey for the current node
    /// </summary>
    /// <returns>
    /// the identity pubkey for the current node
    /// </returns>
    function getIdentity: getIdentityResult;

    /// <summary>
    /// Returns the current inflation governor
    /// </summary>
    /// <returns>
    /// Current inflation governor
    /// </returns>
    function getInflationGovernor: getInflationGovernorResult; overload;

    /// <summary>
    /// Returns the current inflation governor
    /// </summary>
    /// <param name="configObject">
    /// </param>
    /// <returns>
    /// Current inflation governor
    /// </returns>
    function getInflationGovernor(
      const configObject: getInflationGovernorConfigObject
    ): getInflationGovernorResult; overload;

    /// <summary>
    /// Returns the specific inflation values for the current epoch
    /// </summary>
    /// <returns>
    /// specific inflation values for the current epoch
    /// </returns>
    function getInflationRate: getInflationRateResult;

    /// <summary>
    /// Returns the inflation / staking reward for a list of addresses for an epoch
    /// </summary>
    /// <returns>
    /// </returns>
    function getInflationReward: getInflationRewardResult;

    /// <summary>
    /// Returns the 20 largest accounts, by lamport balance (results may be cached up to two hours)
    /// </summary>
    function getLargestAccounts: getLargestAccountsResult; overload;

    /// <summary>
    /// Returns the 20 largest accounts, by lamport balance (results may be cached up to two hours)
    /// </summary>
    /// <param name="configObject">
    /// </param>
    /// <returns>
    /// </returns>
    function getLargestAccounts(
      const configObject: getLargestAccountsConfigObject
    ): getLargestAccountsResult; overload;
    function getLatestBlockhash: getLatestBlockhashResult; overload;

    function getLeaderSchedule: getLeaderScheduleResult; overload;
    function getLeaderSchedule(epoch: UInt64): getLeaderScheduleResult; overload;
    function getLeaderSchedule(epoch: UInt64; configObj: IdentityObj): getLeaderScheduleResult; overload;
    function getLeaderSchedule(configObj: IdentityObj): getLeaderScheduleResult; overload;

    /// <summary>
    /// Get the max slot seen from retransmit stage.
    /// </summary>
    /// <returns>
    /// </returns>
    function getMaxRetransmitSlot: UInt64;

    /// <summary>
    /// Get the max slot seen from after shred insert.
    /// </summary>
    /// <returns>
    /// </returns>
    function getMaxShredInsertSlot: UInt64;

    /// <summary>
    /// Returns minimum balance required to make account rent exempt.
    /// </summary>
    /// <param name="usize">
    /// </param>
    /// <returns>
    /// </returns>
    function getMinimumBalanceForRentExemption(usize: UInt64): UInt64; overload;

    /// <summary>
    /// Returns minimum balance required to make account rent exempt.
    /// </summary>
    /// <param name="usize">
    /// </param>
    /// <param name="configObject">
    /// </param>
    /// <returns>
    /// </returns>
    function getMinimumBalanceForRentExemption(usize: UInt64;
      configObject: getMinimumBalanceForRentExemptionConfigObject): UInt64; overload;

    function getMultipleAccounts(const pubKeys: TArray<string>;
      configObject: getMultipleAccountsConfigObject): getMultipleAccountsResult; overload;

    function getProgramAccounts(const pubKey: string): getProgramAccountsResult;
    function getRecentPerformanceSamples: getRecentPerformanceSamplesResult; overload;
    function getRecentPerformanceSamples(usize: Word): getRecentPerformanceSamplesResult; overload;

    /// <summary>
    /// Returns a list of prioritization fees from recent blocks.
    /// </summary>
    /// <returns>
    /// </returns>
    function getRecentPrioritizationFees: getRecentPrioritizationFeesResult; overload;

    /// <summary>
    /// Returns a list of prioritization fees from recent blocks.
    /// </summary>
    /// <param name="addresses">
    /// Up to max of 128 base-58 encoded addresses
    /// </param>
    /// <returns>
    /// </returns>
    function getRecentPrioritizationFees(
      const addresses: TArray<string>
    ): getRecentPrioritizationFeesResult; overload;

    /// <summary>
    /// Returns signatures for confirmed transactions that include the given address in their accountKeys list.
    /// Returns signatures backwards in time from the provided signature or most recent confirmed block.
    /// </summary>
    /// <param name="address">
    /// </param>
    /// <returns>
    /// </returns>
    function getSignaturesForAddress(
      const address: string
    ): getSignaturesForAddressResult;

    /// <summary>
    /// Returns the statuses of a list of signatures. Each signature must be a txid, the first signature of a transaction.
    /// </summary>
    /// <param name="signatures">
    /// </param>
    /// <returns>
    /// </returns>
    /// <remarks>
    /// Unless the searchTransactionHistory configuration parameter is included, this method only searches the recent status cache of signatures, which retains statuses for all active slots plus MAX_RECENT_BLOCKHASHES rooted slots.
    /// </remarks>
    function getSignatureStatuses(
      const signatures: TArray<string>
    ): getSignatureStatusesResult; overload;
    function getSignatureStatuses(
      const signatures: TArray<string>;
      searchTransactionHistory: searchTransactionHistoryObj
    ): getSignatureStatusesResult; overload;

    /// <summary>
    /// Returns the slot that has reached the given or default commitment level
    /// </summary>
    /// <returns>
    /// </returns>
    function getSlot: UInt64; overload;
    function getSlot(const configObject: getSlotConfigObject): UInt64; overload;

    function getSlotLeader: string; overload;
    function getSlotLeader(const configObject: getSlotLeaderConfigObject): string; overload;

    /// <summary>
    /// Returns the slot leaders for a given slot range
    /// </summary>
    /// <param name="startSlot">
    /// Start slot
    /// </param>
    /// <param name="Limit">
    /// Limit
    /// </param>
    /// <returns>
    /// An array of node identity public keys as base-58 encoded strings
    /// </returns>
    function getSlotLeaders(startSlot: UInt64; Limit: UInt64): TArray<string>;

    // procedure getStakeActivation;
    /// <summary>
    /// Returns the stake minimum delegation, in lamports.
    /// </summary>
    /// <returns>
    /// </returns>
    function getStakeMinimumDelegation(): RPCResponse<UInt64>; overload;

    // procedure getStakeActivation;
    /// <summary>
    /// Returns the stake minimum delegation, in lamports.
    /// </summary>
    /// <returns>
    /// </returns>
    function getStakeMinimumDelegation(
      const configObject: getStakeMinimumDelegationConfigObject
    ): RPCResponse<UInt64>; overload;

    /// <summary>
    /// Returns information about the current supply.
    /// </summary>
    /// <returns>
    /// </returns>
    function getSupply: getSupplyResult; overload;
    function getSupply(const configObject: getSupplyConfigObject): getSupplyResult; overload;

    function getTokenAccountBalance(
      const queryAccount: string
    ): getTokenAccountBalanceResult; overload;
    function getTokenAccountBalance(
      const queryAccount: string;
      configObject: getTokenAccountBalanceConfigObject
    ): getTokenAccountBalanceResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="mint">
    /// Create this using MintObj.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByDelegate(const queryAccount: string;
      const mint: MintObj): getTokenAccountsByDelegateResult; overload;
    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="mint">
    /// Create this using MintObj.Create
    /// </param>
    /// <param name="configObj">
    /// Create this using EncodingObj.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByDelegate(const queryAccount: string;
      const mint: MintObj;
      const configObj: EncodingObj): getTokenAccountsByDelegateResult; overload;
    function getTokenAccountsByDelegate(const queryAccount: string;
      const mint: MintObj;
      const configObj: getTokenAccountsByDelegateConfigObject_2
    ): getTokenAccountsByDelegateResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="programId">
    /// Create this using ProgramIdObj.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByDelegate(const queryAccount: string;
      const programId: ProgramIdObj): getTokenAccountsByDelegateResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="programId">
    /// Create this using ProgramIdObj.Create
    /// </param>
    /// <param name="configObj">
    /// Create this using EncodingObj.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByDelegate(const queryAccount: string;
      const programId: ProgramIdObj;
      const configObj: EncodingObj): getTokenAccountsByDelegateResult; overload;
    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="programId">
    /// Create this using ProgramIdObj.Create
    /// </param>
    /// <param name="configObj">
    /// Create this using getTokenAccountsByDelegateConfigObject.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByDelegate(const queryAccount: string;
      const programId: ProgramIdObj;
      const configObj: getTokenAccountsByDelegateConfigObject_2
    ): getTokenAccountsByDelegateResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="AMintObj">
    /// Create this using MintObj.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByOwner(const queryAccount: string;
      const AMintObj: MintObj): getTokenAccountsByOwnerResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="AMintObj">
    /// Create this using MintObj.Create
    /// </param>
    /// <param name="ConfigObj">
    /// Create this using EncodingObj.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByOwner(const queryAccount: string;
      const AMintObj: MintObj; ConfigObj: EncodingObj
    ): getTokenAccountsByOwnerResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="AMintObj">
    /// Create this using MintObj.Create
    /// </param>
    /// <param name="ConfigObj">
    /// Create this using getTokenAccountsByDelegateConfigObject.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByOwner(const queryAccount: string;
      const AMintObj: MintObj;
      ConfigObj: getTokenAccountsByDelegateConfigObject_2
    ): getTokenAccountsByOwnerResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="AProgramIdObj">
    /// Create this using ProgramIdObj.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByOwner(const queryAccount: string;
      const AProgramIdObj: ProgramIdObj): getTokenAccountsByOwnerResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="AProgramIdObj">
    /// Create this using ProgramIdObj.Create
    /// </param>
    /// <param name="ConfigObj">
    /// Create this using EncodingObj.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByOwner(const queryAccount: string;
      const AProgramIdObj: ProgramIdObj; ConfigObj: EncodingObj
    ): getTokenAccountsByOwnerResult; overload;

    /// <summary>
    /// </summary>
    /// <param name="queryAccount">
    /// </param>
    /// <param name="AProgramIdObj">
    /// Create this using ProgramIdObj.Create
    /// </param>
    /// <param name="ConfigObj">
    /// Create this using getTokenAccountsByDelegateConfigObject.Create
    /// </param>
    /// <returns>
    /// </returns>
    function getTokenAccountsByOwner(const queryAccount: string;
      const AProgramIdObj: ProgramIdObj;
      ConfigObj: getTokenAccountsByDelegateConfigObject_2
    ): getTokenAccountsByOwnerResult; overload;

    function getTokenLargestAccounts: getTokenLargestAccountsResult;

    function getTokenSupply(const pubKey: string): getTokenSupplyResult; overload;
    function getTokenSupply(
      const pubKey: string;
      const ACommitmentConfigObj: commitmentConfigObject
    ): getTokenSupplyResult; overload;

    function getTransaction(const ATxSignature: string): getTransactionResult; overload;
    function getTransaction(const ATxSignature: string;
      const ConfigObj: getTransactionConfigObject): getTransactionResult; overload;
    function getTransactionCount: UInt64;

    function getVersion: getVersionResult;
    function getVoteAccounts: getVoteAccountsResult; overload;
    function getVoteAccounts(const configObj: votePubkey): getVoteAccountsResult; overload;
    function getVoteAccounts(const configObj: getVoteAccountsConfigObject): getVoteAccountsResult; overload;

    function isBlockhashValid(const blockhash: string): isBlockhashValidResult; overload;
    function isBlockhashValid(
      const blockhash: string; const configObj: CommitmentContextSlotObj
    ): isBlockhashValidResult; overload;

    function minimumLedgerSlot: UInt64;

    /// <summary>
    /// Requests an airdrop of lamports to a Pubkey
    /// </summary>
    /// <param name="pubKey">
    /// Pubkey of account to receive lamports, as a base-58 encoded string
    /// </param>
    /// <param name="amount">
    /// Amount of lamports to airdrop
    /// </param>
    /// <returns>
    /// Transaction Signature of the airdrop, as a base-58 encoded string
    /// </returns>
    function requestAirdrop(const pubKey: string; amount: UInt64): string; overload;

    /// <summary>
    /// Requests an airdrop of lamports to a Pubkey
    /// </summary>
    /// <param name="pubKey">
    /// Pubkey of account to receive lamports, as a base-58 encoded string
    /// </param>
    /// <param name="amount">
    /// Amount of lamports to airdrop
    /// </param>
    /// <param name="requestAirDropConfigObject">
    /// </param>
    /// <returns>
    /// Transaction Signature of the airdrop, as a base-58 encoded string
    /// </returns>
    function requestAirdrop(const pubKey: string; amount: UInt64; requestAirDropConfigObject: requestAirDropCommitment): string; overload;

    /// <summary>
    /// Submits a signed transaction to the cluster for processing.
    /// This method does not alter the transaction in any way; it relays the transaction created by clients to the node as-is.
    ///
    /// If the node's rpc service receives the transaction, this method immediately succeeds, without waiting for any confirmations. A successful response from this method does not guarantee the transaction is processed or confirmed by the cluster.
    ///
    /// While the rpc service will reasonably retry to submit it, the transaction could be rejected if transaction's recent_blockhash expires before it lands.
    ///
    /// Use getSignatureStatuses to ensure a transaction is processed and confirmed.
    ///
    /// Before submitting, the following preflight checks are performed:
    ///
    ///     The transaction signatures are verified
    ///     The transaction is simulated against the bank slot specified by the preflight commitment. On failure an error will be returned. Preflight checks may be disabled if desired. It is recommended to specify the same commitment and preflight commitment to avoid confusing behavior.
    ///
    /// The returned signature is the first signature in the transaction, which is used to identify the transaction (transaction id). This identifier can be easily extracted from the transaction data before submission.
    /// </summary>
    /// <param name="signedTransaction">
    /// Fully-signed Transaction, as encoded string.
    /// </param>
    /// <returns>
    /// </returns>
    function sendTransaction(const signedTransaction: string): string; overload;

    /// <summary>
    /// Submits a signed transaction to the cluster for processing.
    /// This method does not alter the transaction in any way; it relays the transaction created by clients to the node as-is.
    ///
    /// If the node's rpc service receives the transaction, this method immediately succeeds, without waiting for any confirmations. A successful response from this method does not guarantee the transaction is processed or confirmed by the cluster.
    ///
    /// While the rpc service will reasonably retry to submit it, the transaction could be rejected if transaction's recent_blockhash expires before it lands.
    ///
    /// Use getSignatureStatuses to ensure a transaction is processed and confirmed.
    ///
    /// Before submitting, the following preflight checks are performed:
    ///
    ///     The transaction signatures are verified
    ///     The transaction is simulated against the bank slot specified by the preflight commitment. On failure an error will be returned. Preflight checks may be disabled if desired. It is recommended to specify the same commitment and preflight commitment to avoid confusing behavior.
    ///
    /// The returned signature is the first signature in the transaction, which is used to identify the transaction (transaction id). This identifier can be easily extracted from the transaction data before submission.
    /// </summary>
    /// <param name="signedTransaction">
    /// Fully-signed Transaction, as encoded string.
    /// </param>
    /// <param name="configObj">
    /// </param>
    /// <returns>
    /// </returns>
    function sendTransaction(
      const signedTransaction: string;
      const configObj: sendTransactionConfigObject
    ): string; overload;

    /// <summary>
    /// Simulate sending a transaction
    /// </summary>
    /// <param name="signedTransaction">
    /// Transaction, as an encded string
    /// </param>
    /// <returns>
    /// </returns>
    function simulateTransaction(
      const signedTransaction: string
    ): simulateTransactionResult; overload;

    /// <summary>
    /// Simulate sending a transaction
    /// </summary>
    /// <param name="signedTransaction">
    /// Transaction, as an encded string
    /// </param>
    /// <param name="AEncodingObj">
    /// Create this using EncodingObj.Create
    /// </param>
    /// <returns>
    /// </returns>
    function simulateTransaction(
      const signedTransaction: string;
      const AEncodingObj: EncodingObj
    ): simulateTransactionResult; overload;

    /// <summary>
    /// Simulate sending a transaction
    /// </summary>
    /// <param name="signedTransaction">
    /// Transaction, as an encded string
    /// </param>
    /// <param name="configObj">
    /// </param>
    /// <returns>
    /// </returns>
    function simulateTransaction(
      const signedTransaction: string;
      const configObj: simulateTransactionConfigObject
    ): simulateTransactionResult; overload;
  end;

implementation

//{ commitmentConfigObject }
//
//constructor commitmentConfigObject.Create(ACommitment: TCommitment);
//begin
//  commitment := ACommitment;
//end;
//
//{ CommitmentContextSlotObj }
//
//constructor CommitmentContextSlotObj.Create(ACommitment: TCommitment; AMinContextSlot: UInt64);
//begin
//  commitment := ACommitment;
//  minContextSlot := AMinContextSlot;
//end;
//
//constructor CommitmentContextSlotObj.Create(AMinContextSlot: UInt64; ACommitment: TCommitment = finalized);
//begin
//  minContextSlot := AMinContextSlot;
//  commitment := ACommitment;
//end;
//
//{ getBlockConfigObject }
//
//constructor getBlockConfigObject.Create(ACommitment: TCommitment;
//  AEncoding: TEncoding = TEncoding.json;
//  ATransactionDetails: TTransactionDetails = full;
//  AMaxSupportedTransactionVersion: Integer = 0;
//  ARewards: Boolean = True
//);
//begin
//  encoding := AEncoding;
//  transactionDetails := ATransactionDetails;
//  maxSupportedTransactionVersion := AMaxSupportedTransactionVersion;
//  rewards := ARewards;
//end;
//
//{ getBlocksConfigObject }
//
//constructor getBlocksConfigObject.Create(ACommitment: TCommitment);
//begin
//  commitment := ACommitment;
//end;
//
//{ searchTransactionHistoryObj }
//
//constructor searchTransactionHistoryObj.Create(ASearchTransactionHistory: Boolean);
//begin
//  searchTransactionHistory := ASearchTransactionHistory;
//end;
//
//{ getSupplyConfigObject }
//
//constructor getSupplyConfigObject.Create(ACommitment: TCommitment;
//  AexcludeNonCirculatingAccountsList: Boolean);
//begin
//  commitment := ACommitment;
//  excludeNonCirculatingAccountsList := AexcludeNonCirculatingAccountsList;
//end;
//
//{ MintObj }
//
//constructor MintObj.Create(const AMint: string);
//begin
//  mint := AMint;
//end;
//
//{ ProgramIdObj }
//
//constructor ProgramIdObj.Create(const AProgramId: string);
//begin
//  programId := AProgramId;
//end;
//
//{ EncodingObj }
//
//constructor EncodingObj.Create(AEncoding: TEncoding);
//begin
//  encoding := AEncoding;
//end;
//
//{ getTokenAccountsByDelegateConfigObject }
//
//class function getTokenAccountsByDelegateConfigObject.Create(
//  ACommitment: TCommitment;
//  AEncoding: TEncoding;
//  AMinContextSlot: UInt64;
//  ADataSlice: TDataSliceOffset
//): getTokenAccountsByDelegateConfigObject_2;
//begin
//  Result.commitment := ACommitment;
//  Result.encoding   := AEncoding;
//  Result.minContextSlot := AMinContextSlot;
//  Result.dataSlice := ADataSlice;
//end;
//
//{ votePubkey }
//
//constructor votePubkey.Create(const AVotePubKey: string);
//begin
//  votePubkey := AVotePubKey;
//end;
//
//{ getVoteAccountsConfigObject }
//constructor getVoteAccountsConfigObject.Create(ACommitment: TCommitment; const AVotePubkey: string;
//  AkeepUnstakedDelinquents: Boolean;
//  AdelinquentSlotDistance: UInt64);
//begin
//  commitment := ACommitment;
//  votePubkey := AVotePubkey;
//  keepUnstakedDelinquents := AkeepUnstakedDelinquents;
//  delinquentSlotDistance := AdelinquentSlotDistance;
//end;
//
//{ requestAirDropCommitment }
//
//constructor requestAirDropCommitment.Create(ACommitment: TCommitment);
//begin
//  commitment := ACommitment;
//end;
//
//{ sendTransactionConfigObject }
//
//constructor sendTransactionConfigObject.Create(AEncoding: TEncoding; ASkipPreflight: Boolean;
//  APreflightCommitment: TCommitment; AMaxRetries: NativeUInt;
//  AMinContextSlot: UInt64);
//begin
//  Encoding := AEncoding;
//  skipPreflight := ASkipPreflight;
//  preflightCommitment := APreflightCommitment;
//  maxRetries := AMaxRetries;
//  minContextSlot := AMinContextSlot;
//end;
//
//{ simulateTransactionConfigObjectAccounts }
//
//constructor simulateTransactionConfigObjectAccounts.Create(const AAddresses: TArray<string>; AEncoding: TEncoding);
//begin
//  addresses := AAddresses;
//  encoding := AEncoding;
//end;
//
//{ simulateTransactionConfigObject }
//
//constructor simulateTransactionConfigObject.Create(
//  ACommitment: TCommitment; ASigVerify: Boolean;
//  AReplaceRecentBlockHash: Boolean;
//  AMinContextSlot: UInt64;
//  AEncoding: TEncoding;
//  AInnerInstructions: Boolean;
//  const AAccounts: simulateTransactionConfigObjectAccounts);
//begin
//  commitment := ACommitment;
//  sigVerify := ASigVerify;
//  replaceRecentBlockhash := AReplaceRecentBlockHash;
//  minContextSlot := AMinContextSlot;
//  encoding := AEncoding;
//  innerInstructions := AInnerInstructions;
//  accounts := AAccounts;
//end;

initialization
  RegisterJSONRPCWrapper(TypeInfo(ISolanaJSONRPC));
end.
