unit utils;

interface

uses
  SysUtils, Main, Cons, Windows, Graphics;

function MyRGB(R,G,B : byte) : LongWord;         // ����
function RealColor(c : byte) : longword;
function Darker(Color:TColor; Percent:Byte):TColor;
function GetRValue(rgb: LONGWORD): Byte;         // ������� ������� ����
function GetGValue(rgb: LONGWORD): Byte;         // ������� ������� ����
function GetBValue(rgb: LONGWORD): Byte;         // ������� ����� ����
function InFov(x1,y1,x2,y2,los : byte) : boolean;// ����������� �� ������� ���������?
procedure DeleteSwap;                            // ������� ����� ����������
function IsFlag(flags : LongWord;
                 flag : LongWord) : boolean;     // �������� �����
procedure StartDecorating(header : string;
                    withoutexit : boolean);      // �������, ��������
procedure DrawBorder(x,y,w,h : byte);            // ����� ��� ���. � ��������
function ExistFile(n : string) : boolean;        // ��������� �� ����� ����?
function ReturnColor(Rn,n : integer;
                          ow : byte) : integer;  // ������� ���� � ����������� �� ���������
function ReturnInvAmount : byte;                 // ������� ����������� ��������� � ���������
function ReturnInvListAmount : byte;             // ������� ����������� ��������������� ��������� � ���������
function WhatToDo(vid : integer) : string;       // ����� '������������' ��� ������ ����� ���������
procedure TakeScreenShot;                        // ������� ��������
function Eq2Vid(cur : byte) : byte;              // ��� ���� ��������������� ��������� ������ ����������
procedure Intro;                                 // ��������
function WhatClass : byte;                       // ������� ����� ������ �����
function CLName : string;                        // ������� �������� ������
function ClassColor : longword;                  // ���� ������
function Rand(A, B: Integer): Integer;           // ��������� ����� ����� �� ���������
function GenerateName(female : boolean) : string; // ��������� �����

implementation

uses
  Player, Monsters, Map, Items, Msg, conf;

{ ���� }
function MyRGB(R,G,B : byte) : LongWord;
begin
  Result := (r or (g shl 8) or (b shl 16));
end;

function RealColor(c : byte) : longword;
begin
  Result := 255;
  case c of
    crRANDOM : Result := MyRGB(Random(155)+100, Random(155)+100, Random(155)+100);
    crBLACK  : Result := cBLACK;
    crBLUE   : Result := cBLUE;
    crGREEN  : Result := cGREEN;
    crRED    : Result := cRED;
    crCYAN   : Result := cCYAN;
    crPURPLE : Result := cPURPLE;
    crBROWN   : Result := cBROWN;
    crWHITE   : Result := cWHITE;
    crGRAY    : Result := cGRAY;
    crYELLOW  : Result := cYELLOW;
    crLIGHTGRAY : Result := cLIGHTGRAY;
    crLIGHTRED   : Result := cLIGHTRED;
    crLIGHTGREEN : Result := cLIGHTGREEN;
    crLIGHTBLUE  : Result := cLIGHTBLUE;
    crORANGE    : Result := cORANGE;
    crBLUEGREEN : Result := cBLUEGREEN;
  end;
end;

function Darker(Color:TColor; Percent:Byte):TColor;
var
  r,g,b:Byte;
begin
Color:=ColorToRGB(Color);
r:=GetRValue(Color);
g:=GetGValue(Color);
b:=GetBValue(Color);
r:=r-muldiv(r,Percent,100);  //�������% ���������� �������
g:=g-muldiv(g,Percent,100);
b:=b-muldiv(b,Percent,100);
result:=RGB(r,g,b);
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
  if (x1>0)and(x1<=MapX)and(y1>0)and(y1<=MapY)and(x2>0)and(x2<=MapX)and(y2>0)and(y2<=MapY)
    then Result := Round(SQRT(SQR(x1-x2)+SQR(y1-y2))) < los
{  begin
    if Round(SQRT(SQR(x1-x2)+SQR(y1-y2))) >= los then
      Result := false else
        Result := true;
  end  }
    else Result := false;
end;

{ ������� ����� ���������� }
procedure DeleteSwap;
var
  s : TSearchRec;
  f : file;
begin
  while FindFirst(Path + 'swap/' + pc.name+'/*.lev', faAnyFile, s) = 0 do
  begin
    AssignFile(f, Path + 'swap/' + pc.name + '/' + s.name);
    {$I-}
    Erase(f);
    CloseFile(f);
    {$I+}
    FindNext(s);
  end;
  {$I-}
  RemoveDir(Path + 'swap/' + pc.name);
  RemoveDir(Path + 'swap');
  {$I+}
end;

{ �������� ����� }
function IsFlag(flags : LongWord; flag : LongWord) : boolean;
begin
  if flags and flag > 0 then
    Result := true else
      Result := false;
end;

{ �������, �������� }
procedure StartDecorating(header : string; withoutexit : boolean);
const
  space  = '-=[ ����� ������ ��� ������ ]=-';
var
  i : byte;
begin
  with Screen.Canvas do
  begin
    For i:=1 to Round(WindowX/2) do
    begin
      Font.Color := Darker(cGRAY,100-i);
      TextOut((i-1)*CharX,0,'=');
      TextOut((i-1)*CharX,CharY*(WindowY-1),'=');
    end;
    For i:=Round(WindowX/2) to WindowX do
    begin
      Font.Color := Darker(cGRAY,i);
      TextOut((i-1)*CharX,0,'=');
      TextOut((i-1)*CharX,CharY*(WindowY-1),'=');
    end;
    Font.Color := cYELLOW;
    TextOut(((WindowX-length(header)) div 2) * CharX, 0, header);
    if withoutexit = FALSE then
    begin
      Font.Color := cBROWN;
      TextOut(((WindowX-length(space)) div 2) * CharX, CharY*(WindowY-1), space);
    end;
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

{ ������� ����������� ��������������� ��������� � ��������� }
function ReturnInvListAmount : byte;
var
  i : byte;
begin
  for i:=1 to MaxHandle do
    if InvList[i] = 0 then
      break;
  Result := i-1;
end;

{ ����� '������������' ��� ������ ����� ��������� }
function WhatToDo(vid : integer) : string;
begin
  case vid of
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
    13: Result := '������������'; // ���������
    14: Result := '������'; // ���
    15: Result := '�����������'; // ������
    16: Result := '������'; // ������
    17: Result := '������'; // �����
    18: Result := '���������'; // ��������� �������
    19: Result := '������'; // �����
    20: Result := '������������'; // ����������
  end;
end;

{ ������� �������� (F5)}
procedure TakeScreenShot;
var
  t : TSystemTime;
  s: string;
begin
  GetSystemTime(t);
  CreateDir(Path + 'screens');
  if pc.name = '' then s := 'unknown' else s := pc.name;
  Screen.SaveToFile(Path + 'screens/' + s + '_'+IntToStr(t.wYear)+IntToStr(t.wMonth)+IntToStr(t.wDay)+IntToStr(t.wHour)+IntToStr(t.wMinute)+IntToStr(t.wSecond)+'.bmp');
  AddMsg('[��������...]',0);
  MainForm.OnPaint(NIL);
end;

{ ��� ���� ��������������� ��������� ������ ���������� }
function Eq2Vid(cur : byte) : byte;
begin
  Result := 0;
  case cur of
    1  : Result := 1;
    2  : Result := 2;
    3  : Result := 3;
    4  : Result := 4;
    5  : Result := 5;
    6  : Result := 6;
    7  : Result := 7;
    8  : Result := 8;
    9  : Result := 9;
    10 : Result := 10;
    11 : Result := 11;
    12 : Result := 12;
    13 : Result := 13;
  end;
end;

{ �������� }
procedure Intro;
const
  s0 = '#       #   #   #          #### #     ';
  s1 = ' #  #  #   ##   ##  # ###  #    ###   ';
  s2 = ' ## # ##  #  #  # # # #  # #### #  #  ';
  s3 = '  # # #   ####  #  ## #  # #    ###   ';
  s4 = '   ###   #    # #   # #  # #### #  #  ';
  s5 = '        #           # ###           # ';
  s6 = '< ����� ENTER ��� ����, ����� ������ >';
begin
  with Screen.Canvas do
  begin
    // WANDER
    Font.Color := cLIGHTGRAY;
    TextOut(((WindowX-length(s0)) div 2) * CharX, 14*CharY, s0);
    Font.Color := cLIGHTBLUE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
    Font.Color := cBLUE;
    TextOut(((WindowX-length(s2)) div 2) * CharX, 16*CharY, s2);
    Font.Color := cBLUE;
    TextOut(((WindowX-length(s3)) div 2) * CharX, 17*CharY, s3);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s4)) div 2) * CharX, 18*CharY, s4);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s5)) div 2) * CharX, 19*CharY, s5);
    // ������
    Font.Color := cPURPLE;
    TextOut(28*CharY, 21*CharY, '������ ' + GameVersion);
    // ������ ������
    Font.Color := cYELLOW;
    TextOut(((WindowX-length(s6)) div 2) * CharX, 25*CharY, s6);
    // �����
    Font.Color := cBROWN;
    case PlayMode of
      0 :TextOut(1, 41*CharY, '����� ����: "�����������" (''C'' ����� ��������)');
      1 :TextOut(1, 41*CharY, '����� ����: "����������"  (''C'' ����� ��������)');
    end;
  end;
end;

{ ������� ����� ������ ����� }
function WhatClass : byte;
begin
  Result := 0;
  case pc.atr[1] of
    1 : // ����
    case pc.atr[2] of
      1 : Result := 1;
      2 : Result := 2;
      3 : Result := 3;
    end;
    2 : // ��������
    case pc.atr[2] of
      1 : Result := 4;
      2 : Result := 5;
      3 : Result := 6;
    end;
    3 : // ���������
    case pc.atr[2] of
      1 : Result := 7;
      2 : Result := 8;
      3 : Result := 9;
    end;
  end;
end;

{ ������� �������� ������ }
function CLName : string;
begin
  case WhatClass of
    1 :
    case pc.gender of
      1 : Result := '����'; 
      2 : Result := '�����������';
    end;
    2 :
    case pc.gender of
      1 : Result := '������';
      2 : Result := '��������';
    end;
    3 :
    case pc.gender of
      1 : Result := '�������';
      2 : Result := '�������';
    end;
    4 :
    case pc.gender of
      1 : Result := '��������';
      2 : Result := '���������';
    end;
    5 :
    case pc.gender of
      1 : Result := '���';
      2 : Result := '�������';
    end;
    6 :
    case pc.gender of
      1 : Result := '�����';
      2 : Result := '��������';
    end;
    7 :
    case pc.gender of
      1 : Result := '����';
      2 : Result := '�����';
    end;
    8 :
    case pc.gender of
      1 : Result := '������';
      2 : Result := '��������';
    end;
    9 :
    case pc.gender of
      1 : Result := '���������';
      2 : Result := '�������������';
    end;
  end;
end;

{ ���� ������ }
function ClassColor : longword;
begin
  Result := 0;
  case WhatClass of
    1 : Result := cLIGHTBLUE;
    2 : Result := cORANGE;
    3 : Result := cLIGHTGRAY;
    4 : Result := cGREEN;
    5 : Result := cGRAY;
    6 : Result := cYELLOW;
    7 : Result := cBROWN;
    8 : Result := cPURPLE;
    9 : Result := cCYAN;
  end;
end;

{ ��������� ����� ����� �� ��������� }
function Rand(A, B: Integer): Integer;
begin
  Randomize;
  Result := Round(Random(B - A + 1) + A);
end;

function FileVersion(AFileName:string): string;
var
  szName: array[0..255] of Char;
  P: Pointer;
  Value: Pointer;
  Len: UINT;
  GetTranslationString:string;
  FFileName: PChar;
  FValid:boolean;
  FSize: DWORD;
  FHandle: DWORD;
  FBuffer: PChar;
begin
  try
   FFileName := StrPCopy(StrAlloc(Length(AFileName) + 1), AFileName);
   FValid := False;
   FSize := GetFileVersionInfoSize(FFileName, FHandle);
   if FSize > 0 then
     try
       GetMem(FBuffer, FSize);
       FValid := GetFileVersionInfo(FFileName, FHandle, FSize, FBuffer);
     except
       FValid := False;
       raise;
     end;
   Result := '';
   if FValid then
     VerQueryValue(FBuffer, '\VarFileInfo\Translation', p, Len)
   else p := nil;
   if P <> nil then
     GetTranslationString := IntToHex(MakeLong(HiWord(Longint(P^)), LoWord(Longint(P^))), 8);
   if FValid then
     begin
       StrPCopy(szName, '\StringFileInfo\' + GetTranslationString + '\FileVersion');
       if VerQueryValue(FBuffer, szName, Value, Len) then
         Result := StrPas(PChar(Value));
     end;
  finally
   try
     if FBuffer <> nil then FreeMem(FBuffer, FSize);
   except
   end;
   try
     StrDispose(FFileName);
   except
   end;
  end;
end;

{ ��������� ���������� ����� }
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

initialization
  GameVersion := FileVersion(Paramstr(0));

finalization

end.
