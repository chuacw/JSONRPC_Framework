{---------------------------------------------------------------------------}
{                                                                           }
{ File:       TestJSONRPC.Client.pas                                        }
{ Function:  A JSON RPC test client                                         }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit TestJSONRPC.Client;

interface

uses
  DUnitX.TestFramework, JSONRPC.User.SomeTypes, JSONRPC.ServerBase.Runner,
  Velthuis.BigDecimals, Velthuis.BigIntegers;

{$IF NOT DECLARED(Velthuis.BigDecimals) AND NOT DECLARED(Velthuis.BigIntegers)}
  {$MESSAGE HINT 'Include Velthuis.BigDecimals to automatically enable SendExtended'}
{$ENDIF}

{$IF SizeOf(Extended) >= 10}
  {$DEFINE EXTENDEDHAS10BYTES}
{$ENDIF}

type

  [TestFixture]
  TTestJSONRPCClient = class
  protected
    // Client JSON RPC
    FSomeJSONRPC: ISomeJSONRPC;
    // Server JSON RPC
    FServerRunner: TCustomJSONRPCServerRunner;

    FStartPort: Integer;
    procedure FindOpenPort;
  public
    [SetupFixture]
    procedure Setup;

    [TearDownFixture]
    procedure TearDown;

    [Test]
    procedure TestOnLogIncomingJSONResponse;

    [Test]
    procedure TestOnLogOutgoingJSONRequest;

    [Test]
    procedure SendBigNumbers;

    [Test, TestCase('AddDoubles', '5.1,6.3')]
    procedure AddDoubles(A, B: Float64);

    [Test, TestCase('AddSomeXY', '1,2')]
    procedure AddSomeXY(const AValue1: Integer; const AValue2: Integer);

    [Test]
    procedure GetSomeDate();

    [Test, TestCase('TestTrue', 'True'), TestCase('TestFalse', 'False')]
    procedure GetSomeBool(ASomeBool: Boolean);

    [Test]
    procedure GetEnum;

    [Test]
    procedure PredEnum;

    [Test]
    procedure SuccEnum;

    [Test]
    procedure SendEnum;

    [Test]
    procedure SomeException;

    [Test, TestCase('AssignHandler', 'True'), TestCase('NoHandler', 'False')]
    procedure SomeSafeCallException(AssignHandler: Boolean);

    [Test, TestCase('SendTrue', 'True'), TestCase('SendFalse', 'False')]
    procedure SendBool(const Value: Boolean);

    [Test, TestCase('SendByte', '1'), TestCase('SendByte', '255'), TestCase('SendByte', '256')]
    procedure SendByte(const Value: Byte);

    [Test, TestCase('SendByteBool', 'False'), TestCase('SendByteBool', 'True')]
    procedure SendByteBool(const Value: ByteBool);

    [Test]
    procedure SendCardinal;

    [Test, TestCase('SendCurrencyMinValue', '-922337203685477.5807'), TestCase('SendCurrencyMaxValue', '922337203685477.5807')]
    procedure SendCurrency(const Value: Currency);

    [Test, TestCase('SendDoubleMinValue', '-2468123'), TestCase('SendDoubleMaxValue', '2468123')]
    procedure SendDouble(const Value: Double);

    {$IF DECLARED(Neslib.MultiPrecision)}
    [Test]
    procedure SendDoubleDouble;

    [Test]
    procedure SendQuadDouble;
    {$ENDIF}

    {$IF DECLARED(Velthuis.BigDecimals)}
      {$IF DEFINED(EXTENDEDHAS10BYTES)}
      [Test, TestCase('SendExtendedMinValue', '-1.18973149535723176505e+4932'), TestCase('SendExtendedMaxValue', '1.18973149535723176505e+4932')]
      {$ELSE}
      [Test, TestCase('SendExtendedMinValue', '-1.7976931348623157081e+308'), TestCase('SendExtendedMaxValue', '1.7976931348623157081e+308')]
      {$ENDIF}
      procedure SendExtended(const Value: Extended);
    {$ENDIF}

    [Test, TestCase('SendDataBooleanArray', '[True,True]')]
    procedure SendData(const A: TArray<Boolean>); overload;

    [Test, TestCase('SendDataIntegerArray', '[1234,90916]')]
    procedure SendData(const A: TArray<Integer>); overload;

    [Test, TestCase('SendDataSingleArray', '[1.0,3.1]')]
    procedure SendData(const A: TArray<Single>); overload;

    [Test, TestCase('SendDataDoubleArray', '[4.5,9.6]')]
    procedure SendData(const A: TArray<Double>); overload;

    [Test]
    procedure SendGUID;

    [Test]
    procedure SendInt64(const Value: Int64);

    [Test]
    procedure SendInteger(const Value: Integer);

    [Test]
    procedure SendLongWord(const Value: LongWord);

    [Test]
    procedure SendNativeInt(const Value: NativeInt);

    [Test]
    procedure SendNativeUInt(const Value: NativeUInt);

    [Test]
    procedure SendShort(const Value: ShortInt);

    [Test]
    procedure SendSingle(const Value: Single);

    [Test]
    procedure SendSmallInt(const Value: SmallInt);

    [Test]
    procedure SendString;

    [Test]
    procedure SendUInt64(const Value: UInt64);

    [Test]
    procedure SendWord(const Value: Word);

    [Test]
    procedure SendWordBool(const Value: WordBool);
  end;

implementation

uses
  System.SysUtils, JSONRPC.RIO, JSONRPC.Common.Types,
  IPPeerServer, IPPeerAPI, JSONRPC.User.SomeTypes.Impl,
  System.DateUtils,
  JSONRPC.Common.FixBuggyNativeTypes, System.Math,
  TestJSONRPC.JSONRPCHTTPServer;

procedure TTestJSONRPCClient.SendBigNumbers;
{$IF DECLARED(Velthuis.BigDecimal)}
var
  LBigNumber, LResult: BigDecimal;
{$ENDIF}
begin
{$IF DECLARED(Velthuis.BigDecimal)}
  LBigNumber := BigDecimal.Create('1.18973149535723176505e+4933');
  LResult := FSomeJSONRPC.SendExtended(LBigNumber);
  Assert.IsTrue(LResult = LBigNumber, 'BigIntegers are not equal!');

  LBigNumber := BigDecimal.Create('-1.18973149535723176505e+4933');
  LResult := FSomeJSONRPC.SendExtended(LBigNumber);
  Assert.IsTrue(LResult = LBigNumber, 'BigIntegers are not equal!');
{$ENDIF}
end;

procedure TTestJSONRPCClient.AddDoubles(A, B: Float64);
begin
  var LResult := FSomeJSONRPC.AddDoubles(A, B);
  Assert.AreEqual(LResult, A + B);
end;

procedure TTestJSONRPCClient.AddSomeXY(const AValue1: Integer; const AValue2: Integer);
begin
  var LResult := FSomeJSONRPC.AddSomeXY(AValue1, AValue2);
  Assert.AreEqual(LResult, AValue1 + AValue2);
end;

procedure TTestJSONRPCClient.GetSomeBool(ASomeBool: Boolean);
begin
  var LResult := FSomeJSONRPC.GetSomeBool(ASomeBool);
  Assert.IsTrue(LResult = ASomeBool, 'Unexpected result');
end;

procedure TTestJSONRPCClient.GetSomeDate;
begin
  var LSomeDate: TDateTime := Now;
  var LResult: TDateTime := FSomeJSONRPC.GetSomeDate(LSomeDate);
  Assert.AreEqual(LResult, IncDay(LSomeDate));
end;

procedure TTestJSONRPCClient.SendBool(const Value: Boolean);
begin
  var LResult := FSomeJSONRPC.SendBool(Value);
  Assert.AreEqual(Value, LResult, 'Booleans are not the same!');
end;

procedure TTestJSONRPCClient.SendByte(const Value: Byte);
begin
  var LResult := FSomeJSONRPC.SendByte(Value);
  Assert.AreEqual(Value, LResult, 'Bytes are not the same!');
end;

procedure TTestJSONRPCClient.SendByteBool(const Value: ByteBool);
begin
  var LResult := FSomeJSONRPC.SendByteBool(Value);
  Assert.AreEqual(Value, LResult, 'ByteBools are not the same!');
end;

procedure TTestJSONRPCClient.SendCardinal;
var
  LValue1, LValue2: Cardinal;
begin
  LValue1 := Cardinal.MinValue;
  var LResult := FSomeJSONRPC.SendCardinal(LValue1);
  Assert.AreEqual(LValue1, LResult, 'Cardinals are not the same!');

  LValue2 := Cardinal.MaxValue;
  LResult := FSomeJSONRPC.SendCardinal(LValue2);
  Assert.AreEqual(LValue2, LResult, 'Cardinals are not the same!');
end;

procedure TTestJSONRPCClient.SendCurrency(const Value: Currency);
var
  LResult: Currency;
begin
  LResult := FSomeJSONRPC.SendCurrency(Value);
  Assert.IsTrue(SameValue(Value, LResult), 'Currencies are not the same!');
end;

{$IF DECLARED(Neslib.MultiPrecision)}
procedure TTestJSONRPCClient.SendDoubleDouble;
var
  LValue,
  LResult: DoubleDouble;
begin
  LValue := '-1.7976931348623157081e+308';
  LResult := FSomeJSONRPC.SendDoubleDouble(LValue);
  Assert.IsTrue(LResult = LValue, 'DoubleDoubles are not the same!');

  LValue := '1.7976931348623157081e+308';
  LResult := FSomeJSONRPC.SendDoubleDouble(LValue);
  Assert.IsTrue(LResult = LValue, 'DoubleDoubles are not the same!');
end;

procedure TTestJSONRPCClient.SendQuadDouble;
var
  LValue, LResult: QuadDouble;
begin
  LValue := '-1.18973149535723176505e+4932';
  LResult := FSomeJSONRPC.SendQuadDouble(LValue);
  Assert.IsTrue(LResult = LValue, 'DoubleDoubles are not the same!');

  LValue := '1.18973149535723176505e+4932'; // Extended.MaxValue
  LResult := FSomeJSONRPC.SendQuadDouble(LValue);
  Assert.IsTrue(LResult = LValue, 'DoubleDoubles are not the same!');
end;
{$ENDIF}

procedure TTestJSONRPCClient.SendDouble(const Value: Double);
var
  LResult: Double;
begin
  LResult := FSomeJSONRPC.SendDouble(Value);
  Assert.IsTrue(SameValue(Value, LResult), 'Doubles are not the same!');
end;

procedure TTestJSONRPCClient.GetEnum;
begin
  var LResult := FSomeJSONRPC.GetEnum(TEnum.enumB);
  Assert.IsTrue(LResult = enumB, 'Enums are not marshalled correctly!');
end;

procedure TTestJSONRPCClient.PredEnum;
begin
  var LResult := FSomeJSONRPC.PredEnum(enumB);
  Assert.IsTrue(LResult = enumA, 'Enums are not marshalled correctly!');
end;

procedure TTestJSONRPCClient.SuccEnum;
begin
  var LResult := FSomeJSONRPC.SuccEnum(enumA);
  Assert.IsTrue(LResult = enumB, 'Enums are not marshalled correctly!');
end;

procedure TTestJSONRPCClient.SendEnum;
begin
  var LResult := FSomeJSONRPC.SendEnum(enumA);
  Assert.IsTrue(LResult = 'enumA', 'Enums are not marshalled correctly!');

  LResult := FSomeJSONRPC.SendEnum(enumB);
  Assert.IsTrue(LResult = 'enumB', 'Enums are not marshalled correctly!');
end;

{$IF DECLARED(Velthuis.BigDecimals)}
procedure TTestJSONRPCClient.SendExtended(const Value: Extended);
begin
  var LFloat := FixedFloatToJson(Value);
{$IF DECLARED(ISomeJSONRPC_SendExtended)}
  var LResult := FSomeJSONRPC.SendExtended(Value);
  Assert.IsTrue(Value = LResult, 'Extendeds are not the same!');
{$ENDIF}
end;
{$ENDIF}

procedure TTestJSONRPCClient.SendData(const A: TArray<Boolean>);
var
  LValues,
  LResult: TArray<Boolean>;
begin
  LValues := [True, True];
  LResult := FSomeJSONRPC.SendData(LValues);
  Assert.AreEqual<TArray<Boolean>>(LResult, LValues, 'Boolean arrays are not equal!');
end;

procedure TTestJSONRPCClient.SendData(const A: TArray<Integer>);
var
  LValues, LResult: TArray<Integer>;
begin
  LValues := [1, 2, 3];
  LResult := FSomeJSONRPC.SendData(LValues);
  Assert.AreEqual<TArray<Integer>>(LResult, LValues, 'Integer arrays are not equal!');
end;

procedure TTestJSONRPCClient.SendData(const A: TArray<Single>);
var
  LValues, LResult: TArray<Single>;
begin
  LValues := [1.0, 2.0];
  LResult := FSomeJSONRPC.SendData(LValues);
  Assert.AreEqual<TArray<Single>>(LResult, LValues, 'Single arrays are not equal!');
end;

procedure TTestJSONRPCClient.SendData(const A: TArray<Double>);
var
  LValues,
  LResult: TArray<Double>;
begin
  LValues := [1.0, 2.0];
  LResult := FSomeJSONRPC.SendData(LValues);
  Assert.AreEqual<TArray<Double>>(LResult, LValues, 'Double arrays are not equal!');
end;

procedure TTestJSONRPCClient.SendGUID;
begin
  var LGUID: TGUID := TGUID.Create('{32CC06A3-D185-4035-B0A6-03A4D5F55CB2}');
  var LResult := FSomeJSONRPC.SendGUID(LGUID);
  Assert.AreEqual(LGUID, LResult, 'GUIDs are not equal!');
end;

procedure TTestJSONRPCClient.SendInt64(const Value: Int64);
begin
  var LResult := FSomeJSONRPC.SendInt64(Value);
  Assert.AreEqual(Value, LResult, 'Int64s are not the same!');
end;

procedure TTestJSONRPCClient.SendInteger(const Value: Integer);
begin
  var LResult := FSomeJSONRPC.SendInteger(Value);
  Assert.AreEqual(Value, LResult, 'Integers are not the same!');
end;

procedure TTestJSONRPCClient.SendLongWord(const Value: LongWord);
begin
  var LResult := FSomeJSONRPC.SendLongWord(Value);
  Assert.AreEqual(Value, LResult, 'LongWords are not the same!');
end;

procedure TTestJSONRPCClient.SendNativeInt(const Value: NativeInt);
begin
  var LResult := FSomeJSONRPC.SendNativeInt(Value);
  Assert.AreEqual(Value, LResult, 'NativeInts are not the same!');
end;

procedure TTestJSONRPCClient.SendNativeUInt(const Value: NativeUInt);
begin
  var LResult := FSomeJSONRPC.SendNativeUInt(Value);
  Assert.AreEqual(Value, LResult, 'NativeUInts are not the same!');
end;

procedure TTestJSONRPCClient.SendShort(const Value: ShortInt);
begin
  var LResult := FSomeJSONRPC.SendShort(Value);
  Assert.AreEqual(Value, LResult, 'ShortInts are not the same!');
end;

procedure TTestJSONRPCClient.SendSingle(const Value: Single);
begin
  var LResult: Single := FSomeJSONRPC.SendSingle(Value);
  Assert.AreEqual(Value, LResult, 'Singles are not the same!');
end;

procedure TTestJSONRPCClient.SendSmallInt(const Value: SmallInt);
begin
  var LResult := FSomeJSONRPC.SendSmallInt(Value);
  Assert.AreEqual(Value, LResult, 'SmallInts are not the same!');
end;

procedure TTestJSONRPCClient.SendString;
begin
  var LValue1 := 'HelloWorld';
  var LResult := FSomeJSONRPC.SendString(LValue1);
  Assert.AreEqual(LValue1, LResult, 'Strings are not the same!');

  var LValue2 := 'Are you ok?';
  var LResult2 := FSomeJSONRPC.SendString(LValue2);
  Assert.AreEqual(LValue2, LResult2, 'Strings are not the same!');
end;

procedure TTestJSONRPCClient.SendUInt64(const Value: UInt64);
begin
  var LResult := FSomeJSONRPC.SendUInt64(Value);
  Assert.AreEqual(Value, LResult, 'UInt64s are not the same!');
end;

procedure TTestJSONRPCClient.SendWord(const Value: Word);
begin
  var LResult := FSomeJSONRPC.SendWord(Value);
  Assert.AreEqual(Value, LResult, 'Words are not the same!');
end;

procedure TTestJSONRPCClient.SendWordBool(const Value: WordBool);
begin
  var LResult := FSomeJSONRPC.SendWordBool(Value);
  Assert.IsTrue(LResult = Value, 'WordBools are not the same!');
end;

procedure TTestJSONRPCClient.FindOpenPort;
begin
  var LPortSet: Boolean;
  FStartPort := 8085;
  repeat
    LPortSet := FServerRunner.CheckPort(FStartPort) > 0;
    if not LPortSet then
      Inc(FStartPort);
  until LPortSet;
end;

procedure TTestJSONRPCClient.Setup;
begin
// Set up internal server
  FServerRunner := TJSONRPCServerIdHTTPRunner.Create;
  FindOpenPort;
  FServerRunner.Host := 'localhost';
  FServerRunner.StartServer(FStartPort);

// Set up RPC client
  var LServerURL := Format('http://localhost:%d', [FStartPort]);
  FSomeJSONRPC := GetSomeJSONRPC(LServerURL);
end;

procedure TTestJSONRPCClient.SomeException;
begin
  var LException := False;
  try
    FSomeJSONRPC.SomeException;
  except
    LException := True;
  end;
  Assert.IsTrue(LException, 'Expected exception isn''t thrown');
end;

procedure TTestJSONRPCClient.SomeSafeCallException(AssignHandler: Boolean);
begin
  var LSafeCallIntercepted := False;
  var LExceptionWithoutSafecallHandler := False;
  case AssignHandler of
    False: begin
      AssignJSONRPCSafeCallExceptionHandler(FSomeJSONRPC, nil);
    end;
    True: begin
      AssignJSONRPCSafeCallExceptionHandler(FSomeJSONRPC,
        function (ExceptObject: TObject; ExceptAddr: Pointer): HResult
        var
          LExc: EJSONRPCException;
          LExcMethod: EJSONRPCMethodException absolute LExc;
        begin
          if ExceptObject is EJSONRPCException then
            begin
              LExc := ExceptObject as EJSONRPCException;
              LSafeCallIntercepted := True;
            end else
          if ExceptObject is Exception then
            begin
              var LExcObj := ExceptObject as Exception;
              LSafeCallIntercepted := True;
            end;
          Result := S_OK; // Clear the error otherwise, CheckAutoResult will raise error
        end
      );
    end;
  end;

  try
    FSomeJSONRPC.SomeSafeCallException;
  except
    if not AssignHandler then
      LExceptionWithoutSafecallHandler := True;
  end;

  case AssignHandler of
    False: begin
      Assert.IsTrue(LExceptionWithoutSafecallHandler, 'normal exception wasn''t assigned!');
    end;
    True: begin
      Assert.IsTrue(LSafeCallIntercepted, 'safecall exception wasn''t intercepted');
    end;
  end;
end;

procedure TTestJSONRPCClient.TearDown;
begin
  FSomeJSONRPC := nil;
  FreeAndNil(FServerRunner);
end;

procedure TTestJSONRPCClient.TestOnLogIncomingJSONResponse;
var
  LJSONRPCClientLog: IJSONRPCClientLog;
  LJSON, LJSON1: string;
  LLogged: Boolean;
  LPassed: Boolean;
begin
  LLogged := False; LPassed := False;
  if Supports(FSomeJSONRPC, IJSONRPCClientLog, LJSONRPCClientLog) then
    begin
      LJSONRPCClientLog.OnLogIncomingJSONResponse := procedure(const AJSON: string)
      begin
        LJSON1 := AJSON;
        LLogged := True;
      end;
      FSomeJSONRPC.AddSomeXY(3,4);
      LJSON := LJSON1;
      LPassed := LJSON = '{"jsonrpc":"2.0","result":7,"id":1}';

      LJSONRPCClientLog.OnLogIncomingJSONResponse := nil;
    end;
  Assert.IsTrue(LPassed and LLogged, 'JSON is not equal!');
end;

procedure TTestJSONRPCClient.TestOnLogOutgoingJSONRequest;
var
  LJSONRPCClientLog: IJSONRPCClientLog;
  LJSON, LJSON1: string;
  LLogged: Boolean;
  LPassed: Boolean;
begin
  LLogged := False; LPassed := False;
  if Supports(FSomeJSONRPC, IJSONRPCClientLog, LJSONRPCClientLog) then
    begin
      LJSONRPCClientLog.OnLogOutgoingJSONRequest  := procedure(const AJSON: string)
      begin
        LJSON1 := AJSON;
        LLogged := True;
      end;
      FSomeJSONRPC.AddSomeXY(1,2);
      LJSON := LJSON1;
      LPassed := LJSON = '{"jsonrpc":"2.0","method":"AddSomeXY","params":{"X":1,"Y":2},"id":2}';

      LJSONRPCClientLog.OnLogOutgoingJSONRequest := nil;
    end;
  Assert.IsTrue(LPassed and LLogged, 'JSON is not equal!');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestJSONRPCClient);

end.
