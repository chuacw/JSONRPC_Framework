unit JSONRPC.ServerNetHTTP.Runner;

interface

uses
  System.Classes,
  JSONRPC.Common.Types, JSONRPC.RIO, JSONRPC.ServerBase.Runner,
  System.Net.ServerSocket;

type

  TJSONRPCServerIdHTTPRunner = class(TJSONRPCServerRunner, IJSONRPCDispatch,
    IJSONRPCGetSetDispatchEvents, IJSONRPCDispatchEvents)
  protected
    FServer: TServerSocket;

    function GetActive: Boolean; override;
    procedure SetActive(const Value: Boolean); override;

    procedure CreateServer; override;
    procedure FreeServer; override;

//    procedure ReadStream(AContext: TIdContext; AStream: TStream);
//    procedure IncomingDataExecute(AContext: TIdContext);
//    procedure HandlePostGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
//      AResponseInfo: TIdHTTPResponseInfo);
    function BindPort(APort: Integer): Boolean; override;

    function GetAddress: string; override;
    function GetHost: string; override;
    procedure SetAddress(const Value: string); override;
    procedure SetHost(const Value: string); override;
    function GetPort: Integer; override;
    procedure SetPort(const APort: Integer); override;

    procedure DoNotifyPortSet; override;

    property Dispatcher: IJSONRPCDispatch read GetJSONRPCDispatch implements IJSONRPCDispatch;
    property JSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents
      read GetGetSetDispatchEvents implements IJSONRPCGetSetDispatchEvents;
    property JSONRPCDispatchEvents: IJSONRPCDispatchEvents
      read GetJSONRPCDispatchEvents implements IJSONRPCDispatchEvents;

  public

    function CheckPort(const APort: Integer): Integer; override;
    function CheckPort(const APort: string): Integer; override;

    procedure StartServer(const APort: Integer = 0); override;
    procedure StopServer; override;

    property Active: Boolean read GetActive write SetActive;
    property Port: Integer read GetPort write SetPort;
//    property Server: TIdHTTPServer read FServer;
  end;

implementation

uses
  System.SysUtils, JSONRPC.Common.Consts, System.Net.Socket;

{ TJSONRPCServerIdHTTPRunner }

function TJSONRPCServerIdHTTPRunner.BindPort(APort: Integer): Boolean;
//var
//  LTestServer: IIPTestServer;
begin
//  Result := True;
//  try
//    LTestServer := PeerFactory.CreatePeer('', IIPTestServer) as IIPTestServer;
//    LTestServer.TestOpenPort(APort, nil);
//  except
//    Result := False;
//  end;
end;

function TJSONRPCServerIdHTTPRunner.CheckPort(const APort: Integer): Integer;
begin
  if BindPort(APort) then
    Result := APort
  else
    Result := 0;
end;

function TJSONRPCServerIdHTTPRunner.CheckPort(const APort: string): Integer;
begin
  Result := CheckPort(APort.ToInteger);
end;

procedure TJSONRPCServerIdHTTPRunner.CreateServer;
begin
  FServerWrapper := TJSONRPCServerWrapper.Create(nil);

//  if not Assigned(FServer) then
//    FServer := TIdHTTPServer.Create(nil);
//  FServer.OnCommandGet := HandlePostGet;
  FServer := TServerSocket.Create(
    function (AServerSocket: TServerSocket; ASocket: System.Net.Socket.TSocket): TProc
    begin
      Result := procedure
      begin

      end;
    end
  );
end;

procedure TJSONRPCServerIdHTTPRunner.FreeServer;
begin
  if Assigned(FServer) then
    FServer.StopListening;
  FreeAndNil(FServer);

  FServerWrapper.Free;
end;

procedure TJSONRPCServerIdHTTPRunner.DoNotifyPortSet;
begin
//  if Assigned(FOnNotifyPortSet) then
//    FOnNotifyPortSet(FServer.DefaultPort);
end;

function TJSONRPCServerIdHTTPRunner.GetActive: Boolean;
begin
//  Result := FServer.Active;
end;

function TJSONRPCServerIdHTTPRunner.GetAddress: string;
begin
  Result := '';
end;

function TJSONRPCServerIdHTTPRunner.GetHost: string;
begin
  Result := '';
end;

function TJSONRPCServerIdHTTPRunner.GetPort: Integer;
begin
//  Result := FServer.DefaultPort;
end;

//procedure TJSONRPCServerIdHTTPRunner.HandlePostGet(AContext: TIdContext;
//  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
//begin
//  ARequestInfo.PostStream.Position := 0;
//  FResponse.Size := 0;
//  AResponseInfo.ContentStream := FResponse;
//  AResponseInfo.FreeContentStream := False;
//  Dispatcher.DispatchJSONRPC(ARequestInfo.PostStream, AResponseInfo.ContentStream);
//  FResponse.Position := 0;
//  AResponseInfo.ContentType := SApplicationJson;
//end;
//
//procedure TJSONRPCServerIdHTTPRunner.IncomingDataExecute(AContext: TIdContext);
//begin
//  FRequest.Size := 0;
//  FResponse.Size := 0;
//
//  AContext.Connection.IOHandler.ReadTimeout := 50;
//
//  ReadStream(AContext, FRequest);
//
//  Dispatcher.DispatchJSONRPC(FRequest, FResponse);
//  AContext.Connection.IOHandler.Write(FResponse);
//end;
//
//procedure TJSONRPCServerIdHTTPRunner.ReadStream(AContext: TIdContext; AStream: TStream);
//begin
//  try
//    AContext.Connection.IOHandler.ReadStream(AStream);
//    AStream.Position := 0;
//  except
//  end;
//end;

procedure TJSONRPCServerIdHTTPRunner.SetActive(const Value: Boolean);
begin
//  FServer.Active := Value;
end;

procedure TJSONRPCServerIdHTTPRunner.SetAddress(const Value: string);
begin
//  var LIP := GStack.ResolveHost(Value);
//  if FServer.Bindings.Count = 0 then
//    begin
//      FServer.Bindings.Add;
//    end;
//  FServer.Bindings[0].IP := LIP;
end;

procedure TJSONRPCServerIdHTTPRunner.SetHost(const Value: string);
begin
//  var LIP := GStack.ResolveHost(Value);
//  if FServer.Bindings.Count = 0 then
//    begin
//      FServer.Bindings.Add;
//    end;
//  FServer.Bindings[0].IP := LIP;
end;

procedure TJSONRPCServerIdHTTPRunner.SetPort(const APort: Integer);
begin
//  if not FServer.Active then
//    begin
//      if CheckPort(APort) > 0 then
//        begin
//          FServer.DefaultPort := APort;
//          DoNotifyPortSet;
//        end else
//        begin
//          DoNotifyPortInUse(APort);
//        end;
//    end;
end;

procedure TJSONRPCServerIdHTTPRunner.StartServer(const APort: Integer = 0);
var
  LPort: Integer;
begin
//  if APort <> 0 then
//    LPort := APort else
//    LPort := FServer.DefaultPort;
//  if not FServer.Active then
//    begin
//      if CheckPort(LPort) > 0 then
//      begin
//        FServer.Bindings[0].Port := LPort;
//        FServer.Active := True;
//        DoNotifyServerIsActive;
//      end else
//      begin
//        DoNotifyPortInUse(LPort);
//      end;
//    end else
//    begin
//      DoNotifyServerIsAlreadyRunning;
//    end;
end;

procedure TJSONRPCServerIdHTTPRunner.StopServer;
begin
//  FServer.Active := False;
  DoNotifyServerIsInactive;
end;

end.
