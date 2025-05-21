unit JSONRPC.Web3.Solana.Encoding;

interface

uses
  JSONRPC.Web3.Solana.Attributes;

type

  [EnumAs(2, 'base64+zstd')]
  TEncoding = (
    base58,
    base64,
    base64_zstd, // 2, base64+zstd
    jsonParsed,
    json
  );

implementation

end.