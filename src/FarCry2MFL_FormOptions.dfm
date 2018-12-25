object FormOptions: TFormOptions
  Left = 406
  Top = 235
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Options'
  ClientHeight = 245
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    513
    245)
  PixelsPerInch = 96
  TextHeight = 13
  object CheckListBox1: TCheckListBox
    Left = 4
    Top = 4
    Width = 161
    Height = 205
    OnClickCheck = CheckListBox1ClickCheck
    ItemHeight = 13
    TabOrder = 0
    OnClick = CheckListBox1Click
  end
  object ButtonOK: TButton
    Left = 152
    Top = 216
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
    TabOrder = 1
    OnClick = ButtonOKClick
  end
  object ButtonCancel: TButton
    Left = 260
    Top = 216
    Width = 101
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Memo1: TMemo
    Left = 168
    Top = 4
    Width = 341
    Height = 205
    TabStop = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
end
