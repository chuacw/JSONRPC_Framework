{---------------------------------------------------------------------------}
{                                                                           }
{ File:      JSONRPC.AppWizard.dpr                                          }
{ Function:  JSON RPC wizard                                                }
{                                                                           }
{ Language:   Delphi version XE11 or later                                  }
{ Author:     Chee-Wee Chua                                                 }
{ Copyright:  (c) 2023,2024 Chee-Wee Chua                                   }
{---------------------------------------------------------------------------}
program JSONRPC.AppWizard;

uses
  Vcl.Forms,
  System.Net.URLClient,
  JSONRPC.App.Form in 'JSONRPC.App.Form.pas' {FormInterfaceGeneration},
  JSONRPC.App.Wizard in 'JSONRPC.App.Wizard.pas' {frmWizard: TFrame},
  JSONRPC.Wizard.Consts in 'JSONRPC.Wizard.Consts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormInterfaceGeneration, FormInterfaceGeneration);
  Application.Run;
end.
