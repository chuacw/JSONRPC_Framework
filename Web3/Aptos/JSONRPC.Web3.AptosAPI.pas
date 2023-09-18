unit JSONRPC.Web3.AptosAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Common.Types,
  System.SysUtils, System.JSON;

type

  AptosAddress = string;

  IAptosJSONRPC = interface(IJSONRPCMethods)
    ['{A1E94111-1F64-40A3-8544-7D6279EEEA3C}']

    [UrlSuffix('/v1/accounts/address')]
    function GetAccount(const Address: AptosAddress): TJSONObject;

    [UrlSuffix('/v1/blocks/by_height/{AHeight}')]
    function GetBlocksByHeight(const AHeight: UInt64): TJSONObject;

    [UrlSuffix('/v1/blocks/by_version/{version}')]
    function GetBlocksByVersion(const version: Integer): TJSONObject; safecall;

  end;

implementation

uses
  JSONRPC.InvokeRegistry;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IAptosJSONRPC));
end.
