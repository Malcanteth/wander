object MainForm: TMainForm
  Left = 530
  Top = 223
  BorderStyle = bsSingle
  Caption = 'WANDER'
  ClientHeight = 206
  ClientWidth = 334
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object GameTimer: TTimer
    Interval = 200
    OnTimer = GameTimerTimer
  end
end
