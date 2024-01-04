unit JSONRPC.ServerBase.Runner;

interface

uses
  IdHTTPServer, IdCustomHTTPServer, System.Classes, IdContext,
  JSONRPC.Common.Types, JSONRPC.RIO;

type

  TCustomJSONRPCServerRunner = class abstract(TInterfacedObject, IJSONRPCDispatch,
    IJSONRPCGetSetDispatchEvents, IJSONRPCDispatchEvents)
  public
  type
    TProcNotifyPortSet = reference to procedure(const APort: Integer);
    TProcNotifyPortInUse = reference to procedure(const APort: Integer);
    TProcNotifyServerIsAlreadyRunning = reference to procedure(const AServer: TCustomJSONRPCServerRunner);
    TProcNotifyServerIsActive = reference to procedure(const AServer: TCustomJSONRPCServerRunner);
    TProcNotifyServerIsInactive = reference to procedure(const AServer: TCustomJSONRPCServerRunner);
  protected
    function GetGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
    function GetJSONRPCDispatch: IJSONRPCDispatch;
    function GetJSONRPCDispatchEvents: IJSONRPCDispatchEvents;
    function GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    function GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
    function GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;

    procedure SetOnDispatchedJSONRPC(const Value: TOnDispatchedJSONRPC);
    procedure SetOnLogIncomingJSONRequest(const Value: TOnLogIncomingJSONRequest);
    procedure SetOnLogOutgoingJSONResponse(const Value: TOnLogOutgoingJSONResponse);

  protected
    FRequest: TStream;
    FResponse: TStream;
    FServerWrapper: TJSONRPCServerWrapper;

    FOnNotifyPortSet: TProcNotifyPortSet;
    FOnNotifyPortInUse: TProcNotifyPortInUse;
    FOnNotifyServerIsAlreadyRunning: TProcNotifyServerIsAlreadyRunning;
    FOnNotifyServerIsActive: TProcNotifyServerIsActive;
    FOnNotifyServerIsInactive: TProcNotifyServerIsInactive;

    function GetAddress: string; virtual; abstract;
    function GetHost: string; virtual; abstract;
    procedure SetAddress(const Value: string); virtual; abstract;
    procedure SetHost(const Value: string); virtual; abstract;

    function GetActive: Boolean; virtual; abstract;
    procedure SetActive(const Value: Boolean); virtual; abstract;

    procedure CreateServerWrapper; virtual; abstract;
    procedure FreeServerWrapper; virtual; abstract;

    procedure CreateServer; virtual; abstract;
    procedure FreeServer; virtual; abstract;

    procedure ReadStream(AContext: TIdContext; AStream: TStream);
    procedure IncomingDataExecute(AContext: TIdContext);
    procedure HandlePostGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    function BindPort(APort: Integer): Boolean; virtual; abstract;

    function GetPort: Integer; virtual; abstract;
    procedure SetPort(const APort: Integer); virtual; abstract;

    procedure DoNotifyPortSet; virtual; abstract;
    procedure DoNotifyPortInUse(const APort: Integer); virtual;
    procedure DoNotifyServerIsActive; virtual;
    procedure DoNotifyServerIsInactive; virtual;
    procedure DoNotifyServerIsAlreadyRunning; virtual;

    property Dispatcher: IJSONRPCDispatch read GetJSONRPCDispatch implements IJSONRPCDispatch;
    property JSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents
      read GetGetSetDispatchEvents implements IJSONRPCGetSetDispatchEvents;
    property JSONRPCDispatchEvents: IJSONRPCDispatchEvents
      read GetJSONRPCDispatchEvents implements IJSONRPCDispatchEvents;
  public

    constructor Create;
    destructor Destroy; override;

    function CheckPort(const APort: Integer): Integer; overload; virtual; abstract;
    function CheckPort(const APort: string): Integer; overload; virtual; abstract;

    procedure StartServer(const APort: Integer = 0); virtual; abstract;
    procedure StopServer; virtual; abstract;

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

    property OnDispatchedJSONRPC: TOnDispatchedJSONRPC read GetOnDispatchedJSONRPC
      write SetOnDispatchedJSONRPC;
    property OnLogIncomingJSONRequest: TOnLogIncomingJSONRequest
      read GetOnLogIncomingJSONRequest write SetOnLogIncomingJSONRequest;
    property OnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse
      read GetOnLogOutgoingJSONResponse write SetOnLogOutgoingJSONResponse;

    property Active: Boolean read GetActive write SetActive;
    property Address: string read GetAddress write SetAddress;
    property Host: string read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;

  end;

implementation

uses
  IPPeerAPI, System.SysUtils, JSONRPC.Common.Consts;

{ TCustomJSONRPCServerRunner }

//function TCustomJSONRPCServerRunner.BindPort(APort: Integer): Boolean;
//var
//  LTestServer: IIPTestServer;
//begin
//  Result := True;
//  try
//    LTestServer := PeerFactory.CreatePeer('', IIPTestServer) as IIPTestServer;
//    LTestServer.TestOpenPort(APort, nil);
//  except
//    Result := False;
//  end;
//end;

//function TCustomJSONRPCServerRunner.CheckPort(const APort: Integer): Integer;
//begin
//  if BindPort(APort) then
//    Result := APort
//  else
//    Result := 0;
//end;
//
//function TCustomJSONRPCServerRunner.CheckPort(const APort: string): Integer;
//begin
//  Result := CheckPort(APort.ToInteger);
//end;

constructor TCustomJSONRPCServerRunner.Create;
begin
  inherited Create;
  FRequest := TMemoryStream.Create;
  FResponse := TMemoryStream.Create;
  CreateServer;
end;

destructor TCustomJSONRPCServerRunner.Destroy;
begin
  FreeServer;

  FResponse.Free;
  FRequest.Free;
  inherited;
end;

procedure TCustomJSONRPCServerRunner.DoNotifyPortInUse(const APort: Integer);
begin
  if Assigned(FOnNotifyPortInUse) then
    FOnNotifyPortInUse(APort);
end;

//procedure TCustomJSONRPCServerRunner.DoNotifyPortSet;
//begin
//  if Assigned(FOnNotifyPortSet) then
//    FOnNotifyPortSet(FServerWrapper.);
//end;

procedure TCustomJSONRPCServerRunner.DoNotifyServerIsActive;
begin
  if Assigned(FOnNotifyServerIsActive) then
    FOnNotifyServerIsActive(Self);
end;

procedure TCustomJSONRPCServerRunner.DoNotifyServerIsAlreadyRunning;
begin
  if Assigned(FOnNotifyServerIsAlreadyRunning) then
    FOnNotifyServerIsAlreadyRunning(Self);
end;

procedure TCustomJSONRPCServerRunner.DoNotifyServerIsInactive;
begin
  if Assigned(FOnNotifyServerIsInactive) then
    FOnNotifyServerIsInactive(Self);
end;

//function TCustomJSONRPCServerRunner.GetActive: Boolean;
//begin
//  Result := FServer.Active;
//end;

function TCustomJSONRPCServerRunner.GetGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  Result := FServerWrapper as IJSONRPCGetSetDispatchEvents;
end;

function TCustomJSONRPCServerRunner.GetJSONRPCDispatch: IJSONRPCDispatch;
begin
  Result := FServerWrapper as IJSONRPCDispatch;
end;

function TCustomJSONRPCServerRunner.GetJSONRPCDispatchEvents: IJSONRPCDispatchEvents;
begin
  Result := FServerWrapper as IJSONRPCDispatchEvents;
end;

function TCustomJSONRPCServerRunner.GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
begin
  Result := FServerWrapper.OnDispatchedJSONRPC;
end;

function TCustomJSONRPCServerRunner.GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
begin
  Result := FServerWrapper.OnLogIncomingJSONRequest;
end;

function TCustomJSONRPCServerRunner.GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
begin
  Result := FServerWrapper.OnLogOutgoingJSONResponse;
end;

//function TCustomJSONRPCServerRunner.GetPort: Integer;
//begin
//  Result := FServer.DefaultPort;
//end;

procedure TCustomJSONRPCServerRunner.HandlePostGet(AContext: TIdContext;
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

procedure TCustomJSONRPCServerRunner.IncomingDataExecute(AContext: TIdContext);
begin
  FRequest.Size := 0;
  FResponse.Size := 0;

  AContext.Connection.IOHandler.ReadTimeout := 50;

  ReadStream(AContext, FRequest);

  Dispatcher.DispatchJSONRPC(FRequest, FResponse);
  AContext.Connection.IOHandler.Write(FResponse);
end;

procedure TCustomJSONRPCServerRunner.ReadStream(AContext: TIdContext; AStream: TStream);
begin
  try
    AContext.Connection.IOHandler.ReadStream(AStream);
    AStream.Position := 0;
  except
  end;
end;

procedure TCustomJSONRPCServerRunner.SetOnDispatchedJSONRPC(
  const Value: TOnDispatchedJSONRPC);
begin
  FServerWrapper.OnDispatchedJSONRPC := Value;
end;

procedure TCustomJSONRPCServerRunner.SetOnLogIncomingJSONRequest(
  const Value: TOnLogIncomingJSONRequest);
begin
  FServerWrapper.OnLogIncomingJSONRequest := Value;
end;

procedure TCustomJSONRPCServerRunner.SetOnLogOutgoingJSONResponse(
  const Value: TOnLogOutgoingJSONResponse);
begin
  FServerWrapper.OnLogOutgoingJSONResponse := Value;
end;

//procedure TCustomJSONRPCServerRunner.SetActive(const Value: Boolean);
//begin
//  FServer.Active := Value;
//end;

//procedure TCustomJSONRPCServerRunner.SetPort(const APort: Integer);
//begin
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
//    end
//end;

//procedure TCustomJSONRPCServerRunner.StartServer(const APort: Integer = 0);
//var
//  LPort: Integer;
//begin
//  if APort <> 0 then
//    LPort := APort else
//    LPort := FServer.DefaultPort;
//  if not FServer.Active then
//    begin
//      if CheckPort(LPort) > 0 then
//      begin
//        FServer.Bindings.Clear;
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
//end;

//procedure TCustomJSONRPCServerRunner.StopServer;
//begin
//  FServer.Active := False;
//  DoNotifyServerIsInactive;
//end;

end.
