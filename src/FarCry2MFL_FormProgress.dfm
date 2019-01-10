object FormProgress: TFormProgress
  Left = 690
  Top = 358
  BorderStyle = bsDialog
  Caption = 'Launching game...'
  ClientHeight = 33
  ClientWidth = 229
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonCancel: TButton
    Left = 160
    Top = 4
    Width = 65
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object ProgressBar1: TProgressBar
    Left = 4
    Top = 4
    Width = 150
    Height = 25
    Smooth = True
    TabOrder = 1
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 92
    Top = 4
  end
end
