unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase, DataSet.Serialize.Config, IniFiles, System.JSON,
  FireDAC.DApt, DataSet.Serialize, FireDAC.Stan.Param;

type
  TDmGlobal = class(TDataModule)
    Conn: TFDConnection;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    function Login(const email, senha: string): TJSONObject;
    function CriarConta(const nome, email, senha: string): TJSONObject;
    function EditarUsuario(id_usuario: Integer; const nome,
      email: string): TJSONObject;
    function EditarSenha(id_usuario: Integer; const senha: string): TJSONObject;
    function ListarTreinos(id_usuario: integer): TJSONArray;
    { Public declarations }
  end;

var
  DmGlobal: TDmGlobal;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.ConnBeforeConnect(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    TFDConnection(Sender).DriverName := Ini.ReadString('Conexao', 'DriverName', 'FB');

    with TFDConnection(Sender).Params do
    begin
      Clear;
      Add('DriverID=' + Ini.ReadString('Conexao', 'DriverID', 'FB'));
      Add('Database=' + Ini.ReadString('Conexao', 'Database', ''));
      Add('User_Name=' + Ini.ReadString('Conexao', 'User_Name', 'SYSDBA'));
      Add('Password=' + Ini.ReadString('Conexao', 'Password', 'masterkey'));
      Add('Port=' + Ini.ReadString('Conexao', 'Port', '3000'));
      Add('Server=' + Ini.ReadString('Conexao', 'Server', 'localhost'));
      Add('Protocol=' + Ini.ReadString('Conexao', 'Protocol', 'TCPIP'));
    end;

    FDPhysFBDriverLink.VendorLib := Ini.ReadString('Conexao', 'VendorLib', '');
  finally
    Ini.Free;
  end;
end;

function TDmGlobal.CriarConta(const nome, email, senha: string): TJSONObject;
begin
  if (nome = '') or (email = '') or (senha = '') then
    raise Exception.Create('Informe o nome, o e-mail e a senha.');

  with TFDQuery.Create(nil) do
  try
    Connection := Conn;
    Active := False;

    SQL.Clear;
    SQL.Add('insert into tab_usuario(nome, email, senha)');
    SQL.Add('values(:nome, :email, :senha)');
    SQL.Add('returning id_usuario, nome, email');

    ParamByName('nome').AsString := nome;
    ParamByName('email').AsString := email;
    ParamByName('senha').AsString := senha;

    Active := True;

    Result := ToJSONObject;
  finally
    Free;
  end;
end;

procedure TDmGlobal.DataModuleCreate(Sender: TObject);
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
  TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';

  Conn.Connected := True;
end;

function TDmGlobal.EditarSenha(id_usuario: Integer;
  const senha: string): TJSONObject;
begin
  if (id_usuario <= 0) or (senha = '') then
    raise Exception.Create('Informe o usuário e a senha.');

  with TFDQuery.Create(nil) do
  try
    Connection := Conn;
    Active := False;

    SQL.Clear;
    SQL.Add('update tab_usuario set senha = :senha');
    SQL.Add('where id_usuario = :id_usuario');
    SQL.Add('returning id_usuario');

    ParamByName('id_usuario').AsInteger := id_usuario;
    ParamByName('senha').AsString := senha;

    Active := True;

    Result := ToJSONObject;
  finally
    Free;
  end;
end;

function TDmGlobal.EditarUsuario(id_usuario: Integer; const nome,
  email: string): TJSONObject;
begin
  if (id_usuario <= 0) or (nome = '') or (email = '') then
    raise Exception.Create('Informe o usuário, o nome e o e-mail.');

  with TFDQuery.Create(nil) do
  try
    Connection := Conn;
    Active := False;

    SQL.Clear;
    SQL.Add('update tab_usuario set nome = :nome, email = :email');
    SQL.Add('where id_usuario = :id_usuario');
    SQL.Add('returning id_usuario');

    ParamByName('id_usuario').AsInteger := id_usuario;
    ParamByName('nome').AsString := nome;
    ParamByName('email').AsString := email;

    Active := True;

    Result := ToJSONObject;
  finally
    Free;
  end;
end;

function TDmGlobal.ListarTreinos(id_usuario: Integer): TJSONArray;
begin
  if (id_usuario <= 0) then
    raise Exception.Create('Informe o usuário.');

  with TFDQuery.Create(nil) do
  try
    Connection := Conn;
    Active := False;

    SQL.Clear;
    SQL.Add('select t.id_treino, t.nome treino, t.descricao descr_treino, t.dia_semana,');
    SQL.Add('       te.duracao, e.id_exercicio, e.nome exercicio,');
    SQL.Add('       e.descricao descr_exercicio, e.url_video');
    SQL.Add('from tab_treino t');
    SQL.Add('join tab_treino_exercicio te on (te.id_treino = t.id_treino)');
    SQL.Add('join tab_exercicio e on (e.id_exercicio = te.id_exercicio)');
    SQL.Add('where t.id_usuario = :id_usuario');
    SQL.Add('order by t.dia_semana, e.nome');

    ParamByName('id_usuario').AsInteger := id_usuario;

    Active := True;

    Result := ToJSONArray;
  finally
    Free;
  end;
end;

function TDmGlobal.Login(const email, senha: string): TJSONObject;
begin
  if (email = '') or (senha = '') then
    raise Exception.Create('Informe o e-mail e a senha.');

  with TFDQuery.Create(nil) do
  try
    Connection := Conn;
    Active := False;

    SQL.Clear;
    SQL.Add('select id_usuario, nome, email');
    SQL.Add('from tab_usuario');
    SQL.Add('where email = :email and senha = :senha');

    ParamByName('email').AsString := email;
    ParamByName('senha').AsString := senha;

    Active := True;

    Result := ToJSONObject;
  finally
    Free;
  end;
end;

end.
