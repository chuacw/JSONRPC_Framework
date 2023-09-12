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
    function GetOnReceivedJSONRPC: TOnReceivedJSONRPC;
    function GetOnSentJSONRPC: TOnSentJSONRPC;

    procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);
    procedure SetOnReceivedJSONRPC(const AProc: TOnReceivedJSONRPC);
    procedure SetOnSentJSONRPC(const AProc: TOnSentJSONRPC);

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property OnDispatchedJSONRPC: TOnDispatchedJSONRPC read GetOnDispatchedJSONRPC
      write SetOnDispatchedJSONRPC;
    property OnReceivedJSONRPC: TOnReceivedJSONRPC read GetOnReceivedJSONRPC
      write SetOnReceivedJSONRPC;
    property OnSentJSONRPC: TOnSentJSONRPC read GetOnSentJSONRPC
      write SetOnSentJSONRPC;
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

function TJSONRPCWebModule1.GetOnReceivedJSONRPC: TOnReceivedJSONRPC;
begin
  Result := FJSONRPCDispatcher.OnReceivedJSONRPC;
end;

function TJSONRPCWebModule1.GetOnSentJSONRPC: TOnSentJSONRPC;
begin
  Result := FJSONRPCDispatcher.OnSentJSONRPC;
end;

procedure TJSONRPCWebModule1.SetOnDispatchedJSONRPC(
  const AProc: TOnDispatchedJSONRPC);
begin
  FJSONRPCDispatcher.OnDispatchedJSONRPC := AProc;
end;

procedure TJSONRPCWebModule1.SetOnReceivedJSONRPC(
  const AProc: TOnReceivedJSONRPC);
begin
  FJSONRPCDispatcher.OnReceivedJSONRPC := AProc;
end;

procedure TJSONRPCWebModule1.SetOnSentJSONRPC(const AProc: TOnSentJSONRPC);
begin

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
