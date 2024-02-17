﻿
unit JSONRPC.Web3.PolkadotAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Web3.Common.Types, JSONRPC.Common.Types,
  System.SysUtils, System.JSON, Velthuis.BigIntegers,
  JSONRPC.Web3.Polkadot.Types;

type

  HexBytes = BigInteger;
  TBlockHash = string;
  THash = string;
  StorageKey = string;

  TMethods = record
    methods: TArray<string>;
  end;

  IPolkadotJSONRPC = interface(IJSONRPCMethods)
    ['{B21C77FA-2E80-43CC-8689-F7A6A94FB918}']

    function system_health: TSystemHealth; safecall;

    /// <summary>
    /// Gets the block hash for the given block number
    /// <param name="blockNumber">Block number to get hash for </param>
    /// </summary>
    function chain_getBlockHash(blockNumber: Integer): TBlockHash; safecall;
    function getFinalizedHead: TBlockHash; safecall;
    /// <summary> List supported methods </summary>
    function rpc_methods: TMethods; safecall;

    function state_getStorage(const key: StorageKey; const at: TBlockHash): TBlockHash; safecall;
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
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil
): IPolkadotJSONRPC;


implementation

uses
  JSONRPC.InvokeRegistry, JSONRPC.Common.Consts;

function GetPolkadotJSONRPC(const AServerURL: string = '';
  const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil;
  const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil
): IPolkadotJSONRPC;
begin
  RegisterJSONRPCWrapper(TypeInfo(IPolkadotJSONRPC));
  var LJSONRPCWrapper := TJSONRPCWrapper.Create(nil);
  LJSONRPCWrapper.OnBeforeInitializeHeaders := procedure(var VNetHeaders: TNetHeaders)
  begin
    VNetHeaders := VNetHeaders + [TNameValuePair.Create(SHeadersContentType, SApplicationJson)];
  end;
  LJSONRPCWrapper.OnLogOutgoingJSONRequest := AOnLoggingOutgoingJSONRequest;
  LJSONRPCWrapper.OnLogIncomingJSONResponse := AOnLoggingIncomingJSONResponse;
  LJSONRPCWrapper.PassParamsByPos := True;
  LJSONRPCWrapper.ServerURL := AServerURL;
  Result := LJSONRPCWrapper as IPolkadotJSONRPC;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IPolkadotJSONRPC));
end.