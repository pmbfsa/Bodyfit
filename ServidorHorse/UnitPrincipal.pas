unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TFrmPrincipal = class(TForm)
    Memo: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses
  Horse, Horse.Jhonson, Horse.BasicAuthentication, Horse.CORS,
  DataSet.Serialize.Config, Controller.Global;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  THorse.Use(Jhonson);
  THorse.Use(CORS);
  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      // Here inside you can access your database and validate if username and password are valid
      Result := AUsername.Equals('99coders') and APassword.Equals('112233');
    end));

  //Registro das rotas...
  Controller.Global.RegistrarRotas;

  //Subir a aplicação...
  THorse.Listen(3000,
    procedure(Horse: THorse)
    begin
      Memo.Lines.Add('Servidor online na porta 3000');
    end);
end;

end.
