﻿program JSONRPC.PolkadotClient;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Math,
  Vcl.Clipbrd, Velthuis.BigIntegers,
  JSONRPC.RIO in '..\..\Common\JSONRPC.RIO.pas',
  JSONRPC.Common.Types in '..\..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.InvokeRegistry in '..\..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.Common.Consts in '..\..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.JsonUtils in '..\..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.Common.RecordHandlers in '..\..\Common\JSONRPC.Common.RecordHandlers.pas',
  JSONRPC.Web3.Common.Types in '..\JSONRPC.Web3.Common.Types.pas',
  JSONRPC.TransportWrapper.HTTP in '..\..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  JSONRPC.Web3.Polkadot.Types in 'JSONRPC.Web3.Polkadot.Types.pas',
  JSONRPC.Web3.PolkadotAPI in 'JSONRPC.Web3.PolkadotAPI.pas';

const
  Base58Alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

function Base58Encode(const input: string): string; experimental
var
  dividend, remainder: UInt64;
  quotient: Integer;
  i: Integer;
  res: string;
begin
  dividend := StrToInt64Def(input, 0);
  res := '';
  while dividend > 0 do
  begin

    quotient := dividend div 58;
    remainder := dividend mod 58;
    res := Base58Alphabet[remainder + 1] + res;
    dividend := quotient;
  end;
  Result := res;
end;

function Base58Decode(const input: string): string; experimental
var
  i, j: Integer;
  c: Char;
  res: BigInteger;
begin
  res := 0;
  for i := 1 to Length(input) do
  begin
    c := input[i];
    j := Pos(c, Base58Alphabet) - 1;
    if j = -1 then
      Exit('');
    res := res * 58 + UInt64(j);
  end;
  Result := res.ToString;
end;

function GetPolkadotClient: IPolkadotJSONRPC;
begin
  Result := GetPolkadotJSONRPC('https://apps-rpc.polkadot.io/',
    procedure(const AJSONRPCRequest: string)
    begin
      WriteLn('--- Outgoing JSON request ---');
      WriteLn(AJSONRPCRequest);
    end,
    procedure(const AJSONRPCResponse: string)
    begin
      WriteLn('--- Incoming JSON response ---');
      Clipboard.AsText := AJSONRPCResponse;
      WriteLn(AJSONRPCResponse);
      WriteLn;
    end
  );
  AssignJSONRPCSafeCallExceptionHandler(Result,
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

procedure TestPolkadotClient;
begin
  try
    var LPolkadotClient := GetPolkadotClient;

    // https://t.me/substratedevs/10356
    var lBlockHash := LPolkadotClient.chain_getBlockHash(0);
    var lGetBlockHash := LPolkadotClient.chain_getBlock(lBlockHash);

    var lLocalPeerId := LPolkadotClient.system_localPeerId;
    var base58Decoded := Base58Decode(lLocalPeerId);
    var LSyncStateGenSpec := LPolkadotClient.sync_state_genSyncSpec;

    var lPendingExtrinsics := LPolkadotClient.author_pendingExtrinsics;
//    // var LRemoveExtrinsicResult := LPolkadotClient.author_removeExtrinsic([]);
//
//    var LGrandpaRoundState := LPolkadotClient.grandpa_roundState;
    var LBlockNumber := LPolkadotClient.chain_getBlock;
    var LHeader := LPolkadotClient.chain_getHeader;
    LBlockHash := LPolkadotClient.chain_getBlockHash(50, $64, 200);
    LBlockHash := LPolkadotClient.chain_getBlockHash(19518865);
    var LGrandpaProveFinality := LPolkadotClient.grandpa_proveFinality(
      (LBlockNumber.block.header.number-10).AsInteger
    );

    var LMetadata := LPolkadotClient.state_getMetadata;
    // var lFinalizedHead := LPolkadotClient.getFinalizedHead; // not available?

    var LAccountNonce := LPolkadotClient.system_accountNextIndex('FJaSzBUAJ1Nwa1u5TbKAFZG5MBtcUouTixdP7hAkmce2SDS');
    var LSystemChain := LPolkadotClient.system_chain;
    var LSystemChainType := LPolkadotClient.system_chainType;
    var LAddresses := LPolkadotClient.system_localListenAddresses;
    var LNodeRoles := LPolkadotClient.system_nodeRoles;
    var LSystemProperties := LPolkadotClient.system_properties;
    var LSystemHealth := LPolkadotClient.system_health;
    Assert(LBlockHash = '0x66722d90a8fec09cb410fed0292b397d5d3cbd1bca376b1fd0c1bb8caee3e6d4');
    WriteLn(LBlockHash.ToString);

    var LMethods := LPolkadotClient.rpc_methods;
    var LKey: StorageKey := '0x26aa394eea5630e07c48ae0c9558cef7f9cce9c888469bb1a0dceaa129672ef8';
    var LAt: TBlockHash := '0x841a21ab1aa402aca5185e1b9d72f85e181de28e8f68e279c4f7a25f06e63d23';

    LBlockHash := LPolkadotClient.state_getStorage(LKey, LAt);

    var LVersion := LPolkadotClient.system_version;
    WriteLn(LVersion);

    var lSyncState := LPolkadotClient.system_syncState;
    var lReservedPeers := LPolkadotClient.system_reservedPeers;
    lLocalPeerId := LPolkadotClient.system_localPeerId;
    var lNodeName := LPolkadotClient.system_name;

    var lStateRuntimeVersion := LPolkadotClient.state_getRuntimeVersion;
    var LPendingRewards := LPolkadotClient.state_call(NominationPoolsApi_pending_rewards, '0x5626fb92ce5aacc7ac4dd042dd55308832ba8dde38c557b140ae8740948fe76c');
    var LBalance := LPolkadotClient.state_call(NominationPoolsApi_points_to_balance, '0xdc000000b9b48ac2020000000000000000000000');
    var LPoints := LPolkadotClient.state_call(NominationPoolsApi_balance_to_points, '0xdc000000b9b48ac2020000000000000000000000');
    WriteLn;
    WriteLn('SUCCESS! There''s no implementation error!');
  except
    WriteLn;
    WriteLn('Investigate the implementation error!');
  end;
end;

begin
  TestPolkadotClient;
  WriteLn;
  Write('Press enter to quit.');
  ReadLn;
end.
