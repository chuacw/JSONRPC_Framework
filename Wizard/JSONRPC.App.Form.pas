unit JSONRPC.App.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  JSONRPC.App.Wizard;

type
  TFormInterfaceGeneration = class(TForm)
    frmWizard: TfrmWizard;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormInterfaceGeneration: TFormInterfaceGeneration;

implementation

{$R *.dfm}

procedure TFormInterfaceGeneration.FormCreate(Sender: TObject);
begin
  frmWizard.frameCreate;
end;

end.
