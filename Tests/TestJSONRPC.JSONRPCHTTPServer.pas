{---------------------------------------------------------------------------}
{                                                                           }
{ File:       TestJSONRPC.JSONRPCHTTPServer.pas                             }
{ Function:   A JSON RPC test server                                        }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit TestJSONRPC.JSONRPCHTTPServer;

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
end;

procedure TJSONRPCServerIdHTTPRunner.FreeServerWrapper;
begin
  FServerWrapper.Free;
end;

end.
