unit JSONRPC.Web3.Ethereum.Converters;

interface

uses
  JSONRPC.Common.Converters, System.TypInfo, System.JSON.Readers,
  System.Rtti, System.JSON.Writers, System.JSON.Serializers;

type
(*

Response when not syncing (fully synced):
false

Response when syncing:
{
  "startingBlock": "0x1234",  // Starting block of the sync
  "currentBlock": "0x5678",   // Current block processed by the node
  "highestBlock": "0x9abc"    // Latest block in the blockchain
}

*)
  TJSONFalseBlockInfoConverter = class(TBaseJsonConverter)
  public
    function CanConvert(ATypeInfo: PTypeInfo): Boolean; override;

    function ReadJson(const AReader: TJsonReader; ATypeInf: PTypeInfo;
    const AExistingValue: TValue; const ASerializer: TJsonSerializer): TValue; override;

    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;
  end;

implementation

uses
  JSONRPC.Web3.EthereumAPI, System.JSON.Types, System.SysUtils;

{ TJSONFalseBlockInfoConverter }

function TJSONFalseBlockInfoConverter.CanConvert(ATypeInfo: PTypeInfo): Boolean;
begin
  Result := ATypeInfo = TypeInfo(TJSONFalseBlockInfo);
end;

function TJSONFalseBlockInfoConverter.ReadJson(const AReader: TJsonReader;
  ATypeInf: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
var
  LEmpty: TJSONFalseBlockInfo;
  LTokenType: TJsonToken;
begin
  LTokenType := AReader.TokenType;
  case LTokenType of
    TJsonToken.Boolean: begin
      // Result := TValue.From(LEmpty);
    end;
    TJsonToken.StartObject: begin
      var LObjTokenType: Boolean;
      repeat
        LObjTokenType := AReader.Read;
        LTokenType := AReader.TokenType;
        if (LTokenType = TJsonToken.EndObject) or (not LObjTokenType) then
          Break;
        var LPropertyName: string := AReader.Value.AsString;
        AReader.Read;
        var LValue: string := AReader.Value.AsString;
        var LTempValue: UInt64 := 0; TryStrToUInt64(LValue, LTempValue);
        if SameText(LPropertyName, 'startingBlock') then
          LEmpty.startingBlock := LTempValue else
        if SameText(LPropertyName, 'currentBlock') then
          LEmpty.currentBlock := LTempValue else
        if SameText(LPropertyName, 'highestBlock') then
          LEmpty.highestBlock := LTempValue;
      until False;
    end;
  end;
  Result := TValue.From(LEmpty);
end;

procedure TJSONFalseBlockInfoConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
begin

end;

end.
