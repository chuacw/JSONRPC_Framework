unit JSONRPC.Web3.Solana.RIO;

interface

uses
  JSONRPC.Client.JSONRPCHTTPWrapper, System.Classes, System.SysUtils;

type
  TWeb3SolanaJSONRPCClient = class(TJSONRPCHTTPWrapper)
  protected
    FOnAfterDispatch: TProc;
    procedure DoAfterDispatch; override;
    function InitializeHeaders(const ARequestStream: TStream): TNetHeaders; override;
  public
    property OnAfterDispatch: TProc read FOnAfterDispatch write FOnAfterDispatch;
  end;

implementation

uses
  JSONRPC.Common.Types, JSONRPC.Common.Consts;

{ TWeb3SolanaJSONRPCClient }

procedure TWeb3SolanaJSONRPCClient.DoAfterDispatch;
begin
  inherited;
  if Assigned(FOnAfterDispatch) then
    FOnAfterDispatch;
end;

function TWeb3SolanaJSONRPCClient.InitializeHeaders(
  const ARequestStream: TStream): TNetHeaders;
begin
  inherited;
  if Result.ContainsName(SHeadersContentType) then
    Result.DeleteName(SHeadersContentType);
  Result := Result + [TNameValuePair.Create(SHeadersContentType, SApplicationJson)];
end;

end.
