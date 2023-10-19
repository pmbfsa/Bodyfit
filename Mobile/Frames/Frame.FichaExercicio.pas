unit Frame.FichaExercicio;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation;

type
  TFrameFichaExercicio = class(TFrame)
    RectSugerido: TRectangle;
    LblTitulo: TLabel;
    Image4: TImage;
    LblSubtitulo: TLabel;
    Rectangle1: TRectangle;
    ChkConcluido: TCheckBox;
    procedure ChkConcluidoChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses DataModule.Global, UnitTreinoCad;

procedure TFrameFichaExercicio.ChkConcluidoChange(Sender: TObject);
begin
  DmGlobal.MarcarExercicioConluido(ChkConcluido.Tag, ChkConcluido.IsChecked);

  FrmTreinoCad.CalcularProgresso;
end;

end.
