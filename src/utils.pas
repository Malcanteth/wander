unit utils;

interface

uses
  SysUtils, Main, Cons, Windows, Graphics, JPEG, Classes;

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
procedure DrawBorder(x,y,w,h,color : byte);      // ����� ��� ���. � ��������
function ExistFile(n : string) : boolean;        // ��������� �� ����� ����?
function ReturnColor(Rn,n : integer;
                          ow : byte) : integer;  // ������� ���� � ����������� �� ���������
function ReturnInvAmount : byte;                 // ������� ����������� ��������� � ���������
function ReturnInvListAmount : byte;             // ������� ����������� ��������������� ��������� � ���������
function WhatToDo(vid : integer) : string;       // ����� '������������' ��� ������ ����� ���������
procedure TakeScreenShot;                        // ������� ��������
function Eq2Vid(cur : byte) : byte;              // ��� ���� ��������������� ��������� ������ ����������
function Vid2Eq(vid : byte) : byte;              // ����� ������ � ���������� ��� ����� ���� ��������
function Rand(A, B: Integer): Integer;           // ��������� ����� ����� �� ���������
function GenerateName(female : boolean) : string;// ��������� �����
function BarWidth(Cx, Mx, Wd: Integer): Integer; // ������ ����
procedure BlackWhite(var AnImage: TBitMap);      // ������������� � �/�
function GetDungeonModeMapName : string;         // ������������ �������� ����������
procedure ChangeGameState(NewState : byte);      // �������� ��������� ����
procedure StartGameMenu;                         // ���������� ������� ����
procedure DrawBG;                                // ��� �����

implementation

uses
  Player, Monsters, Map, Items, Msg, conf, sutils, vars, pngimage;

{ ���� }
function MyRGB(R,G,B : byte) : LongWord;
begin
  Result := (r or (g shl 8) or (b shl 16));
end;

{ ������� ���� }
function RealColor(c : byte) : longword;
begin
  Result := 255;
  case c of
    crRANDOM      : Result := MyRGB(Random(155)+100, Random(155)+100, Random(155)+100);
    crBLACK       : Result := cBLACK;
    crBLUE        : Result := cBLUE;
    crGREEN       : Result := cGREEN;
    crRED         : Result := cRED;
    crCYAN        : Result := cCYAN;
    crPURPLE      : Result := cPURPLE;
    crBROWN       : Result := cBROWN;
    crWHITE       : Result := cWHITE;
    crGRAY        : Result := cGRAY;
    crYELLOW      : Result := cYELLOW;
    crLIGHTGRAY   : Result := cLIGHTGRAY;
    crLIGHTRED    : Result := cLIGHTRED;
    crLIGHTGREEN  : Result := cLIGHTGREEN;
    crLIGHTBLUE   : Result := cLIGHTBLUE;
    crORANGE      : Result := cORANGE;
    crBLUEGREEN   : Result := cBLUEGREEN;
    crRANDOMRED   : Result := MyRGB(Random(155)+100, 40, 40);
    crRANDOMBLUE  : Result := MyRGB(40, 40, Random(155)+100);
    crRANDOMGREEN : Result := MyRGB(40, Random(155)+100, 40);
  end;
end;

{ ������� ���� ������ }
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
      else Result := false;
end;

{ ������� ����� ���������� }
{ TODO -oPD -cminor : ���������� }
procedure DeleteSwap;
var
  s : TSearchRec;
  f : file;
begin
  while FindFirst(Path + 'swap/' + pc.name+'/*.lev', faAnyFile, s) = 0 do
  begin
    AssignFile(f, Path + 'swap/' + pc.name + '/' + s.name);
    {$I-}
    CloseFile(f);
    Erase(f);
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
  DrawBG;
  with GScreen.Canvas do
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
procedure DrawBorder(x,y,w,h,color : byte);
var
  i : byte;
begin
  with GScreen.Canvas do
  begin
    Font.Color := RealColor(color);
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
  s, fname: string;    
  P: TPNGObject;
begin
  GetSystemTime(t);
  CreateDir(Path + 'screens');   
  if pc.name = '' then s := 'unknown' else s := pc.name;
  fname := '<FAIL>';
  fname := s + '_'+IntToStr(t.wYear)+IntToStr(t.wMonth)+IntToStr(t.wDay)+IntToStr(t.wHour)+IntToStr(t.wMinute)+IntToStr(t.wSecond);
  // PNG
  P := TPNGObject.Create;
  try
    P.Assign(GScreen);
    P.SaveToFile(Path + 'screens/' + fname + '.png');
  finally
    P.Free;
  end;
  AddMsg('#������ ��������# ($'+fname+'$).',0);
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

{ ����� ������ � ���������� ��� ����� ���� �������� }
function Vid2Eq(vid : byte) : byte;
begin
  Result := 0;
  case vid of
    1 : Result := 1; // ����
    2 : Result := 2; // ������
    3 : Result := 3; // ����
    4 : Result := 4; // ����� �� ����
    5 : Result := 5; // ������
    6 : Result := 6; // ������ �������� ���
    7 : Result := 7; // ������ �������� ���
    8 : Result := 8; // ���
    9 : Result := 9; // �������
    10: Result := 10; // ������
    11: Result := 11; // ��������
    12: Result := 12; // �����
    13: Result := 13; // ���������
  end;
end;

{ ��������� ����� ����� �� ��������� }
function Rand(A, B: Integer): Integer;
begin
  Result := Round(Random(B - A + 1) + A);
end;

// ������ ����
function BarWidth(Cx, Mx, Wd: Integer): Integer;
var
  I: Integer;
begin
  if (Mx <=0) then Mx := 1;
  I := (Cx * Wd) div Mx;
  if I <= 0 then I := 0;
  if (Cx >= Mx) then I := Wd;
  Result := I;
end;

{ ��������� ���������� ����� }
function GenerateName(female : boolean) : string;
var
  s : string;
  procedure Add2; // ������ ����
  begin
    case Rand(1, 10) of
       1: S := S + '��';
       2: S := S + '��';
       3: S := S + '��';
       4: S := S + '��';
       5: S := S + '��';
       6: S := S + '��';
       7: S := S + '��';
       8: S := S + '��';
       9: S := S + '��';
      10: S := S + '��';
    end;
  end;
  procedure Add3; // ������ ����
  begin
    case Rand(1, 8) of
       1: S := S + '��';
       2: S := S + '�';
       3: S := S + '�';
       4: S := S + '�';
       5: S := S + '�';
       6: S := S + '��';
       7: S := S + '��';
       8: S := S + '��';
    end;
  end;
begin
  case Rand(1, 11) of
     1: S := '��';
     2: S := '��';
     3: S := '���';
     4: S := '���';
     5: S := '���';
     6: S := '���';
     7: S := '���';
     8: S := '���';
     9: S := '���';
    10: S := '��';
    11: S := '���';
  end;
  case Rand(1, 3) of
    1 : Add2;
    2 :
    begin
      Add2;
      Add3;
    end;
    3 : Add3;
  end;
  // ������� ���
  if Female then
  case Rand(1, 3) of
     1: S := S + '��';
     2: S := S + '��';
     3: S := S + '��';
  end;
  Result := S;
end;

{ ������� �������� � �������� ������ }
procedure BlackWhite(var AnImage: TBitMap);
var
  JPGImage: TJPEGImage;
  BMPImage: TBitmap; 
  MemStream: TMemoryStream;
begin 
  BMPImage := TBitmap.Create; 
  try 
    BMPImage.Width  := AnImage.Width;
    BMPImage.Height := AnImage.Height;
    JPGImage := TJPEGImage.Create;
    try
      JPGImage.Assign(AnImage);
      JPGImage.CompressionQuality := 100;
      JPGImage.Compress;
      JPGImage.Grayscale := True;
      BMPImage.Canvas.Draw(0, 0, JPGImage);
      MemStream := TMemoryStream.Create;
      try
        BMPImage.SaveToStream(MemStream);
        MemStream.Position := 0;
        AnImage.LoadFromStream(MemStream);
      finally
        MemStream.Free;
      end;
    finally
      JPGImage.Free;
    end;
  finally
    BMPImage.Free;
  end;
end;

{ ������������ �������� ���������� }
function GetDungeonModeMapName : string;
var
  S : string;
begin
  // �� ������� ���������� ������� ��� �������� (7 ��������)
  case pc.depth of
     1: S := '�������';
     2: S := '�����';
     3: S := '����';
     4: S := '����';
     5: S := '����';
     else
        S := '������';
  end;
  // ������������� (����� ����� - 10 ������ (�����. ������ �������))
  case Rand(1, 22) of
     1: S := S + ' ����';
     2: S := S + ' ������';
     3: S := S + ' ������';
     4: S := S + ' ���������';
     5: S := S + ' ����';
     6: S := S + ' ������';
     7: S := S + ' ���������';
     8: S := S + ' ���������';
     9: S := S + ' ����';
    10: S := S + ' �������';
    11: S := S + ' �����';
    12: S := S + ' ������';
    13: S := S + ' ��������';
    14: S := S + ' ����';
    15: S := S + ' �������';
    16: S := S + ' ������';
    17: S := S + ' �����';
    18: S := S + ' ������';
    19: S := S + ' ������';
    20: S := S + ' ���������';
    21: S := S + ' �������';
    22: S := S + ' �������';
  end;
  Result := S;
end;

{ �������� ��������� ���� }
procedure ChangeGameState(NewState : byte);
begin
  LastGameState := GameState;
  GameState := NewState;
end;

{ ���������� ������� ���� }
procedure StartGameMenu;
begin
  GameMenu := TRUE;
  MenuSelected := 1;
end;

{ ��� ����� }
procedure DrawBG;
var
  X, Y: Byte;
begin
  with GScreen.Canvas do
  begin
    for X := 1 to WindowX do
      for Y := 1 to WindowY do
      begin
        // ������� ������
        Brush.Color := Darker(RealColor(crRANDOMBLUE), 95);
        TextOut((x - 1) * CharX, (y - 1) * CharY, ' ');
      end;
  end;
end;

end.
