unit UnitPerfilSenha;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrmPerfilSenha = class(TForm)
    LytToolbar: TLayout;
    LblTitulo: TLabel;
    ImgFechar: TImage;
    Rectangle1: TRectangle;
    EdtSenha: TEdit;
    EdtSenha2: TEdit;
    RectBtnSalvar: TRectangle;
    BtnSalvar: TSpeedButton;
    procedure ImgFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPerfilSenha: TFrmPerfilSenha;

implementation

{$R *.fmx}

uses DataModule.Global, uSession;

procedure TFrmPerfilSenha.BtnSalvarClick(Sender: TObject);
begin
  if EdtSenha.Text <> EdtSenha2.Text then
  begin
    ShowMessage('A senhas não conferem. Digite novamente.');
    Exit;
  end;

  try
    DmGlobal.EditarSenhaOnline(TSession.ID_USUARIO, EdtSenha.Text);
    Close;
  except
    on E: Exception do
      ShowMessage('Erro ao alterar a senha: ' + E.Message);
  end;
end;

procedure TFrmPerfilSenha.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmPerfilSenha := nil;
end;

procedure TFrmPerfilSenha.ImgFecharClick(Sender: TObject);
begin
  Close;
end;

end.
