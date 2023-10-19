unit UnitTreinoDetalhe;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox;

type
  TFrmTreinoDetalhe = class(TForm)
    LytToolbar: TLayout;
    LblTitulo: TLabel;
    ImgFechar: TImage;
    Label7: TLabel;
    LbExercicios: TListBox;
    RectBtnIniciar: TRectangle;
    BtnIniciar: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure ImgFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnIniciarClick(Sender: TObject);
    procedure LbExerciciosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
  private
    Fid_treino: integer;
    Ftreino: string;
    procedure AddExercicio(id_exercicio: integer; titulo, subtitulo: string);
    procedure CarregarExercicios;
    { Private declarations }
  public
    property id_treino: integer read Fid_treino write Fid_treino;
    property treino: string read Ftreino write Ftreino;
    { Public declarations }
  end;

var
  FrmTreinoDetalhe: TFrmTreinoDetalhe;

implementation

{$R *.fmx}

uses Frame.Treino, UnitTreinoCad, UnitExercicio, DataModule.Global;

procedure TFrmTreinoDetalhe.AddExercicio(id_exercicio: integer;
  titulo, subtitulo: string);
var
  item: TListBoxItem;
  frame: TFrameTreino;
begin
  item := TListBoxItem.Create(LbExercicios);
  item.Selectable := False;
  item.Text := '';
  item.Height := 90;
  item.Tag := id_exercicio;

  //Frame
  frame := TFrameTreino.Create(item);
  frame.LblTitulo.Text := titulo;
  frame.LblSubtitulo.Text := subtitulo;

  item.AddObject(frame);

  LbExercicios.AddObject(item);
end;

procedure TFrmTreinoDetalhe.BtnIniciarClick(Sender: TObject);
begin
  try
    DmGlobal.IniciarTreino(Fid_treino);

    if not Assigned(FrmTreinoCad) then
      Application.CreateForm(TFrmTreinoCad, FrmTreinoCad);

    FrmTreinoCad.id_treino := Fid_treino;
    FrmTreinoCad.treino := Ftreino;
    FrmTreinoCad.Show;
  except on E: Exception do
    ShowMessage(E.Message);
  end;
end;

procedure TFrmTreinoDetalhe.CarregarExercicios;
begin
  LbExercicios.Items.Clear;

  DmGlobal.ListarExercicios(Fid_treino);

  with DmGlobal.qryConsExercicio do
  begin
    while not Eof do
    begin
      AddExercicio(FieldByName('id_exercicio').AsInteger,
        FieldByName('exercicio').AsString,
        FieldByName('duracao').AsString);
      Next;
    end;
  end;
end;

procedure TFrmTreinoDetalhe.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  FrmTreinoDetalhe := nil;
end;

procedure TFrmTreinoDetalhe.FormShow(Sender: TObject);
begin
  LblTitulo.Text := Ftreino;

  CarregarExercicios;
end;

procedure TFrmTreinoDetalhe.ImgFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmTreinoDetalhe.LbExerciciosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  if not Assigned(FrmExercicio) then
    Application.CreateForm(TFrmExercicio, FrmExercicio);

  FrmExercicio.id_exercicio := Item.Tag;
  FrmExercicio.Show;
end;

end.
