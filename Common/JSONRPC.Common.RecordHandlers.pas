unit JSONRPC.Common.RecordHandlers;

interface

uses
  System.TypInfo, System.JSON, JSONRPC.Common.Types, System.Rtti;

type

  /// <summary>
  /// Client-side
  /// </summary>
  TNativeToJSON = reference to procedure(
    const APassParamByPosOrName: TPassParamByPosOrName;
    const AParamName: string;
    const AParamValuePtr: Pointer;
    const AParamsObj: TJSONObject;
    const AParamsArray: TJSONArray
  );
  TJSONToNative = reference to procedure(
    const AResponseObj: TJSONValue;
    const APathName: string; AResultP: Pointer
  );

  TTValueToJSON = reference to procedure(
    const AValue: TValue;
    ATypeInfo: PTypeInfo;
    const AJSONObject: TJSONObject
  );
  TJSONToTValue = reference to function(
    const AJSON: string
  ): TValue;

  TRecordHandlers = record
    NativeToJSON: TNativeToJSON;
    JSONToNative: TJSONToNative;
    TValueToJSON: TTValueToJSON;
    JSONToTValue: TJSONToTValue;
  public
    constructor Create(
      const ANativeToJSON: TNativeToJSON;
      const AJSONToNative: TJSONToNative;
      const ATValueToJSON: TTValueToJSON;
      const AJSONToTValue: TJSONToTValue
    );
  end;
  PRecordHandlers = ^TRecordHandlers;

/// <summary>
/// Looks up record handlers for a record with a specific TypeInfo
/// </summary>
/// <param name="ATypeInfo">The TypeInfo for the native record</param>
/// <param name="OHandlers">A variable of the type <see cref="TRecordHandlers"></param>
function LookupRecordHandlers(ATypeInfo: PTypeInfo; out OHandlers: TRecordHandlers): Boolean;

/// <summary>
/// Register a handler for a record with a specific TypeInfo
/// </summary>
/// <param name="ATypeInfo">The TypeInfo for the native record
/// <code>reference to procedure(
///  const APassParamByPosOrName: TPassParamByPosOrName;
///  const AParamName: string;
///  const AParamValuePtr: Pointer;
///  const AParamsObj: TJSONObject;
///  const AParamsArray: TJSONArray
///);
/// </code>
/// </param>
/// <param name="ANativeToJSON">Converts the native record to JSON
/// <code>reference to procedure(
///  const AResponseObj: TJSONValue;
///  const APathName: string; AResultP: Pointer
///);</code>
/// </param>
/// <param name="AJSONToNative">Converts the JSON string to a native record
/// <code>reference to procedure(
///  const AValue: TValue;
///  ATypeInfo: PTypeInfo;
///  const AJSONObject: TJSONObject
///);</code>
/// </param>
/// <param name="ATValueToJSON">Converts a TValue to a JSON string
/// <code>reference to procedure(
///  const AValue: TValue;
///  ATypeInfo: PTypeInfo;
///  const AJSONObject: TJSONObject
/// );
/// </code></param>
/// <param name="AJSONToTValue">Converts a JSON string to a TValue
/// <code>reference to function(
///  const AJSONRequestObj: TJSONObject;
///  const AParamName: string
/// ): TValue;</code></param>
procedure RegisterRecordHandler(
  ATypeInfo: PTypeInfo;
  const ANativeToJSON: TNativeToJSON;
  const AJSONToNative: TJSONToNative;
  const ATValueToJSON: TTValueToJSON;
  const AJSONToTValue: TJSONToTValue
);

implementation

uses
  System.Generics.Collections;

constructor TRecordHandlers.Create(
  const ANativeToJSON: TNativeToJSON;
  const AJSONToNative: TJSONToNative;
  const ATValueToJSON: TTValueToJSON;
  const AJSONToTValue: TJSONToTValue
);
begin
  NativeToJSON := ANativeToJSON;
  JSONToNative := AJSONToNative;
  TValueToJSON := ATValueToJSON;
  JSONToTValue := AJSONToTValue;
end;

var
  Handlers: TDictionary<PTypeInfo, TRecordHandlers>;

function LookupRecordHandlers(ATypeInfo: PTypeInfo; out OHandlers: TRecordHandlers): Boolean;
var
  LNativeToJSON: TNativeToJSON;
  LJSONToNative: TJSONToNative;
  LTValueToJSON: TTValueToJSON;
  LJSONToTValue: TJSONToTValue;
begin
  Result := Handlers.TryGetValue(ATypeInfo, OHandlers);
  LNativeToJSON := OHandlers.NativeToJSON;
  LJSONToNative := OHandlers.JSONToNative;
  LTValueToJSON := OHandlers.TValueToJSON;
  LJSONToTValue := OHandlers.JSONToTValue;

  OHandlers.NativeToJSON := procedure(
    const APassParamByPosOrName: TPassParamByPosOrName;
    const AParamName: string;
    const AParamValuePtr: Pointer;
    const AParamsObj: TJSONObject;
    const AParamsArray: TJSONArray
  )
  begin
    if Assigned(LNativeToJSON) then
      LNativeToJSON(APassParamByPosOrName, AParamName, AParamValuePtr,
        AParamsObj, AParamsArray);
  end;
  OHandlers.JSONToNative := procedure(
    const AResponseObj: TJSONValue;
    const APathName: string; AResultP: Pointer
  )
  begin
    if Assigned(LJSONToNative) then
      LJSONToNative(AResponseObj, APathName, AResultP);
  end;
  OHandlers.TValueToJSON := procedure(
    const AValue: TValue;
    ATypeInfo: PTypeInfo;
    const AJSONObject: TJSONObject
  )
  begin
    if Assigned(LTValueToJSON) then
      LTValueToJSON(AValue, ATypeInfo, AJSONObject);
  end;
  OHandlers.JSONToTValue := function(
    const AJSON: string
  ): TValue
  begin
    if Assigned(LJSONToTValue) then
      Result := LJSONToTValue(AJSON);
  end;
end;

procedure RegisterRecordHandler(
  ATypeInfo: PTypeInfo;
  const ANativeToJSON: TNativeToJSON;
  const AJSONToNative: TJSONToNative;
  const ATValueToJSON: TTValueToJSON;
  const AJSONToTValue: TJSONToTValue
);
begin
  Handlers.Add(ATypeInfo, TRecordHandlers.Create(
    ANativeToJSON, AJSONToNative, ATValueToJSON, AJSONToTValue)
  );
end;

{ THandler }

initialization
  Handlers := TDictionary<PTypeInfo, TRecordHandlers>.Create;
finalization
  Handlers.Free;
end.
