unit JSONRPC.TransportWrapper.AptosHTTP;

interface

uses
  JSONRPC.TransportWrapper.HTTP, System.Classes, System.Net.URLClient;

type
  TJSONRPCHTTPTransportAptosWrapper = class(TJSONRPCHTTPTransportWrapper)
  public
    procedure Post(const AURL: string; const ASource, AResponseContent: TStream;
      const AHeaders: TNetHeaders); override;
  end;

implementation

uses
  JSONRPC.Common.Types;

{ TJSONRPCHTTPTransportAptosWrapper }

procedure TJSONRPCHTTPTransportAptosWrapper.Post(const AURL: string;
  const ASource, AResponseContent: TStream; const AHeaders: TNetHeaders);
begin
  FClient.Get(AURL, AResponseContent, AHeaders);
end;

procedure InitTransportWrapperHTTP;
begin
  GJSONRPCTransportWrapperClass := TJSONRPCHTTPTransportAptosWrapper;
end;

initialization
  InitTransportWrapperHTTP;
end.
