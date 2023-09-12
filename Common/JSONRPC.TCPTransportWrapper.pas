unit JSONRPC.TransportWrapper.TCP;

interface

uses
  JSONRPC.Common.Types, System.Classes,
  System.Net.HttpClient, System.Net.URLClient;

type

  TJSONRPCHTTPTransportWrapper = class(TJSONRPCTransportWrapper)
  protected
    FClient: THTTPClient;

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

implementation

{ TJSONRPCHTTPTransportWrapper }

constructor TJSONRPCHTTPTransportWrapper.Create;
begin
  inherited;
  FClient := THTTPClient.Create;
end;

destructor TJSONRPCHTTPTransportWrapper.Destroy;
begin
  FClient.Free;
  inherited;
end;

function TJSONRPCHTTPTransportWrapper.GetConnectionTimeout: Integer;
begin
  Result := FClient.ConnectionTimeout;
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

end.
