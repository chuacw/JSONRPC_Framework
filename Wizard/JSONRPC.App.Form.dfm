object FormInterfaceGeneration: TFormInterfaceGeneration
  Left = 71
  Top = 18
  Margins.Left = 7
  Margins.Top = 7
  Margins.Right = 7
  Margins.Bottom = 7
  Caption = 'Interface generation'
  ClientHeight = 1298
  ClientWidth = 1419
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
    Width = 1419
    Height = 1298
    Margins.Left = 7
    Margins.Top = 7
    Margins.Right = 7
    Margins.Bottom = 7
    Align = alClient
    Constraints.MinHeight = 990
    Constraints.MinWidth = 1419
    TabOrder = 0
    ExplicitHeight = 1298
    inherited pnlOptions: TPanel
      ExplicitWidth = 1419
    end
    inherited GroupBox1: TGroupBox
      Top = 927
      ExplicitTop = 927
      ExplicitWidth = 1419
      inherited PageControl1: TPageControl
        inherited TabSheet1: TTabSheet
          inherited memSource: TMemo
            Width = 1416
            Height = 571
            ExplicitWidth = 1416
            ExplicitHeight = 571
          end
        end
        inherited TabSheet2: TTabSheet
          inherited memGetMethodUnit: TMemo
            ExplicitWidth = 1395
          end
        end
      end
    end
  end
end
