object Form2: TForm2
  Left = 237
  Top = 129
  Width = 712
  Height = 429
  Caption = 'Access PC - Desktop Remoto de "fulano"'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 357
    Width = 696
    Height = 33
    Align = alBottom
    TabOrder = 0
    object CheckBox1: TCheckBox
      Left = 8
      Top = 8
      Width = 97
      Height = 17
      TabStop = False
      Caption = 'Mouse Remoto'
      TabOrder = 0
      OnKeyDown = CheckBox1KeyDown
    end
    object CheckBox2: TCheckBox
      Left = 120
      Top = 8
      Width = 105
      Height = 17
      TabStop = False
      Caption = 'Teclado Remoto'
      TabOrder = 1
      OnClick = CheckBox2Click
      OnKeyDown = CheckBox2KeyDown
    end
    object CheckBox3: TCheckBox
      Left = 232
      Top = 8
      Width = 137
      Height = 17
      TabStop = False
      Caption = 'Redimensionar Imagem'
      TabOrder = 2
      OnClick = CheckBox3Click
      OnKeyDown = CheckBox3KeyDown
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 696
    Height = 357
    HorzScrollBar.Smooth = True
    HorzScrollBar.Tracking = True
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Align = alClient
    TabOrder = 1
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 233
      Height = 161
      AutoSize = True
      OnDblClick = Image1DblClick
      OnMouseDown = Image1MouseDown
      OnMouseMove = Image1MouseMove
      OnMouseUp = Image1MouseUp
    end
  end
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
    Left = 136
    Top = 16
  end
end
