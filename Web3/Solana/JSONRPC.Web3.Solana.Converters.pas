unit JSONRPC.Web3.Solana.Converters;

interface

uses
  System.JSON.Converters, System.TypInfo, System.JSON.Readers,
  System.JSON.Serializers, System.Rtti, System.JSON.Writers,
  System.Messaging, JSONRPC.Web3.Solana.Encoding;

type

  TEncodingEnumConverter = class(TJsonEnumNameConverter)
  protected
    class var FMsgId: TMessageSubscriptionId;
    class var FEnumNames: array[JSONRPC.Web3.Solana.Encoding.TEncoding] of string;
    class constructor Create;
    class destructor Destroy;
  public
    function CanConvert(ATypeInfo: PTypeInfo): Boolean; override;
    function ReadJson(const AReader: TJsonReader; ATypeInf: PTypeInfo;
      const AExistingValue: TValue;
      const ASerializer: TJsonSerializer): TValue; override;
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;
  end;

implementation

{ TEncodingEnumConverter }

uses
  System.SysUtils, JSONRPC.Web3.Solana.Attributes,
  JSONRPC.Common.Types;

function TEncodingEnumConverter.CanConvert(ATypeInfo: PTypeInfo): Boolean;
begin
  Result := (ATypeInfo^.Kind = tkEnumeration);
end;

class constructor TEncodingEnumConverter.Create;
var
  I: JSONRPC.Web3.Solana.Encoding.TEncoding;
//  LNames: array[JSONRPC.Web3.Solana.Attributes.TEncoding] of string;
  LTypeInfo: PTypeInfo;
  LType: TRttiType;
//  LOrdValue: Integer;
  LCtx: TRttiContext;
  LAttributes: TArray<TCustomAttribute>;
  LCustomAttr: TCustomAttribute;
  LEnumAsAttr: EnumAsAttribute;
//  LReadName: string;
begin
//  FMsgId := TMessageManager.DefaultManager.SubscribeToMessage(
//    TJsonConverterRegisterMessage,
//    procedure(const Sender: TObject; const AMsg: TMessage)
//    var
//      LMsg: TJsonConverterRegisterMessage absolute AMsg;
//    begin
//      LMsg.Converters.Add(TEncodingEnumConverter.Create);
//    end
//  );
  for I := Low(JSONRPC.Web3.Solana.Encoding.TEncoding) to
    High(JSONRPC.Web3.Solana.Encoding.TEncoding) do
    begin
      FEnumNames[I] := GetEnumName(TypeInfo(JSONRPC.Web3.Solana.Encoding.TEncoding), Ord(I));
    end;

  LTypeInfo := TypeInfo(JSONRPC.Web3.Solana.Encoding.TEncoding);
  LType := LCtx.GetType(LTypeInfo);
  LAttributes := LType.GetAttributes;

//  LOrdValue := -1;
  for LCustomAttr in LAttributes do
    begin
      if LCustomAttr is EnumAsAttribute then
        LEnumAsAttr := EnumAsAttribute(LCustomAttr) else
        LEnumAsAttr := nil;
      if Assigned(LEnumAsAttr) then
        begin
          FEnumNames[JSONRPC.Web3.Solana.Encoding.TEncoding(LEnumAsAttr.Index)] := LEnumAsAttr.EnumName;
        end;
    end;
end;

class destructor TEncodingEnumConverter.Destroy;
begin
//  TMessageManager.DefaultManager.Unsubscribe(TJsonConverterRegisterMessage, FMsgId);
end;

function TEncodingEnumConverter.ReadJson(const AReader: TJsonReader;
  ATypeInf: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
var
  LReadName: string;
  LOrdValue: JSONRPC.Web3.Solana.Encoding.TEncoding;
//  LCtx: TRttiContext;
//  LEnumName: string;
//  LTypeInfo: PTypeInfo;
//  LType: TRttiType;
//  LAttributes: TArray<TCustomAttribute>;
//  LCustomAttr: TCustomAttribute;
//  LEnumAsAttr: EnumAsAttribute;
begin
  AReader.Read; // PropertyName = 'encoding'
  AReader.Read; // PropertyName = 'encoding'
  LReadName := AReader.Value.AsString;

  for LOrdValue := Low(JSONRPC.Web3.Solana.Encoding.TEncoding) to High(JSONRPC.Web3.Solana.Encoding.TEncoding) do
    begin
      if SameText(FEnumNames[JSONRPC.Web3.Solana.Encoding.TEncoding(LOrdValue)], LReadName) then
        Break;
    end;
  Result := TValue.From(LOrdValue);

  AReader.Read; // EndObject
end;

procedure TEncodingEnumConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
var
//  LCtx: TRttiContext;
//  LTypeInfo: PTypeInfo;
//  LType: TRttiType;
//  LCustomAttr: TCustomAttribute;
//  LEnumAsAttr: EnumAsAttribute;
//  LAttributes: TArray<TCustomAttribute>;
  LOrdValue: JSONRPC.Web3.Solana.Encoding.TEncoding;
  LEnumName: string;
begin
  AWriter.WriteStartObject;
  AWriter.WritePropertyName('encoding');

  LOrdValue := JSONRPC.Web3.Solana.Encoding.TEncoding(AValue.AsOrdinal);
  LEnumName := FEnumNames[LOrdValue];

  AWriter.WriteValue(LEnumName);
  AWriter.WriteEndObject;
end;

end.
