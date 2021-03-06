object MainEdForm: TMainEdForm
  Left = 532
  Top = 261
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'MainEdForm'
  ClientHeight = 523
  ClientWidth = 972
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Arial Narrow'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 23
  object GroupBox2: TGroupBox
    Left = 84
    Top = -8
    Width = 468
    Height = 529
    TabOrder = 0
    object coord: TLabel
      Left = 15
      Top = 497
      Width = 22
      Height = 23
      Caption = '0:0'
    end
    object SpeedButton1: TSpeedButton
      Left = 398
      Top = 467
      Width = 62
      Height = 14
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1089#1077#1093
      Flat = True
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 429
      Top = 237
      Width = 31
      Height = 24
      Hint = #1047#1072#1083#1080#1090#1100' '#1074#1089#1102' '#1082#1072#1088#1090#1091' '#1074#1099#1073#1088#1072#1085#1085#1099#1084' '#1090#1072#1081#1083#1086#1084
      Caption = 'fresh'
      Flat = True
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton2Click
    end
    object GroupBox1: TGroupBox
      Left = 15
      Top = 15
      Width = 238
      Height = 216
      Caption = #1058#1072#1081#1083#1099
      TabOrder = 0
      object SetTiles: TSpeedButton
        Left = 43
        Top = 191
        Width = 54
        Height = 15
        Caption = #1058#1072#1081#1083#1099
        Flat = True
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial Narrow'
        Font.Style = []
        ParentFont = False
        OnClick = SetTilesClick
      end
      object SetMonsters: TSpeedButton
        Left = 104
        Top = 191
        Width = 55
        Height = 15
        Caption = #1052#1086#1085#1089#1090#1088#1099
        Flat = True
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial Narrow'
        Font.Style = []
        ParentFont = False
        OnClick = SetMonstersClick
      end
      object Fill: TSpeedButton
        Left = 8
        Top = 191
        Width = 25
        Height = 15
        Hint = #1047#1072#1083#1080#1090#1100' '#1074#1089#1102' '#1082#1072#1088#1090#1091' '#1074#1099#1073#1088#1072#1085#1085#1099#1084' '#1090#1072#1081#1083#1086#1084
        Caption = '~'
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = FillClick
      end
      object SetItems: TSpeedButton
        Left = 168
        Top = 191
        Width = 63
        Height = 15
        Caption = #1055#1088#1077#1076#1084#1077#1090#1099
        Flat = True
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial Narrow'
        Font.Style = []
        ParentFont = False
        OnClick = SetItemsClick
      end
      object ItemsBox: TListBox
        Left = 8
        Top = 23
        Width = 223
        Height = 162
        Color = clBlack
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = 8716164
        Font.Height = -17
        Font.Name = 'Arial Narrow'
        Font.Style = []
        ItemHeight = 22
        ParentFont = False
        TabOrder = 0
      end
    end
    object GroupBox4: TGroupBox
      Left = 15
      Top = 230
      Width = 238
      Height = 85
      Caption = #1050#1072#1088#1090#1072
      TabOrder = 1
      object mapname: TEdit
        Left = 15
        Top = 31
        Width = 216
        Height = 31
        TabOrder = 0
        Text = #1053#1072#1079#1074#1072#1085#1080#1077' '#1082#1072#1088#1090#1099
      end
      object CheckBox11: TCheckBox
        Left = 92
        Top = 61
        Width = 139
        Height = 16
        Caption = #1042#1099#1074#1086#1076#1080#1090#1100' '#1085#1072#1079#1074#1072#1085#1080#1077
        Checked = True
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Arial Narrow'
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 1
      end
    end
    object Save: TButton
      Left = 352
      Top = 497
      Width = 108
      Height = 24
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 2
      OnClick = SaveClick
    end
    object GroupBox5: TGroupBox
      Left = 15
      Top = 321
      Width = 238
      Height = 162
      Caption = #1044#1088#1091#1075#1080#1077' '#1082#1072#1088#1090#1099
      TabOrder = 3
      object Label3: TLabel
        Left = 8
        Top = 130
        Width = 48
        Height = 23
        Caption = 'Label3'
      end
      object up: TEdit
        Left = 84
        Top = 23
        Width = 70
        Height = 31
        TabOrder = 0
        Text = '0'
      end
      object down: TEdit
        Left = 84
        Top = 92
        Width = 70
        Height = 31
        TabOrder = 1
        Text = '0'
      end
      object left: TEdit
        Left = 8
        Top = 54
        Width = 69
        Height = 31
        TabOrder = 2
        Text = '0'
      end
      object right: TEdit
        Left = 161
        Top = 54
        Width = 70
        Height = 31
        TabOrder = 3
        Text = '0'
      end
    end
    object GroupBox3: TGroupBox
      Left = 260
      Top = 15
      Width = 200
      Height = 216
      Caption = #1057#1087#1080#1089#1086#1082' '#1083#1086#1082#1072#1094#1080#1081
      TabOrder = 4
      object MapList: TListBox
        Left = 8
        Top = 23
        Width = 184
        Height = 185
        Color = clBlack
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = 16761154
        Font.Height = -17
        Font.Name = 'Arial Narrow'
        Font.Style = []
        ItemHeight = 22
        ParentFont = False
        TabOrder = 0
        OnClick = MapListClick
      end
    end
    object Button5: TButton
      Left = 200
      Top = 497
      Width = 145
      Height = 24
      Caption = #1055#1077#1088#1077#1079#1072#1087#1080#1089#1072#1090#1100
      TabOrder = 5
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 260
      Top = 237
      Width = 169
      Height = 24
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1083#1077#1089#1090#1085#1080#1094#1099
      TabOrder = 6
      OnClick = Button6Click
    end
    object BloodMode: TComboBox
      Left = 260
      Top = 321
      Width = 200
      Height = 22
      Style = csOwnerDrawFixed
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 7
      Text = #1041#1077#1079' '#1082#1088#1086#1074#1080
      Items.Strings = (
        #1041#1077#1079' '#1082#1088#1086#1074#1080
        #1056#1072#1079#1083#1080#1090#1100' ('#1051#1050#1055') '#1055#1086#1076#1090#1077#1088#1077#1090#1100' ('#1055#1050#1052')')
    end
    object ListBox1: TListBox
      Left = 260
      Top = 344
      Width = 200
      Height = 116
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ItemHeight = 15
      ParentFont = False
      TabOrder = 8
      OnClick = ListBox1Click
    end
    object Button2: TButton
      Left = 260
      Top = 268
      Width = 200
      Height = 24
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1084#1086#1085#1089#1090#1088#1072
      TabOrder = 9
      OnClick = Button2Click
    end
  end
  object GroupBox6: TGroupBox
    Left = 559
    Top = 0
    Width = 353
    Height = 514
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1083#1077#1089#1090#1085#1080#1094#1099
    TabOrder = 1
    Visible = False
    object Label1: TLabel
      Left = 176
      Top = 23
      Width = 36
      Height = 23
      Caption = #1050#1088#1091#1090'.'
    end
    object Label2: TLabel
      Left = 230
      Top = 23
      Width = 30
      Height = 23
      Caption = #1058#1080#1087' '
    end
    object number: TLabel
      Left = 8
      Top = 28
      Width = 8
      Height = 22
      Caption = '1'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clRed
      Font.Height = -17
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
    end
    object CheckBox1: TCheckBox
      Left = 8
      Top = 54
      Width = 16
      Height = 16
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
    end
    object Button7: TButton
      Left = 268
      Top = 367
      Width = 72
      Height = 42
      Caption = #1051#1072#1076#1085#1086'!'
      TabOrder = 1
      OnClick = Button7Click
    end
    object pregen1: TComboBox
      Left = 31
      Top = 54
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object cool1: TEdit
      Left = 176
      Top = 54
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      Text = '0'
    end
    object type1: TEdit
      Left = 230
      Top = 54
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      Text = '0'
    end
    object CheckBox3: TCheckBox
      Left = 8
      Top = 115
      Width = 16
      Height = 16
      Color = clBtnFace
      ParentColor = False
      TabOrder = 5
    end
    object pregen3: TComboBox
      Left = 31
      Top = 115
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
    end
    object cool3: TEdit
      Left = 176
      Top = 115
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      Text = '0'
    end
    object type3: TEdit
      Left = 230
      Top = 115
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 8
      Text = '0'
    end
    object CheckBox4: TCheckBox
      Left = 8
      Top = 145
      Width = 16
      Height = 17
      Color = clBtnFace
      ParentColor = False
      TabOrder = 9
    end
    object pregen4: TComboBox
      Left = 31
      Top = 145
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 10
    end
    object cool4: TEdit
      Left = 176
      Top = 145
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 11
      Text = '0'
    end
    object type4: TEdit
      Left = 230
      Top = 145
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 12
      Text = '0'
    end
    object CheckBox5: TCheckBox
      Left = 8
      Top = 176
      Width = 16
      Height = 16
      Color = clBtnFace
      ParentColor = False
      TabOrder = 13
    end
    object pregen5: TComboBox
      Left = 31
      Top = 176
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 14
    end
    object cool5: TEdit
      Left = 176
      Top = 176
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 15
      Text = '0'
    end
    object type5: TEdit
      Left = 230
      Top = 176
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 16
      Text = '0'
    end
    object CheckBox6: TCheckBox
      Left = 8
      Top = 207
      Width = 16
      Height = 16
      Color = clBtnFace
      ParentColor = False
      TabOrder = 17
    end
    object pregen6: TComboBox
      Left = 31
      Top = 207
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 18
    end
    object cool6: TEdit
      Left = 176
      Top = 207
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 19
      Text = '0'
    end
    object type6: TEdit
      Left = 230
      Top = 207
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 20
      Text = '0'
    end
    object CheckBox7: TCheckBox
      Left = 8
      Top = 237
      Width = 16
      Height = 16
      Color = clBtnFace
      ParentColor = False
      TabOrder = 21
    end
    object pregen7: TComboBox
      Left = 31
      Top = 237
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 22
    end
    object cool7: TEdit
      Left = 176
      Top = 237
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 23
      Text = '0'
    end
    object type7: TEdit
      Left = 230
      Top = 237
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 24
      Text = '0'
    end
    object CheckBox9: TCheckBox
      Left = 8
      Top = 298
      Width = 16
      Height = 17
      Color = clBtnFace
      ParentColor = False
      TabOrder = 25
    end
    object pregen9: TComboBox
      Left = 31
      Top = 298
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 26
    end
    object cool9: TEdit
      Left = 176
      Top = 298
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 27
      Text = '0'
    end
    object type9: TEdit
      Left = 230
      Top = 298
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 28
      Text = '0'
    end
    object CheckBox2: TCheckBox
      Left = 8
      Top = 84
      Width = 16
      Height = 16
      Color = clBtnFace
      ParentColor = False
      TabOrder = 29
    end
    object pregen2: TComboBox
      Left = 31
      Top = 84
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 30
    end
    object cool2: TEdit
      Left = 176
      Top = 84
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 31
      Text = '0'
    end
    object type2: TEdit
      Left = 230
      Top = 84
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 32
      Text = '0'
    end
    object CheckBox8: TCheckBox
      Left = 8
      Top = 268
      Width = 16
      Height = 16
      Color = clBtnFace
      ParentColor = False
      TabOrder = 33
    end
    object pregen8: TComboBox
      Left = 31
      Top = 268
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 34
    end
    object cool8: TEdit
      Left = 176
      Top = 268
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 35
      Text = '0'
    end
    object type8: TEdit
      Left = 230
      Top = 268
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 36
      Text = '0'
    end
    object CheckBox10: TCheckBox
      Left = 8
      Top = 329
      Width = 16
      Height = 16
      Color = clBtnFace
      ParentColor = False
      TabOrder = 37
    end
    object pregen10: TComboBox
      Left = 31
      Top = 329
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 38
    end
    object cool10: TEdit
      Left = 176
      Top = 329
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 39
      Text = '0'
    end
    object type10: TEdit
      Left = 230
      Top = 329
      Width = 39
      Height = 28
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 40
      Text = '0'
    end
    object Memo1: TMemo
      Left = 15
      Top = 421
      Width = 323
      Height = 85
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      Lines.Strings = (
        #1058#1080#1087#1099' '#1075#1077#1085#1077#1088#1080#1088#1091#1077#1084#1099#1093' '#1087#1086#1076#1079#1077#1084#1077#1083#1080#1081':'
        '1 - "'#1055#1088#1072#1074#1080#1083#1100#1085#1099#1081'"'
        '2 - "'#1087#1088#1072#1074#1080#1083#1100#1085#1099#1081'" '#1088#1072#1079#1088#1091#1096#1077#1085#1085#1099#1081
        '3 - '#1088#1091#1080#1085#1099','
        '4-'#1088#1072#1079#1088#1091#1096#1077#1085#1085#1099#1081' '#1083#1072#1073#1080#1088#1080#1085#1090
        '5-'#1088#1072#1079#1088#1091#1096#1077#1085#1085#1099#1077' '#1082#1086#1084#1085#1072#1090#1099)
      ParentFont = False
      TabOrder = 41
    end
    object numberchange: TComboBox
      Left = 61
      Top = 31
      Width = 101
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 42
    end
    object DungeonName: TEdit
      Left = 15
      Top = 383
      Width = 246
      Height = 30
      Enabled = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlack
      Font.Height = -17
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 43
    end
    object RandomName: TCheckBox
      Left = 8
      Top = 360
      Width = 245
      Height = 16
      Caption = #1056#1072#1085#1076#1086#1084#1085#1086#1077' '#1085#1072#1079#1074#1072#1085#1080#1077
      Checked = True
      State = cbChecked
      TabOrder = 44
      OnClick = RandomNameClick
    end
  end
  object GroupBox7: TGroupBox
    Left = 38
    Top = 275
    Width = 246
    Height = 124
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1083#1077#1089#1090#1085#1080#1094#1099' '#1074#1074#1077#1088#1093
    TabOrder = 2
    Visible = False
    object Button1: TButton
      Left = 168
      Top = 92
      Width = 72
      Height = 24
      Caption = #1051#1072#1076#1085#1086'!'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Pregen: TComboBox
      Left = 8
      Top = 31
      Width = 138
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object GroupBox8: TGroupBox
    Left = 38
    Top = 8
    Width = 254
    Height = 131
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1084#1086#1085#1089#1090#1088#1072
    TabOrder = 3
    Visible = False
    object Label4: TLabel
      Left = 8
      Top = 23
      Width = 10
      Height = 23
      Caption = 'X'
    end
    object Label5: TLabel
      Left = 31
      Top = 23
      Width = 9
      Height = 23
      Caption = 'Y'
    end
    object Button3: TButton
      Left = 176
      Top = 99
      Width = 72
      Height = 24
      Caption = #1051#1072#1076#1085#1086'!'
      TabOrder = 0
      OnClick = Button3Click
    end
    object relation: TComboBox
      Left = 8
      Top = 46
      Width = 238
      Height = 22
      Style = csOwnerDrawFixed
      Color = clBlack
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clYellow
      Font.Height = -13
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 1
      Text = '0 - '#1053#1077#1081#1090#1088#1072#1083#1100#1085#1099#1081
      Items.Strings = (
        '0 - '#1053#1077#1081#1090#1088#1072#1083#1100#1085#1099#1081
        '1 - '#1040#1075#1088#1077#1089#1089#1080#1103' ('#1083#1080#1073#1086' '#1086#1076#1077#1088#1078#1080#1084#1086#1089#1090#1100')')
    end
  end
  object MainMenu1: TMainMenu
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N3: TMenuItem
        Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
        OnClick = N3Click
      end
      object N2: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        OnClick = N2Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object N5: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = N5Click
      end
    end
  end
  object Timer1: TTimer
    Interval = 250
    OnTimer = Timer1Timer
    Left = 32
    Top = 192
  end
end
