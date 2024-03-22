unit JSONRPC.Web3.Polkadot.Types;

interface

uses
  Velthuis.BigIntegers, System.Generics.Collections;

type
  TSystemHealth = record
    peers: Integer;
    isSyncing: Boolean;
    shouldHavePeers: Boolean;
  end;

  HexBytes = BigInteger;
  TBlockHash = BigInteger;
  TGetBlockHash = BigInteger;
  THash = string;
  THex = string;
  StorageKey = string;
  TAccountNonce = UInt64;

  TMethods = record
    methods: TArray<string>;
  end;

// {"startingBlock":19480132,"currentBlock":19523851,"highestBlock":19523851},"id":6}
  TSyncState = record
    startingBlock: UInt32;
    currentBlock: UInt32;
    highestBlock: UInt32;
  end;

  TSyncStateGenSyncSpecProperties = record
    ss58Format: UInt32;
    tokenDecimals: UInt32;
    tokenSymbol: string;
  end;
  TSyncStateGenSyncSpecCodeSubstitutes = TDictionary<BigInteger, string>;
  TSyncStateGenSyncSpecGenesisRawTop = TDictionary<BigInteger, BigInteger>;
  TSyncStateGenSyncSpecGenesisRawChildrenDefault = TDictionary<BigInteger, BigInteger>;
  TSyncStateGenSyncSpecGenesisRaw = record
    childrenDefault: TSyncStateGenSyncSpecGenesisRawChildrenDefault;
    top: TSyncStateGenSyncSpecGenesisRawTop;
  end;
  TSyncStateGenSyncSpecGenesis = record
    raw: TSyncStateGenSyncSpecGenesisRaw;
  end;
  TSyncStateGenSyncSpecLightSyncState = record
    babeEpochChanges: BigInteger;
    babeFinalizedBlockWeight: BigInteger;
    finalizedBlockHeader: BigInteger;
    grandpaAuthoritySet: BigInteger;
  end;

  // [
  //  string, // URL to telemetry
  //  UInt32  // max verbosity level
  // ]
  telemetryEndpointsElement = TArray<Variant>;

  // [
  //  UInt32, // block number
  //  Hash    // hash
  // ]
  TForkBlocksElement = TArray<Variant>;

  TSyncStateGenSyncSpec = record
    badBlocks: TArray<TBlockHash>;
    bootNodes: TArray<string>;
    chainType: string;
    codeSubstitutes: TSyncStateGenSyncSpecCodeSubstitutes;
    forkBlocks: TArray<
      TForkBlocksElement
    >;
    genesis: TSyncStateGenSyncSpecGenesis;
    id: string;
    lightSyncState: TSyncStateGenSyncSpecLightSyncState;
    name: string;
    properties: TSyncStateGenSyncSpecProperties;
    protocolId: string;
    telemetryEndpoints: TArray<telemetryEndpointsElement>;
  end;

  // https://spec.polkadot.network/chap-runtime-api
  TStateCallType = (
    NominationPoolsApi_pending_rewards, // args = account id
    NominationPoolsApi_points_to_balance,
    NominationPoolsApi_balance_to_points
  );

  TSystemProperties = record
    ss58Format: Integer;
    tokenDecimals: Integer;
    tokenSymbol: string;
  end;

  // <summary> base58 encoded PeerId </summary>
  TPeerId = string;

  TAPIs = TArray<TArray<BigInteger>>;

  TRuntimeVersion = record
    specName: string;
    implName: string;
    authoringVersion: Integer;
    specVersion: Integer;
    implVersion: Integer;
    apis: TAPIs;
    transactionVersion: Integer;
    stateVersion: Integer;
  end;

  TAccountId = string;

  TSystemPeerRoles = (NONE, FULL, LIGHT, AUTHORITY);
  TSystemPeers = record
    PeerId: string;
    roles: TSystemPeerRoles;
    protocolVersion: UInt32;
    bestHash: THex;
    bestNumber: UInt64;
  end;

  // Not completely defined
  TBabeEpochAuthorship = record // unsafe
  end;

  TVotes = record
    currentWeight: UInt32;
    missing: TArray<string>; // address of authority
  end;

  TRoundState = record
    round: UInt32;
    totalWeight: UInt32;
    thresholdWeight: UInt32;
    prevotes: TVotes;
    precommits: TVotes;
  end;

  TGrandpaRoundState = record
    setId: UInt32;
    best: TRoundState;
    background: TArray<TRoundState>;
  end;

  TDigest = record
    logs: TArray<BigInteger>;
  end;

  TGetBlockHeader = record
    number: BigInteger;
    parentHash: BigInteger;
    stateRoot: BigInteger;
    extrinsicsRoot: BigInteger;
    digest: TDigest;
  end;

  TGetHeader = record
    number: BigInteger;
    parentHash: BigInteger;
    stateRoot: BigInteger;
    extrinsicsRoot: BigInteger;
    digest: TDigest;
  end;

  TBlock = record
    header: TGetBlockHeader;
    extrinsics: TArray<BigInteger>;
  end;

  TGetBlock = record
    block: TBlock;
    justifications: string;
  end;

implementation

end.

