{---------------------------------------------------------------------------}
{                                                                           }
{ File:      JSONRPC.RIO.pas                                                }
{ Function:  Remote invokable class types                                   }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit JSONRPC.RIO;

{$DEFINE BASECLASS}
{$DEFINE SUPPORTS_JSONOBJECT_AS_RESULT}

{$ALIGN 16}
{$CODEALIGN 16}
{$IOCHECKS OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}
{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.TypInfo, System.Classes, System.Rtti, System.Generics.Collections,
  System.JSON.Serializers,
  JSONRPC.InvokeRegistry, System.SysUtils,
  Soap.IntfInfo,
  System.Net.HttpClient, JSONRPC.Common.Types, System.JSON,
  System.Net.URLClient, JSONRPC.Common.Consts;

type
  TJSONRPCWrapper = class;

  IJSONRPCMethods = JSONRPC.Common.Types.IJSONRPCMethods;

  TOnBeforeParseEvent = reference to procedure(const AContext: TInvContext;
    AMethNum: Integer; const AMethMD: TIntfMethEntry; const AMethodID: Int64;
    AJSONResponse: TStream);

  TNetHeaders = System.Net.URLClient.TNetHeaders;
  TNameValuePair = System.Net.URLClient.TNameValuePair;
  /// <summary>
  /// </summary>
  /// <params name="VNetHeaders">
  /// </params>
  TOnBeforeInitializeHeaders = reference to procedure(var VNetHeaders: TNetHeaders);
  TOnAfterInitializeHeaders = reference to procedure(var VNetHeaders: TNetHeaders);

  TInvContext = JSONRPC.InvokeRegistry.TInvContext;
  TIntfMethEntryHelper = record helper for TIntfMethEntry
  protected
    function IJSONRPCMethods_Length(const ARttiContext: TRttiContext): Integer;
    function GetSelfInfo: PTypeInfo; inline;
  public
    function JSONMethodName(const ARttiContext: TRttiContext): string;
    function JSONParamsByPos(const ARttiContext: TRttiContext): Boolean;
    property MethodInfo: PTypeInfo read GetSelfInfo;
  end;

{$IF DEFINED(BASECLASS)}
  TBaseJSONRPCWrapper = class abstract(TComponent,
    IPassParamsByPosition, IPassParamsByName, IPassEnumByName
  )
  protected
  var
    FIntfMD: TIntfMetaData;
    FPassByPosOrName: TPassParamByPosOrName;
    FPassEnumByName: Boolean;
    FLogFormat: TLogFormat;
    FOnAuthentication: TOnAuthentication;
    procedure InitClient; virtual; abstract;
    procedure SetInvokeMethod; virtual; abstract;
    procedure DoDispatch(const AContext: TInvContext; AMethNum: Integer;
      const AMethMD: TIntfMethEntry); virtual;
    function InternalQI(const IID: TGUID; out Obj): HResult; virtual; stdcall; abstract;
  type
    {$REGION 'TRioVirtualInterface'}
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
    {$ENDREGION 'TRioVirtualInterface'}
  public
    constructor Create(AOwner: TComponent); override;

    { IPassParamsByName }
    function GetPassParamsByName: Boolean;
    procedure SetPassParamsByName(const AValue: Boolean);

    { IPassParamsByPosition }
    function GetPassParamsByPosition: Boolean;
    procedure SetPassParamsByPosition(const AValue: Boolean);

    { IPassEnumByName }
    function GetPassEnumByName: Boolean;
    procedure SetPassEnumByName(const AValue: Boolean);

    /// <summary>Passes enum by name, if true. <para />
    /// Otherwise, enums are passed by their ordinal value. <para />
    /// Client side must match the server side.
    /// </summary>
    property PassEnumByName: Boolean read GetPassEnumByName write SetPassEnumByName;

    /// <summary>Passes parameters by name, if true. <para />
    /// Otherwise, parameters are passed by position. <para />
    /// Client side must match the server side.
    /// </summary>
    property PassParamsByName: Boolean read GetPassParamsByName write SetPassParamsByName;

    /// <summary>Passes parameters by position, if true. <para />
    /// Client side must match the server side.
    /// </summary>
    property PassParamsByPos: Boolean read GetPassParamsByPosition write SetPassParamsByPosition;

    /// <summary> Passes parameters by position, if true. <para />
    /// Client side must match the server side.
    /// </summary>
    property PassParamsByPosition: Boolean read GetPassParamsByPosition write SetPassParamsByPosition;

    /// <summary> Chooses the format to log the request, raw or decoded.
    /// </summary>
    property LogFormat: TLogFormat read FLogFormat write FLogFormat;

    property OnAuthentication: TOnAuthentication read FOnAuthentication
      write FOnAuthentication;
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
    IPassParamsByPosition, IPassParamsByName, IPassEnumByName,
    {$ENDIF}
    IInvokable, ISafeCallException, IJSONRPCWrapper,
    IJSONRPCInvocationSettings,
    IJSONRPCClientLog)
  protected
  var
    FExceptObj: TObject;
    FServerURL: string;
    FClient: TJSONRPCTransportWrapper;
    {$IF NOT DEFINED(BASECLASS)}
    FIntfMD: TIntfMetaData;
    FPassByPosOrName: TPassParamByPosOrName;
    FEnumByName: Boolean;
    {$ENDIF}
    FAppendMethodName: Boolean;
    FJSONMethodID: Int64;
    FInterface: IInterface;
    FOnBeforeExecute: TBeforeExecuteEvent;
    FOnAfterExecute: TAfterExecuteEvent;
    FOnBeforeParse: TOnBeforeParseEvent;

    FOnBeforeInitializeHeaders: TOnBeforeInitializeHeaders;
    FOnAfterInitializeHeaders: TOnAfterInitializeHeaders;
    FMethodNames: TArray<string>;

    FOnSync: TOnSyncEvent;
    FOnSafeCallException: TOnSafeCallException;
    FIID: TGUID;
    FRefCount: Integer;
    FOnLogOutgoingJSONRequest: TOnLogOutgoingJSONRequest;
    FOnLogIncomingJSONResponse: TOnLogIncomingJSONResponse;
    FOnLogServerURL: TOnLogServerURL;

    /// <summary> Parses the enum with the given parameters.
    /// </summary>
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

    /// <summary> Converts the Delphi native call to a JSON RPC 2.0 method call
    /// and dispatches the call to the registered transport wrapper.
    /// </summary>
    /// <remarks> Client side JSON RPC parameter conversion </remarks>
    procedure DoDispatch(const AContext: TInvContext; AMethNum: Integer;
      const AMethMD: TIntfMethEntry); {$IF DEFINED(BASECLASS)}override;{$ENDIF}

    /// <summary>
    /// Logs the outgoing request.
    /// <remarks> It is essential that any exceptions be trapped within.
    /// </remarks>
    /// </summary>
    procedure DoLogOutgoingRequest(const ARequest: string);

    /// <summary>
    /// Logs the incoming response.
    /// <remarks> It is essential that any exceptions be trapped within.
    /// </remarks>
    /// </summary>
    procedure DoLogIncomingResponse(const AResponse: string);

    /// <summary> Gets the first chance to parse the enum that comes through
    /// the native Delphi call. By default, it's not handled, unless
    /// OnParseEnum is assigned. Calls FOnParseEnum with all the given parameters.
    /// </summary>
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
    // TODO: Consider calling an event here?
    function DoParseUnhandledResult(AJSONResponseObj: TJSONValue; AResultP: Pointer): Boolean; virtual;

    /// <summary>
    /// Called before the result is parsed.
    /// Return false to continue default parsing
    /// </summary>
    // TODO: Consider calling an event here?
    function DoParseJSONResult(ATypeInfo: PTypeInfo; AJSONResponseObj: TJSONValue; AResultP: Pointer): Boolean; virtual;

    /// <summary>
    /// Called when the final server URL has changed before a request is going to be submitted.
    /// This is for JSON RPC servers like Aptos, where every method has a different URL.
    /// <remarks> It is essential that any exceptions be trapped within.
    /// </remarks>
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

    {$IF NOT DEFINED(BASECLASS)}
    { IPassParamsByName }
    function GetPassParamsByName: Boolean;
    procedure SetPassParamsByName(const AValue: Boolean);

    { IPassParamsByPosition }
    function GetPassParamsByPosition: Boolean;
    procedure SetPassParamsByPosition(const AValue: Boolean);

    { IPassEnumByName }
    function GetPassEnumByName: Boolean;
    procedure SetPassEnumByName(const AValue: Boolean);
    {$ENDIF}

    { IJSONRPCInvocationSettings }

    {$IF RTLVersion >= TRTLVersion.Delphi120 }
    function GetConnectionTimeout: Integer;
    procedure SetConnectionTimeout(const Value: Integer);
    {$ENDIF}

    function GetSendTimeout: Integer;
    procedure SetSendTimeout(const Value: Integer);

    function GetResponseTimeout: Integer;
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


    /// <summary>
    /// Returns the JSONHttpMethod attribute or '' if it doesn't exist.
    /// </summary>
    function GetHttpMethod(const AMethodType: TRttiType;
      const AMethMD: TIntfMethEntry): string;

    /// <summary>
    /// Returns the UrlSuffix attribute or '' if it doesn't exist.
    /// </summary>
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

    /// <summary> Called before HTTP headers are initialized.
    /// Only necessary if transport mechanism is HTTP
    /// </summary>
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

    /// <summary> Parses the enum specified in a native Delphi call.
    /// </summary>
    property OnParseEnum: TOnParseEnum read FOnParseEnum write FOnParseEnum;

    /// <summary> Specifies that safecall exception handler
    /// </summary>
    property OnSafeCallException: TOnSafeCallException read FOnSafeCallException write
      FOnSafeCallException;

    property OnSync: TOnSyncEvent read FOnSync write FOnSync;

    {$IF NOT DEFINED(BASECLASS)}
    /// <summary> Specifies that parameters will be passed/sent by position in the params array
    /// </summary>
    property PassParamsByPos: Boolean read GetPassParamsByPosition write SetPassParamsByPosition;
    /// <summary> Specifies that parameters will be passed/sent by position in the params array
    /// </summary>
    property PassParamsByPosition: Boolean read GetPassParamsByPosition write SetPassParamsByPosition;
    /// <summary> Specifies that parameters will be passed/sent by name in the params object
    /// </summary>
    property PassParamsByName: Boolean read GetPassParamsByName write SetPassParamsByName;
    {$ENDIF}

    {$IF RTLVersion >= TRTLVersion.Delphi120 }
    /// <summary> Specifies the connnection timeout, when connecting to the server
    /// </summary>
    property ConnectionTimeout: Integer read GetConnectionTimeout write SetConnectionTimeout;
    /// <summary> Specifies the send timeout, when sending data to the server
    /// </summary>
    {$ENDIF}

    property SendTimeout: Integer read GetSendTimeout write SetSendTimeout;
    /// <summary> Specifies the response timeout, when receiving data from the server
    /// </summary>
    property ResponseTimeout: Integer read GetResponseTimeout write SetResponseTimeout;

    property JSONRPCWrapper: TJSONRPCWrapper read GetJSONRPCWrapper;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
  end;

  TJSONWrapper = class(TJSONRPCWrapper)
  protected
    procedure InitClient; override;
  end;

  /// <summary> JSON RPC server side handling
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

    FPersistent, FFormatJSONResponse: Boolean;
    FJSONRPCInstances: TArray<IJSONRPCMethods>;

    procedure SetPersistent(const Value: Boolean);
    function CreateInvokableClass(AClass: TInvokableClassClass): TObject;

    procedure DoBeforeDispatchJSONRPC(var AJSONResponse: string);
    procedure DoDispatchedJSONRPC(const AJSONRequest: string);

    /// <summary>
    /// Logs the incoming request.
    /// </summary>
    /// <remarks> It is essential that any exceptions be trapped within.
    /// </remarks>
    procedure DoLogIncomingRequest(const ARequest: string);

    /// <summary>
    /// Logs the outgoing response.
    /// </summary>
    /// <remarks> It is essential that any exceptions be trapped within.
    /// </remarks>
    procedure DoLogOutgoingResponse(const AResponse: string);

    { IJSONRPCGetSetDispatchEvents }
    function GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);

    function GetOnLogIncomingJSONRequest: TOnLogIncomingJSONRequest;
    procedure SetOnLogIncomingJSONRequest(const AProc: TOnLogIncomingJSONRequest);

    function GetOnLogOutgoingJSONResponse: TOnLogOutgoingJSONResponse;
    procedure SetOnLogOutgoingJSONResponse(const AProc: TOnLogOutgoingJSONResponse);

    procedure InitClient; override;
    procedure SetInvokeMethod; override;

    function InternalQI(const IID: TGUID; out Obj): HResult; override; stdcall;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary> Dispatches a single RPC call to the native implementation.
    /// </summary>
    /// <param name="ARequestObj"> contains the RPC JSON call data </param>
    /// <param name="VResponseObj"> returns nil if call is a notification,
    /// otherwise, this is the result of the call</param>
    procedure DispatchJSONRPC(
      const ARequestObj: TJSONValue; var VResponseObj: TJSONObject;
      const E: Exception = nil); overload;

    /// <summary>
    /// Parses incoming JSON requests from the client.
    /// Handles both single and batch RPC calls.
    /// </summary>
    /// <exception cref="EJSONRPCParamParsingException" >
    /// <EJSONRPCParamParsingException, EJSONRPCMethodException
    /// </exception>
    /// <remarks> server side handler </remarks>
    procedure DispatchJSONRPC(const ARequest, AResponse: TStream); overload;

    /// <summary> This is the old DispatchJSONRPC. Once the new DispatchJSONRPC
    /// method has been confirmed to be stable, this can be removed.
    /// </summary>
    procedure OldDispatchJSONRPC(const ARequest, AResponse: TStream); deprecated 'Use DispatchJSONRPC';

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

    /// <summary> Support for persistent interfaces.<para />
    /// If Persistent is false, each interface is recreated and destroyed
    /// at every incoming request, otherwise, the required interface is
    /// created once, and used repeatedly, so it can keep track of state.
    /// </summary>
    property Persistent: Boolean read FPersistent write SetPersistent;
  end;

procedure RegisterJSONRPCWrapper(const ATypeInfo: PTypeInfo);
procedure RegisterJSONWrapper(const ATypeInfo: PTypeInfo); inline;
procedure RegisterInvokableClass(const AClass: TClass);

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

function SetPassParamsByName(const AIntf: IInterface;
  APassParamsByName: Boolean = True): Boolean;
function SetPassParamsByPosition(const AIntf: IInterface;
  APassParamsByPos: Boolean = True): Boolean;

implementation

uses
{$IF DEFINED(DEBUG)} // Figure out which methods are having issues...
  {$IF DEFINED(MSWINDOWS)}Winapi.Windows,{$ENDIF}
{$ENDIF}
  System.Types, System.SyncObjs,
  System.DateUtils, JSONRPC.JsonUtils,
  JSONRPC.Common.RecordHandlers,
  System.JSONConsts, System.Math;

procedure AssignJSONRPCSafeCallExceptionHandler(const AIntf: IInterface;
  const ASafeCallExceptionHandler: TOnSafeCallException);
begin
  var LSafeCallException: ISafeCallException;
  if Supports(AIntf, ISafeCallException, LSafeCallException) then
    LSafeCallException.OnSafeCallException := ASafeCallExceptionHandler;
end;

function SetPassParamsByName(const AIntf: IInterface;
  APassParamsByName: Boolean = True): Boolean;
var
  LPassParamsByName: IPassParamsByName;
begin
  if Supports(AIntf, IPassParamsByName, LPassParamsByName) then
    begin
      LPassParamsByName.PassParamsByName := APassParamsByName;
      Result := True;
    end else
    begin
      Result := False;
    end;
end;

function SetPassParamsByPosition(const AIntf: IInterface;
  APassParamsByPos: Boolean = True): Boolean;
var
  LPassParamsByPos: IPassParamsByPosition;
begin
  if Supports(AIntf, IPassParamsByPosition, LPassParamsByPos) then
    begin
      LPassParamsByPos.PassParamsByPosition := APassParamsByPos;
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

procedure RegisterJSONWrapper(const ATypeInfo: PTypeInfo);
begin
  RegisterJSONRPCWrapper(ATypeInfo);
end;

procedure RegisterInvokableClass(const AClass: TClass);
begin
  InvRegistry.RegisterInvokableClass(AClass);
end;

{$IF DEFINED(BASECLASS)}
constructor TBaseJSONRPCWrapper.Create(AOwner: TComponent);
begin
  inherited;

  PassEnumByName := True;
  PassParamsByName := True;

end;

procedure TBaseJSONRPCWrapper.DoDispatch(const AContext: TInvContext;
  AMethNum: Integer; const AMethMD: TIntfMethEntry);
begin
end;

{ TBaseJSONRPCWrapper.TRioVirtualInterface }
constructor TBaseJSONRPCWrapper.TRioVirtualInterface.Create(ARio: TJSONRPCWrapper;
  AInterface: Pointer);
begin
  inherited Create(AInterface);
  FRio := ARio;
end;

destructor TBaseJSONRPCWrapper.TRioVirtualInterface.Destroy;
begin
  FRio := nil;
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

function TBaseJSONRPCWrapper.GetPassParamsByName: Boolean;
begin
  Result := FPassByPosOrName = tppByName;
end;

procedure TBaseJSONRPCWrapper.SetPassParamsByName(const AValue: Boolean);
begin
  if AValue then
    FPassByPosOrName := tppByName else
    FPassByPosOrName := tppByPos;
end;

function TBaseJSONRPCWrapper.GetPassParamsByPosition: Boolean;
begin
  Result := FPassByPosOrName = tppByPos;
end;

procedure TBaseJSONRPCWrapper.SetPassParamsByPosition(const AValue: Boolean);
begin
  if AValue then
    FPassByPosOrName := tppByPos else
    FPassByPosOrName := tppByName;
end;

function TBaseJSONRPCWrapper.GetPassEnumByName: Boolean;
begin
  Result := FPassEnumByName;
end;

procedure TBaseJSONRPCWrapper.SetPassEnumByName(const AValue: Boolean);
begin
  FPassEnumByName := AValue;
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
  LogFormat := tlfNative;
  InitClient;
  FOnSafeCallException := function (AExceptObject: TObject;
    ExceptAddr: Pointer): HResult
  var
    LExc: EJSONRPCException absolute AExceptObject;
    LExcMethod: EJSONRPCMethodException absolute AExceptObject;
  begin
    Result := S_OK;
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
    begin
      FOnBeforeExecute(AMethodName, AJSONRequest);
      if AJSONRequest.Size > AJSONRequest.Position then
        AJSONRequest.Size := AJSONRequest.Position;
    end;
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
    Result := LHttpMethod.HttpMethod else
    Result := '';
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
    Result := LUrlSuffix.UrlSuffix else
    Result := '';
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

{ TJSONWrapper }

procedure TJSONWrapper.InitClient;
begin
  FAppendMethodName := False;
end;

{ TIntfMethEntryHelper }

function TIntfMethEntryHelper.GetSelfInfo: PTypeInfo;
begin
  Result := SelfInfo;
end;

{$WRITEABLECONST ON}
function TIntfMethEntryHelper.IJSONRPCMethods_Length(const ARttiContext: TRttiContext): Integer;
const
  FLength: Integer = -1;
var
  LType: TRttiType;
  LDeclaredMethods: TArray<TRttiMethod>;
begin
  if FLength <> -1 then
    Exit(FLength);
  LType := ARttiContext.GetType(TypeInfo(IJSONRPCMethods));
  LDeclaredMethods := LType.GetDeclaredMethods;
  Result := Length(LDeclaredMethods);
  FLength := Result;
end;
{$WRITEABLECONST OFF}

function TIntfMethEntryHelper.JSONMethodName(const ARttiContext: TRttiContext): string;
var
  LType: TRttiType;
  DeclaredMethods: TArray<TRttiMethod>;
  LMethod: TRttiMethod;
  LJSONMethodNameAttr: MethodNameAttribute;
begin
  LType := ARttiContext.GetType(Self.MethodInfo); // TRttiInterfaceType
  DeclaredMethods := LType.GetDeclaredMethods;
  LMethod := DeclaredMethods[Self.Pos-3-IJSONRPCMethods_Length(ARttiContext)]; // 3 is number of methods in IInterface
  LJSONMethodNameAttr := LMethod.GetAttribute<MethodNameAttribute>;
  if Assigned(LJSONMethodNameAttr) then
    Result := LJSONMethodNameAttr.Name;
end;

function TIntfMethEntryHelper.JSONParamsByPos(const ARttiContext: TRttiContext): Boolean;
var
  LType: TRttiType;
  DeclaredMethods: TArray<TRttiMethod>;
  LMethod: TRttiMethod;
  LParamByPos: ParamsByPosAttribute;
begin
  LType := ARttiContext.GetType(Self.MethodInfo); // TRttiInterfaceType
  DeclaredMethods := LType.GetDeclaredMethods;
  LMethod := DeclaredMethods[Self.Pos-3-IJSONRPCMethods_Length(ARttiContext)]; // 3 is number of methods in IInterface
  LParamByPos := LMethod.GetAttribute<ParamsByPosAttribute>;
  Result := Assigned(LParamByPos);
end;

function TJSONRPCWrapper.GetMethod(const AMethMD: TIntfMethEntry): TRttiMethod;
begin
  var LType := FRttiContext.GetType(AMethMD.MethodInfo); // TRttiInterfaceType
  Result := LType.GetDeclaredMethods[AMethMD.Pos-3];
end;

function TJSONRPCWrapper.GetMethodName(const AMethMD: TIntfMethEntry): string;
var
  LJSONMethodName: string;
begin
  if High(FMethodNames) < AMethMD.Pos then
    SetLength(FMethodNames, AMethMD.Pos+1);
  if FMethodNames[AMethMD.Pos] <> '' then
    Exit(FMethodNames[AMethMD.Pos]);
  LJSONMethodName := AMethMD.JSONMethodName(FRttiContext);
  if LJSONMethodName = '' then
    FMethodNames[AMethMD.Pos] := AMethMD.Name else
    FMethodNames[AMethMD.Pos] := LJSONMethodName;
  Result := FMethodNames[AMethMD.Pos];
end;

procedure DumpType(const AIntfType: TRttiType); overload;
begin
  OutputDebugString(Format('ClassName: %s, Name: %s',
    [AIntfType.ClassName, AIntfType.Name]));
end;

procedure DumpType(const AParam: TIntfParamEntry; const AIntfType: TRttiType); overload;
var
  LFlags, LName: string;
  LSB: TStringBuilder;
begin
  LSB := TStringBuilder.Create;
  try
    for var I := Low(TParamFlag) to High(TParamFlag) do
      if I in AParam.Flags then
        begin
          LName := GetEnumName(TypeInfo(TParamFlag), Ord(I));
          if LSB.Length <> 0 then
            LSB.Append(',');
          LSB.Append(LName);
        end;
    LFlags := LSB.ToString;
    OutputDebugString(Format('Flags: [%s], ClassName: %s, Name: %s',
      [LFlags, AIntfType.ClassName, AIntfType.Name]));
  finally
    LSB.Free;
  end;
end;

procedure TJSONRPCWrapper.DoDispatch(const AContext: TInvContext;
  AMethNum: Integer; const AMethMD: TIntfMethEntry);
var
  LRequestStream, LResponseStream: TStream;
  LJSONMethodObj: TJSONObject;
  LResultP: Pointer;
  LJSONResponseObj: TJSONValue;
  LHttpMethod, LServerURL: string;
  LParams: TJSONValue;
  LParamsObj: TJSONObject absolute LParams;
  LParamsArray: TJSONArray absolute LParams;
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
    AddJSONVersion(LJSONMethodObj);

    var LIntfType := FRttiContext.GetType(AMethMD.MethodInfo);
    DumpType(LIntfType);

    if FAppendMethodName then
      begin
        var LJSONMethodName := GetMethodName(AMethMD);
        LJSONMethodObj.AddPair(SMETHOD, LJSONMethodName);
      end;

    {$REGION 'Parameter parsing, handling'}
    if AMethMD.ParamCount > 0 then
      begin
        LParams := nil;
        var LSavedParamByPos: IInterface;
        if AMethMD.JSONParamsByPos(FRttiContext) then
          LSavedParamByPos := TSaveRestore<TPassParamByPosOrName>.Create(FPassByPosOrName, tppByPos);
        if FPassByPosOrName = tppByPos then
          LParamsArray := TJSONArray.Create else
          LParamsObj := TJSONObject.Create;
        try
          {$REGION 'Loop through parameters'}
          for var I := 1 to AMethMD.ParamCount do
            begin
              var LParamIndex := I-1;
              var LParamValuePtr := AContext.GetParamPointer(LParamIndex);
              var LParamName := AMethMD.Params[LParamIndex].Name;

              // parse outgoing / handle outgoing data from client to server
              {$REGION 'Parse outgoing data from client to server'}
              var LParamTypeInfo := AMethMD.Params[LParamIndex].Info;
              // SendIntegers(const A: TArray<Integer>) Kind is tkDynArray
              var LRttiType := FRttiContext.GetType(LParamTypeInfo);
              DumpType(AMethMD.Params[LParamIndex], LRttiType);
              // send_integers(const data: array of Integer); Kind is tkInteger instead of tkDynArray

              var LTypeKind := LParamTypeInfo.Kind;

{$IF DEFINED(HANDLE_MISSING_RTTI)}
            The code below is written to handle array of T, where T is any native type
            Unfortunately, there's an issue marshalling it
              if ([pfArray, pfReference] * AMethMD.Params[LParamIndex].Flags <> []) and
                 (LTypeKind <> tkDynArray) then
                LTypeKind := tkArray else
              if ([pfConst, pfArray] * AMethMD.Params[LParamIndex].Flags <> []) and
                 (LTypeKind <> tkDynArray) then
                LTypeKind := tkDynArray;
{$ENDIF}

              case LTypeKind of
                tkArray: begin
                  var LJSONObj := ArrayPtrToJSONArray(LParamValuePtr, LParamTypeInfo);
                  case FPassByPosOrName of
                    tppByName: LParamsObj.AddPair(LParamName, LJSONObj);
                    tppByPos:  LParamsArray.Add(LJSONObj);
                  end;
                end;
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
                            // 6 ordinal types (for boolean) as defined.
                            Assert(False, 'Unhandled new ordinal type!');
                          end;
                          case FPassByPosOrName of
                            tppByName: LParamsObj.AddPair(LParamName, TJSONBool.Create(LValue));
                            tppByPos:  LParamsArray.Add(LValue);
                          end;
                        end else
                        begin // Looks like it's really an enum type!
                          case FPassEnumByName of
                            True: begin
                              var LValue := GetEnumName(LParamTypeInfo, PByte(LParamValuePtr)^);
                              case FPassByPosOrName of
                                tppByName: LParamsObj.AddPair(LParamName, LValue);
                                tppByPos:  LParamsArray.Add(LValue);
                              end;
                            end;
                          else
                            var LValue: Integer := PWord(LParamValuePtr)^;
                            case FPassByPosOrName of
                              tppByName: LParamsObj.AddPair(LParamName, LValue);
                              tppByPos:  LParamsArray.Add(LValue);
                            end;
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
                Assert(False, Format('Unexpected type not handled: %s', [LParamTypeInfo.Name]));
              end;
              else
                Assert(False, 'Unexpected type not handled');
              end;
              {$ENDREGION}
            end;
          LJSONMethodObj.AddPair(SPARAMS, LParams);
          {$ENDREGION 'Loop through parameters'}
        except
          FreeAndNil(LParams);
          raise;
        end;
      end;
    {$ENDREGION 'Parameter parsing, handling'}

    // Only add ID if it's not a Notification call
    var LMethodType := LIntfType;
//    var LJSONNotify := LMethodType.GetAttribute<JSONNotifyAttribute>;
//    var LIsNotification := LJSONNotify <> nil;
    var LIsNotification := LMethodType.HasAttribute<JSONRPCNotifyAttribute>;
    var LMethodID := -1;
    if not LIsNotification then
      begin
        LMethodID := TInterlocked.Increment(FJSONMethodID);
        LJSONMethodObj.AddPair(SID, LMethodID);
      end;

    // client request converted to JSON string
    var LRequestJSON := LJSONMethodObj.ToJSON;
    {$ENDREGION 'Convert native Delphi call to a JSON string'}

    // then send it
    LRequestStream := FClient.RequestStream;
    try
      var LBytes := TEncoding.UTF8.GetBytes(LRequestJSON);
      LRequestStream.Write(LBytes, Length(LBytes));
      LRequestStream.Position := 0;
      DoBeforeExecute(AMethMD.Name, LRequestStream);
      case LogFormat of
        tlfNative: begin
          DoLogOutgoingRequest(LJSONMethodObj.ToString);
        end;
      else
        DoLogOutgoingRequest(LRequestJSON);
      end;
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
              var LExcClassName: string := '';
              if LError.TryGetValue<string>(SCLASSNAME, LExcClassName) then
                begin
                  // Find the exception class
                  var LExcClass := FindExceptionClass(LExcClassName);
                  if Assigned(LExcClass) then
                    raise LExcClass.Create(LCode, LMsg);
                end else
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
                            Assert(False, 'Untested code path: 1355');
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
                            // {$LINE 1234} // what does this do?
                            Assert(False, 'Untested code path: 1367');
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
                          PBoolean(LResultP)^ := SameText(LResultValue, STrue);
                        end;
                        otSWord, otUWord: begin
                          PWordBool(LResultP)^ := SameText(LResultValue, STrue);
                        end;
                        otSLong, otULong: begin
                          PLongBool(LResultP)^ := SameText(LResultValue, STrue);
                        end;
                      end;
                    end else
                    begin // really an enum type
                      var LEnumValue: Integer;

                      case FPassEnumByName of
                        True: begin
                          LEnumValue := GetEnumValue(AMethMD.ResultInfo, LResultValue);
                        end;
                      else
                        LEnumValue := StrToInt(LResultValue);
                      end;
                      // TValue
                      PWord(LResultP)^ := LEnumValue;
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
  I, J, VirtualIndex: Integer;
  LMethNum: Integer;
  LContext: TInvContext;
  LTypeInfo: PTypeInfo;
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
      begin
        J := I-1;
        LContext.SetParamPointer(J, AArgs[I].GetReferenceToRawData);
        LTypeInfo := LMethMD.Params[J].Info;
        if FOwnsObjects and Assigned(LTypeInfo) and (LTypeInfo.Kind = tkClass) then
          begin
            LContext.AddObjectToDestroy(TObject(AArgs[I].GetReferenceToRawData^));
            LContext.AddObjectToDestroy(TObject(AArgs[I].GetReferenceToRawData^));
          end;
      end;

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

{$IF RTLVersion >= TRTLVersion.Delphi120 }
function TJSONRPCWrapper.GetConnectionTimeout: Integer;
begin
  Result := FClient.ConnectionTimeout;
end;

procedure TJSONRPCWrapper.SetConnectionTimeout(const Value: Integer);
begin
  FClient.ConnectionTimeout := Value;
end;
{$ENDIF}

function TJSONRPCWrapper.GetOnSafeCallException: TOnSafeCallException;
begin
  Result := FOnSafeCallException;
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
  FAppendMethodName := True;
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

  if not Result.ContainsName(SHeadersAccept) then
    Result := Result + [TNameValuePair.Create(SHeadersAccept, SApplicationJson)];
  if not Result.ContainsName(CHeadersContentLength) then
    Result := Result + [TNameValuePair.Create(CHeadersContentLength, IntToStr(ARequestStream.Size))];
  if not Result.ContainsName(SHeadersContentType) then
    Result := Result + [TNameValuePair.Create(SHeadersContentType, SApplicationJsonRPC)];

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
    FRegistry.Add(ATypeInfo.TypeData.GUID, ATypeInfo)
  {$IF DEFINED(DEBUG)} else
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

procedure TJSONRPCWrapper.SetInvokeMethod;
begin
  TRIOVirtualInterface(Pointer(FInterface)).OnInvoke := GenericClientMethod;
end;

procedure TJSONRPCWrapper.SetOnSafeCallException(
  const AProc: TOnSafeCallException);
begin
  FOnSafeCallException := AProc;
end;

{$IF NOT DEFINED(BASECLASS)}
function TJSONRPCWrapper.GetPassParamsByName: Boolean;
begin
  Result := FPassByPosOrName = tppByName;
end;

procedure TJSONRPCWrapper.SetPassParamsByName(const AValue: Boolean);
begin
  if AValue then
    FPassByPosOrName := tppByName else
    FPassByPosOrName := tppByPos;
end;

function TJSONRPCWrapper.GetPassParamsByPosition: Boolean;
begin
  Result := FPassByPosOrName = tppByPos;
end;

procedure TJSONRPCWrapper.SetPassParamsByPosition(const AValue: Boolean);
begin
  if AValue then
    FPassByPosOrName := tppByPos else
    FPassByPosOrName := tppByName;
end;

function TJSONRPCWrapper.GetPassEnumByName: Boolean;
begin
  Result := FEnumByName;
end;

procedure TJSONRPCWrapper.SetPassEnumByName(const AValue: Boolean);
begin
  FEnumByName := AValue;
end;
{$ENDIF}

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
   if AIntfMD.MDA[I].MethodInfo = AMethod.Handle then
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

constructor TJSONRPCServerWrapper.Create(AOwner: TComponent);
begin
  inherited;
  FJSONRPCInstances := [];
end;

destructor TJSONRPCServerWrapper.Destroy;
begin
  FOnLogIncomingJSONRequest := nil;
  FOnBeforeDispatchJSONRPC := nil;
  FOnDispatchedJSONRPC := nil;
  FOnLogOutgoingJSONResponse := nil;
  FJSONRPCInstances := nil;
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
  LItem: TJSONValue;
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
                // Handles {"jsonrpc":"2.0","method":"sum","params":[[1,2,3,4]],"id":1}
                LItem := TJSONArray(LJSONValue).Items[0];
                if (LItem is TJSONArray) then
                  LItem := TJSONArray(LItem).Items[0];
                Result :=
                  MatchElementType(
                    TRttiDynamicArrayType(LMethodParam.ParamType).ElementType,
                    LItem
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

procedure DumpParams(const AParams: TArray<TRttiParameter>);
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

procedure DumpMethods(const AMethods: TArray<TRttiMethod>);
{$IF NOT DEFINED(DEBUG)} inline; {$ENDIF}
begin
{$IF DEFINED(DEBUG)}
  for var LMethod in AMethods do
    DumpMethod(LMethod);
{$ENDIF}
end;

{$IF DEFINED(DEBUG)} // Figure out which methods are having issues...
procedure DebugMethods(const AMethods: TArray<TRttiMethod>; const AJSONObject: TJSONObject);
begin
  for var LMethod in AMethods do
    begin
      OutputDebugString(Format('%p', [LMethod.CodeAddress]));
    end;
end;
{$ENDIF}

procedure InvalidRequest; forward;

/// <summary> Method and parameter resolution, delete methods which do not match
/// the parameter type in the JSON object </summary>
procedure RemoveMethodsNotMatchingParameterCount(
  var VMethods: TArray<TRttiMethod>;
  const AParamCount: Integer;
  const AJSONObject: TJSONObject);
var
  LParamsValue: TJSONValue;
  LParamsObj: TJSONObject absolute LParamsValue;
  LParamsArray: TJSONArray absolute LParamsValue;
  LIsObj: Boolean;
begin
  LParamsValue := AJSONObject.GetValue(SPARAMS);
  LIsObj := LParamsValue is TJSONObject;
  for var I := High(VMethods) downto Low(VMethods) do
    begin
      var LParams := VMethods[I].GetParameters;

      // see https://www.jsonrpc.org/specification#parameter_structures
      case LIsObj of
        False: begin  // params is an array
          if not Assigned(LParamsArray) then
            InvalidRequest;
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
  if not Assigned(AType) then
    InvalidRequest;

  LMethods := AType.GetMethods(AMethodName);
// If there's only 1 method for a given name, return immediately
  if Length(LMethods) = 1 then
    Exit(LMethods[0]);
  if Length(LMethods) = 0 then
    Exit(nil);
// If there are multiple methods with the given name, remove methods that
// do not match the JSON parameters
  RemoveMethodsNotMatchingParameterCount(LMethods, AParamCount, AJSONObject);
  if Length(LMethods) >= 1 then
    Exit(LMethods[0]);
  Result := nil;
end;

procedure MethodNotFoundError(const AMethodName: string);
begin
  raise EJSONRPCMethodException.Create(JSONRPC.Common.Consts.SMethodNotFound,
    AMethodName) at ReturnAddress;
end;

procedure InvalidRequest;
begin
  raise EJSONRPCInvalidRequestException.Create(CInvalidRequest, SInvalidRequest) at ReturnAddress;
end;

procedure ClassNotFoundError;
begin
  raise EJSONRPCClassException.Create at ReturnAddress;
end;

procedure TJSONRPCServerWrapper.SetPersistent(const Value: Boolean);
begin
  if FPersistent <> Value then
    begin
      FPersistent := Value;
      case Value of
        False: begin
          if Assigned(FJSONRPCInstances) then
            FJSONRPCInstances := [];
        end;
        True: begin
//          var LClass := InvRegistry.GetInvokableClass;
//          Supports(CreateInvokableClass(TInvokableClassClass(LClass)), IJSONRPCMethods, FJSONRPCInstance);
        end;
      end;
    end;
end;

function TJSONRPCServerWrapper.CreateInvokableClass(AClass: TInvokableClassClass): TObject;
begin
  if Assigned(AClass) then
   Result := AClass.Create else
   Result := nil;
end;

procedure TJSONRPCServerWrapper.DispatchJSONRPC(
  const ARequestObj: TJSONValue; var VResponseObj: TJSONObject;
  const E: Exception = nil);
type
  TJSONState = (tjNothing, tjParsing, tjGettingMethod, tjLookupMethod, tjLookupMDAIndex,
    tjLookupParams, tjParseDateTime, tjParseString, tjParseInteger,
    tjCallMethod, tjParseResponse);

const CErrorFmt = '%s - Method Name: ''%s'', Param Name: ''%s'', Param Value: ''%s'', position: ''%d'', Param Kind: ''%s''';

var
  LJSONState: TJSONState;

  LClassIndex, LParseParamPosition: Integer;
  LParseMethodName, LParseParamName, LParseParamValue: string;
  LParseParamTypeInfo: PTypeInfo;
begin

  LParseParamPosition := -1;
  LClassIndex := 0;
  LJSONState := tjParsing;

  var LMapIntf: InterfaceMapItem;
  var LClass: TClass;

  var LJSONResponseObj: TJSONObject := nil;
  var LJSONRequestObj: TJSONObject := nil;

    try
      if E <> nil then
        raise E;
      if (ARequestObj = nil) or
         ((ARequestObj is TJSONArray) and (TJSONArray(ARequestObj).Count = 0)) then
        InvalidRequest;

      {$REGION 'parse incoming JSON RPC request'} // TODO -ochuacw -ccat: REGION parse incoming JSON RPC request
      if not (ARequestObj is TJSONObject) then
        InvalidRequest;

      var LJSONRequestStr := ARequestObj.ToJSON;
      LJSONRequestObj := ARequestObj as TJSONObject;
      TThread.Current.NameThreadForDebugging(LJSONRequestStr);
      case LogFormat of
        tlfNative: begin
          try
            // Dump the decoded JSON request
            DoLogIncomingRequest(LJSONRequestObj.ToString);
          except
            // If the JSON request can't be decoded, dump the received JSON bytes
            DoLogIncomingRequest(LJSONRequestStr);
          end;
        end;
      else
        DoLogIncomingRequest(LJSONRequestStr);
      end;
      {$ENDREGION 'parse incoming JSON RPC request'} // TODO -ochuacw -ccat: ENDREGION parse incoming JSON RPC request

      var LJSONRequest := LJSONRequestObj.Format();
      try

        var LJSONRPCVersion := LJSONRequestObj.FindValue(SJSONRPC);
        var LRPCVersion: Double := 0.0;
        if (not Assigned(LJSONRPCVersion)) or
           ((not LJSONRPCVersion.TryGetValue<Double>(LRPCVersion)) and
            (not SameValue(LRPCVersion, 2.0))) then
          InvalidRequest;

        LJSONState := tjGettingMethod;
        var LMethodName: string;
        var LJSONValue := LJSONRequestObj.FindValue(SMETHOD);
        if (LJSONValue = nil) or (not LJSONValue.IsJsonString) then
          InvalidRequest;
        LMethodName := LJSONValue.Value;
        if not IsValidIdent(LMethodName, True) then
          InvalidRequest;

        var LResult: TValue;
        var LArgs: TArray<TValue> := [];

        var LRttiContext := TRttiContext.Create;
        LMapIntf := InvRegistry.GetInterface;
        var LType: TRttiType := LRttiContext.GetType(LMapIntf.Info);

//    // NOTE!!! Notifications are requests without an ID
//        var LJSONRPCRequestID: Int64 := -1;
//        var LJSONRPCRequestIDString := '';
//        // string, number, or NULL
//        var LIDIsNumber := LJSONRequestObj.TryGetValue<Int64>(SID, LJSONRPCRequestID);
//        var LIDIsString := False;
//        if not LIDIsNumber then
//          LIDIsString := LJSONRequestObj.TryGetValue<string>(SID, LJSONRPCRequestIDString);
//        var LIsNotification := not (LIDIsNumber or LIDIsString);

        LJSONState := tjLookupMethod;
        LParseMethodName := LMethodName;
        var LParamCount := 0;
        var LParamsObjOrArray := LJSONRequestObj.FindValue(SPARAMS);
        if LParamsObjOrArray is TJSONObject then
          LParamCount := TJSONObject(LParamsObjOrArray).Count else
        if LParamsObjOrArray is TJSONArray then
          LParamCount := TJSONArray(LParamsObjOrArray).Count;
        DumpJSONRequest(LJSONRequestObj);

        // Fetch the meta data for the interface
        LClass := InvRegistry.GetInvokableClass;
        FIntfMD := Default(TIntfMetaData);
        GetIntfMetaData(LMapIntf.Info, FIntfMD, True);

        {$REGION 'Find method'} // TODO -ochuacw -ccat: REGION Find method
        var LMethod: TRttiMethod;
        LMethod := FindMethod(LType, LMethodName, LParamCount, LJSONRequestObj);
        if not Assigned(LMethod) then
          begin
            var LMapIntfs := InvRegistry.GetInterfaces;
            for LMapIntf in LMapIntfs do
              begin
                LType := LRttiContext.GetType(LMapIntf.Info);
                LMethod := FindMethod(LType, LMethodName, LParamCount, LJSONRequestObj);
                if Assigned(LMethod) then
                  begin
                    FIntfMD := Default(TIntfMetaData);
                    GetIntfMetaData(LMapIntf.Info, FIntfMD, True);
                    LClassIndex := 0;
                    if LClass = nil then
                      Break;
                    if not Supports(LClass, LMapIntf.GUID) then
                      begin
                        LClass := nil;
                        var LClasses := InvRegistry.GetInvokableClasses;
                        for var LTempClass in LClasses do
                          begin
                            if Supports(LTempClass, LMapIntf.GUID) then
                              begin
                                LClass := LTempClass;
                                Break;
                              end;
                            Inc(LClassIndex);
                          end;
                      end;
                    if LClass <> nil then
                      Break;
                  end;
              end;
          end else
          begin
            // Update the persistence index
            if FPersistent then
              begin
                var LMapIntfs := InvRegistry.GetInterfaces;
                for LMapIntf in LMapIntfs do
                  begin
                    LType := LRttiContext.GetType(LMapIntf.Info);
                    if LType.Name = LMapIntf.Name then
                      Break;
                    Inc(LClassIndex);
                  end;
              end;
          end;
        {$ENDREGION 'Find method'} // TODO -ochuacw -ccat: ENDREGION Find method
        if not Assigned(LMethod) then
          MethodNotFoundError(LMethodName);
        if not Assigned(LClass) then
          ClassNotFoundError;

    // NOTE!!! Notifications are requests without an ID
        var LJSONRPCRequestID: Int64 := -1;
        var LJSONRPCRequestIDString := '';
        // string, number, or NULL
        var LIDIsNumber := LJSONRequestObj.TryGetValue<Int64>(SID, LJSONRPCRequestID);
        var LIDIsString := False;
        if not LIDIsNumber then
          LIDIsString := LJSONRequestObj.TryGetValue<string>(SID, LJSONRPCRequestIDString);
        var LIsNotification := not (LIDIsNumber or LIDIsString);

        if (not LIsNotification) or Assigned(LMethod.ReturnType) then
          LJSONResponseObj := TJSONObject.Create;

        AddJSONVersion(LJSONResponseObj);

        if FPersistent and (High(FJSONRPCInstances) < LClassIndex) then
          SetLength(FJSONRPCInstances, LClassIndex+1);

        var LParams := LMethod.GetParameters;
        // SetLength so that parameters can be parsed by position or name
        SetLength(LArgs, Length(LParams));
        LJSONState := tjLookupMDAIndex;
        var LMDAIndex := LookupMDAIndex(LMethodName, LParams, FIntfMD);

        Assert( (LMDAIndex >= Low(FIntfMD.MDA)) and
                (LMDAIndex <= High(FIntfMD.MDA)), 'Cannot locate MDA Index!');

        LJSONState := tjLookupParams;

        {$REGION 'Loop over params'}
        for var I := Low(LParams) to High(LParams) do
          begin
            var LArg: TValue;
            var LParamName := Format('params.%s', [LParams[I].Name]);

            LParseParamName := LParams[I].Name;
            LParseParamPosition := I+1;
            LParseParamValue := '';
            LParseParamTypeInfo := LParams[I].ParamType.Handle;

            // look up parameter's position using name
            var LParamPosition :=  LookupParamPosition(FIntfMD.MDA[LMDAIndex].Params, LParams[I].Name);
            if LParamPosition = -1 then
              LParamPosition := I;

            case LParseParamTypeInfo.Kind of
              tkArray, tkDynArray: begin
                // Deliberately empty
              end;
            else
              // This code fails when the param is an array
              // Set up value in case it has an error
              try
                if (LJSONRequestObj is TJSONObject) and
                    (not LJSONRequestObj.TryGetValue<string>(LParamName, LParseParamValue)) then
                  begin
                    var LParamsArr: TJSONArray;
                    if LJSONRequestObj.P[SPARAMS] is TJSONArray then
                      begin
                        LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                        LParseParamValue := LParamsArr[I].AsType<string>;
                      end else
                    if LJSONRequestObj.P[SPARAMS] is TJSONObject then
                      begin
                        // This code handles the case when there's a mismatch between the
                        // formal and actual parameter name, so the parameter value is then
                        // fetched using the parameter position instead of the parameter name
                        // The mismatch occurs when the client side decides to use a parameter name
                        // different from that of the formal parameter name, but matches the formal
                        // parameter signature
                        LParseParamValue := TJSONObject(LJSONRequestObj.P[SPARAMS]).Pairs[LParamPosition].JsonValue.ToString;
                      end;
                  end;
              except
                raise EJSONRPCParamParsingException.Create(LMethodName, LParseParamName);
              end;
            end;

            var LTypeKind  := LParams[I].ParamType.TypeKind;
            // LJSONState := TJSONState(Ord(High(TJSONState)) + Ord(LTypeKind));
            // params may be by name or by position, parse incoming client JSON requests

            if ([pfArray] * LParams[I].Flags <> []) and
               (LTypeKind <> tkDynArray) then
              LTypeKind := tkArray;

            case LTypeKind of
              tkArray, tkDynArray: begin
                var LParamJSONObject := LJSONRequestObj.FindValue(LParamName);
                if Assigned(LParamJSONObject) then
                  DeserializeJSON(LParamJSONObject, LParseParamTypeInfo, LArg) else
                begin
                  var LParam := LJSONRequestObj.P[SPARAMS];
                  if Assigned(LParam) then
                    begin
                      var LParamsArray := (LParam as TJSONArray);
                      var LParamElem := LParamsArray[I];

                      if not (LParamElem is TJSONArray) then
                        InvalidRequest;

                      if Assigned(LParamElem) then
                        begin
                          var LParamElemJSONArray := LParamElem as TJSONArray;
                          DeserializeJSON(LParamElemJSONArray, LParseParamTypeInfo, LArg);
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
                  begin
                    // Default handling of records
                    if Assigned(LParamJSONObject) then
                      DeserializeJSON(LParamJSONObject, LParseParamTypeInfo, LArg);
                  end;
              end;
              tkEnumeration: begin // False, True, etc...
                // Supported types are strings, numbers, boolean, null, objects and arrays
                if IsBoolType(LParseParamTypeInfo) then
                  begin
                    case LParseParamTypeInfo^.TypeData^.OrdType of
                      otSByte, otUByte: begin
                        LArg := TValue.From(Boolean(SameText(
                          LParseParamValue, STrue)));
                      end;
                      otSWord, otUWord: begin
                        LArg := TValue.From(WordBool(SameText(
                          LParseParamValue, STrue)));
                      end;
                      otSLong, otULong: begin
                        LArg := TValue.From(LongBool(SameText(
                          LParseParamValue, STrue)));
                      end;
                    end;
                  end else
                  begin // Really an enumeration
                    var LEnumValue: Integer;
                    case FPassEnumByName of
                      True: begin
                        LEnumValue := GetEnumValue(LParseParamTypeInfo,
                          LParseParamValue
                        );
                      end;
                    else
                      // Enum is passed as an ordinal / integer
                      LEnumValue := StrToInt(LParseParamValue);
                    end;
                    TValue.Make(@LEnumValue, LParseParamTypeInfo, LArg);
                  end;
              end;
              tkString, tkLString, tkUString, tkWString: begin
                LArg := TValue.From<string>(LParseParamValue);
              end;
              tkInteger: begin
                var LTypeName := LParams[I].ParamType.Name;
                var LTypeInfo := LParseParamTypeInfo;
                begin
                  case LTypeInfo.TypeData.OrdType of
                    otSByte: begin // ShortInt
                      Assert(SameText(LTypeName, 'ShortInt'), 'Type mismatch!');
                      LArg := TValue.From(StrToInt(LParseParamValue));
                    end;
                    otSWord: begin // SmallInt
                      Assert(SameText(LTypeName, 'SmallInt'), 'Type mismatch!');
                      LArg := TValue.From(StrToInt(LParseParamValue));
                    end;
                    otSLong: begin // Integer
                      Assert(SameText(LTypeName, 'Integer'), 'Type mismatch!');
                      LArg := TValue.From(StrToInt(LParseParamValue));
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

              end; // tkInteger
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
          end; // end for
          {$ENDREGION 'Loop over params'}

        // {"jsonrpc": "2.0", "result": 19, "id": 1} example of expected result
        // Respond with the same request ID, if the request wasn't not a notification
        var LInstance: TObject;
        if FPersistent then
          begin
            if (not Assigned(FJSONRPCInstances[LClassIndex])) or
              (not Supports(FJSONRPCInstances[LClassIndex], LMapIntf.GUID)) then
              begin
                Supports(CreateInvokableClass(TInvokableClassClass(LClass)),
                  IJSONRPCMethods, FJSONRPCInstances[LClassIndex]);
              end;
            LInstance := TInvokableClass(FJSONRPCInstances[LClassIndex]);
          end else
          begin
            LInstance := CreateInvokableClass(TInvokableClassClass(LClass));
              // TInvokableClassClass(LClass).Create;
          end;

        var LIntf: IJSONRPCMethods;

        var LJSONRPCMethodException: IJSONRPCMethodException;
        if Supports(LInstance, IJSONRPCMethodException, LJSONRPCMethodException) then
          begin
            LJSONRPCMethodException.MethodName := LMethodName;
          end;

        {$REGION 'Execute method'} // TODO -ochuacw -ccat: REGION Execute method
        if Supports(LInstance, LMapIntf.GUID, LIntf) then
          begin
            var LObj := TValue.From(LIntf);
            LJSONState := tjCallMethod;

            // Dispatch the call to the implementor
            // ****************************************************************************
            LResult := LMethod.Invoke(LObj, LArgs);
            // ****************************************************************************
            // LResult := LMethod.Invoke(LInstance, LArgs); // working

            LJSONState := tjParseResponse;

            {$REGION 'Parse results'}  // TODO -ochuacw -ccat: REGION Parse results
            if Assigned(LMethod.ReturnType) then
              begin
                // Add result into the response
                // process outgoing response from server to client
                case LMethod.ReturnType.TypeKind of
                  tkArray,
                  tkDynArray: begin

                    var LJSONArray := ValueToJSONArray(LResult, LMethod.ReturnType.Handle);
                    LJSONResponseObj.AddPair(SRESULT, LJSONArray);

                  end;
                  tkRecord: begin
                    var LTypeInfo := LMethod.ReturnType.Handle;
                    var LJSONObject: TJSONValue;
                    var LHandlers: TRecordHandlers;
                    // Look up custom handlers for records
                    if LookupRecordHandlers(LTypeInfo, LHandlers) then
                      begin
                        LHandlers.TValueToJSON(
                          LResult, LTypeInfo, LJSONResponseObj
                        );
                      end else
                      begin
                        // default handler for records
                        var LJSON := SerializeRecord(LResult, LTypeInfo);
                        LJSONObject := TJSONObject.ParseJSONValue(LJSON);
                        LJSONResponseObj.AddPair(SRESULT, LJSONObject);
                      end;
                  end;
                  tkEnumeration: begin
                    // Only possible values are True, False
                    var LTypeInfo := LMethod.ReturnType.Handle;
                    if IsBoolType(LTypeInfo) then
                      LJSONResponseObj.AddPair(SRESULT, TJSONBool.Create(LResult.AsBoolean)) else
                    begin // really an enum type
                      var LResultOrdinal := LResult.AsOrdinal;
                      case FPassEnumByName of
                        True: begin
                          var LResultName := GetEnumName(LTypeInfo, LResultOrdinal);
                          LJSONResponseObj.AddPair(SRESULT, LResultName);
                        end;
                      else
                        LJSONResponseObj.AddPair(SRESULT, LResultOrdinal);
                      end;
                    end;
                  end;
                  tkString, tkLString, tkUString, tkWString: begin
                    LJSONResponseObj.AddPair(SRESULT, LResult.AsString);
                  end;
                  tkFloat: begin
                    var LTypeInfo := LMethod.ReturnType.Handle;
                    var LFloatType := LTypeInfo^.TypeData.FloatType;

                    CheckTypeInfo(LTypeInfo);
                    CheckFloatType(LFloatType);
                    case LFloatType of
                      ftComp: begin
                        //
                      end;
                      ftCurr: begin
                        LJSONResponseObj.AddPair(SRESULT, LResult.AsCurrency);
                      end;
                      ftDouble, ftExtended, ftSingle:
                      begin
                        if (LTypeInfo = System.TypeInfo(TDate)) or
                           (LTypeInfo = System.TypeInfo(TTime)) or
                           (LTypeInfo = System.TypeInfo(TDateTime)) then
                          begin
                            var LDateTimeStr :=  System.DateUtils.DateToISO8601(LResult.AsExtended, False);
                            LJSONResponseObj.AddPair(SRESULT, LDateTimeStr);
                          end else
                        if LTypeInfo = System.TypeInfo(Single) then
                          begin
                            LJSONResponseObj.AddPair(SRESULT, LResult.AsExtended);
                          end else
                        if LTypeInfo = System.TypeInfo(Extended) then
                          begin
                            LJSONResponseObj.AddPair(SRESULT, LResult.AsExtended);
                          end else
                          begin
                            // Currency and Double
                            LJSONResponseObj.AddPair(SRESULT, LResult.AsExtended);
                          end;
                      end;
                    end;

                  end;
                  tkInteger, tkInt64: LJSONResponseObj.AddPair(SRESULT, LResult.AsOrdinal);
                else
                end;
              end else
              begin
                // Default result when none is expected
                // LJSONResultObj.AddPair(SRESULT, DefaultTrueBoolStr);
                if LJSONResponseObj <> nil then
                  LJSONResponseObj.AddPair('noresult', 'noresult');
              end;
              {$ENDREGION 'Parse results'} // TODO -ochuacw -ccat: ENDREGION Parse results
          end else
          begin
//            var LMsg := Format('Method "%s" not found!', [LMethodName]);
//            raise EJSONRPCMethodException.Create(CMethodNotFound, LMsg);
            MethodNotFoundError(LMethodName);
          end;
        {$ENDREGION 'Execute method'} // TODO -ochuacw -ccat: ENDREGION Execute method

        // add Notification ID here
        if not LIsNotification then
          begin
            AddJSONID(LJSONResponseObj,
              LIDIsString, LJSONRPCRequestIDString,
              LIDIsNumber, LJSONRPCRequestID
            );
          end;

        // Convert the JSON object to JSON
//        var LJSONResult := LJSONResponseObj.ToJSON;
//        var LJSONResultBytes: TBytes; var LCount: NativeInt;
//        DoBeforeDispatchJSONRPC(LJSONResult);
//        JsonToTBytesCount(LJSONResult, LJSONResultBytes, LCount);
//        AResponse.Write(LJSONResultBytes, LCount);

        VResponseObj := LJSONResponseObj;

        DoDispatchedJSONRPC(LJSONRequest);
        LRttiContext.Free;
      finally
        FreeAndNil(LJSONRequestObj);
      end;
    except
      on E: EJSONParseException do
        begin
          // When it's a non-existent call, LJSONResponseObj is not
          // assigned on Linux
          if not Assigned(LJSONResponseObj) then
            LJSONResponseObj := TJSONObject.Create;
          AddJSONVersion(LJSONResponseObj);
          if not Assigned(LJSONResponseObj.FindValue(SERROR)) then
            begin
              var LJSONErrorObj := TJSONObject.Create;
              // Add default code
              LJSONErrorObj.AddPair(SCODE, CParseErrorNotWellFormed);

              // Add default message
              LJSONErrorObj.AddPair(SMESSAGE, JSONRPC.Common.Consts.SParseError);

              // Add the class name
              LJSONErrorObj.AddPair(SCLASSNAME, E.ClassName);
              LJSONResponseObj.AddPair(SERROR, LJSONErrorObj);
            end;
          // Add default ID
          AddJSONIDNull(LJSONResponseObj);
          VResponseObj := LJSONResponseObj;
        end;
      on E: EJSONRPCException do
        begin
          // When it's a non-existent call, LJSONResponseObj is not
          // assigned on Linux
          if not Assigned(LJSONResponseObj) then
            LJSONResponseObj := TJSONObject.Create;

          // Create error object to be returned to JSON RPC client
          // Add default error
          AddJSONVersion(LJSONResponseObj);

          if not Assigned(LJSONResponseObj.FindValue(SERROR)) then
            begin
              var LJSONErrorObj := TJSONObject.Create;
              // Add default code
              LJSONErrorObj.AddPair(SCODE, E.Code);

              // Add default message
              LJSONErrorObj.AddPair(SMESSAGE, E.Message);

              if E is EJSONRPCMethodException then
                begin
                  LJSONErrorObj.AddPair(SMETHOD, EJSONRPCMethodException(E).MethodName);
                  AddJSONCode(LJSONErrorObj, EJSONRPCMethodException(E).Code);
                end;
              if E is EJSONRPCParamParsingException then
                LJSONErrorObj.AddPair(SPARAM, EJSONRPCParamParsingException(E).ParamName);

              // Add the class name
              LJSONErrorObj.AddPair(SCLASSNAME, E.ClassName);
              LJSONResponseObj.AddPair(SERROR, LJSONErrorObj);
            end;

          // Add default ID
          AddJSONIDNull(LJSONResponseObj);
          VResponseObj := LJSONResponseObj;
        end;
    else
      // rpc call with invalid Batch
      if LJSONState in
        [tjParsing, tjParseResponse, tjGettingMethod, tjLookupMethod] then
        begin
          // If still in parsing state, then it must be a parsing error
          if LJSONResponseObj = nil then
            LJSONResponseObj := TJSONObject.Create;
        end;

      // handle failure to parse
      if Assigned(LJSONResponseObj) then
        begin
          AddJSONVersion(LJSONResponseObj);
          var LJSONErrorObj := TJSONObject.Create;
          case LJSONState of
            tjGettingMethod, tjLookupMethod: begin
              LJSONErrorObj.AddPair(SCODE, CParseErrorNotWellFormed);
              LJSONErrorObj.AddPair(SMESSAGE, SMethodNotFound);
            end;
            tjParsing: begin
              LJSONErrorObj.AddPair(SCODE, CParseErrorNotWellFormed);
              LJSONErrorObj.AddPair(SMESSAGE, SParseError);
            end;
            tjParseResponse: begin
              // This occurs when the server response cannot be parsed.
              LJSONErrorObj.AddPair(SCODE, CServerError001);
              LJSONErrorObj.AddPair(SMESSAGE, SInternalServerError);
            end;
          else
            if LJSONState > High(TJSONState) then // parsing error
              begin
                var LTypeKind := Ord(LJSONState) - Ord(High(TJSONState));
                LJSONErrorObj.AddPair(SCODE, CParseErrorNotWellFormed);
                var LErrorMessage := Format(
'%s - Method Name: ''%s'', Param Name: ''%s'', Param Value: ''%s'', position: ''%d'', Param Kind: ''%s'' ',
                  [
                   SParseError, LParseMethodName, LParseParamName, LParseParamValue,
                   LParseParamPosition,
                   GetEnumName(TypeInfo(TTypeKind), Ord(LTypeKind))
                  ]
                );
                LJSONErrorObj.AddPair(SMESSAGE, LErrorMessage);
              end;
          end;
          LJSONResponseObj.AddPair(SERROR, LJSONErrorObj);
          AddJSONIDNull(LJSONResponseObj);
          VResponseObj := LJSONResponseObj;
        end;
    end; // on Exception... else
end;

procedure TJSONRPCServerWrapper.DispatchJSONRPC(const ARequest, AResponse: TStream);
var
  LJSONRequestVal,
  LJSONResponse: TJSONValue;
  LJSONResponseArray: TJSONArray absolute LJSONResponse;
  LJSONRequestArray: TJSONArray absolute LJSONRequestVal;
  LOffset: Integer;
  LException: Exception;
begin
  LJSONResponse := nil;
  ARequest.Position := 0;
  var LJSONRequestBytes: TArray<Byte> := [];
  var Len := ARequest.Size;
  SetLength(LJSONRequestBytes, Len);
  ARequest.Read(LJSONRequestBytes, Len);
  var LJSONRequestStr := TEncoding.UTF8.GetString(LJSONRequestBytes);
  LException := nil;
  LOffset := 0;
  try
    // Check if there's a parse error
    LJSONRequestVal := TJSONObject.ParseJSONValue(LJSONRequestBytes, LOffset,
      [TJSONValue.TJSONParseOption.IsUTF8, TJSONValue.TJSONParseOption.RaiseExc]);
  except
    on E: EJSONParseException do
      begin
        LJSONRequestVal := nil;
        LException := AcquireExceptionObject as Exception;
      end;
  end;
  try
    // batch RPC calls
    if (LJSONRequestVal is TJSONArray) then
      begin
        // Invalid Request
        if (LJSONRequestArray.Count = 0)  then
          begin
            var LJSONResponseObj: TJSONObject := nil;
            var LJSONRequestObj := LJSONRequestVal;
            DispatchJSONRPC(LJSONRequestObj, LJSONResponseObj);
            LJSONResponse := LJSONResponseObj;
          end else
          begin
            LJSONResponseArray := TJSONArray.Create;
            for var LJSONRequestItem in LJSONRequestArray do
              begin
                var LJSONResponseObj: TJSONObject := nil;
                var LJSONRequestObj := LJSONRequestItem.Clone as TJSONValue;
                DispatchJSONRPC(LJSONRequestObj, LJSONResponseObj);
                // If the call is a notification, response obj is not assigned
                if Assigned(LJSONResponseObj) then
                  LJSONResponseArray.AddElement(LJSONResponseObj);
              end;
            if LJSONResponseArray.Count = 0 then
              FreeAndNil(LJSONResponseArray);
          end;
      end else
    if LJSONRequestVal is TJSONObject then // single RPC call
      begin
        var LJSONResponseObj: TJSONObject := nil;
        var LJSONRequestObj := LJSONRequestVal.Clone as TJSONValue;
        DispatchJSONRPC(LJSONRequestObj, LJSONResponseObj);
        LJSONResponse := LJSONResponseObj;
      end else
      begin
        // Parse error
        var LJSONResponseObj: TJSONObject := nil;
        DispatchJSONRPC(nil, LJSONResponseObj, LException);
        LJSONResponse := LJSONResponseObj;
      end;

    var LJSONResult: string;

    if FFormatJSONResponse then
      begin
        if Assigned(LJSONResponse) then
          LJSONResult := LJSONResponse.Format;
      end else
      begin
        if Assigned(LJSONResponse) then
          LJSONResult := LJSONResponse.ToJSON;
      end;

    var LJSONResultBytes: TBytes := []; var LCount: NativeInt;
    JsonToTBytesCount(LJSONResult, LJSONResultBytes, LCount);
    DoBeforeDispatchJSONRPC(LJSONResult);
    AResponse.Write(LJSONResultBytes, LCount);
    DoLogOutgoingResponse(LJSONResult);

  finally
    LJSONRequestVal.Free;
    LJSONResponse.Free;
  end;
end;

procedure TJSONRPCServerWrapper.OldDispatchJSONRPC(const ARequest, AResponse: TStream);
type
  TJSONState = (tjParsing, tjGettingMethod, tjLookupMethod, tjLookupMDAIndex,
    tjLookupParams, tjParseDateTime, tjParseString, tjParseInteger,
    tjCallMethod, tjParseResponse);

const CErrorFmt = '%s - Method Name: ''%s'', Param Name: ''%s'', Param Value: ''%s'', position: ''%d'', Param Kind: ''%s''';

var
  LJSONState: TJSONState;

  LClassIndex, LParseParamPosition: Integer;
  LParseMethodName, LParseParamName, LParseParamValue: string;
  LParseParamTypeInfo: PTypeInfo;
begin


  LParseParamPosition := -1;
  LClassIndex := 0;
  ARequest.Position := 0;
  var LJSONRequestBytes: TArray<Byte>;
  var Len := ARequest.Size;
  SetLength(LJSONRequestBytes, Len);
  ARequest.Read(LJSONRequestBytes, Len);

  var LMapIntf := InvRegistry.GetInterface;
  var LClass := InvRegistry.GetInvokableClass;

// Fetch the meta data for the interface
  FIntfMD := Default(TIntfMetaData);
  GetIntfMetaData(LMapIntf.Info, FIntfMD, True);

  LJSONState := tjParsing;
  var LJSONResponseObj: TJSONObject := TJSONObject.Create;
  var LJSONRequestObj: TJSONObject := nil;
  try
    try

      {$REGION 'parse incoming JSON RPC request'} // TODO -ochuacw -ccat: REGION parse incoming JSON RPC request
      var LJSONRequestStr := TEncoding.UTF8.GetString(LJSONRequestBytes);
      LJSONRequestObj := TJSONObject.ParseJSONValue(LJSONRequestStr) as TJSONObject;
      TThread.Current.NameThreadForDebugging(LJSONRequestStr);
      case LogFormat of
        tlfNative: begin
          try
            // Dump the decoded JSON request
            DoLogIncomingRequest(LJSONRequestObj.ToString);
          except
            // If the JSON request can't be decoded, dump the received JSON bytes
            DoLogIncomingRequest(LJSONRequestStr);
          end;
        end;
      else
        DoLogIncomingRequest(LJSONRequestStr);
      end;
      {$ENDREGION 'parse incoming JSON RPC request'} // TODO -ochuacw -ccat: ENDREGION parse incoming JSON RPC request

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

        // LJSONResultObj := TJSONObject.Create;
        // try
        AddJSONVersion(LJSONResponseObj);
        LJSONState := tjLookupMethod;
        LParseMethodName := LMethodName;
        var LParamCount := 0;
        var LParamsObjOrArray := LJSONRequestObj.FindValue(SPARAMS);
        if LParamsObjOrArray is TJSONObject then
          LParamCount := TJSONObject(LParamsObjOrArray).Count else
        if LParamsObjOrArray is TJSONArray then
          LParamCount := TJSONArray(LParamsObjOrArray).Count;
        DumpJSONRequest(LJSONRequestObj);

        {$REGION 'Find method'} // TODO -ochuacw -ccat: REGION Find method
        var LMethod: TRttiMethod;
        LMethod := FindMethod(LType, LMethodName, LParamCount, LJSONRequestObj);
        if not Assigned(LMethod) then
          begin
            var LMapIntfs := InvRegistry.GetInterfaces;
            for LMapIntf in LMapIntfs do
              begin
                LType := LRttiContext.GetType(LMapIntf.Info);
                LMethod := FindMethod(LType, LMethodName, LParamCount, LJSONRequestObj);
                if Assigned(LMethod) then
                  begin
                    FIntfMD := Default(TIntfMetaData);
                    GetIntfMetaData(LMapIntf.Info, FIntfMD, True);
                    LClassIndex := 0;
                    if LClass = nil then
                      Break;
                    if not Supports(LClass, LMapIntf.GUID) then
                      begin
                        LClass := nil;
                        var LClasses := InvRegistry.GetInvokableClasses;
                        for var LTempClass in LClasses do
                          begin
                            if Supports(LTempClass, LMapIntf.GUID) then
                              begin
                                LClass := LTempClass;
                                Break;
                              end;
                            Inc(LClassIndex);
                          end;
                      end;
                    if LClass <> nil then
                      Break;
                  end;
              end;
          end else
          begin
            // Update the persistence index
            if FPersistent then
              begin
                var LMapIntfs := InvRegistry.GetInterfaces;
                for LMapIntf in LMapIntfs do
                  begin
                    LType := LRttiContext.GetType(LMapIntf.Info);
                    if LType.Name = LMapIntf.Name then
                      Break;
                    Inc(LClassIndex);
                  end;
              end;
          end;
        {$ENDREGION 'Find method'} // TODO -ochuacw -ccat: ENDREGION Find method
        if not Assigned(LMethod) then
          MethodNotFoundError(LMethodName);
        if not Assigned(LClass) then
          ClassNotFoundError;

        if FPersistent and (High(FJSONRPCInstances) < LClassIndex) then
          SetLength(FJSONRPCInstances, LClassIndex+1);

        var LParams := LMethod.GetParameters;
        // SetLength so that parameters can be parsed by position or name
        SetLength(LArgs, Length(LParams));
        LJSONState := tjLookupMDAIndex;
        var LMDAIndex := LookupMDAIndex(LMethodName, LParams, FIntfMD);

        Assert( (LMDAIndex >= Low(FIntfMD.MDA)) and
                (LMDAIndex <= High(FIntfMD.MDA)), 'Cannot locate MDA Index!');

        LJSONState := tjLookupParams;

        {$REGION 'Loop over params'}
        for var I := Low(LParams) to High(LParams) do
          begin
            var LArg: TValue;
            var LParamName := Format('params.%s', [LParams[I].Name]);

            LParseParamName := LParams[I].Name;
            LParseParamPosition := I+1;
            LParseParamValue := '';
            LParseParamTypeInfo := LParams[I].ParamType.Handle;

            // look up parameter's position using name
            var LParamPosition :=  LookupParamPosition(FIntfMD.MDA[LMDAIndex].Params, LParams[I].Name);
            if LParamPosition = -1 then
              LParamPosition := I;

            case LParseParamTypeInfo.Kind of
              tkArray, tkDynArray: begin
                // Deliberately empty
              end;
            else
              // This code fails when the param is an array
              // Set up value in case it has an error
              try
                if (LJSONRequestObj is TJSONObject) and
                    (not LJSONRequestObj.TryGetValue<string>(LParamName, LParseParamValue)) then
                  begin
                    var LParamsArr: TJSONArray;
                    if LJSONRequestObj.P[SPARAMS] is TJSONArray then
                      begin
                        LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                        LParseParamValue := LParamsArr[I].AsType<string>;
                      end else
                    if LJSONRequestObj.P[SPARAMS] is TJSONObject then
                      begin
                        // This code handles the case when there's a mismatch between the
                        // formal and actual parameter name, so the parameter value is then
                        // fetched using the parameter position instead of the parameter name
                        // The mismatch occurs when the client side decides to use a parameter name
                        // different from that of the formal parameter name, but matches the formal
                        // parameter signature
                        LParseParamValue := TJSONObject(LJSONRequestObj.P[SPARAMS]).Pairs[LParamPosition].JsonValue.ToString;
                      end;
                  end;
              except
                raise EJSONRPCParamParsingException.Create(LMethodName, LParseParamName);
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
                      otSByte, otUByte: begin
                        LArg := TValue.From(Boolean(SameText(
                          LParseParamValue, STrue)));
                      end;
                      otSWord, otUWord: begin
                        LArg := TValue.From(WordBool(SameText(
                          LParseParamValue, STrue)));
                      end;
                      otSLong, otULong: begin
                        LArg := TValue.From(LongBool(SameText(
                          LParseParamValue, STrue)));
                      end;
                    end;
                  end else
                  begin // Really an enumeration
                    var LEnumValue: Integer;
                    case FPassEnumByName of
                      True: begin
                        LEnumValue := GetEnumValue(LParseParamTypeInfo,
                          LParseParamValue
                        );
                      end;
                    else
                      // Enum is passed as an ordinal / integer
                      LEnumValue := StrToInt(LParseParamValue);
                    end;
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
                      LArg := TValue.From(StrToInt(LParseParamValue));
                    end;
                    otSLong: begin // Integer
                      Assert(SameText(LTypeName, 'Integer'), 'Type mismatch!');
                      LArg := TValue.From(StrToInt(LParseParamValue));
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

              end; // tkInteger
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
          end; // end for
          {$ENDREGION 'Loop over params'}

        // {"jsonrpc": "2.0", "result": 19, "id": 1} example of expected result
        // Respond with the same request ID, if the request wasn't not a notification
        var LInstance: TObject;
        if FPersistent then
          begin
            if (not Assigned(FJSONRPCInstances[LClassIndex])) or
              (not Supports(FJSONRPCInstances[LClassIndex], LMapIntf.GUID)) then
              begin
                Supports(CreateInvokableClass(TInvokableClassClass(LClass)),
                  IJSONRPCMethods, FJSONRPCInstances[LClassIndex]);
              end;
            LInstance := TInvokableClass(FJSONRPCInstances[LClassIndex]);
          end else
          begin
            LInstance := CreateInvokableClass(TInvokableClassClass(LClass));
              // TInvokableClassClass(LClass).Create;
          end;

        var LIntf: IJSONRPCMethods;

        var LJSONRPCMethodException: IJSONRPCMethodException;
        if Supports(LInstance, IJSONRPCMethodException, LJSONRPCMethodException) then
          begin
            LJSONRPCMethodException.MethodName := LMethodName;
          end;

        {$REGION 'Execute method'} // TODO -ochuacw -ccat: REGION Execute method
        if Supports(LInstance, LMapIntf.GUID, LIntf) then
          begin
            var LObj := TValue.From(LIntf);
            LJSONState := tjCallMethod;

            // Dispatch the call to the implementor
            // ****************************************************************************
            LResult := LMethod.Invoke(LObj, LArgs);
            // ****************************************************************************
            // LResult := LMethod.Invoke(LInstance, LArgs); // working

            LJSONState := tjParseResponse;

            {$REGION 'Parse results'}  // TODO -ochuacw -ccat: REGION Parse results
            if Assigned(LMethod.ReturnType) then
              begin

                if not Assigned(LJSONResponseObj) then
                  LJSONResponseObj := TJSONObject.Create;

                // Add result into the response
                // process outgoing response from server to client
                case LMethod.ReturnType.TypeKind of
                  tkArray,
                  tkDynArray: begin
                    var LJSONArray := ValueToJSONArray(LResult, LMethod.ReturnType.Handle);
                    LJSONResponseObj.AddPair(SRESULT, LJSONArray);
                  end;
                  tkRecord: begin
                    var LTypeInfo := LMethod.ReturnType.Handle;
                    var LJSONObject: TJSONValue;
                    var LHandlers: TRecordHandlers;
                    // Look up custom handlers for records
                    if LookupRecordHandlers(LTypeInfo, LHandlers) then
                      begin
                        LHandlers.TValueToJSON(
                          LResult, LTypeInfo, LJSONResponseObj
                        );
                      end else
                      begin
                        // default handler for records
                        var LJSON := SerializeRecord(LResult, LTypeInfo);
                        LJSONObject := TJSONObject.ParseJSONValue(LJSON);
                        LJSONResponseObj.AddPair(SRESULT, LJSONObject);
                      end;
                  end;
                  tkEnumeration: begin
                    // Only possible values are True, False
                    var LTypeInfo := LMethod.ReturnType.Handle;
                    if IsBoolType(LTypeInfo) then
                      LJSONResponseObj.AddPair(SRESULT, TJSONBool.Create(LResult.AsBoolean)) else
                    begin // really an enum type
                      var LResultOrdinal := LResult.AsOrdinal;
                      case FPassEnumByName of
                        True: begin
                          var LResultName := GetEnumName(LTypeInfo, LResultOrdinal);
                          LJSONResponseObj.AddPair(SRESULT, LResultName);
                        end;
                      else
                        LJSONResponseObj.AddPair(SRESULT, LResultOrdinal);
                      end;
                    end;
                  end;
                  tkString, tkLString, tkUString, tkWString: begin
                    LJSONResponseObj.AddPair(SRESULT, LResult.AsString);
                  end;
                  tkFloat: begin
                    var LTypeInfo := LMethod.ReturnType.Handle;
                    var LFloatType := LTypeInfo^.TypeData.FloatType;

                    CheckTypeInfo(LTypeInfo);
                    CheckFloatType(LFloatType);
                    case LFloatType of
                      ftComp: begin
                        //
                      end;
                      ftCurr: begin
                        LJSONResponseObj.AddPair(SRESULT, LResult.AsCurrency);
                      end;
                      ftDouble, ftExtended, ftSingle:
                      begin
                        if (LTypeInfo = System.TypeInfo(TDate)) or
                           (LTypeInfo = System.TypeInfo(TTime)) or
                           (LTypeInfo = System.TypeInfo(TDateTime)) then
                          begin
                            var LDateTimeStr :=  System.DateUtils.DateToISO8601(LResult.AsExtended, False);
                            LJSONResponseObj.AddPair(SRESULT, LDateTimeStr);
                          end else
                        if LTypeInfo = System.TypeInfo(Single) then
                          begin
                            LJSONResponseObj.AddPair(SRESULT, LResult.AsExtended);
                          end else
                        if LTypeInfo = System.TypeInfo(Extended) then
                          begin
                            LJSONResponseObj.AddPair(SRESULT, LResult.AsExtended);
                          end else
                          begin
                            // Currency and Double
                            LJSONResponseObj.AddPair(SRESULT, LResult.AsExtended);
                          end;
                      end;
                    end;

                  end;
                  tkInteger, tkInt64: LJSONResponseObj.AddPair(SRESULT, LResult.AsOrdinal);
                else
                end;
              end else
              begin
                // Default result when none is expected
                // LJSONResultObj.AddPair(SRESULT, DefaultTrueBoolStr);
                LJSONResponseObj.AddPair('noresult', 'noresult');
              end;
              {$ENDREGION 'Parse results'} // TODO -ochuacw -ccat: ENDREGION Parse results
          end else
          begin
            var LMsg := Format('Method "%s" not found!', [LMethodName]);
            raise EJSONRPCMethodException.Create(CMethodNotFound, LMsg);
          end;
        {$ENDREGION 'Execute method'} // TODO -ochuacw -ccat: ENDREGION Execute method

        // add Notification ID here
        if not LIsNotification then
          begin
            AddJSONID(LJSONResponseObj,
              LIDIsString, LJSONRPCRequestIDString,
              LIDIsNumber, LJSONRPCRequestID
            );
          end;

        // Convert the JSON object to JSON
        var LJSONResult := LJSONResponseObj.ToJSON;
        var LJSONResultBytes: TBytes; var LCount: NativeInt;
        DoBeforeDispatchJSONRPC(LJSONResult);
        JsonToTBytesCount(LJSONResult, LJSONResultBytes, LCount);
        AResponse.Write(LJSONResultBytes, LCount);

        DoDispatchedJSONRPC(LJSONRequest);
        DoLogOutgoingResponse(LJSONResponseObj.Format());
        LRttiContext.Free;
      finally
        FreeAndNil(LJSONRequestObj);
      end;
      FreeAndNil(LJSONResponseObj);
    except
    {$REGION 'Exception handler'}
      // Exception handler
      on E: EJSONRPCException do
        begin
          // Create error object to be returned to JSON RPC client
          // Add default error
          AddJSONVersion(LJSONResponseObj);

          if not Assigned(LJSONResponseObj.FindValue(SERROR)) then
            begin
              var LJSONErrorObj := TJSONObject.Create;

              // Add default code
              LJSONErrorObj.AddPair(SCODE, E.Code);
              // Add default message
              LJSONErrorObj.AddPair(SMESSAGE, E.Message);

              if E is EJSONRPCMethodException then
                begin
                  LJSONErrorObj.AddPair(SMETHOD, EJSONRPCMethodException(E).MethodName);
                  AddJSONCode(LJSONErrorObj, EJSONRPCMethodException(E).Code);
                end;
              if E is EJSONRPCParamParsingException then
                LJSONErrorObj.AddPair(SPARAM, EJSONRPCParamParsingException(E).ParamName);

              // Add the class name
              LJSONErrorObj.AddPair(SCLASSNAME, E.ClassName);
              LJSONResponseObj.AddPair(SERROR, LJSONErrorObj);
            end;

          // Add default ID
          AddJSONIDNull(LJSONResponseObj);
        end;
    else
      // handle failure to parse
      if Assigned(LJSONResponseObj) then
        begin
          AddJSONVersion(LJSONResponseObj);
          var LJSONErrorObj := TJSONObject.Create;
          case LJSONState of
            tjGettingMethod: begin
              LJSONErrorObj.AddPair(SCODE, CParseErrorNotWellFormed);
              LJSONErrorObj.AddPair(SMESSAGE, SMethodNotFound);
            end;
            tjParsing: begin
              LJSONErrorObj.AddPair(SCODE, CParseErrorNotWellFormed);
              LJSONErrorObj.AddPair(SMESSAGE, SParseError);
            end;
          else
            if LJSONState > High(TJSONState) then // parsing error
              begin
                var LTypeKind := Ord(LJSONState) - Ord(High(TJSONState));
                LJSONErrorObj.AddPair(SCODE, CParseErrorNotWellFormed);
                var LErrorMessage := Format(
'%s - Method Name: ''%s'', Param Name: ''%s'', Param Value: ''%s'', position: ''%d'', Param Kind: ''%s'' ',
                  [
                   SParseError, LParseMethodName, LParseParamName, LParseParamValue,
                   LParseParamPosition,
                   GetEnumName(TypeInfo(TTypeKind), Ord(LTypeKind))
                  ]
                );
                LJSONErrorObj.AddPair(SMESSAGE, LErrorMessage);
              end;
          end;
          LJSONResponseObj.AddPair(SERROR, LJSONErrorObj);
          AddJSONIDNull(LJSONResponseObj);
        end;
    {$ENDREGION 'Exception handler'}
    end; // on Exception... else
    if Assigned(LJSONResponseObj) then
      begin
        var LJSONResultBytes: TBytes; var LCount: NativeInt;
        var LJSONResult := LJSONResponseObj.Format;
        DoBeforeDispatchJSONRPC(LJSONResult);
        JsonToTBytesCount(LJSONResult, LJSONResultBytes, LCount);
        AResponse.Write(LJSONResultBytes, LCount);
        DoLogOutgoingResponse(LJSONResult);
      end;
  finally
    FreeAndNil(LJSONRequestObj);
    FreeAndNil(LJSONResponseObj);
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
  var LIntfs: TArray<TGUID> := [
    IInterface, IJSONRPCDispatch, IJSONRPCDispatchEvents,
    IJSONRPCGetSetDispatchEvents,
    IPassParamsByPosition, IPassParamsByName, IPassEnumByName
  ];
  for var LIntf in LIntfs do
    if (IID = LIntf) and GetInterface(IID, Obj) then
      Exit(S_OK);
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



































// chuacw, Jun 2023

