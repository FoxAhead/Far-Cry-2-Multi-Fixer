object FormMods: TFormMods
  Left = 520
  Top = 229
  Width = 521
  Height = 324
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Mods'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    513
    297)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 120
    Top = 12
    Width = 28
    Height = 13
    Caption = 'Name'
  end
  object Label2: TLabel
    Left = 120
    Top = 40
    Width = 22
    Height = 13
    Caption = 'Path'
  end
  object ButtonOK: TButton
    Left = 152
    Top = 268
    Width = 101
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
    OnClick = ButtonOKClick
  end
  object ButtonCancel: TButton
    Left = 260
    Top = 268
    Width = 101
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object CheckListBox1: TCheckListBox
    Left = 4
    Top = 36
    Width = 105
    Height = 229
    OnClickCheck = CheckListBox1ClickCheck
    Anchors = [akLeft, akTop, akBottom]
    DragMode = dmAutomatic
    ItemHeight = 13
    Items.Strings = (
      'erewtert'
      '435324f'
      '2345342')
    TabOrder = 2
    OnClick = CheckListBox1Click
    OnDragDrop = CheckListBox1DragDrop
    OnDragOver = CheckListBox1DragOver
  end
  object Edit1: TEdit
    Left = 152
    Top = 8
    Width = 357
    Height = 21
    TabOrder = 3
  end
  object Edit2: TEdit
    Left = 152
    Top = 36
    Width = 297
    Height = 21
    TabOrder = 4
  end
  object ButtonAdd: TButton
    Left = 4
    Top = 4
    Width = 49
    Height = 25
    Caption = 'Add'
    TabOrder = 5
    OnClick = ButtonAddClick
  end
  object ButtonDel: TButton
    Left = 60
    Top = 4
    Width = 49
    Height = 25
    Caption = 'Del'
    TabOrder = 6
    OnClick = ButtonDelClick
  end
  object CheckBox1: TCheckBox
    Left = 152
    Top = 64
    Width = 161
    Height = 17
    Caption = 'Path relative to the launcher'
    TabOrder = 7
  end
  object Button5: TButton
    Left = 452
    Top = 36
    Width = 57
    Height = 21
    Caption = 'Browse...'
    TabOrder = 8
  end
end
