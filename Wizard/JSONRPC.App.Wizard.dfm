object frmWizard: TfrmWizard
  Left = 0
  Top = 0
  Width = 1440
  Height = 1303
  Margins.Left = 7
  Margins.Top = 7
  Margins.Right = 7
  Margins.Bottom = 7
  TabOrder = 0
  PixelsPerInch = 216
  object pnlOptions: TPanel
    Left = 0
    Top = 0
    Width = 1440
    Height = 613
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object leInterfaceUnitName: TLabeledEdit
      Left = 28
      Top = 53
      Width = 523
      Height = 51
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      EditLabel.Width = 232
      EditLabel.Height = 37
      EditLabel.Margins.Left = 7
      EditLabel.Margins.Top = 7
      EditLabel.Margins.Right = 7
      EditLabel.Margins.Bottom = 7
      EditLabel.Caption = 'Interface Unit name'
      TabOrder = 0
      Text = 'UnitIntf'
      OnChange = leInterfaceUnitNameChange
    end
    object leInterfaceName: TLabeledEdit
      Left = 28
      Top = 266
      Width = 523
      Height = 48
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      EditLabel.Width = 175
      EditLabel.Height = 37
      EditLabel.Margins.Left = 7
      EditLabel.Margins.Top = 7
      EditLabel.Margins.Right = 7
      EditLabel.Margins.Bottom = 7
      EditLabel.Caption = 'Interface name'
      TabOrder = 2
      Text = 'ISomeJSONRPC'
      OnChange = leInterfaceNameChange
    end
    object leUserName: TLabeledEdit
      Left = 853
      Top = 53
      Width = 523
      Height = 50
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      EditLabel.Width = 126
      EditLabel.Height = 37
      EditLabel.Margins.Left = 7
      EditLabel.Margins.Top = 7
      EditLabel.Margins.Right = 7
      EditLabel.Margins.Bottom = 7
      EditLabel.Caption = 'User name'
      TabOrder = 4
      Text = ''
      OnChange = leUserNameChange
    end
    object lePassword: TLabeledEdit
      Left = 853
      Top = 154
      Width = 523
      Height = 45
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      EditLabel.Width = 111
      EditLabel.Height = 37
      EditLabel.Margins.Left = 7
      EditLabel.Margins.Top = 7
      EditLabel.Margins.Right = 7
      EditLabel.Margins.Bottom = 7
      EditLabel.Caption = 'Password'
      TabOrder = 5
      Text = ''
      OnChange = lePasswordChange
    end
    object leServerURL: TLabeledEdit
      Left = 28
      Top = 366
      Width = 757
      Height = 51
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      EditLabel.Width = 128
      EditLabel.Height = 37
      EditLabel.Margins.Left = 7
      EditLabel.Margins.Top = 7
      EditLabel.Margins.Right = 7
      EditLabel.Margins.Bottom = 7
      EditLabel.Caption = 'Server URL'
      TabOrder = 3
      Text = ''
      OnChange = leServerURLChange
    end
    object leMethodName: TLabeledEdit
      Left = 853
      Top = 266
      Width = 523
      Height = 47
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      EditLabel.Width = 172
      EditLabel.Height = 37
      EditLabel.Margins.Left = 7
      EditLabel.Margins.Top = 7
      EditLabel.Margins.Right = 7
      EditLabel.Margins.Bottom = 7
      EditLabel.Caption = 'Method Name'
      TabOrder = 6
      Text = 'GetSomeJSONRPC'
      OnChange = leMethodNameChange
    end
    object cbRequireParams: TCheckListBox
      Left = 28
      Top = 449
      Width = 757
      Height = 153
      Hint = 
        'Check to include as parameter.'#13#10'Rearrange to change parameter de' +
        'claration order.'
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      Columns = 2
      DragMode = dmAutomatic
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -30
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemHeight = 41
      Items.Strings = (
        'Log incoming response'
        'Log outgoing request'
        'Server URL'
        'User Name / Password')
      ParentColor = True
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      OnClick = cbRequireParamsClick
      OnDragOver = cbRequireParamsDragOver
      OnEndDrag = cbRequireParamsEndDrag
    end
    object rgPassParametersBy: TRadioGroup
      Left = 853
      Top = 327
      Width = 451
      Height = 168
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      Caption = 'Pass parameters by '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -30
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'Position'
        'Name')
      ParentFont = False
      TabOrder = 8
      OnClick = rgPassParametersByClick
    end
    object leFunctionGetterUnitName: TLabeledEdit
      Left = 28
      Top = 154
      Width = 523
      Height = 51
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      EditLabel.Width = 310
      EditLabel.Height = 37
      EditLabel.Margins.Left = 7
      EditLabel.Margins.Top = 7
      EditLabel.Margins.Right = 7
      EditLabel.Margins.Bottom = 7
      EditLabel.Caption = 'Function getter Unit name'
      TabOrder = 1
      Text = 'FuncGetter'
      OnChange = leFunctionGetterUnitNameChange
    end
    object Button1: TButton
      Left = 1207
      Top = 550
      Width = 169
      Height = 56
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      Caption = 'Button1'
      TabOrder = 9
      OnClick = Button1Click
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 620
    Width = 1440
    Height = 683
    Margins.Left = 7
    Margins.Top = 7
    Margins.Right = 7
    Margins.Bottom = 7
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = ' Source Files '
    TabOrder = 1
    object PageControl1: TPageControl
      Left = 2
      Top = 39
      Width = 1436
      Height = 642
      Margins.Left = 7
      Margins.Top = 7
      Margins.Right = 7
      Margins.Bottom = 7
      ActivePage = TabSheet2
      Align = alClient
      TabOrder = 0
      ExplicitLeft = -3
      ExplicitTop = 111
      ExplicitHeight = 698
      object TabSheet1: TTabSheet
        Margins.Left = 7
        Margins.Top = 7
        Margins.Right = 7
        Margins.Bottom = 7
        Caption = 'Interface'
        object memSource: TMemo
          Left = 0
          Top = 0
          Width = 1416
          Height = 571
          Margins.Left = 7
          Margins.Top = 7
          Margins.Right = 7
          Margins.Bottom = 7
          Align = alClient
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          ParentColor = True
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
          ExplicitHeight = 627
        end
      end
      object TabSheet2: TTabSheet
        Margins.Left = 7
        Margins.Top = 7
        Margins.Right = 7
        Margins.Bottom = 7
        Caption = 'Common Types'
        ImageIndex = 1
        object memGetMethodUnit: TMemo
          Left = 0
          Top = 0
          Width = 1416
          Height = 571
          Margins.Left = 7
          Margins.Top = 7
          Margins.Right = 7
          Margins.Bottom = 7
          Align = alClient
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          ParentColor = True
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
          ExplicitHeight = 627
        end
      end
    end
  end
end
