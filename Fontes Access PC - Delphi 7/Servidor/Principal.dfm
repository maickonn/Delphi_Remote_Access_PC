object Form1: TForm1
  Left = 199
  Top = 146
  Width = 848
  Height = 416
  Caption = 'Access PC - Servidor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 335
    Width = 832
    Height = 42
    Align = alBottom
    TabOrder = 0
    object Bevel1: TBevel
      Left = 328
      Top = 0
      Width = 17
      Height = 41
      Shape = bsLeftLine
    end
    object Label1: TLabel
      Left = 104
      Top = 15
      Width = 28
      Height = 13
      Caption = 'Porta:'
    end
    object Label2: TLabel
      Left = 200
      Top = 14
      Width = 34
      Height = 13
      Caption = 'Senha:'
    end
    object Button1: TButton
      Left = 8
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Ativar'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 336
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Sobre'
      TabOrder = 1
      OnClick = Button3Click
    end
    object Edit1: TEdit
      Left = 136
      Top = 11
      Width = 49
      Height = 21
      TabOrder = 2
      Text = '6651'
    end
    object Edit2: TEdit
      Left = 240
      Top = 10
      Width = 73
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
    end
  end
  object LV1: TListView
    Left = 0
    Top = 0
    Width = 832
    Height = 316
    Align = alClient
    Columns = <
      item
        Caption = 'IDSock'
        Width = 70
      end
      item
        Caption = 'Identifica'#231#227'o'
        Width = 170
      end
      item
        Caption = 'Sistema Operacional'
        Width = 170
      end
      item
        Caption = 'Processador'
        Width = 190
      end
      item
        Caption = 'IP'
        Width = 150
      end
      item
        Caption = 'Ping'
      end>
    Enabled = False
    GridLines = True
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 1
    ViewStyle = vsReport
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 316
    Width = 832
    Height = 19
    Panels = <
      item
        Text = 'Status:'
        Width = 50
      end
      item
        Text = 'Desativado'
        Width = 100
      end>
  end
  object PopupMenu1: TPopupMenu
    Left = 344
    Top = 104
    object Fecharconexo1: TMenuItem
      Caption = 'Acessar Computador'
      OnClick = Fecharconexo1Click
    end
    object Chato1: TMenuItem
      Caption = 'Chat'
      OnClick = Chato1Click
    end
    object GerenciadordeArquivos1: TMenuItem
      Caption = 'Compartilhador de Arquivos'
      OnClick = GerenciadordeArquivos1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object FecharConexo2: TMenuItem
      Caption = 'Fechar Conex'#227'o'
      OnClick = FecharConexo2Click
    end
  end
  object SS1: TServerSocket
    Active = False
    Port = 6651
    ServerType = stNonBlocking
    OnListen = SS1Listen
    OnAccept = SS1Accept
    OnClientDisconnect = SS1ClientDisconnect
    OnClientError = SS1ClientError
    Left = 392
    Top = 104
  end
  object Timer1: TTimer
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 432
    Top = 104
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    Left = 464
    Top = 104
  end
end
