program MakeTypeInfoProj;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.TypInfo, System.Rtti;

type
{$M+}
  TA = array of Byte;

  IPTypeInfo = interface
  ['{87984C4C-B7D0-4655-B518-CBFB60D05E2C}']
    function GetTypeInfo: PTypeInfo;
  end;

  TTypeInfo<T> = class(TInterfacedObject, IPTypeInfo)
  protected
    FTypeInfo: TTypeInfo;
  public
    constructor Create(const ABaseType: T);
    function GetTypeInfo: PTypeInfo;
    destructor Destroy; override;
  end;

{$M+}
{$TYPEINFO ON}
{$METHODINFO ON}
  TTestClass = class
    function TestTypeInfo1(const A: array of Byte): PTypeInfo;
    function TestTypeInfo2(const A: TA): PTypeInfo;
  end;

procedure DumpType(const AMethod: TRttiMethod); overload;
begin
end;

procedure DumpType(const AParam1, AParam2: TRttiParameter); overload;
begin
  WriteLn(AParam2.ToString);
  WriteLn(AParam1.ToString);
end;

procedure DumpParameter(const AParameter: TRttiParameter);
begin
end;

function CompareTypeInfo(const ATypeInfo1, ATypeInfo2: PTypeInfo): Integer;
begin
  WriteLn('Name1: ', GetTypeName(ATypeInfo1));
  WriteLn('Name2: ', GetTypeName(ATypeInfo2));
end;

{ TTypeInfo<T> }

constructor TTypeInfo<T>.Create(const ABaseType: T);
begin
  inherited Create;
end;

destructor TTypeInfo<T>.Destroy;
begin

  inherited;
end;

function TTypeInfo<T>.GetTypeInfo: PTypeInfo;
begin
  Result := @FTypeInfo;
end;

procedure Main;
begin
  var LTypeInfo := TypeInfo(TTestClass);
  var LRttiContext := TRttiContext.Create;
  var LRttiType := LRttiContext.GetType(LTypeInfo);
  var LMethods := LRttiType.GetDeclaredMethods;
  var LMeth1 := LMethods[0];
  var LMeth2 := LMethods[1];
  var LParams1 := LMeth1.GetParameters;
  var LParams2 := LMeth2.GetParameters;
  var LParam1  := LParams1[0];
  var LParam2  := LParams2[0];
  DumpType(LParam1, LParam2);
  var LTypeInfo1 := PTypeInfo(LParam1.Handle);
  var LTypeInfo2 := PTypeInfo(LParam2.Handle);
  CompareTypeInfo(LTypeInfo1, LTypeInfo2);
end;

{ TTestClass }

function TTestClass.TestTypeInfo1(const A: array of Byte): PTypeInfo;
begin

end;

function TTestClass.TestTypeInfo2(const A: TA): PTypeInfo;
begin

end;

begin
  ReportMemoryLeaksOnShutdown := True;
  Main;
end.
