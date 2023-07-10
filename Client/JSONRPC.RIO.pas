unit JSONRPC.RIO;
interface
implementation
end.

//interface
//
//uses
//  System.Classes, System.Rtti;
//
//type
//
//  TJSONRPCRIO = class;
//
//  { This interface provides access back to the RIO
//    from an interface that the RIO implements
//    NOTE: It is *NOT* implemented at  the RIO level;
//          therefore it cannot control the lifetime
//          of the RIO;
//          therefore you should not hang on to this interface
//          as its underlying RIO could go away!
//          Use the interface for quick RIO configuration
//          when you still have the interface implemented
//          by the RIO; then quickly "Let It Go!" }
//  IRIOAccess = interface
//  ['{FEF7C9CC-A477-40B7-ACBE-487EDA3E5DFE}']
//    function GetRIO: TJSONRPCRIO;
//    property RIO: TJSONRPCRIO read GetRIO;
//  end;
//
//  TBeforeExecuteEvent = procedure(const MethodName: string; SOAPRequest: TStream) of object;
//  TAfterExecuteEvent  = procedure(const MethodName: string; SOAPResponse: TStream) of object;
//
//  TJSONRPCRIO = class(TComponent, IInterface, IRIOAccess)
//  private type
//    TRioVirtualInterface = class(TVirtualInterface)
//    private
//      FRio: TJSONRPCRio;
//    protected
//      function _AddRef: Integer; override; stdcall;
//      function _Release: Integer; override; stdcall;
//    public
//      constructor Create(ARio: TJSONRPCRio; AInterface: Pointer);
//      function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
//    end;
//  private
//    FInterface: IInterface;
//
//{$IFNDEF AUTOREFCOUNT}
//    FRefCount: Integer;
//{$ENDIF !AUTOREFCOUNT}
//
//    { Headers }
//
//    FOnAfterExecute: TAfterExecuteEvent;
//    FOnBeforeExecute: TBeforeExecuteEvent;
//
//    procedure Generic(Method: TRttiMethod;
//      const Args: TArray<TValue>; out Result: TValue);
//
//{$IFNDEF AUTOREFCOUNT}
//    function _AddRef: Integer; stdcall;
//    function _Release: Integer; stdcall;
//{$ENDIF !AUTOREFCOUNT}
//
//    { IRIOAccess }
//    function GetRIO: TJSONRPCRIO;
//
//  protected
//    FIID: TGUID;
//    IntfMD: TIntfMetaData;
//    FConverter: IOPConvert;
//    FWebNode: IWebNode;
//
//    procedure DoDispatch(const Context: TInvContext; MethNum: Integer; const MethMD: TIntfMethEntry);
//    function InternalQI(const IID: TGUID; out Obj): HResult; stdcall;
//
//    { Routines that derived RIOs may override }
//    procedure DoAfterExecute(const MethodName: string; Response: TStream); virtual;
//    procedure DoBeforeExecute(const MethodName: string; Request: TStream); virtual;
//    function  GetResponseStream(BindingType: TWebServiceBindingType): TStream; virtual;
//  public
//    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;
//
//    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
//    { Behave like a TInterfacedObject, (only when Owner = nil) }
//{$IFNDEF AUTOREFCOUNT}
//    procedure AfterConstruction; override;
//    procedure BeforeDestruction; override;
//    class function NewInstance: TObject; override;
//
//    property RefCount: Integer read FRefCount;
//{$ENDIF !AUTOREFCOUNT}
//    property Converter: IOPConvert read FConverter write FConverter;
//  published
//    property OnAfterExecute: TAfterExecuteEvent read FOnAfterExecute write FOnAfterExecute;
//    property OnBeforeExecute: TBeforeExecuteEvent read FOnBeforeExecute write FOnBeforeExecute;
//  end;

implementation

//{ TJSONRPCRIO }
//
//procedure TJSONRPCRIO.AfterConstruction;
//begin
//  inherited;
//
//end;
//
//procedure TJSONRPCRIO.BeforeDestruction;
//begin
//  inherited;
//
//end;
//
//constructor TJSONRPCRIO.Create(AOwner: TComponent);
//begin
//  inherited;
//
//end;
//
//destructor TJSONRPCRIO.Destroy;
//begin
//
//  inherited;
//end;
//
//procedure TJSONRPCRIO.DoAfterExecute(const MethodName: string;
//  Response: TStream);
//begin
//
//end;
//
//procedure TJSONRPCRIO.DoBeforeExecute(const MethodName: string;
//  Request: TStream);
//begin
//
//end;
//
//procedure TJSONRPCRIO.DoDispatch(const Context: TInvContext; MethNum: Integer;
//  const MethMD: TIntfMethEntry);
//begin
//
//end;
//
//procedure TJSONRPCRIO.Generic(Method: TRttiMethod; const Args: TArray<TValue>;
//  out Result: TValue);
//begin
//
//end;
//
//function TJSONRPCRIO.GetResponseStream(
//  BindingType: TWebServiceBindingType): TStream;
//begin
//
//end;
//
//function TJSONRPCRIO.GetRIO: TJSONRPCRIO;
//begin
//
//end;
//
//function TJSONRPCRIO.InternalQI(const IID: TGUID; out Obj): HResult;
//begin
//
//end;
//
//class function TJSONRPCRIO.NewInstance: TObject;
//begin
//
//end;
//
//function TJSONRPCRIO.QueryInterface(const IID: TGUID; out Obj): HResult;
//begin
//
//end;
//
//function TJSONRPCRIO._AddRef: Integer;
//begin
//
//end;
//
//function TJSONRPCRIO._Release: Integer;
//begin
//
//end;
//
//end.

