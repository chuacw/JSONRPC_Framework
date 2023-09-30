unit TestJSONDictionaryConverter1.Converters;

interface

uses
  System.JSON.Serializers,
  System.JSON.Converters,
  System.Rtti,
  System.TypInfo,
  System.JSON.Readers,
  System.JSON.Writers,
  TestJSONDictionaryConverter.Types;

type

  TResultConverter = class(TJsonConverter)
  public
    function CanConvert(ATypeInf: PTypeInfo): Boolean; override;
    function CanRead: Boolean; override;
    function CanWrite: Boolean; override;
    function ReadJson(const AReader: TJsonReader; ATypeInf: PTypeInfo; const AExistingValue: TValue;
      const ASerializer: TJsonSerializer): TValue; override;
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;
  end;

  TValueRange = record
    firstSlot: Integer;
    lastSlot: Integer;
  end;
  TValueRecord = record
    byIdentity: TbyIdentity;
    range: TValueRange;

    class operator Assign(var Dest: TValueRecord; const [ref] Src: TValueRecord);
    class operator Initialize(out Dest: TValueRecord);
    class operator Finalize(var Dest: TValueRecord);
  end;

  [JSONConverter(TResultConverter)]
  TResult = record
    context: record
      slot: Integer;
    end;
    value: TValueRecord;
    class operator Assign(var Dest: TResult; const [ref] Src: TResult);
    class operator Initialize(out Dest: TResult);
    class operator Finalize(var Dest: TResult);
  end;

implementation

uses
  System.JSON.Types, System.SysUtils;

class operator TResult.Assign(var Dest: TResult; const [ref] Src: TResult);
begin
  Dest.context.slot := Src.context.slot;
  Dest.value := Src.value;
end;

class operator TResult.Initialize(out Dest: TResult);
begin
  Dest.context.slot := Default(Integer);
  Dest.value := Default(TValueRecord);
end;

class operator TResult.Finalize(var Dest: TResult);
begin
  Dest.context.slot := Default(Integer);
end;

{ TValueRecord }

class operator TValueRecord.Assign(var Dest: TValueRecord; const [ref] Src: TValueRecord);
begin
  Dest.range := Src.range;
  for var LPair in Src.byIdentity do
    Dest.byIdentity.Add(LPair.Key, Copy(LPair.Value));
end;

class operator TValueRecord.Initialize(out Dest: TValueRecord);
begin
  Dest.byIdentity := TbyIdentity.Create;
  Dest.range := Default(TValueRange);
end;

class operator TValueRecord.Finalize(var Dest: TValueRecord);
begin
  FreeAndNil(Dest.byIdentity);
  Dest.range := Default(TValueRange);
end;

{ TResultConverter }

function TResultConverter.CanConvert(ATypeInf: PTypeInfo): Boolean;
begin
  Result := ATypeInf = TypeInfo(TResult);
end;

function TResultConverter.CanRead: Boolean;
begin
  Result := True;
end;

function TResultConverter.CanWrite: Boolean;
begin
  Result := True;
end;

function TResultConverter.ReadJson(const AReader: TJsonReader;
  ATypeInf: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
var
  LKey, LName: string;
  LInteger: Integer;
  LIntegers: TArray<Integer>;
  LValue: TValue;
  LResult: TResult;
begin
  Assert(AReader.TokenType = TJsonToken.StartObject, 'Unexpected TokenType!');
  AReader.Read;

  Assert(AReader.TokenType = TJsonToken.PropertyName, 'Unexpected TokenType!');
  LName := AReader.Value.AsString; // context

  AReader.Read;
  Assert(AReader.TokenType = TJsonToken.StartObject, 'Unexpected TokenType!');

  AReader.Read;             // TokenType = PropertyName
  Assert(AReader.TokenType = TJsonToken.PropertyName, 'Unexpected TokenType!');
  LName := AReader.Value.AsString; // "slot"

  AReader.Read;             // TokenType = Integer
  Assert(AReader.TokenType = TJsonToken.Integer, 'Unexpected TokenType!');
  LResult.context.slot := AReader.Value.AsInteger;

  AReader.Read;             // TokenType = EndObject;
  Assert(AReader.TokenType = TJsonToken.EndObject, 'Unexpected TokenType!');

  AReader.Read;             // TokenType = PropertyName
  Assert(AReader.TokenType = TJsonToken.PropertyName, 'Unexpected TokenType!');
  LName := AReader.Value.AsString;  // "value"

  AReader.Read;              // TokenType = StartObject
  Assert(AReader.TokenType = TJsonToken.StartObject, 'Unexpected TokenType!');

  AReader.Read;              // TokenType = PropertyName
  Assert(AReader.TokenType = TJsonToken.PropertyName, 'Unexpected TokenType!');
  LName := AReader.Value.AsString;  // byIdentity

  AReader.Read;              // TokenType = StartObject
  Assert(AReader.TokenType = TJsonToken.StartObject, 'Unexpected TokenType!');
  repeat
    AReader.Read;            // TokenType = PropertyName
    LKey := '';
    if AReader.TokenType = TJsonToken.EndObject then
      Break;
    LKey := AReader.Value.AsString; // Key
    LIntegers := [];
    repeat
      AReader.Read;
      LValue := AReader.Value;
      if AReader.TokenType = TJsonToken.Integer then
        begin
          LInteger := LValue.AsInteger;
          LIntegers := LIntegers + [LInteger];
        end;
    until AReader.TokenType = TJsonToken.EndArray;
    if LKey <> '' then
      LResult.value.byIdentity.Add(LKey, LIntegers);
  until AReader.TokenType = TJsonToken.EndObject;

  AReader.Read;              // TokenType = PropertyName
  Assert(AReader.TokenType = TJsonToken.PropertyName, 'Unexpected TokenType!');
  LName := AReader.Value.AsString;  // "range"

  AReader.Read;              // TokenType = StartObject
  Assert(AReader.TokenType = TJsonToken.StartObject, 'Unexpected TokenType!');

  AReader.Read;              // TokenType = PropertyName
  Assert(AReader.TokenType = TJsonToken.PropertyName, 'Unexpected TokenType!');
  LName := AReader.Value.AsString;  // "firstSlot"

  AReader.Read;              // TokenType = Integer
  Assert(AReader.TokenType = TJsonToken.Integer, 'Unexpected TokenType!');
  LResult.value.range.firstSlot := AReader.Value.AsInteger;

  AReader.Read;              // TokenType = PropertyName
  Assert(AReader.TokenType = TJsonToken.PropertyName, 'Unexpected TokenType!');
  LName := AReader.Value.AsString;  // "lastSlot"

  AReader.Read;              // TokenType = Integer
  Assert(AReader.TokenType = TJsonToken.Integer, 'Unexpected TokenType!');
  LResult.value.range.lastSlot := AReader.Value.AsInteger;

  AReader.Read;              // EndObject;
  Assert(AReader.TokenType = TJsonToken.EndObject, 'Unexpected TokenType!');

  AReader.Read;              // EndObject;
  Assert(AReader.TokenType = TJsonToken.EndObject, 'Unexpected TokenType!');

  AReader.Read;              // EndObject;
  Assert(AReader.TokenType = TJsonToken.EndObject, 'Unexpected TokenType!');

  Result := TValue.From(LResult);
end;

procedure TResultConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
var
  LResult: TResult;
begin
  AValue.ExtractRawData(@LResult);

  AWriter.WriteStartObject; // start root

  AWriter.WritePropertyName('context');
  AWriter.WriteStartObject; // start context
  AWriter.WritePropertyName('slot');
  AWriter.WriteValue(LResult.context.slot);
  AWriter.WriteEndObject;   // end context

  AWriter.WritePropertyName('value');
  AWriter.WriteStartObject; // start value
  AWriter.WritePropertyName('byIdentity');
  AWriter.WriteStartObject; // start byIdentity
  for var LPair in LResult.value.byIdentity do
    begin
      AWriter.WritePropertyName(LPair.Key);
      AWriter.WriteStartArray;
      for var LValue in LPair.Value do
        AWriter.WriteValue(LValue);
      AWriter.WriteEndArray;
    end;
  AWriter.WriteEndObject;    // close byIdentity

  AWriter.WritePropertyName('range');
  AWriter.WriteStartObject;  // start range
  AWriter.WritePropertyName('firstSlot');
  AWriter.WriteValue(LResult.value.range.firstSlot);
  AWriter.WritePropertyName('lastSlot');
  AWriter.WriteValue(LResult.value.range.lastSlot);
  AWriter.WriteEndObject;    // end range
  AWriter.WriteEndObject;    // end value
  AWriter.WriteEndObject;    // end root

end;

end.
