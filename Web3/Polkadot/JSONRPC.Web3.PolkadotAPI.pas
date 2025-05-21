﻿
unit JSONRPC.Web3.PolkadotAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Web3.Common.Types, JSONRPC.Common.Types,
  System.SysUtils, System.JSON, Velthuis.BigIntegers,
  JSONRPC.Web3.Polkadot.Types;

const
  UnsafeRPCCall = 'RPC call is unsafe to be called externally';

type


  // See also: https://github.com/w3f/PSPs/blob/master/PSPs/drafts/psp-6.md

  IPolkadotJSONRPC = interface(IJSONRPCMethods)
    ['{B21C77FA-2E80-43CC-8689-F7A6A94FB918}']


    // -------- AUTHOR ----------------------------------

    function author_pendingExtrinsics: TArray<BigInteger>; // tested
    function author_removeExtrinsic(const bytesOrHash: TArray<THash>): TArray<THash>; deprecated 'RPC call is unsafe to be called externally';
    function author_hasSessionKeys(const sessionKeys: THash): Boolean; // tested without session key

    // -------- BABE ----------------------------------
    function babe_epochAuthorship: TBabeEpochAuthorship; deprecated 'RPC call is unsafe to be called externally';

    // -------- CHAIN ----------------------------------

    function chain_getBlock: TGetBlock; safecall; overload;
    function chain_getBlock(const ABlockHash: TBlockHash): TGetBlock; safecall; overload;

    /// <summary>
    /// Gets the block hash for the given block number
    /// <param name="blockNumber">Block number to get hash for </param>
    /// </summary>
    function chain_getBlockHash: TGetBlockHash; safecall; overload;
    function chain_getBlockHash(blockNumber: Integer): TBlockHash; safecall; overload;
    function chain_getBlockHash(blockNumber: BigInteger; nth_Block: BigInteger; nth_Block2: UInt32): TBlockHash; safecall; overload;
    function chain_getHeader: TGetHeader; safecall;

    // -------- GRANDPA ----------------------------------
    function grandpa_proveFinality(BlockNumber: UInt32): BigInteger; safecall;

    function grandpa_roundState: TGrandpaRoundState; safecall;

    // -------- MISCELLANEOUS ----------------------------------

    function getFinalizedHead: TBlockHash; safecall; deprecated 'may not be available, depending on the server connected to';

    /// <summary> List supported methods </summary>
    /// <returns> A record with the field methods containing an array
    /// of method names </returns>
    function rpc_methods: TMethods; safecall; // tested

    // -------- STATE ----------------------------------

    // {"id":266,"jsonrpc":"2.0","method":"state_call",
    // "params":["NominationPoolsApi_pending_rewards","0x5626fb92ce5aacc7ac4dd042dd55308832ba8dde38c557b140ae8740948fe76c"]}
    // {"id":108,"jsonrpc":"2.0","method":"state_call","params":["NominationPoolsApi_points_to_balance","0xdc000000b9b48ac2020000000000000000000000"]}
    function state_call(const ACallType: TStateCallType; const ABlockHash: TBlockHash): THash;

    function state_getMetadata: BigInteger;
    function state_getStorage(const key: StorageKey; const at: TBlockHash): TBlockHash; safecall;
    function state_getRuntimeVersion: TRuntimeVersion;

    // {"id":261,"jsonrpc":"2.0","method":"state_subscribeStorage",
    //  "params":[["0x7a6d38deaa01cb6e76ee69889f1696271f7c4e57dc49e4d6d003b730a7894f32858f760905c8df5ddc000000","0x7a6d38deaa01cb6e76ee69889f169627fa0883f96ad25255581bef5ba72b8750858f760905c8df5ddc000000","0x26aa394eea5630e07c48ae0c9558cef7b99d880ec681799c0cf30e8886371da9e7f05a1c3ad501c866254c88a1957b596d6f646c70792f6e6f706c7301dc000000000000000000000000000000000000","0x5f3e4907f716ac89b6347d15ececedca9c6a637f62ae2af1c7e31eed7e96be04772b99779fb18abb6d6f646c70792f6e6f706c7300dc000000000000000000000000000000000000"]]}
    function state_subscribeStorage(const AStorageKeys: TArray<StorageKey>): StorageKey;

    // {"id":64,"jsonrpc":"2.0","method":"state_unsubscribeStorage","params":["dODgWqzCtM17x25r"]}
    function state_unsubscribeStorage(const AStorageKey: StorageKey): Boolean;

    // -------- SYNC ----------------------------------
    /// <summary>
    /// Returns the json-serialized chainspec running the node, with a sync state.
    /// </summary>
    function sync_state_genSyncSpec(Raw: Boolean = True): TSyncStateGenSyncSpec;

    // -------- SYSTEM ----------------------------------

    /// <summary>
    /// Retrieves the next accountIndex as available on the node
    /// </summary>
    function system_accountNextIndex(const accountId: TAccountId): TAccountNonce;

    /// <summary> Returns the chain name, eg, Polkadot </summary>
    function system_chain: string; safecall;
    /// <summary> Returns the chain type, eg, Live </summary>
    function system_chainType: string; safecall;
    /// <summary> Return health status of the node </summary>
    function system_health: TSystemHealth; safecall;
    /// <summary>
    /// The addresses include a trailing /p2p/ with the local PeerId, and are
    /// thus suitable to be passed to addReservedPeer or as a bootnode address for example.
    /// </summary>
    /// <remarks>
    /// ['/ip4/10.148.12.7/tcp/30333/p2p/12D3KooWHa94spoLCRnKxdhfBcXB7V9ZekR4tS8WeRJhbhRXoKrt',
    /// '/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWHa94spoLCRnKxdhfBcXB7V9ZekR4tS8WeRJhbhRXoKrt']
    /// </remarks>
    function system_localListenAddresses: TArray<string>; safecall;
    /// <summary>
    ///  Returns the base58-encoded PeerId of the node
    /// </summary>
    function system_localPeerId: string; safecall;
    /// <summary> Retrieves the node name </summary>
    function system_name: string; safecall;
    function system_nodeRoles: TArray<string>; safecall;

    function system_peers: TArray<TSystemPeers>; safecall; deprecated 'RPC call is unsafe to be called externally';
    function system_properties: TSystemProperties; safecall;
    function system_reservedPeers: TArray<TPeerId>; safecall;
    // <summary> Gets the sync state of the node </summary>
    function system_syncState: TSyncState; safecall;

    /// <summary> Retrieves version of the node </summary>
    function system_version: string; safecall;

  end;

  TRewardSlashDataElem = record
    era: BigInteger;
    stash: string;
    account: string;
    validator_stash: string;
    amount: Int64;
    block_timestamp: UInt64;
    event_index: string;
    module_id: string;
    event_id: string;
    extrinsic_index: string;
    invalid_era: Boolean;
  end;

  TRewardSlashData = record
    count: Integer;
    list: TArray<TRewardSlashDataElem>;
  end;

  TRewardSlash = record
    code: Integer;
    message: string;
    generated_at: UInt64;
    data: TRewardSlashData;
  end;

  TRewardsDataElemAccountJudgementElem = record
    Index: Integer;
    judgement: string;
  end;

  TRewardsDataElemAccount = record
    address: string;
    display: string;
    judgements: TArray<TRewardsDataElemAccountJudgementElem>;
    identity: Boolean;
  end;

  TRewardsDataElem = record
    pool_id: Integer;
    module_id: string;
    event_id: string;
    extrinsic_index: string;
    event_index: string;
    block_timestamp: Int64;
    amount: Int64;
    account_display: TRewardsDataElemAccount;
  end;

  TRewardsData = record
    count: Integer;
    list: TArray<TRewardsDataElem>;
  end;

  TRewards = record
    code: Integer;
    message: string;
    generated_at: UInt64;
    data: TRewardsData;
  end;

  IPolkadotJSON = interface(IJSONMethods)
    ['{66EA6BE5-169C-4EFE-9768-BAC62DABB383}']

    [UrlSuffix('api/v2/scan/account/reward_slash')]
    function GetRewardSlash(const address: string; is_stash: Boolean;
      page, row: Integer): TRewardSlash;

    [UrlSuffix('api/scan/nomination_pool/rewards')]
    function GetRewards(const address: string;
      page, row: Integer): TRewards;

  end;

(*
{
  "jsonrpc": "2.0",
  "result": {
    "methods": [
      "account_nextIndex",
      "archive_unstable_body",
      "archive_unstable_call",
      "archive_unstable_finalizedHeight",
      "archive_unstable_genesisHash",
      "archive_unstable_hashByHeight",
      "archive_unstable_header",
      "archive_unstable_storage",
      "author_hasKey",
      "author_hasSessionKeys",
      "author_insertKey",
      "author_pendingExtrinsics",
      "author_removeExtrinsic",
      "author_rotateKeys",
      "author_submitAndWatchExtrinsic",
      "author_submitExtrinsic",
      "author_unwatchExtrinsic",
      "babe_epochAuthorship",
      "beefy_getFinalizedHead",
      "beefy_subscribeJustifications",
      "beefy_unsubscribeJustifications",
      "chainHead_unstable_body",
      "chainHead_unstable_call",
      "chainHead_unstable_continue",
      "chainHead_unstable_follow",
      "chainHead_unstable_header",
      "chainHead_unstable_stopOperation",
      "chainHead_unstable_storage",
      "chainHead_unstable_unfollow",
      "chainHead_unstable_unpin",
      "chainSpec_v1_chainName",
      "chainSpec_v1_genesisHash",
      "chainSpec_v1_properties",
      "chain_getBlock",
      "chain_getBlockHash",
      "chain_getFinalisedHead",
      "chain_getFinalizedHead",
      "chain_getHead",
      "chain_getHeader",
      "chain_getRuntimeVersion",
      "chain_subscribeAllHeads",
      "chain_subscribeFinalisedHeads",
      "chain_subscribeFinalizedHeads",
      "chain_subscribeNewHead",
      "chain_subscribeNewHeads",
      "chain_subscribeRuntimeVersion",
      "chain_unsubscribeAllHeads",
      "chain_unsubscribeFinalisedHeads",
      "chain_unsubscribeFinalizedHeads",
      "chain_unsubscribeNewHead",
      "chain_unsubscribeNewHeads",
      "chain_unsubscribeRuntimeVersion",
      "childstate_getKeys",
      "childstate_getKeysPaged",
      "childstate_getKeysPagedAt",
      "childstate_getStorage",
      "childstate_getStorageEntries",
      "childstate_getStorageHash",
      "childstate_getStorageSize",
      "grandpa_proveFinality",
      "grandpa_roundState",
      "grandpa_subscribeJustifications",
      "grandpa_unsubscribeJustifications",
      "mmr_generateProof",
      "mmr_root",
      "mmr_verifyProof",
      "mmr_verifyProofStateless",
      "offchain_localStorageGet",
      "offchain_localStorageSet",
      "payment_queryFeeDetails",
      "payment_queryInfo",
      "rpc_methods",
      "state_call",
      "state_callAt",
      "state_getChildReadProof",
      "state_getKeys",
      "state_getKeysPaged",
      "state_getKeysPagedAt",
      "state_getMetadata",
      "state_getPairs",
      "state_getReadProof",
      "state_getRuntimeVersion",
      "state_getStorage",
      "state_getStorageAt",
      "state_getStorageHash",
      "state_getStorageHashAt",
      "state_getStorageSize",
      "state_getStorageSizeAt",
      "state_queryStorage",
      "state_queryStorageAt",
      "state_subscribeRuntimeVersion",
      "state_subscribeStorage",
      "state_traceBlock",
      "state_trieMigrationStatus",
      "state_unsubscribeRuntimeVersion",
      "state_unsubscribeStorage",
      "subscribe_newHead",
      "sync_state_genSyncSpec",
      "system_accountNextIndex",
      "system_addLogFilter",
      "system_addReservedPeer",
      "system_chain",
      "system_chainType",
      "system_dryRun",
      "system_dryRunAt",
      "system_health",
      "system_localListenAddresses",
      "system_localPeerId",
      "system_name",
      "system_nodeRoles",
      "system_peers",
      "system_properties",
      "system_removeReservedPeer",
      "system_reservedPeers",
      "system_resetLogFilter",
      "system_syncState",
      "system_unstable_networkState",
      "system_version",
      "transactionWatch_unstable_submitAndWatch",
      "transactionWatch_unstable_unwatch",
      "unsubscribe_newHead"
    ]
  },
  "id": 5
}
*)

function GetPolkadotJSONRPC(const AServerURL: string = '';
  const AOnLoggingOutgoingJSONRPCRequest: TOnLogOutgoingJSONRPCRequest = nil;
  const AOnLoggingIncomingJSONRPCResponse: TOnLogIncomingJSONRPCResponse = nil
): IPolkadotJSONRPC;

function GetPolkadotJSON(const AServerURL: string = '';
  const APIKey: string = '';
  const AOnLoggingOutgoingJSONRPCRequest: TOnLogOutgoingJSONRPCRequest = nil;
  const AOnLoggingIncomingJSONRPCResponse: TOnLogIncomingJSONRPCResponse = nil
): IPolkadotJSON;

implementation

uses
  JSONRPC.InvokeRegistry, JSONRPC.Common.Consts, System.JSON.Types,
  JSONRPC.Client.JSONRPCHTTPWrapper;

function GetPolkadotJSONRPC(const AServerURL: string = '';
  const AOnLoggingOutgoingJSONRPCRequest: TOnLogOutgoingJSONRPCRequest = nil;
  const AOnLoggingIncomingJSONRPCResponse: TOnLogIncomingJSONRPCResponse = nil
): IPolkadotJSONRPC;
begin
  RegisterJSONRPCWrapper(TypeInfo(IPolkadotJSONRPC));
  var LJSONRPCWrapper := TJSONRPCHTTPClient.Create;
  LJSONRPCWrapper.OnBeforeInitializeHeaders := procedure(var VNetHeaders: TNetHeaders)
  begin
    VNetHeaders := VNetHeaders + [TNameValuePair.Create(SHeadersContentType, SApplicationJson)];
  end;
  LJSONRPCWrapper.OnLogOutgoingJSONRPCRequest := AOnLoggingOutgoingJSONRPCRequest;
  LJSONRPCWrapper.OnLogIncomingJSONRPCResponse := AOnLoggingIncomingJSONRPCResponse;
  LJSONRPCWrapper.PassParamsByPos := True;
  LJSONRPCWrapper.PassEnumByName := True;
  LJSONRPCWrapper.ServerURL := AServerURL;
  Result := LJSONRPCWrapper as IPolkadotJSONRPC;
end;

function GetPolkadotJSON(const AServerURL: string = '';
  const APIKey: string = '';
  const AOnLoggingOutgoingJSONRPCRequest: TOnLogOutgoingJSONRPCRequest = nil;
  const AOnLoggingIncomingJSONRPCResponse: TOnLogIncomingJSONRPCResponse = nil
): IPolkadotJSON;
begin
  RegisterJSONRPCWrapper(TypeInfo(IPolkadotJSON));
  var LJSONRPCWrapper := TJSONRPCHTTPClient.Create;
  LJSONRPCWrapper.OnBeforeInitializeHeaders := procedure(var VNetHeaders: TNetHeaders)
  begin
    var LOriginHost := 'https://staking.polkadot.network';
    VNetHeaders := VNetHeaders +
      [TNameValuePair.Create(SHeadersContentType, SApplicationJson)] +
      [TNameValuePair.Create(SHeadersOrigin, LOriginHost)] +
      [TNameValuePair.Create(SHeadersHost,   LOriginHost)] +
      [TNameValuePair.Create(SHeadersDNT, SHeadersOne)] +
      [TNameValuePair.Create(SHeadersSecFetchDest, SHeadersEmpty)] +
      [TNameValuePair.Create(SHeadersSecFetchMode, SHeadersCORS)] +
      [TNameValuePair.Create(SHeadersSecFetchSite, SHeadersCrossSite)] +
      [TNameValuePair.Create(SHeadersSecGPC, SHeadersOne)] +
      [TNameValuePair.Create(SHeadersTE, SHeadersTETrailers)] +
      [TNameValuePair.Create(SHeadersXAPIKey, APIKey)];
  end;
  LJSONRPCWrapper.OnLogOutgoingJSONRPCRequest := AOnLoggingOutgoingJSONRPCRequest;
  LJSONRPCWrapper.OnLogIncomingJSONRPCResponse := AOnLoggingIncomingJSONRPCResponse;
  LJSONRPCWrapper.PassParamsByName := True;
  LJSONRPCWrapper.PassEnumByName := True;
  LJSONRPCWrapper.ServerURL := AServerURL;
  Result := LJSONRPCWrapper as IPolkadotJSON;
end;

initialization
  InvokableRegistry.RegisterInterface(TypeInfo(IPolkadotJSONRPC));
end.
