unit JSONRPC.Server.Dispatcher;

{$CODEALIGN 16}

interface

uses
  System.Classes, JSONRPC.InvokeRegistry, JSONRPC.RIO,
  JSONRPC.Common.Types;

type

  TJSONRPCDispatchNode = class(TComponent, IJSONRPCGetSetDispatchEvents)
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
    function GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
    function GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;


    procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);
    procedure SetOnLogIncomingJSONRequest(const AProc: TOnLogIncomingJSONRequest);
    procedure SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);


    property OnDispatchedJSONRPC: TOnDispatchedJSONRPC read GetOnDispatchedJSONRPC
      write SetOnDispatchedJSONRPC;
    property OnLogIncomingJSONRequest: TOnLogIncomingJSONRequest
      read GetOnLogIncomingJSONRequest write SetOnLogIncomingJSONRequest;
    property OnSentJSONRPC: TOnLogOutgoingJSONResponse read GetOnLogOutgoingJSONResponse
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
  LJSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  FOnLogIncomingJSONRequest := AProc;
  if Supports(FJSONRPCDispatcher, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) then
    begin
      LJSONRPCGetSetDispatchEvents.OnLogIncomingJSONRequest := AProc;
    end;
end;

procedure TJSONRPCDispatchNode.SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);
var
  LJSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  FOnLogOutgoingJSONResponse := AProc;
  if Supports(FJSONRPCDispatcher, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) then
    begin
      LJSONRPCGetSetDispatchEvents.OnLogOutgoingJSONResponse := AProc;
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
          LJSONRPCGetSetDispatchEvents.OnLogIncomingJSONRequest := FOnLogIncomingJSONRequest;
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
  LJSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  Result := nil;
  if Supports(FJSONRPCDispatcher, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) then
    begin
      Result := LJSONRPCGetSetDispatchEvents.OnLogIncomingJSONRequest;
    end;
end;

function TJSONRPCDispatchNode.GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
begin
  Result := FOnLogOutgoingJSONResponse;
end;

end.
