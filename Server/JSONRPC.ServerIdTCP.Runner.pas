{---------------------------------------------------------------------------}
{                                                                           }
{ File:      JSONRPC.ServerIdTP.unner.pas                                   }
{ Function:  A JSON RPC custom Indy TCP server runner                       }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit JSONRPC.ServerTCP.Runner;

{$ALIGN 16}
{$CODEALIGN 16}

interface

uses
//  IdHTTPServer, IdCustomHTTPServer,
  JSONRPC.ServerBase.Runner,
  System.Classes, IdContext, JSONRPC.Common.Types,
  JSONRPC.RIO;

type

  TJSONRPCIdTCPServerRunner = class(TJSONRPCServerRunner, IJSONRPCDispatch,
    IJSONRPCGetSetDispatchEvents, IJSONRPCDispatchEvents)
  public
  type
    TProcNotifyPortSet = reference to procedure(const APort: Integer);
    TProcNotifyPortInUse = reference to procedure(const APort: Integer);
    TProcNotifyServerIsAlreadyRunning = reference to procedure(const AServer: TJSONRPCServerRunner);
    TProcNotifyServerIsActive = reference to procedure(const AServer: TJSONRPCServerRunner);
    TProcNotifyServerIsInactive = reference to procedure(const AServer: TJSONRPCServerRunner);
  private
    function GetActive: Boolean; inline;
    procedure SetActive(const Value: Boolean); inline;
    function GetGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
    function GetJSONRPCDispatch: IJSONRPCDispatch;
    function GetJSONRPCDispatchEvents: IJSONRPCDispatchEvents;
  protected
    FServer: TIdHTTPServer;
    FRequest: TStream;
    FResponse: TStream;
    FServerWrapper: TJSONRPCServerWrapper;

    FOnNotifyPortSet: TProcNotifyPortSet;
    FOnNotifyPortInUse: TProcNotifyPortInUse;
    FOnNotifyServerIsAlreadyRunning: TProcNotifyServerIsAlreadyRunning;
    FOnNotifyServerIsActive: TProcNotifyServerIsActive;
    FOnNotifyServerIsInactive: TProcNotifyServerIsInactive;

    procedure ReadStream(AContext: TIdContext; AStream: TStream);
    procedure IncomingDataExecute(AContext: TIdContext);
    procedure HandlePostGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    function BindPort(APort: Integer): Boolean;

    function GetPort: Integer;
    procedure SetPort(const APort: Integer);

    procedure DoNotifyPortSet;
    procedure DoNotifyPortInUse(const APort: Integer);
    procedure DoNotifyServerIsActive;
    procedure DoNotifyServerIsInactive;
    procedure DoNotifyServerIsAlreadyRunning;

    property Dispatcher: IJSONRPCDispatch read GetJSONRPCDispatch implements IJSONRPCDispatch;
    property JSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents
      read GetGetSetDispatchEvents implements IJSONRPCGetSetDispatchEvents;
    property JSONRPCDispatchEvents: IJSONRPCDispatchEvents
      read GetJSONRPCDispatchEvents implements IJSONRPCDispatchEvents;
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
    property Server: TIdHTTPServer read FServer;
  end;

implementation

uses
  IPPeerAPI, System.SysUtils;

{ TJSONRPCServerRunner }

function TJSONRPCServerRunner.BindPort(APort: Integer): Boolean;
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

function TJSONRPCServerRunner.CheckPort(const APort: Integer): Integer;
begin
  if BindPort(APort) then
    Result := APort
  else
    Result := 0;
end;

function TJSONRPCServerRunner.CheckPort(const APort: string): Integer;
begin
  Result := CheckPort(APort.ToInteger);
end;

constructor TJSONRPCServerRunner.Create;
begin
  inherited Create;
  FRequest := TMemoryStream.Create;
  FResponse := TMemoryStream.Create;
  FServer := TIdHTTPServer.Create(nil);
  FServer.OnCommandGet := HandlePostGet;
  FServerWrapper := TJSONRPCServerWrapper.Create(nil);
end;

destructor TJSONRPCServerRunner.Destroy;
begin
  FServerWrapper.Free;
  FServer.StopListening;
  FServer.Free;
  FResponse.Free;
  FRequest.Free;
  inherited;
end;

procedure TJSONRPCServerRunner.DoNotifyPortInUse(const APort: Integer);
begin
  if Assigned(FOnNotifyPortInUse) then
    FOnNotifyPortInUse(APort);
end;

procedure TJSONRPCServerRunner.DoNotifyPortSet;
begin
  if Assigned(FOnNotifyPortSet) then
    FOnNotifyPortSet(FServer.DefaultPort);
end;

procedure TJSONRPCServerRunner.DoNotifyServerIsActive;
begin
  if Assigned(FOnNotifyServerIsActive) then
    FOnNotifyServerIsActive(Self);
end;

procedure TJSONRPCServerRunner.DoNotifyServerIsAlreadyRunning;
begin
  if Assigned(FOnNotifyServerIsAlreadyRunning) then
    FOnNotifyServerIsAlreadyRunning(Self);
end;

procedure TJSONRPCServerRunner.DoNotifyServerIsInactive;
begin
  if Assigned(FOnNotifyServerIsInactive) then
    FOnNotifyServerIsInactive(Self);
end;

function TJSONRPCServerRunner.GetActive: Boolean;
begin
  Result := FServer.Active;
end;

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

function TJSONRPCServerRunner.GetPort: Integer;
begin
  Result := FServer.DefaultPort;
end;

procedure TJSONRPCServerRunner.HandlePostGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  ARequestInfo.PostStream.Position := 0;
  FResponse.Size := 0;
  AResponseInfo.ContentStream := FResponse;
  AResponseInfo.FreeContentStream := False;
  Dispatcher.DispatchJSONRPC(ARequestInfo.PostStream, AResponseInfo.ContentStream);
  FResponse.Position := 0;
  AResponseInfo.ContentType := 'application/json';
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

procedure TJSONRPCServerRunner.SetActive(const Value: Boolean);
begin
  FServer.Active := Value;
end;

procedure TJSONRPCServerRunner.SetPort(const APort: Integer);
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

procedure TJSONRPCServerRunner.StartServer(const APort: Integer = 0);
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

procedure TJSONRPCServerRunner.StopServer;
begin
  FServer.Active := False;
  DoNotifyServerIsInactive;
end;

end.
