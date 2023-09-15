unit JSONRPC.RIO;

{$DEFINE BASECLASS}
{$DEFINE SUPPORTS_JSONOBJECT_AS_RESULT}

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

  TInvContext = JSONRPC.InvokeRegistry.TInvContext;
  TIntfMethEntry = Soap.IntfInfo.TIntfMethEntry;

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
      function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HRESULT; override;
      function GetOnSafeCallException: TOnSafeCallException;
      procedure SetOnSafeCallException(const AProc: TOnSafeCallException);

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

  TJSONRPCWrapper = class(
    {$IF DEFINED(BASECLASS)}
    TBaseJSONRPCWrapper,
    {$ELSE}
    TComponent,
    {$ENDIF}
    IInvokable, IJSONRPCInvocationSettings, ISafeCallException, IJSONRPCWrapper)
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
    FOnSync: TOnSyncEvent;
    FPassByPosOrName: TPassParamByPosOrName;
    FOnSafeCallException: TOnSafeCallException;
    FIID: TGUID;
    FRefCount: Integer;

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
    function InternalQI(const IID: TGUID; out Obj): HResult; override; stdcall;

    procedure InitClient; {$IF DEFINED(BASECLASS)}override;{$ELSE}virtual;{$ENDIF}
    procedure SetInvokeMethod; {$IF DEFINED(BASECLASS)}override;{$ELSE}virtual;{$ENDIF}

    procedure GenericClientMethod(AMethod: TRttiMethod; const AArgs: TArray<TValue>; out Result: TValue);
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

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

    { IJSONRPCWrapper }
    function GetJSONRPCWrapper: TJSONRPCWrapper;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function NewInstance: TObject; override;
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
    property ServerURL: string read FServerURL write SetServerURL;

    property OnAfterExecute: TAfterExecuteEvent read FOnAfterExecute write FOnAfterExecute;
    property OnBeforeExecute: TBeforeExecuteEvent read FOnBeforeExecute write FOnBeforeExecute;

    property OnBeforeParse: TOnBeforeParseEvent read FOnBeforeParse write FOnBeforeParse;

    property OnSafeCallException: TOnSafeCallException read FOnSafeCallException write
      FOnSafeCallException;

    property OnSync: TOnSyncEvent read FOnSync write FOnSync;

    property PassParamsByPos: Boolean read GetParamsPassByPosition write SetParamsPassByPosition;
    property PassParamsByPosition: Boolean read GetParamsPassByPosition write SetParamsPassByPosition;
    property PassParamsByName: Boolean read GetParamsPassByName write SetParamsPassByName;

    property ConnectionTimeout: Integer read GetConnectionTimeout write SetConnectionTimeout;
    property SendTimeout: Integer read GetSendTimeout write SetSendTimeout;
    property ResponseTimeout: Integer read GetResponseTimeout write SetResponseTimeout;

    property JSONRPCWrapper: TJSONRPCWrapper read GetJSONRPCWrapper;
  end;

  TJSONRPCServerWrapper = class(
    {$IF DEFINED(BASECLASS)}
    TBaseJSONRPCWrapper,
    {$ELSE}
    TJSONRPCWrapper,
    {$ENDIF}
    IJSONRPCDispatch, IJSONRPCDispatchEvents, IJSONRPCGetSetDispatchEvents)
  protected
    FOnReceivedJSONRPC: TOnReceivedJSONRPC;
    FOnBeforeDispatchJSONRPC: TOnBeforeDispatchJSONRPC;
    FOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    FOnSentJSONRPC: TOnSentJSONRPC;

    procedure DoBeforeDispatchJSONRPC(var AJSONResponse: string);
    procedure DoReceivedJSONRPC(const AJSONRequest: string);
    procedure DoDispatchedJSONRPC(const AJSONRequest: string);
    procedure DoSentJSONRPC(const AJSONResponse: string);

    { IJSONRPCGetSetDispatchEvents }
    function GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
    function GetOnReceivedJSONRPC: TOnReceivedJSONRPC;
    function GetOnSentJSONRPC: TOnSentJSONRPC;

    procedure SetOnDispatchedJSONRPC(const AProc: TOnDispatchedJSONRPC);
    procedure SetOnReceivedJSONRPC(const AProc: TOnReceivedJSONRPC);
    procedure SetOnSentJSONRPC(const AProc: TOnSentJSONRPC);

//    procedure GenericServerMethod(AMethod: TRttiMethod; const AArgs: TArray<TValue>; out Result: TValue);
    procedure InitClient; override;
    procedure SetInvokeMethod; override;

    function InternalQI(const IID: TGUID; out Obj): HResult; override; stdcall;

    class constructor Create;
  public
    destructor Destroy; override;

    procedure DispatchJSONRPC(const ARequest, AResponse: TStream);

    /// <summary> Response to client
    /// </summary>
    property OnBeforeDispatchJSONRPC: TOnBeforeDispatchJSONRPC read
      FOnBeforeDispatchJSONRPC write FOnBeforeDispatchJSONRPC;
    property OnDispatchedJSONRPC: TOnDispatchedJSONRPC read FOnDispatchedJSONRPC
      write FOnDispatchedJSONRPC;
    property OnReceivedJSONRPC: TOnReceivedJSONRPC read FOnReceivedJSONRPC
      write FOnReceivedJSONRPC;
    property OnSentJSONRPC: TOnSentJSONRPC read FOnSentJSONRPC
      write FOnSentJSONRPC;
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

implementation

uses
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
    Result := E_UNEXPECTED;
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

destructor TJSONRPCWrapper.Destroy;
var
  LRio: TRIOVirtualInterface;
begin
  FreeException;
  FOnBeforeExecute := nil;
  FOnAfterExecute := nil;
  FOnBeforeParse := nil;
  FOnSync := nil;
  FOnSafeCallException := nil;
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

// Client side JSON RPC parameter conversion
procedure TJSONRPCWrapper.DoDispatch(const AContext: TInvContext;
  AMethNum: Integer; const AMethMD: TIntfMethEntry);
const
{$WRITEABLECONST ON}
  CJSONMethodID: Int64 = 0;
var
  LRequestStream, LResponseStream: TStream;
  LJSONMethodObj: TJSONObject;
begin

// create something like this
// {"jsonrpc": "2.0", "method": "CallSomeMethod", "id": 1}
// {"jsonrpc": "2.0", "method": "AddSomeXY", "params": {"x": 5, "y": 6}, "id": 1}

  LJSONMethodObj := TJSONObject.Create;
  try
    LJSONMethodObj.Owned := True;
    LJSONMethodObj.AddPair(SJSONRPC, FloatToJson(2.0));
    LJSONMethodObj.AddPair(SMETHOD, AMethMD.Name);
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

            // parse outgoing data from client to server

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
                    LHandlers.NativeToJSON(FPassByPosOrName, LParamName, LParamValuePtr,
                      LParamsObj, LParamsArray);
                  end else
//                if LParamTypeInfo = TypeInfo(BigDecimal) then
//                  begin
//                    var LJSON := TJSONString.Create(BigDecimal(LParamValuePtr^).ToString);
//                    case FPassByPosOrName of
//                      tppByName: LParamsObj.AddPair(LParamName, LJSON);
//                      tppByPos:  LParamsArray.AddElement(LJSON);
//                    end;
//                  end else
//                if LParamTypeInfo = TypeInfo(BigInteger) then
//                  begin
//                    BigInteger.Hex;
//                    var LJSON := TJSONString.Create('0x'+BigInteger(LParamValuePtr^).ToString(16));
//                    case FPassByPosOrName of
//                      tppByName: LParamsObj.AddPair(LParamName, LJSON);
//                      tppByPos:  LParamsArray.AddElement(LJSON);
//                    end;
//                  end else
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
                // Only possible types are boolean, marshalled as string or as True/False???
                if IsBoolType(LParamTypeInfo) then
                  begin
                    case FPassByPosOrName of
                      tppByName: LParamsObj.AddPair(LParamName, TJSONBool.Create(PBoolean(LParamValuePtr)^));
                      tppByPos:  LParamsArray.AddElement(TJSONBool.Create(PBoolean(LParamValuePtr)^));
                    end;
                  end else
                  begin // Looks like it's really an enum!
                    var LValue := GetEnumName(LParamTypeInfo, PByte(LParamValuePtr)^);
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
              tkInteger:
                case FPassByPosOrName of
                  tppByName: LParamsObj.AddPair(LParamName, PInteger(LParamValuePtr)^);
                  tppByPos:  LParamsArray.Add(PInteger(LParamValuePtr)^);
                end;
              tkFloat: begin
                case LParamTypeInfo^.TypeData.FloatType of
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
                            LHandlers.NativeToJSON(FPassByPosOrName, LParamName,
                              LParamValuePtr, LParamsObj, LParamsArray);
                          end;
                      end else
                      begin
                        var LParamValue := PDouble(LParamValuePtr)^;
                        case FPassByPosOrName of
                          tppByName:  LParamsObj.AddPair(LParamName, LParamValue);
                          tppByPos:   LParamsArray.Add(LParamValue);
                        end;
                      end;
                  end;
                end;
              end; // tkFloat
            else
            end;
          end;
        if FPassByPosOrName = tppByName then
          LJSONMethodObj.AddPair(SPARAMS, LParamsObj) else
          LJSONMethodObj.AddPair(SPARAMS, LParamsArray);
      end;

    // Only add ID if it's not a Notification call
    var LRttiContext := TRttiContext.Create;
    var LIntfType := LRttiContext.GetType(AMethMD.SelfInfo);
    var LMethodType := LIntfType.GetMethod(AMethMD.Name);
    var LJSONNotify := LMethodType.GetAttribute<JSONNotifyAttribute>;
    var LIsNotification := LJSONNotify <> nil;
    var LMethodID := -1;
    if not LIsNotification then
      begin
        LMethodID := TInterlocked.Increment(CJSONMethodID);
        LJSONMethodObj.AddPair(SID, LMethodID);
      end;

    var LRequest := LJSONMethodObj.ToJSON;

    // then send it
    LRequestStream := FClient.RequestStream;
    try
      var LBytes := TEncoding.UTF8.GetBytes(LRequest);
      LRequestStream.Write(LBytes, Length(LBytes));
      DoBeforeExecute(AMethMD.Name, LRequestStream);
      LResponseStream := FClient.ResponseStream;
      try
        // Execute
        if FServerURL <> '' then
          begin
            LRequestStream.Position := 0;
            var LHeaders: TNetHeaders := InitializeHeaders(LRequestStream);
            SendGetPost(FServerURL, LRequestStream, LResponseStream, LHeaders);
          end;

        DoAfterExecute(AMethMD.Name, LResponseStream);
        DoSync(LRequestStream, LResponseStream);
        DoBeforeParse(AContext, AMethNum, AMethMD, LMethodID, LResponseStream);

        // handle error received from JSON RPC server
        var LResponse := '';
        LResponseStream.Seek(0, soFromBeginning);
        SetLength(LBytes, LResponseStream.Size);
        LResponseStream.Read(LBytes, LResponseStream.Size);
        LResponse := TEncoding.UTF8.GetString(LBytes);

        var LResultP := AContext.GetResultPointer;
        var LJSONResponseObj := TJSONObject.ParseJSONValue(TArray<Byte>(LBytes), 0);
        var LError: TJSONValue;
        try
          LError := LJSONResponseObj.FindValue(SERROR);
          if Assigned(LError) then
            begin
              var LCode := LError.GetValue<Integer>(SCODE);
              var LMsg := LError.GetValue<string>(SMESSAGE);
              var LMethodName := LError.FindValue(SMETHOD);
              if Assigned(LMethodName) then
                raise EJSONRPCMethodException.Create(LCode, LMsg, LMethodName.Value) else
                raise EJSONRPCException.Create(LCode, LMsg);
            end else
          if LResultP <> nil then
            begin
                var LResultPathName := SRESULT;
                // parse incoming JSON result from server
                case AMethMD.ResultInfo.Kind of
                {$IF DEFINED(SUPPORTS_JSONOBJECT_AS_RESULT)}
                  tkClass: begin
                    // take a TJSONObject as a result
                    var LJSONObj := LJSONResponseObj.FindValue(LResultPathName);
                    var LClassName := LJSONObj.ClassName;
                    if Assigned(LJSONObj) and (AMethMD.ResultInfo = TypeInfo(TJSONObject)) then
                      TJSONObject(LResultP^) := TJSONObject(LJSONObj);
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
                          DeserializeJSON(LJSONObj, AMethMD.ResultInfo, LResultP^);
                      end;
                  end;
                  tkEnumeration: begin
                    var LResultValue: string := '';
                    LJSONResponseObj.TryGetValue<string>(LResultPathName, LResultValue);
                    if IsBoolType(AMethMD.ResultInfo) then
                      PBoolean(LResultP)^ := SameText(LResultValue, 'True') else
                    begin // really an enum type
                      PByte(LResultP)^ := GetEnumValue(AMethMD.ResultInfo, LResultValue); // Most enum values are 1 byte
                    end;
                  end;
                  tkFloat: begin
                    var LTypeInfo := AMethMD.ResultInfo;
                    case LTypeInfo^.TypeData.FloatType of
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
                    end;
                  end;
                  tkInteger:
                    LJSONResponseObj.TryGetValue<Integer>(LResultPathName, PInteger(LResultP)^);
                  tkInt64:
                    LJSONResponseObj.TryGetValue<Int64>(LResultPathName, PInt64(LResultP)^);
                  tkLString, tkString, tkUString, tkWString: begin
                    LJSONResponseObj.TryGetValue<string>(LResultPathName, PString(LResultP)^);
                  end;
                else
                  // not handled
                end;
            end;
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

procedure TJSONRPCWrapper.DoSync(AJSONRequest, AJSONResponse: TStream);
begin
  if Assigned(FOnSync) then
    FOnSync(AJSONRequest, AJSONResponse);
end;

procedure HandleRIOSafeCallError(ErrorCode: HResult; ErrorAddr: Pointer);
begin
end;

class constructor TJSONRPCWrapper.Create;
begin
  FRegistry := TDictionary<TGUID, PTypeInfo>.Create;
  SafeCallErrorProc := HandleRIOSafeCallError;
end;

class destructor TJSONRPCWrapper.Destroy;
begin
  FRegistry.Free;
end;

procedure TJSONRPCWrapper.GenericClientMethod(AMethod: TRttiMethod;
  const AArgs: TArray<TValue>; out Result: TValue);
var
  LMethMD: TIntfMethEntry;
  I: Integer;
  LMethNum: Integer;
  LContext: TInvContext;
begin
  LContext := TInvContext.Create;
  try
    LMethNum := 0;
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

function TJSONRPCWrapper.InitializeHeaders(const ARequestStream: TStream): TNetHeaders;
begin
  Result := [
    TNameValuePair.Create('accept', SApplicationJson),
    TNameValuePair.Create('Content-Length', IntToStr(ARequestStream.Size)),
    TNameValuePair.Create('Content-Type', SApplicationJsonRPC)
  ];
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
  if not FRegistry.TryGetValue(ATypeInfo.TypeData.GUID, LTypeInfo) then
    FRegistry.Add(ATypeInfo.TypeData.GUID, ATypeInfo);
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

function LookupMDAIndex(const AMethodName: string; const AIntfMD: TIntfMetaData): Integer;
begin
  for var I := 0 to High(AIntfMD.MDA) do
   if AIntfMD.MDA[I].Name = AMethodName then
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

class constructor TJSONRPCServerWrapper.Create;
begin
end;

destructor TJSONRPCServerWrapper.Destroy;
begin
  FOnReceivedJSONRPC := nil;
  FOnBeforeDispatchJSONRPC := nil;
  FOnDispatchedJSONRPC := nil;
  FOnSentJSONRPC := nil;
  inherited;
end;

function MatchElementType(ARttiType: TRttiType; const AJSONParam: TJSONValue): Boolean; overload; forward;

function MatchElementType(ATypeInfo: PTypeInfo; ATypeKind: TTypeKind; const AJSONParam: TJSONValue): Boolean; overload;
begin
  case ATypeKind of
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
    tkInteger, tkFloat:
      Result := AJSONParam is TJSONNumber;
    tkString, tkLString, tkUString, tkWString: begin
      // TJSONNumber inherits from TJSONString so we gotta make sure this is not a number
      Result := (AJSONParam is TJSONString) and not (AJSONParam is TJSONNumber);
    end;
  else
    Result := False;
  end;
end;

function MatchElementType(ARttiType: TRttiType; const AJSONParam: TJSONValue): Boolean; overload;
begin
  if ARttiType is TRttiArrayType then
    begin
      Result := MatchElementType(
        TRttiArrayType(ARttiType).ElementType,
        TJSONArray(AJSONParam)[0]
      );
    end else
  if ARttiType is TRttiDynamicArrayType then
    begin
      Result := MatchElementType(
        TRttiDynamicArrayType(ARttiType).ElementType,
        TJSONArray(AJSONParam)[0]
      );
    end else
    begin
      Result := MatchElementType(ARttiType.Handle, ARttiType.TypeKind, AJSONParam);
    end;
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
        case AIsObj of
          False: begin  // AJSONParams is an array
            raise Exception.Create('This code path is not tested!');
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
//              tkInteger, tkFloat: begin
//                Result := Result and (LJSONValue is TJSONNumber);
//              end;
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

procedure RemoveMethodsNotMatchingParameterCount(var VMethods: TArray<TRttiMethod>;
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
      if Length(LParams) = 0 then
        Continue;
      // see https://www.jsonrpc.org/specification#parameter_structures
      case LIsObj of
        False: begin  // params is an array
          if (Length(LParams) <> LParamsArray.Count) or (not MatchParameterType(LParams, LParamsArray, LIsObj)) then
            Delete(VMethods, I, 1);
        end;
        True: begin   // params is an object
          if (Length(LParams) <> LParamsObj.Count) or (not MatchParameterType(LParams, LParamsObj, LIsObj)) then
            Delete(VMethods, I, 1);
        end;
      end;
    end;
end;

// Finds a method with the given method name and number, as well as type of parameters
// Note that result type of the method is not considered, as result type
// cannot be resolved until the called method returns a result
// and JSON RPC supports returning different results that cannot be easily
// encapsulated without coming up with a new paradigm or a JsonConverter
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
  RemoveMethodsNotMatchingParameterCount(LMethods, AJSONObject);
  if Length(LMethods) = 1 then
    Exit(LMethods[0]);
  Result := nil;
end;

// Working, but doesn't handle batch calls
// parses incoming JSON requests from the client
procedure TJSONRPCServerWrapper.DispatchJSONRPC(const ARequest, AResponse: TStream);
type
  TJSONState = (tjParsing, tjGettingMethod, tjLookupMethod, tjLookupParams,
    tjParseDateTime, tjParseString, tjParseInteger, tjCallMethod);

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
      DoReceivedJSONRPC(LJSONRequestStr);

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
          LJSONResultObj.AddPair(SJSONRPC, FloatToJson(2.0));
          LJSONState := tjLookupMethod;
          LParseMethodName := LMethodName;
          var LParamCount := 0;
          var LParamsObjOrArray := LJSONRequestObj.FindValue(SPARAMS);
          if LParamsObjOrArray is TJSONObject then
            LParamCount := TJSONObject(LParamsObjOrArray).Count else
          if LParamsObjOrArray is TJSONArray then
            LParamCount := TJSONArray(LParamsObjOrArray).Count;
          var LMethod := FindMethod(LType, LMethodName, LParamCount, LJSONRequestObj);

          // LMethod might be nil here
          try
            var LParams := LMethod.GetParameters;
            // SetLength so that parameters can be parsed by position or name
            SetLength(LArgs, Length(LParams));
            LJSONState := tjLookupParams;
            var LMDAIndex := LookupMDAIndex(LMethodName, FIntfMD);

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

                // Set up value in case it has an error
                if  (LJSONRequestObj.ClassType <> TJSONObject) and
                    not LJSONRequestObj.TryGetValue<string>(LParamName, LParseParamValue) then
                  begin
                    var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                    try
                      LParseParamValue := LParamsArr[I].AsType<string>;
                    except
                    end;
                  end;

                var LTypeKind  := LParams[I].ParamType.TypeKind;
                LJSONState := TJSONState(Ord(High(TJSONState)) + Ord(LTypeKind));
                // params may be by name or by position, parse incoming client JSON requests
                case LTypeKind of
                  tkArray,
                  tkDynArray: begin
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
                    var LParamValue: string;
                    if not LJSONRequestObj.TryGetValue<string>(LParamName, LParamValue) then
                      begin
                        var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                        LParamValue := LParamsArr[I].AsType<string>;
                      end;
                      // Supported types are strings, numbers, boolean, null, objects and arrays
                    if IsBoolType(LParseParamTypeInfo) then
                      begin
                        LArg := TValue.From(SameText(LParamValue, 'True'));
                      end else
                      begin // Really an enumeration
                        var LEnumValue := GetEnumValue(LParseParamTypeInfo, LParamValue);
                        TValue.Make(@LEnumValue, LParseParamTypeInfo, LArg);
                      end;
                  end;
                  tkString, tkLString, tkUString, tkWString: begin
                    var LParamValue: string;
                    if not LJSONRequestObj.TryGetValue<string>(LParamName, LParamValue) then
                      begin
                        var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                        var LParamElem := LParamsArr[I];
                        LParamValue := LParamElem.AsType<string>;
                      end;
                    LArg := TValue.From<string>(LParamValue);
                  end;
                  tkInteger, tkInt64: begin
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
                    case LTypeInfo^.TypeData.FloatType of
                      ftDouble, ftExtended, ftSingle:
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
                            // if the client is 32-bit and the server is 64-bit
                            // so convert to BigDecimal
                            var LHandlers: TRecordHandlers;
                            if LookupRecordHandlers(LTypeInfo, LHandlers) then
                              begin
                                var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                                var LJSON := LParamsArr[I].Value;
                                LArg := LHandlers.JSONToTValue(LJSON);
                              end;
                          end else
                          begin
                            var LValue: string;
                            if not LJSONRequestObj.TryGetValue<string>(LParamName, LValue) then
                              begin
                                var LParamsArr := LJSONRequestObj.P[SPARAMS] as TJSONArray;
                                var LParamElem := LParamsArr[I];
                                LValue := LParamElem.AsType<string>;
                              end;
                            LArg := TValue.From(StrToFloat(LValue));
                          end;
                      end;
                    end;
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
                        case LTypeInfo^.TypeData.FloatType of
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
                            if LTypeInfo = System.TypeInfo(Double) then
                              begin
                                LJSONResultObj.AddPair(SRESULT, LResult.AsExtended);
                              end else
                            if LTypeInfo = System.TypeInfo(Extended) then
                              begin
                                LJSONResultObj.AddPair(SRESULT, LResult.AsExtended);
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
          // add ID here
          if not LIsNotification then
            begin
              if LIDIsNumber then LJSONResultObj.AddPair(SID, LJSONRPCRequestID) else
              if LIDIsString then LJSONResultObj.AddPair(SID, LJSONRPCRequestIDString);
            end;

          var LJSONResult := LJSONResultObj.ToJSON;
          var LJSONResultBytes: TBytes; var LCount: NativeInt;
          DoBeforeDispatchJSONRPC(LJSONResult);
          JsonToTBytesCount(LJSONResult, LJSONResultBytes, LCount);
          AResponse.Write(LJSONResultBytes, LCount);

          DoDispatchedJSONRPC(LJSONRequest);
          DoSentJSONRPC(LJSONResultObj.Format());
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
      LJSONResponseObj.AddPair(SJSONRPC, FloatToJson(2.0));
      if Assigned(LJSONRequestObj) then
        begin
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
        DoSentJSONRPC(LJSONResponseObj.Format());
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

procedure TJSONRPCServerWrapper.DoReceivedJSONRPC(const AJSONRequest: string);
begin
  if Assigned(FOnReceivedJSONRPC) then
    FOnReceivedJSONRPC(AJSONRequest);
end;

procedure TJSONRPCServerWrapper.DoSentJSONRPC(const AJSONResponse: string);
begin
  if Assigned(FOnSentJSONRPC) then
    FOnSentJSONRPC(AJSONResponse);
end;

function TJSONRPCServerWrapper.GetOnDispatchedJSONRPC: TOnDispatchedJSONRPC;
begin
  Result := FOnDispatchedJSONRPC;
end;

function TJSONRPCServerWrapper.GetOnReceivedJSONRPC: TOnReceivedJSONRPC;
begin
  Result := FOnReceivedJSONRPC;
end;

function TJSONRPCServerWrapper.GetOnSentJSONRPC: TOnSentJSONRPC;
begin
  Result := FOnSentJSONRPC;
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

procedure TJSONRPCServerWrapper.SetOnReceivedJSONRPC(
  const AProc: TOnReceivedJSONRPC);
begin
  FOnReceivedJSONRPC := AProc;
end;

procedure TJSONRPCServerWrapper.SetOnSentJSONRPC(const AProc: TOnSentJSONRPC);
begin
  FOnSentJSONRPC := AProc;
end;

end.
