unit JSONRPC.User.SomeTypes;

{$CODEALIGN 16}

interface

uses
  JSONRPC.Common.Types, System.Classes, System.JSON.Serializers,
  JSONRPC.RIO, Velthuis.BigDecimals, Velthuis.BigIntegers;

{$IF NOT DECLARED(Velthuis.BigDecimals) AND NOT DECLARED(Velthuis.BigIntegers)}
  {$MESSAGE HINT 'Include Velthuis.BigDecimals to automatically enable SendExtended'}
{$ENDIF}

type

  [JsonSerialize(TJsonMemberSerialization.Fields)]
  TAnotherObject = record
  private
    [JsonName('Data')]
    FData: Double;
    [JsonName('SomeString')]
    FSomeString: string;
    [JsonName('Array')]
    FArray: TArray<Integer>;
  public
    constructor Create(const AData: Double; const ASomeString: string);
    property Data: Double read FData write FData;
    property SomeString: string read FSomeString write FSomeString;
    property &Array: TArray<Integer> read FArray write FArray;
  end align 16;

  [JsonSerialize(TJsonMemberSerialization.Fields)]
  TMyObject = record
  private
    [JsonName('Data')]
    FData: string;

    [JsonName('Num')]
    FNum: Integer;

    [JsonName('Date')]
    FDate: TDateTime;

    [JsonName('AnotherObj')]
    FAnotherObj: TAnotherObject;
  public
    constructor Create(const AData: string; ANum: Integer; ADate: TDateTime;
      const AAnotherObj: TAnotherObject);
    property Data: string read FData write FData;
    property Num: Integer read FNum write FNum;
    property Date: TDateTime read FDate write FDate;
    property AnotherObj: TAnotherObject read FAnotherObj write FAnotherObj;
  end align 16;

  TEnum = (enumA, enumB, enumC);
  TFixedIntegers = array[0..3] of Integer;
  ISomeJSONRPC = interface(IJSONRPCMethods)
    ['{BDA67613-BA2E-415A-9C4E-DE5BD519C05E}']

    [JSONNotify]
    procedure ANotifyMethod;

    procedure CallSomeMethod;
    function CallSomeRoutine: Boolean;
    function AddSomeXY(X, Y: Integer): Integer;
    function AddDoubles(A, B: Float64): Float64;
    function GetSomeDate(const ADateTime: TDateTime): TDateTime;
    function GetDate: TDateTime;
    function Combine(const Str1, Str2: string): string;

    function subtract(minuend, subtrahend: NativeInt): NativeInt;
    function AddString(const X, Y: string): string;
    function GetSomeBool(const ABoolean: Boolean): Boolean; safecall;

    function GetEnum(const A: TEnum): TEnum;
    function SendEnum(const A: TEnum): string;

    {$IF DECLARED(Velthuis.BigIntegers)}
    function SendBigInteger(const Value: BigInteger): BigInteger;
    {$ENDIF}
    {$IF DECLARED(Velthuis.BigDecimals)}
    function SendExtended(const Value: BigDecimal): BigDecimal; overload;
    {$ENDIF}

    function SendBool(const Value: Boolean): Boolean;
    function SendByte(const Value: Byte): Byte;
    function SendByteBool(const Value: ByteBool): ByteBool;
    function SendCardinal(const Value: Cardinal): Cardinal;
    function SendCurrency(const Value: Currency): Currency;
    function SendDouble(const Value: Double): Double;

    {$IF DECLARED(Neslib.MultiPrecision)}
    function SendDoubleDouble(const Value: DoubleDouble): DoubleDouble;
    function SendQuadDouble(const Value: QuadDouble): QuadDouble;
    {$ENDIF}

    function SendGUID(const Value: TGUID): TGUID;
    function SendInt64(const Value: Int64): Int64;
    function SendInteger(const Value: Integer): Integer;
    function SendLongWord(const Value: LongWord): LongWord;
    function SendNativeInt(const Value: NativeInt): NativeInt;
    function SendNativeUInt(const Value: NativeUInt): NativeUInt;
    function SendShort(const Value: ShortInt): ShortInt;
    function SendSingle(const Value: Single): Single;
    function SendSmallInt(const Value: SmallInt): SmallInt;
    function SendString(const Value: string): string;
    function SendUInt64(const Value: UInt64): UInt64;
    function SendWord(const Value: Word): Word;
    function SendWordBool(const Value: WordBool): WordBool;

    function SendIntegers(const A: TArray<Integer>): TArray<Integer>; safecall;
    function SendFixedIntegers(const A: TFixedIntegers): TFixedIntegers; safecall;
    function SendData(const A: TArray<string>): TArray<string>; overload;
    function SendData(const A: TArray<Boolean>): TArray<Boolean>; overload;
    function SendData(const A: TArray<Integer>): TArray<Integer>; overload;
    function SendData(const A: TArray<Single>): TArray<Single>; overload;
    function SendData(const A: TArray<Double>): TArray<Double>; overload;
    function SendData(const A: TArray<string>; const AMsg: string): string; overload;
    function SendData(const A: TArray<string>; const ANumber: Integer): string; overload;
    function SendData(const A: TArray<TArray<string>>): string; overload; safecall;
    function SendData(const A: TArray<TArray<Integer>>): string; overload; safecall;
    function SendData(const A: TArray<TArray<Boolean>>): string; overload; safecall;

    function SendSomeObj(AObj: TMyObject): TMyObject;

    procedure SomeException;
    procedure SomeSafeCallException; safecall;
  end;

  ISomeExtendedJSONRPC = interface(ISomeJSONRPC)
    ['{21923AB6-2A55-473F-9F78-CC13DBDD5E50}']
    function AddSomeXY(X, Y, Z: Integer): Integer;
  end;

implementation

uses
{$IF DEFINED(MSWINDOWS)}
  Winapi.Windows,
{$ENDIF}
  System.JSON, System.Rtti, JSONRPC.InvokeRegistry,
  JSONRPC.JsonUtils, JSONRPC.Common.RecordHandlers;

{ TMyObject }

// As a record, no need to RegisterClass, as well as no memory management issues
constructor TMyObject.Create(const AData: string; ANum: Integer;
  ADate: TDateTime; const AAnotherObj: TAnotherObject);
begin
  FData := AData;
  FNum := ANum;
  FDate := ADate;
  FAnotherObj := AAnotherObj;
end;

{ TAnotherObject }

constructor TAnotherObject.Create(const AData: Double;
  const ASomeString: string);
begin
  FData := AData;
  FSomeString := ASomeString;
  FArray := [5, 3, 1, 4];
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(ISomeJSONRPC));
{$IF DEFINED(TEST)}
  // Developed to send rubbish data to check server tolerance
  InvRegistry.RegisterInterface(TypeInfo(ISomeExtendedJSONRPC));
{$ENDIF}

end.
