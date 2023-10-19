unit UnitTreinoCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.ListBox,
  UnitExercicio, FMX.Ani;

type
  TFrmTreinoCad = class(TForm)
    LytToolbar: TLayout;
    LblTitulo: TLabel;
    ImgFechar: TImage;
    Layout1: TLayout;
    LblProgresso: TLabel;
    RectFundoBarra: TRectangle;
    RectBarra: TRectangle;
    RectBtnConcluir: TRectangle;
    BtnConcluir: TSpeedButton;
    LbExercicios: TListBox;
    procedure FormShow(Sender: TObject);
    procedure ImgFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LbExerciciosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure BtnConcluirClick(Sender: TObject);
  private
    { Private declarations }
    Fid_treino: integer;
    Ftreino: string;
    procedure AddExercicio(id_exercicio: integer; titulo, subtitulo: string;
      ind_concluido: Boolean);
    procedure CarregarExercicios;
    function StringToBoolean(str: string): boolean;
  public
    { Public declarations }
    property id_treino: integer read Fid_treino write Fid_treino;
    property treino: string read Ftreino write Ftreino;
    procedure CalcularProgresso;
  end;

var
  FrmTreinoCad: TFrmTreinoCad;

implementation

{$R *.fmx}

uses Frame.FichaExercicio, DataModule.Global, UnitTreinoDetalhe;

procedure TFrmTreinoCad.AddExercicio(id_exercicio: integer;
  titulo, subtitulo: string; ind_concluido: Boolean);
var
  item: TListBoxItem;
  frame: TFrameFichaExercicio;
begin
  item := TListBoxItem.Create(LbExercicios);
  item.Selectable := False;
  item.Text := '';
  item.Width := Trunc(LbExercicios.Width * 0.85);
  item.Tag := id_exercicio;

  //Frame
  frame := TFrameFichaExercicio.Create(item);
  frame.LblTitulo.Text := titulo;
  frame.LblSubtitulo.Text := subtitulo;
  frame.ChkConcluido.Tag := id_exercicio;

  item.AddObject(frame);

  LbExercicios.AddObject(item);
end;

procedure TFrmTreinoCad.BtnConcluirClick(Sender: TObject);
begin
  DmGlobal.FinalizarTreino(Fid_treino);

  FrmTreinoDetalhe.Close;
  Close;
end;

procedure TFrmTreinoCad.CalcularProgresso;
var
  frame: TFrameFichaExercicio;
  i, qtd_concluido: integer;
begin
  qtd_concluido := 0;

  for i := 0 to LbExercicios.Items.Count - 1 do
  begin
    frame := LbExercicios.ItemByIndex(i).Components[0] as TFrameFichaExercicio;

    if frame.ChkConcluido.IsChecked then
      Inc(qtd_concluido);
  end;

  LblProgresso.Text := qtd_concluido.ToString + ' de ' + LbExercicios.Items.Count.ToString + ' concluídos';

  TAnimator.AnimateFloat(RectBarra, 'Width',
    qtd_concluido / LbExercicios.Items.Count * RectFundoBarra.Width, 0.5,
    TAnimationType.Out, TInterpolationType.Circular);
end;

procedure TFrmTreinoCad.CarregarExercicios;
begin
  LbExercicios.Items.Clear;
  DmGlobal.ListarExerciciosAtividade;

  with DmGlobal.qryConsExercicio do
  begin
    while not Eof do
    begin
      AddExercicio(FieldByName('id_exercicio').AsInteger,
        FieldByName('exercicio').AsString,
        FieldByName('duracao').AsString,
        StringToBoolean(FieldByName('ind_concluido').AsString));
      Next;
    end;
  end;

  CalcularProgresso;
end;

procedure TFrmTreinoCad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmTreinoCad := nil;
end;

procedure TFrmTreinoCad.FormShow(Sender: TObject);
begin
  LblTitulo.Text := Ftreino;

  CarregarExercicios;
end;

procedure TFrmTreinoCad.ImgFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmTreinoCad.LbExerciciosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  if not Assigned(FrmExercicio) then
    Application.CreateForm(TFrmExercicio, FrmExercicio);

  FrmExercicio.id_exercicio := Item.Tag;
  FrmExercicio.Show;
end;

function TFrmTreinoCad.StringToBoolean(str: string): boolean;
begin
  if str = 'S' then
    Result := True
  else
    Result := False;
end;

end.
