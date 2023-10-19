unit UnitPerfilCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit;

type
  TFrmPerfilCad = class(TForm)
    LytToolbar: TLayout;
    LblTitulo: TLabel;
    ImgFechar: TImage;
    Rectangle1: TRectangle;
    EdtNome: TEdit;
    EdtEmail: TEdit;
    RectBtnSalvar: TRectangle;
    BtnSalvar: TSpeedButton;
    procedure ImgFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPerfilCad: TFrmPerfilCad;

implementation

{$R *.fmx}

uses DataModule.Global, uSession, UnitPrincipal;

procedure TFrmPerfilCad.BtnSalvarClick(Sender: TObject);
begin
  try
    DmGlobal.EditarUsuarioOnline(TSession.ID_USUARIO, EdtNome.Text, EdtEmail.Text);
    DmGlobal.EditarUsuario(EdtNome.Text, EdtEmail.Text);

    TSession.NOME := EdtNome.Text;
    TSession.EMAIL := EdtEmail.Text;

    FrmPrincipal.LblNome.Text := EdtNome.Text;

    Close;
  except
    on E: Exception do
      ShowMessage('Erro ao salvar os dados do usuário: ' + E.Message);
  end;
end;

procedure TFrmPerfilCad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmPerfilCad := nil;
end;

procedure TFrmPerfilCad.FormShow(Sender: TObject);
begin
  try
    DmGlobal.ListarUsuario;

    EdtNome.Text := DmGlobal.qryUsuario.FieldByName('nome').AsString;
    EdtEmail.Text := DmGlobal.qryUsuario.FieldByName('email').AsString;
  except
    on E: Exception do
      ShowMessage('Erro ao carregar os dados do usuário: ' + E.Message);
  end;
end;

procedure TFrmPerfilCad.ImgFecharClick(Sender: TObject);
begin
  Close;
end;

end.
