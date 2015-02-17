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
function Rand(A, B: Integer): Integer;           // Случайное целое число из диапазона
function GenerateName(female : boolean) : string;// Генерация имени
function BarWidth(Cx, Mx, Wd: Integer): Integer; // Ширина бара
procedure BlackWhite(var AnImage: TBitMap);      // Преобразовать в ч/б
function GetDungeonModeMapName : string;         // Генерировать название подземелья
procedure ChangeGameState(NewState : byte);      // Поменять состояние игры
procedure StartGameMenu;                         // Отобразить игровое меню
procedure DrawBG;                                // Фон сцены

implementation

uses
  Player, Monsters, Map, Items, Msg, conf, sutils, vars, pngimage;

{ Цвет }
function MyRGB(R,G,B : byte) : LongWord;
begin
  Result := (r or (g shl 8) or (b shl 16));
end;

{ Вернуть цвет }
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

{ Сделать цвет темнее }
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

{ Рамочка для информации о предмете}
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
    P.Assign(GScreen);
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

{ Случайное целое число из диапазона }
function Rand(A, B: Integer): Integer;
begin
  Result := Round(Random(B - A + 1) + A);
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
var
  s : string;
  procedure Add2; // Второй слог
  begin
    case Rand(1, 10) of
       1: S := S + 'ид';
       2: S := S + 'ар';
       3: S := S + 'ор';
       4: S := S + 'ур';
       5: S := S + 'ов';
       6: S := S + 'ик';
       7: S := S + 'ом';
       8: S := S + 'аб';
       9: S := S + 'из';
      10: S := S + 'ок';
    end;
  end;
  procedure Add3; // Третий слог
  begin
    case Rand(1, 8) of
       1: S := S + 'эн';
       2: S := S + 'е';
       3: S := S + 'и';
       4: S := S + 'о';
       5: S := S + 'д';
       6: S := S + 'ес';
       7: S := S + 'ер';
       8: S := S + 'ес';
    end;
  end;
begin
  case Rand(1, 11) of
     1: S := 'Гр';
     2: S := 'Ад';
     3: S := 'Вил';
     4: S := 'Кен';
     5: S := 'Лур';
     6: S := 'Тил';
     7: S := 'Гэл';
     8: S := 'Тор';
     9: S := 'Тас';
    10: S := 'Ат';
    11: S := 'Сэл';
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
  // Женское имя
  if Female then
  case Rand(1, 3) of
     1: S := S + 'оя';
     2: S := S + 'ия';
     3: S := S + 'еа';
  end;
  Result := S;
end;

{ Сделать картинку в оттенках серого }
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

{ Генерировать название подземелья }
function GetDungeonModeMapName : string;
var
  S : string;
begin
  // От глубины подземелья зависит его название (7 символов)
  case pc.depth of
     1: S := 'Обитель';
     2: S := 'Крипт';
     3: S := 'Грот';
     4: S := 'Нора';
     5: S := 'Залы';
     else
        S := 'Пещера';
  end;
  // Разновидность (длина слова - 10 знаков (включ. пробел спереди))
  case Rand(1, 22) of
     1: S := S + ' Снов';
     2: S := S + ' Страха';
     3: S := S + ' Ужасов';
     4: S := S + ' Усталости';
     5: S := S + ' Горя';
     6: S := S + ' Печали';
     7: S := S + ' Ненависти';
     8: S := S + ' Страданий';
     9: S := S + ' Тьмы';
    10: S := S + ' Жалости';
    11: S := S + ' Крови';
    12: S := S + ' Холода';
    13: S := S + ' Кошмаров';
    14: S := S + ' Ночи';
    15: S := S + ' Троллей';
    16: S := S + ' Гномов';
    17: S := S + ' Гулей';
    18: S := S + ' Эльфов';
    19: S := S + ' Тварей';
    20: S := S + ' Насекомых';
    21: S := S + ' Стражей';
    22: S := S + ' Безумия';
  end;
  Result := S;
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

{ Фон сцены }
procedure DrawBG;
var
  X, Y: Byte;
begin
  with GScreen.Canvas do
  begin
    for X := 1 to WindowX do
      for Y := 1 to WindowY do
      begin
        // Вывести символ
        Brush.Color := Darker(RealColor(crRANDOMBLUE), 95);
        TextOut((x - 1) * CharX, (y - 1) * CharY, ' ');
      end;
  end;
end;

end.
