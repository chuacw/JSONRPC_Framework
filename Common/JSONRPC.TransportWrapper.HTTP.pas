unit JSONRPC.TransportWrapper.HTTP;

interface

uses
  JSONRPC.Common.Types, System.Classes,
  System.Net.HttpClient, System.Net.URLClient;

type

  TJSONRPCHTTPTransportWrapper = class(TJSONRPCTransportWrapper)
  protected
    FClient: THTTPClient;

    function GetConnected: Boolean; override;

    function GetRequestStream: TStream; override;
    function GetResponseStream: TStream; override;

    function GetConnectionTimeout: Integer; override;
    function GetResponseTimeout: Integer; override;
    function GetSendTimeout: Integer; override;
    procedure SetConnectionTimeout(const Value: Integer); override;
    procedure SetResponseTimeout(const Value: Integer); override;
    procedure SetSendTimeout(const Value: Integer); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Post(const AURL: string; const ASource, AResponseContent: TStream;
      const AHeaders: TNetHeaders); override;
  end;

procedure InitTransportWrapperHTTP;

implementation

{ TJSONRPCHTTPTransportWrapper }

constructor TJSONRPCHTTPTransportWrapper.Create;
begin
  inherited;
  FClient := THTTPClient.Create;
end;

destructor TJSONRPCHTTPTransportWrapper.Destroy;
begin
  FRequestStream.Free;
  FResponseStream.Free;
  FClient.Free;
  inherited;
end;

function TJSONRPCHTTPTransportWrapper.GetConnected: Boolean;
begin
  Result := True;
end;

function TJSONRPCHTTPTransportWrapper.GetConnectionTimeout: Integer;
begin
  Result := FClient.ConnectionTimeout;
end;

function TJSONRPCHTTPTransportWrapper.GetRequestStream: TStream;
begin
  if not Assigned(FRequestStream) then
    FRequestStream := TTrackedMemoryStream.Create(CheckStream);
  if FRequestStream.Size <> 0 then
    FRequestStream.Size := 0;
  Result := FRequestStream;
end;

function TJSONRPCHTTPTransportWrapper.GetResponseStream: TStream;
begin
  if not Assigned(FResponseStream) then
    FResponseStream:= TTrackedMemoryStream.Create(CheckStream);
  if FResponseStream.Size <> 0 then
    FResponseStream.Size := 0;
  Result := FResponseStream;
end;

function TJSONRPCHTTPTransportWrapper.GetResponseTimeout: Integer;
begin
  Result := FClient.ResponseTimeout;
end;

function TJSONRPCHTTPTransportWrapper.GetSendTimeout: Integer;
begin
  Result := FClient.SendTimeout;
end;

procedure TJSONRPCHTTPTransportWrapper.Post(const AURL: string; const ASource,
  AResponseContent: TStream; const AHeaders: TNetHeaders);
begin
  FClient.Post(AURL, ASource, AResponseContent, AHeaders);
end;

procedure TJSONRPCHTTPTransportWrapper.SetConnectionTimeout(
  const Value: Integer);
begin
  FClient.ConnectionTimeout := Value;
end;

procedure TJSONRPCHTTPTransportWrapper.SetResponseTimeout(const Value: Integer);
begin
  FClient.ResponseTimeout := Value;
end;

procedure TJSONRPCHTTPTransportWrapper.SetSendTimeout(const Value: Integer);
begin
  FClient.SendTimeout := Value;
end;

procedure InitTransportWrapperHTTP;
begin
  GJSONRPCTransportWrapperClass := TJSONRPCHTTPTransportWrapper;
end;

initialization
  if not Assigned(GJSONRPCTransportWrapperClass) then
    InitTransportWrapperHTTP;
end.
