unit JSONRPC.Server.Dispatcher;

{$CODEALIGN 16}

interface

uses
  System.Classes, JSONRPC.InvokeRegistry, JSONRPC.RIO,
  JSONRPC.Common.Types;

type

  TJSONRPCDispatchNode = class(TComponent, IJSONRPCGetSetDispatchEvents,
    IJSONRPCServerLog)
  protected
    FJSONRPCDispatcher: IJSONRPCDispatch;
    FServerWrapper: TJSONRPCServerWrapper;

    FOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    FOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
    FOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;

    procedure SetJSONRPCDispatcher(const Value: IJSONRPCDispatch);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    { IJSONRPCGetSetDispatchEvents }
    function GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);

    { IJSONRPCServerLog }
    function GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
    function GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
    procedure SetOnLogIncomingJSONRequest(const AProc: TOnLogIncomingJSONRequest);
    procedure SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);

    property OnDispatchedJSONRPC: TOnDispatchedJSONRPC read GetOnDispatchedJSONRPC
      write SetOnDispatchedJSONRPC;
    property OnLogIncomingJSONRequest: TOnLogIncomingJSONRequest
      read GetOnLogIncomingJSONRequest write SetOnLogIncomingJSONRequest;
    property OnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse read GetOnLogOutgoingJSONResponse
      write SetOnLogOutgoingJSONResponse;
  public
    procedure DispatchJSONRPC(const ARequest: TStream; AResponse: TStream); virtual;
    destructor Destroy; override;

  published
    property Dispatcher: IJSONRPCDispatch read FJSONRPCDispatcher write SetJSONRPCDispatcher;
  end;

implementation

uses
  JSONRPC.Common.Consts, System.JSON, System.SysUtils, System.Rtti;

procedure TJSONRPCDispatchNode.SetJSONRPCDispatcher(const Value: IJSONRPCDispatch);
begin
  ReferenceInterface(FJSONRPCDispatcher, opRemove);
  FJSONRPCDispatcher := Value;
  ReferenceInterface(FJSONRPCDispatcher, opInsert);
end;

procedure TJSONRPCDispatchNode.SetOnDispatchedJSONRPC(
  const AProc: TOnDispatchedJSONRPC);
var
  LJSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  FOnDispatchedJSONRPC := AProc;
  if Supports(FJSONRPCDispatcher, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) then
    begin
      LJSONRPCGetSetDispatchEvents.OnDispatchedJSONRPC := AProc;
    end;
end;

procedure TJSONRPCDispatchNode.SetOnLogIncomingJSONRequest(
  const AProc: TOnLogIncomingJSONRequest);
var
  LJsonRpcServerLog: IJSONRPCServerLog;
begin
  FOnLogIncomingJSONRequest := AProc;
  if Supports(FJSONRPCDispatcher, IJSONRPCServerLog, LJSONRPCServerLog) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCServerLog) then
    begin
      LJSONRPCServerLog.OnLogIncomingJSONRequest := AProc;
    end;
end;

procedure TJSONRPCDispatchNode.SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);
var
  LJSONRPCServerLog: IJSONRPCServerLog;
begin
  FOnLogOutgoingJSONResponse := AProc;
  if Supports(FJSONRPCDispatcher, IJSONRPCServerLog, LJSONRPCServerLog) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCServerLog) then
    begin
      LJSONRPCServerLog.OnLogOutgoingJSONResponse := AProc;
    end;
end;

procedure TJSONRPCDispatchNode.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and AComponent.IsImplementorOf(FJSONRPCDispatcher) then
    FJSONRPCDispatcher := nil;
end;

destructor TJSONRPCDispatchNode.Destroy;
begin
  FOnDispatchedJSONRPC := nil;
  FOnLogIncomingJSONRequest := nil;
  FOnLogOutgoingJSONResponse := nil;
  FJSONRPCDispatcher := nil;
  FServerWrapper.Free;
  inherited;
end;

procedure TJSONRPCDispatchNode.DispatchJSONRPC(const ARequest: TStream; AResponse: TStream);
begin
  if Assigned(Dispatcher) then
    begin
      var LJSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
      if Supports(Dispatcher, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) then
        begin
          LJSONRPCGetSetDispatchEvents.OnDispatchedJSONRPC := FOnDispatchedJSONRPC;
        end;
      var LJSONRPCServerLog: IJSONRPCServerLog;
      if Supports(Dispatcher, IJSONRPCServerLog, LJSONRPCServerLog) then
        begin
          LJSONRPCServerLog.OnLogIncomingJSONRequest := FOnLogIncomingJSONRequest;
        end;
      Dispatcher.DispatchJSONRPC(ARequest, AResponse);
    end else
    begin
      if not Assigned(FServerWrapper) then
        begin
          FServerWrapper := TJSONRPCServerWrapper.Create(nil);
        end;

      FServerWrapper.OnDispatchedJSONRPC := GOnDispatchedJSONRPC;
      FServerWrapper.OnLogIncomingJSONRequest := GOnLogIncomingJSONRequest;
      FServerWrapper.OnLogOutgoingJSONResponse := GOnLogOutgoingJSONResponse;

      FServerWrapper.DispatchJSONRPC(ARequest, AResponse);
    end;
end;

function TJSONRPCDispatchNode.GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
var
  LJSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  Result := nil;
  if Supports(FJSONRPCDispatcher, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) then
    begin
      Result := LJSONRPCGetSetDispatchEvents.OnDispatchedJSONRPC;
    end;
end;

function TJSONRPCDispatchNode.GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
var
  LJSONRPCServerLog: IJSONRPCServerLog;
begin
  Result := nil;
  if Supports(FJSONRPCDispatcher, IJSONRPCServerLog, LJSONRPCServerLog) or
    Supports(FServerWrapper, IJSONRPCServerLog, LJSONRPCServerLog) then
    begin
      Result := LJSONRPCServerLog.OnLogIncomingJSONRequest;
    end;
end;

function TJSONRPCDispatchNode.GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
var
  LJSONRPCServerLog: IJSONRPCServerLog;
begin
  Result := nil;
  if Supports(FJSONRPCDispatcher, IJSONRPCServerLog, LJSONRPCServerLog) or
    Supports(FServerWrapper, IJSONRPCServerLog, LJSONRPCServerLog) then
    begin
      Result := LJSONRPCServerLog.OnLogOutgoingJSONResponse;
    end;
end;

end.
