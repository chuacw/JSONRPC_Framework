unit JSONRPCWebModule;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp,
  System.TypInfo, JSONRPC.Server.Dispatcher,
  JSONRPC.WebBrokerJSONRPC, JSONRPC.RIO, JSONRPC.Common.Types;

type
  TJSONRPCWebModule1 = class(TWebModule, IJSONRPCGetSetDispatchEvents)
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
  protected
    FJSONRPCDispatcher: TJSONRPCDispatcher;

    function GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    function GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
    function GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;

    procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);
    procedure SetOnLogIncomingJSONRequest(const AProc: TOnLogIncomingJSONRequest);
    procedure SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property OnDispatchedJSONRPC: TOnDispatchedJSONRPC read GetOnDispatchedJSONRPC
      write SetOnDispatchedJSONRPC;
    property OnOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest
      read GetOnLogIncomingJSONRequest write SetOnLogIncomingJSONRequest;
    property OnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse
      read GetOnLogOutgoingJSONResponse write SetOnLogOutgoingJSONResponse;
  end;

var
  WebModuleClass: TComponentClass = TJSONRPCWebModule1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

uses
  JSONRPC.Common.Consts;

{$R *.dfm}

constructor TJSONRPCWebModule1.Create(AOwner: TComponent);
begin
  inherited;
  FJSONRPCDispatcher := TJSONRPCDispatcher.Create(Self);
end;

destructor TJSONRPCWebModule1.Destroy;
begin
  inherited;
end;

function TJSONRPCWebModule1.GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
begin
  Result := FJSONRPCDispatcher.OnDispatchedJSONRPC;
end;

function TJSONRPCWebModule1.GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
begin
  Result := FJSONRPCDispatcher.OnLogIncomingJSONRequest;
end;

function TJSONRPCWebModule1.GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
begin
  Result := FJSONRPCDispatcher.OnLogOutgoingJSONResponse;
end;

procedure TJSONRPCWebModule1.SetOnDispatchedJSONRPC(
  const AProc: TOnDispatchedJSONRPC);
begin
  FJSONRPCDispatcher.OnDispatchedJSONRPC := AProc;
end;

procedure TJSONRPCWebModule1.SetOnLogIncomingJSONRequest(
  const AProc: TOnLogIncomingJSONRequest);
begin
  FJSONRPCDispatcher.OnLogIncomingJSONRequest := AProc;
end;

procedure TJSONRPCWebModule1.SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);
begin
  FJSONRPCDispatcher.OnLogOutgoingJSONResponse := AProc;
end;

procedure TJSONRPCWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  var LBytes := Request.RawContent;
  var LRequestStream := TMemoryStream.Create;
  try
    LRequestStream.Write(LBytes, Length(LBytes));
    LRequestStream.Position := 0;
    var LContentStream := TMemoryStream.Create; // this will be freed automatically
    try
      FJSONRPCDispatcher.DispatchJSONRPC(LRequestStream, LContentStream);
      Response.ContentStream := LContentStream;
      Response.ContentType := SApplicationJson;
      Handled := True;
    except
      FreeAndNil(LContentStream);
      Response.ContentStream := nil;
    end;
  finally
    LRequestStream.Free;
  end;
end;

end.
