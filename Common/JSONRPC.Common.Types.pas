unit JSONRPC.Common.Types;

{$CODEALIGN 16}

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.JSON.Serializers,
  System.Net.URLClient, System.TypInfo, System.Rtti, Soap.IntfInfo,
  System.Net.HttpClient, System.JSON.Readers, System.JSON.Writers;

type

  THttpMethodTypeEnum = (hConnect, hDelete, hGet, hHead, hMerge, hOptions,
    hPatch, hPost, hPut, hTrace);

  TPassParamByPosOrName = (tppByPos, tppByName);

  TOnBeforeDispatchJSONRPC = reference to procedure (var AJSONResponse: string);
  TOnDispatchedJSONRPC = reference to procedure (const AJSONRequest: string);
  TOnReceivedJSONRPC = reference to procedure (const AJSONRequest: string);
  TOnSentJSONRPC = reference to procedure (const AJSONResponse: string);

  // For client side
  TIntfMethEntry = Soap.IntfInfo.TIntfMethEntry;
  TOnParseEnum = reference to function (const ARttiContext: TRttiContext;
    const AMethMD: TIntfMethEntry;
    AParamIndex: Integer;
    AParamTypeInfo: PTypeInfo; AParamValuePtr: Pointer; AParamsObj: TJSONObject;
    AParamsArray: TJSONArray): Boolean;

  // For client side
  TOnLogOutgoingJSONRequest  = reference to procedure(const AJSONRPCRequest: string);
  TOnLogIncomingJSONResponse = reference to procedure(const AJSONRPCResponse: string);
  TOnLogServerURL = reference to procedure(const AServerURL: string);

  // For server side
  TOnLogIncomingJSONRequest  = reference to procedure(const AJSONRPCRequest: string);
  TOnLogOutgoingJSONResponse = reference to procedure(const AJSONRPCResponse: string);

  TOnSyncEvent = reference to procedure(ARequest, AResponse: TStream);

  TOnSafeCallException = reference to function (ExceptObject: TObject;
    ExceptAddr: Pointer): HResult;

  /// <summary> An attribute to apply on a method to tell the JSON RPC wrapper
  /// to send params by position.
  /// </summary>
  TParamsByPosition = class(TCustomAttribute) end deprecated 'Use PassParamsByPos property';

  /// <summary> An attribute to apply on a method to tell the JSON RPC wrapper
  /// to send params by name.
  /// </summary>
  TParamsByName = class(TCustomAttribute) end deprecated 'Use PassParamsByName property';

  /// <summary> An attribute to apply on a method to tell the JSON RPC wrapper
  /// to prevent it from sending an ID for the JSON RPC call.
  /// </summary>
  JSONNotificationAttribute = class(TCustomAttribute);

  /// <summary> An attribute to override the method name used to call the JSON RPC server.
  /// </summary>
  JSONMethodNameAttribute = class(TCustomAttribute)
  protected
    FMethodName: string;
  public
    constructor Create(const AMethodName: string);
{.$WARN HIDING_MEMBER OFF}
    property Name: string read FMethodName;
{.$WARN HIDING_MEMBER ON}
  end;

  JSONHttpMethodAttribute = class(TCustomAttribute)
  protected
    FHttpMethod: string;
  public
    constructor Create(const AHttpMethod: string);
    property HttpMethod: string read FHttpMethod;
  end;

  /// <summary> Allows enums to be marshalled as numbers instead of strings
  /// </summary>
  JSONMarshalAsNumber = class(TCustomAttribute);

  /// <summary> An attribute to apply on a method to tell the JSON RPC wrapper
  /// to prevent it from sending an ID for the JSON RPC call.
  /// </summary>
  JSONNotifyAttribute = JSONNotificationAttribute;

  /// <summary> An attribute to apply on a method to tell the JSON RPC wrapper
  /// to modify the server URL before calling on it.
  /// </summary>
  UrlSuffixAttribute = class(TCustomAttribute)
  protected
    FUrlSuffix: string;
  public
    constructor Create(const AUrlSuffix: string);
    property UrlSuffix: string read FUrlSuffix;
  end;

  {$METHODINFO ON}
  {$TYPEINFO ON}
  /// <summary> All JSON RPC interfaces needs to inherit from this
  /// </summary>
  IJSONRPCMethods = interface(IInvokable)
    ['{77E7ACCD-3C1E-45CF-8DA9-171444F5338F}']
  end;
  {$METHODINFO OFF}
  {$TYPEINFO OFF}

  IJSONRPCDispatch = interface
    ['{9E733EDC-7639-4DAF-96FF-BCF141F7D8F2}']
    procedure DispatchJSONRPC(const ARequest, AResponse: TStream);
  end;

  IJSONRPCDispatchEvents = interface
    ['{85A741DE-6B8C-4481-A001-9A62D76D027A}']
    procedure DoDispatchedJSONRPC(const AJSONRequest: string);
    procedure DoLogIncomingRequest(const ARequest: string);
    procedure DoLogOutgoingResponse(const AResponse: string);
  end;

  /// <summary> A client class implements this interface in order to
  /// allow getting and setting safecall exception handlers.
  /// </summary>
  ISafeCallException = interface
    ['{4CBE5D30-42FD-473A-B784-1B36A7129D6D}']
    function GetOnSafeCallException: TOnSafeCallException;
    procedure SetOnSafeCallException(const AProc: TOnSafeCallException);

    property OnSafeCallException: TOnSafeCallException read GetOnSafeCallException
      write SetOnSafeCallException;
  end;

  /// <summary> A client class implements this interface in order to signify that
  ///  it allows consumers to monitor incoming responses and outgoing requests.
  /// </summary>
  IJSONRPCClientLog = interface
    ['{846F7319-7FFF-4634-BDB4-6D518C65E5A6}']

    function GetOnLogOutgoingJSONRequest: TOnLogOutgoingJSONRequest;
    procedure SetOnLogOutgoingJSONRequest(const AProc: TOnLogOutgoingJSONRequest);

    function GetOnLogIncomingJSONResponse: TOnLogIncomingJSONResponse;
    procedure SetOnLogIncomingJSONResponse(const AProc: TOnLogIncomingJSONResponse);

    function GetOnLogServerURL: TOnLogServerURL;
    procedure SetOnLogServerURL(const AProc: TOnLogServerURL);

    property OnLogOutgoingJSONRequest: TOnLogOutgoingJSONRequest
      read GetOnLogOutgoingJSONRequest write SetOnLogOutgoingJSONRequest;
    property OnLogIncomingJSONResponse: TOnLogIncomingJSONResponse
      read GetOnLogIncomingJSONResponse write SetOnLogIncomingJSONResponse;
    property OnLogServerURL: TOnLogServerURL
      read GetOnLogServerURL write SetOnLogServerURL;
  end;

  /// <summary> A server class implements this interface in order to signify that
  ///  it allows consumers to monitor incoming requests and outgoing responses.
  /// </summary>
  IJSONRPCServerLog = interface
    ['{3CD1A72D-3A00-4A07-8295-E0EDDBB32F20}']
    function GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
    procedure SetOnLogIncomingJSONRequest(const AProc: TOnLogIncomingJSONRequest);

    function GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
    procedure SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);

    /// <summary>
    /// Provides access to the OnLogIncomingJSONRequest property of the server
    /// You can assign your routine to this, and your routine will be called
    /// before the server reads the incoming JSON request.
    /// </summary>
    property OnLogIncomingJSONRequest: TOnLogIncomingJSONRequest
      read GetOnLogIncomingJSONRequest write SetOnLogIncomingJSONRequest;

    /// <summary>
    /// Provides access to the OnLogOutgoingJSONResponse property of the server
    /// You can assign your routine to this, and your routine will be called
    /// before the server sends its response.
    /// </summary>
    property OnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse
      read GetOnLogOutgoingJSONResponse write SetOnLogOutgoingJSONResponse;
  end;

  IJSONRPCGetSetDispatchEvents = interface
    ['{48A201AB-42B9-4EB2-B6D8-8B6E47EED9F5}']

    function GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);

    property OnDispatchedJSONRPC: TOnDispatchedJSONRPC read GetOnDispatchedJSONRPC
      write SetOnDispatchedJSONRPC;

  end;

  IJSONRPCInvocationSettings = interface
    ['{F5412FA7-D6A5-4BF7-8A40-E556ABF6432E}']
    function GetParamsPassByPosition: Boolean;
    function GetParamsPassByName: Boolean;
    procedure SetParamsPassByPosition(const AValue: Boolean);
    procedure SetParamsPassByName(const AValue: Boolean);

    function GetConnectionTimeout: Integer;
    function GetSendTimeout: Integer;
    function GetResponseTimeout: Integer;
    procedure SetConnectionTimeout(const Value: Integer);
    procedure SetSendTimeout(const Value: Integer);
    procedure SetResponseTimeout(const Value: Integer);

    property PassParamsByPosition: Boolean read GetParamsPassByPosition write SetParamsPassByPosition;
    property PassParamsByName: Boolean read GetParamsPassByName write SetParamsPassByName;

    property ConnectionTimeout: Integer read GetConnectionTimeout write SetConnectionTimeout;
    property SendTimeout: Integer read GetSendTimeout write SetSendTimeout;
    property ResponseTimeout: Integer read GetResponseTimeout write SetResponseTimeout;
  end;

  IJSONRPCException = interface
    ['{2CEF2D46-2CB5-4521-BEC3-EFF2EF219C88}']
    function GetCode: Integer;
    procedure SetCode(ACode: Integer);
    property Code: Integer read GetCode write SetCode;

    function GetMessage: string;
    procedure SetMessage(const AMsg: string);
    property Message: string read GetMessage write SetMessage;
  end;

  IJSONRPCMethodException = interface(IJSONRPCException)
    ['{292C126A-5F91-48EB-AFDB-188B1F3D3D47}']
    function GetMethodName: string;
    procedure SetMethodName(const AMethodName: string);

    property MethodName: string read GetMethodName write SetMethodName;
  end;

{$M+}
  /// <summary> An exception class that contains the JSON RPC Code
  /// </summary>
  EJSONRPCException = class(Exception)
  protected
    FCode: Integer;
  public
    constructor Create(ACode: Integer; const AMsg: string); overload;
    constructor Create(AExceptObj: TObject); overload;
    property Code: Integer read FCode write FCode;
  end;
{$M-}

  /// <summary> An exception class that contains the Method Name.
  /// </summary>
  EJSONRPCMethodException = class(EJSONRPCException)
  protected
    FMethodName: string;
  public
    constructor Create(ACode: Integer; const AMsg: string; const AMethodName: string); overload;
    constructor Create(AExceptObj: TObject); overload;
{$WARN HIDING_MEMBER OFF}
    property MethodName: string read FMethodName write FMethodName;
{$WARN HIDING_MEMBER ON}
  end;

  EJSONRPCMethodMissingException = class(EJSONRPCException)
  end;

  TTransportWrapperType = (twtHTTP, twtTCP);

  TJSONRPCBoolean = class(TJSONBool)
  public
    function Value: string; override;
  end;

  [JsonSerialize(TJsonMemberSerialization.Fields)]
  TError = record
  private
    Fcode: Integer;
    Fmessage: string;
  public
    property code: Integer read Fcode write Fcode;
    property message: string read Fmessage write Fmessage;
  end align 16;

  TTrackedMemoryStream = class;

  TJSONRPCTransportWrapper = class abstract
  protected
    FRequestStream,
    FResponseStream: TTrackedMemoryStream;

    procedure CheckStream(AStream: TStream);

    function GetConnected: Boolean; virtual; abstract;
    function GetRequestStream: TStream; virtual; abstract;
    function GetResponseStream: TStream; virtual; abstract;

    function GetConnectionTimeout: Integer; virtual; abstract;
    function GetResponseTimeout: Integer; virtual; abstract;
    function GetSendTimeout: Integer; virtual; abstract;
    procedure SetConnectionTimeout(const Value: Integer); virtual; abstract;
    procedure SetResponseTimeout(const Value: Integer); virtual; abstract;
    procedure SetSendTimeout(const Value: Integer); virtual; abstract;
  public
    procedure Connect; virtual;

    constructor Create; virtual; abstract;
    destructor Destroy; override;
    procedure Post(const AURL: string; const ASource, AResponseContent: TStream;
      const AHeaders: TNetHeaders); virtual; abstract;
    function HttpMethod(const AMethod: string; const AURL: string;
      const ASource, AResponseContent: TStream;
      const AHeaders: TNetHeaders): IHTTPResponse; virtual; abstract;
    property ConnectionTimeout: Integer read GetConnectionTimeout write SetConnectionTimeout;
    property ResponseTimeout: Integer read GetResponseTimeout write SetResponseTimeout;
    property SendTimeout: Integer read GetSendTimeout write SetSendTimeout;

    property Connected: Boolean read GetConnected;

    property RequestStream: TStream read GetRequestStream;
    property ResponseStream: TStream read GetResponseStream;

  end;

  TJSONRPCTransportWrapperClass = class of TJSONRPCTransportWrapper;

  TTrackedMemoryStream = class(TMemoryStream)
  protected
    FProc: TProc<TStream>;
  public
    constructor Create(const AProc: TProc<TStream>);
    destructor Destroy; override;
  end;

  // 17045a12
  TJsonHexConverter = class(TJsonConverter)
  public
    function CanConvert(ATypeInfo: PTypeInfo): Boolean; override;
    function CanRead: Boolean; override;
    function CanWrite: Boolean; override;
  end;

  TJsonPrefixHexConverter = class(TJsonHexConverter)
  protected
    FPrefix: string;
  public
    constructor Create(const APrefix: string);
    function ReadJson(const AReader: TJsonReader; ATypeInfo: PTypeInfo;
      const AExistingValue: TValue; const ASerializer: TJsonSerializer): TValue; override;
    {$MESSAGE WARN 'Untested'}
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;
  end;

  TJsonDelphiHexConverter = class(TJsonPrefixHexConverter)
  public
    procedure AfterConstruction; override;
  end;

  TJsonCppHexConverter = class(TJsonPrefixHexConverter)
  public
    procedure AfterConstruction; override;
  end;

var
  GOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
  GOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
  GOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
  GJSONRPCTransportWrapperClass: TJSONRPCTransportWrapperClass;

{$IF SizeOf(Extended) > SizeOf(Double)}
  {$DEFINE HasExtended}
{$IFEND}
implementation

uses
  JSONRPC.Common.RecordHandlers, Velthuis.BigDecimals, Velthuis.BigIntegers,
  JSONRPC.JsonUtils, JSONRPC.Common.Consts;

{ TJSONRPCBoolean }

function TJSONRPCBoolean.Value: string;
begin
  Result := LowerCase(inherited);
  Result[1] := UpCase(Result[1]);
end;

{ EJSONRPCException }

constructor EJSONRPCException.Create(ACode: Integer; const AMsg: string);
begin
  inherited Create(AMsg);
  FCode := ACode;
end;

constructor EJSONRPCException.Create(AExceptObj: TObject);
var
  LExc: EJSONRPCException absolute AExceptObj;
begin
  Create(LExc.Code, LExc.Message);
end;

{ EJSONRPCMethodException }

constructor EJSONRPCMethodException.Create(ACode: Integer; const AMsg,
  AMethodName: string);
begin
  inherited Create(ACode, AMsg);
  FMethodName := AMethodName;
end;

constructor EJSONRPCMethodException.Create(AExceptObj: TObject);
var
  LExc: EJSONRPCMethodException absolute AExceptObj;
begin
  Create(LExc.Code, LExc.Message, LExc.MethodName);
end;

{ TJSONRPCTransportWrapper }

procedure TJSONRPCTransportWrapper.CheckStream(AStream: TStream);
begin
  if AStream = FRequestStream then
    FRequestStream := nil else
  if AStream = FResponseStream then
    FResponseStream := nil;
end;

procedure TJSONRPCTransportWrapper.Connect;
begin
end;

destructor TJSONRPCTransportWrapper.Destroy;
begin
  FRequestStream.Free;
  FResponseStream.Free;
  inherited;
end;

{ TTrackedMemoryStream }

constructor TTrackedMemoryStream.Create(const AProc: TProc<TStream>);
begin
  inherited Create;
  FProc := AProc;
end;

destructor TTrackedMemoryStream.Destroy;
begin
  if Assigned(FProc) then
    FProc(Self);
  inherited;
end;

{ JSONMethodNameAttribute }

constructor JSONMethodNameAttribute.Create(const AMethodName: string);
begin
  FMethodName := AMethodName;
end;

{ UrlSuffixAttribute }

constructor UrlSuffixAttribute.Create(const AUrlSuffix: string);
begin
  FUrlSuffix := AUrlSuffix;
end;

{ JSONHttpMethodAttribute }

constructor JSONHttpMethodAttribute.Create(const AHttpMethod: string);
begin
  inherited Create;
  FHttpMethod := AHttpMethod;
end;

{ TJsonHexConverter }

function TJsonHexConverter.CanConvert(ATypeInfo: PTypeInfo): Boolean;
begin
  Result := ATypeInfo.Kind = tkString;
end;

function TJsonHexConverter.CanRead: Boolean;
begin
  Result := True;
end;

function TJsonHexConverter.CanWrite: Boolean;
begin
  Result := True;
end;

{ TJsonPrefixHexConverter }

constructor TJsonPrefixHexConverter.Create(const APrefix: string);
begin
  inherited Create;
  FPrefix := APrefix;
end;

function TJsonPrefixHexConverter.ReadJson(const AReader: TJsonReader;
  ATypeInfo: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
var
  I: Integer;
  S: string;
begin
  S := FPrefix + AReader.Value.AsString;
  if TryStrToInt(S, I) then
    Result := TValue.From(I);
end;

procedure TJsonPrefixHexConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
begin
  ASerializer.Serialize(AWriter, AValue);
end;

{ TJsonDelphiHexConverter }

procedure TJsonDelphiHexConverter.AfterConstruction;
begin
  FPrefix := '$';
end;

{ TJsonCppHexConverter }

procedure TJsonCppHexConverter.AfterConstruction;
begin
  FPrefix := '0x';
end;

initialization

  RegisterRecordHandler(TypeInfo(BigDecimal),
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
      LJSON := TJSONString.Create(BigDecimal(AParamValuePtr^).ToString);
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
      PBigDecimal(AResultP)^.Create(LResultValue);
    end,
    procedure(const AValue: TValue; ATypeInfo: PTypeInfo; const AJSONObject: TJSONObject)
    // TValueToJSON
    var
      LBigDecimal: BigDecimal;
      LJSON: string;
    begin
      ValueToObj(AValue, ATypeInfo, LBigDecimal);
      LJSON := LBigDecimal.ToString;
      AJSONObject.AddPair(SRESULT, LJSON);
    end,
    function(const AJSON: string): TValue
    // JSONToTValue
    begin
      Result := TValue.From(BigDecimal.Create(AJSON));
    end
  );

  // Delphi cannot handle the precision of Extended
  // if the client is 32-bit and the server is 64-bit
  // then convert to BigDecimal

  RegisterRecordHandler(TypeInfo(Extended),
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
      LBigDecimal: BigDecimal;
      LJSON: TJSONString;
    begin
      LBigDecimal := BigDecimal.Create(Extended(AParamValuePtr^));
      LJSON := TJSONString.Create(LBigDecimal.ToString);
      case APassParamByPosOrName of
        tppByName: AParamsObj.AddPair(AParamName, LJSON);
        tppByPos:  AParamsArray.AddElement(LJSON);
      end;
    end,
    // JSONToNative
    procedure(const AJSONResponseObj: TJSONValue; const APathName: string; AResultP: Pointer)
    var
      LResultValue: string;
      LBigDecimal: BigDecimal;
    begin
      AJSONResponseObj.TryGetValue<string>(APathName, LResultValue);
      BigDecimal.TryParse(LResultValue, LBigDecimal);
      {$IF DEFINED(HasExtended)}
      PExtended(AResultP)^ := LBigDecimal.AsExtended;
      {$ELSE}
      PExtended(AResultP)^ := LBigDecimal.AsDouble;
      {$ENDIF}
    end,
    // TValueToJSON
    procedure(const AValue: TValue; ATypeInfo: PTypeInfo; const AJSONObject: TJSONObject)
    var
      LBigDecimal: Extended;
    begin
      LBigDecimal := AValue.AsExtended;
      var LJSON := TJSONNumber.Create(LBigDecimal.ToString);
      AJSONObject.AddPair(SRESULT, LJSON);
    end,
    // JSONToTValue
    function(const AJSON: string): TValue
    begin
      Result := TValue.From(StrToFloat(AJSON));
    end
  );

  RegisterRecordHandler(TypeInfo(BigInteger),
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
      BigInteger.Hex;
      LJSON := TJSONString.Create('0x'+BigInteger(AParamValuePtr^).ToString(16));
      case APassParamByPosOrName of
        tppByName: AParamsObj.AddPair(AParamName, LJSON);
        tppByPos:  AParamsArray.AddElement(LJSON);
      end;
    end,
    // JSONToNative
    procedure(const AJSONResponseObj: TJSONValue; const APathName: string; AResultP: Pointer)
    var
      LDecimalPlaces: Integer;
      LResultValue: string;
    begin
      AJSONResponseObj.TryGetValue<string>(APathName, LResultValue);
      if LResultValue.StartsWith('0x', True) then
        begin
          LResultValue := Copy(LResultValue, Low(LResultValue) + 2);
          LDecimalPlaces := 16;
        end else
        begin
          LDecimalPlaces := 10;
        end;
      BigInteger.TryParse(LResultValue, LDecimalPlaces, PBigInteger(AResultP)^);
    end,
    procedure(const AValue: TValue; ATypeInfo: PTypeInfo; const AJSONObject: TJSONObject)
    // TValueToJSON
    var
      LBigInteger: BigInteger;
      LJSON: string;
    begin
      // LResult is a TValue from BigDecimal
      ValueToObj(AValue, ATypeInfo, LBigInteger);
      LJSON := LBigInteger.ToString;
      AJSONObject.AddPair(SRESULT, LJSON);
    end,
    function(const AJSON: string): TValue
    // JSONToTValue
    var
      LParamValue: string;
      LBigInteger: BigInteger;
      LDecimalPlaces: Integer;
    begin
      if AJSON.StartsWith('0x', True) then
        begin
          LParamValue := Copy(AJSON, Low(LParamValue) + 2);
          LDecimalPlaces := 16;
        end else
        begin
          LParamValue := AJSON;
          LDecimalPlaces := 10;
        end;
      BigInteger.TryParse(LParamValue, LDecimalPlaces, LBigInteger);
      Result := TValue.From(LBigInteger);
    end
  );

end.
