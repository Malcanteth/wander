unit utils;

interface

uses
  SysUtils, Main, Cons;

function MyRGB(R,G,B : byte) : LongWord;         // ����
function GetRValue(rgb: LONGWORD): Byte;         // ������� ������� ����
function GetGValue(rgb: LONGWORD): Byte;         // ������� ������� ����
function GetBValue(rgb: LONGWORD): Byte;         // ������� ����� ����
function InFov(x1,y1,x2,y2,los : byte) : boolean;// ����������� �� ������� ���������?
procedure DeleteSwap;                            // ������� ����� ����������
function GenerateName(female : boolean) : string;// ��������� �����
function IsFlag(flags : LongWord;
                 flag : LongWord) : boolean;     // �������� �����
function HeSheIt(id,vid : byte) : string;        // ������� ��������� � ����������� �� ���� � ��������
procedure StartDecorating(header : string);      // �������, ��������
procedure DrawBorder(x,y,w,h : byte);            // ����� ��� ���. � ��������
function ExistFile(n : string) : boolean;        // ��������� �� ����� ����?
function ReturnColor(Rn,n : integer;
                          ow : byte) : integer;  // ������� ���� � ����������� �� ���������
function ReturnInvAmount : byte;                 // ������� ����������� ��������� � ���������
function WhatToDo(id : integer) : string;        // ����� '������������' ��� ������ ����� ���������

implementation

uses
  Player, Monsters, Map, Items;

{ ���� }
function MyRGB(R,G,B : byte) : LongWord;
begin
  Result := (r or (g shl 8) or (b shl 16));
end;

{ ������� ������� ���� }
function GetRValue(rgb: LONGWORD): Byte;
begin
  Result := Byte(rgb);
end;

{ ������� ������� ���� }
function GetGValue(rgb: LONGWORD): Byte;
begin
  Result := Byte(rgb shr 8);
end;

{ ������� ����� ���� }
function GetBValue(rgb: LONGWORD): Byte;
begin
  Result := Byte(rgb shr 16);
end;

{ ����������� �� ������� ���������? }
function InFov(x1,y1,x2,y2,los : byte) : boolean;
begin
  if (x1>0)and(x1<=MapX)and(y1>0)and(y1<=MapY)and(x2>0)and(x2<=MapX)and(y2>0)and(y2<=MapY)then
  begin
    if Round(SQRT(SQR(x1-x2)+SQR(y1-y2))) >= los then
      Result := false else
        Result := true;
  end else
    Result := false;
end;

{ ������� ����� ���������� }
procedure DeleteSwap;
var
  s : TSearchRec;
  f : file;
begin
  while FindFirst('swap/'+pc.name+'/*.lev',faAnyFile,s) = 0 do
  begin
    AssignFile(f,'swap/'+pc.name+'/'+s.name);
    {$I-}
    Erase(f);
    CloseFile(f);
    {$I+}
    FindNext(s);
  end;
  {$I-}
  RMDir('swap/'+pc.name);
  RMDir('swap');
  {$I+}
end;

{ ��������� ����� }
function GenerateName(female : boolean) : string;
const
  name1 : array[1..7]of string[3] = ('��','��','���','���','���','���','���');
  name2 : array[1..6]of string[2] = ('��','��','��','��','��','��');
  name3 : array[1..6]of string[3] = ('��','�','�','�','�','��');
  fends : array[1..3]of string[3] = ('��','��','��');
var
  s : string[40];
begin
  s := name1[random(7)+1];
  s := s + name2[random(6)+1];
  if random(2)+1 = 2 then
    s := s + name3[random(6)+1];
  if female then
    s := s + fends[random(3)+1];
  Result := s;
end;

{ �������� ����� }
function IsFlag(flags : LongWord; flag : LongWord) : boolean;
begin
  if flags and flag > 0 then
    Result := true else
      Result := false;
end;

{ ������� ��������� � ����������� �� ���� � �������� }
function HeSheIt(id,vid : byte) : string;
begin
  case vid of
    1:
    case MonstersData[id].gender of
      genMIDLE : Result := '�';
      genMALE  : Result := '';
      genFEMALE: Result := '�';
    end;
    2:
    case MonstersData[id].gender of
      genMIDLE : Result := '���';
      genMALE  : Result := '��';
      genFEMALE: Result := '���';
    end;
  end;
end;

{ �������, �������� }
procedure StartDecorating(header : string);
const
  space  = '-=[ ����� ������ ��� ������ ]=-';
var
  i : byte;
begin
  with Screen.Canvas do
  begin
    For i:=1 to WindowX do
    begin
      Font.Color := cGRAY;
      TextOut((i-1)*CharX,0,'=');
      TextOut((i-1)*CharX,CharY*(WindowY-1),'=');
    end;
    Font.Color := cYELLOW;
    TextOut(((WindowX-length(header)) div 2) * CharX, 0, header);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(space)) div 2) * CharX, CharY*(WindowY-1), space);
  end;
end;

{ ������� ��� ���������� � ��������}
procedure DrawBorder(x,y,w,h : byte);
var
  i : byte;
begin
  with Screen.Canvas do
  begin
    Font.Color := cGRAY;
    TextOut(x*CharX,y*CharY,'.');
    TextOut((x+w)*CharX,y*CharY,'.');
    TextOut(x*CharX,(y+h)*CharY,'''');
    TextOut((x+w)*CharX,(y+h)*CharY,'''');
    For i:=x+1 to x+w-1 do
    begin
      TextOut(i*CharX,y*CharY,'-');
      TextOut(i*CharX,(y+h)*CharY,'-');
    end;
    For i:=y+1 to y+h-1 do
    begin
      TextOut(x*CharX,i*CharY,'|');
      TextOut((x+w)*CharX,i*CharY,'|');
    end;
  end;
end;

{ ��������� �� ����� ����? }
function ExistFile(n : string) : boolean;
var
  f : file;
begin
  assign(f,n);
  {$I-}
  reset(f);
  {$I+}
  if IOResult=0 then
  begin
    close(f);
    Result := true;
  end else
    Result := false;
end;

{  ������� ���� � ����������� �� ��������� }
function ReturnColor(Rn, n : integer; ow : byte) : integer;
var
  x : integer;
begin
  Result := 255;
  case ow of
    1 : // ��������
    begin
      if Rn > 0 then
      begin
        x := Round((n*100)/Rn);
        case x of
          100      : Result := cGREEN;
          85..99   : Result := cLIGHTGREEN;
          50..84   : Result := cRED;
          1..49    : Result := cLIGHTRED
          else
                     Result := cGRAY;
        end;
      end else
        Result := cGRAY;
    end;
    2 : // ����
    begin
      if Rn > 0 then
      begin
        x := Round((n*100)/Rn);
        case x of
          100      : Result := cPURPLE;
          85..99   : Result := cBLUE;
          50..84   : Result := cLIGHTBLUE;
          20..49   : Result := cRED;
          1..19    : Result := cLIGHTRED
          else
                     Result := cGRAY;
        end;
      end else
        Result := cGRAY;
    end;
  end;
end;

{ ������� ����������� ��������� � ��������� }
function ReturnInvAmount : byte;
var
  i, kol  : byte;
begin
  kol := 0;
  for i:=1 to MaxHandle do
    if pc.inv[i].id > 0 then
      inc(kol) else
        break;
  Result := kol;
end;

{ ����� '������������' ��� ������ ����� ��������� }
function WhatToDo(id : integer) : string;
begin
  case ItemsData[id].vid of
    1 : Result := '������'; // ����
    2 : Result := '������'; // ������
    3 : Result := '������'; // ����
    4 : Result := '������'; // ����� �� ����
    5 : Result := '������'; // ������
    6 : Result := '�����������'; // ������ �������� ���
    7 : Result := '�����������'; // ������ �������� ���
    8 : Result := '������������'; // ���
    9 : Result := '������'; // �������
    10: Result := '������'; // ������
    11: Result := '������'; // ��������
    12: Result := '������'; // �����
    13: Result := '������'; // ���������
    14: Result := '������'; // ���
    15: Result := '�����������'; // ������
    16: Result := '������'; // ������
    17: Result := '������'; // �����
    18: Result := '���������'; // ��������� �������
    19: Result := '������'; // �����
    20: Result := '������������'; // ����������
  end;
end;

end.
