unit msg;

interface

uses
  Main, Cons, Utils;

var
  Msgs : array[1..MsgAmount] of string;


procedure AddMsg(s : string);
procedure AddDrawMsg(s : string);
procedure ClearMsg;
procedure More;
procedure Apply;
procedure ShowMsgs;
function Ask(s : string) : string;

implementation

{ Добавить сообщение }
procedure AddMsg(s : string);
var
  a,i : byte;
  w,o : string;
begin
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
      if o <> '' then AddMsg(o);
      break;
    end else
      if (Msgs[a] = '')and(a = MsgAmount) then
      begin
        More;
        AddMsg(s);
        break;
      end;
end;

{ Добавить сообщение и отобразить}
procedure AddDrawMsg(s : string);
begin
  AddMsg(s);
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

{ Дальше }
procedure More;
begin
  Msgs[MsgAmount] := '{(Дальше)}';
  MainForm.OnPaint(NIL);
  WaitMore := True;
  while WaitMore = True do
    MainForm.ProcessMsg;
  ClearMsg
end;

{ Ждем нажатия ENTER }
procedure Apply;
begin
  Msgs[MsgAmount] := '{(Нажми ENTER для продолжения)}';
  MainForm.OnPaint(NIL);
  WaitENTER := True;
  while WaitENTER = True do
    MainForm.ProcessMsg;
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
    Brush.Color := 0;
    for y:=1 to MsgAmount do
      if Msgs[y] <> '' then
      begin
        c := 0;
        t := 1;
        for x:=1 to Length(Msgs[y]) do
        begin
          //Символы начала и конца цвета
          if Msgs[y][x] = '{' then
            c := 1 else
          if Msgs[y][x] = '}' then
            c := 0 else
          if Msgs[y][x] = '<' then
            c := 2 else
          if Msgs[y][x] = '>' then
            c := 0 else
          if Msgs[y][x] = '[' then
            c := 3 else
          if Msgs[y][x] = ']' then
            c := 0 else
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
function Ask(s : string) : string;
begin
  AddDrawMsg(s);
  Answer := ' ';
  while Answer = ' ' do
    MainForm.ProcessMsg;
  Result := Answer;
  Answer := '';
end;

end.



