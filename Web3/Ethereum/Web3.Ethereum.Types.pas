unit Web3.Ethereum.Types;

interface

uses
  System.SysUtils, System.JSON.Serializers, System.TypInfo, System.JSON.Readers,
  System.JSON.Writers, System.Rtti;

type

  {$SCOPEDENUMS ON}
  TBlockNumber = (earliest, latest, safe, finalized, pending);

  Web3Address = string;
  Hash = string;
  NonceType = string;
  HexNumber = string;
  BloomFilter = string;
  log = string;

  TEthSyncingConverter = class(TJsonConverter)
  public
    function CanConvert(ATypeInf: PTypeInfo): Boolean; override;
    function ReadJson(const AReader: TJsonReader; ATypeInf: PTypeInfo;
    const AExistingValue: TValue; const ASerializer: TJsonSerializer): TValue; override;
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;
  end;

  TransactionReceiptObjectConverter = class(TJsonConverter)
  end;

  [JsonConverter(TEthSyncingConverter)]
  TEthSyncing = record
    Syncing: Boolean;
    startingBlock: HexNumber; currentBlock: HexNumber; highestBlock: HexNumber;
  end;

  TransactionObject = record
    from: Web3Address;
    &to: Web3Address;
    gas: HexNumber;
    gasPrice: HexNumber;
    value: HexNumber;
    data: Hash;
    nonce: HexNumber;
    &type: HexNumber;
  end;
  PTransactionObject = ^TransactionObject;
  [JsonConverter(TransactionReceiptObjectConverter)]
  TransactionReceiptObject = record
    transactionHash: Hash;
    transactionIndex: HexNumber;
    blockHash: Hash;
    blockNumber: HexNumber;
    from: Web3Address;
    &to: Web3Address;
    cumulativeGasUsed: HexNumber;
    effectiveGasPrice: HexNumber;
    gasUsed: HexNumber;
    contractAddress: Web3Address;
    logs: TArray<log>;
    logsBloom: BloomFilter;
  end;

  Withdrawal = record
    index: HexNumber;
    validatorIndex: HexNumber;
    address: Web3Address;
    amount: HexNumber;
  end;

  getBlockByHashReturn = record
    baseFeePerGas: HexNumber;
    mixHash: HexNumber;
    number: HexNumber;
    hash: Hash;
    parentHash: Hash;
    nonce: NonceType;
    sha3Uncles: Hash;
    logsBloom: BloomFilter;
    transactionsRoot: HexNumber;
    stateRoot: HexNumber;
    receiptsRoot: HexNumber;
    miner: Web3Address;
    difficulty: HexNumber;
    totalDifficulty: HexNumber;
    extraData: HexNumber;
    size: HexNumber;
    gasLimit: HexNumber;
    gasUsed: HexNumber;
    timestamp: HexNumber;
    transactions: TArray<HexNumber>;
    uncles: TArray<HexNumber>;
    withdrawals: TArray<Withdrawal>;
    withdrawalsRoot: HexNumber;
  end;

  HexBytes = string;
  HexBytesHelper = record helper for HexBytes
    class operator Implicit(const ABytes: TBytes): HexBytes;
  end;

implementation

uses
  System.JSON.Types;

{ HexBytesHelper }

class operator HexBytesHelper.Implicit(const ABytes: TBytes): HexBytes;
var
  LSB: TStringBuilder;
begin
  LSB := TStringBuilder.Create;
  try
    for var AByte in ABytes do
      begin

      end;
  finally

    LSB.Free;
  end;
end;

{ TEthSyncingConverter }

function TEthSyncingConverter.CanConvert(ATypeInf: PTypeInfo): Boolean;
begin
  Result := True;
end;

function TEthSyncingConverter.ReadJson(const AReader: TJsonReader;
  ATypeInf: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
var
  LJSONText: string;
  LEthSyncing: TEthSyncing;
  Index: Integer;
begin
  LEthSyncing := Default(TEthSyncing);
  Index := 0;
  var LTokenType := AReader.TokenType;
  var Done := False;
  repeat
    Done := AReader.Read;
    var LValue := AReader.Value;
    case LTokenType of
      TJsonToken.Boolean: LEthSyncing.Syncing := LValue.AsBoolean;
    end;
  until AReader.CurrentState = TJsonReader.TState.Finished;
  Result := TValue.From(LEthSyncing);
end;

procedure TEthSyncingConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
begin
  inherited;

end;

end.
