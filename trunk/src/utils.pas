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

  TCallback = procedure(Index: byte);

  TMenu = class
  private
    _F: TStringList;
    X,Y,Pos: byte;
    Sel: char;
    ForeColor, BgColor, SelColor: LongWord;
    CallBackProc : TCallback;
    BreakKey : word;
    function getSelected: byte;
    function getCount: byte;
  public
    constructor Create(ax,ay: byte; aSel: char = '>'; aForeColor: LongInt = cCYAN;
                       aBgColor: LongInt = cBROWN; aSelColor: LongInt = cYELLOW);
    property Selected: byte read getSelected;
    property Count: byte read getCount;
    procedure Add(s: String); overload;
    procedure Add(s: String; c: LongInt); overload;
    procedure addBreakKey(Key: word);
    procedure Draw;
    procedure setCallback(newCallback: TCallback);
    function Run(Start: byte = 1): byte;
    destructor Destroy;
  end;

function MyRGB(R,G,B : byte) : LongWord;         // Цвет
function RealColor(c : byte) : longword;
function Darker(Color:TColor; Percent:Byte):TColor;
function GetRValue(rgb: LONGWORD): Byte;         // Достать красный цвет
function GetGValue(rgb: LONGWORD): Byte;         // Достать зеленый цвет
function GetBValue(rgb: LONGWORD): Byte;         // Достать синий цвет
function InFov(x1,y1,x2,y2,los : byte) : boolean;// Принадлежит ли радиусу видимости?
procedure DeleteSwap;                            // Удалить файлы сохранения
function IsFlag(flags : LongWord;
                 flag : LongWord) : boolean;     // Проверка флага
procedure StartDecorating(header : string;
                    withoutexit : boolean);      // Рамочка, название
procedure DrawBorder(x,y,w,h,color : byte);      // Рамка для инф. о предмете
function ReturnColor(Rn,n : integer;
                          ow : byte) : integer;  // Вернуть цвет в зависимости от процентов
function ReturnInvAmount : byte;                 // Вернуть колличество предметов в инвентаре
function ReturnInvListAmount : byte;             // Вернуть колличество отфильтрованных предметов в инвентаре
function WhatToDo(vid : integer) : string;       // Слово 'использовать' для разных видов предметов
procedure TakeScreenShot;                        // Сделать скриншот
function Eq2Vid(cur : byte) : byte;              // Вид вещи соответствующий выбранной ячейки экипировки
function Vid2Eq(vid : byte) : byte;              // Номер ячейки в экипировки для этого вида предмета
procedure Intro;                                 // Заставка
function Rand(A, B: Integer): Integer;           // Случайное целое число из диапазона
function GenerateName(female : boolean) : string;// Генерация имени
function BarWidth(Cx, Mx, Wd: Integer): Integer; // Ширина бара
procedure BlackWhite(var AnImage: TBitMap);      // Преобразовать в ч/б
function GetDungeonModeMapName : string;         // Генерировать название подземелья
procedure ChangeGameState(NewState : byte);      // Поменять состояние игры
procedure StartGameMenu;                         // Отобразить игровое меню

implementation

uses
  Main, Player, Monsters, Map, Items, Msg, conf, sutils, vars, script, pngimage,
  wlog, help, herogen, MapEditor, mbox;

{ Цвет }
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
r:=r-muldiv(r,Percent,100);  //процент% уменьшения яркости
g:=g-muldiv(g,Percent,100);
b:=b-muldiv(b,Percent,100);
result:=RGB(r,g,b);
end;

{ Достать красный цвет }
function GetRValue(rgb: LONGWORD): Byte;
begin
  Result := Byte(rgb);
end;

{ Достать зеленый цвет }
function GetGValue(rgb: LONGWORD): Byte;
begin
  Result := Byte(rgb shr 8);
end;

{ Достать синий цвет }
function GetBValue(rgb: LONGWORD): Byte;
begin
  Result := Byte(rgb shr 16);
end;

{ Принадлежит ли радиусу видимости? }
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

{ Удалить файлы сохранения }
{ TODO -oPD -cminor : Доработать }
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

{ Проверка флага }
function IsFlag(flags : LongWord; flag : LongWord) : boolean;
begin
  if flags and flag > 0 then
    Result := true else
      Result := false;
end;

{ Рамочка, название }
procedure StartDecorating(header : string; withoutexit : boolean);
const space  = '-=[ НАЖМИ ПРОБЕЛ ДЛЯ ВЫХОДА ]=-';
var
  i : byte;
begin
  For i:=1 to ((WindowX) div 2)+1 do
  begin
    MainForm.DrawString((i-1),0,Darker(cGRAY,100-i),'=');
    MainForm.DrawString((i-1),(WindowY-1),Darker(cGRAY,100-i),'=');
    MainForm.DrawString(WindowX - (i-1),0,Darker(cGRAY,100-i), '=');
    MainForm.DrawString(WindowX - (i-1),(WindowY-1),Darker(cGRAY,100-i),'=');
  end;
  MainForm.DrawString(((WindowX-length(header)) div 2),  0, cYELLOW, header);
  if withoutexit = FALSE then
    MainForm.DrawString(((WindowX-length(space)) div 2) , (WindowY-1), cBROWN, space);
end;

{ Рамочка для информации о предмете}
procedure DrawBorder(x,y,w,h,color : byte);
var i, j: byte;
begin
  MainForm.DrawString(x,y,RealColor(color),bsBDiagonal,Frame[5]+StringOfChar(Frame[1],w-2)+Frame[6]);
  for i:=y+1 to y+h-1 do
    MainForm.DrawString(x,i,RealColor(color),Frame[2]+StringOfChar(' ',w-2)+Frame[4]);
  MainForm.DrawString(x,(y+h),RealColor(color),Frame[7]+StringOfChar(Frame[3],w-2)+Frame[8]);
end;

{  Вернуть цвет в зависимости от процентов }
function ReturnColor(Rn, n : integer; ow : byte) : integer;
var
  x : integer;
begin
  Result := 255;
  case ow of
    1 : // Здоровье
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
    2 : // Мана
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

{ Вернуть колличество предметов в инвентаре }
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

{ Вернуть колличество отфильтрованных предметов в инвентаре }
function ReturnInvListAmount : byte;
var
  i : byte;
begin
  for i:=1 to MaxHandle do
    if InvList[i] = 0 then
      break;
  Result := i-1;
end;

{ Слово 'использовать' для разных видов предметов }
function WhatToDo(vid : integer) : string;
begin
  case vid of
    1 : Result := 'Надеть'; // Шлем
    2 : Result := 'Надеть'; // Амулет
    3 : Result := 'Надеть'; // Плащ
    4 : Result := 'Надеть'; // Броня на тело
    5 : Result := 'Надеть'; // Ремень
    6 : Result := 'Вооружиться'; // Оружие ближнего боя
    7 : Result := 'Вооружиться'; // Оружие дальнего боя
    8 : Result := 'Использовать'; // Щит
    9 : Result := 'Надеть'; // Браслет
    10: Result := 'Надеть'; // Кольцо
    11: Result := 'Надеть'; // Перчатки
    12: Result := 'Надеть'; // Обувь
    13: Result := 'Использовать'; // Аммуниция
    14: Result := 'Съесть'; // Еда
    15: Result := 'Пересчитать'; // Монеты
    16: Result := 'Читать'; // Свиток
    17: Result := 'Читать'; // Книга
    18: Result := 'Взмахнуть'; // Волшебная палочка
    19: Result := 'Выпить'; // Зелье
    20: Result := 'Использовать'; // Инструмент
  end;
end;

{ Сделать скриншот (F5)}
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
    P.Assign(_Screen);
    P.SaveToFile(Path + 'screens/' + fname + '.png');
  finally
    P.Free;
  end;
  AddMsg('#Сделан скриншот# ($'+fname+'$).',0);
  MainForm.Redraw;
end;

{ Вид вещи соответствующий выбранной ячейки экипировки }
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

{ Номер ячейки в экипировки для этого вида предмета }
function Vid2Eq(vid : byte) : byte;
begin
  Result := 0;
  case vid of
    1 : Result := 1; // Шлем
    2 : Result := 2; // Амулет
    3 : Result := 3; // Плащ
    4 : Result := 4; // Броня на тело
    5 : Result := 5; // Ремень
    6 : Result := 6; // Оружие ближнего боя
    7 : Result := 7; // Оружие дальнего боя
    8 : Result := 8; // Щит
    9 : Result := 9; // Браслет
    10: Result := 10; // Кольцо
    11: Result := 11; // Перчатки
    12: Result := 12; // Обувь
    13: Result := 13; // Аммуниция
  end;
end;

{ Заставка }
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
  // WANDER
  MainForm.DrawString(((WindowX-length(s0)) div 2) , up, cLIGHTGRAY, s0);
  MainForm.DrawString(((WindowX-length(s1)) div 2) , (up+1), cLIGHTBLUE, s1);
  MainForm.DrawString(((WindowX-length(s2)) div 2) , (up+2), cBLUE, s2);
  MainForm.DrawString(((WindowX-length(s3)) div 2) , (up+3), cBLUE, s3);
  MainForm.DrawString(((WindowX-length(s4)) div 2) , (up+4), cBROWN, s4);
  MainForm.DrawString(((WindowX-length(s5)) div 2) , (up+5), cBROWN, s5);
  // Версия
  MainForm.DrawString(((WindowX+length(s1))div 2), (up+1), cBLUEGREEN, GameVersion);
end;

{ Случайное целое число из диапазона }
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

// Ширина бара
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

{ Генерация случайного имени }
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

{ Генерировать название подземелья }
function GetDungeonModeMapName : string;
begin
  V.SetInt('GenDungeon.Depth', PC.Depth);
  V.SetStr('GenDungeon.Name', '');
  Script.Run('GenDungeon.pas');
  Result := Trim(V.GetStr('GenDungeon.Name'));
end;

{ Поменять состояние игры }
procedure ChangeGameState(NewState : byte);
begin
  LastGameState := GameState;
  GameState := NewState;
end;

{ Отобразить игровое меню }
procedure StartGameMenu;
const
  TableX = 39;
  TableW = 20;
  MenuNames : array[1..GMChooseAmount] of string =
  ('Новая игра', 'Выход');
var
  i,j: byte;
begin
  repeat
    if (GameState = gsPlay) then BlackWhite(_Screen) else Intro;
    DrawBorder(TableX, Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2, TableW,(GMChooseAmount+2)+1,crBLUEGREEN);
    GameMenu := TRUE;
    with TMenu.Create(TableX+2, (WindowY div 2)-(GMChooseAmount+2)div 2) do
    begin
      for i:=1 to GMChooseAmount do
        Add(MenuNames[i]);
      j := 1;
      repeat
        j:=Run(Selected);
      until ((j = 0) and (GameState <> gsINTRO))or(j<>0);
      Free;
    end;
    GameMenu := FALSE;
    if j = 0 then exit;
    case j of
      gmNEWGAME :
        if ChooseMode then
        begin
          M.MonL[pc.idinlist] := pc;
          MainForm.InitGame;
          break;
        end else GameState := gsIntro;
      gmEXIT    :
        begin
          GameMenu := FALSE;
          if GameState = gsINTRO then AskForQuit := FALSE;
          MainForm.Close;
          break;
        end;
      end;
  until false;
end;

{ Класс TIntQueue }

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
  _F.AddObject(s, Pointer(ForeColor));
  Log('Added '+s);
end;

procedure TMenu.Add(s: String; c: LongInt);
begin
  _F.AddObject(s, Pointer(c));
  Log('Added '+s);
end;

procedure TMenu.addBreakKey(Key: word);
begin
  BreakKey := Key;
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
  CallBackProc := nil;
  BreakKey := 27;
end;

destructor TMenu.Destroy;
begin
  _F.Free;
end;

procedure TMenu.Draw;
var i: byte;
begin
  if not(_F.Count = 0) then
    begin
      MainForm.SetBgColor(cBlack);
      for i:= 0 to _F.Count-1 do
      begin
        MainForm.DrawString(x,(y+i),BgColor,'[ ] ');
        MainForm.DrawString((x+4),(y+i),LongInt(_F.Objects[i]),_F[i]);
      end;
      MainForm.DrawString((x+1),(y+pos-1),SelColor,'>');
    end;
  MainForm.Redraw;
end;

function TMenu.getCount: byte;
begin
  Result := _F.Count;
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
      if (@CallbackProc <> nil) then
        CallbackProc(Pos);    
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
      if Key = BreakKey then break;
    until false;
  end;
end;

procedure TMenu.setCallback(newCallback: TCallback);
begin
  CallbackProc := newCallback;
end;

initialization
  // Версия игры
  EX := Explode('.', FileVersion(Paramstr(0)));
  GameVersion := EX[0] + '.' + EX[1] + EX[2];
  if (strtoint(Ex[3]) in [1..27]) then GameVersion := GameVersion + chr(96+strtoint(Ex[3]));
end.
