unit JSONRPC.Web3.Ethereum.RIO;

interface

uses
  JSONRPC.RIO, System.TypInfo, System.Classes, System.JSON, System.Rtti,
  JSONRPC.Client.JSONRPCHTTPWrapper, System.SysUtils;

type
  TWeb3EthereumJSONRPCClient = class(TJSONRPCHTTPWrapper)
  protected
    FOnAfterDispatch: TProc;
    procedure DoAfterDispatch; override;
    function SerializeRecord(const [Ref] VRecord; ATypeInfo: PTypeInfo): string; override;
    procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo;
      var VRestoredRecord); overload; override;
    procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo;
      var VValue: TValue);  overload; override;
  public
    constructor Create(AOwner: TComponent); override;
    property OnAfterDispatch: TProc read FOnAfterDispatch write FOnAfterDispatch;
  end;

implementation

uses
  JSONRPC.JsonUtils, JSONRPC.Common.Types,
  JSONRPC.Web3.Common.Types, System.JSON.Readers, System.JSON.Serializers,
  JSONRPC.Web3.Ethereum.Serializers;

{ TWeb3EthereumJSONRPCClient }

constructor TWeb3EthereumJSONRPCClient.Create(AOwner: TComponent);
begin
  inherited;
  FPassByPosOrName := tppByPos;
end;

procedure TWeb3EthereumJSONRPCClient.DeserializeJSON(const AJsonValue: TJSONValue;
  ATypeInfo: PTypeInfo; var VRestoredRecord);
var
  LValue: TValue;
{$IF DEFINED(DEBUG)}
  LClassName: string;
{$ENDIF}
begin
{$IF DEFINED(DEBUG)}
  LClassName := AJsonValue.ClassName;
{$ENDIF}
  if AJsonValue is TJSONNull then
    begin
      // How to initialize a null record?
      InvokeRecordInitializer(@VRestoredRecord, ATypeInfo);
    end else
    begin
      DeserializeJSON(AJsonValue, ATypeInfo, LValue);
      ValueToObj(LValue, ATypeInfo, VRestoredRecord);
    end;
end;

procedure TWeb3EthereumJSONRPCClient.DeserializeJSON(const AJsonValue: TJSONValue;
  ATypeInfo: PTypeInfo; var VValue: TValue);
var
  LObjReader: TJsonReader;
{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
  LSerializer: TJsonSerializerHelper;
{$ELSE }
  LSerializer: TJsonSerializer;
{$ENDIF}
begin
  if not Assigned(AJsonValue) then
    begin
      Exit;
    end;
  LObjReader := TJsonObjectReader.Create(AJsonValue);
{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
  LSerializer := TJsonSerializerHelper.Create;
{$ELSEIF RTLVersion >= 36.0 }
  LSerializer := TWeb3EthereumJsonSerializer.Create;
{$ENDIF}
  try
{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
    VValue := LSerializer.InternalDeserialize(LObjReader, ATypeInfo);
{$ELSEIF RTLVersion >= 36.0 }
    VValue := LSerializer.Deserialize(LObjReader, ATypeInfo);
{$ENDIF}
  finally
    LSerializer.Free;
    LObjReader.Free;
  end;
end;

procedure TWeb3EthereumJSONRPCClient.DoAfterDispatch;
begin
  if Assigned(FOnAfterDispatch) then
    FOnAfterDispatch;
end;

function TWeb3EthereumJSONRPCClient.SerializeRecord(const [ref] VRecord;
  ATypeInfo: PTypeInfo): string;
var
  LCopy: string;
begin
  if ATypeInfo = TypeInfo(Web3Address) then
    begin
      LCopy := PString(VRecord)^;
      UniqueString(LCopy);
      Result := LCopy;
    end else
    begin
      Result := inherited;
    end;
end;

end.
