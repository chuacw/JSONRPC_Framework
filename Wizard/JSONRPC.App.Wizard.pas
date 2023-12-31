unit JSONRPC.App.Wizard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, Vcl.CheckLst, Vcl.ComCtrls;

type
  TfrmWizard = class(TFrame)
    pnlOptions: TPanel;
    leServerURL: TLabeledEdit;
    leUserName: TLabeledEdit;
    lePassword: TLabeledEdit;
    rgPassParametersBy: TRadioGroup;
    cbRequireParams: TCheckListBox;
    leMethodName: TLabeledEdit;
    GroupBox1: TGroupBox;
    memSource: TMemo;
    leInterfaceName: TLabeledEdit;
    leInterfaceUnitName: TLabeledEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    memGetMethodUnit: TMemo;
    leFunctionGetterUnitName: TLabeledEdit;
    Button1: TButton;
    procedure leInterfaceNameChange(Sender: TObject);
    procedure cbRequireParamsClick(Sender: TObject);
    procedure rgPassParametersByClick(Sender: TObject);
    procedure leServerURLChange(Sender: TObject);
    procedure leMethodNameChange(Sender: TObject);
    procedure cbRequireParamsEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure cbRequireParamsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure btnShowHideSourceClick(Sender: TObject);
    procedure leUserNameChange(Sender: TObject);
    procedure lePasswordChange(Sender: TObject);

    procedure leInterfaceUnitNameChange(Sender: TObject);
    procedure leFunctionGetterUnitNameChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FGUID: TGUID;
    FDragIndex: Integer;

    function GetPassword: string;
    function GetUserName: string;
    function GetServerURL: string;
    function GetRequireLogging: Boolean;
    function GetRequireLogIncoming: Boolean;
    function GetRequireLogOutgoing: Boolean;
    function GetRequireParams: Boolean;
    function GetRequireServerURL: Boolean;
    function GetRequireUserNamePassword: Boolean;

    procedure RegenerateSourceUnit;
    procedure RegenerateInterfaceGetterUnit;

    function GetInterfaceUnitName: string;
    function GetFunctionGetterUnitName: string;
    function GetFunctionGetterMethodName: string;
    function GetInterfaceName: string;

    /// <summary>
    /// <remarks> After this source is added to the project, these files are required to be added:
    /// <para />
    /// <para>JSONRPC.Common.Consts.pas,</para>
    /// <para>JSONRPC.Common.RecordHandlers.pas,</para>
    /// <para>JSONRPC.Common.Types.pas,</para>
    /// <para>JSONRPC.InvokeRegistry.pas,</para>
    /// <para>JSONRPC.JsonUtils.pas,</para>
    /// <para>JSONRPC.RIO.pas</para>
    /// <para />
    /// in order for the project to compile
    /// </remarks>
    /// </summary>
    function GetInterfaceSource: string;

    /// <summary>
    /// <remarks> After this source is added to the project, these files are required to be added:
    /// <para />
    /// <para>JSONRPC.Common.Consts.pas,</para>
    /// <para>JSONRPC.Common.RecordHandlers.pas,</para>
    /// <para>JSONRPC.Common.Types.pas,</para>
    /// <para>JSONRPC.InvokeRegistry.pas,</para>
    /// <para>JSONRPC.JsonUtils.pas,</para>
    /// <para>JSONRPC.RIO.pas</para>
    /// <para />
    /// in order for the project to compile
    /// </remarks>
    /// </summary>
    function GetFunctionGetterSource: string;
  public
    { Public declarations }
    procedure frameCreate;

    property FunctionGetterUnitName: string read GetFunctionGetterUnitName;
    property FunctionGetterMethodName: string read GetFunctionGetterMethodName;
    property InterfaceUnitName: string read GetInterfaceUnitName;
    property InterfaceName: string read GetInterfaceName;

    property InterfaceSource: string read GetInterfaceSource;
    property FunctionGetterSource: string read GetFunctionGetterSource;

    property ServerURL: string read GetServerURL;
    property UserName: string read GetUserName;
    property Password: string read GetPassword;
    property RequireParams: Boolean read GetRequireParams;
    property RequireLogging: Boolean read GetRequireLogging;
    property RequireLogIncoming: Boolean read GetRequireLogIncoming;
    property RequireLogOutgoing: Boolean read GetRequireLogOutgoing;
    property RequireServerURL: Boolean read GetRequireServerURL;
    property RequireUserNamePassword: Boolean read GetRequireUserNamePassword;
  end;

implementation

uses
  JSONRPC.Wizard.Consts, System.StrUtils, System.IOUtils;

{$R *.dfm}

type
  EInvalidIdent = class(Exception);
  TLabeledEditHelper = class helper for TLabeledEdit
  public
    procedure Reset;
  end;

{ TLabeledEditHelper }

procedure TLabeledEditHelper.Reset;
begin
  inherited Reset;
end;

{ TfrmWizard }

function TfrmWizard.GetFunctionGetterMethodName: string;
begin
  Result := leMethodName.Text;
end;

function TfrmWizard.GetFunctionGetterUnitName: string;
begin
  Result := leFunctionGetterUnitName.Text;
end;

function TfrmWizard.GetInterfaceName: string;
begin
  Result := leInterfaceName.Text;
end;

function TfrmWizard.GetInterfaceUnitName: string;
begin
  Result := leInterfaceUnitName.Text;
end;

function TfrmWizard.GetInterfaceSource: string;
begin
  Result := memSource.Lines.Text;
end;

function TfrmWizard.GetFunctionGetterSource: string;
begin
  Result := memGetMethodUnit.Lines.Text;
end;

function TfrmWizard.GetPassword: string;
begin
  Result := lePassword.Text;
end;

function TfrmWizard.GetRequireLogging: Boolean;
begin
  Result := RequireLogIncoming or RequireLogOutgoing;
end;

const
  CLogIncoming:  string = 'Log incoming response';
  CLogOutgoing:  string = 'Log outgoing request';
  CServerURL:    string = 'Server URL';
  CUserNamePass: string = 'User Name / Password';

function TfrmWizard.GetRequireLogIncoming: Boolean;
begin
  var LIndex := cbRequireParams.Items.IndexOf(CLogIncoming);
  Result := cbRequireParams.Checked[LIndex];
end;

function TfrmWizard.GetRequireLogOutgoing: Boolean;
begin
  var LIndex := cbRequireParams.Items.IndexOf(CLogOutgoing);
  Result := cbRequireParams.Checked[LIndex];
end;

function TfrmWizard.GetRequireParams: Boolean;
begin
  Result := RequireServerURL or RequireLogging;
end;

function TfrmWizard.GetRequireServerURL: Boolean;
begin
  var LIndex := cbRequireParams.Items.IndexOf(CServerURL);
  Result := cbRequireParams.Checked[LIndex];
end;

function TfrmWizard.GetRequireUserNamePassword: Boolean;
begin
  var LIndex := cbRequireParams.Items.IndexOf(CUserNamePass);
  Result := cbRequireParams.Checked[LIndex];
end;

function TfrmWizard.GetServerURL: string;
begin
  Result := leServerURL.Text;
end;

//function TfrmWizard.GetInterfaceUnitName: string;
//begin
//  Result := leInterfaceUnitName.Text;
//end;

function TfrmWizard.GetUserName: string;
begin
  Result := leUserName.Text;
end;

procedure InvalidIdentifier(const ANewName: string);
begin
  raise EInvalidIdent.CreateFmt(SInvalidIdentifierFmt, [ANewName]);
end;

procedure TfrmWizard.leInterfaceUnitNameChange(Sender: TObject);
begin
  if (not IsValidIdent(InterfaceUnitName, True)) or (InterfaceUnitName = FunctionGetterUnitName) then
    begin
      var LNewName := InterfaceUnitName;
      try
        InvalidIdentifier(LNewName);
      finally
        leInterfaceUnitName.Reset;
      end;
    end;
  RegenerateSourceUnit;
  RegenerateInterfaceGetterUnit;
end;

procedure TfrmWizard.leUserNameChange(Sender: TObject);
begin
  RegenerateInterfaceGetterUnit;
end;

procedure TfrmWizard.leFunctionGetterUnitNameChange(Sender: TObject);
begin
  if (not IsValidIdent(FunctionGetterUnitName, True)) or (FunctionGetterUnitName = InterfaceUnitName) then
    begin
      var LNewName := FunctionGetterUnitName;
      try
        InvalidIdentifier(LNewName);
      finally
        leFunctionGetterUnitName.Reset;
      end;
    end;
  RegenerateSourceUnit;
  RegenerateInterfaceGetterUnit;
end;

procedure TfrmWizard.leInterfaceNameChange(Sender: TObject);
begin
  if not IsValidIdent(InterfaceUnitName) then
    begin
      var LNewName := InterfaceUnitName;
      try
        InvalidIdentifier(LNewName);
      finally
        leInterfaceUnitName.Reset;
      end;
    end;
  RegenerateSourceUnit;
  RegenerateInterfaceGetterUnit;
end;

procedure TfrmWizard.leMethodNameChange(Sender: TObject);
begin
  if not IsValidIdent(leMethodName.Text) then
    begin
      var LNewName := leMethodName.Text;
      try
        InvalidIdentifier(LNewName);
      finally
        leMethodName.Reset;
      end;
    end;
  RegenerateInterfaceGetterUnit;
end;

procedure TfrmWizard.lePasswordChange(Sender: TObject);
begin
  RegenerateInterfaceGetterUnit;
end;

procedure TfrmWizard.leServerURLChange(Sender: TObject);
begin
  RegenerateInterfaceGetterUnit;
end;

procedure TfrmWizard.btnShowHideSourceClick(Sender: TObject);
begin
//  GroupBox1.Visible := not GroupBox1.Visible;
//  if not GroupBox1.Visible then
//    begin
//      Height := Panel1.Height + Panel1.Top;
//    end;
end;

procedure TfrmWizard.Button1Click(Sender: TObject);
var
  LFileName1, LFileName2: string;
begin
  LFileName1 := 'c:\temp\' + InterfaceUnitName + '.pas';
  LFileName2 := 'c:\temp\' + FunctionGetterUnitName + '.pas';
  TFile.WriteAllText(LFileName1, InterfaceSource);
  TFile.WriteAllText(LFileName2, FunctionGetterSource);
end;

procedure TfrmWizard.cbRequireParamsClick(Sender: TObject);
begin
  RegenerateInterfaceGetterUnit;
end;

procedure TfrmWizard.cbRequireParamsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);

begin
  var LIndex := cbRequireParams.ItemAtPos(Point(X, Y), True);
  if (LIndex <> -1) and (FDragIndex = -1) then
    begin
      FDragIndex := LIndex;
      Accept := True;
    end;
end;

procedure TfrmWizard.cbRequireParamsEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  if FDragIndex = -1 then
    Exit;
  try
    var LIndex := cbRequireParams.ItemAtPos(Point(X, Y), True);
    if LIndex = -1 then
      LIndex := 0;
    cbRequireParams.Items.Exchange(FDragIndex, LIndex);
    RegenerateInterfaceGetterUnit;
  finally
    FDragIndex := -1;
  end;
end;

procedure TfrmWizard.frameCreate;
begin
  FDragIndex := -1;

  var LArrParams: TArray<string> := [
    CServerURL, CLogIncoming, CLogOutgoing, CUserNamePass
  ];
  cbRequireParams.Items.Clear;
  cbRequireParams.Items.AddStrings(LArrParams);

//  for var I := 0 to cbRequireParams.Count-1 do
//    begin
//      cbRequireParams.Items.Objects[I] := TObject(I);
//    end;

  FGUID := TGUID.NewGuid;

  RegenerateSourceUnit;
  RegenerateInterfaceGetterUnit;

end;


type
  TSBHelper = class helper for TStringBuilder
  public
    procedure AppendDelimiter;
  end;

procedure TSBHelper.AppendDelimiter;
begin
  if Length <> 0 then
    begin
      Append('; ');
      AppendLine;
    end;
end;

procedure TfrmWizard.RegenerateInterfaceGetterUnit;
var
  LSBParams: TStringBuilder;
  LUnitName, LMethodPrototype, LParamPassing, LParams,
  LLoggingCode, LAuthenticationCode, LAdditionalUnits: string;
  LHasDefault: Boolean;
begin
  LUnitName := FunctionGetterUnitName;
  LHasDefault := False;
//  if RequireParams then
    begin
      LSBParams := TStringBuilder.Create(4096);
      try
        var LArrParams: TArray<string> := [CLogIncoming, CLogOutgoing, CUserNamePass, CServerURL];
        for var I := 0 to cbRequireParams.Count-1 do
          begin
                if (cbRequireParams.Items.IndexOf(CLogIncoming) = I) then
                  begin
                    if RequireLogIncoming then
                      begin
                        LSBParams.AppendDelimiter;
                        LSBParams.Append('const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil');
                        LHasDefault := True;
                      end;
                  end else
                if (cbRequireParams.Items.IndexOf(CLogOutgoing) = I) then
                  begin
                    if RequireLogOutgoing then
                      begin
                        LSBParams.AppendDelimiter;
                        LSBParams.Append('const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil');
                        LHasDefault := True;
                      end;
                  end else
                if (cbRequireParams.Items.IndexOf(CUserNamePass) = I) then
                  begin
                    if RequireUserNamePassword then
                      begin
                        LSBParams.AppendDelimiter;
                        var LDefaultUserName := '';
                        var LDefaultPassword := '';
                        var LUserName := ''; var LPassword := '';
                        LHasDefault := LHasDefault or (UserName <> '') or (Password <> '');
                        if LHasDefault then
                          LDefaultUserName := Format(' = ''%s''', [UserName]);
                        var LUserNameParam := Format('const AUserName: string%s; ', [LDefaultUserName]);
                        LSBParams.Append(LUserNameParam);

                        if LHasDefault then
                          LDefaultPassword := Format(' = ''%s''', [Password]);
                        var LPasswordParam := Format('const APassword: string%s', [LDefaultPassword]);
                        LSBParams.Append(LPasswordParam);
                      end;
                  end else
                if (cbRequireParams.Items.IndexOf(CServerURL) = I) then
                  begin
                    if RequireServerURL then
                      begin
                        LSBParams.AppendDelimiter;
                        LSBParams.Append(Format('const AServerURL: string = ''%s''', [ServerURL]));
                        LHasDefault := True;
                      end;
                  end;
          end;
//        if RequireUserNamePassword then
//          begin
//            LSBParams.AppendDelimiter;
//            LSBParams.Append('const AUserName: string; ');
//            LSBParams.Append('const APassword: string');
//          end;
//        if RequireServerURL then
//          begin
//            LSBParams.AppendDelimiter;
//            LSBParams.Append(Format('const AServerURL: string = ''%s''', [ServerURL]));
//          end;
//        if RequireLogging then
//          begin
//            if RequireLogIncoming then
//              begin
//                LSBParams.AppendDelimiter;
//                LSBParams.Append('const AOnLoggingIncomingJSONResponse: TOnLogIncomingJSONResponse = nil');
//              end;
//            if RequireLogOutgoing then
//              begin
//                LSBParams.AppendDelimiter;
//                LSBParams.Append('const AOnLoggingOutgoingJSONRequest: TOnLogOutgoingJSONRequest = nil');
//              end;
//          end;
      finally
        if LSBParams.Length <> 0 then
          begin
            LSBParams.Insert(0, '(');
            LSBParams.Append(')');
          end;
        LParams := LSBParams.ToString;
        LSBParams.Free;
      end;
    end;

  LMethodPrototype := Format('function %s%s: %s', [FunctionGetterMethodName, LParams,
    InterfaceName]);

  if rgPassParametersBy.ItemIndex = 0 then
    LParamPassing := '''
  // Params passing
  LJSONRPCWrapper.PassParamsByPos := True;
''';

  if RequireLogIncoming or RequireLogOutgoing then
    begin
      var LSB := TStringBuilder.Create(4096);
      try
        LSB.AppendLine('  // Logging features');
        if RequireLogIncoming then
          LSB.AppendLine('''
  LJSONRPCWrapper.OnLogIncomingJSONResponse := AOnLoggingIncomingJSONResponse;
''');
        if RequireLogOutgoing then
          LSB.AppendLine('''
  LJSONRPCWrapper.OnLogOutgoingJSONRequest := AOnLoggingOutgoingJSONRequest;
''');
      finally
        LLoggingCode := LSB.ToString;
      end;
    end;


  if (UserName <> '') or (Password <> '') or RequireUserNamePassword then
    begin
      LAuthenticationCode := '''
  // Authentication features
  if (AUserName <> '') or (APassword <> '') then
    begin
      LJSONRPCWrapper.OnBeforeInitializeHeaders := procedure (var VNetHeaders: TNetHeaders)
      begin
        var LUserNamePassword := Format('%s:%s', [AUserName, APassword]);
        VNetHeaders := [TNameValuePair.Create('Authorization', 'Basic ' +
          TNetEncoding.Base64String.Encode(LUserNamePassword))];
      end;
    end;
''';
      LAdditionalUnits := ', System.SysUtils, System.NetEncoding';
    end;

  var LFeatures := '';
  if (Length(LParamPassing) + Length(LLoggingCode) + Length(LAuthenticationCode)) <> 0 then
    begin
      var LSB := TStringBuilder.Create(512);
      try
        LSB.AppendLine;
        if RequireServerURL then
          begin
            LSB.AppendLine('  LJSONRPCWrapper.ServerURL := AServerURL;');
            LSB.AppendLine;
          end;
        if LParamPassing <> '' then
          begin
            LSB.AppendLine(LParamPassing);
          end;
        if LLoggingCode <> '' then
          begin
            if LSB.Length <> 0 then
              LSB.AppendLine;
            LSB.Append(LLoggingCode);
          end;
        if LAuthenticationCode <> '' then
          begin
            if LSB.Length <> 0 then
              LSB.AppendLine;
            LSB.AppendLine(LAuthenticationCode);
          end;
      finally
        LFeatures := LSB.ToString;
        LSB.Free;
      end;
    end;
  var LCode := Format(SMethodSource, [
    FunctionGetterUnitName, InterfaceUnitName, LMethodPrototype,
    LAdditionalUnits, InterfaceName, LFeatures
  ]);
  memGetMethodUnit.Lines.Text := LCode;
end;

procedure TfrmWizard.RegenerateSourceUnit;
begin
  memSource.Lines.Text := Format(SInterfaceUnitSource, [
    InterfaceUnitName, leInterfaceName.Text, GUIDToString(FGUID)
  ]);
end;

procedure TfrmWizard.rgPassParametersByClick(Sender: TObject);
begin
  RegenerateInterfaceGetterUnit;
end;

end.
