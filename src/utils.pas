unit utils;

interface

uses
  SysUtils, Main, Cons, Windows, Graphics;

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
procedure DrawBorder(x,y,w,h : byte);            // Рамка для инф. о предмете
function ExistFile(n : string) : boolean;        // Существет ли такой файл?
function ReturnColor(Rn,n : integer;
                          ow : byte) : integer;  // Вернуть цвет в зависимости от процентов
function ReturnInvAmount : byte;                 // Вернуть колличество предметов в инвентаре
function ReturnInvListAmount : byte;             // Вернуть колличество отфильтрованных предметов в инвентаре
function WhatToDo(vid : integer) : string;       // Слово 'использовать' для разных видов предметов
procedure TakeScreenShot;                        // Сделать скриншот
function Eq2Vid(cur : byte) : byte;              // Вид вещи соответствующий выбранной ячейки экипировки
procedure Intro;                                 // Заставка
function WhatClass : byte;                       // Вернуть цифру класса героя
function CLName : string;                        // Вернуть название класса
function ClassColor : longword;                  // Цвет класса
function Rand(A, B: Integer): Integer;           // Случайное целое число из диапазона
function GenerateName(female : boolean) : string; // Генерация имени

implementation

uses
  Player, Monsters, Map, Items, Msg, conf;

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
  s: string;
begin
  GetSystemTime(t);
  CreateDir(Path + 'screens');
  if pc.name = '' then s := 'unknown' else s := pc.name;
  Screen.SaveToFile(Path + 'screens/' + s + '_'+IntToStr(t.wYear)+IntToStr(t.wMonth)+IntToStr(t.wDay)+IntToStr(t.wHour)+IntToStr(t.wMinute)+IntToStr(t.wSecond)+'.bmp');
  AddMsg('[Скриншот...]',0);
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

{ Заставка }
procedure Intro;
const
  s0 = '#       #   #   #          #### #     ';
  s1 = ' #  #  #   ##   ##  # ###  #    ###   ';
  s2 = ' ## # ##  #  #  # # # #  # #### #  #  ';
  s3 = '  # # #   ####  #  ## #  # #    ###   ';
  s4 = '   ###   #    # #   # #  # #### #  #  ';
  s5 = '        #           # ###           # ';
  s6 = '< Нажми ENTER для того, чтобы начать >';
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
    // Версия
    Font.Color := cPURPLE;
    TextOut(28*CharY, 21*CharY, 'Версия ' + GameVersion);
    // Нажите кнопку
    Font.Color := cYELLOW;
    TextOut(((WindowX-length(s6)) div 2) * CharX, 25*CharY, s6);
    // Режим
    Font.Color := cBROWN;
    case PlayMode of
      0 :TextOut(1, 41*CharY, 'Режим игры: "ПРИКЛЮЧЕНИЕ" (''C'' чтобы поменять)');
      1 :TextOut(1, 41*CharY, 'Режим игры: "ПОДЗЕМЕЛЬЕ"  (''C'' чтобы поменять)');
    end;
  end;
end;

{ Вернуть цифру класса героя }
function WhatClass : byte;
begin
  Result := 0;
  case pc.atr[1] of
    1 : // сила
    case pc.atr[2] of
      1 : Result := 1;
      2 : Result := 2;
      3 : Result := 3;
    end;
    2 : // ловкость
    case pc.atr[2] of
      1 : Result := 4;
      2 : Result := 5;
      3 : Result := 6;
    end;
    3 : // интеллект
    case pc.atr[2] of
      1 : Result := 7;
      2 : Result := 8;
      3 : Result := 9;
    end;
  end;
end;

{ Вернуть название класса }
function CLName : string;
begin
  case WhatClass of
    1 :
    case pc.gender of
      1 : Result := 'Воин'; 
      2 : Result := 'Воительница';
    end;
    2 :
    case pc.gender of
      1 : Result := 'Варвар';
      2 : Result := 'Амазонка';
    end;
    3 :
    case pc.gender of
      1 : Result := 'Паладин';
      2 : Result := 'Паладин';
    end;
    4 :
    case pc.gender of
      1 : Result := 'Странник';
      2 : Result := 'Странница';
    end;
    5 :
    case pc.gender of
      1 : Result := 'Вор';
      2 : Result := 'Воришка';
    end;
    6 :
    case pc.gender of
      1 : Result := 'Монах';
      2 : Result := 'Монахиня';
    end;
    7 :
    case pc.gender of
      1 : Result := 'Жрец';
      2 : Result := 'Жрица';
    end;
    8 :
    case pc.gender of
      1 : Result := 'Колдун';
      2 : Result := 'Колдунья';
    end;
    9 :
    case pc.gender of
      1 : Result := 'Мыслитель';
      2 : Result := 'Мыслительница';
    end;
  end;
end;

{ Цвет класса }
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

{ Генерация случайного имени }
function GenerateName(female : boolean) : string;
const
  name1 : array[1..7]of string[3] = ('Гр','Ад','Вил','Кен','Лур','Тил','Гэл');
  name2 : array[1..6]of string[2] = ('ид','ар','ор','ов','ик','ом');
  name3 : array[1..6]of string[3] = ('эн','е','и','о','д','ер');
  fends : array[1..3]of string[3] = ('оя','ия','еа');
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
