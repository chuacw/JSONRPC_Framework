unit Neslib.MultiPrecision.RecordHandlers;

interface

implementation

uses
  JSONRPC.Common.RecordHandlers, Neslib.MultiPrecision,
  JSONRPC.Common.Types, System.TypInfo, System.JSON, System.Rtti,
  JSONRPC.JsonUtils, JSONRPC.Common.Consts;

initialization
  Neslib.MultiPrecision.MultiPrecisionInit;
  RegisterRecordHandler(TypeInfo(QuadDouble),
    procedure(
      const APassParamByPosOrName: TPassParamByPosOrName;
      ATypeInfo: PTypeInfo;
      const AParamName: string;
      const AParamValuePtr: Pointer;
      const AParamsObj: TJSONObject;
      const AParamsArray: TJSONArray
    )
    // NativeToJSON
    var
      LJSON: TJSONString;
    begin
      LJSON := TJSONString.Create(QuadDouble(AParamValuePtr^).ToString);
      case APassParamByPosOrName of
        tppByName: AParamsObj.AddPair(AParamName, LJSON);
        tppByPos:  AParamsArray.AddElement(LJSON);
      end;
    end,
    procedure(const AJSONResponseObj: TJSONValue; const APathName: string; AResultP: Pointer)
    // JSONToNative
    var
      LResultValue: string;
    begin
      AJSONResponseObj.TryGetValue<string>(APathName, LResultValue);
      PQuadDouble(AResultP)^.Init(LResultValue);
    end,
    procedure(const AValue: TValue; ATypeInfo: PTypeInfo; const AJSONObject: TJSONObject)
    // TValueToJSON
    var
      LBigDecimal: QuadDouble;
      LJSON: string;
    begin
      ValueToObj(AValue, ATypeInfo, LBigDecimal);
      LJSON := LBigDecimal.ToString;
      AJSONObject.AddPair(SRESULT, LJSON);
    end,
    function(const AJSON: string): TValue
    // JSONToTValue
    var
      LQuadDouble: QuadDouble;
    begin
      LQuadDouble.Init(AJSON);
      Result := TValue.From(LQuadDouble);
    end
  );

  // Delphi cannot handle the precision of Extended
  // if the client is 32-bit and the server is 64-bit
  // so convert to BigDecimal

  RegisterRecordHandler(TypeInfo(DoubleDouble),
    // NativeToJSON
    procedure(
      const APassParamByPosOrName: TPassParamByPosOrName;
      ATypeInfo: PTypeInfo;
      const AParamName: string;
      const AParamValuePtr: Pointer;
      const AParamsObj: TJSONObject;
      const AParamsArray: TJSONArray
    )
    var
      LJSON: TJSONString;
    begin
      LJSON := TJSONString.Create(DoubleDouble(AParamValuePtr^).ToString);
      case APassParamByPosOrName of
        tppByName: AParamsObj.AddPair(AParamName, LJSON);
        tppByPos:  AParamsArray.AddElement(LJSON);
      end;
    end,
    // JSONToNative
    procedure(const AJSONResponseObj: TJSONValue; const APathName: string; AResultP: Pointer)
    var
      LResultValue: string;
      LDoubleDouble: DoubleDouble;
    begin
      AJSONResponseObj.TryGetValue<string>(APathName, LResultValue);
      DoubleDouble.TryParse(LResultValue, LDoubleDouble);
      PDoubleDouble(AResultP)^ := LDoubleDouble;
    end,
    // TValueToJSON
    procedure(const AValue: TValue; ATypeInfo: PTypeInfo; const AJSONObject: TJSONObject)
    var
      LDoubleDouble: DoubleDouble;
    begin
      LDoubleDouble := AValue.AsType<DoubleDouble>;
      var LJSON := TJSONNumber.Create(LDoubleDouble.ToString);
      AJSONObject.AddPair(SRESULT, LJSON);
    end,
    // JSONToTValue
    function(const AJSON: string): TValue
    var
      LDoubleDouble: DoubleDouble;
    begin
      DoubleDouble.TryParse(AJSON, LDoubleDouble);
      Result := TValue.From(LDoubleDouble);
    end
  );

end.
