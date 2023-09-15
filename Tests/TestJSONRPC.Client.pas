unit TestJSONRPC.Client;

interface

uses
  DUnitX.TestFramework, JSONRPC.User.SomeTypes, JSONRPC.ServerBase.Runner;

{$IF SizeOf(Extended) >= 10}
  {$DEFINE EXTENDEDHAS10BYTES}
{$ENDIF}

type

  [TestFixture]
  TTestJSONRPCClient = class
  private
  protected
    FSomeRPC: ISomeJSONRPC;
    FServerRunner: TJSONRPCServerRunner;
    FStartPort: Integer;
  public
    [SetupFixture]
    procedure Setup;

    [TearDownFixture]
    procedure TearDown;
    // Sample Methods
    // Simple single Test

    [Test, TestCase('AddSomeXY', '1,2')]
    procedure AddSomeXY(const AValue1: Integer; const AValue2: Integer);

    [Test]
    procedure GetSomeDate();

    [Test, TestCase('TestTrue', 'True'), TestCase('TestFalse', 'False')]
    procedure GetSomeBool(ASomeBool: Boolean);

    [Test, TestCase('AddDoubles', '5.1,6.3')]
    procedure AddDoubles(A, B: Float64);

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

    [Test, TestCase('SendCardinalMinValue', '0'), TestCase('SendCardinalMaxValue', '4294967295')]
    procedure SendCardinal(const Value: Cardinal);

    [Test, TestCase('SendCurrencyMinValue', '-922337203685477.5807'), TestCase('SendCurrencyMaxValue', '922337203685477.5807')]
    procedure SendCurrency(const Value: Currency);

    [Test, TestCase('SendDoubleMinValue', '-1.7976931348623157081e+308'), TestCase('SendDoubleMaxValue', '1.7976931348623157081e+308')]
    procedure SendDouble(const Value: Double);

    {$IF DEFINED(EXTENDEDHAS10BYTES)}
    [Test, TestCase('SendExtendedMinValue', '-1.18973149535723176505e+4932'), TestCase('SendExtendedMaxValue', '1.18973149535723176505e+4932')]
    {$ELSE}
    [Test, TestCase('SendExtendedMinValue', '-1.7976931348623157081e+308'), TestCase('SendExtendedMaxValue', '1.7976931348623157081e+308')]
    {$ENDIF}
    procedure SendExtended(const Value: Extended);

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
    procedure SendString(const Value: string);

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
  JSONRPC.ServerIdHTTP.Runner, System.DateUtils;

procedure TTestJSONRPCClient.AddDoubles(A, B: Float64);
begin
  var LResult := FSomeRPC.AddDoubles(A, B);
  Assert.AreEqual(LResult, A + B);
end;

procedure TTestJSONRPCClient.AddSomeXY(const AValue1: Integer; const AValue2: Integer);
begin
  var LResult := FSomeRPC.AddSomeXY(AValue1, AValue2);
  Assert.AreEqual(LResult, AValue1 + AValue2);
end;

procedure TTestJSONRPCClient.GetSomeBool(ASomeBool: Boolean);
begin
  var LResult := FSomeRPC.GetSomeBool(ASomeBool);
  Assert.IsTrue(LResult = ASomeBool, 'Unexpected result');
end;

procedure TTestJSONRPCClient.GetSomeDate;
begin
  var LSomeDate: TDateTime := Now;
  var LResult: TDateTime := FSomeRPC.GetSomeDate(LSomeDate);
  Assert.AreEqual(LResult, IncDay(LSomeDate));
end;

procedure TTestJSONRPCClient.SendBool(const Value: Boolean);
begin
  var LResult := FSomeRPC.SendBool(Value);
  Assert.AreEqual(Value, LResult, 'Booleans are not the same!');
end;

procedure TTestJSONRPCClient.SendByte(const Value: Byte);
begin
  var LResult := FSomeRPC.SendByte(Value);
  Assert.AreEqual(Value, LResult, 'Bytes are not the same!');
end;

procedure TTestJSONRPCClient.SendByteBool(const Value: ByteBool);
begin
  var LResult := FSomeRPC.SendByteBool(Value);
  Assert.AreEqual(Value, LResult, 'ByteBools are not the same!');
end;

procedure TTestJSONRPCClient.SendCardinal(const Value: Cardinal);
begin
  var LResult := FSomeRPC.SendCardinal(Value);
  Assert.AreEqual(Value, LResult, 'Cardinals are not the same!');
end;

procedure TTestJSONRPCClient.SendCurrency(const Value: Currency);
begin
  var LResult := FSomeRPC.SendCurrency(Value);
  Assert.AreEqual<Currency>(Value, LResult, 'Currencies are not the same!');
end;

procedure TTestJSONRPCClient.SendDouble(const Value: Double);
begin
  var LResult := FSomeRPC.SendDouble(Value);
  Assert.AreEqual<Double>(Value, LResult, 'Doubles are not the same!');
end;

procedure TTestJSONRPCClient.SendEnum;
begin
  var LResult := FSomeRPC.SendEnum(TEnum.enumB);
  Assert.IsTrue(LResult = 'enumB', 'Enums are not marshalled correctly!');
end;

procedure TTestJSONRPCClient.SendExtended(const Value: Extended);
begin
  var LResult := FSomeRPC.SendExtended(Value);
  Assert.IsTrue(Value = LResult, 'Extendeds are not the same!');
end;

procedure TTestJSONRPCClient.SendGUID;
begin
  var LGUID: TGUID := TGUID.Create('{32CC06A3-D185-4035-B0A6-03A4D5F55CB2}');
  var LResult := FSomeRPC.SendGUID(LGUID);
  Assert.AreEqual(LGUID, LResult, 'GUIDs are not equal!');
end;

procedure TTestJSONRPCClient.SendInt64(const Value: Int64);
begin
  var LResult := FSomeRPC.SendInt64(Value);
  Assert.AreEqual(Value, LResult, 'Int64s are not the same!');
end;

procedure TTestJSONRPCClient.SendInteger(const Value: Integer);
begin
  var LResult := FSomeRPC.SendInteger(Value);
  Assert.AreEqual(Value, LResult, 'Integers are not the same!');
end;

procedure TTestJSONRPCClient.SendLongWord(const Value: LongWord);
begin
  var LResult := FSomeRPC.SendLongWord(Value);
  Assert.AreEqual(Value, LResult, 'LongWords are not the same!');
end;

procedure TTestJSONRPCClient.SendNativeInt(const Value: NativeInt);
begin
  var LResult := FSomeRPC.SendNativeInt(Value);
  Assert.AreEqual(Value, LResult, 'NativeInts are not the same!');
end;

procedure TTestJSONRPCClient.SendNativeUInt(const Value: NativeUInt);
begin
  var LResult := FSomeRPC.SendNativeUInt(Value);
  Assert.AreEqual(Value, LResult, 'NativeUInts are not the same!');
end;

procedure TTestJSONRPCClient.SendShort(const Value: ShortInt);
begin
  var LResult := FSomeRPC.SendShort(Value);
  Assert.AreEqual(Value, LResult, 'ShortInts are not the same!');
end;

procedure TTestJSONRPCClient.SendSingle(const Value: Single);
begin
  var LResult: Single := FSomeRPC.SendSingle(Value);
  Assert.AreEqual(Value, LResult, 'Singles are not the same!');
end;

procedure TTestJSONRPCClient.SendSmallInt(const Value: SmallInt);
begin
  var LResult := FSomeRPC.SendSmallInt(Value);
  Assert.AreEqual(Value, LResult, 'SmallInts are not the same!');
end;

procedure TTestJSONRPCClient.SendString(const Value: string);
begin
  var LResult := FSomeRPC.SendString(Value);
  Assert.AreEqual(Value, LResult, 'Strings are not the same!');
end;

procedure TTestJSONRPCClient.SendUInt64(const Value: UInt64);
begin
  var LResult := FSomeRPC.SendUInt64(Value);
  Assert.AreEqual(Value, LResult, 'UInt64s are not the same!');
end;

procedure TTestJSONRPCClient.SendWord(const Value: Word);
begin
  var LResult := FSomeRPC.SendWord(Value);
  Assert.AreEqual(Value, LResult, 'Words are not the same!');
end;

procedure TTestJSONRPCClient.SendWordBool(const Value: WordBool);
begin
  var LResult := FSomeRPC.SendWordBool(Value);
  Assert.IsTrue(LResult, 'WordBools are not the same!');
end;

procedure TTestJSONRPCClient.Setup;
begin
// Set up internal server

  FServerRunner := TJSONRPCServerIdHTTPRunner.Create;
  var LPortSet: Boolean;
  FStartPort := 8085;
  repeat
    LPortSet := FServerRunner.CheckPort(FStartPort) > 0;
    if not LPortSet then
      Inc(FStartPort);
  until LPortSet;
  FServerRunner.Host := 'localhost';
  FServerRunner.StartServer(FStartPort);

// Set up RPC client
  var LServerURL := Format('http://localhost:%d', [FStartPort]);
  FSomeRPC := GetSomeJSONRPC(LServerURL);
end;

procedure TTestJSONRPCClient.SomeException;
begin
  var LException := False;
  try
    FSomeRPC.SomeException;
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
      AssignJSONRPCSafeCallExceptionHandler(FSomeRPC, nil);
    end;
    True: begin
      AssignJSONRPCSafeCallExceptionHandler(FSomeRPC,
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
    FSomeRPC.SomeSafeCallException;
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
  FSomeRPC := nil;
  FreeAndNil(FServerRunner);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestJSONRPCClient);

end.
