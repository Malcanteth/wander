unit msg;

interface

uses
  Main, Cons, Utils, SUtils;

type
  THistory = record
    Msg : string;
    Amount : integer;
  end;

var
  Msgs : array[1..MsgAmount] of string;
  History : array[1..MaxHistory] of THistory;
  InputX, InputY : integer;
  InputString : string[13];
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
function Input(sx, sy: integer; ss: string): string;
procedure ShowInput;

implementation

uses SysUtils, Conf, Player, Windows, Graphics, Monsters;

{ �������� ��������� }
procedure AddMsg(s: string; id : integer);
var
  a,i,j : byte;
  w,o : string;
begin
  if id < 2 then
    S := GetMsg(S, pc.gender) else
      S := GetMsg(S, MonstersData[id].gender);
  //����� ������ ����
  for a:=1 to MsgAmount do
    if (Msgs[a] = '')and(a < MsgAmount) then
    begin
      w := s;
      o := '';
      //����� ��������� ������� ������
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
      // �������� � �������
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
      if o <> '' then AddMsg(o,id);
      break;
    end else
      if (Msgs[a] = '')and(a = MsgAmount) then
      begin
        More;
        AddMsg(s,id);
        break;
      end;
end;

(* ������� ��������� � ����������� �� ���� ����� {/�} ��� {�/�} *)
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

{ �������� ��������� � ����������}
procedure AddDrawMsg(s: string; id : integer);
begin
  AddMsg(s,id);
  MainForm.OnPaint(NIL);
end;

{ �������� ��� ��������� }
procedure ClearMsg;
var
  i : byte;
begin
  for i:=1 to MsgAmount do
    Msgs[i] := '';
end;

{ ������ }
procedure More;
begin
  Msgs[MsgAmount] := '{(������)}';
  MainForm.OnPaint(NIL);
  WaitMore := True;
  while WaitMore = True do
    MainForm.ProcessMsg;
  ClearMsg
end;

{ ���� ������� ENTER }
procedure Apply;
begin
  Msgs[MsgAmount] := '{(����� ENTER ��� �����������)}';
  MainForm.OnPaint(NIL);
  WaitENTER := True;
  while WaitENTER = True do
    MainForm.ProcessMsg;
  ClearMsg
end;

{ �������� ��������� }
procedure ShowMsgs;
var
  x,y,c,t : byte;
begin
  //���������
  with Screen.Canvas do
  begin
    Font.Name := FontMsg;
    Brush.Color := 0;
    for y:=1 to MsgAmount do
      if Msgs[y] <> '' then
      begin
        c := 0;
        t := 1;
        for x:=1 to Length(Msgs[y]) do
        begin
          //������� ������ � ����� �����
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
            //���� ����
            case c of
              0 : Font.Color := MyRGB(160,160,160);  //�����
              1 : Font.Color := MyRGB(255,255,0);    //������
              2 : Font.Color := MyRGB(200,0,0);      //�������
              3 : Font.Color := MyRGB(0,200,0);      //�������
            end;
            Textout((t-1)*CharX, (MapY*CharY)+((y-1)*CharY), Msgs[y][x]);
            inc(t);
          end;
        end;
      end;
  end;
end;

{ ������ ������ }
function Ask(s : string) : char;
begin
  AddDrawMsg(s,0);
  Answer := ' ';
  while Answer = ' ' do
    MainForm.ProcessMsg;
  Result := Answer[1];
  Answer := '';
end;

{ ������� ����� ������ ������������ }
function Input(sx,sy : integer; ss : string) : string;
begin
  InputString := ss;
  InputPos := Length(ss);
  InputX := sx;
  InputY := sy;
  WaitENTER := True;
  Inputing := TRUE;
  MainForm.OnPaint(NIL);  
  while WaitENTER = True do
    MainForm.ProcessMsg;
  Inputing := FALSE;
  Result := InputString;
end;

{ ������� ��, ��� ���� ������������ }
procedure ShowInput;
var OldStyle : TBrushStyle;
begin
  //���������
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

end.


