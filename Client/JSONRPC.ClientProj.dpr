program JSONRPC.ClientProj;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  JSONRPC.RIO in '..\Common\JSONRPC.RIO.pas',
  System.Classes,
  System.Rtti,
  System.JSON,
  System.SysUtils,
  System.TypInfo,
  Winapi.Windows,
  System.DateUtils,
  System.JSON.Serializers,
  System.JSON.Writers,
  JSONRPC.Common.Consts in '..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.InvokeRegistry in '..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.User.SomeTypes in '..\Common\JSONRPC.User.SomeTypes.pas',
  JSONRPC.Common.Types in '..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.JsonUtils in '..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.TransportWrapper.HTTP in '..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  JSONRPC.User.SomeTypes.Impl in 'JSONRPC.User.SomeTypes.Impl.pas',
  System.Net.ClientSocket in '..\..\NetSocket\Client\System.Net.ClientSocket.pas',
  System.Net.Socket.Common in '..\..\NetSocket\Common\System.Net.Socket.Common.pas',
  JSONRPC.Common.RecordHandlers in '..\Common\JSONRPC.Common.RecordHandlers.pas';

procedure Main;
begin
  var LJSONRPC := GetSomeJSONRPC('http://localhost:8083');
  try

    // Pass by position, or pass by name, default = pass params by name
//    var LJSONRPCInvocationSettings: IJSONRPCInvocationSettings;
//    if Supports(LJSONRPC, IJSONRPCInvocationSettings, LJSONRPCInvocationSettings) then
//      begin
//        LJSONRPCInvocationSettings.PassParamsByPosition := True;
//      end;

    AssignJSONRPCSafeCallExceptionHandler(LJSONRPC,
      function (ExceptObject: TObject; ExceptAddr: Pointer): HResult
      var
        LExc: EJSONRPCException;
        LExcMethod: EJSONRPCMethodException absolute LExc;
      begin
        if ExceptObject is EJSONRPCException then
          begin
            LExc := ExceptObject as EJSONRPCException;
            WriteLn('Intercepted safecall exception...');
            Write(Format('message: "%s", code: %d', [LExc.Message, LExc.Code]));
            if LExc is EJSONRPCMethodException then
              begin
                Write(Format(', method: "%s"', [LExcMethod.MethodName]));
              end;
            WriteLn;
            WriteLn(StringOfChar('-', 90));
          end else
        if ExceptObject is Exception then
          begin
            var LExcObj := ExceptObject as Exception;
            WriteLn('Intercepted safecall exception...');
            WriteLn(Format('message: "%s"', [LExcObj.Message]));
          end;
        Result := S_OK; // Clear the error otherwise, CheckAutoResult will raise error
      end
    );

    try
      LJSONRPC.SomeException;
    except
      on E: EJSONRPCMethodException do
        begin
          WriteLn('Intercepted normal exception...');
          WriteLn(Format('message: %s, code: %d, method: %s', [E.Message, E.Code, E.MethodName]));
          WriteLn(StringOfChar('-', 90));
        end;
      on E: EJSONRPCException do
        begin
          WriteLn('Intercepted normal exception...');
          WriteLn(Format('message: %s, code: %d', [E.Message, E.Code]));
          WriteLn(StringOfChar('-', 90));
        end;
    end;

//    var LResultBigInt := LJSONRPC.SendBigInteger(UInt64.MaxValue);
//    Assert(LResultBigInt = UInt64.MaxValue, 'Roundtripping failed');

// This needs to run in 32-bit and the server needs to run in 64-bit
    var LResult := LJSONRPC.SendExtended(Extended.MaxValue);
    Assert(LResult = Extended.MaxValue, 'Roundtripping failed');

    // A safecall do not need any exception handler
    // it uses the one assigned by AssignSafeCallExceptionHandler

    // This causes an exception that's trapped above
    LJSONRPC.SomeSafeCallException;

//    var LEnum := LJSONRPC.GetEnum(enumB);
//    var LResult := LJSONRPC.SendData([[False, False], [False, True]]);
//    LResult := LJSONRPC.SendData([[5], [6]]);
//    LResult := LJSONRPC.SendData([['A'], ['B']]);
//    var LArray1: TMyArray := [1, 2, 3, 4, 5];
//    var LFixedInt: TFixedIntegers;
//    LFixedInt[0] := 1; LFixedInt[1] := 1; LFixedInt[2] := 2; LFixedInt[3] := 3;
//    ArrayToJSONArray(LArray1, TypeInfo(TMyArray));
//    var LArrayStr := SerializeRecord(@LArray1, TypeInfo(TMyArray));
//    var LIntegers := LJSONRPC.SendIntegers([1, 2, 3, 4, 5]);
//    var LFixedIntegers := LJSONRPC.SendFixedIntegers(LFixedInt);

    var LAnotherObj := TAnotherObject.Create(8.0, 'SomeValue');
    var LObj := TMyObject.Create('Hello', 5, Now, LAnotherObj);

    var LResultObj := LJSONRPC.SendSomeObj(LObj);
    var LSomeDate := LJSONRPC.GetSomeDate(Now);
    WriteLn(DateToISO8601(LSomeDate));
    var LResultInt := LJSONRPC.AddSomeXY(5, 6);
    Writeln('AddSomeXY: ', LResultInt);
    var LResultFloat := LJSONRPC.AddDoubles(1.0, 2.1);
    Writeln('Doubles: ', LResultFloat);
    LJSONRPC.GetSomeBool(False);
    LJSONRPC.CallSomeMethod;
  except
  end;
  LJSONRPC := nil;
end;

begin
  try
    ReportMemoryLeaksOnShutdown := True;
    Main;
  finally
    Write('Press enter to terminate...');
    ReadLn;
  end;
end.
