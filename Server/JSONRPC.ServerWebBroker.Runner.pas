unit JSONRPC.ServerWebBroker.Runner;

interface

uses
  IdHTTPWebBrokerBridge;

type
  TIdHTTPWebBrokerBridge = IdHTTPWebBrokerBridge.TIdHTTPWebBrokerBridge;

  TJSONRPCServerWebBrokerRunner = class
  public
  type
    TProcNotifyPortSet = reference to procedure(const APort: Integer);
    TProcNotifyPortInUse = reference to procedure(const APort: Integer);
    TProcNotifyServerIsAlreadyRunning = reference to procedure(const AServer: TJSONRPCServerWebBrokerRunner);
    TProcNotifyServerIsActive = reference to procedure(const AServer: TJSONRPCServerWebBrokerRunner);
    TProcNotifyServerIsInactive = reference to procedure(const AServer: TJSONRPCServerWebBrokerRunner);
  private
    function GetActive: Boolean; inline;
    procedure SetActive(const Value: Boolean); inline;
  protected
    FServer: TIdHTTPWebBrokerBridge;
    FOnNotifyPortSet: TProcNotifyPortSet;
    FOnNotifyPortInUse: TProcNotifyPortInUse;
    FOnNotifyServerIsAlreadyRunning: TProcNotifyServerIsAlreadyRunning;
    FOnNotifyServerIsActive: TProcNotifyServerIsActive;
    FOnNotifyServerIsInactive: TProcNotifyServerIsInactive;

    function BindPort(APort: Integer): Boolean;

    function GetPort: Integer;
    procedure SetPort(const APort: Integer);

    procedure DoNotifyPortSet;
    procedure DoNotifyPortInUse(const APort: Integer);
    procedure DoNotifyServerIsActive;
    procedure DoNotifyServerIsInactive;
    procedure DoNotifyServerIsAlreadyRunning;

  public

    constructor Create;
    destructor Destroy; override;

    function CheckPort(const APort: Integer): Integer; overload;
    function CheckPort(const APort: string): Integer; overload;

    procedure StartServer(const APort: Integer = 0);
    procedure StopServer;

    property OnNotifyPortSet: TProcNotifyPortSet read FOnNotifyPortSet write
      FOnNotifyPortSet;
    property OnNotifyPortInUse: TProcNotifyPortInUse read FOnNotifyPortInUse write
      FOnNotifyPortInUse;
    property OnNotifyServerIsActive: TProcNotifyServerIsActive read
      FOnNotifyServerIsActive write FOnNotifyServerIsActive;
    property OnNotifyServerIsInactive: TProcNotifyServerIsInactive read
      FOnNotifyServerIsInactive write FOnNotifyServerIsInactive;
    property OnNotifyServerIsAlreadyRunning: TProcNotifyServerIsAlreadyRunning read
      FOnNotifyServerIsAlreadyRunning write FOnNotifyServerIsAlreadyRunning;

    property Active: Boolean read GetActive write SetActive;
    property Port: Integer read GetPort write SetPort;
    property Server: TIdHTTPWebBrokerBridge read FServer;
  end;

implementation

uses
  IPPeerAPI, System.SysUtils;

{ TJSONRPCServerWebBrokerRunner }

function TJSONRPCServerWebBrokerRunner.BindPort(APort: Integer): Boolean;
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

function TJSONRPCServerWebBrokerRunner.CheckPort(const APort: Integer): Integer;
begin
  if BindPort(APort) then
    Result := APort
  else
    Result := 0;
end;

function TJSONRPCServerWebBrokerRunner.CheckPort(const APort: string): Integer;
begin
  Result := CheckPort(APort.ToInteger);
end;

constructor TJSONRPCServerWebBrokerRunner.Create;
begin
  inherited Create;
  FServer := TIdHTTPWebBrokerBridge.Create(nil);
end;

destructor TJSONRPCServerWebBrokerRunner.Destroy;
begin
  FServer.StopListening;
  FServer.Free;
  inherited;
end;

procedure TJSONRPCServerWebBrokerRunner.DoNotifyPortInUse(const APort: Integer);
begin
  if Assigned(FOnNotifyPortInUse) then
    FOnNotifyPortInUse(APort);
end;

procedure TJSONRPCServerWebBrokerRunner.DoNotifyPortSet;
begin
  if Assigned(FOnNotifyPortSet) then
    FOnNotifyPortSet(FServer.DefaultPort);
end;

procedure TJSONRPCServerWebBrokerRunner.DoNotifyServerIsActive;
begin
  if Assigned(FOnNotifyServerIsActive) then
    FOnNotifyServerIsActive(Self);
end;

procedure TJSONRPCServerWebBrokerRunner.DoNotifyServerIsAlreadyRunning;
begin
  if Assigned(FOnNotifyServerIsAlreadyRunning) then
    FOnNotifyServerIsAlreadyRunning(Self);
end;

procedure TJSONRPCServerWebBrokerRunner.DoNotifyServerIsInactive;
begin
  if Assigned(FOnNotifyServerIsInactive) then
    FOnNotifyServerIsInactive(Self);
end;

function TJSONRPCServerWebBrokerRunner.GetActive: Boolean;
begin
  Result := FServer.Active;
end;

function TJSONRPCServerWebBrokerRunner.GetPort: Integer;
begin
  Result := FServer.DefaultPort;
end;

procedure TJSONRPCServerWebBrokerRunner.SetActive(const Value: Boolean);
begin
  FServer.Active := Value;
end;

procedure TJSONRPCServerWebBrokerRunner.SetPort(const APort: Integer);
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

procedure TJSONRPCServerWebBrokerRunner.StartServer(const APort: Integer = 0);
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
        FServer.Bindings.Clear;
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

procedure TJSONRPCServerWebBrokerRunner.StopServer;
begin
  FServer.Active := False;
  DoNotifyServerIsInactive;
end;

end.
