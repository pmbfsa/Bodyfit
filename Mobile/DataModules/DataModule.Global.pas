unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, DataSet.Serialize.Config, System.IOUtils,
  System.DateUtils, System.JSON, RESTRequest4D, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.DApt,
  System.StrUtils;

type
  TDmGlobal = class(TDataModule)
    Conn: TFDConnection;
    TabUsuario: TFDMemTable;
    qryUsuario: TFDQuery;
    TabTreino: TFDMemTable;
    qryTreinoExercicio: TFDQuery;
    qryConsEstatistica: TFDQuery;
    qryConsTreino: TFDQuery;
    qryConsExercicio: TFDQuery;
    qryAtividade: TFDQuery;
    qryGeral: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoginOnline(email, senha: string);
    procedure CriarContaOnline(nome, email, senha: string);
    procedure InserirUsuario(id_usuario: integer; nome, email: string);
    procedure ListarTreinoExercicioOnline(id_usuario: integer);
    procedure ExcluirTreinoExercicio;
    procedure InserirTreinoExercicio(id_treino: integer; treino,
      descr_treino: string; dia_semana, id_exercicio: integer; exercicio,
      descr_exercicio, duracao, url_video: string);
    function TreinosMes(dt: TDateTime): integer;
    function Pontuacao: integer;
    procedure TreinoSugerido(dt: TDateTime);
    procedure ListarTreinos;
    procedure ListarExercicios(id_treino: integer);
    procedure DetalheExercicio(id_exercicio: integer);
    procedure IniciarTreino(id_treino: integer);
    procedure ListarExerciciosAtividade;
    procedure FinalizarTreino(id_treino: integer);
    procedure MarcarExercicioConluido(id_treino: integer;
      ind_concluido: boolean);
    procedure ListarUsuario;
    procedure EditarUsuario(nome, email: string);
    procedure EditarUsuarioOnline(id_usuario: integer; nome, email: string);
    procedure EditarSenhaOnline(id_usuario: integer; senha: string);
    procedure Logout;
  end;

var
  DmGlobal: TDmGlobal;

const
//  BASE_URL = 'http://localhost:3000';
  BASE_URL = 'http://192.168.68.102:3000';

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.ConnAfterConnect(Sender: TObject);
begin
  //Dados do usuário
  Conn.ExecSQL(' CREATE TABLE IF NOT EXISTS TAB_USUARIO(' +
               '   ID_USUARIO INTEGER NOT NULL PRIMARY KEY,' +
               '   NOME       VARCHAR(100),' +
               '   EMAIL      VARCHAR(100),' +
               '   PONTOS     INTEGER);');

  //Todos os treinos e recebidos do servidor
  Conn.ExecSQL(' CREATE TABLE IF NOT EXISTS TAB_TREINO_EXERCICIO(' +
               '   ID_TREINO_EXERCICIO INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,' +
               '   ID_TREINO           INTEGER,' +
               '   TREINO              VARCHAR(100),' +
               '   DESCR_TREINO        VARCHAR(100),' +
               '   DIA_SEMANA          INTEGER,' +
               '   ID_EXERCICIO        INTEGER,' +
               '   EXERCICIO           VARCHAR(100),' +
               '   DESCR_EXERCICIO     VARCHAR(1000),' +
               '   DURACAO             VARCHAR(100),' +
               '   URL_VIDEO           VARCHAR(1000));');

  //Treinos finalizados
  Conn.ExecSQL(' CREATE TABLE IF NOT EXISTS TAB_ATIVIDADE_HISTORICO(' +
               '   ID_HISTORICO INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,' +
               '   ID_TREINO    INTEGER,' +
               '   DT_ATIVIDADE DATETIME);');

  //Treino em andamento
  Conn.ExecSQL(' CREATE TABLE IF NOT EXISTS TAB_ATIVIDADE(' +
               '   ID_ATIVIDADE  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,' +
               '   ID_TREINO     INTEGER,' +
               '   ID_EXERCICIO  INTEGER,' +
               '   EXERCICIO     VARCHAR(100),' +
               '   DURACAO       VARCHAR(100),' +
               '   IND_CONCLUIDO CHAR(1));');
end;

procedure TDmGlobal.ConnBeforeConnect(Sender: TObject);
begin
  Conn.DriverName := 'SQLite';

  {$IFDEF MSWINDOWS}
  Conn.Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\banco.db';
  {$ELSE}
  Conn.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'banco.db');
  {$ENDIF}
end;

procedure TDmGlobal.CriarContaOnline(nome, email, senha: string);
var
  resp: IResponse;
begin
  TabUsuario.FieldDefs.Clear;

  with TJSONObject.Create do
  try
    AddPair('nome', nome);
    AddPair('email', email);
    AddPair('senha', senha);

    resp := TRequest.New.BaseURL(BASE_URL)
      .Resource('usuarios/registro')
      .AddBody(ToJSON)
      .BasicAuthentication('99coders', '112233')
      .Accept('application/json')
      .DataSetAdapter(TabUsuario)
      .Post;

    if resp.StatusCode <> 201 then
      raise Exception.Create(resp.Content);
  finally
    DisposeOf;
  end;
end;

procedure TDmGlobal.DataModuleCreate(Sender: TObject);
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
  TDataSetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';

  Conn.Connected := True;
end;

procedure TDmGlobal.DetalheExercicio(id_exercicio: integer);
begin
  with qryConsExercicio do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select * from tab_treino_exercicio');
    SQL.Add('where id_exercicio = :id_exercicio');

    ParamByName('id_exercicio').AsInteger := id_exercicio;

    Active := True;
  end;
end;

procedure TDmGlobal.EditarSenhaOnline(id_usuario: integer; senha: string);
var
  resp: IResponse;
begin
  with TJSONObject.Create do
  try
    AddPair('id_usuario', TJSONNumber.Create(id_usuario));
    AddPair('senha', senha);

    resp := TRequest.New.BaseURL(BASE_URL)
      .Resource('usuarios/senha')
      .AddBody(ToJSON)
      .BasicAuthentication('99coders', '112233')
      .Accept('application/json')
      .Put;

    if resp.StatusCode <> 200 then
      raise Exception.Create(resp.Content);
  finally
    DisposeOf;
  end;
end;

procedure TDmGlobal.EditarUsuario(nome, email: string);
begin
  with qryUsuario do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('update tab_usuario set nome = :nome, email = :email');
    ParamByName('nome').AsString := nome;
    ParamByName('email').AsString := email;
    ExecSQL
  end;
end;

procedure TDmGlobal.EditarUsuarioOnline(id_usuario: integer; nome, email: string);
var
  resp: IResponse;
begin
  with TJSONObject.Create do
  try
    AddPair('id_usuario', TJSONNumber.Create(id_usuario));
    AddPair('nome', nome);
    AddPair('email', email);

    resp := TRequest.New.BaseURL(BASE_URL)
      .Resource('usuarios')
      .AddBody(ToJSON)
      .BasicAuthentication('99coders', '112233')
      .Accept('application/json')
      .Put;

    if resp.StatusCode <> 200 then
      raise Exception.Create(resp.Content);
  finally
    DisposeOf;
  end;
end;

procedure TDmGlobal.ExcluirTreinoExercicio;
begin
  Conn.ExecSQL('delete from tab_treino_exercicio');
end;

procedure TDmGlobal.FinalizarTreino(id_treino: integer);
begin
  with qryGeral do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('insert into tab_atividade_historico(id_treino, dt_atividade)');
    SQL.Add('values(:id_treino, :dt_atividade)');

    ParamByName('id_treino').AsInteger := id_treino;
    ParamByName('dt_atividade').AsString := FormatDateTime('yyyy-mm-dd', Now);

    ExecSQL;

    Active := False;
    SQL.Clear;
    SQL.Add('delete from tab_atividade');

    ExecSQL;

    Active := False;
    SQL.Clear;
    SQL.Add('update tab_usuario set pontos = ifnull(pontos, 0) + 10');

    ExecSQL;
  end;
end;

procedure TDmGlobal.IniciarTreino(id_treino: integer);
begin
  with qryAtividade do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('delete from tab_atividade');
    ExecSQL;

    Active := False;
    SQL.Clear;
    SQL.Add('insert into tab_atividade(id_treino, id_exercicio, exercicio, duracao, ind_concluido)');
    SQL.Add('select id_treino, id_exercicio, exercicio, duracao, ''N''');
    SQL.Add('from tab_treino_exercicio');
    SQL.Add('where id_treino = :id_treino');

    ParamByName('id_treino').AsInteger := id_treino;

    ExecSQL;
  end;
end;

procedure TDmGlobal.InserirTreinoExercicio(id_treino: integer; treino,
  descr_treino: string; dia_semana, id_exercicio: integer; exercicio,
  descr_exercicio, duracao, url_video: string);
begin
  with qryTreinoExercicio do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('insert into tab_treino_exercicio(id_treino, treino, descr_treino,');
    SQL.Add('  dia_semana, id_exercicio, exercicio, descr_exercicio, duracao,');
    SQL.Add('  url_video)');
    SQL.Add('values (:id_treino, :treino, :descr_treino, :dia_semana, :id_exercicio,');
    SQL.Add('  :exercicio, :descr_exercicio, :duracao, :url_video)');

    ParamByName('id_treino').AsInteger := id_treino;
    ParamByName('treino').AsString := treino;
    ParamByName('descr_treino').AsString := descr_treino;
    ParamByName('dia_semana').AsInteger := dia_semana;
    ParamByName('id_exercicio').AsInteger := id_exercicio;
    ParamByName('exercicio').AsString := exercicio;
    ParamByName('descr_exercicio').AsString := descr_exercicio;
    ParamByName('duracao').AsString := duracao;
    ParamByName('url_video').AsString := url_video;

    ExecSQL;
  end;
end;

procedure TDmGlobal.InserirUsuario(id_usuario: integer; nome, email: string);
begin
  with qryUsuario do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('delete from tab_usuario where id_usuario <> :id_usuario');
    ParamByName('id_usuario').AsInteger := id_usuario;
    ExecSQL;

    Active := False;
    SQL.Clear;
    SQL.Add('select * from tab_usuario');
    Active := True;

    if IsEmpty then
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('insert into tab_usuario(id_usuario, nome, email, pontos)');
      SQL.Add('values(:id_usuario, :nome, :email, 0)');
      ParamByName('id_usuario').AsInteger := id_usuario;
      ParamByName('nome').AsString := nome;
      ParamByName('email').AsString := email;
      ExecSQL;
    end
    else
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('update tab_usuario set nome = :nome, email = :email');
      ParamByName('nome').AsString := nome;
      ParamByName('email').AsString := email;
      ExecSQL;
    end;
  end;
end;

procedure TDmGlobal.ListarExercicios(id_treino: integer);
begin
  with qryConsExercicio do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select * from tab_treino_exercicio');
    SQL.Add('where id_treino = :id_treino');
    SQL.Add('order by exercicio');

    ParamByName('id_treino').AsInteger := id_treino;

    Active := True;
  end;
end;

procedure TDmGlobal.ListarExerciciosAtividade;
begin
  with qryConsExercicio do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select * from tab_atividade');
    SQL.Add('order by exercicio');
    Active := True;
  end;
end;

procedure TDmGlobal.ListarTreinoExercicioOnline(id_usuario: integer);
var
  resp: IResponse;
begin
  TabTreino.FieldDefs.Clear;

  resp := TRequest.New.BaseURL(BASE_URL)
    .Resource('treinos')
    .AddParam('id_usuario', id_usuario.ToString)
    .BasicAuthentication('99coders', '112233')
    .Accept('application/json')
    .DataSetAdapter(TabTreino)
    .Get;

  if resp.StatusCode <> 200 then
    raise Exception.Create(resp.Content);
end;

procedure TDmGlobal.ListarTreinos;
begin
  with qryConsTreino do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select distinct id_treino, treino, descr_treino');
    SQL.Add('from tab_treino_exercicio');
    SQL.Add('order by dia_semana');
    Active := True;
  end;
end;

procedure TDmGlobal.ListarUsuario;
begin
  with qryUsuario do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select * from tab_usuario');
    Active := True;
  end;
end;

procedure TDmGlobal.LoginOnline(email, senha: string);
var
  resp: IResponse;
begin
  TabUsuario.FieldDefs.Clear;

  with TJSONObject.Create do
  try
    AddPair('email', email);
    AddPair('senha', senha);

    resp := TRequest.New.BaseURL(BASE_URL)
      .Resource('usuarios/login')
      .AddBody(ToJSON)
      .BasicAuthentication('99coders', '112233')
      .Accept('application/json')
      .DataSetAdapter(TabUsuario)
      .Post;

    if resp.StatusCode <> 200 then
      raise Exception.Create(resp.Content);
  finally
    DisposeOf;
  end;
end;

procedure TDmGlobal.Logout;
begin
  with Conn do
  begin
    ExecSQL('delete from tab_usuario');
    ExecSQL('delete from tab_treino_exercicio');
    ExecSQL('delete from tab_atividade_historico');
    ExecSQL('delete from tab_atividade');
  end;
end;

procedure TDmGlobal.MarcarExercicioConluido(id_treino: integer;
  ind_concluido: boolean);
begin
  with qryGeral do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('update tab_atividade set ind_concluido = :ind_concluido');
    SQL.Add('where id_exercicio = :id_exercicio');
    ParamByName('ind_concluido').AsString := IfThen(ind_concluido, 'S', 'N');
    ParamByName('id_exercicio').AsInteger := id_treino;
    ExecSQL;
  end;
end;

function TDmGlobal.Pontuacao: integer;
begin
  with qryConsEstatistica do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select ifnull(pontos, 0) as pontos from tab_usuario');

    Active := True;

    Result := FieldByName('pontos').AsInteger;
  end;
end;

function TDmGlobal.TreinosMes(dt: TDateTime): integer;
begin
  with qryConsEstatistica do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select id_historico from tab_atividade_historico');
    SQL.Add('where dt_atividade between :dt1 and :dt2');

    ParamByName('dt1').AsString := FormatDateTime('yyyy-mm-dd', StartOfTheMonth(dt));
    ParamByName('dt2').AsString := FormatDateTime('yyyy-mm-dd', EndOfTheMonth(dt));

    Active := True;

    Result := RecordCount;
  end;
end;

procedure TDmGlobal.TreinoSugerido(dt: TDateTime);
begin
  with qryConsEstatistica do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select * from tab_treino_exercicio');
    SQL.Add('where dia_semana = :dia_semana');

    ParamByName('dia_semana').AsInteger := DayOfWeek(dt);

    Active := True;
  end;
end;

end.
