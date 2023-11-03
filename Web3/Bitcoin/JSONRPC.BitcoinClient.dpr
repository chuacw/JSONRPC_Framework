program JSONRPC.BitcoinClient;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  JSONRPC.TransportWrapper.HTTP in '..\..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  JSONRPC.RIO in '..\..\Common\JSONRPC.RIO.pas',
  JSONRPC.JsonUtils in '..\..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.InvokeRegistry in '..\..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.Common.Types in '..\..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.Common.RecordHandlers in '..\..\Common\JSONRPC.Common.RecordHandlers.pas',
  JSONRPC.Common.Consts in '..\..\Common\JSONRPC.Common.Consts.pas',
  System.Net.ClientSocket in '..\..\..\NetSocket\Client\System.Net.ClientSocket.pas',
  System.Net.Socket.Common in '..\..\..\NetSocket\Common\System.Net.Socket.Common.pas',
  JSONRPC.User.BitcoinRPC in 'JSONRPC.User.BitcoinRPC.pas',
  JSONRPC.User.BitcoinTypes in 'JSONRPC.User.BitcoinTypes.pas',
  JSONRPC.User.Types.MemoryInfo in 'JSONRPC.User.Types.MemoryInfo.pas',
  JSONRPC.User.Types.WalletInfo in 'JSONRPC.User.Types.WalletInfo.pas',
  dotenv in '..\..\..\GitHub\dotenv.pas',
  JSONRPC.User.Types.BlockchainInfo in 'JSONRPC.User.Types.BlockchainInfo.pas',
  JSONRPC.User.Types.BestBlockHash in 'JSONRPC.User.Types.BestBlockHash.pas',
  JSONRPC.User.Types.BlockInfo in 'JSONRPC.User.Types.BlockInfo.pas',
  JSONRPC.User.Types.BlockDefaultInfo in 'JSONRPC.User.Types.BlockDefaultInfo.pas';

procedure BitcoinOutgoingRequest(const AJSONRPCRequest: string);
begin
  WriteLn('Outgoing request -----------------------------------------------');
  WriteLn(AJSONRPCRequest);
end;

procedure BitcoinIncomingResponse(const AJSONRPCResponse: string);
begin
  WriteLn('Incoming response ----------------------------------------------');
  WriteLn(AJSONRPCResponse);
end;

procedure Main;
var
  LBitcoinRPCServer: IBitcoinJSONRPC;
  LMemoryInfo: MemoryInfoResult;
  LWalletInfo: WalletInfoResult;
  LServer, LUserName, LPassword: string;
  LBlockCount: UInt64;
begin
  LUserName := process['username'];
  LPassword := process['password'];
  LServer   := process['server'];

  LBitcoinRPCServer := GetBitcoinJSONRPC(LServer, LUserName, LPassword,
    BitcoinOutgoingRequest, BitcoinIncomingResponse
  );
  var LBestBlockHash := LBitcoinRPCServer.BestBlockHash;
  var LBlock := LBitcoinRPCServer.getblockJSONObject(LBestBlockHash, 1);
  var LBlockJSONObj := LBitcoinRPCServer.getblock(LBestBlockHash, TVerbosity.HexEncodedData);

  LMemoryInfo := LBitcoinRPCServer.MemoryInfo;
  LWalletInfo := LBitcoinRPCServer.WalletInfo;
  LBlockCount := LBitcoinRPCServer.BlockCount;
  var LBlockchainInfo := LBitcoinRPCServer.BlockchainInfo;
end;

begin
  Main;
end.
