unit JSONRPC.Web3.AptosAPI;

interface

uses
  JSONRPC.RIO, JSONRPC.Common.Types, System.JSON,
  JSONRPC.Web3.Aptos.Common.Types;

const
  AptosMainNet = 'https://fullnode.mainnet.aptoslabs.com/';
  AptosDevNet  = 'https://fullnode.devnet.aptoslabs.com/';
  AptosTestNet = 'https://fullnode.testnet.aptoslabs.com/';

type

  AptosAddress = string;

  IAptosJSONRPC = interface(IJSONRPCMethods)
    ['{A1E94111-1F64-40A3-8544-7D6279EEEA3C}']

    [UrlSuffix('/v1/accounts/{Address}')]
    function GetAccount(const Address: AptosAddress): TJSONObject; safecall;

    [UrlSuffix('/v1/blocks/by_height/{height}')]
    function GetBlocksByHeight(const height: UInt64): TBlocksByHeightResult; safecall;

    [UrlSuffix('/v1/blocks/by_version/{version}')]
    function GetBlocksByVersion(const version: Integer): TJSONValue; safecall;

    [UrlSuffix('/v1/accounts/{address}/resources')]
    function GetAccountResources(const address: AptosAddress): TJSONValue; safecall;

    [UrlSuffix('/v1/accounts/{address}/modules')]
    function GetAccountModules(const address: AptosAddress): TJSONValue; safecall;

    [UrlSuffix('/v1/accounts/{address}/resource/{resource_type}')]
    function GetAccountResource(const address: AptosAddress;
      const resource_type: string): TJSONValue; safecall;
  end;

implementation

uses
  JSONRPC.InvokeRegistry;

initialization
  InvokableRegistry.RegisterInterface(TypeInfo(IAptosJSONRPC));
end.
