{---------------------------------------------------------------------------}
{                                                                           }
{ File:      JSONRPC.Server.JSONRPCHTTPServer.pas                           }
{ Function:  Constants for JSON RPC HTTP server                             }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit JSONRPC.Server.JSONRPCHTTPServer;

{$ALIGN 16}
{$CODEALIGN 16}

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

