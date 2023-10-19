unit UnitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.TabControl, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit,
  uLoading, uSession;

type
  TFrmLogin = class(TForm)
    Layout1: TLayout;
    Image1: TImage;
    TabControl: TTabControl;
    TabLogin: TTabItem;
    TabConta: TTabItem;
    RectLogin: TRectangle;
    Rectangle1: TRectangle;
    EdtEmail: TEdit;
    EdtSenha: TEdit;
    RectBtnLogin: TRectangle;
    BtnLogin: TSpeedButton;
    LblConta: TLabel;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    EdtContaEmail: TEdit;
    EdtContaSenha: TEdit;
    Rectangle4: TRectangle;
    BtnConta: TSpeedButton;
    LblLogin: TLabel;
    EdtContaNome: TEdit;
    procedure BtnLoginClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnContaClick(Sender: TObject);
    procedure LblLoginClick(Sender: TObject);
    procedure LblContaClick(Sender: TObject);
  private
    procedure ThreadLoginTerminate(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.fmx}

uses UnitPrincipal, DataModule.Global;
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TFrmLogin.BtnContaClick(Sender: TObject);
var
  t: TThread;
begin
  TLoading.Show(FrmLogin, '');

  t := TThread.CreateAnonymousThread(procedure
  begin
    DmGlobal.CriarContaOnline(EdtContaNome.Text, EdtContaEmail.Text,
      EdtContaSenha.Text);

    with DmGlobal.TabUsuario do
    begin
      DmGlobal.InserirUsuario(
        FieldByName('id_usuario').AsInteger,
        FieldByName('nome').AsString,
        FieldByName('email').AsString);

      TSession.ID_USUARIO := FieldByName('id_usuario').AsInteger;
      TSession.NOME := FieldByName('nome').AsString;
      TSession.EMAIL := FieldByName('email').AsString;
    end;
  end);

  t.OnTerminate := ThreadLoginTerminate;
  t.Start;
end;

procedure TFrmLogin.BtnLoginClick(Sender: TObject);
var
  t: TThread;
begin
  TLoading.Show(FrmLogin, '');

  t := TThread.CreateAnonymousThread(procedure
  begin
    DmGlobal.LoginOnline(EdtEmail.Text, EdtSenha.Text);

    with DmGlobal.TabUsuario do
    begin
      DmGlobal.InserirUsuario(
        FieldByName('id_usuario').AsInteger,
        FieldByName('nome').AsString,
        FieldByName('email').AsString);

      TSession.ID_USUARIO := FieldByName('id_usuario').AsInteger;
      TSession.NOME := FieldByName('nome').AsString;
      TSession.EMAIL := FieldByName('email').AsString;
    end;
  end);

  t.OnTerminate := ThreadLoginTerminate;
  t.Start;
end;

procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmLogin := nil;
end;

procedure TFrmLogin.LblContaClick(Sender: TObject);
begin
  TabControl.GotoVisibleTab(1);
end;

procedure TFrmLogin.LblLoginClick(Sender: TObject);
begin
  TabControl.GotoVisibleTab(0);
end;

procedure TFrmLogin.ThreadLoginTerminate(Sender: TObject);
begin
  TLoading.Hide;

  if Sender is TThread and Assigned(TThread(Sender).FatalException) then
  begin
    ShowMessage(Exception(TThread(Sender).FatalException).Message);
    Exit;
  end;

  if not Assigned(FrmPrincipal) then
    Application.CreateForm(TFrmPrincipal, FrmPrincipal);

  Application.MainForm := FrmPrincipal;
  FrmPrincipal.Show;
  FrmLogin.Close;
end;

end.
