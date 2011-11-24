unit utils;

interface

uses
  SysUtils, Main, Cons, Windows, Graphics, JPEG, Classes;

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
function ExistFile(n : string) : boolean;        // Существет ли такой файл?
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
  Player, Monsters, Map, Items, Msg, conf, sutils, vars, script, pngimage;

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
const
  space  = '-=[ НАЖМИ ПРОБЕЛ ДЛЯ ВЫХОДА ]=-';
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

{ Рамочка для информации о предмете}
procedure DrawBorder(x,y,w,h,color : byte);
var
  i : byte;
begin
  with Screen.Canvas do
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

{ Существет ли такой файл? }
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
    P.Assign(Screen);
    P.SaveToFile(Path + 'screens/' + fname + '.png');
  finally
    P.Free;
  end;
  AddMsg('#Сделан скриншот# ($'+fname+'$).',0);
  MainForm.OnPaint(NIL);
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
    // Версия
    Font.Color := cBLUEGREEN;
    TextOut(34*CharY, (up+1)*CharY, GameVersion);
  end;
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
begin
  GameMenu := TRUE;
  MenuSelected := 1;
end;

var
  EX: TExplodeResult;

initialization
  // Версия игры
  EX := Explode('.', FileVersion(Paramstr(0)));
  GameVersion := EX[0] + '.' + EX[1] + EX[2];
  if (strtoint(Ex[3]) in [1..27]) then GameVersion := GameVersion + chr(96+strtoint(Ex[3]));
end.
