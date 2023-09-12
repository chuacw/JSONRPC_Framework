program JSONRPC.ClientProj;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  JSONRPC.RIO in '..\Common\JSONRPC.RIO.pas',
  System.Classes,
  System.Rtti,
  System.JSON,
  System.SysUtils,
  JSONRPCMethodsBase in 'JSONRPCMethodsBase.pas',
  JSONRPC.Common.Consts in '..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.InvokeRegistry in '..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.User.SomeTypes in '..\Common\JSONRPC.User.SomeTypes.pas',
  JSONRPC.Common.Types in '..\Common\JSONRPC.Common.Types.pas';

//type
//
//{$METHODINFO ON}
//  SomeJSONRPC = interface(IJSONRPCMethods)
//    ['{BDA67613-BA2E-415A-9C4E-DE5BD519C05E}']
//    procedure CallSomeMethod;
//    function CallSomeRoutine: Boolean;
//    function AddSomeXY(X, Y: Integer): Integer;
//    function GetSomeDate(const ADateTime: TDateTime): TDateTime;
//  end;

function GetSomeJSONRPC(const ServerURL: string = ''): ISomeJSONRPC;
begin
  RegisterJSONRPCWrapper(TypeInfo(ISomeJSONRPC));
  var LJSONRPCWrapper := TJSONRPCWrapper.Create(nil);

//  // OnSync is typically not used, unless you're testing something,
//  // in this case, just copy the request into the response
//  LJSONRPCWrapper.OnSync := procedure (ARequest, AResponse: TStream)
//  begin
//    AResponse.CopyFrom(ARequest);
//  end;
//
//  // Do anything to the JSON response stream, before parsing starts...
//  // Since there's no server, write response data into the server response, so that it can be parsed
//
//  LJSONRPCWrapper.OnBeforeParse := procedure (const AContext: TInvContext;
//    AMethNum: Integer; const AMethMD: TIntfMethEntry; const AMethodID: Int64;
//    AJSONResponse: TStream)
//  begin
//    if (AJSONResponse.Size <> 0) and (AMethMD.Name = 'AddSomeXY') then
//      begin
//        AJSONResponse.Position := 0;
//
//        var LBytes: TArray<Byte>;
//        SetLength(LBytes, AJSONResponse.Size);
//        AJSONResponse.Read(LBytes[0], AJSONResponse.Size);
////        var LJSONResponseStr := TEncoding.UTF8.GetString(LBytes);
//
//// THIS BUG WILL KILL / HANG THE DEBUGGER, on exit of this method
////       var LJSONResponseStr := '';
////       AJSONResponse.Read(LJSONResponseStr, AJSONResponse.Size);
//
//        var LJSONObj := TJSONObject.ParseJSONValue(LBytes, 0);
//        try
//          var LX: Integer := LJSONObj.GetValue<Integer>('params.X');
//          var LY: Integer := LJSONObj.GetValue<Integer>('params.Y');
//          var LValue: TValue := LX + LY;
//          AJSONResponse.Size := 0;
//          WriteJSONResult(AContext, AMethNum, AMethMD, AMethodID, LValue, AJSONResponse);
//        finally
//          LJSONObj.Free;
//        end;
//      end;
//  end;

  LJSONRPCWrapper.ServerURL := ServerURL;
  Result := LJSONRPCWrapper as ISomeJSONRPC;
end;

procedure Main;
begin
  var LJSONRPC := GetSomeJSONRPC
  ('http://localhost:8083')
  ;
  try
    var LResultInt := LJSONRPC.AddSomeXY(5, 6);
    Writeln(LResultInt);
    var LResultFloat := LJSONRPC.AddDoubles(1.0, 2.1);
    Writeln(LResultFloat);
    LJSONRPC.CallSomeMethod;
  except
  end;
  LJSONRPC := nil;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  Main;
end.
