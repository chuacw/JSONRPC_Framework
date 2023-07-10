program TestProj1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  TestProj1.JSONRPCRIOImpl in 'TestProj1.JSONRPCRIOImpl.pas',
  System.Classes,	System.Rtti, System.JSON, System.SysUtils,
  JSONRPCMethodsBase in 'JSONRPCMethodsBase.pas';

type

{$METHODINFO ON}
  SomeJSONRPC = interface(IJSONRPCMethods)
    ['{BDA67613-BA2E-415A-9C4E-DE5BD519C05E}']
    procedure CallSomeMethod;
    function CallSomeRoutine: boolean;
    function AddSomeXY(X, Y: Integer): Integer;
  end;

function GetSomeJSONRPC(const ServerURL: string = ''): SomeJSONRPC;
begin
  RegisterJSONRPCWrapper(TypeInfo(SomeJSONRPC));
  var LJSONRPCWrapper := TJSONRPCWrapper.Create(nil);

  // OnSync is typically not used, unless you're testing something,
  // in this case, just copy the request into the response
  LJSONRPCWrapper.OnSync := procedure (ARequest, AResponse: TStream)
  begin
    AResponse.CopyFrom(ARequest);
  end;

// Do anything to the JSON response stream, before parsing starts...
// Since there's no server, write response data into the server response, so that it can be parsed

  LJSONRPCWrapper.OnBeforeParse := procedure (const AContext: TInvContext; 
    AMethNum: Integer; const AMethMD: TIntfMethEntry; const AMethodID: Int64;
    AJSONResponse: TStream)
  begin
    if (AJSONResponse.Size <> 0) and (AMethMD.Name = 'AddSomeXY') then
      begin
        var LBytes: TBytes;
        AJSONResponse.Position := 0;
        SetLength(LBytes, AJSONResponse.Size);
        AJSONResponse.Read(LBytes[0], AJSONResponse.Size);
        var LJSONResponseStr := TEncoding.UTF8.GetString(LBytes);
        var LJSONObj := TJSONObject.ParseJSONValue(LJSONResponseStr);
        try
          var LX: Integer := LJSONObj.GetValue<Integer>('params.X');
          var LY: Integer := LJSONObj.GetValue<Integer>('params.Y');
          var LValue: TValue := LX + LY;
          AJSONResponse.Size := 0;
          WriteJSONResult(AContext, AMethNum, AMethMD, AMethodID, LValue, AJSONResponse);
        finally
          LJSONObj.Free;
        end;
      end;
  end;
  
  LJSONRPCWrapper.ServerURL := ServerURL;
  Result := LJSONRPCWrapper as SomeJSONRPC;
end;

procedure Main;
begin
  var LJSONRPC := GetSomeJSONRPC;
  var LAdditionResult := LJSONRPC.AddSomeXY(5, 6);
  LJSONRPC := nil;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  Main;
end.
