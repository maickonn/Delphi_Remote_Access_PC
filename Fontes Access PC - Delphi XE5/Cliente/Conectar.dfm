object Form1: TForm1
  Left = 192
  Top = 124
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Access PC'
  ClientHeight = 164
  ClientWidth = 293
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
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 40
    Height = 13
    Caption = 'IP/Host:'
  end
  object Label2: TLabel
    Left = 200
    Top = 16
    Width = 28
    Height = 13
    Caption = 'Porta:'
  end
  object Label3: TLabel
    Left = 8
    Top = 48
    Width = 34
    Height = 13
    Caption = 'Senha:'
  end
  object Label4: TLabel
    Left = 8
    Top = 77
    Width = 64
    Height = 13
    Caption = 'Identifica'#231#227'o:'
  end
  object Edit1: TEdit
    Left = 56
    Top = 12
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 232
    Top = 12
    Width = 49
    Height = 21
    TabOrder = 1
    Text = '6651'
  end
  object Edit3: TEdit
    Left = 56
    Top = 44
    Width = 225
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
  end
  object Button1: TButton
    Left = 8
    Top = 112
    Width = 75
    Height = 25
    Caption = 'Conectar'
    TabOrder = 4
    OnClick = Button1Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 145
    Width = 293
    Height = 19
    Panels = <
      item
        Text = 'Status:'
        Width = 50
      end
      item
        Text = 'Desconectado'
        Width = 150
      end>
  end
  object Edit4: TEdit
    Left = 80
    Top = 73
    Width = 201
    Height = 21
    TabOrder = 3
    Text = 'Access PC - Cliente'
  end
  object CheckBox1: TCheckBox
    Left = 88
    Top = 116
    Width = 201
    Height = 17
    Caption = 'Auto reconectar se perder Conex'#227'o'
    TabOrder = 5
  end
  object CS1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnecting = CS1Connecting
    OnConnect = CS1Connect
    OnDisconnect = CS1Disconnect
    OnRead = CS1Read
    OnError = CS1Error
    Left = 88
    Top = 88
  end
  object CS2: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = CS2Connect
    OnRead = CS2Read
    OnError = CS2Error
    Left = 120
    Top = 88
  end
  object CS3: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = CS3Connect
    OnRead = CS3Read
    OnError = CS3Error
    Left = 152
    Top = 88
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 15000
    OnTimer = Timer1Timer
    Left = 256
    Top = 56
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 15000
    OnTimer = Timer2Timer
    Left = 224
    Top = 56
  end
  object CS4: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = CS4Connect
    OnRead = CS4Read
    OnError = CS4Error
    Left = 184
    Top = 88
  end
  object CS5: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = CS6Connect
    OnRead = CS5Read
    OnError = CS6Error
    Left = 216
    Top = 88
  end
end
