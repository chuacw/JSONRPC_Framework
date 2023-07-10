// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://localhost:8083/wsdl/IEmployee
//  >Import : http://localhost:8083/wsdl/IEmployee>0
// Version  : 1.0
// (9/7/2023 8:09:29 AM - - $Rev: 113440 $)
// ************************************************************************ //

unit IEmployee1;

interface

uses Soap.InvokeRegistry, Soap.SOAPHTTPClient, System.Types, Soap.XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:double          - "http://www.w3.org/2001/XMLSchema"[Gbl]

  TMyEmployee          = class;                 { "urn:EmployeeIntf"[GblCplx] }

  {$SCOPEDENUMS ON}
  { "urn:EmployeeIntf"[GblSmpl] }
  TEnumTest = (etNone, etAFew, etSome, etAlot);

  {$SCOPEDENUMS OFF}



  // ************************************************************************ //
  // XML       : TMyEmployee, global, <complexType>
  // Namespace : urn:EmployeeIntf
  // ************************************************************************ //
  TMyEmployee = class(TRemotable)
  private
    FLastName: string;
    FFirstName: string;
    FSalary: Double;
  published
    property LastName:  string  read FLastName write FLastName;
    property FirstName: string  read FFirstName write FFirstName;
    property Salary:    Double  read FSalary write FSalary;
  end;

  TDoubleArray = array of Double;               { "urn:EmployeeIntf"[GblCplx] }

  // ************************************************************************ //
  // Namespace : urn:EmployeeIntf-IEmployee
  // soapAction: urn:EmployeeIntf-IEmployee#%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : rpc
  // use       : encoded
  // binding   : IEmployeebinding
  // service   : IEmployeeservice
  // port      : IEmployeePort
  // URL       : http://localhost:8083/soap/IEmployee
  // ************************************************************************ //
  IEmployee = interface(IInvokable)
  ['{2F72B144-A51B-890A-DD55-ED9AD11AB9CA}']
    function  echoEnum(const Value: TEnumTest): TEnumTest; stdcall;
    function  echoDoubleArray(const Value: TDoubleArray): TDoubleArray; stdcall;
    function  echoMyEmployee(const Value: TMyEmployee): TMyEmployee; stdcall;
    function  echoDouble(const Value: Double): Double; stdcall;
  end;

function GetIEmployee(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IEmployee;
function GetJSONRPCEmployee: IEmployee;


implementation
  uses System.SysUtils;

function GetJSONRPCEmployee: IEmployee;
begin
end;

function GetIEmployee(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IEmployee;
const
  defWSDL = 'http://localhost:8083/wsdl/IEmployee';
  defURL  = 'http://localhost:8083/soap/IEmployee';
  defSvc  = 'IEmployeeservice';
  defPrt  = 'IEmployeePort';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IEmployee);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  { IEmployee }
  InvRegistry.RegisterInterface(TypeInfo(IEmployee), 'urn:EmployeeIntf-IEmployee', '');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IEmployee), 'urn:EmployeeIntf-IEmployee#%operationName%');
  RemClassRegistry.RegisterXSInfo(TypeInfo(TEnumTest), 'urn:EmployeeIntf', 'TEnumTest');
  RemClassRegistry.RegisterXSClass(TMyEmployee, 'urn:EmployeeIntf', 'TMyEmployee');
  RemClassRegistry.RegisterXSInfo(TypeInfo(TDoubleArray), 'urn:EmployeeIntf', 'TDoubleArray');

end.