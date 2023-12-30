unit JSONRPC.DelphiUnitCreator;

interface

uses
  ToolsAPI, System.Classes;

type

  TDelphiUnitCreator = class(TInterfacedObject, IOTAModuleCreator, IOTACreator)
  protected
    FPersonality: string;
    FImplementationSource: string;
    FInterfaceSource: string;
    FImplementationStream,
    FInterfaceStream: TStream;
    function GetImplementationStream: TStream;
    function GetInterfaceStream: TStream;
  public
    constructor Create(const APersonality: string);
    destructor Destroy; override;

    { IOTACreator }
    /// <summary>
    /// Return a string representing the default creator type in which to augment.
    /// See the definitions of sApplication, sConsole, sLibrary and
    /// sPackage, etc.. above.  Return an empty string indicating that this
    /// creator will provide *all* information
    /// </summary>
    function GetCreatorType: string;
    /// <summary>
    /// Return False if this is a new module
    /// </summary>
    function GetExisting: Boolean;
    /// <summary>
    /// Return the File system IDString that this module uses for reading/writing
    /// </summary>
    function GetFileSystem: string;
    /// <summary>
    /// Return the Owning module, if one exists (for a project module, this would
    /// be a project; for a project this is a project group)
    /// </summary>
    function GetOwner: IOTAModule;
    /// <summary>
    /// Return true, if this item is to be marked as un-named.  This will force the
    /// save as dialog to appear the first time the user saves.
    /// </summary>
    function GetUnnamed: Boolean;

    { IOTAModuleCreator }
    /// <summary>
    /// Return the Ancestor form name
    /// </summary>
    function GetAncestorName: string;
    /// <summary>
    /// Return the implementation filename, or blank to have the IDE create a new
    /// unique one. (C++ .cpp file or Delphi unit) NOTE: If a value is returned then it *must* be a
    /// fully qualified filename.  This also applies to GetIntfFileName and
    /// GetAdditionalFileName on the IOTAAdditionalFilesModuleCreator interface.
    /// </summary>
    function GetImplFileName: string;
    /// <summary>
    /// Return the interface filename, or blank to have the IDE create a new
    /// unique one.  (C++ header)
    /// </summary>
    function GetIntfFileName: string;
    /// <summary>
    /// Return the form name
    /// </summary>
    function GetFormName: string;
    /// <summary>
    /// Return True to Make this module the main form of the given Owner/Project
    /// </summary>
    function GetMainForm: Boolean;
    /// <summary>
    /// Return True to show the form
    /// </summary>
    function GetShowForm: Boolean;
    /// <summary>
    /// Return True to show the source
    /// </summary>
    function GetShowSource: Boolean;
    /// <summary>
    /// Create and return the Form resource for this new module if applicable
    /// </summary>
    function NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
    /// <summary>
    /// Create and return the Implementation source for this module. (C++ .cpp
    /// file or Delphi unit)
    /// </summary>
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    /// <summary>
    /// Create and return the Interface (C++ header) source for this module
    /// </summary>
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    /// <summary>
    /// Called when the new form/datamodule/custom module is created
    /// </summary>
    procedure FormCreated(const FormEditor: IOTAFormEditor);

    property ImplementationSource: string read FImplementationSource write
      FImplementationSource;
    property InterfaceSource: string read FInterfaceSource write
      FInterfaceSource;

    property InterfaceStream: TStream read GetInterfaceStream;
    property ImplementationStream: TStream read GetImplementationStream;
  end;

implementation

{ TDelphiUnitCreator }

constructor TDelphiUnitCreator.Create(const APersonality: string);
begin
  inherited Create;
  FPersonality := APersonality;
end;

destructor TDelphiUnitCreator.Destroy;
begin
  FImplementationStream.Free;
  FInterfaceStream.Free;
  inherited;
end;

procedure TDelphiUnitCreator.FormCreated(const FormEditor: IOTAFormEditor);
begin
  // Do nothing?
end;

function TDelphiUnitCreator.GetAncestorName: string;
begin
  Result := '';
end;

function TDelphiUnitCreator.GetCreatorType: string;
begin
  Result := '';
end;

function TDelphiUnitCreator.GetExisting: Boolean;
begin
  Result := False;
end;

function TDelphiUnitCreator.GetFileSystem: string;
begin
  Result := '';
end;

function TDelphiUnitCreator.GetFormName: string;
begin
  Result := '';
end;

function TDelphiUnitCreator.GetImplementationStream: TStream;
begin
  if not Assigned(FImplementationStream) then
    FImplementationStream := TStringStream.Create;
  Result := FImplementationStream;
end;

function TDelphiUnitCreator.GetImplFileName: string;
begin
  Result := '';
end;

function TDelphiUnitCreator.GetInterfaceStream: TStream;
begin
  if not Assigned(FInterfaceStream) then
    FInterfaceStream := TStringStream.Create;
  Result := FInterfaceStream;
end;

function TDelphiUnitCreator.GetIntfFileName: string;
begin
  Result := '';
end;

function TDelphiUnitCreator.GetMainForm: Boolean;
begin
  Result := False;
end;

function TDelphiUnitCreator.GetOwner: IOTAModule;
begin
  Result := GetActiveProject;
end;

function TDelphiUnitCreator.GetShowForm: Boolean;
begin
  Result := False;
end;

function TDelphiUnitCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

function TDelphiUnitCreator.GetUnnamed: Boolean;
begin
  Result := True;
end;

function TDelphiUnitCreator.NewFormFile(const FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result := nil;
end;

function TDelphiUnitCreator.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  if (FImplementationSource = '') and Assigned(FImplementationStream) then
    FImplementationSource := TStringStream(FImplementationStream).DataString;
  Result := TOTAFile.Create(FImplementationSource);
end;

function TDelphiUnitCreator.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  if (FInterfaceSource = '') and Assigned(FInterfaceStream) then
    FInterfaceSource := TStringStream(FInterfaceStream).DataString;
  Result := TOTAFile.Create(FInterfaceSource);
end;

end.
