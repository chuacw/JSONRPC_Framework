unit TestProj1.JSONRPCRIOImpl;

interface

uses
  System.TypInfo, System.Classes, System.Rtti, System.Generics.Collections,
  System.JSON.Serializers, Soap.IntfInfo, Soap.InvokeRegistry, System.SysUtils,
  Soap.Rio, System.Net.HttpClient;

type
  TJSONRPCWrapper = class;

  IRIOAccess = interface
  ['{FEF7C9CC-A477-40B7-ACBE-487EDA3E5DFE}']
    function GetRIO: TJSONRPCWrapper;
    property RIO: TJSONRPCWrapper read GetRIO;
  end;

  IOPJSONRPCConvert = interface
    ['{BF190F6C-9753-426A-93EE-E2499B8F1F8E}']
    { Property Accessors }

    { client methods }
    function InvContextToMsg(const IntfMD: TIntfMetaData;
                             MethNum: Integer;
                             Con: TInvContext;
                             Headers: THeaderList): TStream;
    procedure ProcessResponse(const Resp: TStream;
                              const IntfMD: TIntfMetaData;
                              const MD: TIntfMethEntry;
                              Context: TInvContext;
                              Headers: THeaderList);  overload;

    { server methods }
    procedure MsgToInvContext(const Request: InvString;
                              const IntfMD: TIntfMetaData;
                              var MethNum: Integer;
                              Context: TInvContext); overload;
    procedure MsgToInvContext(const Request: TStream;
                              const IntfMD: TIntfMetaData;
                              var MethNum: Integer;
                              Context: TInvContext;
                              Headers: THeaderList);  overload;
    procedure MakeResponse(const IntfMD: TIntfMetaData;
                              const MethNum: Integer;
                              Context: TInvContext;
                              Response: TStream;
                              Headers: THeaderList);
    procedure MakeFault(const Ex: Exception; EStream: TStream);

  end;

  IJSONRPCMethods = IInvokable;

  [JsonSerialize(TJsonMemberSerialization.Public)]
  TJsonRpcMethod = class(TPersistent)
  private
    Fjsonrpc: Double;
    Fmethod: string;
    Fid: Integer;
    class var CFID: Integer;
  protected
    class constructor Create;
  public
    constructor Create;
    property jsonrpc: Double read Fjsonrpc write Fjsonrpc;
    property method: string read Fmethod write Fmethod;
    property id: Integer read Fid write Fid;
  end;

  TBeforeParseEvent = reference to procedure(const AContext: TInvContext; 
    AMethNum: Integer; const AMethMD: TIntfMethEntry; const AMethodID: Int64; 
    AJSONResponse: TStream);

  TOnSyncEvent = reference to procedure(ARequest, AResponse: TStream);

  TInvContext = Soap.InvokeRegistry.TInvContext;
  TIntfMethEntry = Soap.IntfInfo.TIntfMethEntry;

  TJSONRPCWrapper = class(TComponent, IInvokable, IRIOAccess)
  protected
    FServerURL: string;
    FClient: THTTPClient;
    FInterface: IInterface;
    FOnBeforeExecute: TBeforeExecuteEvent;
    FOnAfterExecute: TAfterExecuteEvent;
    FOnBeforeParse: TBeforeParseEvent;
    FOnSync: TOnSyncEvent;
    
    class var FRegistry: TDictionary<TGUID, PTypeInfo>;
    
    FIID: TGUID;
    FRefCount: Integer;
    FIntfMD: TIntfMetaData;

    procedure SetServerURL(const Value: string); virtual;
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

    class procedure RegisterWrapper(const ATypeInfo: PTypeInfo); static;
    class constructor Create;
    class destructor Destroy;

  protected

    procedure DoBeforeExecute(const AMethodName: string; AJSONRequest: TStream); virtual;
    procedure DoAfterExecute(const AMethodName: string; AJSONRequest: TStream); virtual;
    procedure DoBeforeParse(const AContext: TInvContext;  AMethNum: Integer; 
      const AMethMD: TIntfMethEntry; const AMethodID: Int64; AJSONResponse: TStream); virtual;

    procedure DoSync(AJSONRequest, AJSONResponse: TStream); virtual;
  
    procedure DoDispatch(const AContext: TInvContext; AMethNum: Integer; const AMethMD: TIntfMethEntry);
    function InternalQI(const IID: TGUID; out Obj): HResult; stdcall;
    procedure GenericMethod(AMethod: TRttiMethod; const AArgs: TArray<TValue>; out Result: TValue);
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    { IRIOAccess }
    function GetRIO: TJSONRPCWrapper;
  public
    destructor Destroy; override;
    class function NewInstance: TObject; override;
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
    property ServerURL: string read FServerURL write SetServerURL;

    property OnBeforeExecute: TBeforeExecuteEvent read FOnBeforeExecute write FOnBeforeExecute;
    property OnAfterExecute: TAfterExecuteEvent read FOnAfterExecute write FOnAfterExecute;

    property OnBeforeParse: TBeforeParseEvent read FOnBeforeParse write FOnBeforeParse;

    property OnSync: TOnSyncEvent read FOnSync write FOnSync;
  end;

procedure RegisterJSONRPCWrapper(const ATypeInfo: PTypeInfo);

procedure WriteJSONResult(const AContext: TInvContext; 
    AMethNum: Integer; const AMethMD: TIntfMethEntry; const AMethodID: Int64; 
    AResponseValue: TValue; AJSONResponse: TStream);

implementation

uses
  System.Types, System.SyncObjs, System.JSON;


procedure RegisterJSONRPCWrapper(const ATypeInfo: PTypeInfo);
begin
  TJSONRPCWrapper.RegisterWrapper(ATypeInfo);
end;

procedure WriteJSONResult(const AContext: TInvContext; 
  AMethNum: Integer; const AMethMD: TIntfMethEntry; const AMethodID: Int64;
  AResponseValue: TValue; AJSONResponse: TStream);
begin
  // Write this // {"jsonrpc": "2.0", "result": 19, "id": 1}
  var LJSONObject := TJSONObject.Create;
  try
    LJSONObject.AddPair('jsonrpc', FloatToJson(2.0));
    case AMethMD.ResultInfo.Kind of
      tkInteger: LJSONObject.AddPair('result', AResponseValue.AsOrdinal);
    end;
    LJSONObject.AddPair('id', AMethodID);
    var LJSON := LJSONObject.ToString;
    var LBytes := TEncoding.UTF8.GetBytes(LJSON);
    AJSONResponse.Write(LBytes[0], Length(LBytes));
  finally
    LJSONObject.Free;
  end;
end;

{ TJSONRPCWrapper }

destructor TJSONRPCWrapper.Destroy;
begin
  FClient.Free;
  TRIOVirtualInterface(Pointer(FInterface)).Free;
  Pointer(FInterface) := nil;
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
    LJSONMethodObj.AddPair('jsonrpc', FloatToJson(2.0));
    LJSONMethodObj.AddPair('method', AMethMD.Name);
    if AMethMD.ParamCount > 0 then
      begin
        var LParamsObj := TJSONObject.Create;
        for var I := 1 to AMethMD.ParamCount do
          begin
            var LParamValuePtr := AContext.GetParamPointer(I-1);
            var LParamName := AMethMD.Params[I-1].Name;
            case AMethMD.Params[I-1].Info.Kind of
              tkString, tkLString, tkUString:
                LParamsObj.AddPair(LParamName, PString(LParamValuePtr)^);
              tkInteger:
                LParamsObj.AddPair(LParamName, PInteger(LParamValuePtr)^);
            else
            end;
          end;
        LJSONMethodObj.AddPair('params', LParamsObj);
      end;
    var LMethodID := TInterlocked.Increment(CJSONMethodID);
    LJSONMethodObj.AddPair('id', LMethodID);
    var LRequest := LJSONMethodObj.ToString;

    // then send it
    LRequestStream := TMemoryStream.Create;
    try
      var LBytes := TEncoding.UTF8.GetBytes(LRequest);
      LRequestStream.Write(LBytes, Length(LBytes));
      DoBeforeExecute(AMethMD.Name, LRequestStream);
      LResponseStream := TMemoryStream.Create;
      try
        if FServerURL <> '' then
          begin
            FClient.Post(FServerURL, LRequestStream, LResponseStream);
          end;
        DoAfterExecute(AMethMD.Name, LResponseStream);
        DoSync(LRequestStream, LResponseStream);
        DoBeforeParse(AContext, AMethNum, AMethMD, LMethodID, LResponseStream);

        var LResultP := AContext.GetResultPointer;
        if LResultP <> nil then
          begin
            var LResponse := '';
            LResponseStream.Seek(0, soFromBeginning);
            SetLength(LBytes, LResponseStream.Size);
            LResponseStream.Read(LBytes, LResponseStream.Size);
            LResponse := TEncoding.UTF8.GetString(LBytes);
            var LJSONObj := TJSONObject.ParseJSONValue(LResponse);
            try
              var LResultPathName := 'result';
              case AMethMD.ResultInfo.Kind of
                tkInteger: begin
                  var LResult: Integer;
                  if LJSONObj.TryGetValue<Integer>(LResultPathName, LResult) then
                    PInteger(LResultP)^ := LResult;
                end;
              end;
            finally
              LJSONObj.Free;
            end;
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
  // response
  // {"jsonrpc": "2.0", "result": 19, "id": 1}

//  { Convert parameter to XML packet }
//  Req := FConverter.InvContextToMsg(IntfMD, MethNum, Context, FHeadersOutBound);
//  try
//{$IFDEF ATTACHMENT_SUPPORT}
//    { Get the Binding Type
//      NOTE: We're interested in the input/call }
//    BindingType := GetBindingType(MethMD, True);
//
//    { NOTE: Creation of AttachHandler could be delayed - doesn't
//            seem to matter much though }
//    AttachHandler := GetMimeAttachmentHandler(BindingType);
//    AttachHandler.OnGetAttachment := OnGetAttachment;
//    AttachHandler.OnSendAttachment := OnSendAttachment;
//{$ELSE}
//    BindingType := btSOAP;
//{$ENDIF}
//    try
//{$IFDEF ATTACHMENT_SUPPORT}
//      { Create MIME stream if we're MIME bound }
//      if (BindingType = btMIME) then
//      begin
//        { Create a MIME stream from the request and attachments }
//        AttachHandler.CreateMimeStream(Req, FConverter.Attachments);
//
//        { Set the MIME Boundary
//          Investigate: Since one of the weaknesses of MIME is the boundary,
//          it seems that we should be going the other way.
//          IOW, since the programmer can configure IWebNode's MIMEBoundary,
//          we should be using that to initialize the AttachHandler's MIME Boundary.
//          IOW, allow the programmer to customize the boundary... instead of
//          ignoring whatever value the programmer may have put there at design time
//          and hardcoding the MIMEBoundary.
//
//          Or maybe that property should not be exposed at the Designer Level  ????  }
//        FWebNode.MimeBoundary := AttachHandler.MIMEBoundary;
//
//        { Allow for transport-specific initialization that needs to take
//          place prior to execution - NOTE: It's important to call this
//          routine before calling FinalizeStream - this allows the attachment's
//          stream to be modified/configured }
//        { NOTE: Skip 3 for AddRef,Release & QI }
//        { NOTE: Hardcoding '3' makes an assumption: that the interface derived
//                directly from IInvokable (i.e. IUnknown). Under that condition
//                3 represent the three standard methods of IUknown. However,
//                someone could ask the RIO for an interface that derives from
//                something else that derives from IUnknown. In that case, the
//                '3' here would be wrong. The importer always generates interfaces
//                derived from IInvokable - so we're *relatively* safe. }
//        FWebNode.BeforeExecute(IntfMD, MethMD, MethNum-3, AttachHandler);
//
//        { This is a hack - but for now, LinkedRIO requires that FinalizeStream
//          be called from here - doing so, breaks HTTPRIO - so we resort to a
//          hack. Ideally, I'm thinking of exposing a thin AttachHeader interface
//          that the transport can use to set SOAP headers - allowing each transport
//          to perform any packet customization }
//        if AttachHeader <> '' then
//          AttachHandler.AddSoapHeader(AttachHeader);
//        AttachHandler.FinalizeStream;
//      end else
//{$ENDIF}
//        { NOTE: Skip 3 for AddRef,Release & QI - See comment above about '3' }
//        FWebNode.BeforeExecute(IntfMD, MethMD, MethNum-3, nil);
//
//      { Allow event to see packet we're sending }
//      { This allows the handler to see the whole packet - i.e. attachments too }
//{$IFDEF ATTACHMENT_SUPPORT}
//      if BindingType = btMIME then
//        DoBeforeExecute(MethMD.Name, AttachHandler.GetMIMEStream)
//      else
//{$ENDIF}
//        DoBeforeExecute(MethMD.Name, Req);
//
//{$IFDEF ATTACHMENT_SUPPORT}
//      RespBindingType := GetBindingType(MethMD, False);
//{$ELSE}
//      RespBindingType := btSOAP;
//{$ENDIF}
//      Resp := GetResponseStream(RespBindingType);
//      try
//{$IFDEF ATTACHMENT_SUPPORT}
//        if (BindingType = btMIME) then
//        begin
//          try
//            FWebNode.Execute(AttachHandler.GetMIMEStream, Resp);
//          finally
//            FConverter.Attachments.Clear;
//            FHeadersOutBound.Clear;
//          end;
//        end
//        else
//{$ENDIF}
//        try
//          FWebNode.Execute(Req, Resp);
//        finally
//          { Clear Outbound headers }
//          FHeadersOutBound.Clear;
//        end;
//
//        { Assume the response is the SOAP Envelope in XML format. NOTE: In case
//          of attachments, this could actually be a Multipart/Related response }
//        RespXML := Resp;
//
//        XMLStream := TMemoryStream.Create;
//        try
//          { This allows the handler to see the whole packet - i.e. attachments too }
//          DoAfterExecute(MethMD.Name, Resp);
//{$IFDEF ATTACHMENT_SUPPORT}
//          { If we're expecting MIME parts, process 'em }
//          if FWebNode.MimeBoundary <> '' then
//          begin
//            AttachHandler.ProcessMultiPartForm(Resp, XMLStream,
//              FWebNode.MimeBoundary,
//              nil,
//              FConverter.Attachments,
//              FConverter.TempDir);
//             { Now point RespXML to Envelope }
//            RespXML := XMLStream;
//          end;
//{$ENDIF}
//          FConverter.ProcessResponse(RespXML, IntfMD, MethMD,
//            Context, FHeadersInbound);
//        finally
//          XMLStream.Free;
//        end;
//      finally
//        Resp.Free;
//      end;
//    finally
//      FConverter.Attachments.Clear;
//    end;
//  finally
//    Req.Free;
//  end;
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

procedure TJSONRPCWrapper.GenericMethod(AMethod: TRttiMethod;
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
    DoDispatch(LContext, LMethNum, LMethMD);
  finally
    LContext.Free;
  end;
end;

function TJSONRPCWrapper.GetRIO: TJSONRPCWrapper;
begin
  Result := Self;
end;

function TJSONRPCWrapper.InternalQI(const IID: TGUID; out Obj): HResult;
begin
  Result := E_NOINTERFACE;

  { IInterface, IRIOAccess }
  if (IID = IInterface) or (IID = IRIOAccess) then
    if GetInterface(IID, Obj) then Result := 0;

  if (Result <> 0) and (FInterface <> nil) and (IID = FIID) then
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
          TRIOVirtualInterface(Pointer(FInterface)).OnInvoke := GenericMethod;
          GetIntfMetaData(LValue, FIntfMD, True);
          Result := S_OK;
        end else
        begin
          Pointer(Obj) := nil;
          Result := S_FALSE;
        end;
    end;

  if Result = S_OK then
    Result := InternalQI(IID, Obj);
end;

class procedure TJSONRPCWrapper.RegisterWrapper(const ATypeInfo: PTypeInfo);
begin
  FRegistry.Add(ATypeInfo.TypeData.GUID, ATypeInfo);
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

{ TJsonRpcMethod }

constructor TJsonRpcMethod.Create;
begin
  inherited Create;
  Fjsonrpc := 2.0;
  Fid := TInterlocked.Increment(CFID);

  CFID := Fid;
end;

class constructor TJsonRpcMethod.Create;
begin
  CFID := 0;
end;

end.
