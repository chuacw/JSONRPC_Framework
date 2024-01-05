unit JSONRPC.TransportWrapper.HTTP;

{$CODEALIGN 16}

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
    function HttpMethod(const AMethod: string; const AURL: string;
      const ASource, AResponseContent: TStream;
      const AHeaders: TNetHeaders): IHTTPResponse; override;
  end;

procedure InitTransportWrapperHTTP;

implementation

uses
  System.SysUtils;

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

//const
//  sHTTPMethodConnect = 'CONNECT'; // do not localize
//  sHTTPMethodDelete = 'DELETE'; // do not localize
//  sHTTPMethodGet = 'GET'; // do not localize
//  sHTTPMethodHead = 'HEAD'; // do not localize
//  sHTTPMethodOptions = 'OPTIONS'; // do not localize
//  sHTTPMethodPost = 'POST'; // do not localize
//  sHTTPMethodPut = 'PUT'; // do not localize
//  sHTTPMethodTrace = 'TRACE'; // do not localize
//  sHTTPMethodMerge = 'MERGE'; // do not localize
//  sHTTPMethodPatch = 'PATCH'; // do not localize

function HttpMethodToEnum(const AMethod: string): THttpMethodTypeEnum;
begin
// Search common methods first...
  if SameText(AMethod, sHTTPMethodGet) then
    Result := hGet else
  if SameText(AMethod, sHTTPMethodPost) then
    Result := hPost else
  if SameText(AMethod, sHTTPMethodConnect) then
    Result := hConnect else
  if SameText(AMethod, sHTTPMethodDelete) then
    Result := hDelete else
  if SameText(AMethod, sHTTPMethodHead) then
    Result := hHead else
  if SameText(AMethod, sHTTPMethodOptions) then
    Result := hOptions else
  if SameText(AMethod, sHTTPMethodMerge) then
    Result := hMerge else
  if SameText(AMethod, sHTTPMethodPatch) then
    Result := hPatch else
  if SameText(AMethod, sHTTPMethodPut) then
    Result := hPut else
  if SameText(AMethod, sHTTPMethodTrace) then
    Result := hTrace else
    Result := hGet;
end;

function TJSONRPCHTTPTransportWrapper.HttpMethod(const AMethod, AURL: string;
  const ASource, AResponseContent: TStream; const AHeaders: TNetHeaders): IHTTPResponse;
var
  LMethod: THttpMethodTypeEnum;
begin
  LMethod := HttpMethodToEnum(AMethod);
  case LMethod of
    hConnect: begin
      var LRequest: IHTTPRequest := FClient.GetRequest(AMethod, AURL);
      Result := FClient.Execute(LRequest, AResponseContent, AHeaders);
    end;
    hDelete: begin
      {$IF RTLVersion >= 36}
      Result := FClient.Delete(AURL, ASource, AResponseContent, AHeaders);
      {$ELSEIF RTLVersion >= 35}
      var LRequest: IHTTPRequest := FClient.GetRequest(AMethod, AURL);
      Result := FClient.Execute(LRequest, AResponseContent, AHeaders);
      {$ENDIF}
    end;
    hGet: begin
      Result := FClient.Get(AURL, AResponseContent, AHeaders);
    end;
    hHead: begin
      Result := FClient.Head(AURL, AHeaders);
    end;
    hMerge: begin
      Result := FClient.Merge(AURL, ASource, AHeaders);
    end;
    hOptions: begin
      Result := FClient.Options(AURL, AResponseContent, AHeaders);
    end;
    hPatch: begin
      Result := FClient.Patch(AURL, ASource, AResponseContent, AHeaders);
    end;
    hPost: begin
      Result := FClient.Post(AURL, ASource, AResponseContent, AHeaders);
    end;
    hPut: begin
      Result := FClient.Put(AURL, ASource, AResponseContent, AHeaders);
    end;
    hTrace: begin
      Result := FClient.Trace(AURL, AResponseContent, AHeaders);
    end;
  end;
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



































// chuacw, Jun 2023

