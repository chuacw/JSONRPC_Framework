unit Web3.Aptos.RIO;

interface

uses
  JSONRPC.RIO, System.TypInfo, System.Classes, System.JSON, System.Rtti,
  System.Net.URLClient;

type
  TWeb3AptosJSONRPCWrapper = class(TJSONRPCWrapper)
  protected
    function InitializeHeaders(const ARequestStream: TStream): TNetHeaders; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  JSONRPC.Common.Consts;

{ TWeb3AptosJSONRPCWrapper }

constructor TWeb3AptosJSONRPCWrapper.Create(AOwner: TComponent);
begin
  inherited;
  FPassByPosOrName := tppByPos;
end;

function TWeb3AptosJSONRPCWrapper.InitializeHeaders(
  const ARequestStream: TStream): TNetHeaders;
begin
  Result := [
    TNameValuePair.Create(SAccept, SApplicationJson),
    TNameValuePair.Create(SContentType, SApplicationJson)
  ];
end;

end.
