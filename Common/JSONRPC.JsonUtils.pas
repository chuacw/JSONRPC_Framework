unit JSONRPC.JsonUtils;

{$CODEALIGN 16}

interface

uses
  System.SysUtils, System.Rtti, System.Classes, System.TypInfo,
  System.JSON, System.Generics.Collections;

/// <summary>
/// Convert the given JSON string into UTF8-encoded bytes, and the length into VCount.
/// </summary>
procedure JsonToTBytesCount(const AJSON: string; out VBytes: TBytes; out VCount: NativeInt);

/// <summary>
/// Deserialize the given JSON string with the given TypeInfo, into the record wrapped by TValue
/// </summary>
procedure DeserializeRecord(const AJSON: string; ATypeInfo: PTypeInfo; var VValue: TValue); overload;

/// <summary>
/// Deserialize the JSON using the given TypeInfo, in the record
/// </summary>
procedure DeserializeRecord(const AJSON: string; ATypeInfo: PTypeInfo; var VRestoredRecord); overload;

/// <summary>
/// Deserialize the JSON using the given TypeInfo, in the record address
/// </summary>
procedure DeserializeRecord(const AJSON: string; ATypeInfo: PTypeInfo; PtrToRestoredRecord: Pointer); overload;

/// <summary>
/// Deserialize the JSON using the given TypeInfo, into VValue
/// </summary>
procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo; var VValue: TValue); overload;

/// <summary>
/// Deserialize the JSON using the given TypeInfo, into VRestoredRecord
/// </summary>
procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo; var VRestoredRecord); overload;

/// <summary>
/// Convert a TValue into the record itself
/// </summary>
/// <param name="AValue"> The TValue carrying the data of the record</param>
/// <param name="ATypeInfo"> The TypeInfo of the record</param>
/// <param name="VRestoredRecord> The untyped variable of the record</param>
procedure ValueToObj(const AValue: TValue; ATypeInfo: PTypeInfo; var VRestoredRecord);


/// <summary>
/// Serialize the record using the given TypeInfo into a JSON string
/// </summary>
function SerializeRecord(const [ref] VRecord; ATypeInfo: PTypeInfo): string; overload; inline;

/// <summary>
/// Serialize the record using the given TypeInfo into a JSON string
/// </summary>
function SerializeRecord(const PtrToRecord: Pointer; ATypeInfo: PTypeInfo): string; overload;

/// <summary>
/// Serialize AValue using the given TypeInfo into a JSON string, calls
/// SerializeValue, ie, it's a wrapper
/// </summary>
function SerializeRecord(const AValue: TValue; ATypeInfo: PTypeInfo): string; overload; inline;

/// <summary>
/// Serialize AValue using the given TypeInfo into a JSON string
/// </summary>
function SerializeValue(const AValue: TValue; ATypeInfo: PTypeInfo): string; overload;

/// <summary>
/// Serialize AValue using the given TypeInfo into VJSONValue
/// </summary>
procedure SerializeValue(const AValue: TValue; ATypeInfo: PTypeInfo; out VJSONValue: TJSONValue); overload;

/// <summary>
/// Serialize the given native array into a TJSONArray
/// </summary>
function ArrayToJSONArray(const AArray; ATypeInfo: PTypeInfo): TJSONArray;

/// <summary>
/// Serialize the given AValue of type TValue into a TJSONArray
/// </summary>
function ValueToJSONArray(const AValue: TValue; ATypeInfo: PTypeInfo): TJSONArray; inline;

procedure WriteJSONResult(
  AMethNum: Integer; const ATypeInfo: PTypeInfo; const AMethodID: Int64;
  AResponseValue: TValue; AJSONResponse: TStream);

procedure CheckFloatType(AFloatType: TFloatType); inline;
procedure CheckTypeInfo(ATypeInfo: PTypeInfo); inline;

/// <summary>
/// Adds the "jsonrpc": "2.0" into the header
/// </summary>
procedure AddJSONVersion(const AJSONObj: TJSONObject); inline;

function SameJson(const AJSON1, AJSON2: string): Boolean;

procedure OutputDebugString(const AMsg: string); inline;

function IfThen(AValue: Boolean; const ATrue: TFunc<Integer>; const AFalse: TFunc<Integer>): Integer;

type
  TCollectionsHelper = class
  public
    class function ListToArray<T>(const AList: TList<T>): TArray<T>; static;
    class function DictionaryToArray<K, V>(
      const ADictionary: TDictionary<K, V>): TArray<TPair<K, V>>;
  end;

implementation

uses
  JSONRPC.Common.Consts, System.JSON.Serializers, System.JSON.Readers,
{$IF DEFINED(DEBUG)}
  {$IF DEFINED(MSWINDOWS)}
    Winapi.Windows,
  {$ENDIF}
{$ENDIF}
  System.JSON.Writers;

procedure OutputDebugString(const AMsg: string);
begin
  {$IF DEFINED(MSWINDOWS)}
  Winapi.Windows.OutputDebugString(PChar(AMsg));
  {$ENDIF}
end;

procedure AddJSONVersion(const AJSONObj: TJSONObject);
begin
  AJSONObj.AddPair(SJSONRPC, FloatToJson(2.0));
end;

procedure CheckFloatType(AFloatType: TFloatType);
begin
{$IF DEFINED(DEBUG)}
  if AFloatType <> ftSingle then
    ;
{$ENDIF}
end;

procedure CheckTypeInfo(ATypeInfo: PTypeInfo);
begin
{$IF DEFINED(DEBUG)}
  if ATypeInfo <> nil then
    ;
{$ENDIF}
end;

// 0 => nil
// >0 => inline ok
// <0 => heap data
// Main purpose is to determine where & how much data to blit when copying in / out.
function GetInlineSize(TypeInfo: PTypeInfo): Integer;
begin
  if TypeInfo = nil then
    Exit(0);

  case TypeInfo^.Kind of
    tkInteger, tkEnumeration, tkChar, tkWChar:
      case GetTypeData(TypeInfo)^.OrdType of
        otSByte, otUByte: Exit(1);
        otSWord, otUWord: Exit(2);
        otSLong, otULong: Exit(4);
      else
        Exit(0);
      end;
    tkSet:
      begin
        Result := SizeOfSet(TypeInfo);
{$IF   SizeOf(Extended) > SizeOf(TMethod)}
        if Result > SizeOf(Extended) then
          Result := -Result;
{$ELSE SizeOf(Extended) <= SizeOf(TMethod)}
        if Result > SizeOf(TMethod) then
          Result := -Result;
{$ENDIF}
        Exit;
      end;
    tkFloat:
      case GetTypeData(TypeInfo)^.FloatType of
        ftSingle: Exit(4);
        ftDouble: Exit(8);
        ftExtended: Exit(SizeOf(Extended));
        ftComp: Exit(8);
        ftCurr: Exit(8);
      else
        Exit(0);
      end;
    tkClass:
{$IFDEF AUTOREFCOUNT}
      Exit(-SizeOf(Pointer));
{$ELSE  AUTOREFCOUNT}
      Exit(SizeOf(Pointer));
{$ENDIF AUTOREFCOUNT}
    tkClassRef: Exit(SizeOf(Pointer));
    tkMethod: Exit(SizeOf(TMethod));
    tkInt64: Exit(8);
    tkDynArray, tkUString, tkLString, tkWString, tkInterface: Exit(-SizeOf(Pointer));
{$IFNDEF NEXTGEN}
    tkString: Exit(-GetTypeData(TypeInfo)^.MaxLength - 1);
{$ENDIF !NEXTGEN}
    tkPointer: Exit(SizeOf(Pointer));
    tkProcedure: Exit(SizeOf(Pointer));
    tkRecord, tkMRecord: Exit(-GetTypeData(TypeInfo)^.RecSize);
    tkArray: Exit(-GetTypeData(TypeInfo)^.ArrayData.Size);
    tkVariant: Exit(-SizeOf(Variant));
  else
    Exit(0);
  end;
end;

{.$DEFINE UseRTL35}
{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
type
  TJsonSerializerHelper = class(TJsonSerializer)
  public
    function InternalDeserialize(const AReader: TJsonReader; ATypeInf: PTypeInfo): TValue; override;
  end;

function TJsonSerializerHelper.InternalDeserialize(const AReader: TJsonReader; ATypeInf: PTypeInfo): TValue;
begin
  Result := inherited;
end;
{$ENDIF}

procedure DeserializeRecord(const AJSON: string; ATypeInfo: PTypeInfo; var VValue: TValue); overload;
var
{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
  LValue: TValue;
{$ENDIF}
  LReader: TJsonTextReader;
  LTextReader: TTextReader;
begin
  var LSerializer :=
{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
    TJsonSerializerHelper.Create;
{$ELSEIF RTLVersion >= 36.0}
    TJsonSerializer.Create;
{$ENDIF}
  LTextReader := TStringReader.Create(AJSON);
  LReader := TJsonTextReader.Create(LTextReader);
  try
// working
//    LValue := LSerializer.Deserialize(LReader, ATypeInfo);
//    LValue.TryCast(ATypeInfo, VValue);

{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
// working, except where RTLVersion <= 36.0, then it doesn't work
    LValue := LSerializer.InternalDeserialize(LReader, ATypeInfo);
    LValue.TryCast(ATypeInfo, VValue);
{$ELSEIF RTLVersion >= 36.0}
    VValue := LSerializer.Deserialize(LReader, ATypeInfo);
{$ENDIF}

  finally
    LReader.Free;
    LTextReader.Free;
    LSerializer.Free;
  end;
end;

procedure DeserializeRecord(const AJSON: string; ATypeInfo: PTypeInfo; var vRestoredRecord);
var
  LValue: TValue;
begin
  DeserializeRecord(AJSON, ATypeInfo, LValue);
  if LValue.TypeInfo = nil then
    FillChar(Pointer(@vRestoredRecord)^, Abs(GetInlineSize(ATypeInfo)), 0)
  else
    LValue.ExtractRawData(@vRestoredRecord);
end;

procedure DeserializeRecord(const AJSON: string; ATypeInfo: PTypeInfo; PtrToRestoredRecord: Pointer);
begin
  DeSerializeRecord(AJSON, ATypeInfo, PtrToRestoredRecord^);
end;

procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo;
  var VValue: TValue);
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

procedure ValueToObj(const AValue: TValue; ATypeInfo: PTypeInfo; var VRestoredRecord);
begin
  if AValue.TypeInfo = nil then
    FillChar(Pointer(@vRestoredRecord)^, Abs(GetInlineSize(ATypeInfo)), 0)
  else
    AValue.ExtractRawData(@VRestoredRecord);
end;

procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo;
  var VRestoredRecord); overload;
var
  LValue: TValue;
begin
  DeserializeJSON(AJsonValue, ATypeInfo, LValue);
  ValueToObj(LValue, ATypeInfo, VRestoredRecord);
end;

/// [ref] required for records less than 8 bytes, otherwise, the compiler
/// will stuff the parameter into a register
function SerializeRecord(const [ref] VRecord; ATypeInfo: PTypeInfo): string;
begin
  Result := SerializeRecord(@VRecord, ATypeInfo);
end;

function ArrayToJSONArray(const AArray; ATypeInfo: PTypeInfo): TJSONArray;
begin
  var LStr: string := SerializeRecord(@AArray, ATypeInfo);
  Result := TJSONArray.ParseJSONValue(LStr) as TJSONArray;
end;

function SerializeRecord(const PtrToRecord: Pointer; ATypeInfo: PTypeInfo): string;
var
  LValue: TValue;
begin
  TValue.Make(PtrToRecord, ATypeInfo, LValue);
  Result := SerializeRecord(LValue, ATypeInfo);
end;

function SerializeValue(const AValue: TValue; ATypeInfo: PTypeInfo): string;
var
  ASerializer: TJsonSerializer;
  AJsonObjWriter: TJsonObjectWriter;
begin
  ASerializer := TJsonSerializer.Create;
  AJsonObjWriter := TJsonObjectWriter.Create;
  try
    ASerializer.Serialize(AJsonObjWriter, AValue);
    Result := AJsonObjWriter.JSON.ToJSON;
  finally
    AJsonObjWriter.Free;
    ASerializer.Free;
  end;
end;

function ValueToJSONArray(const AValue: TValue; ATypeInfo: PTypeInfo): TJSONArray;
begin
  var LStr := SerializeRecord(AValue, ATypeInfo);
  Result := TJSONArray.ParseJSONValue(LStr) as TJSONArray;
end;

function SerializeRecord(const AValue: TValue; ATypeInfo: PTypeInfo): string;
begin
  Result := SerializeValue(AValue, ATypeInfo);
end;

procedure SerializeValue(const AValue: TValue; ATypeInfo: PTypeInfo; out VJSONValue: TJSONValue);
begin
  var ASerializer := TJsonSerializer.Create;
  var AJsonObjWriter := TJsonObjectWriter.Create;
  try
    ASerializer.Serialize(AJsonObjWriter, AValue);
    VJSONValue := AJsonObjWriter.JSON.Clone as TJSONValue;
  finally
    AJsonObjWriter.Free;
    ASerializer.Free;
  end;
end;

procedure JsonToTBytesCount(const AJSON: string; out VBytes: TBytes; out VCount: NativeInt);
begin
  VBytes := TEncoding.UTF8.GetBytes(AJSON);
  VCount := Length(VBytes);
end;

procedure WriteJSONResult(
  AMethNum: Integer; const ATypeInfo: PTypeInfo; const AMethodID: Int64;
  AResponseValue: TValue; AJSONResponse: TStream);
begin
  // Write this {"jsonrpc": "2.0", "result": 19, "id": 1}
  var LJSONObject := TJSONObject.Create;
  try
    AddJSONVersion(LJSONObject);
    case ATypeInfo.Kind of
      tkInteger: LJSONObject.AddPair(SRESULT, AResponseValue.AsInteger);
      tkString, tkLString, tkUString:
        LJSONObject.AddPair(SRESULT, AResponseValue.AsString);
    end;
    LJSONObject.AddPair(SID, AMethodID);
    var LJSON := LJSONObject.ToString;
    var LBytes := TEncoding.UTF8.GetBytes(LJSON);
    AJSONResponse.Write(LBytes[0], Length(LBytes));
  finally
    LJSONObject.Free;
  end;
end;

//  [JsonSerialize(TJsonMemberSerialization.Fields)]
//  TMyObject = record
//  private
//    FData: string;
//    FNum: Integer;
//    FDate: TDateTime;
//  public
//    constructor Create(const AData: string; ANum: Integer; ADate: TDateTime);
//    property Data: string read FData write FData;
//    property Num: Integer read FNum write FNum;
//    property Date: TDateTime read FDate write FDate;
//  end;


//    Tested working example
//    var LObj := TMyObject.Create('Hello', 5, Now);
//    var LJSONText := SerializeRecord(LObj, System.TypeInfo(TMyObject));
//    var LNewJSONObj := TJSONObject.ParseJSONValue(LJSONText);
//    var LParams := TJSONObject.Create;
//    LParams.AddPair('AObj', LNewJSONObj);
//
//    var LJSONObj := LParams.Get('AObj').JsonValue;
//    var LNewObject: TMyObject;
//    DeserializeJSON(LJSONObj, System.TypeInfo(TMyObject), LNewObject);

{ TCollectionsHelper }

class function TCollectionsHelper.DictionaryToArray<K, V>(
  const ADictionary: TDictionary<K, V>): TArray<TPair<K, V>>;
begin
  Result := ADictionary.ToArray;
end;

class function TCollectionsHelper.ListToArray<T>(
  const AList: TList<T>): TArray<T>;
begin
  Result := AList.ToArray;
end;

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

function IfThen(AValue: Boolean; const ATrue: TFunc<Integer>; const AFalse: TFunc<Integer>): Integer;
begin
  if AValue then
    Result := ATrue() else
    Result := AFalse();
end;

end.

