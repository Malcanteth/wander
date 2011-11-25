unit msg;

interface

uses
  Main, Cons, Utils, SUtils, Controls, classes;

type
  THistory = record
    Msg : string;
    Amount : integer;
  end;

type TKey = record
  Key : word;
  Shift: TShiftState;
end;

var
  Msgs : array[1..MsgAmount] of string;
  History : array[1..MaxHistory] of THistory;
  InputX, InputY : integer;
  InputString : string;
  InputLength : byte;
  InputPos : byte;
  LastMsgY, LastMsgL : byte;


procedure AddMsg(s : string; id : integer);
function GetMsg(AString: String; gender : byte): string;
procedure AddDrawMsg(s : string; id : integer);
procedure ClearMsg;
procedure More;
procedure Apply;
procedure ShowMsgs;
function Ask(s: string): char;
function Input(sx,sy : integer; ss : string; MaxLen: byte = MsgLength-2): string;
procedure ShowInput;
procedure AddTextLine(X, Y: Word; Msg: string); // Цветная строка
function CreateKey(aKey: Word; aShift: TShiftState): TKey;

implementation

uses SysUtils, Conf, Player, Windows, Graphics, Monsters, wlog;

function CreateKey(aKey: Word; aShift: TShiftState): TKey;
begin
  with Result do
  begin
    Key := aKey;
    Shift := aShift;
  end;
end;

// Добавить сообщение
procedure AddMsg(s: string; id : integer);
var
  b : integer;

// Подпрограмма рекурсивно добавляет сообщения
procedure UseMsg(s: string; id : integer);
var
  a,i,j : byte;
  w,o : string;
begin
  if id < 2 then
    S := GetMsg(S, pc.gender) else
      S := GetMsg(S, MonstersData[id].gender);
  //Найти пустой слот
  for a:=1 to MsgAmount do
    if (Msgs[a] = '')and(a < MsgAmount) then
    begin
      w := s;
      o := '';
      //Длина сообщения слишком велика
      if Length(s) > MsgLength then
      begin
        for i:=Length(w) downto 1 do
        begin
          if (w[i] = ' ')and(i<=MsgLength)then
            break;
          delete(w,i,1);
          o := Copy(s,i,Length(s)-i+1);
        end;
      end;
      Msgs[a] := w;
      LastMsgY := a;
      LastMsgL := Length(w);
      // Добавить в историю
      if (w <> '') and (w <> ' ') then
      begin
        if History[MaxHistory].Msg = '' then
        begin
          for j:=1 to MaxHistory do
            if History[j].Msg = '' then
            begin
              if History[j-1].Msg = w then
                inc(History[j-1].Amount) else
                  begin
                    History[j].Msg := w;
                    History[j].Amount := 1;
                  end;
              break;
            end;
        end else
          begin
            if History[MaxHistory].Msg = w then
              inc(History[MaxHistory].Amount) else
              begin
                for j:=2 to MaxHistory do
                  History[j-1] := History[j];
                History[MaxHistory].Msg := w;
                History[MaxHistory].Amount := 1;
              end;
          end;
      end;
      if o <> '' then UseMsg(o,id);
      break;
    end else
      if (Msgs[a] = '')and(a = MsgAmount) then    
      begin
        More;
        UseMsg(s,id);
        break;
      end;
end;

begin
  // Доб. сообщение
  UseMsg(S, ID);
  // Корректируем сообщение в зависимости от пола
  if id < 2 then
    S := GetMsg(S, pc.gender) else
      S := GetMsg(S, MonstersData[id].gender);
  // Исключаем служебные символы
  for b:=1 to Length(s) do
    if (s[b] = '*') or (s[b] = '$') or (s[b] = '#') then
      Delete(s,b,1);  
end;

(* Вернуть окончание в зависимости от пола героя {/Ж} или {М/Ж} *)
function GetMsg(AString: String; gender : byte): string;
var
  I: Integer;
  SX, RX, S1, S2: String;
  RF: Byte;
begin
  if Gender = 10 then Gender := pc.gender;
  SX := '';
  RX := '';
  RF := 0;
  for I := 1 to Length(AString) do
  begin
    case AString[I] of
      '{': begin
             RF := 1;
             Continue;
           end;
      '}': RF := 2;
    end;
    case RF of
      0: RX := RX + AString[I];
      1: SX := SX + AString[I];
      2: begin
           S1 := GetStrKey('/',SX,);
           S2 := GetStrValue('/',SX);
           SX := '';
           RF := 0;
           if (Gender = genFEMALE) then RX := RX + S2 else RX := RX + S1;
         end;
    end;
  end;
  Result := RX;
end;

{ Добавить сообщение и отобразить}
procedure AddDrawMsg(s: string; id : integer);
begin
  AddMsg(s,id);
  MainForm.OnPaint(NIL);
end;

{ Очистить все сообщения }
procedure ClearMsg;
var
  i : byte;
begin
  for i:=1 to MsgAmount do
    Msgs[i] := '';
end;

function getKey: word;
var Key: word;
begin
  if KeyQueue.isEmpty then Key := 0 else Key := KeyQueue.Pop;
  while Key = 0 do
  begin
    Sleep(10);
    MainForm.ProcessMsg;
    if KeyQueue.isEmpty then Key := 0 else Key := KeyQueue.Pop;
  end;
  Result := Key;
//  Log(inttostr(Key)); //удобно смотреть коды клавиш в консоли)))
end;

{ Дальше }
procedure More;
var Key : Word;
begin
  Msgs[MsgAmount] := '$(Дальше)$';
  MainForm.OnPaint(NIL);
  Inputing := true;
  while not (GetKey in [13,32]) do;
  Inputing := false;
  ClearMsg
end;

{ Ждем нажатия ENTER }
procedure Apply;
begin
  Msgs[MsgAmount] := '$(Нажми ENTER для продолжения)$';
  MainForm.OnPaint(NIL);
  Inputing := true;
  while not GetKey = 13 do;
  Inputing := false;
  ClearMsg
end;

{ Показать сообщения }
procedure ShowMsgs;
var
  x,y,c,t : byte;
begin
  //Сообщения
  with Screen.Canvas do
  begin
    Font.Name := FontMsg;
    Brush.Color := 0;
    c := 0;
    for y:=1 to MsgAmount do
      if Msgs[y] <> '' then
      begin
        t := 1;
        for x:=1 to Length(Msgs[y]) do
        begin
          //Символы начала и конца цвета
          if Msgs[y][x] = '$' then  // желтый
          begin
            if c = 0 then c := 1 else c := 0;
          end else
          if Msgs[y][x] = '*' then  // красный
          begin
            if c= 0 then c := 2 else c := 0;
          end else
          if Msgs[y][x] = '#' then  // зеленый
          begin
            if c= 0 then c := 3 else c := 0;
          end else
            begin
              //Цвет букв
              case c of
                0 : Font.Color := MyRGB(160,160,160);  //Серый
                1 : Font.Color := MyRGB(255,255,0);    //Желтый
                2 : Font.Color := MyRGB(200,0,0);      //Красный
                3 : Font.Color := MyRGB(0,200,0);      //Зеленый
              end;
              Textout((t-1)*CharX, (MapY*CharY)+((y-1)*CharY), Msgs[y][x]);
              inc(t);
            end;
        end;
      end;
  end;
end;

{ Задать вопрос }
function Ask(s : string) : char;
begin
  AddDrawMsg(s,0);
  Inputing := true;
  Result := UpCase (Chr(GetKey));
  Inputing := false;  
end;

function GetCharFromVirtualKey(Key: Word): string;
var
  keyboardState: TKeyboardState;
  asciiResult: Integer;
begin
  GetKeyboardState(keyboardState) ;
  SetLength(Result, 2) ;
  asciiResult := ToAscii(key, MapVirtualKey(key, 0), keyboardState, @Result[1], 0) ;
  case asciiResult of
    0: Result := '';
    1: SetLength(Result, 1) ;
    2:;
  else
    Result := '';
  end;
end;

{ Функция ввода текста пльзователем }
function Input(sx,sy : integer; ss : string; MaxLen: byte = MsgLength-2) : string;
var Key : Word;
  n : string;
begin
  InputString := ss;
  InputPos := Length(ss);
  InputX := sx;
  InputY := sy;
  InputLength := MaxLen;
  Inputing := TRUE;
  MainForm.GameTimer.Enabled := true;
  MainForm.OnPaint(NIL);
  repeat
    Key := getKey;
    if Key = 13 then
      break
    else
    if (Key = VK_BACK) and (InputPos > 0) then
    begin
      Delete(InputString,InputPos,1);
      dec(InputPos);
    end
    else if (Key = VK_DELETE) and (InputPos < Length(InputString)) then
    begin
      Delete(InputString,InputPos+1,1);
    end
    else if Key = VK_HOME then
      InputPos := 0
    else if Key = VK_END then
      InputPos := length(InputString)
    else if (Key = VK_LEFT) and (InputPos > 0) then
      dec(InputPos)
    else if (Key = VK_RIGHT) and (InputPos < Length(InputString)) then
      inc(InputPos)
    else if length(InputString)<InputLength then
    begin
      n := GetCharFromVirtualKey(Key);
      if n<>'' then
      begin
        if ord(n[1]) > 31 then
        begin
          Insert(n, InputString, InputPos+1);
          Inc(InputPos);
        end;
      end;
    end;
    if (GameState = gsConsole) then
    case Key of
      VK_ESCAPE, 192: begin InputString := ''; break; end;
      VK_UP: if LogPos > 0 then dec(LogPos);
      VK_DOWN: if LogPos < 250 then inc(LogPos);
    end;
    MainForm.OnPaint(NIL);
  until false;
  MainForm.GameTimer.Enabled := false;
  Inputing := false;
  Result := InputString;
end;

{ Вывести то, что ввел пользователь }
procedure ShowInput;
var OldStyle : TBrushStyle;
begin
  //Сообщения
  with Screen.Canvas do
  begin
    Brush.Color := 0;
    Font.Color := MyRGB(160,160,160);
    Textout(InputX*CharX, InputY*CharY, InputString);
    if GetTickCount mod 1000 < 500 then
    begin
      OldStyle := Brush.Style;
      Brush.Style := bsClear;
      Font.Color := cLIGHTGREEN;
      Textout((InputX+(InputPos))*CharX, InputY*CharY, '_');
      Brush.Style := OldStyle;
    end;
  end;
end;

// Цветная строка
procedure AddTextLine(X, Y: Word; Msg: string);
var
  C, I, T: Integer;
begin
  T := X;
  C := 0;
  with Screen.Canvas do
  for I := 1 to Length(Msg) do
  begin
    // Маркер в тексте (не показывается)
    case Msg[I] of
      '$': begin if C = 0 then C := 1 else C := 0; Continue; end;
      '#': begin if C = 0 then C := 2 else C := 0; Continue; end;
      '*': begin if C = 0 then C := 3 else C := 0; Continue; end;
    end;
    // Текущий цвет
    case C of
      0 : Font.Color := cLIGHTGRAY;
      1 : Font.Color := cORANGE;
      2 : Font.Color := cGREEN;
      3 : Font.Color := cGRAY;
    end;
    Textout(T*CharX, Y*CharY, Msg[I]);
    Inc(T);
  end;
end;

end.



