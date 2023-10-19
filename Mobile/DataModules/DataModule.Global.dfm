object DmGlobal: TDmGlobal
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 550
  Width = 413
  object Conn: TFDConnection
    Params.Strings = (
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    AfterConnect = ConnAfterConnect
    BeforeConnect = ConnBeforeConnect
    Left = 48
    Top = 24
  end
  object TabUsuario: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 176
    Top = 24
  end
  object qryUsuario: TFDQuery
    Connection = Conn
    Left = 48
    Top = 72
  end
  object TabTreino: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 176
    Top = 72
  end
  object qryTreinoExercicio: TFDQuery
    Connection = Conn
    Left = 48
    Top = 120
  end
  object qryConsEstatistica: TFDQuery
    Connection = Conn
    Left = 48
    Top = 168
  end
  object qryConsTreino: TFDQuery
    Connection = Conn
    Left = 48
    Top = 216
  end
  object qryConsExercicio: TFDQuery
    Connection = Conn
    Left = 48
    Top = 264
  end
  object qryAtividade: TFDQuery
    Connection = Conn
    Left = 48
    Top = 312
  end
  object qryGeral: TFDQuery
    Connection = Conn
    Left = 48
    Top = 488
  end
end
