unit JSONRPC.ServerBase.Runner;

interface

uses
  IdHTTPServer, IdCustomHTTPServer, System.Classes, IdContext,
  JSONRPC.Common.Types, JSONRPC.RIO;

type

  TJSONRPCServerRunner = class(TInterfacedObject, IJSONRPCDispatch,
    IJSONRPCGetSetDispatchEvents, IJSONRPCDispatchEvents)
  public
  type
    TProcNotifyPortSet = reference to procedure(const APort: Integer);
    TProcNotifyPortInUse = reference to procedure(const APort: Integer);
    TProcNotifyServerIsAlreadyRunning = reference to procedure(const AServer: TJSONRPCServerRunner);
    TProcNotifyServerIsActive = reference to procedure(const AServer: TJSONRPCServerRunner);
    TProcNotifyServerIsInactive = reference to procedure(const AServer: TJSONRPCServerRunner);
  private
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
//    FServer: TIdHTTPServer;
    FRequest: TStream;
    FResponse: TStream;
    FIntf: IInterface; // Capture interface
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

    procedure CreateServer; virtual; abstract;
    procedure FreeServer; virtual; abstract;

    procedure ReadStream(AContext: TIdContext; AStream: TStream);
    procedure IncomingDataExecute(AContext: TIdContext);
    procedure HandlePostGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    function BindPort(APort: Integer): Boolean; virtual; abstract;

    function GetPort: Integer; virtual; abstract;
    procedure SetPort(const APort: Integer); virtual; abstract;

    procedure DoNotifyPortSet; virtual;
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
//    property Server: TIdHTTPServer read FServer;

  end;

implementation

uses
  IPPeerAPI, System.SysUtils, JSONRPC.Common.Consts;

{ TJSONRPCServerRunner }

//function TJSONRPCServerRunner.BindPort(APort: Integer): Boolean;
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

//function TJSONRPCServerRunner.CheckPort(const APort: Integer): Integer;
//begin
//  if BindPort(APort) then
//    Result := APort
//  else
//    Result := 0;
//end;
//
//function TJSONRPCServerRunner.CheckPort(const APort: string): Integer;
//begin
//  Result := CheckPort(APort.ToInteger);
//end;

constructor TJSONRPCServerRunner.Create;
begin
  inherited Create;
  FRequest := TMemoryStream.Create;
  FResponse := TMemoryStream.Create;
  CreateServer;
  FServerWrapper := TJSONRPCServerWrapper.Create(nil);
end;

destructor TJSONRPCServerRunner.Destroy;
begin
  FServerWrapper.Free;
  FIntf := nil;
  FreeServer;

  FResponse.Free;
  FRequest.Free;
  inherited;
end;

procedure TJSONRPCServerRunner.DoNotifyPortInUse(const APort: Integer);
begin
//  if Assigned(FOnNotifyPortInUse) then
//    FOnNotifyPortInUse(APort);
end;

procedure TJSONRPCServerRunner.DoNotifyPortSet;
begin
//  if Assigned(FOnNotifyPortSet) then
//    FOnNotifyPortSet(FServer.DefaultPort);
end;

procedure TJSONRPCServerRunner.DoNotifyServerIsActive;
begin
//  if Assigned(FOnNotifyServerIsActive) then
//    FOnNotifyServerIsActive(Self);
end;

procedure TJSONRPCServerRunner.DoNotifyServerIsAlreadyRunning;
begin
//  if Assigned(FOnNotifyServerIsAlreadyRunning) then
//    FOnNotifyServerIsAlreadyRunning(Self);
end;

procedure TJSONRPCServerRunner.DoNotifyServerIsInactive;
begin
//  if Assigned(FOnNotifyServerIsInactive) then
//    FOnNotifyServerIsInactive(Self);
end;

//function TJSONRPCServerRunner.GetActive: Boolean;
//begin
//  Result := FServer.Active;
//end;

function TJSONRPCServerRunner.GetGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  Result := FServerWrapper as IJSONRPCGetSetDispatchEvents;
end;

function TJSONRPCServerRunner.GetJSONRPCDispatch: IJSONRPCDispatch;
begin
  Result := FServerWrapper as IJSONRPCDispatch;
end;

function TJSONRPCServerRunner.GetJSONRPCDispatchEvents: IJSONRPCDispatchEvents;
begin
  Result := FServerWrapper as IJSONRPCDispatchEvents;
end;

function TJSONRPCServerRunner.GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
begin
  Result := FServerWrapper.OnDispatchedJSONRPC;
end;

function TJSONRPCServerRunner.GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
begin
  Result := FServerWrapper.OnLogIncomingJSONRequest;
end;

function TJSONRPCServerRunner.GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
begin
  Result := FServerWrapper.OnLogOutgoingJSONResponse;
end;

//function TJSONRPCServerRunner.GetPort: Integer;
//begin
//  Result := FServer.DefaultPort;
//end;

procedure TJSONRPCServerRunner.HandlePostGet(AContext: TIdContext;
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

procedure TJSONRPCServerRunner.IncomingDataExecute(AContext: TIdContext);
begin
  FRequest.Size := 0;
  FResponse.Size := 0;

  AContext.Connection.IOHandler.ReadTimeout := 50;

  ReadStream(AContext, FRequest);

  Dispatcher.DispatchJSONRPC(FRequest, FResponse);
  AContext.Connection.IOHandler.Write(FResponse);
end;

procedure TJSONRPCServerRunner.ReadStream(AContext: TIdContext; AStream: TStream);
begin
  try
    AContext.Connection.IOHandler.ReadStream(AStream);
    AStream.Position := 0;
  except
  end;
end;

procedure TJSONRPCServerRunner.SetOnDispatchedJSONRPC(
  const Value: TOnDispatchedJSONRPC);
begin
  FServerWrapper.OnDispatchedJSONRPC := Value;
end;

procedure TJSONRPCServerRunner.SetOnLogIncomingJSONRequest(
  const Value: TOnLogIncomingJSONRequest);
begin
  FServerWrapper.OnLogIncomingJSONRequest := Value;
end;

procedure TJSONRPCServerRunner.SetOnLogOutgoingJSONResponse(
  const Value: TOnLogOutgoingJSONResponse);
begin
  FServerWrapper.OnLogOutgoingJSONResponse := Value;
end;

//procedure TJSONRPCServerRunner.SetActive(const Value: Boolean);
//begin
//  FServer.Active := Value;
//end;

//procedure TJSONRPCServerRunner.SetPort(const APort: Integer);
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

//procedure TJSONRPCServerRunner.StartServer(const APort: Integer = 0);
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

//procedure TJSONRPCServerRunner.StopServer;
//begin
//  FServer.Active := False;
//  DoNotifyServerIsInactive;
//end;

end.
