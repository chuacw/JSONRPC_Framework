unit JSONRPC.Server.JSONRPCHTTPServer;

interface

uses
  JSONRPC.CustomServerIdHTTP.Runner;

type
  TJSONRPCServerIdHTTPRunner = class(TCustomJSONRPCServerIdHTTPRunner)
  protected
    procedure CreateServerWrapper; override;
    procedure FreeServerWrapper; override;
  end;

implementation

uses
  JSONRPC.RIO;

{ TJSONRPCServerIdHTTPRunner }

procedure TJSONRPCServerIdHTTPRunner.CreateServerWrapper;
begin
  FServerWrapper := TJSONRPCServerWrapper.Create(nil);
  FServerWrapper.Persistent := True;
end;

procedure TJSONRPCServerIdHTTPRunner.FreeServerWrapper;
begin
  FServerWrapper.Free;
end;

end.



































// chuacw, Jun 2023

