unit Controller.Global;

interface

uses
  Horse, DataModule.Global, System.JSON, System.SysUtils;

procedure RegistrarRotas;
procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure CriarConta(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure EditarSenha(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ListarTreinos(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure RegistrarRotas;
begin
  THorse.Post('/usuarios/login', Login);
  THorse.Post('/usuarios/registro', CriarConta);
  THorse.Put('/usuarios/senha', EditarSenha);
  THorse.Put('/usuarios', EditarUsuario);
  THorse.Get('/treinos', ListarTreinos);
end;

procedure Login(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  DmGlobal: TDmGlobal;
  email, senha: string;
  body, json_ret: TJSONObject;
begin
  DmGlobal := TDmGlobal.Create(nil);
  try
    try
      body := Req.Body<TJSONObject>;

      email := body.GetValue<string>('email', '');
      senha := body.GetValue<string>('senha', '');

      json_ret := DmGlobal.Login(email, senha);

      if json_ret.Count = 0 then
        Res.Send('E-mail e senha inválidos.').Status(401)
      else
        Res.Send<TJSONObject>(json_ret).Status(200);
    except
      on E: Exception do
        Res.Send(E.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure CriarConta(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  DmGlobal: TDmGlobal;
  nome, email, senha: string;
  body: TJSONObject;
begin
  DmGlobal := TDmGlobal.Create(nil);
  try
    try
      body := Req.Body<TJSONObject>;

      nome := body.GetValue<string>('nome', '');
      email := body.GetValue<string>('email', '');
      senha := body.GetValue<string>('senha', '');

      Res.Send<TJSONObject>(DmGlobal.CriarConta(nome, email,
        senha)).Status(201);
    except
      on E: Exception do
        Res.Send(E.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  DmGlobal: TDmGlobal;
  id_usuario: Integer;
  nome, email: string;
  body: TJSONObject;
begin
  DmGlobal := TDmGlobal.Create(nil);
  try
    try
      body := Req.Body<TJSONObject>;

      id_usuario := body.GetValue<Integer>('id_usuario', 0);
      nome := body.GetValue<string>('nome', '');
      email := body.GetValue<string>('email', '');

      Res.Send<TJSONObject>(DmGlobal.EditarUsuario(id_usuario, nome,
        email)).Status(200);
    except
      on E: Exception do
        Res.Send(E.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure EditarSenha(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  DmGlobal: TDmGlobal;
  id_usuario: Integer;
  senha: string;
  body: TJSONObject;
begin
  DmGlobal := TDmGlobal.Create(nil);
  try
    try
      body := Req.Body<TJSONObject>;

      id_usuario := body.GetValue<Integer>('id_usuario', 0);
      senha := body.GetValue<string>('senha', '');

      Res.Send<TJSONObject>(DmGlobal.EditarSenha(id_usuario,
        senha)).Status(200);
    except
      on E: Exception do
        Res.Send(E.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

procedure ListarTreinos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  DmGlobal: TDmGlobal;
  id_usuario: Integer;
begin
  DmGlobal := TDmGlobal.Create(nil);
  try
    try
      try
        id_usuario := Req.Query['id_usuario'].ToInteger;
      except
        id_usuario := 0;
      end;

      Res.Send<TJSONArray>(DmGlobal.ListarTreinos(id_usuario)).Status(200);
    except
      on E: Exception do
        Res.Send(E.Message).Status(500);
    end;
  finally
    FreeAndNil(DmGlobal);
  end;
end;

end.
