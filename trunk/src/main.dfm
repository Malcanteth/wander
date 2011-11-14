object MainForm: TMainForm
  Left = 514
  Top = 208
  BorderStyle = bsSingle
  Caption = 'WANDER'
  ClientHeight = 186
  ClientWidth = 334
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MM
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object GameTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = GameTimerTimer
    Left = 160
    Top = 112
  end
  object MM: TMainMenu
    Left = 192
    Top = 112
    object N1: TMenuItem
      Caption = #1048#1075#1088#1072
      object N2: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = N2Click
      end
    end
    object N3: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object N4: TMenuItem
        Caption = #1055#1086#1084#1086#1097#1100
        Enabled = False
        ShortCut = 112
        OnClick = N4Click
      end
      object N5: TMenuItem
        Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1103
        Enabled = False
        OnClick = N5Click
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object N7: TMenuItem
        Caption = #1054#1073' '#1080#1075#1088#1077'...'
        OnClick = N7Click
      end
    end
  end
end
