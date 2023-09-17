unit JSONRPC.WebBrokerJSONRPC;

{$CODEALIGN 16}

interface

uses
  System.Classes, System.SysUtils, System.Masks, JSONRPC.Server.Dispatcher,
  Web.AutoDisp, Web.HTTPApp, JSONRPC.Common.Types;

type
  TJSONRPCDispatcherException = procedure(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; E: Exception; var Handled: Boolean) of object;

  { Webbroker component that dispatches JSON RPC requests }
  TJSONRPCDispatcher = class(TJSONRPCDispatchNode)
  protected
    FOnException: TJSONRPCDispatcherException;

    function DispatchEnabled: Boolean;
    function DispatchRequest(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property OnDispatchedJSONRPC;
    property OnReceivedJSONRPC;
    property OnSentJSONRPC;

    property OnException: TJSONRPCDispatcherException read FOnException write FOnException;
  end;

function GetJSONRPCWebModule: TWebModule;

procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);
procedure SetOnReceivedJSONRPC(const AProc: TOnReceivedJSONRPC);
procedure SetOnSentJSONRPC(const AProc: TOnSentJSONRPC);

implementation

uses
  System.Math,
  Soap.SOAPAttach,
  Soap.SOAPConst;

threadvar
  JSONRPCWebModule:  TWebModule;

function GetJSONRPCWebModule: TWebModule;
begin
  Result := JSONRPCWebModule;
end;

{ TJSONRPCDispatcher }

constructor TJSONRPCDispatcher.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOnDispatchedJSONRPC := GOnDispatchedJSONRPC;
  FOnReceivedJSONRPC   := GOnReceivedJSONRPC;
end;

destructor TJSONRPCDispatcher.Destroy;
begin
  inherited Destroy;
end;

function TJSONRPCDispatcher.DispatchEnabled: Boolean;
begin
  Result := True;
end;

function StreamAsTBytes(Stream: TStream): TBytes;
begin
  SetLength(Result, Stream.Size);
  Stream.Position := 0;
  Stream.Read(Result, 0, Length(Result));
  Stream.Position := 0;
end;

function TJSONRPCDispatcher.DispatchRequest(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse): Boolean;
var
  LJSONStream, LResponseStream: TMemoryStream;
  LRequestStream: TWebRequestStream;
  ExceptEnv: string;

begin
  try
    if Owner is TWebModule then
      JSONRPCWebModule := TWebModule(Owner);
    try
      try
        { Make sure we have a dispatcher }
        if not Assigned(FJSONRPCDispatcher) and not ((csDesigning in ComponentState) or (csLoading in ComponentState)) then
          raise Exception.Create(SNoDispatcher);

        LJSONStream := TMemoryStream.Create;
        try
          { Wrap request around a stream }
          LRequestStream := TWebRequestStream.Create(Request);
          try
              LJSONStream.Position := 0;
              LResponseStream := TMemoryStream.Create;
              try

                FJSONRPCDispatcher.DispatchJSONRPC(LJSONStream, LResponseStream);

                LResponseStream.Position := 0;

                { Here we send back the response to the client }
                { Response.SendResponse; }
                Result := True;
              finally
                LResponseStream.Free;
              end;
          finally
            LRequestStream.Free;
          end;
        finally
          LJSONStream.Free;
        end;
      except
        on E: Exception do
        begin

          if Assigned(FOnException) then
          begin
            Result := False;
            FOnException(Self, Request, Response, E, Result);
            if Result then
              Exit;
          end;

          { Default to 200, as required by spec. }
          Response.StatusCode := 200;

{$IFNDEF UNICODE}
          Response.Content :=  ExceptEnv;
{$ELSE}
          Response.Content := ExceptEnv;
{$ENDIF}
          Result := True;
        end;
      end;
    except
      { Swallow any unexpected exception, it will bring down some web servers }
      Result := False;
    end;
  finally
    { Reset current JSONRPCWebModule }
    JSONRPCWebModule := nil;
  end;
end;

procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);
begin
  GOnDispatchedJSONRPC := AProc;
end;

procedure SetOnReceivedJSONRPC(const AProc: TOnReceivedJSONRPC);
begin
  GOnReceivedJSONRPC := AProc;
end;

procedure SetOnSentJSONRPC(const AProc: TOnSentJSONRPC);
begin
  GOnSentJSONRPC := AProc;
end;


end.

