unit utils;

interface

uses
  SysUtils, Main, Cons, Windows, Graphics, JPEG, Classes;

function MyRGB(R, G, B: Byte): LongWord; // Цвет
function RealColor(c: byte): LongWord;
function Darker(Color: TColor; Percent: byte): TColor;
function GetRValue(rgb: LongWord): byte; // Достать красный цвет
function GetGValue(rgb: LongWord): byte; // Достать зеленый цвет
function GetBValue(rgb: LongWord): byte; // Достать синий цвет
function InFov(x1, y1, x2, y2, los: byte): boolean; // Принадлежит ли радиусу видимости?
procedure DeleteSwap; // Удалить файлы сохранения
function IsFlag(flags: LongWord; flag: LongWord): boolean; // Проверка флага
procedure StartDecorating(header: string; withoutexit: boolean); // Рамочка, название
procedure DrawBorder(x, y, w, h, Color: byte); // Рамка для инф. о предмете
function ExistFile(n: string): boolean; // Существет ли такой файл?
function ReturnColor(Rn, n: integer; ow: byte): integer; // Вернуть цвет в зависимости от процентов
function ReturnInvAmount: byte; // Вернуть колличество предметов в инвентаре
function ReturnInvListAmount: byte; // Вернуть колличество отфильтрованных предметов в инвентаре
function WhatToDo(vid: integer): string; // Слово 'использовать' для разных видов предметов
procedure TakeScreenShot; // Сделать скриншот
function Eq2Vid(cur: byte): byte; // Вид вещи соответствующий выбранной ячейки экипировки
function Vid2Eq(vid: byte): byte; // Номер ячейки в экипировки для этого вида предмета
function Rand(A, B: integer): integer; // Случайное целое число из диапазона
function GenerateName(female: boolean): string; // Генерация имени
function BarWidth(Cx, Mx, Wd: integer): integer; // Ширина бара
procedure BlackWhite(var AnImage: TBitMap); // Преобразовать в ч/б
function GetDungeonModeMapName: string; // Генерировать название подземелья
procedure ChangeGameState(NewState: byte); // Поменять состояние игры
procedure StartGameMenu; // Отобразить игровое меню
procedure DrawBG; // Фон сцены

implementation

uses
  Player, Monsters, Map, Items, Msg, conf, sutils, vars, pngimage;

{ Цвет }
function MyRGB(R, G, B: byte): LongWord;
begin
  Result := (R or (G shl 8) or (B shl 16));
end;

{ Вернуть цвет }
function RealColor(c: byte): LongWord;
begin
  Result := 255;
  case c of
    crRANDOM:
      Result := MyRGB(Random(155) + 100, Random(155) + 100, Random(155) + 100);
    crBLACK:
      Result := cBLACK;
    crBLUE:
      Result := cBLUE;
    crGREEN:
      Result := cGREEN;
    crRED:
      Result := cRED;
    crCYAN:
      Result := cCYAN;
    crPURPLE:
      Result := cPURPLE;
    crBROWN:
      Result := cBROWN;
    crWHITE:
      Result := cWHITE;
    crGRAY:
      Result := cGRAY;
    crYELLOW:
      Result := cYELLOW;
    crLIGHTGRAY:
      Result := cLIGHTGRAY;
    crLIGHTRED:
      Result := cLIGHTRED;
    crLIGHTGREEN:
      Result := cLIGHTGREEN;
    crLIGHTBLUE:
      Result := cLIGHTBLUE;
    crORANGE:
      Result := cORANGE;
    crBLUEGREEN:
      Result := cBLUEGREEN;
    crRANDOMRED:
      Result := MyRGB(Random(155) + 100, 40, 40);
    crRANDOMBLUE:
      Result := MyRGB(40, 40, Random(155) + 100);
    crRANDOMGREEN:
      Result := MyRGB(40, Random(155) + 100, 40);
  end;
end;

{ Сделать цвет темнее }
function Darker(Color: TColor; Percent: byte): TColor;
var
  R, G, B: byte;
begin
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  R := R - muldiv(R, Percent, 100); // процент% уменьшения яркости
  G := G - muldiv(G, Percent, 100);
  B := B - muldiv(B, Percent, 100);
  Result := rgb(R, G, B);
end;

{ Достать красный цвет }
function GetRValue(rgb: LongWord): byte;
begin
  Result := byte(rgb);
end;

{ Достать зеленый цвет }
function GetGValue(rgb: LongWord): byte;
begin
  Result := byte(rgb shr 8);
end;

{ Достать синий цвет }
function GetBValue(rgb: LongWord): byte;
begin
  Result := byte(rgb shr 16);
end;

{ Принадлежит ли радиусу видимости? }
function InFov(x1, y1, x2, y2, los: byte): boolean;
begin
  if (x1 > 0) and (x1 <= MapX) and (y1 > 0) and (y1 <= MapY) and (x2 > 0) and (x2 <= MapX) and (y2 > 0) and (y2 <= MapY) then
    Result := Round(SQRT(SQR(x1 - x2) + SQR(y1 - y2))) < los
  else
    Result := false;
end;

{ Удалить файлы сохранения }
{ TODO -oPD -cminor : Доработать }
procedure DeleteSwap;
var
  s: TSearchRec;
  f: file;
begin
  while FindFirst(Path + 'swap/' + pc.name + '/*.lev', faAnyFile, s) = 0 do
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
function IsFlag(flags: LongWord; flag: LongWord): boolean;
begin
  if flags and flag > 0 then
    Result := true
  else
    Result := false;
end;

{ Рамочка, название }
procedure StartDecorating(header: string; withoutexit: boolean);
const
  space = '-=[ НАЖМИ ПРОБЕЛ ДЛЯ ВЫХОДА ]=-';
var
  i: byte;
begin
  DrawBG;
  with GScreen.Canvas do
  begin
    For i := 1 to Round(WindowX / 2) do
    begin
      Font.Color := Darker(cGRAY, 100 - i);
      TextOut((i - 1) * CharX, 0, '=');
      TextOut((i - 1) * CharX, CharY * (WindowY - 1), '=');
    end;
    For i := Round(WindowX / 2) to WindowX do
    begin
      Font.Color := Darker(cGRAY, i);
      TextOut((i - 1) * CharX, 0, '=');
      TextOut((i - 1) * CharX, CharY * (WindowY - 1), '=');
    end;
    Font.Color := cYELLOW;
    TextOut(((WindowX - length(header)) div 2) * CharX, 0, header);
    if withoutexit = false then
    begin
      Font.Color := cBROWN;
      TextOut(((WindowX - length(space)) div 2) * CharX, CharY * (WindowY - 1), space);
    end;
  end;
end;

{ Рамочка для информации о предмете }
procedure DrawBorder(x, y, w, h, Color: byte);
var
  i: byte;
begin
  with GScreen.Canvas do
  begin
    Font.Color := RealColor(Color);
    TextOut(x * CharX, y * CharY, '.');
    TextOut((x + w) * CharX, y * CharY, '.');
    TextOut(x * CharX, (y + h) * CharY, '''');
    TextOut((x + w) * CharX, (y + h) * CharY, '''');
    For i := x + 1 to x + w - 1 do
    begin
      TextOut(i * CharX, y * CharY, '-');
      TextOut(i * CharX, (y + h) * CharY, '-');
    end;
    For i := y + 1 to y + h - 1 do
    begin
      TextOut(x * CharX, i * CharY, '|');
      TextOut((x + w) * CharX, i * CharY, '|');
    end;
  end;
end;

{ Существет ли такой файл? }
function ExistFile(n: string): boolean;
var
  f: file;
begin
  assign(f, n);
{$I-}
  reset(f);
{$I+}
  if IOResult = 0 then
  begin
    close(f);
    Result := true;
  end
  else
    Result := false;
end;

{ Вернуть цвет в зависимости от процентов }
function ReturnColor(Rn, n: integer; ow: byte): integer;
var
  x: integer;
begin
  Result := 255;
  case ow of
    1: // Здоровье
      begin
        if Rn > 0 then
        begin
          x := Round((n * 100) / Rn);
          case x of
            100:
              Result := cGREEN;
            85 .. 99:
              Result := cLIGHTGREEN;
            50 .. 84:
              Result := cRED;
            1 .. 49:
              Result := cLIGHTRED
          else
            Result := cGRAY;
          end;
        end
        else
          Result := cGRAY;
      end;
    2: // Мана
      begin
        if Rn > 0 then
        begin
          x := Round((n * 100) / Rn);
          case x of
            100:
              Result := cPURPLE;
            85 .. 99:
              Result := cBLUE;
            50 .. 84:
              Result := cLIGHTBLUE;
            20 .. 49:
              Result := cRED;
            1 .. 19:
              Result := cLIGHTRED
          else
            Result := cGRAY;
          end;
        end
        else
          Result := cGRAY;
      end;
  end;
end;

{ Вернуть колличество предметов в инвентаре }
function ReturnInvAmount: byte;
var
  i, kol: byte;
begin
  kol := 0;
  for i := 1 to MaxHandle do
    if pc.inv[i].id > 0 then
      inc(kol)
    else
      break;
  Result := kol;
end;

{ Вернуть колличество отфильтрованных предметов в инвентаре }
function ReturnInvListAmount: byte;
var
  i: byte;
begin
  for i := 1 to MaxHandle do
    if InvList[i] = 0 then
      break;
  Result := i - 1;
end;

{ Слово 'использовать' для разных видов предметов }
function WhatToDo(vid: integer): string;
begin
  case vid of
    1:
      Result := 'Надеть'; // Шлем
    2:
      Result := 'Надеть'; // Амулет
    3:
      Result := 'Надеть'; // Плащ
    4:
      Result := 'Надеть'; // Броня на тело
    5:
      Result := 'Надеть'; // Ремень
    6:
      Result := 'Вооружиться'; // Оружие ближнего боя
    7:
      Result := 'Вооружиться'; // Оружие дальнего боя
    8:
      Result := 'Использовать'; // Щит
    9:
      Result := 'Надеть'; // Браслет
    10:
      Result := 'Надеть'; // Кольцо
    11:
      Result := 'Надеть'; // Перчатки
    12:
      Result := 'Надеть'; // Обувь
    13:
      Result := 'Использовать'; // Аммуниция
    14:
      Result := 'Съесть'; // Еда
    15:
      Result := 'Пересчитать'; // Монеты
    16:
      Result := 'Читать'; // Свиток
    17:
      Result := 'Читать'; // Книга
    18:
      Result := 'Взмахнуть'; // Волшебная палочка
    19:
      Result := 'Выпить'; // Зелье
    20:
      Result := 'Использовать'; // Инструмент
  end;
end;

{ Сделать скриншот (F5) }
procedure TakeScreenShot;
var
  t: TSystemTime;
  s, fname: string;
  P: TPNGObject;
begin
  GetSystemTime(t);
  CreateDir(Path + 'screens');
  if pc.name = '' then
    s := 'unknown'
  else
    s := pc.name;
  fname := '<FAIL>';
  fname := s + '_' + IntToStr(t.wYear) + IntToStr(t.wMonth) + IntToStr(t.wDay) + IntToStr(t.wHour) + IntToStr(t.wMinute) + IntToStr(t.wSecond);
  // PNG
  P := TPNGObject.Create;
  try
    P.assign(GScreen);
    P.SaveToFile(Path + 'screens/' + fname + '.png');
  finally
    P.Free;
  end;
  AddMsg('#Сделан скриншот# ($' + fname + '$).', 0);
  MainForm.OnPaint(NIL);
end;

{ Вид вещи соответствующий выбранной ячейки экипировки }
function Eq2Vid(cur: byte): byte;
begin
  Result := 0;
  case cur of
    1:
      Result := 1;
    2:
      Result := 2;
    3:
      Result := 3;
    4:
      Result := 4;
    5:
      Result := 5;
    6:
      Result := 6;
    7:
      Result := 7;
    8:
      Result := 8;
    9:
      Result := 9;
    10:
      Result := 10;
    11:
      Result := 11;
    12:
      Result := 12;
    13:
      Result := 13;
  end;
end;

{ Номер ячейки в экипировки для этого вида предмета }
function Vid2Eq(vid: byte): byte;
begin
  Result := 0;
  case vid of
    1:
      Result := 1; // Шлем
    2:
      Result := 2; // Амулет
    3:
      Result := 3; // Плащ
    4:
      Result := 4; // Броня на тело
    5:
      Result := 5; // Ремень
    6:
      Result := 6; // Оружие ближнего боя
    7:
      Result := 7; // Оружие дальнего боя
    8:
      Result := 8; // Щит
    9:
      Result := 9; // Браслет
    10:
      Result := 10; // Кольцо
    11:
      Result := 11; // Перчатки
    12:
      Result := 12; // Обувь
    13:
      Result := 13; // Аммуниция
  end;
end;

{ Случайное целое число из диапазона }
function Rand(A, B: integer): integer;
begin
  Result := Round(Random(B - A + 1) + A);
end;

// Ширина бара
function BarWidth(Cx, Mx, Wd: integer): integer;
var
  i: integer;
begin
  if (Mx <= 0) then
    Mx := 1;
  i := (Cx * Wd) div Mx;
  if i <= 0 then
    i := 0;
  if (Cx >= Mx) then
    i := Wd;
  Result := i;
end;

{ Генерация случайного имени }
function GenerateName(female: boolean): string;
var
  s: string;
  procedure Add2; // Второй слог
  begin
    case Rand(1, 10) of
      1:
        s := s + 'ид';
      2:
        s := s + 'ар';
      3:
        s := s + 'ор';
      4:
        s := s + 'ур';
      5:
        s := s + 'ов';
      6:
        s := s + 'ик';
      7:
        s := s + 'ом';
      8:
        s := s + 'аб';
      9:
        s := s + 'из';
      10:
        s := s + 'ок';
    end;
  end;
  procedure Add3; // Третий слог
  begin
    case Rand(1, 8) of
      1:
        s := s + 'эн';
      2:
        s := s + 'е';
      3:
        s := s + 'и';
      4:
        s := s + 'о';
      5:
        s := s + 'д';
      6:
        s := s + 'ес';
      7:
        s := s + 'ер';
      8:
        s := s + 'ес';
    end;
  end;

begin
  case Rand(1, 11) of
    1:
      s := 'Гр';
    2:
      s := 'Ад';
    3:
      s := 'Вил';
    4:
      s := 'Кен';
    5:
      s := 'Лур';
    6:
      s := 'Тил';
    7:
      s := 'Гэл';
    8:
      s := 'Тор';
    9:
      s := 'Тас';
    10:
      s := 'Ат';
    11:
      s := 'Сэл';
  end;
  case Rand(1, 3) of
    1:
      Add2;
    2:
      begin
        Add2;
        Add3;
      end;
    3:
      Add3;
  end;
  // Женское имя
  if female then
    case Rand(1, 3) of
      1:
        s := s + 'оя';
      2:
        s := s + 'ия';
      3:
        s := s + 'еа';
    end;
  Result := s;
end;

{ Сделать картинку в оттенках серого }
procedure BlackWhite(var AnImage: TBitMap);
var
  JPGImage: TJPEGImage;
  BMPImage: TBitMap;
  MemStream: TMemoryStream;
begin
  BMPImage := TBitMap.Create;
  try
    BMPImage.Width := AnImage.Width;
    BMPImage.Height := AnImage.Height;
    JPGImage := TJPEGImage.Create;
    try
      JPGImage.assign(AnImage);
      JPGImage.CompressionQuality := 100;
      JPGImage.Compress;
      JPGImage.Grayscale := true;
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
function GetDungeonModeMapName: string;
var
  s: string;
begin
  // От глубины подземелья зависит его название (7 символов)
  case pc.depth of
    1:
      s := 'Обитель';
    2:
      s := 'Крипт';
    3:
      s := 'Грот';
    4:
      s := 'Нора';
    5:
      s := 'Залы';
  else
    s := 'Пещера';
  end;
  // Разновидность (длина слова - 10 знаков (включ. пробел спереди))
  case Rand(1, 22) of
    1:
      s := s + ' Снов';
    2:
      s := s + ' Страха';
    3:
      s := s + ' Ужасов';
    4:
      s := s + ' Усталости';
    5:
      s := s + ' Горя';
    6:
      s := s + ' Печали';
    7:
      s := s + ' Ненависти';
    8:
      s := s + ' Страданий';
    9:
      s := s + ' Тьмы';
    10:
      s := s + ' Жалости';
    11:
      s := s + ' Крови';
    12:
      s := s + ' Холода';
    13:
      s := s + ' Кошмаров';
    14:
      s := s + ' Ночи';
    15:
      s := s + ' Троллей';
    16:
      s := s + ' Гномов';
    17:
      s := s + ' Гулей';
    18:
      s := s + ' Эльфов';
    19:
      s := s + ' Тварей';
    20:
      s := s + ' Насекомых';
    21:
      s := s + ' Стражей';
    22:
      s := s + ' Безумия';
  end;
  Result := s;
end;

{ Поменять состояние игры }
procedure ChangeGameState(NewState: byte);
begin
  LastGameState := GameState;
  GameState := NewState;
  if (NewState = gsINTRO) then
    StartGameMenu;
end;

{ Отобразить игровое меню }
procedure StartGameMenu;
begin
  GameMenu := true;
  MenuSelected := 1;
end;

{ Фон сцены }
procedure DrawBG;
var
  x, y: byte;
begin
  with GScreen.Canvas do
  begin
    for x := 1 to WindowX do
      for y := 1 to WindowY do
      begin
        // Вывести символ
        Brush.Color := Darker(RealColor(crRANDOMBLUE), 95);
        TextOut((x - 1) * CharX, (y - 1) * CharY, ' ');
      end;
  end;
end;

end.
