unit TestJSONDictionaryConverter2.Converters;

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

  TValueRange = record
    firstSlot: Integer;
    lastSlot: Integer;
  end;

  TValueRecord = record
    [JsonConverter(TbyIdentityConverter)]
    byIdentity: TbyIdentity;
    range: TValueRange;

    class operator Assign(var Dest: TValueRecord; const [ref] Src: TValueRecord);
    class operator Initialize(out Dest: TValueRecord);
    class operator Finalize(var Dest: TValueRecord);
  end;

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

end.
