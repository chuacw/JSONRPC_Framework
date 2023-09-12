unit Web3.Serializers;

interface

uses
  System.JSON.Serializers, System.JSON.Readers, System.TypInfo, System.Rtti;

type
  TWeb3JsonSerializer = class(TJsonSerializer)
  public
    constructor Create; reintroduce;
    function InternalDeserialize(const AReader: TJsonReader; ATypeInfo: PTypeInfo): TValue; override;
  end;

  TWeb3JsonSerializerHelper = class helper for TWeb3JsonSerializer
  end;

implementation

uses
  Web3.Common.Types, Web3.Ethereum.Types, System.JSON.Writers,
  System.JSON.Types;

type

  TWeb3ContractResolver = class(TJsonDefaultContractResolver)
  protected
    procedure InitializeContract(const AJsonContract: TJsonContract; const ARttiType: TRttiType); override;
    function CreateContract(ATypeInfo: PTypeInfo): TJsonContract; override;
  end;

  TTransactionReceiptObjectConverter = class(TJsonConverter)
  public
    function CanConvert(ATypeInfo: PTypeInfo): Boolean; override;
    function ReadJson(const AReader: TJsonReader; ATypeInfo: PTypeInfo;
      const AExistingValue: TValue; const ASerializer: TJsonSerializer): TValue; override;
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;
  end;

  THexNumberJsonContract = class(TJsonPrimitiveContract)
  public
    constructor Create(ATypeInfo: PTypeInfo);
  end;

  TWeb3AddressJsonContract = class(TJsonPrimitiveContract)
  public
    constructor Create(ATypeInfo: PTypeInfo);
  end;

{ TWeb3JsonSerializer }

constructor TWeb3JsonSerializer.Create;
begin
  inherited Create;
  ContractResolver := TWeb3ContractResolver.Create;
end;

function TWeb3JsonSerializer.InternalDeserialize(const AReader: TJsonReader;
  ATypeInfo: PTypeInfo): TValue;
//var
//  LSerializerReader: TJsonSerializerReader;
begin
//  LSerializerReader := TJsonSerializerReader.Create(Self);
//  try
//    Result := LSerializerReader.DeSerialize(AReader, ATypeInf);
//  finally
//    LSerializerReader.Free;
//  end;
  inherited;
end;

{ TWeb3ContractResolver }

function TWeb3ContractResolver.CreateContract(
  ATypeInfo: PTypeInfo): TJsonContract;
begin
  if ATypeInfo = TypeInfo(HexNumber) then
    Result := THexNumberJsonContract.Create(ATypeInfo) else
  if ATypeInfo = TypeInfo(Web3Address) then
    Result := TWeb3AddressJsonContract.Create(ATypeInfo) else
    Result := inherited;
end;

procedure TWeb3ContractResolver.InitializeContract(
  const AJsonContract: TJsonContract; const ARttiType: TRttiType);
begin
  inherited;
end;

{ THexNumberJsonContract }

constructor THexNumberJsonContract.Create(ATypeInfo: PTypeInfo);
begin
  inherited Create(ATypeInfo, TJsonPrimitiveKind.String);
end;

{ TWeb3AddressJsonContract }

constructor TWeb3AddressJsonContract.Create(ATypeInfo: PTypeInfo);
begin
  inherited Create(ATypeInfo, TJsonPrimitiveKind.String);
end;

{ TTransactionReceiptObjectConverter }

function TTransactionReceiptObjectConverter.CanConvert(
  ATypeInfo: PTypeInfo): Boolean;
begin
  Result := ATypeInfo = TypeInfo(TransactionReceiptObject);
end;

function TTransactionReceiptObjectConverter.ReadJson(const AReader: TJsonReader;
  ATypeInfo: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
begin
  if AReader.TokenType = TJsonToken.Null then
    ;
end;

procedure TTransactionReceiptObjectConverter.WriteJson(
  const AWriter: TJsonWriter; const AValue: TValue;
  const ASerializer: TJsonSerializer);
begin
  inherited;
end;

end.