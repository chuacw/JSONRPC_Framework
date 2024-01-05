unit JSONRPC.Common.Consts;

interface

const
  SJSONRPC: string = 'jsonrpc';
  SID: string      = 'id';
  SRESULT: string  = 'result';
  SMETHOD: string  = 'method';

  SPARAMS: string  = 'params';

  SERROR: string   = 'error';
  SCODE: string    = 'code';
  SMESSAGE: string = 'message';

  SCLASSNAME: string = 'class';

  SMethodNotFound: string  = 'Method not found';
  SParseError: string      = 'Parse error';
  SInvalidRequest: string  = 'Invalid Request';

  SApplicationJson: string    = 'application/json';
  SApplicationJsonRPC: string = 'application/json-rpc';
  SAccept: string             = 'accept';
  SContentType: string        = 'content-type';

  CParseError     = -32700;
  CInvalidRequest = -32600;
  CMethodNotFound = -32601;
  CInvalidParams  = -32602;
  CInternalError  = -32603;
  CServerError000 = -32000;
  CServerError099 = -32099;

implementation

end.



































// chuacw, Jun 2023

