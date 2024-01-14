{---------------------------------------------------------------------------}
{                                                                           }
{ File:      JSONRPC.ServerTCP.Runer.pas                                    }
{ Function:  Types for for JSON RPC TCP server                              }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit JSONRPC.ServerTCP.Runner;

interface

uses
  System.Net.Socket, System.Classes, JSONRPC.Common.Types,
  JSONRPC.RIO, JSONRPC.ServerBase.Runner, System.Net.ServerSocket;

type

  TJSONRPCServerTCPRunner = class(TCustomJSONRPCServerRunner, IJSONRPCDispatch,
    IJSONRPCGetSetDispatchEvents, IJSONRPCDispatchEvents)
  public
  type
    TProcNotifyPortSet = reference to procedure(const APort: Integer);
    TProcNotifyPortInUse = reference to procedure(const APort: Integer);
    TProcNotifyServerIsAlreadyRunning = reference to procedure(const AServer: TJSONRPCServerTCPRunner);
    TProcNotifyServerIsActive = reference to procedure(const AServer: TJSONRPCServerTCPRunner);
    TProcNotifyServerIsInactive = reference to procedure(const AServer: TJSONRPCServerTCPRunner);
  private
    function GetGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
    function GetJSONRPCDispatch: IJSONRPCDispatch;
    function GetJSONRPCDispatchEvents: IJSONRPCDispatchEvents;
  protected
    FEndpoint: TNetEndpoint;
    FServer: TServerSocket;
//    FRequest: TStream;
//    FResponse: TStream;
//    FServerWrapper: TJSONRPCServerWrapper;

    function GetRequestStream: TStream;
    function GetResponseStream: TStream;

//    FOnNotifyPortSet: TProcNotifyPortSet;
//    FOnNotifyPortInUse: TProcNotifyPortInUse;
//    FOnNotifyServerIsAlreadyRunning: TProcNotifyServerIsAlreadyRunning;
//    FOnNotifyServerIsActive: TProcNotifyServerIsActive;
//    FOnNotifyServerIsInactive: TProcNotifyServerIsInactive;

    procedure CreateServerWrapper; override;
    procedure FreeServerWrapper; override;

    function GetAddress: string; override;
    function GetHost: string; override;
    procedure SetAddress(const Value: string); override;
    procedure SetHost(const Value: string); override;

    function GetActive: Boolean; override;
    procedure SetActive(const Value: Boolean); override;

    procedure CreateServer; override;
    procedure FreeServer; override;

    procedure ReadStream(AStream: TStream);
    procedure IncomingDataExecute;
    function BindPort(APort: Integer): Boolean; override;

    function GetPort: Integer; override;
    procedure SetPort(const APort: Integer); override;

    function RunThread(AServerSocket: TServerSocket; ANewSocket: System.Net.Socket.TSocket): TProc;

    procedure DoNotifyPortSet; override;
    procedure DoNotifyPortInUse(const APort: Integer); override;
    procedure DoNotifyServerIsActive; override;
    procedure DoNotifyServerIsInactive; override;
    procedure DoNotifyServerIsAlreadyRunning; override;

    property Dispatcher: IJSONRPCDispatch read GetJSONRPCDispatch implements IJSONRPCDispatch;
    property JSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents
      read GetGetSetDispatchEvents implements IJSONRPCGetSetDispatchEvents;
    property JSONRPCDispatchEvents: IJSONRPCDispatchEvents
      read GetJSONRPCDispatchEvents implements IJSONRPCDispatchEvents;
  public

//    constructor Create;
//    destructor Destroy; override;

    function CheckPort(const APort: Integer): Integer; override;
    function CheckPort(const APort: string): Integer; override;

    procedure StartServer(const APort: Integer = 0); override;
    procedure StopServer; override;

//    property OnNotifyPortSet: TProcNotifyPortSet read FOnNotifyPortSet write
//      FOnNotifyPortSet;
//    property OnNotifyPortInUse: TProcNotifyPortInUse read FOnNotifyPortInUse write
//      FOnNotifyPortInUse;
//    property OnNotifyServerIsActive: TProcNotifyServerIsActive read
//      FOnNotifyServerIsActive write FOnNotifyServerIsActive;
//    property OnNotifyServerIsInactive: TProcNotifyServerIsInactive read
//      FOnNotifyServerIsInactive write FOnNotifyServerIsInactive;
//    property OnNotifyServerIsAlreadyRunning: TProcNotifyServerIsAlreadyRunning read
//      FOnNotifyServerIsAlreadyRunning write FOnNotifyServerIsAlreadyRunning;

    property Active: Boolean read GetActive write SetActive;
  end;

implementation

{$HINTS OFF}

uses
  System.SysUtils, Winapi.Winsock2;

{ TJSONRPCServerTCPRunner }

function TJSONRPCServerTCPRunner.BindPort(APort: Integer): Boolean;
begin
  Result := True;
  try
    FEndpoint.Port := APort;
//    FServer.Bind(FEndpoint);
  except
    Result := False;
  end;
end;

function TJSONRPCServerTCPRunner.CheckPort(const APort: Integer): Integer;
var
  LTempPort: Word;
begin
  LTempPort := FEndpoint.Port;
  if BindPort(APort) then
    begin
      FEndpoint.Port := APort;
      Result := APort;
    end else
    begin
      FEndpoint.Port := LTempPort;
      Result := LTempPort;
    end;
end;

function TJSONRPCServerTCPRunner.CheckPort(const APort: string): Integer;
begin
  Result := CheckPort(APort.ToInteger);
end;

//constructor TJSONRPCServerTCPRunner.Create;
//begin
//  inherited Create;
//  FRequest := TMemoryStream.Create;
//  FResponse := TMemoryStream.Create;
//  FServer := TSocket.Create(TSocketType.TCP, TEncoding.UTF8);
//  FServerWrapper := TJSONRPCServerWrapper.Create(nil);
//end;

procedure TJSONRPCServerTCPRunner.CreateServer;
var
  LIPAddr: TIPAddress;

begin
  CreateServerWrapper;

  FEndpoint.Family := AF_INET;
  FEndpoint.Address := TIPAddress.Any;
  FServer := TServerSocket.Create(RunThread);
end;

procedure TJSONRPCServerTCPRunner.CreateServerWrapper;
begin
  FServerWrapper := TJSONRPCServerWrapper.Create(nil);
end;

//destructor TJSONRPCServerTCPRunner.Destroy;
//begin
//  FServerWrapper.Free;
//  FServer.Free;
//  FResponse.Free;
//  FRequest.Free;
//  inherited;
//end;

procedure TJSONRPCServerTCPRunner.DoNotifyPortInUse(const APort: Integer);
begin
  if Assigned(FOnNotifyPortInUse) then
    FOnNotifyPortInUse(APort);
end;

procedure TJSONRPCServerTCPRunner.DoNotifyPortSet;
begin
  if Assigned(FOnNotifyPortSet) then
    FOnNotifyPortSet(FEndpoint.Port);
end;

procedure TJSONRPCServerTCPRunner.DoNotifyServerIsActive;
begin
  if Assigned(FOnNotifyServerIsActive) then
    FOnNotifyServerIsActive(Self);
end;

procedure TJSONRPCServerTCPRunner.DoNotifyServerIsAlreadyRunning;
begin
  if Assigned(FOnNotifyServerIsAlreadyRunning) then
    FOnNotifyServerIsAlreadyRunning(Self);
end;

procedure TJSONRPCServerTCPRunner.DoNotifyServerIsInactive;
begin
  if Assigned(FOnNotifyServerIsInactive) then
    FOnNotifyServerIsInactive(Self);
end;

procedure TJSONRPCServerTCPRunner.FreeServer;
begin
  FServer.Free;
  FreeServerWrapper;
end;

procedure TJSONRPCServerTCPRunner.FreeServerWrapper;
begin
  FServerWrapper.Free;
end;

function TJSONRPCServerTCPRunner.GetActive: Boolean;
begin
  Result := FServer.State * [TSocketState.Connected, TSocketState.Listening] <> [];
end;

function TJSONRPCServerTCPRunner.GetAddress: string;
begin
  Result := FEndpoint.Address.Address;
end;

function TJSONRPCServerTCPRunner.GetGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  Result := FServerWrapper as IJSONRPCGetSetDispatchEvents;
end;

function TJSONRPCServerTCPRunner.GetHost: string;
begin
  Result := FEndpoint.Address.Address;
end;

function TJSONRPCServerTCPRunner.GetJSONRPCDispatch: IJSONRPCDispatch;
begin
  Result := FServerWrapper as IJSONRPCDispatch;
end;

function TJSONRPCServerTCPRunner.GetJSONRPCDispatchEvents: IJSONRPCDispatchEvents;
begin
  Result := FServerWrapper as IJSONRPCDispatchEvents;
end;

function TJSONRPCServerTCPRunner.GetPort: Integer;
begin
  Result := FEndpoint.Port;
end;

function TJSONRPCServerTCPRunner.GetRequestStream: TStream;
begin
  Result := FRequest;
end;

function TJSONRPCServerTCPRunner.GetResponseStream: TStream;
begin
  Result := FResponse;
end;

//procedure TJSONRPCServerTCPRunner.HandlePostGet(AContext: TIdContext;
//  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
//begin
//  ARequestInfo.PostStream.Position := 0;
//  FResponse.Size := 0;
//  AResponseInfo.ContentStream := FResponse;
//  AResponseInfo.FreeContentStream := False;
//  Dispatcher.DispatchJSONRPC(ARequestInfo.PostStream, AResponseInfo.ContentStream);
//  FResponse.Position := 0;
//  AResponseInfo.ContentType := 'application/json';
//end;

procedure TJSONRPCServerTCPRunner.IncomingDataExecute;
begin
  FRequest.Position := 0;
  FResponse.Position := 0;
  FResponse.Size := 0;

//  ReadStream(AContext, FRequest);

  Dispatcher.DispatchJSONRPC(FRequest, FResponse);
  FResponse.Position := 0;
//  AContext.Connection.IOHandler.Write(FResponse);
end;

procedure TJSONRPCServerTCPRunner.ReadStream(AStream: TStream);
var
  LReceivedString: string;
  LBuffer: TBytes;
begin
  try
//    LReceivedString := FServer.ReceiveString();
//    AStream.Position := 0;
//    LBuffer := TEncoding.UTF8.GetBytes(LReceivedString);
//    AStream.Write(LBuffer, Length(LBuffer));
//    AStream.Position := 0;
  except
  end;
end;

function TJSONRPCServerTCPRunner.RunThread(AServerSocket: TServerSocket;
  ANewSocket: System.Net.Socket.TSocket): TProc;
var
  LNewSocket: System.Net.Socket.TSocket;
begin
  LNewSocket := ANewSocket;
  Result := procedure
  var
    LRequestString, LResponseString: string;
    LRequestStream, LResponseStream: TStream;
    LRequestBytes, LResponseBytes: TBytes;
    LSocket: System.Net.Socket.TSocket;
    LByteCount: Integer;
  begin
    LSocket := LNewSocket;
    while not TThread.CheckTerminated do
      begin
        LRequestStream := GetRequestStream;
        LResponseStream := GetResponseStream;
        LRequestBytes := LSocket.ReceiveFrom;
        if Length(LRequestBytes) <> 0 then
          begin
            LRequestStream.Write(LRequestBytes, Length(LRequestBytes));
            LRequestString := StringOf(LRequestBytes);
            IncomingDataExecute;
            if LResponseStream.Position <> LResponseStream.Size then
              begin
                SetLength(LResponseBytes, LResponseStream.Size);
                LResponseStream.Read(LResponseBytes, Length(LResponseBytes));
                LResponseString := LSocket.Encoding.GetString(LResponseBytes);
                LByteCount := LSocket.Encoding.GetByteCount(LResponseString);
                LSocket.Send(LByteCount, SizeOf(LByteCount), []);
                LSocket.Send(LResponseString);
                LResponseStream.Size := 0;
                LRequestStream.Size := 0;
                LResponseBytes := nil;
                LRequestBytes := nil;
                TThread.Current.Terminate;
              end;
          end;
      end;
    LSocket.Free;
  end;
end;

procedure TJSONRPCServerTCPRunner.SetActive(const Value: Boolean);
begin
  if Value then
    begin
      FServer.Listen(FEndpoint);
    end else
    begin
//      FServer.Close;
      FServer.StopListening;
    end;
end;

procedure TJSONRPCServerTCPRunner.SetAddress(const Value: string);
begin
  FEndpoint.SetAddress(Value);
end;

procedure TJSONRPCServerTCPRunner.SetHost(const Value: string);
begin
  FEndpoint.SetAddress(Value);
end;

procedure TJSONRPCServerTCPRunner.SetPort(const APort: Integer);
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
//    end
  if FEndpoint.Port <> APort then
    begin
      FEndpoint.Port := APort;
      DoNotifyPortSet;
    end;
end;

procedure TJSONRPCServerTCPRunner.StartServer(const APort: Integer = 0);
var
  LPort: Integer;
begin
  if APort <> 0 then
    begin
      FEndpoint.Port := APort;
      LPort := APort;
    end else
    begin
      FEndpoint.Port := APort;
      LPort := APort;
    end;
  if not Active then
    begin
      if CheckPort(LPort) > 0 then
      begin
//        FServer.Bindings.Clear;
//        FServer.Active := True;
        FServer.Listen(FEndpoint);
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

procedure TJSONRPCServerTCPRunner.StopServer;
begin
//  FServer.Active := False;
//  FServer.Close;
  FServer.StopListening;
  DoNotifyServerIsInactive;
end;

end.
