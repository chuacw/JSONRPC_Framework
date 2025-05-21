program JSONRPC.BitcoinClient;

{$APPTYPE CONSOLE}
{$WARN DUPLICATE_CTOR_DTOR OFF}
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
  JSONRPC.User.BitcoinRPC in 'JSONRPC.User.BitcoinRPC.pas',
  JSONRPC.User.BitcoinTypes in 'JSONRPC.User.BitcoinTypes.pas',
  JSONRPC.User.Types.MemoryInfo in 'JSONRPC.User.Types.MemoryInfo.pas',
  JSONRPC.User.Types.WalletInfo in 'JSONRPC.User.Types.WalletInfo.pas',
  dotenv in '..\..\..\GitHub\dotenv.pas',
  JSONRPC.User.Types.BlockchainInfo in 'JSONRPC.User.Types.BlockchainInfo.pas',
  JSONRPC.User.Types.BestBlockHash in 'JSONRPC.User.Types.BestBlockHash.pas',
  JSONRPC.User.Types.BlockInfo in 'JSONRPC.User.Types.BlockInfo.pas',
  JSONRPC.User.Types.BlockDefaultInfo in 'JSONRPC.User.Types.BlockDefaultInfo.pas',
  JSONRPC.RttiUtils in '..\..\Common\JSONRPC.RttiUtils.pas',
  JSONRPC.Common.FixBuggyNativeTypes in '..\..\Common\JSONRPC.Common.FixBuggyNativeTypes.pas',
  JSONRPC.Common.Converters in '..\..\Common\JSONRPC.Common.Converters.pas';

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
  LUserName := process.env['username']; // Alternatively, process['username']
  LPassword := process.env['password']; //   '' process.env['password']
  LServer   := process.env['server'];   //   '' process.env['server']

  LBitcoinRPCServer := GetBitcoinJSONRPC(LServer, LUserName, LPassword,
    BitcoinOutgoingRequest, BitcoinIncomingResponse
  );
  var LBestBlockHash := LBitcoinRPCServer.BestBlockHash;
  var LBlockHash := LBitcoinRPCServer.BlockHash[1000];
  // The following RPC call will take a long time to return
  var LBlock := LBitcoinRPCServer.getblockJSONObject(LBestBlockHash, 1);
//  var LBlockJSONObj := LBitcoinRPCServer.getblock(LBestBlockHash, TVerbosity.HexEncodedData);

  LMemoryInfo := LBitcoinRPCServer.MemoryInfo;
  LWalletInfo := LBitcoinRPCServer.WalletInfo;
  LBlockCount := LBitcoinRPCServer.BlockCount;
  var LBlockchainInfo := LBitcoinRPCServer.BlockchainInfo;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    try
      Main;
    except
      on E: Exception do
        WriteLn(E.Message);
    end;
  finally
    Write('Press enter to close');
    ReadLn;
  end;
end.
