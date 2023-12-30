object FormInterfaceGeneration: TFormInterfaceGeneration
  Left = 71
  Top = 18
  Margins.Left = 7
  Margins.Top = 7
  Margins.Right = 7
  Margins.Bottom = 7
  Caption = 'Interface generation'
  ClientHeight = 1298
  ClientWidth = 1386
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -27
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 216
  TextHeight = 37
  inline frmWizard: TfrmWizard
    Left = 0
    Top = 0
    Width = 1386
    Height = 1298
    Margins.Left = 7
    Margins.Top = 7
    Margins.Right = 7
    Margins.Bottom = 7
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 1386
    ExplicitHeight = 1298
    inherited pnlOptions: TPanel
      Width = 1386
      StyleElements = [seFont, seClient, seBorder]
      inherited leInterfaceUnitName: TLabeledEdit
        Height = 45
        EditLabel.ExplicitLeft = 0
        EditLabel.ExplicitTop = -40
        EditLabel.ExplicitWidth = 244
        StyleElements = [seFont, seClient, seBorder]
        ExplicitHeight = 45
      end
      inherited leInterfaceName: TLabeledEdit
        Height = 45
        EditLabel.ExplicitLeft = 0
        EditLabel.ExplicitTop = -40
        EditLabel.ExplicitWidth = 194
        StyleElements = [seFont, seClient, seBorder]
        ExplicitHeight = 45
      end
      inherited leUserName: TLabeledEdit
        Height = 45
        EditLabel.ExplicitLeft = 0
        EditLabel.ExplicitTop = -40
        EditLabel.ExplicitWidth = 145
        StyleElements = [seFont, seClient, seBorder]
        ExplicitHeight = 45
      end
      inherited lePassword: TLabeledEdit
        EditLabel.ExplicitLeft = 0
        EditLabel.ExplicitTop = -40
        EditLabel.ExplicitWidth = 132
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited leServerURL: TLabeledEdit
        Height = 45
        EditLabel.ExplicitLeft = 0
        EditLabel.ExplicitTop = -40
        EditLabel.ExplicitWidth = 142
        StyleElements = [seFont, seClient, seBorder]
        ExplicitHeight = 45
      end
      inherited leMethodName: TLabeledEdit
        Height = 45
        EditLabel.ExplicitLeft = 0
        EditLabel.ExplicitTop = -40
        EditLabel.ExplicitWidth = 186
        StyleElements = [seFont, seClient, seBorder]
        ExplicitHeight = 45
      end
      inherited cbRequireParams: TCheckListBox
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited leFunctionGetterUnitName: TLabeledEdit
        Height = 45
        EditLabel.ExplicitLeft = 0
        EditLabel.ExplicitTop = -40
        EditLabel.ExplicitWidth = 318
        StyleElements = [seFont, seClient, seBorder]
        ExplicitHeight = 45
      end
    end
    inherited GroupBox1: TGroupBox
      Top = 615
      Width = 1386
      ExplicitTop = 615
      ExplicitWidth = 1386
      inherited PageControl1: TPageControl
        Width = 1382
        ExplicitWidth = 1382
        inherited TabSheet1: TTabSheet
          inherited memSource: TMemo
            Width = 1362
            StyleElements = [seFont, seClient, seBorder]
            ExplicitWidth = 1362
          end
        end
        inherited TabSheet2: TTabSheet
          ExplicitWidth = 1362
          inherited memGetMethodUnit: TMemo
            Width = 1362
            StyleElements = [seFont, seClient, seBorder]
            ExplicitWidth = 1362
          end
        end
      end
    end
  end
end
