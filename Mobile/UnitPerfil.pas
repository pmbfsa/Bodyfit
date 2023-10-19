unit UnitPerfil;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

type
  TFrmPerfil = class(TForm)
    LytToolbar: TLayout;
    LblTitulo: TLabel;
    ImgFechar: TImage;
    RectPerfil: TRectangle;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    RectDesconectar: TRectangle;
    Image3: TImage;
    Image4: TImage;
    Label2: TLabel;
    RectSenha: TRectangle;
    Image5: TImage;
    Image6: TImage;
    Label3: TLabel;
    Label4: TLabel;
    procedure ImgFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RectPerfilClick(Sender: TObject);
    procedure RectSenhaClick(Sender: TObject);
    procedure RectDesconectarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPerfil: TFrmPerfil;

implementation

{$R *.fmx}

uses UnitPerfilCad, UnitPerfilSenha, DataModule.Global, UnitLogin,
  UnitPrincipal;

procedure TFrmPerfil.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmPerfil := nil;
end;

procedure TFrmPerfil.ImgFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPerfil.RectDesconectarClick(Sender: TObject);
begin
  try
    DmGlobal.Logout;

    if not Assigned(FrmLogin) then
      Application.CreateForm(TFrmLogin, FrmLogin);

    Application.MainForm := FrmLogin;
    FrmLogin.Show;

    FrmPrincipal.Close;
    FrmPerfil.Close;
  except
    on E: Exception do
      ShowMessage('Erro ao desconectar: ' + E.Message);
  end;
end;

procedure TFrmPerfil.RectPerfilClick(Sender: TObject);
begin
  if not Assigned(FrmPerfilCad) then
    Application.CreateForm(TFrmPerfilCad, FrmPerfilCad);

  FrmPerfilCad.Show;
end;

procedure TFrmPerfil.RectSenhaClick(Sender: TObject);
begin
  if not Assigned(FrmPerfilSenha) then
    Application.CreateForm(TFrmPerfilSenha, FrmPerfilSenha);

  FrmPerfilSenha.Show;
end;

end.
