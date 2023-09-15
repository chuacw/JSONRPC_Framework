unit Web3.Ethereum.Types;

interface

uses
  System.SysUtils, System.JSON.Serializers, System.TypInfo, System.JSON.Readers,
  System.JSON.Writers, System.Rtti, Velthuis.BigIntegers;

type

  {$SCOPEDENUMS ON}
  TBlockNumber = (earliest, latest, safe, finalized, pending);

  Web3Address = BigInteger;
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

implementation

uses
  System.JSON, JSONRPC.Common.Types, JSONRPC.Common.RecordHandlers,
  System.JSON.Types, JSONRPC.JsonUtils, JSONRPC.Common.Consts;

{ TEthSyncingConverter }

function TEthSyncingConverter.CanConvert(ATypeInf: PTypeInfo): Boolean;
begin
  Result := True;
end;

function TEthSyncingConverter.ReadJson(const AReader: TJsonReader;
  ATypeInf: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
var
//  LJSONText: string;
  LEthSyncing: TEthSyncing;
begin
  LEthSyncing := Default(TEthSyncing);
  var LTokenType := AReader.TokenType;
  repeat
    AReader.Read;
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

initialization
  RegisterRecordHandler(TypeInfo(BigInteger),
    procedure(
      const APassParamByPosOrName: TPassParamByPosOrName;
      const AParamName: string;
      const AParamValuePtr: Pointer;
      const AParamsObj: TJSONObject;
      const AParamsArray: TJSONArray
    )
    // NativeToJSON
    var
      LJSON: TJSONString;
    begin
      BigInteger.Hex;
      LJSON := TJSONString.Create('0x'+BigInteger(AParamValuePtr^).ToString(16));
      case APassParamByPosOrName of
        tppByName: AParamsObj.AddPair(AParamName, LJSON);
        tppByPos:  AParamsArray.AddElement(LJSON);
      end;
    end,
    procedure(const AJSONResponseObj: TJSONValue; const APathName: string; AResultP: Pointer)
    // JSONToNative
    var
      LDecimalPlaces: Integer;
    begin
      var LResultValue: string;
      AJSONResponseObj.TryGetValue<string>(APathName, LResultValue);
      if LResultValue.StartsWith('0x', True) then
        begin
          LResultValue := Copy(LResultValue, Low(LResultValue) + 2);
          LDecimalPlaces := 16;
        end else
        begin
          LDecimalPlaces := 10;
        end;
      BigInteger.TryParse(LResultValue, LDecimalPlaces, PBigInteger(AResultP)^);
    end,
    procedure(const AValue: TValue; ATypeInfo: PTypeInfo; const AJSONObject: TJSONObject)
    // TValueToJSON
    var
      LBigInteger: BigInteger;
      LJSON: string;
    begin
      // LResult is a TValue from BigDecimal
      ValueToObj(AValue, ATypeInfo, LBigInteger);
      LJSON := LBigInteger.ToString;
      AJSONObject.AddPair(SRESULT, LJSON);
    end,
    function(const AJSONRequestObj: TJSONObject; const AParamName: string): TValue
    // JSONToTValue
    var
      LParamValue: string;
      LBigInteger: BigInteger;
    begin
      AJSONRequestObj.TryGetValue<string>(AParamName, LParamValue);
      if LParamValue.StartsWith('0x', True) then
        LParamValue := Copy(LParamValue, Low(LParamValue) + 2);
      BigInteger.TryParse(LParamValue, 16, LBigInteger);
      Result := TValue.From(LBigInteger);
    end
  );
end.
