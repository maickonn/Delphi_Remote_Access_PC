object Form4: TForm4
  Left = 200
  Top = 149
  Width = 683
  Height = 359
  Caption = 'Chat'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 240
    Width = 667
    Height = 81
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 0
    OnKeyDown = Memo1KeyDown
    OnKeyUp = Memo1KeyUp
  end
  object Memo2: TMemo
    Left = 0
    Top = 0
    Width = 667
    Height = 240
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
