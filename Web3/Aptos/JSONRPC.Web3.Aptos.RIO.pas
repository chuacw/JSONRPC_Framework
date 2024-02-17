unit JSONRPC.Web3.Aptos.RIO;

interface

uses
  JSONRPC.RIO, System.Classes, System.Net.URLClient, JSONRPC.Common.Types;

type
  TWeb3AptosJSONRPCWrapper = class(TJSONRPCWrapper)
  protected
    procedure DoBeforeExecute(const AMethodName: string; AJSONRequest: TStream); override;

    function InitializeHeaders(const ARequestStream: TStream): TNetHeaders; override;

    procedure UpdateServerURL(const AContext: TInvContext;
      const AMethMD: TIntfMethEntry; var VServerURL: string); override;
 public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  JSONRPC.Common.Consts, System.Rtti, System.SysUtils,
  System.TypInfo;

{ TWeb3AptosJSONRPCWrapper }

constructor TWeb3AptosJSONRPCWrapper.Create(AOwner: TComponent);
begin
  inherited;
  FPassByPosOrName := tppByPos;
end;

procedure TWeb3AptosJSONRPCWrapper.DoBeforeExecute(const AMethodName: string;
  AJSONRequest: TStream);
begin
// Aptos is a REST server, not a JSON RPC server, so no need to include a JSON RPC request
  AJSONRequest.Size := 0;
  inherited;
end;

function TWeb3AptosJSONRPCWrapper.InitializeHeaders(
  const ARequestStream: TStream): TNetHeaders;
begin
  Result := [
    TNameValuePair.Create(SHeadersAccept, SApplicationJson),
    TNameValuePair.Create(SHeadersContentType, SApplicationJson)
  ];
end;

procedure TWeb3AptosJSONRPCWrapper.UpdateServerURL(
  const AContext: TInvContext;
  const AMethMD: TIntfMethEntry; var VServerURL: string);
var
  LMethod: TRttiMethod;
  LParamName: string;
  LParamTypeInfo: PTypeInfo;
  I: Integer;
  LParamPointer: Pointer;
begin
  if AMethMD.ParamCount > 0 then
    begin
      I := 0;
      for var LParam in AMethMD.Params do
        begin
          if LParam.Info = nil then
            Continue; // Exit better or continue?
          LParamName := Format('{%s}', [LParam.Name]);
          if VServerURL.Contains(LParamName) then
            begin
              LParamTypeInfo := AMethMD.Params[I].Info;
              LParamPointer := AContext.GetParamPointer(I);
              case LParamTypeInfo.Kind of
                tkString, tkUString:
                  VServerURL := StringReplace(VServerURL, LParamName, string(LParamPointer^), [rfReplaceAll]);
                tkInteger: begin
                  var LValue := IntToStr(PInteger(LParamPointer)^);
                  VServerURL := StringReplace(VServerURL, LParamName, LValue, [rfReplaceAll]);
                end;
                tkInt64: begin
                  var LValue := IntToStr(PUInt64(LParamPointer)^);
                  VServerURL := StringReplace(VServerURL, LParamName, LValue, [rfReplaceAll]);
                end;
              end;
            end;
          Inc(I);
        end;
    end;
end;

end.
