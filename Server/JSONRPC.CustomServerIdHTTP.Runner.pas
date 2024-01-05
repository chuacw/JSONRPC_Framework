unit JSONRPC.CustomServerIdHTTP.Runner;

interface

uses
  IdHTTPServer, IdCustomHTTPServer, System.Classes, IdContext,
  JSONRPC.Common.Types, JSONRPC.RIO, JSONRPC.ServerBase.Runner;

type

  TCustomJSONRPCServerIdHTTPRunner = class abstract(TCustomJSONRPCServerRunner,
    IJSONRPCDispatch, IJSONRPCGetSetDispatchEvents, IJSONRPCDispatchEvents
  )
  protected
    FServer: TIdHTTPServer;

    function GetActive: Boolean; override;
    procedure SetActive(const Value: Boolean); override;

    procedure CreateServer; override;
    procedure FreeServer; override;
    procedure SetHttpServer(const AServer: TIdHTTPServer);

    procedure ReadStream(AContext: TIdContext; AStream: TStream);
    procedure IncomingDataExecute(AContext: TIdContext);
    procedure HandlePostGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
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

    destructor Destroy; override;

    function CheckPort(const APort: Integer): Integer; override;
    function CheckPort(const APort: string): Integer; override;

    procedure StartServer(const APort: Integer = 0); override;
    procedure StopServer; override;

    property Active: Boolean read GetActive write SetActive;
    property Port: Integer read GetPort write SetPort;
    property Server: TIdHTTPServer read FServer write SetHttpServer;
  end;

implementation

uses
  IdStack, IPPeerAPI, IPPeerServer, System.SysUtils, JSONRPC.Common.Consts;

{ TCustomJSONRPCServerIdHTTPRunner }

function TCustomJSONRPCServerIdHTTPRunner.BindPort(APort: Integer): Boolean;
var
  LTestServer: IIPTestServer;
begin
  Result := True;
  try
    LTestServer := PeerFactory.CreatePeer('', IIPTestServer) as IIPTestServer;
    LTestServer.TestOpenPort(APort, nil);
  except
    Result := False;
  end;
end;

function TCustomJSONRPCServerIdHTTPRunner.CheckPort(const APort: Integer): Integer;
begin
  if BindPort(APort) then
    Result := APort
  else
    Result := 0;
end;

function TCustomJSONRPCServerIdHTTPRunner.CheckPort(const APort: string): Integer;
begin
  Result := CheckPort(APort.ToInteger);
end;

destructor TCustomJSONRPCServerIdHTTPRunner.Destroy;
begin
  if Assigned(FServer) then
    FServer.Active := False;
  inherited;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.CreateServer;
begin
  CreateServerWrapper;

  if not Assigned(FServer) then
    Server := TIdHTTPServer.Create(nil);
end;

procedure TCustomJSONRPCServerIdHTTPRunner.FreeServer;
begin
  if Assigned(FServer) then
    FServer.StopListening;
  FreeAndNil(FServer);

  FreeServerWrapper;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.SetHttpServer(const AServer: TIdHTTPServer);
begin
  if FServer <> AServer then
    FServer.Free;
  FServer := AServer;
  FServer.OnCommandGet := HandlePostGet;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.DoNotifyPortSet;
begin
  if Assigned(FOnNotifyPortSet) then
    FOnNotifyPortSet(FServer.DefaultPort);
end;

function TCustomJSONRPCServerIdHTTPRunner.GetActive: Boolean;
begin
  Result := FServer.Active;
end;

function TCustomJSONRPCServerIdHTTPRunner.GetAddress: string;
begin
  Result := '';
end;

function TCustomJSONRPCServerIdHTTPRunner.GetHost: string;
begin
  Result := '';
end;

function TCustomJSONRPCServerIdHTTPRunner.GetPort: Integer;
begin
  Result := FServer.DefaultPort;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.HandlePostGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  ARequestInfo.PostStream.Position := 0;
  FResponse.Size := 0;
  AResponseInfo.ContentStream := FResponse;
  AResponseInfo.FreeContentStream := False;
  Dispatcher.DispatchJSONRPC(ARequestInfo.PostStream, AResponseInfo.ContentStream);
  FResponse.Position := 0;
  AResponseInfo.ContentType := SApplicationJson;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.IncomingDataExecute(AContext: TIdContext);
begin
  FRequest.Size := 0;
  FResponse.Size := 0;

  AContext.Connection.IOHandler.ReadTimeout := 50;

  ReadStream(AContext, FRequest);

  Dispatcher.DispatchJSONRPC(FRequest, FResponse);
  AContext.Connection.IOHandler.Write(FResponse);
end;

procedure TCustomJSONRPCServerIdHTTPRunner.ReadStream(AContext: TIdContext; AStream: TStream);
begin
  try
    AContext.Connection.IOHandler.ReadStream(AStream);
    AStream.Position := 0;
  except
  end;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.SetActive(const Value: Boolean);
begin
  FServer.Active := Value;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.SetAddress(const Value: string);
begin
  var LIP := GStack.ResolveHost(Value);
  if FServer.Bindings.Count = 0 then
    begin
      FServer.Bindings.Add;
    end;
  FServer.Bindings[0].IP := LIP;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.SetHost(const Value: string);
begin
  var LIP := GStack.ResolveHost(Value);
  if FServer.Bindings.Count = 0 then
    begin
      FServer.Bindings.Add;
    end;
  FServer.Bindings[0].IP := LIP;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.SetPort(const APort: Integer);
begin
  if not FServer.Active then
    begin
      if CheckPort(APort) > 0 then
        begin
          FServer.DefaultPort := APort;
          DoNotifyPortSet;
        end else
        begin
          DoNotifyPortInUse(APort);
        end;
    end
end;

procedure TCustomJSONRPCServerIdHTTPRunner.StartServer(const APort: Integer = 0);
var
  LPort: Integer;
begin
  if APort <> 0 then
    LPort := APort else
    LPort := FServer.DefaultPort;
  if not FServer.Active then
    begin
      if CheckPort(LPort) > 0 then
      begin
        FServer.Bindings[0].Port := LPort;
        FServer.Active := True;
        DoNotifyServerIsActive;
      end else
      begin
        DoNotifyPortInUse(LPort);
      end;
    end else
    begin
      DoNotifyServerIsAlreadyRunning;
    end;
end;

procedure TCustomJSONRPCServerIdHTTPRunner.StopServer;
begin
  FServer.Active := False;
  DoNotifyServerIsInactive;
end;

end.



































// chuacw, Jun 2023

