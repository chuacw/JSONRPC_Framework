{---------------------------------------------------------------------------}
{                                                                           }
{ File:       JSONRPC.InvokeRegistry.pas                                    }
{ Function:   JSON RPC InvokeRegistry                                       }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
unit JSONRPC.InvokeRegistry;

{$ALIGN 16}
{$CODEALIGN 16}

interface

uses
  {$IFDEF POSIX}Posix.SysTypes,{$ENDIF}
  System.SysUtils, System.TypInfo, System.Classes, System.Generics.Collections,
  System.SyncObjs,
  Soap.IntfInfo,
  JSONRPC.Common.Types;

type

  InvString = UnicodeString;
  TDataContext = class;

//  { TRemotable is the base class for remoting complex types - it introduces a virtual
//    constructor (to allow the JSON RPC runtime to properly create the object and derived
//    types) and it provides life-time management - via DataContext - so the JSON RPC
//    runtime can properly disposed of complex types received by a Service }
//{$M+}
//  TRemotable = class
//  private
//    FDataContext: TDataContext;
//    procedure SetDataContext(Value: TDataContext);
//  public
//    constructor Create; virtual;
//    destructor  Destroy; override;
//
//    property   DataContext: TDataContext read FDataContext write SetDataContext;
//  end;
//{$M-}
//
//  PTRemotable = ^TRemotable;
//  TRemotableClass = class of TRemotable;

  TInvokableClass = class(TInterfacedObject, IInterface,
    IJSONRPCMethodException, IJSONRPCMethods
  )
  protected
    FMessage: string;
    FCode: Integer;
    FMethodName: string;

    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  public
    constructor Create; virtual;

    function SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult; override;

    { IJSONRPCMethods }

//    /// <summary>
//    /// Directly sends a JSON to the server.
//    /// <example>
//    /// This shows how to send a JSON.
//    /// In this case, this is a broken JSON.
//    /// <code>
//    /// LJSONRPCWrapper.SendJSON('{"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]');
//    /// </code>
//    /// </example>
//    /// </summary>
//    /// <exception cref="SomeException">when things go wrong.</exception>
//    /// <c> some code </c>
//    /// <param name="AJSON">The UTF8 message to be sent
//    /// </param>
//    procedure SendJSON(const AJSON: string; const AProc: TProc);
//    procedure FakeCall;

    { IJSONRPCException }
    function GetCode: Integer;
    procedure SetCode(ACode: Integer);
    property Code: Integer read GetCode write SetCode;

    function GetMessage: string;
    procedure SetMessage(const AMsg: string);
    property Message: string read GetMessage write SetMessage;

    { IJSONRPCException }
    function GetMethodName: string;
    procedure SetMethodName(const AMethodName: string);

    {$WARN HIDING_MEMBER OFF}
    /// <summary> Sets or gets the JSONMethodName that is currently being called.
    /// </summary>
    property MethodName: string read GetMethodName write SetMethodName;
    {$WARN HIDING_MEMBER ON}

  end;
  TInvokableClassClass = class of TInvokableClass;

  { Used when registering a class factory  - Specify a factory callback
    if you need to control the lifetime of the object - otherwise JSON RPC
    will create the implementation class using the virtual constructor }
  TCreateInstanceProc = procedure(out obj: TObject);

  InvRegClassEntry = record
    ClassType: TClass;
    Proc: TCreateInstanceProc;
  end align 16;

  InterfaceMapItem = record
    Name: string;                             { Native name of interface    }
    ExtName: InvString;                       { PortTypeName                }
    UnitName: string;                         { Filename of interface       }
    GUID: TGUID;                              { GUID of interface           }
    Info: PTypeInfo;                          { Typeinfo of interface       }
    DefImpl: TClass;                          { Metaclass of implementation }
{$IFDEF WIDE_RETURN_NAMES}
    ReturnParamNames: InvString;              { Return Parameter names      }
{$ELSE}
    ReturnParamNames: string;                 { Return Parameter names      }
{$ENDIF}
  end align 16;

  TInvokableClassRegistry = class
  protected
    FCriticalSection: TCriticalSection;
    FRegIntfs: TArray<InterfaceMapItem>;
    FRegClasses: TArray<InvRegClassEntry>;

    procedure DeleteFromReg(AClass: TClass; Info: PTypeInfo);
  public
    constructor Create;
    destructor Destroy; override;

    { Basic Invokable Interface Registration Routine }
    procedure RegisterInterface(Info: PTypeInfo);

    function GetInvokableClass: TClass;
    function GetInvokableClasses: TArray<TClass>;
    function GetInterface: InterfaceMapItem;
    function GetInterfaces: TArray<InterfaceMapItem>;

    procedure RegisterInvokableClass(AClass: TClass; const CreateProc: TCreateInstanceProc); overload;
    procedure RegisterInvokableClass(AClass: TClass); overload;

    procedure RegisterReturnParamNames(Info: PTypeInfo; const RetParamNames: InvString);

  private
    procedure Lock; virtual;
    procedure UnLock; virtual;
    function  GetIntfIndex(const IntfInfo: PTypeInfo): Integer;
  public

    procedure GetInterfaceInfoFromName(const UnitName,  IntfName: string; var Info: PTypeInfo; var IID: TGUID);
    function  GetInterfaceTypeInfo(const AGUID: TGUID): Pointer;
    function  GetInvokableObjectFromClass(AClass: TClass): TObject;
    function  GetRegInterfaceEntry(Index: Integer): InterfaceMapItem;
    function  HasRegInterfaceImpl(Index: Integer): Boolean;
    procedure GetClassFromIntfInfo(Info: PTypeInfo; var AClass: TClass);
    function  GetInterfaceCount: Integer;

    procedure UnRegisterInterface(Info: PTypeInfo);
    procedure UnRegisterInvokableClass(AClass: TClass);
  end;

  ETypeRegistryException = class(Exception);

  TRemotableTypeRegistry = class
  private
    FAutoRegister: Boolean;
    FCriticalSection: TCriticalSection;
  protected
    procedure Lock; virtual;
    procedure UnLock; virtual;
  public
    constructor Create;
    destructor Destroy; override;

    { Flag to automatically register types }
    property AutoRegisterNativeTypes: Boolean read FAutoRegister write FAutoRegister;
  end;

  TRemotableClassRegistry       = TRemotableTypeRegistry;

{ Forward ref. structure to satisfy DynamicArray<Type>        }
{ encountered before declaration of Type itself in .HPP file  }

  TDynToClear = record
    P: Pointer;
    Info: PTypeInfo;
  end align 16;

  TDataContext = class
  protected
    FObjsToDestroy: TArray<TObject>;
    FDataOffset: Integer;
    FData: TArray<Byte>;
    FDataP: TArray<Pointer>;
    FVarToClear: TArray<Pointer>;
    FDynArrayToClear: TArray<TDynToClear>;
{$IFNDEF NEXTGEN}
    FStrToClear: TArray<Pointer>;
    FWStrToClear: TArray<Pointer>;
{$ENDIF !NEXTGEN}
{$IFDEF UNICODE}
    FUStrToClear: TArray<Pointer>;
{$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;
    function  AllocData(Size: Integer): Pointer;
    procedure SetDataPointer(Index: Integer; P: Pointer);
    function  GetDataPointer(Index: Integer): Pointer;
    procedure AddObjectToDestroy(Obj: TObject);
    procedure RemoveObjectToDestroy(Obj: TObject);
    procedure AddDynArrayToClear(P: Pointer; Info: PTypeInfo);
    procedure AddVariantToClear(P: PVarData);
{$IFNDEF NEXTGEN}
    procedure AddStrToClear(P: Pointer);
    procedure AddWStrToClear(P: Pointer);
{$ENDIF !NEXTGEN}
{$IFDEF UNICODE}
    procedure AddUStrToClear(P: Pointer);
{$ENDIF}
  end;

  TInvContext = class(TDataContext)
  protected
    FResultP: Pointer;
  public
  const
    TEnumSize = SizeOf(Integer);
  type
    PEnum = ^TEnum;
    TEnum = Integer;
    procedure AllocServerData(const MD: TIntfMethEntry);
    procedure SetMethodInfo(const MD: TIntfMethEntry);

    function  GetParamPointer(Param: Integer): Pointer;
    procedure SetParamPointer(Param: Integer; P: Pointer);

    function  GetResultPointer: Pointer;
    procedure SetResultPointer(P: Pointer);

    property ParamPointer[Index: Integer]: Pointer read GetParamPointer write
      SetParamPointer;
    property ResultPointer: Pointer read GetResultPointer write SetResultPointer;
  end;

//function  GetRemotableDataContext: Pointer;
//procedure SetRemotableDataContext(Value: Pointer);

function  InvRegistry:   TInvokableClassRegistry;

implementation

uses
  {$IF DEFINED(MSWINDOWS)}Winapi.Windows,
  {$ELSEIF DEFINED(POSIX)}Posix.Unistd,{$ENDIF}
  System.RTTI, System.Types, System.Variants,
  Soap.SOAPConst,
  JSONRPC.RIO;

var
  JSONRPCInvRegistryV: TInvokableClassRegistry;

//threadvar
//  RemotableDataContext: Pointer;
//
//function GetRemotableDataContext: Pointer;
//begin
//  Result := RemotableDataContext;
//end;
//
//procedure SetRemotableDataContext(Value: Pointer);
//begin
//  RemotableDataContext := Value;
//end;

function TInvokableClassRegistry.GetInterfaceCount: Integer;
begin
  Result := 0;
  if FRegIntfs <> nil then
    Result := Length(FRegIntfs);
end;

function TInvokableClassRegistry.GetRegInterfaceEntry(Index: Integer): InterfaceMapItem;
begin
  if Index < Length(FRegIntfs) then
    Result := FRegIntfs[Index];
end;

function TInvokableClassRegistry.HasRegInterfaceImpl(Index: Integer): Boolean;
begin
  if Index < Length(FRegIntfs) then
    Result := FRegIntfs[Index].DefImpl <> nil
  else
    Result := False;
end;


constructor TInvokableClassRegistry.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TInvokableClassRegistry.Destroy;
begin
  FreeAndNil(FCriticalSection);
  inherited Destroy;
end;

procedure TInvokableClassRegistry.Lock;
begin
  FCriticalSection.Enter;
end;

procedure TInvokableClassRegistry.UnLock;
begin
  FCriticalSection.Leave;
end;

procedure TInvokableClassRegistry.RegisterInvokableClass(AClass: TClass);
var
  LContext: TRttiContext;
  LType: TRttiType;
  LInstanceType: TRttiInstanceType absolute LType;
  LIntf: TRttiInterfaceType;
  LIntfs: TArray<TRttiInterfaceType>;
begin
  LContext := TRttiContext.Create;
  LType := LContext.GetType(AClass);
  if LType <> nil then
    begin
      if LType is TRttiInstanceType then
        begin
          LIntfs := LInstanceType.GetImplementedInterfaces;
          for LIntf in LIntfs do
            if (LIntf.BaseType <> nil) and (LIntf.BaseType.GUID = IJSONRPCMethods) then
              RegisterInterface(LIntf.Handle);
        end;
    end;
  RegisterInvokableClass(AClass, nil);
end;

function TInvokableClassRegistry.GetInvokableClass: TClass;
begin
  if Length(FRegClasses) > 0 then
    Result := FRegClasses[0].ClassType else
    Result := nil;
end;

function TInvokableClassRegistry.GetInvokableClasses: TArray<TClass>;
begin
  if Length(FRegClasses) > 0 then
    begin
      SetLength(Result, Length(FRegClasses));
      for var I := Low(FRegClasses) to High(FRegClasses) do
        Result[I] := FRegClasses[I].ClassType;
    end else
    begin
      Result := nil;
    end;
end;

function TInvokableClassRegistry.GetInterface: InterfaceMapItem;
begin
  if Length(FRegIntfs) > 0 then
    Result := FRegIntfs[0] else
    begin
      Result := Default(InterfaceMapItem);
      Initialize(Result);
    end;
end;

function TInvokableClassRegistry.GetInterfaces: TArray<InterfaceMapItem>;
begin
  if Length(FRegIntfs) > 0 then
    Result := FRegIntfs else
    Result := nil;
end;

procedure TInvokableClassRegistry.RegisterInvokableClass(AClass: TClass;
  const CreateProc: TCreateInstanceProc);
var
  Index, I, J: Integer;
  Table: PInterfaceTable;
begin
  Lock;
  try
    Table := AClass.GetInterfaceTable;
    { If a class does not implement interfaces, try its parent }
    if Table = nil then
      begin
        if (AClass.ClassParent <> nil) then
          begin
            Table := AClass.ClassParent.GetInterfaceTable;
          end;
      end;
    if Table = nil then
      raise ETypeRegistryException.CreateFmt(SNoInterfacesInClass, [AClass.ClassName]);
    Index := Length(FRegClasses);
    SetLength(FRegClasses, Index + 1);
    FRegClasses[Index].ClassType := AClass;
    FRegClasses[Index].Proc := CreateProc;

    { Find out what Registered invokable interface this class implements }
    for I := 0 to Table.EntryCount - 1 do
    begin
      for J := 0 to Length(FRegIntfs) - 1 do
        if IsEqualGUID(FRegIntfs[J].GUID, Table.Entries[I].IID) then
          { NOTE: Don't replace an existing implementation           }
          {       This approach allows for better control over what  }
          {       class implements a particular interface            }
          if FRegIntfs[J].DefImpl = nil then
            FRegIntfs[J].DefImpl := AClass;
    end;
  finally
    UnLock;
  end;
end;

procedure TInvokableClassRegistry.DeleteFromReg(AClass: TClass; Info: PTypeInfo);
var
  I, Index, ArrayLen: Integer;
begin
  Lock;
  try
    Index := -1;
    if Assigned(Info) then
      ArrayLen := Length(FRegIntfs)
    else
      ArrayLen := Length(FRegClasses);
    for I := 0 to ArrayLen - 1 do
      begin
        if (Assigned(Info) and (FRegIntfs[I].Info = Info)) or
          (Assigned(AClass) and (FRegClasses[I].ClassType = AClass)) then
          begin
            Index := I;
            Break;
          end;
      end;
    if Index <> -1 then
      begin
        if Assigned(Info) then
          begin
            for I := Index to ArrayLen - 2 do
              FRegIntfs[I] := FRegIntfs[I+1];
            SetLength(FRegIntfs, Length(FRegIntfs) -1);
          end else
          begin
            for I := Index to ArrayLen - 2 do
              FRegClasses[I] := FRegClasses[I+1];
            SetLength(FRegClasses, Length(FRegClasses) -1);
          end;
      end;
  finally
    UnLock;
  end;
end;

procedure TInvokableClassRegistry.UnRegisterInvokableClass(AClass: TClass);
var
  I: Integer;
begin
  { Remove class from any interfaces it was registered as default class }
  for I := 0 to Length(FRegIntfs) - 1 do
    if FRegIntfs[I].DefImpl = AClass then
      FRegIntfs[I].DefImpl := nil;

  DeleteFromReg(AClass, nil);
end;

procedure TInvokableClassRegistry.RegisterInterface(Info: PTypeInfo);
var
  Index: Integer;
  IntfMD: TIntfMetaData;
  I, J: Integer;
  Table: PInterfaceTable;
begin
  Lock;
  try
    // Exit if interface already registered.
    for I := 0 to Length(FRegIntfs) - 1 do
      if FRegIntfs[I].Info = Info then
        Exit;

    GetIntfMetaData(Info, IntfMD, True);

    Index := Length(FRegIntfs);
    SetLength(FRegIntfs, Index + 1);
    FRegIntfs[Index].GUID := IntfMD.IID;
    FRegIntfs[Index].Info := Info;
    FRegIntfs[Index].Name := IntfMD.Name;
    FRegIntfs[Index].UnitName := IntfMD.UnitName;

    if FRegIntfs[Index].DefImpl = nil then
      begin
        { NOTE: First class that implements this interface wins! }
        for I := 0 to Length(FRegClasses) - 1 do
          begin
            { Allow for a class whose parent implements interfaces }
            Table :=  FRegClasses[I].ClassType.GetInterfaceTable;
            if (Table = nil) then
              begin
                Table := FRegClasses[I].ClassType.ClassParent.GetInterfaceTable;
              end;
            if Table = nil then // Guard against lack of interface
              Continue;
            for J := 0 to Table.EntryCount - 1 do
              begin
                if IsEqualGUID(IntfMD.IID, Table.Entries[J].IID) then
                  begin
                    FRegIntfs[Index].DefImpl := FRegClasses[I].ClassType;
                    Exit;
                  end;
              end;
          end;
      end;
  finally
    Unlock;
  end;
end;

procedure TInvokableClassRegistry.RegisterReturnParamNames(Info: PTypeInfo; const RetParamNames: InvString);
var
  I: Integer;
begin
  Lock;
  try
    I := GetIntfIndex(Info);
    if I >= 0 then
      begin
        FRegIntfs[I].ReturnParamNames := RetParamNames;
      end;
  finally
    Unlock;
  end;
end;

{ calls to this method need to be within a Lock/try <here> finally/unlock block }
function TInvokableClassRegistry.GetIntfIndex(const IntfInfo: PTypeInfo): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(FRegIntfs)-1 do
    begin
      if IntfInfo = FRegIntfs[I].Info then
        begin
          Exit(I);
        end;
    end;
end;

procedure TInvokableClassRegistry.UnRegisterInterface(Info: PTypeInfo);
begin
  DeleteFromReg(nil, Info);
end;

function TInvokableClassRegistry.GetInterfaceTypeInfo(const AGUID: TGUID): Pointer;
var
  I: Integer;
begin
  Result := nil;
  Lock;
  try
    for I := 0 to Length(FRegIntfs) - 1 do
    begin
      if IsEqualGUID(AGUID, FRegIntfs[I].GUID) then
      begin
        Result := FRegIntfs[I].Info;
        Exit;
      end;
    end;
  finally
    UnLock;
  end;
end;

procedure TInvokableClassRegistry.GetInterfaceInfoFromName(
  const UnitName, IntfName: string; var Info: PTypeInfo; var IID: TGUID);
var
  I: Integer;
begin
  Info := nil;
  Lock;
  try
    for I := 0 to Length(FRegIntfs) - 1 do
      begin
        if SameText(IntfName, FRegIntfs[I].Name) and
          ((UnitName = '') or (SameText(UnitName, FRegIntfs[I].UnitName))) then
          begin
            Info := FRegIntfs[I].Info;
            IID := FRegIntfs[I].GUID;
          end;
      end;
  finally
    UnLock;
  end;
end;

function TInvokableClassRegistry.GetInvokableObjectFromClass(
  AClass: TClass): TObject;
var
  I: Integer;
  Found: Boolean;
begin
  Result := nil;
  Lock;
  Found := False;
  try
    for I := 0 to Length(FRegClasses) - 1 do
      if FRegClasses[I].ClassType = AClass then
        if Assigned(FRegClasses[I].Proc) then
          begin
            FRegClasses[I].Proc(Result);
            Found := True;
          end;
    if not Found and  AClass.InheritsFrom(TInvokableClass) then
      Result := TInvokableClassClass(AClass).Create;
  finally
    UnLock;
  end;
end;

procedure TInvokableClassRegistry.GetClassFromIntfInfo(Info: PTypeInfo;
  var AClass: TClass);
var
  I: Integer;
begin
  AClass := nil;
  Lock;
  try
    for I := 0 to Length(FRegIntfs) - 1 do
      if FRegIntfs[I].Info = Info then
        begin
          AClass := FRegIntfs[I].DefImpl;
          Break;
        end;
  finally
    UnLock;
  end;
end;

{ TInvokableClass }

constructor TInvokableClass.Create;
begin
  inherited Create;
end;

function TInvokableClass.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TInvokableClass.SafeCallException(ExceptObject: TObject;
  ExceptAddr: Pointer): HResult;
var
  L0: Exception absolute ExceptObject;
  L1: EJSONRPCException absolute ExceptObject;
  L2: EJSONRPCMethodException absolute ExceptObject;
begin
  FCode := 0;
  FMessage := '';
  FMethodName := '';
  if ExceptObject is EJSONRPCException then
    begin
      FCode := L1.Code;
      FMessage := L1.Message;
    end;
  if ExceptObject is EJSONRPCMethodException then
    begin
      FMethodName := L2.MethodName;
    end;
  if ExceptObject is Exception then
    begin
      FMessage := L0.Message;
    end;
  Result := E_UNEXPECTED;
end;

function TInvokableClass.GetCode: Integer;
begin
  Result := FCode;
end;

//procedure TInvokableClass.FakeCall;
//begin
//end;
//
//procedure TInvokableClass.SendJSON(const AJSON: string;
//  const AProc: TProc);
//var
//  LJSON: string;
//  LOnBeforeExecute: TBeforeExecuteEvent;
//begin
//  LJSON := AJSON;
//  var LIJSONRPCWrapper: IJSONRPCWrapper;
//  var LJSONRPCWrapper: TJSONRPCWrapper;
//  if Supports(Self, IJSONRPCWrapper, LIJSONRPCWrapper) then
//    begin
//      LJSONRPCWrapper := LIJSONRPCWrapper.JSONRPCWrapper;
//      LOnBeforeExecute := LJSONRPCWrapper.OnBeforeExecute;
//      LJSONRPCWrapper.OnBeforeExecute :=
//      procedure(const MethodName: string; ARequest: TStream)
//      begin
//        var LJSONRequest := LJSON;
//        var LJSONRequestBytes := TEncoding.UTF8.GetBytes(LJSONRequest);
//        ARequest.Write(LJSONRequestBytes, Length(LJSONRequestBytes));
//      end;
//    end;
//
//  AProc;
//
//  if Supports(Self, IJSONRPCWrapper, LIJSONRPCWrapper) then
//    begin
//      LJSONRPCWrapper := LIJSONRPCWrapper.JSONRPCWrapper;
//      LJSONRPCWrapper.OnBeforeExecute := LOnBeforeExecute;
//    end;
//end;

procedure TInvokableClass.SetCode(ACode: Integer);
begin
  FCode := ACode;
end;

function TInvokableClass.GetMessage: string;
begin
  Result := FMessage;
end;

procedure TInvokableClass.SetMessage(const AMsg: string);
begin
  FMessage := AMsg;
end;

function TInvokableClass.GetMethodName: string;
begin
  Result := FMethodName;
end;

procedure TInvokableClass.SetMethodName(const AMethodName: string);
begin
  FMethodName := AMethodName;
end;

//{ TRemotable }
//
//constructor TRemotable.Create;
//begin
//  inherited;
//  if RemotableDataContext <> nil then
//    begin
//      TDataContext(RemotableDataContext).AddObjectToDestroy(Self);
//      Self.DataContext := TDataContext(RemotableDataContext);
//    end;
//end;
//
//destructor TRemotable.Destroy;
//begin
//  if RemotableDataContext <> nil then
//    begin
//      TDataContext(RemotableDataContext).RemoveObjectToDestroy(Self);
//      Self.DataContext := nil;
//    end;
//  inherited Destroy;
//end;
//
//procedure TRemotable.SetDataContext(Value: TDataContext);
//begin
//  if (RemotableDataContext <> nil) and (RemotableDataContext = Self.DataContext) then
//    begin
//      TDataContext(RemotableDataContext).RemoveObjectToDestroy(Self);
//    end;
//  FDataContext := Value;
//end;

constructor TRemotableTypeRegistry.Create;
begin
  inherited Create;
  FAutoRegister := True;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TRemotableTypeRegistry.Destroy;
begin
  FreeAndNil(FCriticalSection);
  inherited Destroy;
end;

procedure TRemotableTypeRegistry.Lock;
begin
  FCriticalSection.Enter;
end;

procedure TRemotableTypeRegistry.UnLock;
begin
  FCriticalSection.Leave;
end;

{ TDataContext }

procedure TDataContext.SetDataPointer(Index: Integer; P: Pointer);
begin
  FDataP[Index] := P;
end;

function TDataContext.GetDataPointer(Index: Integer): Pointer;
begin
  Result := FDataP[Index];
end;

procedure TDataContext.AddVariantToClear(P: PVarData);
var
  I: Integer;
begin
  for I := 0 to Length(FVarToClear) -1 do
    if FVarToClear[I] = P then
      Exit;
  I := Length(FVarToClear);
  SetLength(FVarToClear, I + 1);
  FVarToClear[I] := P;
end;

{$IFNDEF NEXTGEN}
procedure TDataContext.AddStrToClear(P: Pointer);
var
  I: Integer;
begin
  { If this string is in the list already, we're set }
  for I := 0 to Length(FStrToClear) -1 do
    if FStrToClear[I] = P then
      Exit;
  I := Length(FStrToClear);
  SetLength(FStrToClear, I + 1);
  FStrToClear[I] := P;
end;

procedure TDataContext.AddWStrToClear(P: Pointer);
var
  I: Integer;
begin
  { If this WideString is in the list already, we're set }
  for I := 0 to Length(FWStrToClear) -1 do
    if FWStrToClear[I] = P then
      Exit;
  I := Length(FWStrToClear);
  SetLength(FWStrToClear, I + 1);
  FWStrToClear[I] := P;
end;
{$ENDIF !NEXTGEN}

{$IFDEF UNICODE}
procedure TDataContext.AddUStrToClear(P: Pointer);
var
  I: Integer;
begin
  { If this UnicodeString is in the list already, we're set }
  for I := 0 to Length(FUStrToClear) -1 do
    if FUStrToClear[I] = P then
      Exit;
  I := Length(FUStrToClear);
  SetLength(FUStrToClear, I + 1);
  FUStrToClear[I] := P;
end;
{$ENDIF}

constructor TDataContext.Create;
begin
  inherited;
end;

destructor TDataContext.Destroy;
var
  I: Integer;
  P: Pointer;
begin
  { Clean up objects we've allocated }
  for I := 0 to Length(FObjsToDestroy) - 1 do
    begin
       if (FObjsToDestroy[I] <> nil) then
         begin
//           if FObjsToDestroy[I].InheritsFrom(TRemotable) then
//             TRemotable(FObjsToDestroy[I]).Free else
             FObjsToDestroy[I].Free;
         end;
    end;
  SetLength(FObjsToDestroy, 0);

  { Clean Variants we allocated }
  for I := 0 to Length(FVarToClear) - 1 do
    begin
      if Assigned(FVarToClear[I]) then
        Variant( PVarData(FVarToClear[I])^) := NULL;
    end;
  SetLength(FVarToClear, 0);

  { Clean up dynamic arrays we allocated }
  for I := 0 to Length(FDynArrayToClear) - 1 do
    begin
      if Assigned(FDynArrayToClear[I].P) then
        begin
          P := PPointer(FDynArrayToClear[I].P)^;
          DynArrayClear(P, FDynArrayToClear[I].Info)
        end;
    end;
  SetLength(FDynArrayToClear, 0);

{$IFNDEF NEXTGEN}
  { Clean up strings we allocated }
  for I := 0 to Length(FStrToClear) - 1 do
    begin
      if Assigned(FStrToClear[I]) then
        PAnsiString(FStrToClear[I])^ := '';
    end;
  SetLength(FStrToClear, 0);
{$ENDIF !NEXTGEN}

{$IFDEF UNICODE}
  { Cleanup unicode strings we allocated }
  for I := 0 to Length(FUStrToClear) - 1 do
    begin
      if Assigned(FUStrToClear[I]) then
        PUnicodeString(FUStrToClear[I])^ := '';
    end;
  SetLength(FUStrToClear, 0);
{$ENDIF}

{$IFNDEF NEXTGEN}
  { Clean up WideStrings we allocated }
  for I := 0 to Length(FWStrToClear) - 1 do
    begin
      if Assigned(FWStrToClear[I]) then
        PWideString(FWStrToClear[I])^ := '';
    end;
  SetLength(FWStrToClear, 0);
{$ENDIF !NEXTGEN}

  inherited;
end;

procedure TDataContext.AddDynArrayToClear(P: Pointer; Info: PTypeInfo);
var
  I: Integer;
begin
  for I := 0 to Length(FDynArrayToClear) -1 do
    if FDynArrayToClear[I].P = P then
      Exit;
  I := Length(FDynArrayToClear);
  SetLength(FDynArrayToClear, I + 1);
  FDynArrayToClear[I].P := P;
  FDynArrayToClear[I].Info := Info;
end;

procedure TDataContext.AddObjectToDestroy(Obj: TObject);
var
  Index, EmptySlot: Integer;
begin
  EmptySlot := -1;
  // DO NOT REPLACE WITH TArray.IndexOf<TObject>
  for Index := 0 to Length(FObjsToDestroy) -1 do
    begin
      if FObjsToDestroy[Index] = Obj then
        Exit;
      if FObjsToDestroy[Index] = nil then
        EmptySlot := Index;
    end;

  if EmptySlot <> -1 then
    begin
      FObjsToDestroy[EmptySlot] := Obj;
      Exit;
    end;
  Index := Length(FObjsToDestroy);
  SetLength(FObjsToDestroy, Index + 1);
  FObjsToDestroy[Index] := Obj;
end;

procedure TDataContext.RemoveObjectToDestroy(Obj: TObject);
var
  I: Integer;
begin
  I := 0;
  while I < Length(FObjsToDestroy) do
    begin
      if FObjsToDestroy[I] = Obj then
        begin
          FObjsToDestroy[I] := nil;
          Break;
        end;
      Inc(I);
    end;
end;

function TDataContext.AllocData(Size: Integer): Pointer;
begin
  Result := @FData[FDataOffset];
  Inc(FDataOffset, Size);
end;

{ TInvContext }

const
  MAXINLINESIZE = SizeOf(TVarData) + 4;

procedure TInvContext.SetMethodInfo(const MD: TIntfMethEntry);
begin
  SetLength(FDataP, MD.ParamCount + 1);
  SetLength(FData, (MD.ParamCount + 1) * MAXINLINESIZE);
end;

procedure TInvContext.SetParamPointer(Param: Integer; P: Pointer);
begin
  SetDataPointer(Param,  P);
end;

function TInvContext.GetParamPointer(Param: Integer): Pointer;
begin
  Result := GetDataPointer(Param);
end;

function TInvContext.GetResultPointer: Pointer;
begin
  Result := FResultP;
end;

procedure TInvContext.SetResultPointer(P: Pointer);
begin
  FResultP := P;
end;

procedure TInvContext.AllocServerData(const MD: TIntfMethEntry);

  function GetTypeSize(Info: PTypeInfo): Integer;
  var
    Context: TRttiContext;
    Typ: TRttiType;
  begin
    if (Info = TypeInfo(Variant)) or (Info = TypeInfo(OleVariant)) then
      Exit(SizeOf(TVarData));
    Result := SizeOf(Pointer);
    Typ := Context.GetType(Info);
    if Assigned(Typ) then
      Result := Typ.TypeSize;
  end;

var
  I: Integer;
  Info: PTypeInfo;
  P: Pointer;
begin
  for I := 0 to MD.ParamCount - 1 do
    begin
      P := AllocData(GetTypeSize(MD.Params[I].Info));
      SetParamPointer(I, P);
      case MD.Params[I].Info.Kind of
        tkVariant: begin
          Variant(PVarData(P)^) := NULL;
          AddVariantToClear(PVarData(P));
        end;
        tkDynArray: begin
          AddDynArrayToClear(P, MD.Params[I].Info);
        end;
        {$IFNDEF NEXTGEN}
        tkLString: begin
          PAnsiString(P)^ := '';
          AddStrToClear(P);
        end;
        tkWString: begin
          PWideString(P)^ := '';
          AddWStrToClear(P);
        end;
        {$ENDIF !NEXTGEN}
        {$IFDEF UNICODE}
        tkUString: begin
          PUnicodeString(P)^ := '';
          AddUStrToClear(P);
        end;
        {$ENDIF}
      end;

//      if MD.Params[I].Info.Kind = tkVariant then
//        begin
//          Variant(PVarData(P)^) := NULL;
//          AddVariantToClear(PVarData(P));
//        end else if MD.Params[I].Info.Kind = tkDynArray then
//        begin
//          AddDynArrayToClear(P, MD.Params[I].Info);
//    {$IFNDEF NEXTGEN}
//        end else if MD.Params[I].Info.Kind = tkLString then
//        begin
//          PAnsiString(P)^ := '';
//          AddStrToClear(P);
//    {$ENDIF !NEXTGEN}
//    {$IFDEF UNICODE}
//        end else if MD.Params[I].Info.Kind = tkUString then
//        begin
//          PUnicodeString(P)^ := '';
//          AddUStrToClear(P);
//    {$ENDIF}
//    {$IFNDEF NEXTGEN}
//        end else if MD.Params[I].Info.kind = tkWString then
//        begin
//          PWideString(P)^ := '';
//          AddWStrToClear(P);
//    {$ENDIF !NEXTGEN}
//        end;
    end;

  Info := MD.ResultInfo;
  if Info <> nil then
    begin
      case Info^.Kind of
  {$IFNDEF NEXTGEN}
        tkLString:
          begin
            P := AllocData(SizeOf(PAnsiString));
            PAnsiString(P)^ := '';
            AddStrToClear(P);
          end;
        tkWString:
          begin
            P := AllocData(SizeOf(PWideString));
            PWideString(P)^ := '';
            AddWStrToClear(P);
          end;
  {$ENDIF !NEXTGEN}
  {$IFDEF UNICODE}
        tkUString:
          begin
            P := AllocData(SizeOf(PUnicodeString));
            PUnicodeString(P)^ := '';
            AddUStrToClear(P);
          end;
  {$ENDIF}
        tkInteger, tkEnumeration: begin
          // Integers and enums are allocated 4 bytes
          P := AllocData(SizeOf(TInvContext.TEnum));
        end;
        tkInt64:
          P := AllocData(SizeOf(Int64));
        tkVariant:
          begin
            P := AllocData(SizeOf(TVarData));
            Variant( PVarData(P)^ ) := NULL;
            AddVariantToClear(PVarData(P));
          end;
        tkDynArray:
          begin
            P := AllocData(GetTypeSize(Info));
            AddDynArrayToClear(P, MD.ResultInfo);
          end;
        else
          P := AllocData(GetTypeSize(Info));
      end;
      SetResultPointer(P);
    end;
end;

procedure InitIR;
begin
  JSONRPCInvRegistryV := TInvokableClassRegistry.Create;
end;

function InvRegistry: TInvokableClassRegistry;
begin
  if not Assigned(JSONRPCInvRegistryV) then
    InitIR;
  Result := JSONRPCInvRegistryV;
end;

initialization
  InvRegistry;
finalization
  JSONRPCInvRegistryV.Free;
end.



































// chuacw, Jun 2023

