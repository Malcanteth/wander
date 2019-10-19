unit msg;

interface

uses
  Main, Cons, Utils, SUtils;

type
  THistory = record
    msg: string;
    Amount: integer;
  end;

var
  Msgs: array [1 .. MsgAmount] of string;
  History: array [1 .. MaxHistory] of THistory;
  InputX, InputY: integer;
  InputString: string[13];
  InputPos: byte;
  LastMsgY, LastMsgL: byte;

procedure AddMsg(s: string; id: integer);
function GetMsg(AString: String; gender: byte): string;
procedure AddDrawMsg(s: string; id: integer);
procedure ClearMsg;
procedure More;
procedure Apply;
procedure ShowMsgs;
function Ask(s: string): AnsiChar;
function Input(sx, sy: integer; ss: string): string;
procedure ShowInput;
procedure AddTextLine(X, Y: Word; msg: string); // Цветная строка

implementation

uses SysUtils, Conf, Player, Windows, Graphics, Monsters, wlog;

// Добавить сообщение
procedure AddMsg(s: string; id: integer);
var
  b: integer;

  // Подпрограмма рекурсивно добавляет сообщения
  procedure UseMsg(s: string; id: integer);
  var
    a, i, j: byte;
    w, o: string;
  begin
    if id < 2 then
      s := GetMsg(s, pc.gender)
    else
      s := GetMsg(s, MonstersData[id].gender);
    // Найти пустой слот
    for a := 1 to MsgAmount do
      if (Msgs[a] = '') and (a < MsgAmount) then
      begin
        w := s;
        o := '';
        // Длина сообщения слишком велика
        if Length(s) > MsgLength then
        begin
          for i := Length(w) downto 1 do
          begin
            if (w[i] = ' ') and (i <= MsgLength) then
              break;
            delete(w, i, 1);
            o := Copy(s, i, Length(s) - i + 1);
          end;
        end;
        Msgs[a] := w;
        LastMsgY := a;
        LastMsgL := Length(w);
        // Добавить в историю
        if (w <> '') and (w <> ' ') then
        begin
          if History[MaxHistory].msg = '' then
          begin
            for j := 1 to MaxHistory do
              if History[j].msg = '' then
              begin
                if History[j - 1].msg = w then
                  inc(History[j - 1].Amount)
                else
                begin
                  History[j].msg := w;
                  History[j].Amount := 1;
                end;
                break;
              end;
          end
          else
          begin
            if History[MaxHistory].msg = w then
              inc(History[MaxHistory].Amount)
            else
            begin
              for j := 2 to MaxHistory do
                History[j - 1] := History[j];
              History[MaxHistory].msg := w;
              History[MaxHistory].Amount := 1;
            end;
          end;
        end;
        if o <> '' then
          UseMsg(o, id);
        break;
      end
      else if (Msgs[a] = '') and (a = MsgAmount) then
      begin
        More;
        UseMsg(s, id);
        break;
      end;
  end;

begin
  // Доб. сообщение
  UseMsg(s, id);
  // Корректируем сообщение в зависимости от пола
  if id < 2 then
    s := GetMsg(s, pc.gender)
  else
    s := GetMsg(s, MonstersData[id].gender);
  // Исключаем служебные символы
  for b := 1 to Length(s) do
    if (s[b] = '*') or (s[b] = '$') or (s[b] = '#') then
      delete(s, b, 1);
  // Добавляем в лог
  if (s <> '') and (s <> ' ') then
    Log(s);
end;

(* Вернуть окончание в зависимости от пола героя {/Ж} или {М/Ж} *)
function GetMsg(AString: String; gender: byte): string;
var
  i: integer;
  sx, RX, S1, S2: String;
  RF: byte;
begin
  if gender = 10 then
    gender := pc.gender;
  sx := '';
  RX := '';
  RF := 0;
  for i := 1 to Length(AString) do
  begin
    case AString[i] of
      '{':
        begin
          RF := 1;
          Continue;
        end;
      '}':
        RF := 2;
    end;
    case RF of
      0:
        RX := RX + AString[i];
      1:
        sx := sx + AString[i];
      2:
        begin
          S1 := GetStrKey('/', sx);
          S2 := GetStrValue('/', sx);
          sx := '';
          RF := 0;
          if (gender = genFEMALE) then
            RX := RX + S2
          else
            RX := RX + S1;
        end;
    end;
  end;
  Result := RX;
end;

{ Добавить сообщение и отобразить }
procedure AddDrawMsg(s: string; id: integer);
begin
  AddMsg(s, id);
  MainForm.OnPaint(NIL);
end;

{ Очистить все сообщения }
procedure ClearMsg;
var
  i: byte;
begin
  for i := 1 to MsgAmount do
    Msgs[i] := '';
end;

{ Дальше }
procedure More;
begin
  Msgs[MsgAmount] := '$(Дальше)$';
  MainForm.OnPaint(NIL);
  WaitMore := True;
  while WaitMore = True do
    MainForm.ProcessMsg;
  ClearMsg
end;

{ Ждем нажатия ENTER }
procedure Apply;
begin
  Msgs[MsgAmount] := '$(Нажми ENTER для продолжения)$';
  MainForm.OnPaint(NIL);
  WaitENTER := True;
  while WaitENTER = True do
    MainForm.ProcessMsg;
  ClearMsg;
end;

{ Показать сообщения }
procedure ShowMsgs;
var
  X, Y, c, t: byte;
begin
  // Сообщения
  with GScreen.Canvas do
  begin
    Font.Name := FontMsg;
    Brush.Color := 0;
    c := 0;
    for Y := 1 to MsgAmount do
      if Msgs[Y] <> '' then
      begin
        t := 1;
        for X := 1 to Length(Msgs[Y]) do
        begin
          // Символы начала и конца цвета
          if Msgs[Y][X] = '$' then // желтый
          begin
            if c = 0 then
              c := 1
            else
              c := 0;
          end
          else if Msgs[Y][X] = '*' then // красный
          begin
            if c = 0 then
              c := 2
            else
              c := 0;
          end
          else if Msgs[Y][X] = '#' then // зеленый
          begin
            if c = 0 then
              c := 3
            else
              c := 0;
          end
          else
          begin
            // Цвет букв
            case c of
              0:
                Font.Color := MyRGB(160, 160, 160); // Серый
              1:
                Font.Color := MyRGB(255, 255, 0); // Желтый
              2:
                Font.Color := MyRGB(200, 0, 0); // Красный
              3:
                Font.Color := MyRGB(0, 200, 0); // Зеленый
            end;
            Textout((t - 1) * CharX, (MapY * CharY) + ((Y - 1) * CharY), Msgs[Y][X]);
            inc(t);
          end;
        end;
      end;
  end;
end;

{ Задать вопрос }
function Ask(s: string): AnsiChar;
begin
  AddDrawMsg(s, 0);
  Answer := ' ';
  while Answer = ' ' do
  begin
    Sleep(10);
    MainForm.ProcessMsg;
  end;
  Result := Answer[1];
  Answer := '';
end;

{ Функция ввода текста пльзователем }
function Input(sx, sy: integer; ss: string): string;
begin
  InputString := ss;
  InputPos := Length(ss);
  InputX := sx;
  InputY := sy;
  WaitENTER := True;
  Inputing := True;
  MainForm.OnPaint(NIL);
  while WaitENTER = True do
  begin
    Sleep(10);
    MainForm.ProcessMsg;
  end;
  Inputing := FALSE;
  Result := InputString;
end;

{ Вывести то, что ввел пользователь }
procedure ShowInput;
var
  OldStyle: TBrushStyle;
begin
  // Сообщения
  with GScreen.Canvas do
  begin
    Brush.Color := 0;
    Font.Color := MyRGB(160, 160, 160);
    Textout(InputX * CharX, InputY * CharY, InputString);
    if GetTickCount mod 1000 < 500 then
    begin
      OldStyle := Brush.Style;
      Brush.Style := bsClear;
      Font.Color := cLIGHTGREEN;
      Textout((InputX + (InputPos)) * CharX, InputY * CharY, '_');
      Brush.Style := OldStyle;
    end;
  end;
end;

// Цветная строка
procedure AddTextLine(X, Y: Word; msg: string);
var
  c, i, t: integer;
begin
  t := X;
  c := 0;
  with GScreen.Canvas do
    for i := 1 to Length(msg) do
    begin
      // Маркер в тексте (не показывается)
      case msg[i] of
        '$':
          begin
            if c = 0 then
              c := 1
            else
              c := 0;
            Continue;
          end;
        '#':
          begin
            if c = 0 then
              c := 2
            else
              c := 0;
            Continue;
          end;
        '*':
          begin
            if c = 0 then
              c := 3
            else
              c := 0;
            Continue;
          end;
      end;
      // Текущий цвет
      case c of
        0:
          Font.Color := cLIGHTGRAY;
        1:
          Font.Color := cORANGE;
        2:
          Font.Color := cGREEN;
        3:
          Font.Color := cGRAY;
      end;
      Textout(t * CharX, Y * CharY, msg[i]);
      inc(t);
    end;
end;

end.
