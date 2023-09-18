unit JSONRPC.Web3.AptosAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Common.Types,
  System.SysUtils, System.JSON;

type

  AptosAddress = string;

  IAptosJSONRPC = interface(IJSONRPCMethods)
    [UrlSuffix('/v1/accounts/address')]
    function GetAccount(const Address: AptosAddress): TJSONObject;

  end;

implementation

uses
  JSONRPC.InvokeRegistry;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IAptosJSONRPC));
end.
