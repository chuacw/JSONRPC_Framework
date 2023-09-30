program JSONRPC.SolanaClient;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.JSON.Serializers,
  JSONRPC.Web3.SolanaClient in 'JSONRPC.Web3.SolanaClient.pas',
  JSONRPC.Web3.SolanaAPI in 'JSONRPC.Web3.SolanaAPI.pas',
  JSONRPC.TransportWrapper.HTTP in '..\..\Common\JSONRPC.TransportWrapper.HTTP.pas',
  JSONRPC.RIO in '..\..\Common\JSONRPC.RIO.pas',
  JSONRPC.JsonUtils in '..\..\Common\JSONRPC.JsonUtils.pas',
  JSONRPC.InvokeRegistry in '..\..\Common\JSONRPC.InvokeRegistry.pas',
  JSONRPC.Common.Types in '..\..\Common\JSONRPC.Common.Types.pas',
  JSONRPC.Common.RecordHandlers in '..\..\Common\JSONRPC.Common.RecordHandlers.pas',
  JSONRPC.Common.Consts in '..\..\Common\JSONRPC.Common.Consts.pas',
  JSONRPC.Web3.SolanaTypes in 'JSONRPC.Web3.SolanaTypes.pas',
  JSONRPC.Web3.SolanaTypes.getVoteAccountResultsType in 'JSONRPC.Web3.SolanaTypes.getVoteAccountResultsType.pas',
  JSONRPC.Web3.Solana.CustomConverters in 'JSONRPC.Web3.Solana.CustomConverters.pas',
  JSONRPC.Web3.Solana.RIO in 'JSONRPC.Web3.Solana.RIO.pas',
  JSONRPC.Web3.Solana.Attributes in 'JSONRPC.Web3.Solana.Attributes.pas';

procedure Main;
var
  LCtx: TRttiContext;
  LTypeInfo: PTypeInfo;
  LType: TRttiType;
  LAttribute: EnumAsAttribute;
begin
  LTypeInfo := TypeInfo(TEncoding);
  LType := LCtx.GetType(LTypeInfo);
  LAttribute := LType.GetAttribute<EnumAsAttribute>;
  // LAttribute.Index =
end;

begin
  Main;
end.
