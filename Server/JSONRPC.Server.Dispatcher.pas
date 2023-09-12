unit JSONRPC.Server.Dispatcher;

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
    FOnReceivedJSONRPC: TOnReceivedJSONRPC;
    FOnSentJSONRPC: TOnSentJSONRPC;

    procedure SetJSONRPCDispatcher(const Value: IJSONRPCDispatch);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    { IJSONRPCGetSetDispatchEvents }
    function GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    function GetOnReceivedJSONRPC: TOnReceivedJSONRPC;
    function GetOnSentJSONRPC: TOnSentJSONRPC;


    procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);
    procedure SetOnReceivedJSONRPC(const AProc: TOnReceivedJSONRPC);
    procedure SetOnSentJSONRPC(const AProc: TOnSentJSONRPC);


    property OnDispatchedJSONRPC: TOnDispatchedJSONRPC read GetOnDispatchedJSONRPC
      write SetOnDispatchedJSONRPC;
    property OnReceivedJSONRPC: TOnReceivedJSONRPC read GetOnReceivedJSONRPC
      write SetOnReceivedJSONRPC;
    property OnSentJSONRPC: TOnSentJSONRPC read GetOnSentJSONRPC
      write SetOnSentJSONRPC;
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

procedure TJSONRPCDispatchNode.SetOnReceivedJSONRPC(
  const AProc: TOnReceivedJSONRPC);
var
  LJSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  FOnReceivedJSONRPC := AProc;
  if Supports(FJSONRPCDispatcher, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) then
    begin
      LJSONRPCGetSetDispatchEvents.OnReceivedJSONRPC := AProc;
    end;
end;

procedure TJSONRPCDispatchNode.SetOnSentJSONRPC(const AProc: TOnSentJSONRPC);
var
  LJSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  FOnSentJSONRPC := AProc;
  if Supports(FJSONRPCDispatcher, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) then
    begin
      LJSONRPCGetSetDispatchEvents.OnSentJSONRPC := AProc;
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
  FOnReceivedJSONRPC := nil;
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
          LJSONRPCGetSetDispatchEvents.OnReceivedJSONRPC := FOnReceivedJSONRPC;
        end;
      Dispatcher.DispatchJSONRPC(ARequest, AResponse);
    end else
    begin
      if not Assigned(FServerWrapper) then
        begin
          FServerWrapper := TJSONRPCServerWrapper.Create(nil);
        end;

      FServerWrapper.OnDispatchedJSONRPC := GOnDispatchedJSONRPC;
      FServerWrapper.OnReceivedJSONRPC := GOnReceivedJSONRPC;
      FServerWrapper.OnSentJSONRPC := GOnSentJSONRPC;

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

function TJSONRPCDispatchNode.GetOnReceivedJSONRPC: TOnReceivedJSONRPC;
var
  LJSONRPCGetSetDispatchEvents: IJSONRPCGetSetDispatchEvents;
begin
  Result := nil;
  if Supports(FJSONRPCDispatcher, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) or
    Supports(FServerWrapper, IJSONRPCGetSetDispatchEvents, LJSONRPCGetSetDispatchEvents) then
    begin
      Result := LJSONRPCGetSetDispatchEvents.OnReceivedJSONRPC;
    end;
end;

function TJSONRPCDispatchNode.GetOnSentJSONRPC: TOnSentJSONRPC;
begin
  Result := FOnSentJSONRPC;
end;

end.
