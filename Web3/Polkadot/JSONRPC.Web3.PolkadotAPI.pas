
unit JSONRPC.Web3.PolkadotAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Web3.Common.Types, JSONRPC.Common.Types,
  System.SysUtils, System.JSON, Velthuis.BigIntegers,
  // for TBigIntegerConverter
  System.Rtti, System.TypInfo, System.JSON.Readers,
  JSONRPC.Web3.Polkadot.Types, System.JSON.Serializers;

type

  HexBytes = BigInteger;
  TBlockHash = string;
  THash = string;
  StorageKey = string;

  TMethods = record
    methods: TArray<string>;
  end;

// {"startingBlock":19480132,"currentBlock":19523851,"highestBlock":19523851},"id":6}
  TSyncState = record
    startingBlock: Integer;
    currentBlock: Integer;
    highestBlock: Integer;
  end;

  // https://spec.polkadot.network/chap-runtime-api
  TStateCallType = (
    NominationPoolsApi_pending_rewards, // args = account id
    NominationPoolsApi_points_to_balance,
    NominationPoolsApi_balance_to_points
  );

  TBigIntegerConverter = class(TJsonConverter)
  public
    function CanConvert(ATypeInfo: PTypeInfo): Boolean; override;
    function CanRead: Boolean; override;
    function ReadJson(const AReader: TJsonReader; ATypeInfo: PTypeInfo; const AExistingValue: TValue;
      const ASerializer: TJsonSerializer): TValue; override;
  end;

  TAPIs = TArray<TArray<BigInteger>>;

  TRuntimeVersion = record
    specName: string;
    implName: string;
    authoringVersion: Integer;
    specVersion: Integer;
    implVersion: Integer;
    [JsonConverter(TBigIntegerConverter)]
    apis: TAPIs;
    transactionVersion: Integer;
    stateVersion: Integer;
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

    function author_pendingExtrinsics: TArray<string>; // tested

    function author_removeExtrinsic(const bytesOrHash: TArray<THash>): TArray<THash>; deprecated 'unsafe to call externally';
    function author_hasSessionKeys(const sessionKeys: THash): Boolean; // tested without session key

    /// <summary> List supported methods </summary>
    /// <returns> A record with the field methods containing an array
    /// of method names </returns>
    function rpc_methods: TMethods; safecall; // tested

    function state_getStorage(const key: StorageKey; const at: TBlockHash): TBlockHash; safecall;

    function state_getRuntimeVersion: TRuntimeVersion;

    function state_getMetadata: BigInteger;

    // <summary> Gets the sync state of the node </summary>
    function system_syncState: TSyncState; safecall;

    /// <summary> Retrieves version of the node </summary>
    function system_version: string; safecall;

    function system_reservedPeers: TArray<string>; safecall;
    function system_localPeerId: string; safecall;
    /// <summary> Retrieves the node name </summary>
    function system_name: string; safecall;

    // {"id":64,"jsonrpc":"2.0","method":"state_unsubscribeStorage","params":["dODgWqzCtM17x25r"]}
    function state_unsubscribeStorage(const AStorageKey: StorageKey): Boolean;

    // {"id":261,"jsonrpc":"2.0","method":"state_subscribeStorage",
    //  "params":[["0x7a6d38deaa01cb6e76ee69889f1696271f7c4e57dc49e4d6d003b730a7894f32858f760905c8df5ddc000000","0x7a6d38deaa01cb6e76ee69889f169627fa0883f96ad25255581bef5ba72b8750858f760905c8df5ddc000000","0x26aa394eea5630e07c48ae0c9558cef7b99d880ec681799c0cf30e8886371da9e7f05a1c3ad501c866254c88a1957b596d6f646c70792f6e6f706c7301dc000000000000000000000000000000000000","0x5f3e4907f716ac89b6347d15ececedca9c6a637f62ae2af1c7e31eed7e96be04772b99779fb18abb6d6f646c70792f6e6f706c7300dc000000000000000000000000000000000000"]]}
    function state_subscribeStorage(const AStorageKeys: TArray<StorageKey>): StorageKey;

    // {"id":266,"jsonrpc":"2.0","method":"state_call",
    // "params":["NominationPoolsApi_pending_rewards","0x5626fb92ce5aacc7ac4dd042dd55308832ba8dde38c557b140ae8740948fe76c"]}
    // {"id":108,"jsonrpc":"2.0","method":"state_call","params":["NominationPoolsApi_points_to_balance","0xdc000000b9b48ac2020000000000000000000000"]}
    function state_call(const ACallType: TStateCallType; const ABlockHash: TBlockHash): THash;

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
  JSONRPC.InvokeRegistry, JSONRPC.Common.Consts, System.JSON.Types;

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
  LJSONRPCWrapper.PassEnumByName := True;
  LJSONRPCWrapper.ServerURL := AServerURL;
  Result := LJSONRPCWrapper as IPolkadotJSONRPC;
end;

{ TBigIntegerConverter }

function TBigIntegerConverter.CanConvert(ATypeInfo: PTypeInfo): Boolean;
begin
  Result := ATypeInfo = TypeInfo(TAPIs);
end;

function TBigIntegerConverter.CanRead: Boolean;
begin
  Result := True;
end;

function TBigIntegerConverter.ReadJson(const AReader: TJsonReader;
  ATypeInfo: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
type
  TMember = TArray<BigInteger>;
  TContainer = TArray<TMember>;
var
  V1: BigInteger;
  V2: BigInteger;
  LArray: TContainer;
  LMember: TMember;
  InArray: Integer;
begin
  Assert(AReader.CurrentState = TJsonReader.TState.ArrayStart, '');
  InArray := 0;
  // AReader.TokenType = StartArray
  while AReader.TokenType in [TJsonToken.StartArray, TJsonToken.EndArray,
    TJsonToken.String, TJsonToken.Float] do
    begin
      AReader.Read;
      case AReader.TokenType of
        TJsonToken.StartArray: Inc(InArray);
        TJsonToken.EndArray: begin
          if InArray = 0 then
            begin
              Result := TValue.From(LArray);
              Break;
            end else Dec(InArray);
        end;
        TJsonToken.String: V1 := BigInteger.Create(AReader.Value.AsString);
        TJsonToken.Float: begin
          V2 := BigInteger.Create(AReader.Value.AsExtended);
          LMember := [V1, V2];
          LArray := LArray + [LMember];
        end;
      end;
    end;

//  LState := AReader.CurrentState; // ArrayStart
//  AReader.Read;
//
//  V1 := AReader.Value.AsString; // AReader.TokenType = String
//  LState := AReader.CurrentState; // PostValue
//  AReader.Read;
//  V2 := AReader.Value.AsExtended; // AReader.TokenType = Float
//
//  LState := AReader.CurrentState; // PostValue
//  AReader.Read;
//  LState := AReader.CurrentState; // AReader.TokenType = EndArray
//  AReader.Read;
//  LState := AReader.CurrentState;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IPolkadotJSONRPC));
end.
