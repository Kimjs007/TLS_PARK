object frmModelDownload: TfrmModelDownload
  Left = 449
  Top = 236
  BorderStyle = bsDialog
  Caption = 'Model Download'
  ClientHeight = 433
  ClientWidth = 1055
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnl2: TPanel
    Left = 0
    Top = 0
    Width = 1055
    Height = 35
    Align = alTop
    BevelOuter = bvSpace
    BorderStyle = bsSingle
    Caption = 'PG Download Status'
    Color = clNavy
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
    StyleElements = [seBorder]
  end
  object pnlManualFusing: TPanel
    Left = 0
    Top = 35
    Width = 1055
    Height = 390
    Align = alTop
    BevelOuter = bvSpace
    BorderStyle = bsSingle
    Color = clTeal
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
    StyleElements = [seBorder]
    object pnl1: TPanel
      Left = 681
      Top = 274
      Width = 869
      Height = 65
      BevelOuter = bvSpace
      BorderStyle = bsSingle
      Caption = 'Error'
      Color = clSkyBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      Visible = False
      StyleElements = [seBorder]
    end
  end
  object pnlErrorDisplay: TPanel
    Left = 101
    Top = 88
    Width = 869
    Height = 65
    BevelOuter = bvSpace
    BorderStyle = bsSingle
    Caption = 'Error'
    Color = clMaroon
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    Visible = False
    StyleElements = [seBorder]
  end
  object pnlDpcConfigSet: TPanel
    Left = 0
    Top = 460
    Width = 1055
    Height = 114
    Align = alTop
    BevelOuter = bvSpace
    BorderStyle = bsSingle
    Color = clTeal
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 3
    StyleElements = [seBorder]
    object pnl4: TPanel
      Left = 681
      Top = 274
      Width = 869
      Height = 65
      BevelOuter = bvSpace
      BorderStyle = bsSingle
      Caption = 'Error'
      Color = clSkyBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      Visible = False
      StyleElements = [seBorder]
    end
  end
  object pnl5: TPanel
    Left = 0
    Top = 425
    Width = 1055
    Height = 35
    Align = alTop
    BevelOuter = bvSpace
    BorderStyle = bsSingle
    Caption = 'DPC Config Set Status'
    Color = clGreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 4
    StyleElements = [seBorder]
  end
  object tmrDisplayOffMessage: TTimer
    Enabled = False
    OnTimer = tmrDisplayOffMessageTimer
    Left = 28
    Top = 380
  end
  object tmrFrmclose: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrFrmcloseTimer
    Left = 180
    Top = 394
  end
end
