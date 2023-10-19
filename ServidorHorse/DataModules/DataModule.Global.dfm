object DmGlobal: TDmGlobal
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 538
  Width = 408
  object Conn: TFDConnection
    Params.Strings = (
      'Database=C:\Bodyfit\ServidorHorse\DB\BANCO.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Server=localhost'
      'Port=3050'
      'Protocol=TCPIP'
      'DriverID=FB')
    TxOptions.Isolation = xiDirtyRead
    ConnectedStoredUsage = []
    LoginPrompt = False
    BeforeConnect = ConnBeforeConnect
    Left = 48
    Top = 24
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    VendorLib = 'C:\Program Files (x86)\Firebird\Firebird_4_0\fbclient.dll'
    Left = 160
    Top = 24
  end
end
