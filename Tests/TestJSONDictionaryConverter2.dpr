program TestJSONDictionaryConverter2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.JSON.Serializers,
  System.JSON,
  TestJSONDictionaryConverter.Types in 'TestJSONDictionaryConverter.Types.pas',
  TestJSONDictionaryConverter2.Converters in 'TestJSONDictionaryConverter2.Converters.pas',
  JSONRPC.Web3.Solana.Attributes in '..\Web3\Solana\JSONRPC.Web3.Solana.Attributes.pas',
  JSONRPC.Web3.Solana.CustomConverters in '..\Web3\Solana\JSONRPC.Web3.Solana.CustomConverters.pas';

function SameJson(const AJSON1, AJSON2: string): Boolean;
var
  LJSONV1, LJSONV2: TJSONValue;
  LJSON1, LJSON2: string;
begin
  try
    LJSONV1 := TJSONObject.ParseJSONValue(AJSON1);
    LJSONV2 := TJSONObject.ParseJSONValue(AJSON2);
    LJSON1 := LJSONV1.ToString;
    LJSON2 := LJSONV2.ToString;
    Result := LJSON1 = LJSON2;
  except
    Result := False;
  end;
end;

type
  TMyEncoding = record
    [JsonConverter(TEncodingEnumConverter)]
    testencoding: TEncoding;
  end;

procedure TestEncoding;
var
  LJSON1, LJSON2: string;
  LSerializer: TJsonSerializer;
  LEncoding1, LEncoding2: TMyEncoding;
begin
  LJSON1 := '{"testencoding":{"encoding":"jsonParsed"}}';
  LSerializer := TJsonSerializer.Create;
  try
    LEncoding1.testencoding := base64_zstd;
    LJSON2 := LSerializer.Serialize<TMyEncoding>(LEncoding1);
    LEncoding2 := LSerializer.Deserialize<TMyEncoding>(LJSON1);
    WriteLn('LJSON1: ', LJSON1);
    WriteLn('LJSON2: ', LJSON2);
    WriteLn;

    WriteLn('JSON1 is same as JSON2: ', SameJson(LJSON1, LJSON2));
  finally
    LSerializer.Free;
  end;
end;

procedure Main;
var
  LJSON1, LJSON2: string;
  LSerializer: TJsonSerializer;
  LResult: getAccountInfoResult;
begin
  LJSON1 := '{'#13#10+
  '    "context": {'#13#10+
  '        "slot": 9887'#13#10+
  '    },'#13#10+
  '    "value": {'#13#10+
  '        "byIdentity": {'#13#10+
  '            "85iYT5RuzRTDgjyRa3cP8SYhM2j21fj7NhfJ3peu1DPr": ['#13#10+
  '                9888,'#13#10+
  '                9886'#13#10+
  '            ]'#13#10+
  '        },'#13#10+
  '        "range": {'#13#10+
  '            "firstSlot": 0,'#13#10+
  '            "lastSlot": 9887'#13#10+
  '        }'#13#10+
  '    }'#13#10+
  '}'#13#10;
  LSerializer := TJsonSerializer.Create;
  try
    LResult := LSerializer.Deserialize<getAccountInfoResult>(LJSON1);
    LJSON2 := LSerializer.Serialize<getAccountInfoResult>(LResult);
    WriteLn('LJSON1: ', LJSON1);
    WriteLn('LJSON2: ', LJSON2);
    WriteLn;

    WriteLn('JSON1 is same as JSON2: ', SameJson(LJSON1, LJSON2));
  finally
    LSerializer.Free;
  end;
end;

begin
  TestEncoding;
end.
