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
  System.Net.Socket.Common in '..\..\NetSocket\Common\System.Net.Socket.Common.pas';

{$MESSAGE WARN 'Works with ServerBroker, not ServerIndy yet'}

type
{$M+}
{$RTTI FIELDS([vcPrivate, vcProtected, vcPublic, vcPublished])
       PROPERTIES([vcPrivate, vcProtected, vcPublic, vcPublished])}
  TFoo = record
    FBar: Integer;
    property Bar: Integer read FBar;
  end;

procedure Main;
type
  TMyArray = TArray<Integer>;
var
  LClientSocket: TClientSocket;
  LEndpoint: TNetEndpoint;
  LID: Integer; LText: string;
  LBuffer: TBytes;
  ctx: TRttiContext;
begin
//  LClientSocket := TClientSocket.Create;
//  LEndpoint.Port := 8083;
//  LEndpoint.SetAddress('localhost');
//  LEndpoint.Family := AF_INET;
//  try
//    LClientSocket.Connect(LEndpoint);  // this can throw an exception
//
//    LID := 0;
//    for var I := 1 to 10 do
//      begin
//        Inc(LID);
//        LText :=  Format(
//        '''
//        {"jsonrpc": 2.0, "method": "GetSomeDate", "params": {"ADateTime":"%s"}, "id": %d}
//        '''
//        , [DateToISO8601(Now), LID]);
//        LBuffer := BytesOf(LText);
//        WriteLn('Sending...');
//        WriteLn(LText);
//
//        LClientSocket.Send(LBuffer);
//        LBuffer := nil;
//
//        LClientSocket.Receive(LBuffer);
//        if Length(LBuffer) <> 0 then
//          begin
//            WriteLn('Received...');
//            var LReceivedString := StringOf(LBuffer);
//            WriteLn(LReceivedString);
//          end;
//        WriteLn(StringOfChar('-', 100));
//      end;
//  except
//  end;
  var LJSONRPC := GetSomeJSONRPC
  ('http://localhost:8083', twtHTTP)
  ;
  try
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
