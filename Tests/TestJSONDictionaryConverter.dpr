program TestJSONDictionaryConverter;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.JSON.Serializers, System.JSON,
  TestJSONDictionaryConverter.Types in 'TestJSONDictionaryConverter.Types.pas',
  TestJSONDictionaryConverter.Converters in 'TestJSONDictionaryConverter.Converters.pas';

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

procedure Main;
var
  LJSON1, LJSON2: string;
  LSerializer: TJsonSerializer;
  LResult: TResult;
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
    LResult := LSerializer.Deserialize<TResult>(LJSON1);
    LJSON2 := LSerializer.Serialize<TResult>(LResult);
    WriteLn('LJSON1: ', LJSON1);
    WriteLn('LJSON2: ', LJSON2);
    WriteLn;

    WriteLn('JSON1 is same as JSON2: ', SameJson(LJSON1, LJSON2));
  finally
    LSerializer.Free;
  end;
end;

begin
  Main;
end.
