// This unit is autogenerated. Do not edit it manually.
// Source: JSON entered in editor
// Date: 28/9/2023 5:08:55 PM

unit JSONRPC.Web3.SolanaTypes;

interface

uses
  System.JSON.Serializers, System.Generics.Collections, System.JSON.Converters,
  JSONRPC.Web3.Solana.CustomConverters, JSONRPC.Web3.Solana.Attributes;

type

  TByIdentity = TDictionary<string, TArray<Integer>>;
  /// <summary> This needs to be in a separate type section as generics
  /// have issues with attributes if they're not in a separate section
  /// </summary>
  TByIdentityConverter = class(TJsonStringDictionaryConverter<TArray<Integer>>);

type

  [JsonSerialize(TJsonMemberSerialization.Fields)]
  TRange = record
  private
    FfirstSlot: Integer;
    FlastSlot: Integer;
  public
    property firstSlot: Integer read FfirstSlot write FfirstSlot;
    property lastSlot: Integer read FlastSlot write FlastSlot;
  end;

  [JsonSerialize(TJsonMemberSerialization.Fields)]
  TContext = record
  private
    Fslot: Integer;
  public
    property slot: Integer read Fslot write Fslot;
  end;

  [JsonSerialize(TJsonMemberSerialization.Fields)]
  TgetBlockProductionContext = record
  private
    [JsonName('apiVersion')]
    FapiVersion: string;

    [JsonName('slot')]
    Fslot: UInt64;
  public
    property apiVersion: string read FapiVersion write FapiVersion;
    property slot: UInt64 read Fslot write Fslot;
  end;


  [JsonSerialize(TJsonMemberSerialization.Fields)]
  TgetBlockProductionValue = record
  private
    [JsonConverter(TByIdentityConverter), JsonName('byIdentity')]
    FbyIdentity: TByIdentity;

    [JsonName('range')]
    Frange: TRange;
  public
    class operator Assign(var Dest: TgetBlockProductionValue; const [ref] Src: TgetBlockProductionValue);
    class operator Initialize(out Dest: TgetBlockProductionValue);
    class operator Finalize(var Dest: TgetBlockProductionValue);

    property byIdentity: TByIdentity read FbyIdentity write FbyIdentity;
    property range: TRange read Frange write Frange;
  end;

  [JsonSerialize(TJsonMemberSerialization.Fields)]
  TgetBlockProductionResult = record
  private
    Fcontext: TContext;
    Fvalue: TgetBlockProductionValue;
  public
    property context: TContext read Fcontext write Fcontext;
    property value: TgetBlockProductionValue read Fvalue write Fvalue;
  end;

implementation

uses
  System.SysUtils;

{ TgetBlockProductionValue }

class operator TgetBlockProductionValue.Assign(var Dest: TgetBlockProductionValue;
  const [ref] Src: TgetBlockProductionValue);
begin
  var LByIdentity := Dest.FbyIdentity;
  for var LPair in Src.FbyIdentity do
    begin
      LByIdentity.Add(LPair.Key, Copy(LPair.Value));
    end;
end;

class operator TgetBlockProductionValue.Finalize(var Dest: TgetBlockProductionValue);
begin
  FreeAndNil(Dest.FbyIdentity);
end;

class operator TgetBlockProductionValue.Initialize(out Dest: TgetBlockProductionValue);
begin
  Dest.FbyIdentity := TDictionary<string, TArray<Integer>>.Create;
end;

end.
