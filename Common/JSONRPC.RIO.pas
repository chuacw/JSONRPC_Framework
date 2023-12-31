unit JSONRPC.RIO;

{$DEFINE BASECLASS}
{$DEFINE SUPPORTS_JSONOBJECT_AS_RESULT}

{$CODEALIGN 16}
{$IOCHECKS OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

interface

uses
  System.TypInfo, System.Classes, System.Rtti, System.Generics.Collections,
  System.JSON.Serializers,
  JSONRPC.InvokeRegistry, System.SysUtils,
  Soap.IntfInfo, Soap.Rio,
  System.Net.HttpClient, JSONRPC.Common.Types, System.JSON,
  System.Net.URLClient;

type
  TJSONRPCWrapper = class;

  IJSONRPCMethods = JSONRPC.Common.Types.IJSONRPCMethods;

  TOnBeforeParseEvent = reference to procedure(const AContext: TInvContext;
    AMethNum: Integer; const AMethMD: TIntfMethEntry; const AMethodID: Int64;
    AJSONResponse: TStream);

  TNetHeaders = System.Net.URLClient.TNetHeaders;
  TNameValuePair = System.Net.URLClient.TNameValuePair;
  TOnBeforeInitializeHeaders = reference to procedure(var ANetHeaders: TNetHeaders);
  TOnAfterInitializeHeaders = reference to procedure(var ANetHeaders: TNetHeaders);

  TInvContext = JSONRPC.InvokeRegistry.TInvContext;
  TIntfMethEntryHelper = record helper for TIntfMethEntry
  public
    function JSONMethodName(const ARttiContext: TRttiContext): string;
  end;

{$IF DEFINED(BASECLASS)}
  TBaseJSONRPCWrapper = class abstract(TComponent)
  protected
  var
    FIntfMD: TIntfMetaData;
    procedure InitClient; virtual; abstract;
    procedure SetInvokeMethod; virtual; abstract;
    procedure DoDispatch(const AContext: TInvContext; AMethNum: Integer;
      const AMethMD: TIntfMethEntry); virtual;
    function InternalQI(const IID: TGUID; out Obj): HResult; virtual; stdcall; abstract;
  type
    TRioVirtualInterface = class(TVirtualInterface, ISafeCallException)
    protected
      FRio: TJSONRPCWrapper;
      function _AddRef: Integer; override; stdcall;
      function _Release: Integer; override; stdcall;
    public
      constructor Create(ARio: TJSONRPCWrapper; AInterface: Pointer);
      destructor Destroy; override;
      function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;

      /// <summary> Calls user-specified safecall exception handler defined in the
      /// JSON RPC wrapper
      /// </summary>
      function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HRESULT; override;

      /// <summary> Gets the user-specified safecall exception handler
      /// </summary>
      function GetOnSafeCallException: TOnSafeCallException;
      /// <summary> Sets the user-specified safecall exception handler
      /// </summary>
      procedure SetOnSafeCallException(const AProc: TOnSafeCallException);

      /// <summary> Allows set/getting of the user-specified safecall exception handler
      /// </summary>
      property OnSafeCallException: TOnSafeCallException read GetOnSafeCallException
        write SetOnSafeCallException;
     end;
  end;
{$ENDIF}

  IJSONRPCWrapper = interface
    ['{EA0EF076-3AFD-48DC-84EC-32B7344B7581}']
    function GetJSONRPCWrapper: TJSONRPCWrapper;
    property JSONRPCWrapper: TJSONRPCWrapper read GetJSONRPCWrapper;
  end;

  /// <summary> JSON RPC client side
  /// </summary>
  TJSONRPCWrapper = class(
    {$IF DEFINED(BASECLASS)}
    TBaseJSONRPCWrapper,
    {$ELSE}
    TComponent,
    {$ENDIF}
    IInvokable, IJSONRPCInvocationSettings, ISafeCallException, IJSONRPCWrapper,
    IJSONRPCClientLog)
  protected
  {$IF NOT DEFINED(BASECLASS)}
  type
    TPassParamByPosOrName = (tppByPos, tppByName);
  {$ENDIF}
  var
    FExceptObj: TObject;
    FServerURL: string;
    FClient: TJSONRPCTransportWrapper;
    {$IF NOT DEFINED(BASECLASS)}
    FIntfMD: TIntfMetaData;
    {$ENDIF}
    FInterface: IInterface;
    FOnBeforeExecute: TBeforeExecuteEvent;
    FOnAfterExecute: TAfterExecuteEvent;
    FOnBeforeParse: TOnBeforeParseEvent;

    FOnBeforeInitializeHeaders: TOnBeforeInitializeHeaders;
    FOnAfterInitializeHeaders: TOnAfterInitializeHeaders;
    FMethodNames: TArray<string>;

    FOnSync: TOnSyncEvent;
    FPassByPosOrName: TPassParamByPosOrName;
    FOnSafeCallException: TOnSafeCallException;
    FIID: TGUID;
    FRefCount: Integer;
    FOnLogOutgoingJSONRequest: TOnLogOutgoingJSONRequest;
    FOnLogIncomingJSONResponse: TOnLogIncomingJSONResponse;
    FOnLogServerURL: TOnLogServerURL;
    FOnParseEnum: TOnParseEnum;
    FRttiContext: TRttiContext;
    FOwnsObjects: Boolean;
    FJSONObjects: TList<TJSONValue>;

    class var FRegistry: TDictionary<TGUID, PTypeInfo>;

    procedure SetServerURL(const Value: string); virtual;
{$IF NOT DEFINED(BASECLASS)}
  type
    TRioVirtualInterface = class(TVirtualInterface)
    private
      FRio: TJSONRPCWrapper;
    protected
      function _AddRef: Integer; override; stdcall;
      function _Release: Integer; override; stdcall;
    public
      constructor Create(ARio: TJSONRPCWrapper; AInterface: Pointer);
      function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
    end;
{$ENDIF}
  protected
    class procedure RegisterWrapper(const ATypeInfo: PTypeInfo); static;
    class constructor Create;
    class destructor Destroy;

    // These help in unit testing
    procedure DoAfterExecute(const AMethodName: string; AJSONRequest: TStream); virtual;
    procedure DoBeforeExecute(const AMethodName: string; AJSONRequest: TStream); virtual;
    procedure DoBeforeParse(const AContext: TInvContext;  AMethNum: Integer;
      const AMethMD: TIntfMethEntry; const AMethodID: Int64; AJSONResponse: TStream); virtual;

    procedure DoSync(AJSONRequest, AJSONResponse: TStream); virtual;

    procedure DoDispatch(const AContext: TInvContext; AMethNum: Integer; const AMethMD: TIntfMethEntry); {$IF DEFINED(BASECLASS)}override;{$ENDIF}
    procedure DoLogOutgoingRequest(const ARequest: string);
    procedure DoLogIncomingResponse(const AResponse: string);

    function DoParseEnum(const ARttiContext: TRttiContext;
      const AMethMD: TIntfMethEntry;
      AParamIndex: Integer;
      AParamTypeInfo: PTypeInfo; AParamValuePtr: Pointer;
      AParamsObj: TJSONObject; AParamsArray: TJSONArray): Boolean; virtual;

    procedure DoBeforeInitializeHeaders(var VNetHeaders: TNetHeaders);
    procedure DoAfterInitializeHeaders(var VNetHeaders: TNetHeaders);

    /// <summary>
    /// Called when there's no code that can parse the result.
    /// Return false in order not to cause an error
    /// </summary>
    function DoParseUnhandledResult(AJSONResponseObj: TJSONValue; AResultP: Pointer): Boolean;

    /// <summary>
    /// Called before the result is parsed.
    /// Return false to continue default parsing
    /// </summary>
    function DoParseJSONResult(ATypeInfo: PTypeInfo; AJSONResponseObj: TJSONValue; AResultP: Pointer): Boolean;

    /// <summary>
    /// Called when the final server URL has changed before a request is going to be submitted.
    /// This is for JSON RPC servers like Aptos, where every method has a different URL.
    /// </summary>
    procedure DoLogServerURL(const AURL: string);

    function InternalQI(const IID: TGUID; out Obj): HResult; override; stdcall;

    procedure InitClient; {$IF DEFINED(BASECLASS)}override;{$ELSE}virtual;{$ENDIF}
    procedure SetInvokeMethod; {$IF DEFINED(BASECLASS)}override;{$ELSE}virtual;{$ENDIF}

    procedure GenericClientMethod(AMethod: TRttiMethod; const AArgs: TArray<TValue>; out Result: TValue);
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    function GetMethod(const AMethMD: TIntfMethEntry): TRttiMethod;

    /// <summary>
    /// Obtains the cached method name. Can be the native name, or a name
    /// specified by the JSONMethodName attribute.
    /// </summary>
    function GetMethodName(const AMethMD: TIntfMethEntry): string;

    { IJSONRPCInvocationSettings }
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

    { ISafeCallException }
    function GetOnSafeCallException: TOnSafeCallException;
    procedure SetOnSafeCallException(const AProc: TOnSafeCallException);

    procedure FreeException;
    function SerializeRecord(const [ref] VRecord; ATypeInfo: PTypeInfo): string; virtual;
    procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo;
      var VValue: TValue); overload; virtual;
    procedure DeserializeJSON(const AJsonValue: TJSONValue; ATypeInfo: PTypeInfo;
      var VRestoredRecord); overload; virtual;

    /// <summary>
    ///    Sets up (or not) HTTP headers (or any other headers) before sending
    ///    the request.
    /// </summary>
    function InitializeHeaders(const ARequestStream: TStream): TNetHeaders; virtual;

    /// <summary>
    ///    Sends the request from the client over to the server
    /// </summary>
    procedure SendGetPost(const AServerURL: string;
      const ARequestStream, AResponseStream: TStream;
      const AHeaders: TNetHeaders); virtual;

    procedure HttpMethod(const AHttpMethod, AServerURL: string;
      const ARequestStream, AResponseStream: TStream;
      const AHeaders: TNetHeaders);

    { IJSONRPCWrapper }
    function GetJSONRPCWrapper: TJSONRPCWrapper;

    function GetHttpMethod(const AMethodType: TRttiType;
      const AMethMD: TIntfMethEntry): string;
    function GetUrlSuffix(const AMethodType: TRttiType;
      const AMethMD: TIntfMethEntry): string;

    procedure UpdateServerURL(
      const AContext: TInvContext;
      const AMethMD: TIntfMethEntry; var VServerURL: string); virtual;

    function CloneAndTrackJSONObjectToFree(const AJSONObj: TJSONValue): TJSONObject;
    procedure FreeLastResponse;

    function GetOnLogOutgoingJSONRequest: TOnLogOutgoingJSONRequest;
    procedure SetOnLogOutgoingJSONRequest(const AProc: TOnLogOutgoingJSONRequest);

    function GetOnLogIncomingJSONResponse: TOnLogIncomingJSONResponse;
    procedure SetOnLogIncomingJSONResponse(const AProc: TOnLogIncomingJSONResponse);

    function GetOnLogServerURL: TOnLogServerURL;
    procedure SetOnLogServerURL(const AProc: TOnLogServerURL);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function NewInstance: TObject; override;
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
    /// <summary> Calls the user-specified safecall exception handler.
    /// If not specified, will route to the default safecall exception handler defined
    /// in the inheritance hierarchy
    /// </summary>
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
    property ServerURL: string read FServerURL write SetServerURL;

    property OnAfterExecute: TAfterExecuteEvent read FOnAfterExecute write FOnAfterExecute;
    property OnBeforeExecute: TBeforeExecuteEvent read FOnBeforeExecute write FOnBeforeExecute;

    property OnBeforeParse: TOnBeforeParseEvent read FOnBeforeParse write FOnBeforeParse;

    property OnBeforeInitializeHeaders: TOnBeforeInitializeHeaders
      read FOnBeforeInitializeHeaders write FOnBeforeInitializeHeaders;
    property OnAfterInitializeHeaders: TOnAfterInitializeHeaders
      read FOnAfterInitializeHeaders write FOnAfterInitializeHeaders;

    property OnLogOutgoingJSONRequest: TOnLogOutgoingJSONRequest
      read GetOnLogOutgoingJSONRequest write SetOnLogOutgoingJSONRequest;
    property OnLogIncomingJSONResponse: TOnLogIncomingJSONResponse
      read GetOnLogIncomingJSONResponse write SetOnLogIncomingJSONResponse;
    property OnLogServerURL: TOnLogServerURL
      read GetOnLogServerURL write SetOnLogServerURL;

    property OnParseEnum: TOnParseEnum read FOnParseEnum write FOnParseEnum;

    /// <summary> Specifies that safecall exception handler
    /// </summary>
    property OnSafeCallException: TOnSafeCallException read FOnSafeCallException write
      FOnSafeCallException;

    property OnSync: TOnSyncEvent read FOnSync write FOnSync;

    /// <summary> Specifies that parameters will be passed/sent by position in the params array
    /// </summary>
    property PassParamsByPos: Boolean read GetParamsPassByPosition write SetParamsPassByPosition;
    /// <summary> Specifies that parameters will be passed/sent by position in the params array
    /// </summary>
    property PassParamsByPosition: Boolean read GetParamsPassByPosition write SetParamsPassByPosition;
    /// <summary> Specifies that parameters will be passed/sent by name in the params object
    /// </summary>
    property PassParamsByName: Boolean read GetParamsPassByName write SetParamsPassByName;

    /// <summary> Specifies the connnection timeout, when connecting to the server
    /// </summary>
    property ConnectionTimeout: Integer read GetConnectionTimeout write SetConnectionTimeout;
    /// <summary> Specifies the send timeout, when sending data to the server
    /// </summary>
    property SendTimeout: Integer read GetSendTimeout write SetSendTimeout;
    /// <summary> Specifies the response timeout, when receiving data from the server
    /// </summary>
    property ResponseTimeout: Integer read GetResponseTimeout write SetResponseTimeout;

    property JSONRPCWrapper: TJSONRPCWrapper read GetJSONRPCWrapper;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
  end;

  /// <summary> JSON RPC server side
  /// </summary>
  TJSONRPCServerWrapper = class(
    {$IF DEFINED(BASECLASS)}
    TBaseJSONRPCWrapper,
    {$ELSE}
    TJSONRPCWrapper,
    {$ENDIF}
    IJSONRPCDispatch, IJSONRPCDispatchEvents, IJSONRPCGetSetDispatchEvents,
    IJSONRPCServerLog)
  protected
    FOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
    FOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;

    FOnBeforeDispatchJSONRPC: TOnBeforeDispatchJSONRPC;
    FOnDispatchedJSONRPC: TOnDispatchedJSONRPC;

    procedure DoBeforeDispatchJSONRPC(var AJSONResponse: string);
    procedure DoDispatchedJSONRPC(const AJSONRequest: string);
    procedure DoLogIncomingRequest(const ARequest: string);
    procedure DoLogOutgoingResponse(const AResponse: string);

    { IJSONRPCGetSetDispatchEvents }
    function GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);

    function GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
    procedure SetOnLogIncomingJSONRequest(const AProc: TOnLogIncomingJSONRequest);

    function GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
    procedure SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);

//    procedure GenericServerMethod(AMethod: TRttiMethod; const AArgs: TArray<TValue>; out Result: TValue);
    procedure InitClient; override;
    procedure SetInvokeMethod; override;

    function InternalQI(const IID: TGUID; out Obj): HResult; override; stdcall;

  public
    destructor Destroy; override;

    procedure DispatchJSONRPC(const ARequest, AResponse: TStream);

    /// <summary> Response to client
    /// </summary>
    property OnBeforeDispatchJSONRPC: TOnBeforeDispatchJSONRPC read
      FOnBeforeDispatchJSONRPC write FOnBeforeDispatchJSONRPC;
    property OnDispatchedJSONRPC: TOnDispatchedJSONRPC read FOnDispatchedJSONRPC
      write FOnDispatchedJSONRPC;

    property OnLogIncomingJSONRequest: TOnLogIncomingJSONRequest
      read FOnLogIncomingJSONRequest write FOnLogIncomingJSONRequest;
    property OnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse
      read FOnLogOutgoingJSONResponse write FOnLogOutgoingJSONResponse;
  end;

procedure RegisterJSONRPCWrapper(const ATypeInfo: PTypeInfo);

/// <summary>
/// Handles exceptions generated by safecall methods
/// <param name="AIntf">The JSON RPC interface</param>
/// <param name="AIntf">The safecall exception handler
/// <code>reference to function (ExceptObject: TObject; ExceptAddr: Pointer): HResult;
/// </code>
/// </param>
/// </summary>
procedure AssignJSONRPCSafeCallExceptionHandler(const AIntf: IInterface;
  const ASafeCallExceptionHandler: TOnSafeCallException); inline;

function PassParamsByName(const AIntf: IInterface): Boolean;
function PassParamsByPosition(const AIntf: IInterface): Boolean;

implementation

uses
{$IF DEFINED(DEBUG)} // Figure out which methods are having issues...
  Winapi.Windows,
{$ENDIF}
  System.Types, System.SyncObjs, JSONRPC.Common.Consts,
  System.DateUtils, JSONRPC.JsonUtils,
  JSONRPC.Common.RecordHandlers,
  System.JSONConsts;

procedure AssignJSONRPCSafeCallExceptionHandler(const AIntf: IInterface;
  const ASafeCallExceptionHandler: TOnSafeCallException);
begin
  var LSafeCallException: ISafeCallException;
  if Supports(AIntf, ISafeCallException, LSafeCallException) then
    LSafeCallException.OnSafeCallException := ASafeCallExceptionHandler;
end;

function PassParamsByName(const AIntf: IInterface): Boolean;
var
  LJSONRPCInvocationSettings: IJSONRPCInvocationSettings;
begin
  if Supports(AIntf, IJSONRPCInvocationSettings, LJSONRPCInvocationSettings) then
    begin
      LJSONRPCInvocationSettings.PassParamsByName := True;
      Result := True;
    end else
    begin
      Result := False;
    end;
end;

function PassParamsByPosition(const AIntf: IInterface): Boolean;
var
  LJSONRPCInvocationSettings: IJSONRPCInvocationSettings;
begin
  if Supports(AIntf, IJSONRPCInvocationSettings, LJSONRPCInvocationSettings) then
    begin
      LJSONRPCInvocationSettings.PassParamsByPosition := True;
      Result := True;
    end else
    begin
      Result := False;
    end;
end;

procedure RegisterJSONRPCWrapper(const ATypeInfo: PTypeInfo);
begin
  TJSONRPCWrapper.RegisterWrapper(ATypeInfo);
end;

{$IF DEFINED(BASECLASS)}
{ TBaseJSONRPCWrapper.TRioVirtualInterface }
procedure TBaseJSONRPCWrapper.DoDispatch(const AContext: TInvContext;
  AMethNum: Integer; const AMethMD: TIntfMethEntry);
begin
end;

constructor TBaseJSONRPCWrapper.TRioVirtualInterface.Create(ARio: TJSONRPCWrapper;
  AInterface: Pointer);
begin
  FRio := ARio;
  inherited Create(AInterface);
end;

destructor TBaseJSONRPCWrapper.TRioVirtualInterface.Destroy;
begin
  inherited;
end;

function TBaseJSONRPCWrapper.TRioVirtualInterface.QueryInterface(const IID: TGUID;
  out Obj): HRESULT;
begin
  Result := inherited;
  if Result <> S_OK then
    Result := FRio.InternalQI(IID, Obj);
end;

function TBaseJSONRPCWrapper.TRioVirtualInterface.SafeCallException(
  ExceptObject: TObject; ExceptAddr: Pointer): HRESULT;
begin
  Result := FRio.SafeCallException(ExceptObject, ExceptAddr);
end;

function TBaseJSONRPCWrapper.TRioVirtualInterface.GetOnSafeCallException: TOnSafeCallException;
begin
  Result := FRio.OnSafeCallException;
end;

procedure TBaseJSONRPCWrapper.TRioVirtualInterface.SetOnSafeCallException(const AProc: TOnSafeCallException);
begin
  FRio.OnSafeCallException := AProc;
end;

function TBaseJSONRPCWrapper.TRioVirtualInterface._AddRef: Integer;
begin
  Result := FRio._AddRef;
end;

function TBaseJSONRPCWrapper.TRioVirtualInterface._Release: Integer;
begin
  Result := FRio._Release;
end;
{$ENDIF}

// Fix for numbers that can't be marshalled
//type
//  TJSONObjectHelper = class helper for TJSONObject
//  public
//    function AddPair(const Str: string; const Value: BigDecimal): TJSONObject; overload;
//  end;
//
//  TJSONPairHelper = class helper for TJSONPair
//  public
//    constructor Create(const Str: string; const Value: BigDecimal); overload;
//  end;
//
//  TJSONNumberHelper = class helper for TJSONNumber
//  protected
//    function GetAsBigDecimal: BigDecimal;
//  public
//    constructor Create(const Value: BigDecimal); overload;
//    property AsBigDecimal: BigDecimal read GetAsBigDecimal;
//  end;
//
//  TJSONValueHelper = class helper for TJSONValue
//  public
//    function AsTypeBigDecimal: BigDecimal;
//  end;
//
//  TJSONArrayHelper = class helper for TJSONArray
//  public
//    function Add(const Element: BigDecimal): TJSONArray; overload;
//  end;
//
//function TJSONObjectHelper.AddPair(const Str: string; const Value: BigDecimal): TJSONObject;
//begin
//  if not Str.IsEmpty then
//    AddPair(TJSONPair.Create(Str, Value));
//  Result := Self;
//end;
//
//constructor TJSONPairHelper.Create(const Str: string; const Value: BigDecimal);
//begin
//  inherited Create(TJSONString.Create(Str), TJSONNumber.Create(Value));
//end;
//
//constructor TJSONNumberHelper.Create(const Value: BigDecimal);
//begin
//  inherited Create(Value.ToString);
//end;
//
//function TJSONNumberHelper.GetAsBigDecimal: BigDecimal;
//begin
//  Result := BigDecimal.Create(FValue);
//end;
//
//function TJSONValueHelper.AsTypeBigDecimal: BigDecimal;
//var
//  LTypeInfo: PTypeInfo;
//  LValue: TValue;
//begin
//  LTypeInfo := System.TypeInfo(BigDecimal);
//  if not AsTValue(LTypeInfo, LValue) then
//    raise EJSONException.CreateResFmt(@SCannotConvertJSONValueToType,
//      [ClassName, LTypeInfo.Name]);
//  Result := LValue.AsType<BigDecimal>;
//end;
//
//function TJSONArrayHelper.Add(const Element: BigDecimal): TJSONArray;
//begin
//  AddElement(TJSONNumber.Create(Element));
//  Result := Self;
//end;

{ TJSONRPCWrapper }

procedure TJSONRPCWrapper.FreeException;
begin
  FreeAndNil(FExceptObj);
end;

constructor TJSONRPCWrapper.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPassByPosOrName := tppByName;
  InitClient;
  FOnSafeCallException := function (AExceptObject: TObject;
    ExceptAddr: Pointer): HResult
  var
    LExc: EJSONRPCException absolute AExceptObject;
    LExcMethod: EJSONRPCMethodException absolute AExceptObject;
  begin
    Result := S_OK; // ------- ???
    FreeException;
    if ExceptObject is EJSONRPCMethodException then
      begin
        FExceptObj := EJSONRPCMethodException.Create(AExceptObject);
      end else
    if ExceptObject is EJSONRPCException then
      begin
        if not Assigned(FExceptObj) then
          FExceptObj := EJSONRPCException.Create(AExceptObject);
      end;
  end;
  FOwnsObjects := True;
  FJSONObjects := TList<TJSONValue>.Create;
end;

//procedure TJSONRPCWrapper.DeserializeJSON(const AJsonValue: TJSONValue;
//  ATypeInfo: PTypeInfo; var VValue: TValue);
//begin
//
//end;

procedure TJSONRPCWrapper.DeserializeJSON(const AJsonValue: TJSONValue;
  ATypeInfo: PTypeInfo; var VRestoredRecord);
var
  LValue: TValue;
begin
  if AJsonValue is TJSONNull then
    begin
      // Initializes an empty record
      InvokeRecordInitializer(@VRestoredRecord, ATypeInfo);
    end else
    begin
      DeserializeJSON(AJsonValue, ATypeInfo, LValue);
      ValueToObj(LValue, ATypeInfo, VRestoredRecord);
    end;
end;

procedure TJSONRPCWrapper.DeserializeJSON(const AJsonValue: TJSONValue;
  ATypeInfo: PTypeInfo; var VValue: TValue);
begin
  JSONRPC.JsonUtils.DeserializeJSON(AJsonValue, ATypeInfo, VValue);
end;

function TJSONRPCWrapper.CloneAndTrackJSONObjectToFree(
  const AJSONObj: TJSONValue): TJSONObject;
begin
  if AJSONObj = nil then
    Exit(nil);
  Result := AJSONObj.Clone as TJSONObject;
  if FOwnsObjects then
    begin
      FJSONObjects.Add(Result);
    end;
end;

procedure TJSONRPCWrapper.FreeLastResponse;
begin
  if FOwnsObjects then
    begin
      for var LObj in FJSONObjects do
        LObj.Free;
      FJSONObjects.Clear;
    end;
end;

destructor TJSONRPCWrapper.Destroy;
var
  LRio: TRIOVirtualInterface;
begin
  FreeLastResponse;
  FreeException;
  FOnBeforeExecute := nil;
  FOnAfterExecute := nil;
  FOnBeforeParse := nil;
  FOnSync := nil;
  FOnSafeCallException := nil;
  FJSONObjects.Free;
  FClient.Free;
  LRio := TInterlocked.Exchange(Pointer(FInterface), nil);
  LRio.Free;
  inherited;
end;

procedure TJSONRPCWrapper.DoAfterExecute(const AMethodName: string;
  AJSONRequest: TStream);
begin
  if Assigned(FOnAfterExecute) then
    FOnAfterExecute(AMethodName, AJSONRequest);
end;

procedure TJSONRPCWrapper.DoBeforeExecute(const AMethodName: string;
  AJSONRequest: TStream);
begin
  if Assigned(FOnBeforeExecute) then
    FOnBeforeExecute(AMethodName, AJSONRequest);
end;

procedure TJSONRPCWrapper.DoBeforeParse(const AContext: TInvContext;
  AMethNum: Integer; const AMethMD: TIntfMethEntry; const AMethodID: Int64; 
  AJSONResponse: TStream);
begin
  if Assigned(FOnBeforeParse) then
    FOnBeforeParse(AContext, AMethNum, AMethMD, AMethodID, AJSONResponse);
end;

function TJSONRPCWrapper.GetHttpMethod(const AMethodType: TRttiType;
  const AMethMD: TIntfMethEntry): string;
var
  LType: TRttiType;
  LHttpMethod: JSONHttpMethodAttribute;
begin
  LType := AMethodType;
  LHttpMethod := LType.GetAttribute<JSONHttpMethodAttribute>;
  if Assigned(LHttpMethod) then
    Result := LHttpMethod.HttpMethod;
end;

function TJSONRPCWrapper.GetUrlSuffix(
  const AMethodType: TRttiType;
  const AMethMD: TIntfMethEntry): string;
var
  LType: TRttiType;
  LUrlSuffix: UrlSuffixAttribute;
begin
  LType := AMethodType;
  LUrlSuffix := LType.GetAttribute(UrlSuffixAttribute) as UrlSuffixAttribute;
  if Assigned(LUrlSuffix) then
    Result := LUrlSuffix.UrlSuffix;
end;

function TJSONRPCWrapper.GetOnLogOutgoingJSONRequest: TOnLogOutgoingJSONRequest;
begin
  Result := FOnLogOutgoingJSONRequest;
end;
procedure TJSONRPCWrapper.SetOnLogOutgoingJSONRequest(const AProc: TOnLogOutgoingJSONRequest);
begin
  FOnLogOutgoingJSONRequest := AProc;
end;
function TJSONRPCWrapper.GetOnLogIncomingJSONResponse: TOnLogIncomingJSONResponse;
begin
  Result := FOnLogIncomingJSONResponse;
end;
procedure TJSONRPCWrapper.SetOnLogIncomingJSONResponse(const AProc: TOnLogIncomingJSONResponse);
begin
  FOnLogIncomingJSONResponse := AProc;
end;
function TJSONRPCWrapper.GetOnLogServerURL: TOnLogServerURL;
begin
  Result := FOnLogServerURL;
end;
procedure TJSONRPCWrapper.SetOnLogServerURL(const AProc: TOnLogServerURL);
begin
  FOnLogServerURL := AProc;
end;

procedure TJSONRPCWrapper.UpdateServerURL(
  const AContext: TInvContext;
  const AMethMD: TIntfMethEntry;
  var VServerURL: string);
begin
end;

function TIntfMethEntryHelper.JSONMethodName(const ARttiContext: TRttiContext): string;
var
  LType: TRttiType;
  DeclaredMethods: TArray<TRttiMethod>;
  LMethod: TRttiMethod;
  LJSONMethodNameAttr: JSONMethodNameAttribute;
begin
  LType := ARttiContext.GetType(Self.SelfInfo); // TRttiInterfaceType
  DeclaredMethods := LType.GetDeclaredMethods;
  LMethod := DeclaredMethods[Self.Pos-3]; // 3 is number of methods in IInterface
  LJSONMethodNameAttr := LMethod.GetAttribute<JSONMethodNameAttribute>;
  if Assigned(LJSONMethodNameAttr) then
    Result := LJSONMethodNameAttr.Name;
end;

function TJSONRPCWrapper.GetMethod(const AMethMD: TIntfMethEntry): TRttiMethod;
begin
  var LType := FRttiContext.GetType(AMethMD.SelfInfo); // TRttiInterfaceType
  Result := LType.GetDeclaredMethods[AMethMD.Pos-3];
end;

function TJSONRPCWrapper.GetMethodName(const AMethMD: TIntfMethEntry): string;
var
  LJSONMethodName: string;
begin
  if Length(FMethodNames) < AMethMD.Pos then
    SetLength(FMethodNames, AMethMD.Pos+1);
  if FMethodNames[AMethMD.Pos] <> '' then
    Exit(FMethodNames[AMethMD.Pos]);
  LJSONMethodName := AMethMD.JSONMethodName(FRttiContext);
  if LJSONMethodName = '' then
    FMethodNames[AMethMD.Pos] := AMethMD.Name else
    FMethodNames[AMethMD.Pos] := LJSONMethodName;
  Result := FMethodNames[AMethMD.Pos];
end;

procedure DumpType(const AIntfType: TRttiType);
begin
  OutputDebugString(AIntfType.Name);
end;

// Client side JSON RPC parameter conversion
procedure TJSONRPCWrapper.DoDispatch(const AContext: TInvContext;
  AMethNum: Integer; const AMethMD: TIntfMethEntry);
const
{$WRITEABLECONST ON}
  CJSONMethodID: Int64 = 0;
var
  LRequestStream, LResponseStream: TStream;
  LJSONMethodObj: TJSONObject;
  LResultP: Pointer;
  LJSONResponseObj: TJSONValue;
  LHttpMethod, LServerURL: string;
begin

// create something like this, with PassParamsByName

// {"jsonrpc": "2.0", "method": "CallSomeMethod", "id": 1}
// {"jsonrpc": "2.0", "method": "AddSomeXY", "params": {"x": 5, "y": 6}, "id": 2}

// create something like this, with PassParamsByPosition
// {"jsonrpc": "2.0", "method": "AddSomeXY", "params": {5, 6}, "id": 2}

  FreeLastResponse;
  LJSONMethodObj := TJSONObject.Create;
  try
    {$REGION 'Convert native Delphi call to a JSON string'}
    LJSONMethodObj.Owned := True;
    AddJSONVersion(LJSONMethodObj);

    var LIntfType := FRttiContext.GetType(AMethMD.SelfInfo);
    DumpType(LIntfType);
    var LJSONMethodName := GetMethodName(AMethMD);
    LJSONMethodObj.AddPair(SMETHOD, LJSONMethodName);

    if AMethMD.ParamCount > 0 then
      begin

        var LParamsObj: TJSONObject := nil;
        var LParamsArray: TJSONArray := nil;
        if FPassByPosOrName = tppByPos then
          LParamsArray := TJSONArray.Create else
          LParamsObj := TJSONObject.Create;

        for var I := 1 to AMethMD.ParamCount do
          begin
            var LParamValuePtr := AContext.GetParamPointer(I-1);
            var LParamName := AMethMD.Params[I-1].Name;

            // parse outgoing / handle outgoing data from client to server
            {$REGION 'Parse outgoing data from client to server'}
            var LParamTypeInfo := AMethMD.Params[I-1].Info;
            case LParamTypeInfo.Kind of
              tkArray,
              tkDynArray: begin
                var LJSONObj := ArrayToJSONArray(LParamValuePtr^, LParamTypeInfo);
                case FPassByPosOrName of
                  tppByName: LParamsObj.AddPair(LParamName, LJSONObj);
                  tppByPos:  LParamsArray.Add(LJSONObj);
                end;
              end;
              tkRecord: begin
                var LHandlers: TRecordHandlers;
                if LookupRecordHandlers(LParamTypeInfo, LHandlers) then
                  begin
                    LHandlers.NativeToJSON(FPassByPosOrName, LParamTypeInfo,
                      LParamName, LParamValuePtr, LParamsObj, LParamsArray);
                  end else
                  begin
                    var LJSON := SerializeRecord(LParamValuePtr^, LParamTypeInfo);
                    var LJSONObj := TJSONObject.ParseJSONValue(LJSON);
                    case FPassByPosOrName of
                      tppByName: LParamsObj.AddPair(LParamName, LJSONObj);
                      tppByPos:  LParamsArray.AddElement(LJSONObj);
                    end;
                  end;
              end;
              tkEnumeration: begin
                // First chance to parse enum
                if not DoParseEnum(FRttiContext, AMethMD, I, LParamTypeInfo, LParamValuePtr, LParamsObj, LParamsArray) then
                  begin
                  // Only possible types are boolean, WordBool, LongBool, etc
                  // marshalled as string or as True/False???
                    if IsBoolType(LParamTypeInfo) then
                      begin
                        var LValue: Boolean;
                        case LParamTypeInfo^.TypeData^.OrdType of
    //                    case GetTypeData(LParamTypeInfo)^.OrdType of
                          otSByte, otUByte: begin
                            LValue := PBoolean(LParamValuePtr)^;
                          end;
                          otSWord, otUWord: begin
                            LValue := PWordBool(LParamValuePtr)^;
                          end;
                          otSLong, otULong: begin
                            LValue := PLongBool(LParamValuePtr)^;
                          end;
                        else
                          // This currently won't happen, because there's only
                          // 6 ordinal types as defined.
                          Assert(False, 'Unhandled new ordinal type!');
                        end;
                        case FPassByPosOrName of
                          tppByName: LParamsObj.AddPair(LParamName, TJSONBool.Create(LValue));
                          tppByPos:  LParamsArray.Add(LValue);
                        end;
                      end else
                      begin // Looks like it's really an enum!
                        var LValue := GetEnumName(LParamTypeInfo, PByte(LParamValuePtr)^);
                        case FPassByPosOrName of
                          tppByName: LParamsObj.AddPair(LParamName, LValue);
                          tppByPos:  LParamsArray.Add(LValue);
                        end;
                      end;
                  end else
                  begin
                    var LValue := PByte(LParamValuePtr)^;
                    case FPassByPosOrName of
                      tppByName: LParamsObj.AddPair(LParamName, LValue);
                      tppByPos:  LParamsArray.Add(LValue);
                    end;
                  end;
              end;
              tkLString, tkString, tkUString, tkWString:
                case FPassByPosOrName of
                  tppByName: LParamsObj.AddPair(LParamName, PString(LParamValuePtr)^);
                  tppByPos:  LParamsArray.Add(PString(LParamValuePtr)^);
                end;
              tkInteger: begin
                var LTypeInfo := LParamTypeInfo;
                var LTypeName := string(LTypeInfo^.Name);
                case LTypeInfo.TypeData.OrdType of
                  otSByte: begin // ShortInt
                    Assert(SameText(LTypeName, 'ShortInt'), 'Type mismatch!');
                    case FPassByPosOrName of
                      tppByName: LParamsObj.AddPair(LParamName, PShortInt(LParamValuePtr)^);
                      tppByPos:  LParamsArray.Add(PShortInt(LParamValuePtr)^);
                    end;
                  end;
                  otSWord: begin
                    Assert(SameText(LTypeName, 'SmallInt'), 'Type mismatch!');
                    case FPassByPosOrName of
                      tppByName: LParamsObj.AddPair(LParamName, PSmallInt(LParamValuePtr)^);
                      tppByPos:  LParamsArray.Add(PSmallInt(LParamValuePtr)^);
                    end;
                  end;
                  otSLong: begin // Integer
                    Assert(SameText(LTypeName, 'Integer'), 'Type mismatch!');
                    case FPassByPosOrName of
                      tppByName: LParamsObj.AddPair(LParamName, PInteger(LParamValuePtr)^);
                      tppByPos:  LParamsArray.Add(PInteger(LParamValuePtr)^);
                    end;
                  end;
                  otUByte: begin // Byte
                    Assert(SameText(LTypeName, 'Byte'), 'Type mismatch!');
                    case FPassByPosOrName of
                      tppByName: LParamsObj.AddPair(LParamName, PByte(LParamValuePtr)^);
                      tppByPos:  LParamsArray.Add(PByte(LParamValuePtr)^);
                    end;
                  end;
                  otUWord: begin
                    Assert(SameText(LTypeName, 'Word'), 'Type mismatch!');
                    case FPassByPosOrName of
                      tppByName: LParamsObj.AddPair(LParamName, PWord(LParamValuePtr)^);
                      tppByPos:  LParamsArray.Add(PWord(LParamValuePtr)^);
                    end;
                  end;
                  otULong: begin // Cardinal
                    Assert(SameText(LTypeName, 'Cardinal'), 'Type mismatch!');
                    case FPassByPosOrName of
                      tppByName: LParamsObj.AddPair(LParamName, PCardinal(LParamValuePtr)^);
                      tppByPos:  LParamsArray.Add(PCardinal(LParamValuePtr)^);
                    end;
                  end;
                end;

              end;
              tkFloat: begin
                var LFloatType := LParamTypeInfo^.TypeData.FloatType;
                CheckFloatType(LFloatType);
                case LFloatType of
//                  ftComp: begin
//                    var LParamValue := PComp(LParamValuePtr)^;
//                    case FPassByPosOrName of
//                      tppByName: LParamsObj.AddPair(LParamName, LParamValue);
//                      tppByPos:  LParamsArray.Add(LParamValue);
//                    end;
//                  end;
                  ftCurr: begin
                    var LParamValue := PCurrency(LParamValuePtr)^;
                    begin
                      case FPassByPosOrName of
                        tppByName: LParamsObj.AddPair(LParamName, LParamValue);
                        tppByPos:  LParamsArray.Add(LParamValue);
                      end;
                    end;
                  end;
                  ftDouble, ftExtended, ftSingle:
                  begin
                    if (LParamTypeInfo = System.TypeInfo(TDate)) or
                       (LParamTypeInfo = System.TypeInfo(TTime)) or
                       (LParamTypeInfo = System.TypeInfo(TDateTime)) then
                      begin
                        var LParamValue := DateToISO8601(PDateTime(LParamValuePtr)^, False);
                        case FPassByPosOrName of
                          tppByName: LParamsObj.AddPair(LParamName, LParamValue);
                          tppByPos:  LParamsArray.Add(LParamValue);
                        end;
                      end else
                    if LParamTypeInfo = System.TypeInfo(Single) then
                      begin
                        var LParamValue := PSingle(LParamValuePtr)^;
                        case FPassByPosOrName of
                          tppByName: LParamsObj.AddPair(LParamName, LParamValue);
                          tppByPos:  LParamsArray.Add(LParamValue);
                        end;
                      end else
                    if LParamTypeInfo = System.TypeInfo(Extended) then
                      begin
                        // Delphi cannot handle the precision of Extended
                        // if the client is 32-bit and the server is 64-bit
                        // so convert to BigDecimal
                        var LHandlers: TRecordHandlers;
                        if LookupRecordHandlers(LParamTypeInfo, LHandlers) then
                          begin
                            LHandlers.NativeToJSON(FPassByPosOrName,
                              LParamTypeInfo, LParamName,
                              LParamValuePtr, LParamsObj, LParamsArray);
                          end;
                      end else // Currency, Double
                      begin
                        var LParamValue := PDouble(LParamValuePtr)^;
                        begin
                          case FPassByPosOrName of
                            tppByName:  LParamsObj.AddPair(LParamName, LParamValue);
                            tppByPos:   LParamsArray.Add(LParamValue);
                          end;
                        end;
                      end;
                  end;
                end;
              end; // tkFloat
            tkInt64: begin
              var LParamValue := PInt64(LParamValuePtr)^;
              begin
                case FPassByPosOrName of
                  tppByName:  LParamsObj.AddPair(LParamName, LParamValue);
                  tppByPos:   LParamsArray.Add(LParamValue);
                end;
              end;
            end;
            tkClass: begin
              //

            end;
            else
              Assert(False, 'Unexpected type not handled');
            end;
            {$ENDREGION}
          end;
        if FPassByPosOrName = tppByName then
          LJSONMethodObj.AddPair(SPARAMS, LParamsObj) else
          LJSONMethodObj.AddPair(SPARAMS, LParamsArray);
      end;


    // Only add ID if it's not a Notification call
    var LMethodType := LIntfType;
    var LJSONNotify := LMethodType.GetAttribute<JSONNotifyAttribute>;
    var LIsNotification := LJSONNotify <> nil;
    var LMethodID := -1;
    if not LIsNotification then
      begin
        LMethodID := TInterlocked.Increment(CJSONMethodID);
        LJSONMethodObj.AddPair(SID, LMethodID);
      end;

    // client request converted to JSON string
    var LRequestJSON := LJSONMethodObj.ToJSON;
    {$ENDREGION}

    // then send it
    LRequestStream := FClient.RequestStream;
    try
      var LBytes := TEncoding.UTF8.GetBytes(LRequestJSON);
      var LSizeBefore := LRequestStream.Size;
      LRequestStream.Write(LBytes, Length(LBytes));
      DoBeforeExecute(AMethMD.Name, LRequestStream);
      var LSizeAfter := LRequestStream.Size;
      var LTempJSON := LRequestJSON;
      if LSizeBefore <> LSizeAfter then
        begin
          var LStringStream := TStringStream.Create;
          try
            LStringStream.CopyFrom(LRequestStream);
            LTempJSON := LStringStream.DataString;
          finally
            LStringStream.Free;
          end;
        end;
      DoLogOutgoingRequest(LTempJSON);
      LResponseStream := FClient.ResponseStream;
      try
        // Execute
        if FServerURL <> '' then
          begin
            LRequestStream.Position := 0;
            var LHeaders: TNetHeaders := InitializeHeaders(LRequestStream);
            LServerURL := FServerURL;
            var LUrlSuffix := GetURLSuffix(LMethodType, AMethMD);
            if LUrlSuffix <> '' then
              begin
                if not LServerURL.EndsWith('/') then
                  LServerURL := LServerURL + '/';
                if LUrlSuffix.StartsWith('/') then
                  Delete(LUrlSuffix, Low(LUrlSuffix), 1);
                LServerURL := LServerURL + LUrlSuffix;
                // Prevent duplicates
                if LServerURL.EndsWith('//') then
                  Delete(LServerURL, Length(LServerURL), 1);
                UpdateServerURL(AContext, AMethMD, LServerURL);
                DoLogServerURL(LServerURL);
              end;
            LHttpMethod := GetHttpMethod(LMethodType, AMethMD);
            if (LHttpMethod = '') then
              SendGetPost(LServerURL, LRequestStream, LResponseStream, LHeaders) else
              HttpMethod(LHttpMethod, LServerURL, LRequestStream, LResponseStream, LHeaders);
          end;

        DoAfterExecute(AMethMD.Name, LResponseStream);
        DoSync(LRequestStream, LResponseStream);
        DoBeforeParse(AContext, AMethNum, AMethMD, LMethodID, LResponseStream);

        // handle error received from JSON RPC server
        var LResponse := '';
        LResponseStream.Seek(0, soFromBeginning);
        SetLength(LBytes, LResponseStream.Size);
        LResponseStream.Read(LBytes, LResponseStream.Size);
        // parse incoming response from server
        LResponse := TEncoding.UTF8.GetString(LBytes);
        DoLogIncomingResponse(LResponse);

        LResultP := AContext.ResultPointer;
        LJSONResponseObj := TJSONObject.ParseJSONValue(TArray<Byte>(LBytes), 0);
        var LError: TJSONValue;
        try
          {$REGION 'Check for any errors from the server'}
          LError := LJSONResponseObj.FindValue(SERROR);
          if Assigned(LError) and not (LError is TJSONNull) then
            begin
              var LCode := LError.GetValue<Integer>(SCODE);
              var LMsg := LError.GetValue<string>(SMESSAGE);
              var LMethodName := LError.FindValue(SMETHOD);
              if Assigned(LMethodName) then
                raise EJSONRPCMethodException.Create(LCode, LMsg, LMethodName.Value) else
                raise EJSONRPCException.Create(LCode, LMsg);
            end;
          {$ENDREGION}
          {$REGION 'Parse results from server, if any'}
          if LResultP <> nil then
            begin
              var LResultPathName := SRESULT;
              // parse incoming JSON result from server
              DoParseJSONResult(AMethMD.ResultInfo, LJSONResponseObj, LResultP);
              case AMethMD.ResultInfo.Kind of
              {$IF DEFINED(SUPPORTS_JSONOBJECT_AS_RESULT)}
                tkClass: begin
                  // take a TJSONObject as a result
                    var LJSONObj := LJSONResponseObj.FindValue(LResultPathName);
                    if LJSONObj <> nil then
                      begin
                        if Assigned(LJSONObj) and
                        (
                          (AMethMD.ResultInfo = TypeInfo(TJSONObject)) or
                          (AMethMD.ResultInfo^.TypeData^.ClassType.InheritsFrom(TJSONValue))
                        ) then
                          begin
                            TJSONObject(LResultP^) := CloneAndTrackJSONObjectToFree(LJSONObj);
                          end else
                          begin
                            Assert(False, 'Untested code path: 1004');
                          end;
                      end else
                      begin
                        // There's no "result" on Aptos, the entire block
                        // is a JSON object
                        if (AMethMD.ResultInfo = TypeInfo(TJSONObject)) or
                          (AMethMD.ResultInfo^.TypeData^.ClassType.InheritsFrom(TJSONValue)) then
                          begin
                            TJSONObject(LResultP^) := CloneAndTrackJSONObjectToFree(LJSONResponseObj);
                          end else
                          begin
                            Assert(False, 'Untested code path: 1018');
                          end;
                      end;
                end;
              {$ELSE}
                tkClass: begin
                  Assert(False, 'Class not supported as result yet!');
                end;
              {$ENDIF}
                tkArray,
                tkDynArray: begin
                  var LJSONObj := LJSONResponseObj.FindValue(LResultPathName);
                  if Assigned(LJSONObj) then
                    DeserializeJSON(LJSONObj, AMethMD.ResultInfo, LResultP^);
                end;
                tkRecord: begin
                  var LTypeInfo := AMethMD.ResultInfo;
                  var LHandlers: TRecordHandlers;
                  if LookupRecordHandlers(LTypeInfo, LHandlers) then
                    begin
                      LHandlers.JSONToNative(LJSONResponseObj, LResultPathName, LResultP);
                    end else
//                    if LTypeInfo = TypeInfo(BigDecimal) then
//                      begin
//                        var LResultValue: string := '';
//                        LJSONResponseObj.TryGetValue<string>(LResultPathName, LResultValue);
//                        PBigDecimal(LResultP)^ := BigDecimal.Create(LResultValue);
//                      end else
//                    if LTypeInfo = TypeInfo(BigInteger) then
//                      begin
//                        var LResultValue: string := '';
//                        LJSONResponseObj.TryGetValue<string>(LResultPathName, LResultValue);
//                        if LResultValue.StartsWith('0x', True) then
//                          LResultValue := Copy(LResultValue, Low(LResultValue) + 2);
//                        BigInteger.TryParse(LResultValue, 16, PBigInteger(LResultP)^);
//                      end else
                    begin
                      var LJSONObj := LJSONResponseObj.FindValue(LResultPathName);
                      if Assigned(LJSONObj) then
                        DeserializeJSON(LJSONObj, AMethMD.ResultInfo, LResultP^) else
                      begin
                        // JSON Response
                        DeserializeJSON(LJSONResponseObj, AMethMD.ResultInfo, LResultP^);
                      end;
                    end;
                end;
                tkEnumeration: begin
                  var LResultValue: string := '';
                  LJSONResponseObj.TryGetValue<string>(LResultPathName, LResultValue);
                  if IsBoolType(AMethMD.ResultInfo) then
                    begin
                      case AMethMD.ResultInfo^.TypeData^.OrdType of
                        otSByte, otUByte: begin
                          PBoolean(LResultP)^ := SameText(LResultValue, 'True');
                        end;
                        otSWord, otUWord: begin
                          PWordBool(LResultP)^ := SameText(LResultValue, 'True');
                        end;
                        otSLong, otULong: begin
                          PLongBool(LResultP)^ := SameText(LResultValue, 'True');
                        end;
                      end;
                    end else
                    begin // really an enum type
                      TInvContext.PEnum(LResultP)^ := GetEnumValue(AMethMD.ResultInfo, LResultValue); // Most enum values are 1 byte
                    end;
                end;
                tkFloat: begin
                  var LTypeInfo := AMethMD.ResultInfo;
                  var LFloatType := LTypeInfo^.TypeData.FloatType;
                  begin
                    CheckTypeInfo(LTypeInfo);
                    CheckFloatType(LFloatType);
                    case LFloatType of
                      ftComp: begin
                        LJSONResponseObj.TryGetValue<Comp>(LResultPathName, PComp(LResultP)^);
                      end;
                      ftCurr: begin
                        // Currency cannot be extracted successfully, but double can.
                        PCurrency(LResultP)^ := LJSONResponseObj.GetValue<Double>(LResultPathName, 0.0);
                      end;
                      ftDouble, ftExtended, ftSingle:
                      begin
                        if (LTypeInfo = System.TypeInfo(TDate)) or
                           (LTypeInfo = System.TypeInfo(TTime)) or
                           (LTypeInfo = System.TypeInfo(TDateTime)) then
                          begin
                            var LDateTimeStr: string;
                            LJSONResponseObj.TryGetValue<string>(LResultPathName, LDateTimeStr);
                            PDateTime(LResultP)^ := ISO8601ToDate(LDateTimeStr, False);
                          end else
                        if LTypeInfo = System.TypeInfo(Double) then
                          begin
                            LJSONResponseObj.TryGetValue<Double>(LResultPathName, PDouble(LResultP)^);
                          end else
                        if LTypeInfo = System.TypeInfo(Extended) then
                          begin
                            var LHandlers: TRecordHandlers;
                            if LookupRecordHandlers(LTypeInfo, LHandlers) then
                              begin
                                LHandlers.JSONToNative(LJSONResponseObj, LResultPathName, LResultP);
                              end;
                          end;
                      end;
                    end; // end case
                  end;
                end;
                tkInteger: begin
                  var LTypeInfo := AMethMD.ResultInfo;
                  CheckTypeInfo(LTypeInfo);

                  case LTypeInfo.TypeData.OrdType of
                    otSByte: begin // ShortInt
                      LJSONResponseObj.TryGetValue<ShortInt>(LResultPathName, PShortInt(LResultP)^);
                    end;
                    otSWord: begin // SmallInt
                      LJSONResponseObj.TryGetValue<SmallInt>(LResultPathName, PSmallInt(LResultP)^);
                    end;
                    otSLong: begin // Integer
                      LJSONResponseObj.TryGetValue<Integer>(LResultPathName, PInteger(LResultP)^);
                    end;
                    otUByte: begin // Byte
                      LJSONResponseObj.TryGetValue<Byte>(LResultPathName, PByte(LResultP)^);
                    end;
                    otUWord: begin // Word
                      LJSONResponseObj.TryGetValue<Word>(LResultPathName, PWord(LResultP)^);
                    end;
                    otULong: begin // Cardinal
                      LJSONResponseObj.TryGetValue<Cardinal>(LResultPathName, PCardinal(LResultP)^);
                    end;
                  end;
                  // LJSONResponseObj.TryGetValue<Integer>(LResultPathName, PInteger(LResultP)^);
                end;
                tkInt64:
                  LJSONResponseObj.TryGetValue<Int64>(LResultPathName, PInt64(LResultP)^);
                tkLString, tkString, tkUString, tkWString: begin
                  LJSONResponseObj.TryGetValue<string>(LResultPathName, PString(LResultP)^);
                end;
              else
                // not handled
                if not DoParseUnhandledResult(LJSONResponseObj, LResultP) then
                  Assert(False, 'Unhandled type in handling response from server');
              end;
            end;
          {$ENDREGION}
        finally
          FreeAndNil(LJSONResponseObj);
        end;
      finally
        LResponseStream.Free;
      end;
    finally
      LRequestStream.Free;
    end;
  finally
    LJSONMethodObj.Free;
  end;
end;

procedure TJSONRPCWrapper.DoLogOutgoingRequest(const ARequest: string);
begin
{$IF DECLARED(OutputDebugString)}
  OutputDebugString(ARequest);
{$ENDIF}
  if Assigned(FOnLogOutgoingJSONRequest) then
    FOnLogOutgoingJSONRequest(ARequest);
end;

procedure TJSONRPCWrapper.DoLogIncomingResponse(const AResponse: string);
begin
  if Assigned(FOnLogIncomingJSONResponse) then
    FOnLogIncomingJSONResponse(AResponse);
end;

function TJSONRPCWrapper.DoParseEnum(const ARttiContext: TRttiContext;
  const AMethMD: TIntfMethEntry;
  AParamIndex: Integer;
  AParamTypeInfo: PTypeInfo; AParamValuePtr: Pointer;
  AParamsObj: TJSONObject; AParamsArray: TJSONArray): Boolean;
begin
  Result := False;
  if Assigned(FOnParseEnum) then
    Result := FOnParseEnum(ARttiContext, AMethMD, AParamIndex, AParamTypeInfo,
      AParamValuePtr, AParamsObj, AParamsArray);
end;

function TJSONRPCWrapper.DoParseUnhandledResult(AJSONResponseObj: TJSONValue;
  AResultP: Pointer): Boolean;
begin
  Result := False;
end;

function TJSONRPCWrapper.DoParseJSONResult(ATypeInfo: PTypeInfo; AJSONResponseObj: TJSONValue;
  AResultP: Pointer): Boolean;
begin
  Result := False;
end;

procedure TJSONRPCWrapper.DoLogServerURL(const AURL: string);
begin
  if Assigned(FOnLogServerURL) then
    FOnLogServerURL(AURL);
end;

procedure TJSONRPCWrapper.DoSync(AJSONRequest, AJSONResponse: TStream);
begin
  if Assigned(FOnSync) then
    FOnSync(AJSONRequest, AJSONResponse);
end;

class constructor TJSONRPCWrapper.Create;
begin
  FRegistry := TDictionary<TGUID, PTypeInfo>.Create;
end;

class destructor TJSONRPCWrapper.Destroy;
begin
  FRegistry.Free;
end;

procedure TJSONRPCWrapper.GenericClientMethod(AMethod: TRttiMethod;
  const AArgs: TArray<TValue>; out Result: TValue);
var
  LMethMD: TIntfMethEntry;
  I, VirtualIndex: Integer;
  LMethNum: Integer;
  LContext: TInvContext;
begin
  LContext := TInvContext.Create;
  try
    LMethNum := -1;

    VirtualIndex := AMethod.VirtualIndex;
    I := VirtualIndex;
    if FIntfMD.MDA[I].Pos = VirtualIndex then
      begin
        LMethNum := I;
        LMethMD := FIntfMD.MDA[I];
        LContext.SetMethodInfo(LMethMD);
      end;

    if LMethNum = -1 then
      for I := 0 to Length(FIntfMD.MDA) do
        if FIntfMD.MDA[I].Pos = AMethod.VirtualIndex then
          begin
            LMethNum := I;
            LMethMD := FIntfMD.MDA[I];
            LContext.SetMethodInfo(LMethMD);
            Break;
          end;
    for I := 1 to LMethMD.ParamCount do
      LContext.SetParamPointer(I-1, AArgs[I].GetReferenceToRawData);

    if Assigned(LMethMD.ResultInfo) then
      begin
        TValue.Make(nil, LMethMD.ResultInfo, Result);
        LContext.SetResultPointer(Result.GetReferenceToRawData);
      end else
      begin
        LContext.SetResultPointer(nil);
      end;
    DoDispatch(LContext, LMethNum, LMethMD);  // Client dispatch
  finally
    LContext.Free;
  end;
end;

function TJSONRPCWrapper.GetConnectionTimeout: Integer;
begin
  Result := FClient.ConnectionTimeout;
end;

function TJSONRPCWrapper.GetOnSafeCallException: TOnSafeCallException;
begin
  Result := FOnSafeCallException;
end;

function TJSONRPCWrapper.GetParamsPassByName: Boolean;
begin
  Result := FPassByPosOrName = tppByName;
end;

function TJSONRPCWrapper.GetParamsPassByPosition: Boolean;
begin
  Result := FPassByPosOrName = tppByPos;
end;

function TJSONRPCWrapper.GetResponseTimeout: Integer;
begin
  Result := FClient.ResponseTimeout;
end;

function TJSONRPCWrapper.GetSendTimeout: Integer;
begin
  Result := FClient.SendTimeout;
end;

procedure TJSONRPCWrapper.InitClient;
begin
  Assert(Assigned(GJSONRPCTransportWrapperClass),
    'GJSONRPCTransportWrapperClass is not assigned!');
  FClient := GJSONRPCTransportWrapperClass.Create;
end;

procedure TJSONRPCWrapper.DoBeforeInitializeHeaders(var VNetHeaders: TNetHeaders);
begin
  if Assigned(FOnBeforeInitializeHeaders) then
    FOnBeforeInitializeHeaders(VNetHeaders);
end;

procedure TJSONRPCWrapper.DoAfterInitializeHeaders(var VNetHeaders: TNetHeaders);
begin
  if Assigned(FOnAfterInitializeHeaders) then
    FOnAfterInitializeHeaders(VNetHeaders);
end;

type
  TNameValueArrayHelper = record helper for TNameValueArray
    function ContainsName(const AName: string): Boolean;
  end;

function TNameValueArrayHelper.ContainsName(const AName: string): Boolean;
begin
  for var I := Low(Self) to High(Self) do
    begin
      if SameText(Self[I].Name, AName) then
        Exit(True);
    end;
  Result := False;
end;

function TJSONRPCWrapper.InitializeHeaders(const ARequestStream: TStream): TNetHeaders;
begin
  Result := [];
  DoBeforeInitializeHeaders(Result);

  if not Result.ContainsName('accept') then
    Result := Result + [TNameValuePair.Create('accept', SApplicationJson)];
  if not Result.ContainsName('Content-Length') then
    Result := Result + [TNameValuePair.Create('Content-Length', IntToStr(ARequestStream.Size))];
  if not Result.ContainsName('Content-Type') then
    Result := Result + [TNameValuePair.Create('Content-Type', SApplicationJsonRPC)];

  DoAfterInitializeHeaders(Result);
end;

function TJSONRPCWrapper.InternalQI(const IID: TGUID; out Obj): HResult;
begin
  Result := E_NOINTERFACE;

  { IInterface, IJSONRPCWrapper, etc... }
  if GetInterface(IID, Obj) then
    Result := S_OK;

  if (Result <> S_OK) and (FInterface <> nil) and (IID = FIID) then
    Result := TRIOVirtualInterface(Pointer(FInterface)).QueryInterface(IID, Obj);
end;

class function TJSONRPCWrapper.NewInstance: TObject;
begin
  // Set an implicit refcount so that refcounting
  // during construction won't destroy the object.
  Result := inherited NewInstance;
  TJSONRPCWrapper(Result).FRefCount := 1;
end;

function TJSONRPCWrapper.QueryInterface(const IID: TGUID; out Obj): HRESULT;
var
  LValue: PTypeInfo;
begin
  Result := S_FALSE;
  if FInterface = nil then
    begin
      if FRegistry.TryGetValue(IID, LValue) then
        begin
          Pointer(FInterface) := TRioVirtualInterface.Create(Self, LValue);
          FIID := IID;
          SetInvokeMethod;
          GetIntfMetaData(LValue, FIntfMD, True);
          Result := S_OK;
        end else
        begin
          Pointer(Obj) := nil;
        end;
    end;

  if Result = S_OK then
    Result := InternalQI(IID, Obj);
end;

class procedure TJSONRPCWrapper.RegisterWrapper(const ATypeInfo: PTypeInfo);
var
  LTypeInfo: PTypeInfo;
begin
  if ATypeInfo.TypeData.GUID = TGUID.Empty then
    raise Exception.Create('No GUID assigned to interface');

  if not FRegistry.TryGetValue(ATypeInfo.TypeData.GUID, LTypeInfo) then
    FRegistry.Add(ATypeInfo.TypeData.GUID, ATypeInfo) {$IF DEFINED(DEBUG)} else
  begin
    {$IF DECLARED(OutputDebugString)}
      var LMsg := Format('Trying to register duplicate interface: GUID: %s, Name: %s',
        [ATypeInfo^.TypeData^.GUID.ToString, ATypeInfo^.Name]);
      OutputDebugString(LMsg);
    {$ENDIF}
  end
  {$ENDIF}
  ;
end;

function TJSONRPCWrapper.SafeCallException(ExceptObject: TObject;
  ExceptAddr: Pointer): HResult;
begin
  if Assigned(FOnSafeCallException) then
    Result := FOnSafeCallException(ExceptObject, ExceptAddr) else
  begin
    // raise ExceptObject at ExceptAddr;
    Result := inherited;
  end;
end;

function TJSONRPCWrapper.GetJSONRPCWrapper: TJSONRPCWrapper;
begin
  Result := Self;
end;

procedure TJSONRPCWrapper.HttpMethod(const AHttpMethod, AServerURL: string;
  const ARequestStream, AResponseStream: TStream;
  const AHeaders: TNetHeaders);
begin
  FClient.HttpMethod(AHttpMethod, AServerURL, ARequestStream, AResponseStream,
    AHeaders);
end;

procedure TJSONRPCWrapper.SendGetPost(const AServerURL: string;
  const ARequestStream, AResponseStream: TStream; const AHeaders: TNetHeaders);
begin
  FClient.Post(AServerURL, ARequestStream, AResponseStream, AHeaders);
end;

function TJSONRPCWrapper.SerializeRecord(const [ref] VRecord;
  ATypeInfo: PTypeInfo): string;
begin
  Result := JSONRPC.JsonUtils.SerializeRecord(VRecord, ATypeInfo);
end;

procedure TJSONRPCWrapper.SetConnectionTimeout(const Value: Integer);
begin
  FClient.ConnectionTimeout := Value;
end;

procedure TJSONRPCWrapper.SetInvokeMethod;
begin
  TRIOVirtualInterface(Pointer(FInterface)).OnInvoke := GenericClientMethod;
end;

procedure TJSONRPCWrapper.SetOnSafeCallException(
  const AProc: TOnSafeCallException);
begin
  FOnSafeCallException := AProc;
end;

procedure TJSONRPCWrapper.SetParamsPassByName(const AValue: Boolean);
begin
  if AValue then
    FPassByPosOrName := tppByName else
    FPassByPosOrName := tppByPos;
end;

procedure TJSONRPCWrapper.SetParamsPassByPosition(const AValue: Boolean);
begin
  if AValue then
    FPassByPosOrName := tppByPos else
    FPassByPosOrName := tppByName;
end;

procedure TJSONRPCWrapper.SetResponseTimeout(const Value: Integer);
begin
  FClient.ResponseTimeout := Value;
end;

procedure TJSONRPCWrapper.SetSendTimeout(const Value: Integer);
begin
  FClient.SendTimeout := Value;
end;

procedure TJSONRPCWrapper.SetServerURL(const Value: string);
begin
  FServerURL := Value;
end;

function TJSONRPCWrapper._AddRef: Integer;
begin
  Result := TInterlocked.Increment(FRefCount);
end;

function TJSONRPCWrapper._Release: Integer;
begin
  Result := TInterlocked.Decrement(FRefCount);
  if ((Result = 0) and not (Owner is TComponent)) or ((Result = 1) and not (Owner is TComponent)) then
    Destroy;
end;

{ TJSONRPCWrapper.TRioVirtualInterface }
{$IF NOT DEFINED(BASECLASS)}

constructor TJSONRPCWrapper.TRioVirtualInterface.Create(ARio: TJSONRPCWrapper;
  AInterface: Pointer);
begin
  FRio := ARio;
  inherited Create(AInterface);
end;

function TJSONRPCWrapper.TRioVirtualInterface.QueryInterface(const IID: TGUID;
  out Obj): HRESULT;
begin
  Result := inherited;
  if Result <> 0 then
    Result := FRio.InternalQI(IID, Obj);
end;

function TJSONRPCWrapper.TRioVirtualInterface._AddRef: Integer;
begin
  Result := FRio._AddRef;
end;

function TJSONRPCWrapper.TRioVirtualInterface._Release: Integer;
begin
  Result := FRio._Release;
end;
{$ENDIF}

{ TJSONRPCServerWrapper }

function MatchParams(const AParams1: TIntfParamEntryArray;
  const AParams2: TArray<TRttiParameter>): Boolean;
var
  I, J: Integer;
  LParams1: TIntfParamEntryArray;
  LParams2: TArray<TRttiParameter>;
begin
  LParams1 := AParams1;
  if LParams1[High(LParams1)].Info = nil then
    Delete(LParams1, High(LParams1), 1);
  LParams2 := AParams2;
  if Length(LParams2) > 0 then
    if LParams2[High(LParams2)].ParamType.Handle = nil then
      Delete(LParams2, High(LParams2), 1);

  if Length(LParams1) <> Length(LParams2) then
    Exit(False);

  J := Low(LParams2);
// Match the parameter's RTTI
  for I := Low(LParams1) to High(LParams1) do
    begin
      if LParams1[I].Info <> LParams2[J].ParamType.Handle then
        Exit(False);
      Inc(J);
    end;
  Result := True;
end;

function LookupMDAIndex(const AMethodName: string;
  const AParams: TArray<TRttiParameter>;
  const AIntfMD: TIntfMetaData): Integer; overload;
begin
  for var I := 0 to High(AIntfMD.MDA) do
   if (AIntfMD.MDA[I].Name = AMethodName) and
       MatchParams(AIntfMD.MDA[I].Params, AParams) then
     Exit(I);
  Result := -1;
end;

// Obsolete
function LookupMDAIndex(const AMethod: TRttiMethod;
  const AIntfMD: TIntfMetaData): Integer; overload;
  deprecated 'Use LookupMDAIndex with AParams';
begin
  for var I := 0 to High(AIntfMD.MDA) do
   if AIntfMD.MDA[I].SelfInfo = AMethod.Handle then
     Exit(I);
  Result := -1;
end;

function LookupParamPosition(const AParams: TIntfParamEntryArray; const AParamName: string): Integer;
begin
  for var I := Low(AParams) to High(AParams) do
    if AParams[I].Name = AParamName then
      Exit(I);
  Result := -1;
end;

destructor TJSONRPCServerWrapper.Destroy;
begin
  FOnLogIncomingJSONRequest := nil;
  FOnBeforeDispatchJSONRPC := nil;
  FOnDispatchedJSONRPC := nil;
  FOnLogOutgoingJSONResponse := nil;
  inherited;
end;

function MatchRange(ATypeInfo: PTypeInfo; LValue: Extended): Boolean;
var
  LFloatType: TFloatType;
begin
  LFloatType := ATypeInfo.TypeData.FloatType;
  case LFloatType of
    ftSingle: begin
      Result := (LValue >= Single.MinValue) and (LValue <= Single.MaxValue);
    end;
    ftDouble: begin
      Result := (LValue >= Double.MinValue) and (LValue <= Double.MaxValue);
    end;
    ftExtended: begin
      Result := (LValue >= Extended.MinValue) and (LValue <= Extended.MaxValue);
    end;
    ftCurr: begin
      Result := (LValue >= Currency.MinValue) and (LValue <= Currency.MaxValue);
    end;
  else
    Result := False;
  end;
end;

function MatchElementType(ARttiType: TRttiType; const AJSONParam: TJSONValue): Boolean; overload; forward;

function MatchElementType(ATypeInfo: PTypeInfo; ATypeKind: TTypeKind; const AJSONParam: TJSONValue): Boolean; overload;
begin
  case ATypeKind of
    tkDynArray: begin
      // Possible to have an empty array, and if that's the case, this code will
      // throw an exception, since the first element is accessed, so, assume
      // it matches
      try
        Result := MatchElementType(ATypeInfo.TypeData.DynArrElType^,
          ATypeInfo.TypeData.DynArrElType^.Kind,
          TJSONArray(AJSONParam).Items[0]
        );
      except
        Result := True;
      end;
    end;
    tkEnumeration: begin // Boolean only
      if IsBoolType(ATypeInfo) then
        begin
          Result := (AJSONParam is TJSONBool);
        end else
        begin
          // An enum can be marshalled in JSON as either a string or an integer
          // but is currently only marshalled as a string
          Result := (AJSONParam is TJSONString) or (AJSONParam is TJSONNumber);
        end;
    end;
    tkInteger: begin
      var LValue: Integer;
      Result := (AJSONParam is TJSONNumber) and
        TryStrToInt(AJSONParam.Value, LValue);
    end;
    tkFloat: begin
      var LValue: Extended;
      Result := (AJSONParam is TJSONNumber) and
        TryStrToFloat(AJSONParam.Value, LValue) and
        MatchRange(ATypeInfo, LValue);
    end;
    tkString, tkLString, tkUString, tkWString: begin
      // TJSONNumber inherits from TJSONString so we gotta make sure this is not a number
      Result := (not (AJSONParam is TJSONNumber)) and (AJSONParam is TJSONString);
    end;
  else
    Result := False;
  end;
end;

function MatchElementType(ARttiType: TRttiType; const AJSONParam: TJSONValue): Boolean; overload;
begin
  if ARttiType is TRttiArrayType then
    begin
      try
        if AJSONParam is TJSONArray then
          begin
            Result := MatchElementType(
              TRttiArrayType(ARttiType).ElementType,
              TJSONArray(AJSONParam)[0]
            );
          end else
          begin
            var LType := TRttiDynamicArrayType(ARttiType).ElementType;
            Result := AJSONParam is TJSONArray and
              MatchElementType(LType.Handle, LType.TypeKind, AJSONParam);
          end;
      except
        Result := True;
      end;
    end else
  if ARttiType is TRttiDynamicArrayType then
    begin
      // Possible to have an empty array, and if that's the case, this code will
      // throw an exception, since the first element is accessed, so, assume
      // it matches
      try
        Result := (AJSONParam is TJSONArray) and
          MatchElementType(
            TRttiDynamicArrayType(ARttiType).Handle, ARttiType.TypeKind,
            TJSONArray(AJSONParam)[0]
          );
      except
        Result := True; // assume match
      end;
    end else
    begin
      Result := MatchElementType(ARttiType.Handle, ARttiType.TypeKind, AJSONParam);
    end;
end;

procedure DumpParamType(AParam: TRttiParameter);
{$IF NOT DEFINED(DEBUG)} inline; {$ENDIF}
begin
{$IF DEFINED(DEBUG)}
  OutputDebugString(AParam.ParamType.Name);
{$ENDIF}
end;

// Match all parameter types
// If any of the parameter types do not match the JSON,
// return false
// If all parameter types match the JSON return true
function MatchParameterType(const AMethodParams: TArray<TRttiParameter>;
  const AJSONParams: TJSONValue; const AIsObj: Boolean): Boolean;
var
  LJSONArray: TJSONArray absolute AJSONParams;
  LJSONObj: TJSONObject absolute AJSONParams;
  LMethodParam: TRttiParameter;
  LJSONPair: TJSONPair;
  LJSONValue: TJSONValue;
begin
  Result := True;
  for var I := Low(AMethodParams) to High(AMethodParams) do
    begin
      LMethodParam := AMethodParams[I];
      DumpParamType(LMethodParam);
        case AIsObj of
          False: begin  // AJSONParams is an array
            Result := AJSONParams is TJSONArray;
            LJSONValue := AJSONParams;
            case LMethodParam.ParamType.TypeKind of
              tkArray: begin
                Result :=
                  MatchElementType(
                    TRttiArrayType(LMethodParam.ParamType).ElementType,
                    TJSONArray(LJSONValue).Items[0]
                  );
              end;
              tkDynArray: begin
                Result :=
                  MatchElementType(
                    TRttiDynamicArrayType(LMethodParam.ParamType).ElementType,
                    TJSONArray(LJSONValue).Items[0]
                  );
              end;
            end;
          end;
          True: begin   // AJSONParams is an object
            LJSONPair := LJSONObj.Pairs[I];
            LJSONValue := LJSONPair.JsonValue;
            case LMethodParam.ParamType.TypeKind of
              tkArray: begin
                Result := Result and (LJSONValue is TJSONArray) and
                  MatchElementType(
                    TRttiArrayType(LMethodParam.ParamType).ElementType,
                    TJSONArray(LJSONValue).Items[0]
                  );
              end;
              tkDynArray: begin
                Result := Result and (LJSONValue is TJSONArray) and
                  MatchElementType(
                    TRttiDynamicArrayType(LMethodParam.ParamType).ElementType,
                    TJSONArray(LJSONValue).Items[0]
                  );
              end;
              tkInteger, tkFloat: begin
                Result := Result and (LJSONValue is TJSONNumber);
              end;
//              tkString, tkLString, tkUString, tkWString: begin
//                // TJSONNumber inherits from TJSONString so we gotta make sure this is not a number
//                Result := Result and (LJSONValue is TJSONString) and not (LJSONValue is TJSONNumber);
//              end;
            else
              Result := Result and MatchElementType(
                LMethodParam.ParamType.Handle,
                LMethodParam.ParamType.TypeKind, LJSONValue
              );
            end;
          end;
        end;
      if not Result then
        Break;
    end;
end;

procedure DumpParams(AParams: TArray<TRttiParameter>);
{$IF NOT DEFINED(DEBUG)} inline; {$ENDIF}
begin
{$IF DEFINED(DEBUG)}
  for var I := Low(AParams) to High(AParams) do
    DumpParamType(AParams[I]);
{$ENDIF}
end;

procedure DumpMethod(AMethod: TRttiMethod);
{$IF NOT DEFINED(DEBUG)} inline; {$ENDIF}
begin
{$IF DEFINED(DEBUG)}
  if not Assigned(AMethod) then
    begin
      OutputDebugString('No method assigned!');
      Exit;
    end;
  OutputDebugString(AMethod.ToString);
{$ENDIF}
end;

procedure DumpJSONRequest(const AJSONRequestObj: TJSONObject);
{$IF NOT DEFINED(DEBUG)} inline; {$ENDIF}
begin
{$IF DEFINED(DEBUG)}
  OutputDebugString(AJSONRequestObj.ToJSON);
{$ENDIF}
end;

procedure DumpMethods(AMethods: TArray<TRttiMethod>);
{$IF NOT DEFINED(DEBUG)} inline; {$ENDIF}
begin
{$IF DEFINED(DEBUG)}
  for var LMethod in AMethods do
    DumpMethod(LMethod);
{$ENDIF}
end;

{$IF DEFINED(DEBUG)} // Figure out which methods are having issues...
procedure DebugMethods(AMethods: TArray<TRttiMethod>; const AJSONObject: TJSONObject);
begin
  for var LMethod in AMethods do
    begin
      OutputDebugString(Format('%p', [LMethod.CodeAddress]));
    end;
end;
{$ENDIF}

// Method and parameter resolution, delete methods which do not match
// the parameter type in the JSON object
procedure RemoveMethodsNotMatchingParameterCount(
  var VMethods: TArray<TRttiMethod>;
  const AParamCount: Integer;
  const AJSONObject: TJSONObject);
var
  LParamsValue: TJSONValue;
  LParamsObj: TJSONObject absolute LParamsValue;
  LParamsArray: TJSONArray absolute LParamsObj;
  LIsObj: Boolean;
begin
  LParamsValue := AJSONObject.GetValue('params');
  LIsObj := LParamsValue is TJSONObject;
  for var I := High(VMethods) downto Low(VMethods) do
    begin
      var LParams := VMethods[I].GetParameters;

      // see https://www.jsonrpc.org/specification#parameter_structures
      case LIsObj of
        False: begin  // params is an array
          if (Length(LParams) <> LParamsArray.Count) or
             (not MatchParameterType(LParams, LParamsArray, LIsObj)) then
            Delete(VMethods, I, 1);
        end;
        True: begin   // params is an object
          if (Length(LParams) <> LParamsObj.Count) or
             (not MatchParameterType(LParams, LParamsObj, LIsObj)) then
            Delete(VMethods, I, 1);
        end;
      end;
    end;
  Assert(Length(VMethods) >= 1, 'Expected to have at least 1 method!');
end;

// Finds a method with the given method name and number, as well as type of parameters
// Note that result type of the method is not considered, as result type
// cannot be resolved until the called method returns a result
// and JSON RPC supports returning different results that cannot be easily
// encapsulated without coming up with a new paradigm or a JsonConverter
// The first method that matches the parameters are considered the winner
// Use unique names for methods if you do not wish to accidentally call
// another method that matches the parameter type.
function FindMethod(AType: TRttiType; const AMethodName: string; const
  AParamCount: Integer; const AJSONObject: TJSONObject): TRttiMethod;
var
  LMethods: TArray<TRttiMethod>;
begin
  LMethods := AType.GetMethods(AMethodName);
// If there's only 1 method for a given name, return immediately
  if Length(LMethods) = 1 then
    Exit(LMethods[0]);
// If there are multiple methods with the given name, remove methods that
// do not match the JSON parameters
  RemoveMethodsNotMatchingParameterCount(LMethods, AParamCount, AJSONObject);
  if Length(LMethods) >= 1 then
    Exit(LMethods[0]);
  Result := nil;
end;

procedure MethodNotFoundError;
begin
  raise Exception.Create('Method not found') at ReturnAddress;
end;

// Working, but doesn't handle batch calls
// parses incoming JSON requests from the client
procedure TJSONRPCServerWrapper.DispatchJSONRPC(const ARequest, AResponse: TStream);
type
  TJSONState = (tjParsing, tjGettingMethod, tjLookupMethod, tjLookupParams,
    tjParseDateTime, tjParseString, tjParseInteger, tjCallMethod,
    tjParseResponse);

const CErrorFmt = '%s - Method Name: ''%s'', Param Name: ''%s'', Param Value: ''%s'', position: ''%d'', Param Kind: ''%s''';

var
  LJSONState: TJSONState;

  LParseParamPosition: Integer;
  LParseMethodName, LParseParamName, LParseParamValue: string;
  LParseParamTypeInfo: PTypeInfo;
  LJSONResultObj: TJSONObject;
begin
// Set parsing error
  LParseParamPosition := -1;

  ARequest.Position := 0;
  var LJSONRequestBytes: TArray<Byte>;
  var Len := ARequest.Size;
  SetLength(LJSONRequestBytes, Len);
  ARequest.Read(LJSONRequestBytes, Len);

  var LMapIntf := InvRegistry.GetInterface;
  var LClass := InvRegistry.GetInvokableClass;

// Fetch the meta data for the interface, this assumes there's only 1 interface
// and would need to be updated if there were more than 1 interface
// Improves performance by checking only if it's not filled up yet
  if FIntfMD.Name = '' then
    GetIntfMetaData(LMapIntf.Info, FIntfMD, True);

  LJSONState := tjParsing;
  var LJSONResponseObj: TJSONObject := TJSONObject.Create;
  var LJSONRequestObj: TJSONObject := nil;
  try
    try
      var LJSONRequestStr := TEncoding.UTF8.GetString(LJSONRequestBytes);
      DoLogIncomingRequest(LJSONRequestStr);

      LJSONRequestObj := TJSONObject.ParseJSONValue(LJSONRequestStr) as TJSONObject;
      var LJSONRequest := LJSONRequestObj.Format();
      try

        LJSONState := tjGettingMethod;
        var LMethodName := LJSONRequestObj.GetValue<string>(SMETHOD);
        var LResult: TValue;
        var LArgs: TArray<TValue> := [];

        var LRttiContext := TRttiContext.Create;
        var LType: TRttiType := LRttiContext.GetType(LMapIntf.Info);

    // NOTE!!! Notifications are requests without an ID
        var LJSONRPCRequestID: Int64 := -1;
        var LJSONRPCRequestIDString := '';
        // string, number, or NULL
        var LIDIsNumber := LJSONRequestObj.TryGetValue<Int64>(SID, LJSONRPCRequestID);
        var LIDIsString := False;
        if not LIDIsNumber then
          LIDIsString := LJSONRequestObj.TryGetValue<string>(SID, LJSONRPCRequestIDString);
        var LIsNotification := not (LIDIsNumber or LIDIsString);

        LJSONResultObj := TJSONObject.Create;
        try
          AddJSONVersion(LJSONResultObj);
          LJSONState := tjLookupMethod;
          LParseMethodName := LMethodName;
          var LParamCount := 0;
          var LParamsObjOrArray := LJSONRequestObj.FindValue(SPARAMS);
          if LParamsObjOrArray is TJSONObject then
            LParamCount := TJSONObject(LParamsObjOrArray).Count else
          if LParamsObjOrArray is TJSONArray then
            LParamCount := TJSONArray(LParamsObjOrArray).Count;
          DumpJSONRequest(LJSONRequestObj);
          var LMethod := FindMethod(LType, LMethodName, LParamCount, LJSONRequestObj);
          if not Assigned(LMethod) then
            MethodNotFoundError;
          DumpJSONRequest(LJSONRequestObj);
          DumpMethod(LMethod);
          try
            var LParams := LMethod.GetParameters;
            // SetLength so that parameters can be parsed by position or name
            SetLength(LArgs, Length(LParams));
            LJSONState := tjLookupParams;
            var LMDAIndex := LookupMDAIndex(LMethodName, LParams, FIntfMD);
//              LookupMDAIndex(LMethod, FIntfMD);

            for var I := Low(LParams) to High(LParams) do
              begin
                var LArg: TValue;
                var LParamName := Format('params.%s', [LParams[I].Name]);

                LParseParamName := LParams[I].Name;
                LParseParamPosition := I+1;
                LParseParamValue := '';
                LParseParamTypeInfo := LParams[I].ParamType.Handle;

                // look up parameter's position using name
                var LParamPosition := LookupParamPosition(FIntfMD.MDA[LMDAIndex].Params, LParams[I].Name);
                if LParamPosition = -1 then
                  LParamPosition := I;

                case LParseParamTypeInfo.Kind of
                  tkArray, tkDynArray: begin
                  end;
                else
                  // This code fails when the param is an array
                  // Set up value in case it has an error
                  try
                    if (LJSONRequestObj is TJSONObject) and
                        (not LJSONRequestObj.TryGetValue<string>(LParamName, LParseParamValue)) then
                      begin
                        var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                        LParseParamValue := LParamsArr[I].AsType<string>;
                      end;
                  except
                  end;
                end;

                var LTypeKind  := LParams[I].ParamType.TypeKind;
                // LJSONState := TJSONState(Ord(High(TJSONState)) + Ord(LTypeKind));
                // params may be by name or by position, parse incoming client JSON requests
                case LTypeKind of
                  tkArray, tkDynArray: begin
                    var LParamJSONObject := LJSONRequestObj.FindValue(LParamName);
                    if Assigned(LParamJSONObject) then
                      DeserializeJSON(LParamJSONObject, LParams[I].ParamType.Handle, LArg) else
                    begin
                      var LParam := LJSONRequestObj.P[SPARAMS];
                      if Assigned(LParam) then
                        begin
                          var LParamsArray := (LParam as TJSONArray);
                          var LParamElem := LParamsArray[I];
                          if Assigned(LParamElem) then
                            begin
                              var LParamElemJSONArray := LParamElem as TJSONArray;
                              DeserializeJSON(LParamElemJSONArray, LParams[I].ParamType.Handle, LArg);
                            end;
                        end;
                    end;
                  end;
                  tkRecord: begin
                    var LParamJSONObject := LJSONRequestObj.FindValue(LParamName);
                    var LHandlers: TRecordHandlers;
                    var LJSON := '';
                    // Try looking up the parameter by name and if it fails
                    // look up the parameter by position
                    // The JSON is then passed to the handler
                    if Assigned(LParamJSONObject) then
                      LJSONRequestObj.TryGetValue<string>(LParamName, LJSON) else
                      LJSON := TJSONArray(LParamsObjOrArray)[LParamPosition].Value;
                    if LookupRecordHandlers(LParseParamTypeInfo, LHandlers) then
                      begin
                        LArg := LHandlers.JSONToTValue(LJSON);
                      end else
//                    if LParseParamTypeInfo = TypeInfo(BigDecimal) then
//                      begin
//                        var LParamValue: string;
//                        LJSONRequestObj.TryGetValue<string>(LParamName, LParamValue);
//                        LArg := TValue.From(BigDecimal.Create(LParamValue));
//                      end else
//                    if LParseParamTypeInfo = TypeInfo(BigInteger) then
//                      begin
//                        var LParamValue: string;
//                        LJSONRequestObj.TryGetValue<string>(LParamName, LParamValue);
//                        var LBigInteger: BigInteger;
//                        if LParamValue.StartsWith('0x', True) then
//                          LParamValue := Copy(LParamValue, Low(LParamValue) + 2);
//                        BigInteger.TryParse(LParamValue, 16, LBigInteger);
//                        LArg := TValue.From(LBigInteger);
//                      end else
                      begin
                        // Default handling of records
                        if Assigned(LParamJSONObject) then
                          DeserializeJSON(LParamJSONObject, LParams[I].ParamType.Handle, LArg);
                      end;
                  end;
                  tkEnumeration: begin // False, True, etc...
                    // Supported types are strings, numbers, boolean, null, objects and arrays
                    if IsBoolType(LParseParamTypeInfo) then
                      begin
                        case LParseParamTypeInfo^.TypeData^.OrdType of
//                        case GetTypeData(LParseParamTypeInfo)^.OrdType of
                          otSByte, otUByte: begin
                            LArg := TValue.From(Boolean(SameText(
                              LParseParamValue,
                              'True')));
                          end;
                          otSWord, otUWord: begin
                            LArg := TValue.From(WordBool(SameText(
                              LParseParamValue,
                              'True')));
                          end;
                          otSLong, otULong: begin
                            LArg := TValue.From(LongBool(SameText(
                              LParseParamValue,
                            'True')));
                          end;
                        end;
                      end else
                      begin // Really an enumeration
                        var LEnumValue := GetEnumValue(LParseParamTypeInfo,
                          LParseParamValue
                        );
                        TValue.Make(@LEnumValue, LParseParamTypeInfo, LArg);
                      end;
                  end;
                  tkString, tkLString, tkUString, tkWString: begin
                    LArg := TValue.From<string>(LParseParamValue);
                  end;
                  tkInteger: begin
                    var LTypeName := LParams[I].ParamType.Name;
                    var LTypeInfo := LParams[I].ParamType.Handle;
                    begin
                      case LTypeInfo.TypeData.OrdType of
                        otSByte: begin // ShortInt
                          Assert(SameText(LTypeName, 'ShortInt'), 'Type mismatch!');
                          LArg := TValue.From(StrToInt(LParseParamValue));
                        end;
                        otSWord: begin // SmallInt
                          Assert(SameText(LTypeName, 'SmallInt'), 'Type mismatch!');
                            LArg := TValue.From(
                              StrToInt(LParseParamValue)
                            );
                        end;
                        otSLong: begin // Integer
                          Assert(SameText(LTypeName, 'Integer'), 'Type mismatch!');
                            LArg := TValue.From(
                              StrToInt(LParseParamValue)
                            );
                        end;
                        otUByte: begin // Byte
                          Assert(SameText(LTypeName, 'Byte'), 'Type mismatch!');
                          LArg := TValue.From(Byte(StrToInt(LParseParamValue)));
                        end;
                        otUWord: begin // Word
                          Assert(SameText(LTypeName, 'Word'), 'Type mismatch!');
                          LArg := TValue.From(StrToUInt(LParseParamValue));
                        end;
                        otULong: begin // Cardinal
                          Assert(SameText(LTypeName, 'Cardinal'), 'Type mismatch!');
                          LArg := TValue.From(StrToUInt(LParseParamValue));
                        end;
                      end;
                    end;

                  end;
                  tkInt64: begin
                    var LParamValue: Int64;
                    if not LJSONRequestObj.TryGetValue<Int64>(LParamName, LParamValue) then
                      begin
                        var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                        var LParamElem := LParamsArr[I];
                        LParamValue := LParamElem.AsType<Int64>;
                      end;
                    LArg := TValue.From(LParamValue);
                  end;
                  tkFloat: begin
                    // check if it's a date time
                    var LTypeInfo := FIntfMD.MDA[LMDAIndex].Params[I].Info;
                    var LFloatType := LTypeInfo^.TypeData.FloatType;
                    begin
                      CheckTypeInfo(LTypeInfo);
                      CheckFloatType(LFloatType);
                      case LFloatType of
                        ftComp: begin
                          var LValue: Comp;
                          if not LJSONRequestObj.TryGetValue<Comp>(LParamName, LValue) then
                            begin
                              var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                              var LParamElem := LParamsArr[I];
                              LValue := LParamElem.AsType<Comp>;
                            end;
                          LArg := TValue.From(LValue);
                        end;
//                        ftCurr: begin
//                          var LValue: Currency;
//                          if not LJSONRequestObj.TryGetValue<Currency>(LParamName, LValue) then
//                            begin
//                              var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
//                              var LParamElem := LParamsArr[I];
//                              LValue := LParamElem.AsType<Currency>;
//                            end;
//                          LArg := TValue.From(LValue);
//                        end;
                        ftCurr, ftDouble, ftExtended, ftSingle:
                        begin
                          if (LTypeInfo = System.TypeInfo(TDate)) or
                             (LTypeInfo = System.TypeInfo(TTime)) or
                             (LTypeInfo = System.TypeInfo(TDateTime)) then
                            begin
                              var LDateTimeStr: string;
                              if not LJSONRequestObj.TryGetValue<string>(LParamName, LDateTimeStr) then
                                begin
                                  var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                                  var LParamElem := LParamsArr[I];
                                  LDateTimeStr := LParamElem.AsType<string>;
                                end;
                              var LDateTime: TDateTime := ISO8601ToDate(LDateTimeStr, False); // Convert to local date/time
                              LArg := TValue.From(LDateTime);
                            end else
                          if LTypeInfo = TypeInfo(Single) then
                            begin
                              var LValue: Single;
                              if not LJSONRequestObj.TryGetValue<Single>(LParamName, LValue) then
                                begin
                                  var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                                  var LParamElem := LParamsArr[I];
                                  LValue := LParamElem.AsType<Single>;
                                end;
                              LArg := TValue.From(LValue);
                            end else
                          if LTypeInfo = TypeInfo(Extended) then
                            begin
                              // Delphi cannot handle the precision of Extended
                              // if/when the client is 32-bit and the server is 64-bit
                              // because Extended.MaxValue (32-bit) > Extended.MaxValue (64-bit)
                              // so convert to BigDecimal
                              var LHandlers: TRecordHandlers;
                              if LookupRecordHandlers(LTypeInfo, LHandlers) then
                                begin
                                  var LValue: Extended;

                                  if not LJSONRequestObj.TryGetValue<Extended>(LParamName, LValue) then
                                    begin
                                      var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                                      var LJSON := LParamsArr[I].Value;
                                      LArg := LHandlers.JSONToTValue(LJSON);
                                    end else
                                    begin
                                      LArg := TValue.From(LValue);
                                    end;

                                end;
                            end else
                            begin
                              // ftCurr, ftDouble
                              var LValue: Double := StrToFloat(LParseParamValue);
//                              var LParamValue := LJSONRequestObj.FindValue(LParamName);
//                              if Assigned(LParamValue) then
//                                begin
////                                  LValue := // LJSONRequestObj.GetValue<Double>(LParamName);
////                                    LParamValue.AsType<Double>;
//                                  var LValueStr := LParamValue.Value;
//                                  TextToFloat(LValueStr, LValue, System.SysUtils.FormatSettings);
//                                end else
//                                begin
//                                  var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
//                                  var LParamElem := LParamsArr[I];
//                                  LValue := LParamElem.AsType<Double>;
//                                end;
////                              if not LJSONRequestObj.TryGetValue<Double>(LParamName, LValue) then
////                                begin
////                                  var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
////                                  var LParamElem := LParamsArr[I];
////                                  LValue := LParamElem.AsType<Double>;
////                                end;
                              LArg := TValue.From(LValue);
                            end;
                        end; // ftDouble, ftSingle, etc...
                      end; // case
                    end; // begin
                  end;
                else
                  raise EJSONException.Create(SParseError);
                end;
                if LParamPosition <> -1 then
                  LArgs[LParamPosition] := LArg;
              end;

        // {"jsonrpc": "2.0", "result": 19, "id": 1} example of expected result
          // Respond with the same request ID, if the request wasn't not a notification
            var LInstance := TInvokableClassClass(LClass).Create;

            var LIntf: IJSONRPCMethods;
            var LJSONRPCMethodException: IJSONRPCMethodException;
            if Supports(LInstance, IJSONRPCMethodException, LJSONRPCMethodException) then
              begin
                LJSONRPCMethodException.MethodName := LMethodName;
              end;
            if Supports(LInstance, LMapIntf.GUID, LIntf) then
              begin
//              try
                var LObj := TValue.From(LIntf);
                LJSONState := tjCallMethod;

                // Dispatch the call to the implementor
                LResult := LMethod.Invoke(LObj, LArgs); // working
//                LResult := LMethod.Invoke(LInstance, LArgs); // working

                LJSONState := tjParseResponse;
                if Assigned(LMethod.ReturnType) then
                  begin
                    // Add result into the response
                    // process outgoing response from server to client
                    case LMethod.ReturnType.TypeKind of
                      tkArray,
                      tkDynArray: begin
                        var LJSONArray := ValueToJSONArray(LResult, LMethod.ReturnType.Handle);
                        LJSONResultObj.AddPair(SRESULT, LJSONArray);
                      end;
                      tkRecord: begin
                        var LTypeInfo := LMethod.ReturnType.Handle;
                        var LJSONObject: TJSONValue;
                        var LHandlers: TRecordHandlers;
                        // Look up custom handlers for records
                        if LookupRecordHandlers(LTypeInfo, LHandlers) then
                          begin
                            LHandlers.TValueToJSON(
                              LResult, LTypeInfo, LJSONResultObj
                            );
                          end else
                          begin
                            // default handler for records
                            var LJSON := SerializeRecord(LResult, LTypeInfo);
                            LJSONObject := TJSONObject.ParseJSONValue(LJSON);
                            LJSONResultObj.AddPair(SRESULT, LJSONObject);
                          end;
                      end;
                      tkEnumeration: begin
                        // Only possible values are True, False
                        var LTypeInfo := LMethod.ReturnType.Handle;
                        if IsBoolType(LTypeInfo) then
                          LJSONResultObj.AddPair(SRESULT, TJSONBool.Create(LResult.AsBoolean)) else
                        begin // really an enum type
                          var LResultOrdinal := LResult.AsOrdinal;
                          var LResultValue := GetEnumName(LTypeInfo, LResultOrdinal);
                          LJSONResultObj.AddPair(SRESULT, TJSONString.Create(LResultValue));
                        end;
                      end;
                      tkString, tkLString, tkUString, tkWString: begin
                        LJSONResultObj.AddPair(SRESULT, LResult.AsString);
                      end;
                      tkFloat: begin
                        var LTypeInfo := LMethod.ReturnType.Handle;
                        var LFloatType := LTypeInfo^.TypeData.FloatType;
                        begin
                          CheckTypeInfo(LTypeInfo);
                          CheckFloatType(LFloatType);
                          case LFloatType of
                            ftComp: begin
                              //
                            end;
                            ftCurr: begin
                              LJSONResultObj.AddPair(SRESULT, LResult.AsCurrency);
                            end;
                            ftDouble, ftExtended, ftSingle:
                            begin
                              if (LTypeInfo = System.TypeInfo(TDate)) or
                                 (LTypeInfo = System.TypeInfo(TTime)) or
                                 (LTypeInfo = System.TypeInfo(TDateTime)) then
                                begin
                                  var LDateTimeStr :=  System.DateUtils.DateToISO8601(LResult.AsExtended, False);
                                  LJSONResultObj.AddPair(SRESULT, LDateTimeStr);
                                end else
                              if LTypeInfo = System.TypeInfo(Single) then
                                begin
                                  LJSONResultObj.AddPair(SRESULT, LResult.AsExtended);
                                end else
                              if LTypeInfo = System.TypeInfo(Extended) then
                                begin
                                  LJSONResultObj.AddPair(SRESULT, LResult.AsExtended);
                                end else
                                begin
                                  // Currency and Double
                                  LJSONResultObj.AddPair(SRESULT, LResult.AsExtended);
                                end;
                            end;
                          end;
                        end;
                      end;
                      tkInteger, tkInt64: LJSONResultObj.AddPair(SRESULT, LResult.AsOrdinal);
                    else
                    end;
                  end else
                  begin
                    // Default result when none is expected
                    // LJSONResultObj.AddPair(SRESULT, DefaultTrueBoolStr);
                    LJSONResultObj.AddPair('noresult', 'noresult');
                  end;
              end;

          except
            on E: Exception do
              begin
                var LErrMsg := E.Message;
                UniqueString(LErrMsg);
                // handle missing method, parsing errors, etc
                var LJSONErrorObj := TJSONObject.Create;
                case LJSONState	of
                  tjGettingMethod: begin
                    LJSONErrorObj.AddPair(SCODE, CInternalError);
                    LJSONErrorObj.AddPair(SMESSAGE, LErrMsg);
                  end;
                  tjLookupMethod: begin
                    LJSONErrorObj.AddPair(SCODE, CMethodNotFound);
                    LJSONErrorObj.AddPair(SMESSAGE, SMethodNotFound);
                  end;
                  tjLookupParams: begin
                    // Failed to look up params
                    LJSONErrorObj.AddPair(SCODE, CInvalidParams);
                    LJSONErrorObj.AddPair(SMESSAGE, LErrMsg);
                  end;
                  tjCallMethod: begin
                    LJSONErrorObj.AddPair(SCODE, CInternalError);
                    LJSONErrorObj.AddPair(SMESSAGE, LErrMsg);
                    LJSONErrorObj.AddPair(SMETHOD, LMethodName);
                  end;
                else
                  FreeAndNil(LJSONErrorObj);
                  raise;
                end;
                LJSONResultObj.AddPair(SERROR, LJSONErrorObj);
              end;
          end;
          // add Notification ID here
          if not LIsNotification then
            begin
              if LIDIsNumber then LJSONResultObj.AddPair(SID, LJSONRPCRequestID) else
              if LIDIsString then LJSONResultObj.AddPair(SID, LJSONRPCRequestIDString);
            end;

          // Convert the JSON object to JSON
          var LJSONResult := LJSONResultObj.ToJSON;
          var LJSONResultBytes: TBytes; var LCount: NativeInt;
          DoBeforeDispatchJSONRPC(LJSONResult);
          JsonToTBytesCount(LJSONResult, LJSONResultBytes, LCount);
          AResponse.Write(LJSONResultBytes, LCount);

          DoDispatchedJSONRPC(LJSONRequest);
          DoLogOutgoingResponse(LJSONResultObj.Format());
        finally
          LJSONResultObj.Free;
        end;
        LRttiContext.Free;
      finally
        FreeAndNil(LJSONRequestObj);
      end;
      FreeAndNil(LJSONResponseObj);
    except
      // handle failure to parse
      if Assigned(LJSONRequestObj) then
        begin
          AddJSONVersion(LJSONResponseObj);
          case LJSONState of
            tjGettingMethod: begin
              LJSONResponseObj.AddPair(SERROR, CParseError);
              LJSONResponseObj.AddPair(SMESSAGE, SMethodNotFound);
            end;
            tjParsing: begin
              LJSONResponseObj.AddPair(SERROR, CParseError);
              LJSONResponseObj.AddPair(SMESSAGE, SParseError);
            end;
          else
            if LJSONState > High(TJSONState) then // parsing error
              begin
                var LTypeKind := Ord(LJSONState) - Ord(High(TJSONState));
                LJSONResponseObj.AddPair(SERROR, CParseError);
                var LErrorMessage := Format(
'%s - Method Name: ''%s'', Param Name: ''%s'', Param Value: ''%s'', position: ''%d'', Param Kind: ''%s'' ',
                  [
                   SParseError, LParseMethodName, LParseParamName, LParseParamValue,
                   LParseParamPosition,
                   GetEnumName(TypeInfo(TTypeKind), Ord(LTypeKind))
                  ]
                );
                LJSONResponseObj.AddPair(SMESSAGE, LErrorMessage);
              end;
          end;
        end else
        begin
          LJSONResponseObj.AddPair(SERROR, CInvalidRequest);
          LJSONResponseObj.AddPair(SMESSAGE, SInvalidRequest);
          if not Assigned(LJSONResponseObj.FindValue('id')) then
            LJSONResponseObj.AddPair('id', TJSONNull.Create);
        end;
    end;
    if Assigned(LJSONResponseObj) then
      begin
        var LJSONResultBytes: TBytes; var LCount: NativeInt;
        var LJSONResult := LJSONResponseObj.ToJSON;
        DoBeforeDispatchJSONRPC(LJSONResult);
        JsonToTBytesCount(LJSONResult, LJSONResultBytes, LCount);
        AResponse.Write(LJSONResultBytes, LCount);
        DoLogOutgoingResponse(LJSONResponseObj.Format());
      end;
  finally
    FreeAndNil(LJSONRequestObj);
    LJSONResponseObj.Free;
  end;
end;

procedure TJSONRPCServerWrapper.DoDispatchedJSONRPC(const AJSONRequest: string);
begin
  if Assigned(FOnDispatchedJSONRPC) then
    FOnDispatchedJSONRPC(AJSONRequest);
end;

procedure TJSONRPCServerWrapper.DoBeforeDispatchJSONRPC(var AJSONResponse: string);
begin
  if Assigned(FOnBeforeDispatchJSONRPC) then
    FOnBeforeDispatchJSONRPC(AJSONResponse);
end;

procedure TJSONRPCServerWrapper.DoLogIncomingRequest(const ARequest: string);
begin
  if Assigned(FOnLogIncomingJSONRequest) then
    FOnLogIncomingJSONRequest(ARequest);
end;

procedure TJSONRPCServerWrapper.DoLogOutgoingResponse(const AResponse: string);
begin
  if Assigned(FOnLogOutgoingJSONResponse) then
    FOnLogOutgoingJSONResponse(AResponse);
end;

function TJSONRPCServerWrapper.GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
begin
  Result := FOnDispatchedJSONRPC;
end;


function TJSONRPCServerWrapper.GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
begin
  Result := FOnLogIncomingJSONRequest;
end;

function TJSONRPCServerWrapper.GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
begin
  Result := FOnLogOutgoingJSONResponse;
end;

procedure TJSONRPCServerWrapper.InitClient;
begin
  // do nothing
end;

function TJSONRPCServerWrapper.InternalQI(const IID: TGUID; out Obj): HResult;
begin
  { IInterface, IJSONRPCDispatch, IJSONRPCDispatchEvents, IJSONRPCGetSetDispatchEvents, etc... }
  if ((IID = IInterface) or (IID = IJSONRPCDispatch) or
      (IID = IJSONRPCDispatchEvents) or
      (IID = IJSONRPCGetSetDispatchEvents)) and GetInterface(IID, Obj) then
    Result := S_OK else
    Result := E_NOINTERFACE;
end;

procedure TJSONRPCServerWrapper.SetInvokeMethod;
begin
// This is empty, the server should never call any methods, as all
// it does is respond to calls
end;

procedure TJSONRPCServerWrapper.SetOnDispatchedJSONRPC(
  const AProc: TOnDispatchedJSONRPC);
begin
  FOnDispatchedJSONRPC := AProc;
end;

procedure TJSONRPCServerWrapper.SetOnLogIncomingJSONRequest(const AProc: TOnLogIncomingJSONRequest);
begin
  FOnLogIncomingJSONRequest := AProc;
end;

procedure TJSONRPCServerWrapper.SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);
begin
  FOnLogOutgoingJSONResponse := AProc;
end;

end.
