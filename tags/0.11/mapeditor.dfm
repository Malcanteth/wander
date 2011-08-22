object MainEdForm: TMainEdForm
  Left = 192
  Top = 124
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'MainEdForm'
  ClientHeight = 567
  ClientWidth = 854
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Arial Narrow'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 23
  object GroupBox2: TGroupBox
    Left = 88
    Top = 0
    Width = 473
    Height = 553
    TabOrder = 0
    object GroupBox1: TGroupBox
      Left = 16
      Top = 16
      Width = 249
      Height = 105
      Caption = #1058#1072#1081#1083#1099
      TabOrder = 0
      object TileList: TComboBox
        Left = 18
        Top = 24
        Width = 217
        Height = 22
        Style = csOwnerDrawFixed
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Times New Roman'
        Font.Style = []
        ItemHeight = 16
        ParentFont = False
        TabOrder = 0
      end
      object Fill: TButton
        Left = 160
        Top = 56
        Width = 75
        Height = 25
        Caption = #1047#1072#1083#1080#1090#1100
        TabOrder = 1
        OnClick = FillClick
      end
    end
    object GroupBox3: TGroupBox
      Left = 16
      Top = 128
      Width = 249
      Height = 105
      Caption = #1052#1086#1085#1089#1090#1088#1099
      TabOrder = 1
      object MonsterList: TComboBox
        Left = 18
        Top = 24
        Width = 217
        Height = 22
        Style = csOwnerDrawFixed
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Times New Roman'
        Font.Style = []
        ItemHeight = 16
        ParentFont = False
        TabOrder = 0
      end
      object DeleteMonster: TCheckBox
        Left = 136
        Top = 72
        Width = 97
        Height = 17
        Caption = #1059#1076#1072#1083#1080#1090#1100
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clRed
        Font.Height = -19
        Font.Name = 'Arial Narrow'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
    object GroupBox4: TGroupBox
      Left = 16
      Top = 240
      Width = 249
      Height = 89
      Caption = #1050#1072#1088#1090#1072
      TabOrder = 2
      object mapname: TEdit
        Left = 12
        Top = 32
        Width = 225
        Height = 31
        TabOrder = 0
        Text = #1053#1072#1079#1074#1072#1085#1080#1077' '#1082#1072#1088#1090#1099
      end
    end
    object MapList: TListBox
      Left = 272
      Top = 24
      Width = 185
      Height = 209
      ItemHeight = 23
      TabOrder = 3
      OnClick = MapListClick
    end
    object Button1: TButton
      Left = 376
      Top = 240
      Width = 75
      Height = 25
      Caption = #1042#1099#1073#1088#1072#1090#1100
      TabOrder = 4
    end
    object Save: TButton
      Left = 328
      Top = 520
      Width = 137
      Height = 25
      Caption = #1057#1054#1061#1056#1040#1053#1048#1058#1068
      TabOrder = 5
      OnClick = SaveClick
    end
    object GroupBox5: TGroupBox
      Left = 16
      Top = 336
      Width = 249
      Height = 145
      Caption = #1044#1088#1091#1075#1080#1077' '#1082#1072#1088#1090#1099
      TabOrder = 6
      object Edit1: TEdit
        Left = 88
        Top = 24
        Width = 73
        Height = 31
        TabOrder = 0
        Text = '0'
      end
      object Edit2: TEdit
        Left = 88
        Top = 96
        Width = 73
        Height = 31
        TabOrder = 1
        Text = '0'
      end
      object Edit3: TEdit
        Left = 8
        Top = 56
        Width = 73
        Height = 31
        TabOrder = 2
        Text = '0'
      end
      object Edit4: TEdit
        Left = 168
        Top = 56
        Width = 73
        Height = 31
        TabOrder = 3
        Text = '0'
      end
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
end
