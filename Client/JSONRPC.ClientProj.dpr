program JSONRPC.ClientProj;

{$APPTYPE CONSOLE}
{$WARN DUPLICATE_CTOR_DTOR OFF}
{$R *.res}

uses
  JSONRPC.RIO in '..\Common\JSONRPC.RIO.pas',
  System.Classes,
  System.Generics.Collections,
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
  JSONRPC.Common.RecordHandlers in '..\Common\JSONRPC.Common.RecordHandlers.pas';

procedure Main;
begin
  var LJSONRPC := GetSomeJSONRPC('http://localhost:8083',
    procedure(const AJSONRPCRequest: string)
    begin
      Writeln(StringOfChar('-', 90));
      WriteLn(Format('Outgoing JSON RPC Request: %s', [AJSONRPCRequest]));
      Writeln(StringOfChar('-', 90));
    end,
    procedure(const AJSONRPCResponse: string)
    begin
      Writeln(StringOfChar('-', 90));
      WriteLn(Format('Incoming JSON RPC Response: %s', [AJSONRPCResponse]));
      Writeln(StringOfChar('-', 90));
    end
  );
  try
    Write('Press enter to see the value, press enter again to continue...');
    var LEnum := LJSONRPC.GetEnum(enumB);
    ReadLn;
    WriteLn(GetEnumName(TypeInfo(TEnum), Ord(LEnum)));
    ReadLn;
    LJSONRPC.SendBool(True);
//    var AList := TList<Integer>.Create;
//    AList.AddRange([1, 2, 3, 4, 5]);
//    var LResultList := LJSONRPC.SendSomeList(AList);

{$IF DECLARED(ISomeJSONRPC_SendExtended)}
    var LResultExtended := LJSONRPC.SendExtended(Extended.MaxValue);
    Assert(LResultExtended = Extended.MaxValue, 'Roundtripping failed');
{$ENDIF}

    // Pass by position, or pass by name, default = pass params by name
    SetPassParamsByPosition(LJSONRPC);

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

{$IF DECLARED(ISomeJSONRPC_SendBigInteger)}
    var LResultBigInt := LJSONRPC.SendBigInteger(UInt64.MaxValue);
{$ENDIF}

{$IF DECLARED(ISomeJSONRPC_SendExtended)}
// This needs to run in 32-bit and the server needs to run in 64-bit
    var LExtendedResult := LJSONRPC.SendExtended(Extended.MaxValue);
{$ENDIF}

    // A safecall do not need any exception handler
    // it uses the one assigned by AssignSafeCallExceptionHandler

    // This causes an exception that's trapped above
    LJSONRPC.SomeSafeCallException;
    LJSONRPC.SomeSafeCallException;

    LEnum := LJSONRPC.GetEnum(enumB);
    var LResult := LJSONRPC.SendData([[False, False], [False, True]]);
    LResult := LJSONRPC.SendData([[5], [6]]);
    LResult := LJSONRPC.SendData([['A'], ['B']]);

    var LIntegers := LJSONRPC.SendIntegers([1, 2, 3, 4, 5]);

    var LFixedInt: TFixedIntegers;
    LFixedInt[0] := 1; LFixedInt[1] := 1; LFixedInt[2] := 2; LFixedInt[3] := 3;
    var LFixedIntegers := LJSONRPC.SendFixedIntegers(LFixedInt);

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

    WriteLn('Program completed');
  except
    WriteLn('Program did not complete');
  end;

  // This is automatically released, so your code can choose not to nil
  // it
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
