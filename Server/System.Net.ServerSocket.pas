unit System.Net.ServerSocket;

interface

uses
  Winapi.Winsock2,
  System.Net.Socket, System.Classes, System.SysUtils;

const
  AF_INET  = Winapi.Winsock2.AF_INET;
  AF_INET6 = Winapi.Winsock2.AF_INET6;

type

  TNetEndpoint = System.Net.Socket.TNetEndpoint;
  TServerSocket = class;
  TProc = System.SysUtils.TProc;
  TRunThread = reference to function (AServerSocket: TServerSocket; ASocket: System.Net.Socket.TSocket): TProc;

  TServerSocket = class
  private
    procedure SetReceiveTimeout(const Value: Integer);
    function GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function GetFamily: Word;
    procedure SetFamily(const Value: Word);
    function GetState: TSocketStates;
    function GetLocalPort: Integer;
  protected
    FSocket: System.Net.Socket.TSocket;
    FTerminated: Boolean;
    FThread: TThread;
    FThreadList: TThreadList;
    FRunThread: TRunThread;

    function GetAddress: string; inline;
    procedure SetAddress(const Value: string); inline;

    function GetReceiveTimeout: Integer;

    function GetEndpoint: TNetEndpoint;
    procedure SetEndpoint(const Value: TNetEndpoint);

    procedure CreateThreadList; inline;
    procedure FreeThreadList;
  public
    constructor Create(const ARunThread: TRunThread);
    destructor Destroy; override;

    procedure Close(ForceClosed: Boolean);
    function Accept(Timeout: Cardinal = INFINITE): TSocket;
    procedure Listen(const Endpoint: TNetEndpoint; QueueSize: Integer = -1); inline;
    procedure StopListening;

    procedure Terminate;

    property Address: string read GetAddress write SetAddress;
    property Endpoint: TNetEndpoint read GetEndpoint write SetEndpoint;
    property Family: Word read GetFamily write SetFamily;
    property LocalPort: Integer read GetLocalPort;
    property ReceiveTimeout: Integer read GetReceiveTimeout write SetReceiveTimeout;
    property State: TSocketStates read GetState;
    property Terminated: Boolean read FTerminated;
    property Port: Integer read GetPort write SetPort;

  end;

implementation

{ TServerSocket }

function TServerSocket.Accept(Timeout: Cardinal): TSocket;
begin
  Result := FSocket.Accept(Timeout);
end;

procedure TServerSocket.Close(ForceClosed: Boolean);
begin
  FSocket.Close(ForceClosed);
end;

constructor TServerSocket.Create(const ARunThread: TRunThread);
begin
  Assert(Assigned(ARunThread), 'ARunThread not assigned!');

  FRunThread := ARunThread;

  CreateThreadList;

  FSocket := System.Net.Socket.TSocket.Create(TSocketType.TCP, TEncoding.UTF8);
{$IF DECLARED(ConnectTimeout)}
  FSocket.ConnectTimeout := 500;
{$ENDIF}
  FSocket.ReceiveTimeout := 500;
  FSocket.SendTimeout := 500;

  FThread := TThread.CreateAnonymousThread(procedure
  var
    LNewSocket: System.Net.Socket.TSocket;
    LNewThread: TThread;
    LServerSocket: System.Net.Socket.TSocket;
  begin
    LServerSocket := FSocket;
    while (not (TSocketState.Listening in LServerSocket.State) and (not FTerminated)) do
      begin
        Sleep(10);
      end;
    try
      while not FTerminated do
        begin
          try
            LNewSocket := LServerSocket.Accept(LServerSocket.ReceiveTimeout); // throws exception if not listening
            if Assigned(LNewSocket) then
              begin
                LNewThread := TThread.CreateAnonymousThread(FRunThread(Self, LNewSocket));
                FThreadList.Add(LNewThread);
                LNewThread.FreeOnTerminate := False;
                LNewThread.Start;
              end;
          except
          end;
        end;
    except
    end;
  end);

  FThread.FreeOnTerminate := False;
  FThread.Start;
end;

procedure TServerSocket.CreateThreadList;
begin
  FThreadList := TThreadList.Create;
end;

destructor TServerSocket.Destroy;
begin
  Terminate;
  FThread.WaitFor;
  FThread.Free;

  FreeThreadList;

  FSocket.Close(True);
  FSocket.Free;
  inherited;
end;

procedure TServerSocket.FreeThreadList;
var
  LList: Tlist;
  LListCount: Integer;
  LThread: TThread;
begin
  if Assigned(FThreadList) then
    repeat
      LList := FThreadList.LockList;
      LListCount := LList.Count;
      if LListCount <> 0 then
        begin
          LThread := TThread(LList.Last);
          if Assigned(LThread) then
            begin
              LThread.Terminate;
              LThread.WaitFor;
              LThread.Free;
            end;
          LList.Remove(LThread);
          FThreadList.UnlockList;
        end;
    until LListCount = 0;
  FreeAndNil(FThreadList);
end;

function TServerSocket.GetAddress: string;
begin
  Result := FSocket.Endpoint.Address.Address;
end;

function TServerSocket.GetEndpoint: TNetEndpoint;
begin
  Result := FSocket.Endpoint;
end;

function TServerSocket.GetFamily: Word;
begin
  Result := FSocket.Endpoint.Family;
end;

function TServerSocket.GetLocalPort: Integer;
begin
  Result := FSocket.LocalPort;
end;

function TServerSocket.GetPort: Integer;
begin
  Result := FSocket.LocalPort;
end;

function TServerSocket.GetReceiveTimeout: Integer;
begin
  Result := FSocket.ReceiveTimeout;
end;

function TServerSocket.GetState: TSocketStates;
begin
  Result := FSocket.State;
end;

procedure TServerSocket.Listen(const Endpoint: TNetEndpoint;
  QueueSize: Integer);
begin
  if not Assigned(FThreadList) then
    CreateThreadList;
  FSocket.Listen(Endpoint, QueueSize)
end;

procedure TServerSocket.SetAddress(const Value: string);
begin
  FSocket.Endpoint.SetAddress(Value);
end;

procedure TServerSocket.SetEndpoint(const Value: TNetEndpoint);
begin
  FSocket.Endpoint.Port := Value.Port;
  FSocket.Endpoint.Address := Value.Address;
  FSocket.Endpoint.Family := Value.Family;
end;

procedure TServerSocket.SetFamily(const Value: Word);
begin
  FSocket.Endpoint.Family := Value;
end;

procedure TServerSocket.SetPort(const Value: Integer);
begin
  FSocket.Endpoint.Port := Value;
end;

procedure TServerSocket.SetReceiveTimeout(const Value: Integer);
begin
  FSocket.ReceiveTimeout := Value;
end;

procedure TServerSocket.StopListening;
begin
  FSocket.Close(True);
  FreeThreadList;
  CreateThreadList;
end;

procedure TServerSocket.Terminate;
begin
  FTerminated := True;
  FThread.Terminate;
end;

end.
