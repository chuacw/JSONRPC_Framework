unit JSONRPC.User.ServerImpl;

interface

uses
  System.Types, JSONRPC.User.SomeTypes, JSONRPC.InvokeRegistry,
  Velthuis.BigDecimals, Velthuis.BigIntegers, Neslib.MultiPrecision;

type

  TSomeJSONRPC = class(TInvokableClass, ISomeJSONRPC)
  public
    constructor Create; override;
    destructor Destroy; override;

    { ISomeJSONRPC }
    procedure ANotifyMethod;
    function AddSomeXY(X: Integer; Y: Integer): Integer;
    procedure CallSomeMethod;
    function CallSomeRoutine: Boolean;
    function GetSomeDate(const ADateTime: TDateTime): TDateTime;
    function AddDoubles(A, B: Float64): Float64;
    function Combine(const Str1, Str2: string): string;

    { Neslib.MultiPrecision }
    {$IF DECLARED(Neslib.MultiPrecision)}
    function SendDoubleDouble(const Value: DoubleDouble): DoubleDouble;
    function SendQuadDouble(const Value: QuadDouble): QuadDouble;
    {$ENDIF}

    function subtract(minuend, subtrahend: NativeInt): NativeInt;
    function AddString(const X: string; const Y: string): string;
    function GetDate: TDateTime;
    function GetEnum(const A: TEnum): TEnum;
    function GetSomeBool(const ABoolean: Boolean): Boolean; safecall;
    function SendSomeObj(AObj: TMyObject): TMyObject;

    function SendIntegers(const A: TArray<Integer>): TArray<Integer>; overload; safecall;
    function SendFixedIntegers(const A: TFixedIntegers): TFixedIntegers; safecall;

    function SendBigDecimal(const Value: BigDecimal): BigDecimal;
    function SendBigInteger(const Value: BigInteger): BigInteger; overload;
    function SendBool(const Value: Boolean): Boolean;
    function SendByte(const Value: Byte): Byte;
    function SendByteBool(const Value: ByteBool): ByteBool;
    function SendCardinal(const Value: Cardinal): Cardinal;
    function SendCurrency(const Value: Currency): Currency;
    function SendDouble(const Value: Double): Double;
    function SendExtended(const Value: BigDecimal): BigDecimal; overload;
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

    function SendData(const A: TArray<string>): TArray<string>; overload;
    function SendData(const A: TArray<string>; const AMsg: string): string; overload;
    function SendData(const A: TArray<string>; const ANumber: Integer): string; overload;
    function SendData(const A: TArray<TArray<string>>): string; overload;
    function SendData(const A: TArray<TArray<Integer>>): string; overload;
    function SendData(const A: TArray<TArray<Boolean>>): string; overload;

    function SendEnum(const A: TEnum): string;

    procedure SomeException;
    procedure SomeSafeCallException; safecall;
  end;

implementation

{ TSomeJSONRPC }

uses
  JSONRPC.RIO, System.SysUtils, System.DateUtils, System.Rtti,
  JSONRPC.JsonUtils, System.TypInfo, JSONRPC.Common.Types,
  System.JSON,
  JSONRPC.Common.RecordHandlers;

function TSomeJSONRPC.AddDoubles(A, B: Float64): Float64;
begin
  Result := A + B;
end;

function TSomeJSONRPC.AddSomeXY(X, Y: Integer): Integer;
begin
  Result := X + Y;
end;

function TSomeJSONRPC.AddString(const X, Y: string): string;
begin
  Result := X + Y;
end;

procedure TSomeJSONRPC.ANotifyMethod;
begin
end;

procedure TSomeJSONRPC.CallSomeMethod;
begin
end;

function TSomeJSONRPC.CallSomeRoutine: Boolean;
begin
  Result := True;
end;

function TSomeJSONRPC.Combine(const Str1, Str2: string): string;
begin
  Result := Format('%s %s', [Str1, Str2]);
end;

constructor TSomeJSONRPC.Create;
begin
  inherited;
end;

destructor TSomeJSONRPC.Destroy;
begin
  inherited;
end;

function TSomeJSONRPC.GetDate: TDateTime;
begin
  Result := Now;
end;

function TSomeJSONRPC.GetEnum(const A: TEnum): TEnum;
begin
  if Succ(A) > High(TEnum) then
    Result := Low(TEnum) else
    Result := Succ(A);
end;

function TSomeJSONRPC.GetSomeBool(const ABoolean: Boolean): Boolean;
begin
  Result := ABoolean;
end;

function TSomeJSONRPC.GetSomeDate(const ADateTime: TDateTime): TDateTime;
begin
  Result := IncDay(ADateTime, 1);
end;

{$IF DECLARED(Neslib.MultiPrecision)}
function TSomeJSONRPC.SendDoubleDouble(const Value: DoubleDouble): DoubleDouble;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendQuadDouble(const Value: QuadDouble): QuadDouble;
begin
  Result := Value;
end;
{$ENDIF}

function TSomeJSONRPC.SendEnum(const A: TEnum): string;
begin
  Result := GetEnumName(TypeInfo(TEnum), Ord(A));
end;

function TSomeJSONRPC.SendExtended(const Value: BigDecimal): BigDecimal;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendFixedIntegers(
  const A: TFixedIntegers): TFixedIntegers;
begin
  Result := A;
  for var I := Low(Result) to High(Result) do
    Inc(Result[I], 2);
end;

function TSomeJSONRPC.SendGUID(const Value: TGUID): TGUID;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendInt64(const Value: Int64): Int64;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendInteger(const Value: Integer): Integer;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendIntegers(const A: TArray<Integer>): TArray<Integer>;
begin
  Result := [];
  for var AValue in A do
    Result := Result + [AValue + 1];
end;

function TSomeJSONRPC.SendLongWord(const Value: LongWord): LongWord;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendNativeInt(const Value: NativeInt): NativeInt;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendNativeUInt(const Value: NativeUInt): NativeUInt;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendShort(const Value: ShortInt): ShortInt;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendSingle(const Value: Single): Single;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendSmallInt(const Value: SmallInt): SmallInt;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendSomeObj(AObj: TMyObject): TMyObject;
begin
  Result := AObj;
  Result.Data := 'Hi ' + Result.Data;
  Result.Num := Result.Num + 1;
  Result.Date := IncDay(Result.Date);
end;

function TSomeJSONRPC.SendString(const Value: string): string;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendUInt64(const Value: UInt64): UInt64;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendWord(const Value: Word): Word;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendWordBool(const Value: WordBool): WordBool;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendData(const A: TArray<string>): TArray<string>;
begin
  Result := A;
  for var I := Low(Result) to High(Result) do
    Result[I] := 'Hello ' + Result[I];
end;

function TSomeJSONRPC.SendData(const A: TArray<string>; const AMsg: string): string;
begin
  Result := AMsg;
end;

function TSomeJSONRPC.SendData(const A: TArray<string>;
  const ANumber: Integer): string;
begin
  Result := ANumber.ToString;
end;

function TSomeJSONRPC.subtract(minuend, subtrahend: NativeInt): NativeInt;
begin
  Result := minuend - subtrahend;
end;

function TSomeJSONRPC.SendBigInteger(const Value: BigInteger): BigInteger;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendBigDecimal(const Value: BigDecimal): BigDecimal;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendBool(const Value: Boolean): Boolean;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendByte(const Value: Byte): Byte;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendByteBool(const Value: ByteBool): ByteBool;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendCardinal(const Value: Cardinal): Cardinal;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendCurrency(const Value: Currency): Currency;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendData(const A: TArray<TArray<Boolean>>): string;
var
  LValue: TValue;
begin
  LValue := TValue.From(A);
  var SValue := SerializeValue(LValue, TypeInfo(TArray<TArray<Boolean>>));
  Result := 'TArray<TArray<Boolean>>: ' + SValue;
end;

function TSomeJSONRPC.SendDouble(const Value: Double): Double;
begin
  Result := Value;
end;

function TSomeJSONRPC.SendData(const A: TArray<TArray<Integer>>): string;
var
  LValue: TValue;
begin
  LValue := TValue.From(A);
  var SValue := SerializeValue(LValue, TypeInfo(TArray<TArray<Integer>>));
  Result := 'TArray<TArray<Integer>>: ' + SValue;
end;

function TSomeJSONRPC.SendData(const A: TArray<TArray<string>>): string;
var
  LValue: TValue;
begin
  LValue := TValue.From(A);
  var SValue := SerializeValue(LValue, TypeInfo(TArray<TArray<string>>));
  Result := 'TArray<TArray<string>>: ' + SValue;
end;

procedure TSomeJSONRPC.SomeException;
begin
  var AErrorMsg := 'Some server error within TSomeJSONRPC.SomeException';  // or your own message
  raise EJSONRPCException.Create(AErrorMsg);
end;

procedure TSomeJSONRPC.SomeSafeCallException;
begin
  var AErrorMsg := 'Exception within TSomeJSONRPC.SomeSafeCallException'; // or your own message
  raise EJSONRPCMethodException.Create(-32601, AErrorMsg, FMethodName);
end;

initialization
{ Invokable classes must be registered }
  InvRegistry.RegisterInvokableClass(TSomeJSONRPC);
  RegisterJSONRPCWrapper(TypeInfo(ISomeJSONRPC));

end.

