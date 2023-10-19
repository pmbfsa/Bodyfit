unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, uLoading,
  uSession, System.DateUtils;

type
  TFrmPrincipal = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    LblNome: TLabel;
    ImgPerfil: TImage;
    Layout2: TLayout;
    RectDashTreino: TRectangle;
    RectFundoTreino: TRectangle;
    RectBarraTreino: TRectangle;
    Layout3: TLayout;
    Label3: TLabel;
    Image2: TImage;
    LblQtdTreino: TLabel;
    Rectangle3: TRectangle;
    RectFundoPontos: TRectangle;
    RectBarraPontos: TRectangle;
    Layout4: TLayout;
    Label5: TLabel;
    Image3: TImage;
    LblPontos: TLabel;
    Label7: TLabel;
    RectSugestao: TRectangle;
    LblSugestao: TLabel;
    ImgSugestao: TImage;
    Label9: TLabel;
    LbTreinos: TListBox;
    ImgRefresh: TImage;
    procedure FormShow(Sender: TObject);
    procedure LbTreinosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure ImgPerfilClick(Sender: TObject);
    procedure RectSugestaoClick(Sender: TObject);
    procedure ImgRefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure CarregarTreinos;
    procedure AddTreino(id_treino: integer; titulo, subtitulo: string);
    procedure SincronizarTreinos;
    procedure ThreadSicronizarTerminate(Sender: TObject);
    procedure MontarDashboard;
    procedure MontarBarraProgresso;
    procedure MontarTreinoSugerido;
    procedure ThreadDashboardTerminate(Sender: TObject);
    procedure DetalhesTreino(id_treino: integer; treino: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses Frame.Treino, UnitTreinoDetalhe, UnitPerfil, DataModule.Global;

procedure TFrmPrincipal.AddTreino(id_treino: integer;
  titulo, subtitulo: string);
var
  item: TListBoxItem;
  frame: TFrameTreino;
begin
  item := TListBoxItem.Create(LbTreinos);
  item.Selectable := False;
  item.Text := '';
  item.Height := 90;
  item.Tag := id_treino;
  item.TagString := titulo;

  //Frame
  frame := TFrameTreino.Create(item);
  frame.LblTitulo.Text := titulo;
  frame.LblSubtitulo.Text := subtitulo;

  item.AddObject(frame);

  LbTreinos.AddObject(item);
end;

procedure TFrmPrincipal.CarregarTreinos;
begin
  LbTreinos.Items.Clear;

  DmGlobal.ListarTreinos;

  with DmGlobal.qryConsTreino do
  begin
    while not Eof do
    begin
      AddTreino(FieldByName('id_treino').AsInteger,
        FieldByName('treino').AsString,
        FieldByName('descr_treino').AsString);
      Next;
    end;
  end;
end;

procedure TFrmPrincipal.DetalhesTreino(id_treino: integer; treino: string);
begin
  if not Assigned(FrmTreinoDetalhe) then
    Application.CreateForm(TFrmTreinoDetalhe, FrmTreinoDetalhe);

  FrmTreinoDetalhe.id_treino := id_treino;
  FrmTreinoDetalhe.treino := treino;
  FrmTreinoDetalhe.Show;
end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmPrincipal := nil;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  LblNome.Text := TSession.NOME;

  SincronizarTreinos;
end;

procedure TFrmPrincipal.ImgPerfilClick(Sender: TObject);
begin
  if not Assigned(FrmPerfil) then
    Application.CreateForm(TFrmPerfil, FrmPerfil);

  FrmPerfil.Show;
end;

procedure TFrmPrincipal.ImgRefreshClick(Sender: TObject);
begin
  MontarDashboard;
end;

procedure TFrmPrincipal.LbTreinosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  DetalhesTreino(Item.Tag, Item.TagString);
end;

procedure TFrmPrincipal.MontarBarraProgresso;
begin
  RectBarraTreino.Width := RectFundoTreino.Width * LblQtdTreino.Text.ToInteger / DaysInMonth(now);
  RectBarraPontos.Width := RectFundoPontos.Width * LblPontos.Text.ToInteger / 1000;
end;

procedure TFrmPrincipal.MontarDashboard;
var
  t: TThread;
begin
  TLoading.Show(FrmPrincipal, '');

  t := TThread.CreateAnonymousThread(procedure
  var
    qtd_treino, pontos: integer;
  begin
    qtd_treino := DmGlobal.TreinosMes(now);
    pontos := DmGlobal.Pontuacao;

    DmGlobal.TreinoSugerido(now);

    TThread.Synchronize(TThread.CurrentThread, procedure
    begin
      LblQtdTreino.Text := qtd_treino.ToString;
      LblPontos.Text := pontos.ToString;

      MontarBarraProgresso;
      MontarTreinoSugerido;
    end);
  end);

  t.OnTerminate := ThreadDashboardTerminate;
  t.Start;
end;

procedure TFrmPrincipal.MontarTreinoSugerido;
begin
  with DmGlobal.qryConsEstatistica do
  begin
    if RecordCount = 0 then
    begin
      LblSugestao.Text := 'Nenhuma Sugestão';
      ImgSugestao.Visible := False;
      RectSugestao.Tag := 0;
    end
    else
    begin
      LblSugestao.Text := FieldByName('descr_treino').AsString;
      ImgSugestao.Visible := True;
      RectSugestao.Tag := FieldByName('id_treino').AsInteger;
    end;
  end;
end;

procedure TFrmPrincipal.RectSugestaoClick(Sender: TObject);
begin
  if RectSugestao.Tag > 0 then
    DetalhesTreino(RectSugestao.Tag, LblSugestao.Text);
end;

procedure TFrmPrincipal.SincronizarTreinos;
var
  t: TThread;
begin
  TLoading.Show(FrmPrincipal, '');

  t := TThread.CreateAnonymousThread(procedure
  begin
    DmGlobal.ListarTreinoExercicioOnline(TSession.ID_USUARIO);

    with DmGlobal.TabTreino do
    begin
      if RecordCount > 0 then
        DmGlobal.ExcluirTreinoExercicio;

      while not Eof do
      begin
        DmGlobal.InserirTreinoExercicio(
          FieldByName('id_treino').AsInteger,
          FieldByName('treino').AsString,
          FieldByName('descr_treino').AsString,
          FieldByName('dia_semana').AsInteger,
          FieldByName('id_exercicio').AsInteger,
          FieldByName('exercicio').AsString,
          FieldByName('descr_exercicio').AsString,
          FieldByName('duracao').AsString,
          FieldByName('url_video').AsString);
        Next;
      end;
    end;
  end);

  t.OnTerminate := ThreadSicronizarTerminate;
  t.Start;
end;

procedure TFrmPrincipal.ThreadDashboardTerminate(Sender: TObject);
begin
  TLoading.Hide;

  CarregarTreinos;
end;

procedure TFrmPrincipal.ThreadSicronizarTerminate(Sender: TObject);
begin
  TLoading.Hide;

  MontarDashboard;
end;

end.
