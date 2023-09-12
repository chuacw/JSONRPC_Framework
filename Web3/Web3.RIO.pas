unit Web3.RIO;

interface

uses
  JSONRPC.RIO, System.TypInfo, System.Classes, System.JSON, System.Rtti;

type
  TWeb3EthereumJSONRPCWrapper = class(TJSONRPCWrapper)
  protected
    function SerializeRecord(const [Ref] VRecord; ATypeInfo: PTypeInfo): string; override;
    procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo;
      var VRestoredRecord); overload; override;
    procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo;
      var VValue: TValue);  overload; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  JSONRPC.JsonUtils,
  Web3.Common.Types, System.JSON.Readers, System.JSON.Serializers;

{ TWeb3EthereumJSONRPCWrapper }

constructor TWeb3EthereumJSONRPCWrapper.Create(AOwner: TComponent);
begin
  inherited;
  FPassByPosOrName := tppByPos;
end;

procedure TWeb3EthereumJSONRPCWrapper.DeserializeJSON(const AJsonValue: TJSONValue;
  ATypeInfo: PTypeInfo; var VRestoredRecord);
var
  LValue: TValue;
begin
  DeserializeJSON(AJsonValue, ATypeInfo, LValue);
  ValueToObj(LValue, ATypeInfo, VRestoredRecord);
end;

procedure TWeb3EthereumJSONRPCWrapper.DeserializeJSON(const AJsonValue: TJSONValue;
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
//      VValue := TValue.Empty;
      Exit;
    end;
  LObjReader := TJsonObjectReader.Create(AJsonValue);
{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
  LSerializer := TJsonSerializerHelper.Create;
{$ELSEIF RTLVersion >= 36.0 }
  LSerializer := TJsonSerializer.Create;
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

function TWeb3EthereumJSONRPCWrapper.SerializeRecord(const [ref] VRecord;
  ATypeInfo: PTypeInfo): string;
begin
  if ATypeInfo = TypeInfo(Web3Address) then
    Result := PString(VRecord)^ else
    Result := inherited;
end;

end.
