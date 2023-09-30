unit TestJSONDictionaryConverter.Types;

interface

uses
  System.JSON.Converters, System.Generics.Collections;

type

  TbyIdentityConverter = TJsonStringDictionaryConverter<TArray<Integer>>;
  TbyIdentity = TDictionary<string, TArray<Integer>>;

implementation

end.
