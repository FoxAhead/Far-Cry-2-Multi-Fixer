object Form1: TForm1
  Left = 376
  Top = 442
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Far Cry 2 Multi Fixer Launcher'
  ClientHeight = 297
  ClientWidth = 513
  Color = clBtnFace
  Constraints.MaxWidth = 521
  Constraints.MinWidth = 521
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  DesignSize = (
    513
    297)
  PixelsPerInch = 96
  TextHeight = 13
  object LabelExe: TLabel
    Tag = 1
    Left = 8
    Top = 8
    Width = 28
    Height = 13
    Caption = 'Game'
  end
  object LabelVersion: TLabel
    Left = 470
    Top = 280
    Width = 35
    Height = 13
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
    Caption = 'Version'
    Enabled = False
  end
  object LabelAuthor: TLabel
    Left = 8
    Top = 272
    Width = 75
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '2019 FoxAhead'
    Enabled = False
  end
  object LabelGitHub: TLabel
    Left = 472
    Top = 264
    Width = 33
    Height = 13
    Cursor = crHandPoint
    Alignment = taRightJustify
    Anchors = [akRight, akBottom]
    Caption = 'GitHub'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = LabelGitHubClick
  end
  object LabelDebug: TLabel
    Left = 404
    Top = 280
    Width = 101
    Height = 13
    Anchors = [akRight, akBottom]
    AutoSize = False
    Transparent = True
    OnClick = LabelDebugClick
  end
  object Memo1: TMemo
    Left = 4
    Top = 32
    Width = 505
    Height = 229
    TabStop = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      
        'This launcher adds some fixes and tweaks for Far Cry 2 game with' +
        'out modifying game executables.'
      ''
      
        'Jackal Tapes bug patch, Intel Bonus Content unlocking, FOV chang' +
        'ing and more...'
      ''
      'Features can be switched in '#39'Options...'#39' dialog.'
      ''
      
        'This launcher will search for FarCry2.EXE, Dunia.DLL and FarCry2' +
        'MF.DLL files and try to set all paths '
      'automatically.'
      ''
      
        'You can create shortcut to start game immediately. All selected ' +
        'paths will be saved in shortcut.'
      ''
      
        'Supported game version is v1.03 in variations: Steam, GOG (Retai' +
        'l) and Uplay (very similar to Steam).')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object ButtonBrowseExe: TButton
    Tag = 1
    Left = 444
    Top = 2
    Width = 65
    Height = 25
    Caption = 'Browse...'
    TabOrder = 2
    OnClick = ButtonBrowseExeClick
  end
  object EditExe: TEdit
    Tag = 1
    Left = 44
    Top = 4
    Width = 393
    Height = 21
    TabStop = False
    AutoSize = False
    Color = clBtnFace
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 5
  end
  object ButtonStart: TButton
    Left = 300
    Top = 268
    Width = 101
    Height = 25
    Hint = 'Close this screen and start game'
    Anchors = [akBottom]
    Caption = 'Play'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = ButtonStartClick
  end
  object ButtonShortcut: TButton
    Left = 192
    Top = 268
    Width = 101
    Height = 25
    Anchors = [akBottom]
    Caption = 'Create shortcut...'
    TabOrder = 4
    OnClick = ButtonShortcutClick
  end
  object ButtonOptions: TButton
    Left = 120
    Top = 268
    Width = 65
    Height = 25
    Anchors = [akBottom]
    Caption = 'Options...'
    TabOrder = 3
    OnClick = ButtonOptionsClick
  end
  object OpenDialogExe: TOpenDialog
    Filter = 'FarCry2.exe|FarCry2.exe|*.exe|*.exe'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 404
    Top = 4
  end
  object SaveDialogLnk: TSaveDialog
    FileName = 'Far Cry 2 with Multi Fixer.lnk'
    Filter = '*.lnk|*.lnk'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 184
    Top = 192
  end
  object Timer1: TTimer
    Interval = 500
    OnTimer = Timer1Timer
    Left = 404
    Top = 64
  end
end
