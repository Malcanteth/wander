unit utils;

interface

uses
  SysUtils, Cons, Windows, Graphics, JPEG, Classes;

type
  PInt = ^TInt;

  TInt = record
    N: integer;
    next: PInt;
  end;

  TIntQueue = class
    Front, Tail: PInt;
  public
    Count: integer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function IsEmpty: boolean;
    procedure Push(AnInt: integer);
    function Pop: integer;
    function GetFront(var AnInt: integer): boolean;
    function InList(AnInt: integer): boolean;
    function IndexOf(AnInt: integer): integer;
  end;

  TMenu = class
  private
    _F: TStringList;
    X,Y,Pos: byte;
    Sel: char;
    ForeColor, BgColor, SelColor: LongWord;
    function getSelected: byte;
  public
    constructor Create(ax,ay: byte; aSel: char = '>'; aForeColor: LongInt = cCYAN;
                       aBgColor: LongInt = cBROWN; aSelColor: LongInt = cYELLOW);
    property Selected: byte read getSelected;
    procedure Add(s: String);
    procedure Draw;
    function Run(Start: byte = 1): byte;
    destructor Destroy;
  end;

function MyRGB(R,G,B : byte) : LongWord;         // ����
function RealColor(c : byte) : longword;
function Darker(Color:TColor; Percent:Byte):TColor;
function GetRValue(rgb: LONGWORD): Byte;         // ������� ������� ����
function GetGValue(rgb: LONGWORD): Byte;         // ������� ������� ����
function GetBValue(rgb: LONGWORD): Byte;         // ������� ����� ����
procedure DrawBar(x,y,l: word; c1,c2: LONGWORD); //��������� ������� ��������/����/�����/��� ����-��
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
procedure Intro;                                 // ��������
function Rand(A, B: Integer): Integer;           // ��������� ����� ����� �� ���������
function GenerateName(female : boolean) : string;// ��������� �����
function BarWidth(Cx, Mx, Wd: Integer): Integer; // ������ ����
procedure BlackWhite(var AnImage: TBitMap);      // ������������� � �/�
function GetDungeonModeMapName : string;         // ������������ �������� ����������
procedure ChangeGameState(NewState : byte);      // �������� ��������� ����
procedure StartGameMenu;                         // ���������� ������� ����

implementation

uses
  Main, Player, Monsters, Map, Items, Msg, conf, sutils, vars, script, pngimage, wlog, help;

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

procedure DrawBar(x,y,l: word; c1,c2: LONGWORD); //��������� ����� ��������/����/�����/��� ����-��
var i,j: word;
  StartRGB, EndRGB: array[0..2] of Byte; // ����������� ����
  ax, ay, Colors, Delta: Word; // ����� ������, ������� ������������ ��� ���������
begin
  with Screen.Canvas do
  begin
    Pen.Width := 9;
    ax :=  x*CharX+(CharX div 2);
    ay := y*CharY+(CharY div 2);
    if (c1 = c2)or(l=0) then
    begin
      Pen.Color := c1;
      MoveTo(ax, ay);
      LineTo(ax+l, ay);
    end
    else
    begin
      StartRGB[0] := GetRValue(c1);
      StartRGB[1] := GetGValue(c1);
      StartRGB[2] := GetBValue(c1);
      EndRGB[0] := GetRValue(c2);
      EndRGB[1] := GetGValue(c2);
      EndRGB[2] := GetBValue(c2);
      Colors := l div 2; // ����� �������� �� ������
      Delta := l div Colors; // ����� �������� ��� ����� ��������
      For i := 0 to Colors do
      begin
        Pen.Color := RGB((StartRGB[0] + MulDiv(i, EndRGB[0] - StartRGB[0], Colors-1)),
                         (StartRGB[1] + MulDiv(i, EndRGB[1] - StartRGB[1], Colors-1)),
                         (StartRGB[2] + MulDiv(i, EndRGB[2] - StartRGB[2], Colors-1)));
        MoveTo(ax+i*delta, ay);
        LineTo(ax+i*delta, ay);
      end;
    end;
  end;
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
procedure DrawBorder(x,y,w,h,color : byte);
var
  i, j: byte;
begin
  with Screen.Canvas do
  begin
    Font.Color := RealColor(color);
    TextOut(x*CharX,y*CharY,Frame[5]);
    TextOut((x+w)*CharX,y*CharY,Frame[6]);
    TextOut(x*CharX,(y+h)*CharY,Frame[7]);
    TextOut((x+w)*CharX,(y+h)*CharY,Frame[8]);
    for i:=x+1 to x+w-1 do
    begin
      TextOut(i*CharX,y*CharY,Frame[1]);
      TextOut(i*CharX,(y+h)*CharY,Frame[3]);
    end;
    for i:=y+1 to y+h-1 do
    begin
      TextOut(x*CharX,i*CharY,Frame[2]);
      TextOut((x+w)*CharX,i*CharY,Frame[4]);
    end;
    for i := y + 1 to y + h - 1 do
      for j := x + 1 to x + w - 1 do
        TextOut(j*CharX,i*CharY,' ');
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
    P.Assign(Screen);
    P.SaveToFile(Path + 'screens/' + fname + '.png');
  finally
    P.Free;
  end;
  AddMsg('#������ ��������# ($'+fname+'$).',0);
  MainForm.Redraw;
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

{ �������� }
procedure Intro;
const
  up = 5;
  s0 = '#       #   #   #          #### #     ';
  s1 = ' #  #  #   ##   ##  # ###  #    ###   ';
  s2 = ' ## # ##  #  #  # # # #  # #### #  #  ';
  s3 = '  # # #   ####  #  ## #  # #    ###   ';
  s4 = '   ###   #    # #   # #  # #### #  #  ';
  s5 = '        #           # ###           # ';
begin
  MainForm.cls;
  with Screen.Canvas do
  begin
    // WANDER
    Font.Color := cLIGHTGRAY;
    TextOut(((WindowX-length(s0)) div 2) * CharX, up*CharY, s0);
    Font.Color := cLIGHTBLUE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, (up+1)*CharY, s1);
    Font.Color := cBLUE;
    TextOut(((WindowX-length(s2)) div 2) * CharX, (up+2)*CharY, s2);
    Font.Color := cBLUE;
    TextOut(((WindowX-length(s3)) div 2) * CharX, (up+3)*CharY, s3);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s4)) div 2) * CharX, (up+4)*CharY, s4);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s5)) div 2) * CharX, (up+5)*CharY, s5);
    // ������
    Font.Color := cBLUEGREEN;
    TextOut(34*CharY, (up+1)*CharY, GameVersion);
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
begin
  V.SetBool('GenName.Female', Female);
  Script.Run('GenName.pas');
  Result := Trim(V.GetStr('GenName.Name'));
end;

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
        //you need to reset the position of the MemoryStream to 0 
        MemStream.Position := 0; 

        AnImage.LoadFromStream(MemStream); 
        //AnImage.Refresh; 
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
begin
  V.SetInt('GenDungeon.Depth', PC.Depth);
  V.SetStr('GenDungeon.Name', '');
  Script.Run('GenDungeon.pas');
  Result := Trim(V.GetStr('GenDungeon.Name'));
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
  Intro;
  DrawGameMenu;
end;

{ ����� TIntQueue }

procedure InitPInt (var AnIntPtr: PInt; AVal: integer);
begin
  new(AnIntPtr);
  with AnIntPtr^ do begin
    N := AVal;
    next := nil;
  end;
end;

//PInt.prev is older item toward front of queue. PInt.next is new item toward rear of queue.
constructor TIntQueue.Create;
begin
  inherited Create;
  Front := nil;
  Tail := nil;
  Count := 0;
end;

destructor TIntQueue.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TIntQueue.Clear;
var Cur, Nxt: PInt;
begin
  Cur := Front;
  while Cur <> nil do begin
    Nxt := Cur^.next;
    dispose(Cur);
    Cur := Nxt;
  end;
  Front := nil;
  Count := 0;
end;

function TIntQueue.IsEmpty: boolean;
begin
  Result := (Front = nil);
end;

procedure TIntQueue.Push(AnInt: integer);
// only adds to the tail
var
  NewNode: PInt;
begin
  InitPInt(NewNode, AnInt);
  if Front = nil then
    Front := NewNode
  else
    Tail^.next := NewNode;
  Tail := NewNode;
  inc(Count);
end;

function TIntQueue.Pop: Integer;
// only can remove from the front
var oFront: PInt;
begin
  if Front <> nil then begin
    oFront := Front;
    Result := oFront^.N;
    Front := Front^.next;
    dispose(oFront);
    dec(Count);
  end;
end;

function TIntQueue.GetFront(var AnInt: integer): boolean;
begin
  Result := false;
  AnInt := 0;
  if Front <> nil then begin
    AnInt := Front^.N;
    Result := true;
  end;
end;

function TIntQueue.InList(AnInt: integer): boolean;
var Cur: PInt;
begin
  Result := false;
  Cur := Front;
  while (Cur <> nil) and (not Result) do begin
    if Cur^.N = AnInt then Result := true
    else Cur := Cur^.next;
  end;
end;

function TIntQueue.IndexOf(AnInt: integer): integer;
// returns the position of an integer in the Queue from the front, with 1 being the first and 0 being non existent
var
Found: boolean;
Cur: PInt;
begin
  Result := 0;
  Cur := Front;
  Found := false;
  while (Cur <> nil) and (not Found) do begin
    inc(Result);
    if Cur^.N = AnInt then Found := true
    else Cur := Cur^.next;
  end;
  if not Found then Result := 0;
end;

var
  EX: TExplodeResult;

{ TMenu }

procedure TMenu.Add(s: String);
begin
  _F.Add(s);
  Log('Added '+s);
end;

constructor TMenu.Create(ax, ay: byte; aSel: char = '>'; aForeColor: LongInt = cCYAN;
                       aBgColor: LongInt = cBROWN; aSelColor: LongInt = cYELLOW);
begin
  _F := TStringList.Create;
  x := ax;
  y := ay;
  Sel := aSel;
  ForeColor := aForeColor;
  BgColor := aBgColor;
  SelColor := aSelColor;
end;

destructor TMenu.Destroy;
begin
  _F.Free;
end;

procedure TMenu.Draw;
var i: byte;
begin
  if not(_F.Count = 0) then
    with Screen.Canvas do
    begin
      Brush.Color := cBlack;
      for i:= 0 to _F.Count-1 do
      begin
        Font.Color := BgColor;
        TextOut(x*CharX,(y+i)*charY,'[ ] ');
        Font.Color := ForeColor;
        TextOut((x+4)*CharX,(y+i)*charY,_F[i]);
      end;
      Font.Color := SelColor;
      TextOut((x+1)*CharX,(y+pos-1)*charY,'>');
    end;
  MainForm.Redraw;
end;

function TMenu.getSelected: byte;
begin
  Result := Pos;
end;

function TMenu.Run(Start: byte = 1): byte;
var Key : Word;
begin
  if Start = 0 then Start := 1;
  if Start > _F.Count then Start:=_F.Count;
  if Start = 0 then Result := 0 else
  begin
    Pos := Start;
    repeat
      Draw;
      Key := getKey;
      case Key of
        13: begin Result := Pos; break; end;
        27: begin Result := 0; break; end;
        VK_UP: if Pos > 1 then dec(Pos);
        VK_DOWN: if Pos < _F.Count then inc(Pos);
        VK_HOME: Pos := 1;
        VK_END: Pos := _F.Count;
      end;
    until false;
  end;
end;

initialization
  // ������ ����
  EX := Explode('.', FileVersion(Paramstr(0)));
  GameVersion := EX[0] + '.' + EX[1] + EX[2];
  if (strtoint(Ex[3]) in [1..27]) then GameVersion := GameVersion + chr(96+strtoint(Ex[3]));
end.
