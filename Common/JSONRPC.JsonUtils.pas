{---------------------------------------------------------------------------}
{                                                                           }
{ File:       JSONRPC.JsonUtils.pas                                         }
{ Function:   Various utiliies for JSON RPC                                 }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit JSONRPC.JsonUtils;

{$ALIGN 16}
{$CODEALIGN 16}

interface

uses
  System.SysUtils, System.Rtti, System.Classes, System.TypInfo,
  System.JSON.Readers, System.JSON.Serializers,
  Velthuis.BigIntegers, Velthuis.BigDecimals,
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
/// Serialize the given native array into a TJSONArray
/// </summary>
function ArrayPtrToJSONArray(const PArray; ATypeInfo: PTypeInfo): TJSONArray;

function ValueToJSONArray(const AValue: TValue; ATypeInfo: PTypeInfo): TJSONArray;

function VariantOpenArrayToDynArray(const AData: array of const): TArray<TVarRec>;

///// <summary> Converts an variant open array (which have no RTTI) to a dynamic array (which supports RTTI).
///// </summary>
//function VariantOpenArrayToJSONArray(const Args: array of const): TJSONArray;

/// <summary>
/// </summary>
procedure WriteJSONResult(
  AMethNum: Integer; const ATypeInfo: PTypeInfo; const AMethodID: Int64;
  AResponseValue: TValue; AJSONResponse: TStream);

procedure CheckFloatType(AFloatType: TFloatType); inline;
procedure CheckTypeInfo(ATypeInfo: PTypeInfo); inline;

/// <summary>
/// Adds the "jsonrpc": "2.0" into the header, only if AJSONObj is non-null
/// </summary>
procedure AddJSONVersion(const AJSONObj: TJSONObject); inline;

/// <summary>
/// Adds the "id": string/number into the header, only if AJSONResultObj is
/// non-null
/// </summary>
procedure AddJSONID(const AJSONObj: TJSONObject;
  const LIDIsString: Boolean; const LJSONRPCRequestIDString: string;
  const LIDIsNumber: Boolean; const LJSONRPCRequestID: Int64);

procedure AddJSONIDNull(const AJSONObj: TJSONObject);
procedure AddJSONCode(const AJSONObj: TJSONObject; ACode: Integer);
procedure AddJSONError(const AJSONObj: TJSONObject; const AErrorObj: TJSONObject);
procedure RemoveJSONResult(const AJSONObj: TJSONObject);

function SameJSON(const AJSON1, AJSON2: TJSONArray): Boolean; overload;
function SameJSON(const AJSON1, AJSON2: TJSONValue): Boolean; overload;
function SameJSON(const AJSONObj1, AJSONObj2: TJSONObject): Boolean; overload;
function SameJson(const AJSONStr1, AJSONStr2: string): Boolean; overload;

procedure OutputDebugString(const AMsg: string); inline;

function IfThen(AValue: Boolean; const ATrue: TFunc<Integer>; const AFalse: TFunc<Integer>): Integer; overload;
function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: TFunc<Integer>): Integer; overload;
function IfThen(AValue: Boolean; const ATrue: TFunc<Integer>; const AFalse: Integer): Integer; overload;

function MakeTypeInfo(ATypeKind: TTypeKind): PTypeInfo;

type

  /// <summary>
  /// This class automatically restores a value of a variable, after setting it to a new value.
  /// </summary>
  TSaveRestore<T> = class(TInterfacedObject)
  protected
    FOldValue: T;
    FValueAddr: ^T;
    constructor Create; overload;
  public
    /// <summary>
    /// This function takes a variable, saves its original value, sets it to the new value
    /// and returns an IInterface.
    /// <param name="OriginVar"> The var address of a value</param>
    /// <param name="NewValue"> The new value to set OriginVar to. </param>
    /// <returns> An IInterface, which will restore the value when destroyed. </returns>
    /// </summary>
    class function Create(var OriginVar: T; const NewValue: T): IInterface; overload; static;

    /// <summary> Restores the OriginVar to its original value
    /// </summary>
    destructor Destroy; override;
  end;

{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
type

  TJsonSerializerHelper = class(TJsonSerializer)
  public
    function InternalDeserialize(const AReader: TJsonReader; ATypeInf: PTypeInfo): TValue; override;
  end;

  TCollectionsHelper = class
  public
    class function ListToArray<T>(const AList: TList<T>): TArray<T>; static;
    class function DictionaryToArray<K, V>(
      const ADictionary: TDictionary<K, V>): TArray<TPair<K, V>>;
  end;
{$ENDIF}

implementation

uses
  JSONRPC.Common.Consts,
{$IF DEFINED(DEBUG)}
  {$IF DEFINED(MSWINDOWS)}
    Winapi.Windows,
  {$ENDIF}
{$ENDIF}
{$IF DECLARED(BigInteger) OR DECLARED(BigDecimal)}
  System.JSON.Types,
{$ENDIF}
  JSONRPC.Common.Types,
  System.JSON.Writers;

{$IF DECLARED(BigInteger) OR DECLARED(BigDecimal)}
type
  TBigNumberJsonSerializer = class(TJsonSerializer)
  public
    constructor Create;
  end;

  TBigNumberContractResolver = class(TJsonDynamicContractResolver, IJsonContractResolver);

  TBigNumberJsonContract = class(TJsonConverterContract)
  public
    constructor Create(ATypeInf: PTypeInfo);
  end;

  TBigNumberJsonConverter = class(TJsonConverter)
  public
    function CanConvert(ATypeInfo: PTypeInfo): Boolean; override;
    function CanRead: Boolean; override;
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;
  end;

  TArrayBigIntegerConverter = class(TBigNumberJsonConverter)
  public
    function ReadJson(const AReader: TJsonReader; ATypeInfo: PTypeInfo; const AExistingValue: TValue;
      const ASerializer: TJsonSerializer): TValue; override;
  end;

  TArrayArrayBigIntegerConverter = class(TBigNumberJsonConverter)
  public
    function ReadJson(const AReader: TJsonReader; ATypeInfo: PTypeInfo; const AExistingValue: TValue;
      const ASerializer: TJsonSerializer): TValue; override;
  end;

  TBigIntegerConverter = class(TBigNumberJsonConverter)
  public
    function ReadJson(const AReader: TJsonReader; ATypeInfo: PTypeInfo;
      const AExistingValue: TValue; const ASerializer: TJsonSerializer): TValue; override;
  end;

  TBigDecimalConverter = class(TBigNumberJsonConverter)
  public
    function ReadJson(const AReader: TJsonReader; ATypeInfo: PTypeInfo;
      const AExistingValue: TValue; const ASerializer: TJsonSerializer): TValue; override;
  end;

  TBigNumberAttributeProvider = class(TInterfacedObject, IJsonAttributeProvider)
  protected
    FRttiObject: TRttiObject;
  public
    constructor Create(const ARttiObject: TRttiObject);
    function GetAttribute(const AAttributeClass: TCustomAttributeClass; AInherit: Boolean = False): TCustomAttribute;
  end;

constructor TBigNumberJsonSerializer.Create;
var
  LContractResolver: TJsonDynamicContractResolver;
begin
  inherited;
  {$IF DECLARED(BigInteger) OR DECLARED(BigDecimal)}
  LContractResolver := TBigNumberContractResolver.Create;
  {$ENDIF}
  {$IF DECLARED(BigInteger)}
  LContractResolver.SetTypeConverter(TypeInfo(BigInteger), TBigIntegerConverter);
  LContractResolver.SetTypeConverter(TypeInfo(TArray<BigInteger>), TArrayBigIntegerConverter);
  {$ENDIF}
  {$IF DECLARED(BigDecimal)}
  LContractResolver.SetTypeConverter(TypeInfo(BigDecimal), TBigDecimalConverter);
//  LContractResolver.SetTypeConverter(TypeInfo(TArray<BigDecimal>), TArrayBigDecimalConverter);
  {$ENDIF}
  {$IF DECLARED(BigInteger) OR DECLARED(BigDecimal)}
  ContractResolver := LContractResolver;
  {$ENDIF}
end;

constructor TBigNumberJsonContract.Create(ATypeInf: PTypeInfo);
begin
  inherited;
  {$IF DECLARED(BigInteger)}
  if ATypeInf = TypeInfo(BigInteger) then
    Converter := TBigIntegerConverter.Create;
  {$ENDIF}
  {$IF DECLARED(BigDecimal)}
  if ATypeInf = TypeInfo(BigDecimal) then
    Converter := TBigDecimalConverter.Create;
  {$ENDIF}
end;

{ TArrayBigIntegerConverter }

function TArrayBigIntegerConverter.ReadJson(const AReader: TJsonReader;
  ATypeInfo: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
var
  V1, V2: BigInteger;
  LArray: TArray<BigInteger>;
  InArray: Integer;
begin
  InArray := 0;
  while AReader.TokenType in [
    TJsonToken.StartArray, TJsonToken.String, TJsonToken.Float, TJsonToken.EndArray] do
    begin
      AReader.Read;
      case AReader.TokenType of
        TJsonToken.StartArray: Inc(InArray);
        TJsonToken.EndArray: begin
          if InArray = 0 then
            begin
              Result := TValue.From(LArray);
              Break;
            end else Dec(InArray);
        end;
        TJsonToken.String: begin
          LArray := LArray + [BigInteger.Create(AReader.Value.AsString)];
        end;
        TJsonToken.Float: begin
          LArray := LArray + [BigInteger.Create(AReader.Value.AsExtended)];
        end;
      end;
    end;
end;

{ TArrayArrayBigIntegerConverter }

function TArrayArrayBigIntegerConverter.ReadJson(const AReader: TJsonReader;
  ATypeInfo: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
type
  TMember = TArray<BigInteger>;
  TContainer = TArray<TMember>;
var
  V1: BigInteger;
  V2: BigInteger;
  LArray: TContainer;
  LMember: TMember;
  InArray: Integer;
begin
  Assert(AReader.CurrentState = TJsonReader.TState.ArrayStart);
  InArray := 0;
  // AReader.TokenType = StartArray
  while AReader.TokenType in [TJsonToken.StartArray, TJsonToken.EndArray,
    TJsonToken.String, TJsonToken.Float] do
    begin
      AReader.Read;
      case AReader.TokenType of
        TJsonToken.StartArray: Inc(InArray);
        TJsonToken.EndArray: begin
          if InArray = 0 then
            begin
              Result := TValue.From(LArray);
              Break;
            end else Dec(InArray);
        end;
        TJsonToken.String: V1 := BigInteger.Create(AReader.Value.AsString);
        TJsonToken.Float: begin
          V2 := BigInteger.Create(AReader.Value.AsExtended);
          LMember := [V1, V2];
          LArray := LArray + [LMember];
        end;
      end;
    end;
end;

{ TBigNumberJsonConverter }
function TBigNumberJsonConverter.CanConvert(ATypeInfo: PTypeInfo): Boolean;
begin
  Result := True;
end;

function TBigNumberJsonConverter.CanRead: Boolean;
begin
  Result := True;
end;

procedure TBigNumberJsonConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
begin
  Assert(False, 'Not implemented yet');
end;

{ TBigIntegerConverter }

function TBigIntegerConverter.ReadJson(const AReader: TJsonReader;
  ATypeInfo: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
begin
  Assert((AReader.TokenType = TJsonToken.String) or (AReader.TokenType = TJsonToken.Float));
  case AReader.TokenType of
    TJsonToken.String: Result := TValue.From(BigInteger.Create(AReader.Value.AsString));
    TJsonToken.Float: Result := TValue.From(BigDecimal.Create(AReader.Value.AsExtended));
  end;
end;

{ TBigDecimalConverter }

function TBigDecimalConverter.ReadJson(const AReader: TJsonReader;
  ATypeInfo: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
begin
  Assert(AReader.TokenType = TJsonToken.String);
  Result := TValue.From(BigDecimal.Create(AReader.Value.AsString));
end;

{ TBigNumberAttributeProvider }
constructor TBigNumberAttributeProvider.Create(const ARttiObject: TRttiObject);
begin
  inherited Create;
  FRttiObject := ARttiObject;
end;

function TBigNumberAttributeProvider.GetAttribute(const AAttributeClass: TCustomAttributeClass; AInherit: Boolean = False): TCustomAttribute;
var
  LTypeInfo: PTypeInfo;
begin
  if AAttributeClass = JsonIgnoreAttribute then
    Exit(nil);
  if AAttributeClass = JsonConverterAttribute then
    begin
      LTypeInfo := PTypeInfo(FRttiObject.Handle);
      if LTypeInfo = TypeInfo(BigInteger) then
        Exit(nil);
      if LTypeInfo = TypeInfo(BigDecimal) then
        Exit(nil);
//      if LTypeInfo = TypeInfo(
    end;
end;

{$ENDIF}


procedure OutputDebugString(const AMsg: string);
begin
  {$IF DEFINED(MSWINDOWS) AND DEFINED(DEBUG)}
  Winapi.Windows.OutputDebugString(PChar(AMsg));
  {$ENDIF}
end;

procedure AddJSONVersion(const AJSONObj: TJSONObject);
begin
  if not Assigned(AJSONObj) or // If it's empty, don't add
     Assigned(AJSONObj.FindValue(SJSONRPC)) then  // or if it's already assigned
    Exit;

  AJSONObj.AddPair(SJSONRPC, FloatToJson(2.0));
end;

procedure AddJSONID(const AJSONObj: TJSONObject;
  const LIDIsString: Boolean; const LJSONRPCRequestIDString: string;
  const LIDIsNumber: Boolean; const LJSONRPCRequestID: Int64);
begin
  if not Assigned(AJSONObj) or // If it's empty, don't add
    Assigned(AJSONObj.FindValue(SID)) then
    Exit;

  if LIDIsString then
    AJSONObj.AddPair(SID, LJSONRPCRequestIDString) else
  if LIDIsNumber then
    AJSONObj.AddPair(SID, LJSONRPCRequestID);
end;

procedure AddJSONIdNull(const AJSONObj: TJSONObject);
var
  LID: TJSONPair;
begin
  if not Assigned(AJSONObj) then
    Exit;
  if Assigned(AJSONObj.FindValue(SID)) then
    begin
      LID := AJSONObj.RemovePair(SID);
      LID.Free;
    end;
  AJSONObj.AddPair(SID, TJSONNull.Create);
end;

procedure AddJSONCode(const AJSONObj: TJSONObject; ACode: Integer);
var
  LID: TJSONPair;
begin
  if Assigned(AJSONObj.FindValue(SCODE)) then
    begin
      LID := AJSONObj.RemovePair(SCODE);
      LID.Free;
    end;
  AJSONObj.AddPair(SCODE, ACode);
end;

procedure AddJSONError(const AJSONObj: TJSONObject; const AErrorObj: TJSONObject);
begin
  if Assigned(AJSONObj) then
    begin
      if Assigned(AErrorObj) then
        AJSONObj.AddPair(SERROR, AErrorObj);
    end;
end;

procedure RemoveJSONResult(const AJSONObj: TJSONObject);
begin
  if Assigned(AJSONObj) then
    begin
      var LResult := AJSONObj.FindValue(SRESULT);
      if Assigned(LResult) then
        begin
          var LPair := AJSONObj.RemovePair(SRESULT);
          LPair.Free;
        end;
    end;
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

{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
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
  LJsonValue: TJSONValue;
{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
  LSerializer: TJsonSerializerHelper;
{$ELSE }
  LSerializer: TJsonSerializer;
{$ENDIF}
begin
  if not Assigned(AJsonValue) then
    begin
      VValue := TValue.Empty;
      Exit;
    end;
  LJsonValue := AJsonValue;
  LObjReader := TJsonObjectReader.Create(AJsonValue);
{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
  LSerializer := TJsonSerializerHelper.Create;
{$ELSEIF RTLVersion >= 36.0 }
  {$IF DECLARED(BigInteger) OR DECLARED(BigDecimal)}
    LSerializer := TBigNumberJsonSerializer.Create;
  {$ELSE}
    LSerializer := TJsonSerializer.Create;
  {$ENDIF}
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

function ArrayPtrToJSONArray(const PArray; ATypeInfo: PTypeInfo): TJSONArray;
type
  TDynArray = TArray<Integer>;
  PDynArray = ^TDynArray;
var
  P: PByte;
  Size, Len: Integer;
  LValue: TValue;
begin
  Result := TJSONArray.Create;
  Size := ATypeInfo.TypeData.elSize;
  Len := System.Length(TDynArray(PArray)) div ATypeInfo.TypeData.elSize;
  P := Pointer(PArray);
  for var I := 0 to Len-1 do
    begin
      TValue.Make(P, ATypeInfo, LValue);
      Inc(P, Size);
      Result.Add(LValue.AsOrdinal);
    end;
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
  {$IF DECLARED(BigInteger) OR DECLARED(BigDecimal)}
    ASerializer := TBigNumberJsonSerializer.Create;
  {$ELSE}
    ASerializer := TJsonSerializer.Create;
  {$ENDIF}
  AJsonObjWriter := TJsonObjectWriter.Create;
  try
    ASerializer.Serialize(AJsonObjWriter, AValue);
    Result := AJsonObjWriter.JSON.ToJSON;
  finally
    AJsonObjWriter.Free;
    ASerializer.Free;
  end;
end;

function ConstItemToTJsonValue(const Item: TVarRec): TJsonValue;
begin
  case Item.VType of
    vtInteger:
      begin
        Result := TJSONNumber.Create(Item.VInteger);
      end;
    vtExtended:
      begin
        Result := TJSONNumber.Create(Item.VExtended^);
      end;
    vtString:
      begin
        Result := TJSONString.Create(string(Item.VString^));
      end;
    vtPChar:
      begin
        var LStr := Item.VPChar;
        Result := TJSONString.Create(string(LStr));
      end;
    vtPWideChar:
      begin
        var LStr := Item.VPWideChar;
        Result := TJSONString.Create(LStr);
      end;
    vtAnsiString:
      begin
        // A little trickier: casting to AnsiString will ensure
        // reference counting is done properly.
        Result := TJSONString.Create(string(AnsiString(Item.VAnsiString)));
      end;
    vtCurrency:
      begin
        Result := TJSONNumber.Create(Item.VCurrency^);
      end;
    // Casting ensures a proper copy is created.
    vtWideString:
      begin
        Result := TJSONString.Create(WideString(Item.VWideString));
      end;
    vtInt64:
      begin
        Result := TJSONNumber.Create(Item.VInt64^);
      end;
    vtUnicodeString:
      begin
        // Similar to AnsiString.
        Result := TJSONString.Create(UnicodeString(Item.VUnicodeString));
      end;
  else
    // VPointer and VObject don't have proper copy semantics so it
    // is impossible to write generic code that copies the contents
    Result := nil;
    Assert(False, '');
  end;
end;

function ValueToJSONArray(const AValue: TValue; ATypeInfo: PTypeInfo): TJSONArray;
begin
  if (ATypeInfo = TypeInfo(TConstArray)) then
    begin
      var LJSONArray := TJSONArray.Create;
      var LConstArray := TConstArray(AValue.GetReferenceToRawData^);
      for var I := Low(LConstArray) to High(LConstArray) do
        begin
          var LItem := LConstArray[I];
          var LJSONValue := ConstItemToTJsonValue(LItem);
          LJSONArray.AddElement(LJSONValue);
        end;
      FinalizeVarRecArray(LConstArray);
      Exit(LJSONArray);
    end;
  var LStr := SerializeRecord(AValue, ATypeInfo);
  Result := TJSONArray.ParseJSONValue(LStr) as TJSONArray;
end;

function VariantOpenArrayToDynArray(const AData: array of const): TArray<TVarRec>;
begin
  SetLength(Result, Length(AData));
  for var I := Low(AData) to High(AData) do
    begin
      Result[I] := CopyVarRec(AData[I]);
    end;
end;

function SerializeRecord(const AValue: TValue; ATypeInfo: PTypeInfo): string;
begin
  if ATypeInfo = TypeInfo(TConstArray) then
    begin
      Assert(False, 'Untested');
    end else
    begin
      Result := SerializeValue(AValue, ATypeInfo);
    end;
end;

procedure SerializeValue(const AValue: TValue; ATypeInfo: PTypeInfo; out VJSONValue: TJSONValue);
begin
  var ASerializer :=
  {$IF DECLARED(BigInteger) OR DECLARED(BigDecimal)}
    TBigNumberJsonSerializer.Create
  {$ELSE}
    TJsonSerializer.Create
  {$ENDIF}
    ;
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
  if Length(AJSON) = 0 then
    begin
      VCount := 0;
      Exit;
    end;
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

{$IF DEFINED(UseRTL35) OR (RTLVersion < 36.0)}
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
{$ENDIF}

function SameJSON(const AJSON1, AJSON2: TJSONValue): Boolean;
begin
  Result := AJSON1.ToString = AJSON2.ToString;
end;

function SameJSON(const AJSON1, AJSON2: TJSONArray): Boolean;
begin
  Result := AJSON1.Count = AJSON2.Count;
  for var I := 0 to AJSON1.Count-1 do
    begin
      if (AJSON1.Items[I].ClassType = TJSONObject) and
         (AJSON2.Items[I].ClassType = TJSONObject) then
        Result := Result and SameJSON(TJSONObject(AJSON1.Items[I]), TJSONObject(AJSON2.Items[I])) else
        Result := Result and SameJSON(AJSON1.Items[I], AJSON2.Items[I]);
      if not Result then
        Exit(Result);
    end;
end;

function SameJSON(const AJSONObj1, AJSONObj2: TJSONObject): Boolean; overload;
var
  LJSONObj1, LJSONObj2: TJSONObject;
begin
  if AJSONObj1.Count <= AJSONObj2.Count then
    begin
      LJSONObj1 := AJSONObj1;
      LJSONObj2 := AJSONObj2;
    end else
    begin
      LJSONObj2 := AJSONObj1;
      LJSONObj1 := AJSONObj2;
    end;
  Result := LJSONObj1.Count <= LJSONObj2.Count;
  try
    for var I := 0 to LJSONObj1.Count-1 do
      begin
        var LPair1 := LJSONObj1.Pairs[I];
        var LPair2 := LJSONObj2.Get(LPair1.JsonString.Value);

        Result := Result and Assigned(LPair1) and Assigned(LPair2);
        if not Result then
          Exit(Result);

        if (LPair1.JsonValue is TJSONObject) and
           (LPair2.JsonValue.ClassType = LPair1.JsonValue.ClassType) then
          Result := Result and
            SameJSON(LPair1.JsonValue as TJSONObject, LPair2.JsonValue as TJSONObject) else
        if (LPair1.JsonValue is TJSONArray) and
           (LPair2.JsonValue.ClassType = LPair1.JsonValue.ClassType) then
          Result := Result and
            SameJSON(LPair1.JsonValue as TJSONArray, LPair2.JsonValue as TJSONArray) else
        if (LPair1.JsonValue is TJSONValue) and
           (LPair2.JsonValue.ClassType = LPair1.JsonValue.ClassType) then
          Result := Result and
            SameJSON(LPair1.JsonValue, LPair2.JsonValue);
        if not Result then
          Exit(Result);
      end;
  except
    Result := False;
  end;
end;

function SameJSON(const AJSONStr1, AJSONStr2: string): Boolean; overload;
var
  LJSONVal1, LJSONVal2: TJSONValue;

  LJSONObj1: TJSONObject absolute LJSONVal1;
  LJSONObj2: TJSONObject absolute LJSONVal2;

  LJSONArray1: TJSONArray absolute LJSONVal1;
  LJSONArray2: TJSONArray absolute LJSONVal2;
begin
  if AJSONStr1 = AJSONStr2 then
    Exit(True);
  LJSONVal1 := TJSONValue.ParseJSONValue(AJSONStr1);
  try
    LJSONVal2 := TJSONValue.ParseJSONValue(AJSONStr2);
    try
      if (LJSONVal1 is TJSONObject) then
        Result := ((LJSONVal1.ClassType = LJSONVal2.ClassType) and
                   SameJSON(LJSONObj1, LJSONObj2)) else
      if (LJSONVal1 is TJSONArray) then
        Result := ((LJSONVal1.ClassType = LJSONVal2.ClassType) and
                    SameJSON(LJSONArray1, LJSONArray2)) else
        Result := False;
    finally
      LJSONObj2.Free;
    end;
  finally
    LJSONObj1.Free;
  end;
end;

//function SameJson(const AJSON1, AJSON2: string): Boolean;
//var
//  LJSONV1, LJSONV2: TJSONValue;
//  LJSON1, LJSON2: string;
//begin
//  try
//    LJSONV1 := TJSONObject.ParseJSONValue(AJSON1);
//    LJSONV2 := TJSONObject.ParseJSONValue(AJSON2);
//    {$IF DEFINED(DEBUG)}
//    LJSON1 := LJSONV1.ToString;
//    LJSON2 := LJSONV2.ToString;
//    Result := Assigned(LJSONV2) and Assigned(LJSONV1) and (LJSON1 = LJSON2);
//    {$ELSE}
//    Result := Assigned(LJSONV2) and Assigned(LJSONV1) and
//              (LJSONV1.ToString = LJSONV2.ToString);
//    {$ENDIF}
//  except
//    Result := False;
//  end;
//end;

function IfThen(AValue: Boolean; const ATrue: TFunc<Integer>; const AFalse: TFunc<Integer>): Integer;
begin
  if AValue then
    Result := ATrue else
    Result := AFalse;
end;

function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: TFunc<Integer>): Integer;
begin
  if AValue then
    Result := ATrue else
    Result := AFalse;
end;

function IfThen(AValue: Boolean; const ATrue: TFunc<Integer>; const AFalse: Integer): Integer;
begin
  if AValue then
    Result := ATrue else
    Result := AFalse;
end;

function MakeTypeInfo(ATypeKind: TTypeKind): PTypeInfo; experimental;
begin
end;

{ TSaveRestore<T> }

class function TSaveRestore<T>.Create(var OriginVar: T;
  const NewValue: T): IInterface;
var
  LSaveRestore: TSaveRestore<T>;
begin
  LSaveRestore := TSaveRestore<T>.Create;
  LSaveRestore.FValueAddr := @OriginVar;
  LSaveRestore.FOldValue := OriginVar;
  OriginVar := NewValue;
  Result := LSaveRestore as IInterface;
end;

constructor TSaveRestore<T>.Create;
begin
  inherited Create;
end;

destructor TSaveRestore<T>.Destroy;
type
  PT = ^T;
begin
  PT(FValueAddr)^ := FOldValue;
  inherited;
end;

end.



































// chuacw, Jun 2023



