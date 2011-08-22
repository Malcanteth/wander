unit utils;

interface

uses
  SysUtils, Main, Cons;

function MyRGB(R,G,B : byte) : LongWord;         // Цвет
function GetRValue(rgb: LONGWORD): Byte;         // Достать красный цвет
function GetGValue(rgb: LONGWORD): Byte;         // Достать зеленый цвет
function GetBValue(rgb: LONGWORD): Byte;         // Достать синий цвет
function InFov(x1,y1,x2,y2,los : byte) : boolean;// Принадлежит ли радиусу видимости?
procedure DeleteSwap;                            // Удалить файлы сохранения
function GenerateName(female : boolean) : string;// Генерация имени
function IsFlag(flags : LongWord;
                 flag : LongWord) : boolean;     // Проверка флага
function HeSheIt(id,vid : byte) : string;        // Вернуть окончание в зависимости от пола и ситуации
procedure StartDecorating(header : string);      // Рамочка, название
procedure DrawBorder(x,y,w,h : byte);            // Рамка для инф. о предмете
function ExistFile(n : string) : boolean;        // Существет ли такой файл?
function ReturnColor(Rn,n : integer;
                          ow : byte) : integer;  // Вернуть цвет в зависимости от процентов
function ReturnInvAmount : byte;                 // Вернуть колличество предметов в инвентаре
function WhatToDo(id : integer) : string;        // Слово 'использовать' для разных видов предметов

implementation

uses
  Player, Monsters, Map, Items;

{ Цвет }
function MyRGB(R,G,B : byte) : LongWord;
begin
  Result := (r or (g shl 8) or (b shl 16));
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
  if (x1>0)and(x1<=MapX)and(y1>0)and(y1<=MapY)and(x2>0)and(x2<=MapX)and(y2>0)and(y2<=MapY)then
  begin
    if Round(SQRT(SQR(x1-x2)+SQR(y1-y2))) >= los then
      Result := false else
        Result := true;
  end else
    Result := false;
end;

{ Удалить файлы сохранения }
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

{ Генерация имени }
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

{ Проверка флага }
function IsFlag(flags : LongWord; flag : LongWord) : boolean;
begin
  if flags and flag > 0 then
    Result := true else
      Result := false;
end;

{ Вернуть окончание в зависимости от пола и ситуации }
function HeSheIt(id,vid : byte) : string;
begin
  case vid of
    1:
    case MonstersData[id].gender of
      genMIDLE : Result := 'о';
      genMALE  : Result := '';
      genFEMALE: Result := 'а';
    end;
    2:
    case MonstersData[id].gender of
      genMIDLE : Result := 'ось';
      genMALE  : Result := 'ся';
      genFEMALE: Result := 'ась';
    end;
  end;
end;

{ Рамочка, название }
procedure StartDecorating(header : string);
const
  space  = '-=[ НАЖМИ ПРОБЕЛ ДЛЯ ВЫХОДА ]=-';
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

{ Слово 'использовать' для разных видов предметов }
function WhatToDo(id : integer) : string;
begin
  case ItemsData[id].vid of
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
    13: Result := 'Надеть'; // Аммуниция
    14: Result := 'Съесть'; // Еда
    15: Result := 'Пересчитать'; // Монеты
    16: Result := 'Читать'; // Свиток
    17: Result := 'Читать'; // Книга
    18: Result := 'Взмахнуть'; // Волшебная палочка
    19: Result := 'Выпить'; // Зелье
    20: Result := 'Использовать'; // Инструмент
  end;
end;

end.
