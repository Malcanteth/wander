unit items;

interface

uses
  Cons, Flags, Utils, Main, SysUtils, Msg;

type
  TItem = record
    id               : byte;         // Идентификатор
    amount           : word;         // Колличество
  end;

  TItemData = record
    name1, name2, name3        : string[40];      // Название (1ед.число,2мн.число,3кого)
    vid                        : byte;            // Вид предмета
    color                      : longword;        // Цвет
    mass                       : real;
    attack, defense            : word;
    flags                      : longword;        // Флажки:)
  end;

const
  { Константы количества предметов }
  ItemsAmount = 26;

  {  Описание предметов }
  ItemsData : array[1..ItemsAmount] of TItemData =
  (
    ( name1: 'Золотая Монета'; name2: 'Золотые Монеты'; name3: 'Золотую Монету';
      vid:15; color: cYELLOW; mass: 0.01;
      attack: 1; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Столовый Нож'; name2: 'Столовые Ножи'; name3: 'Столовый Нож';
      vid:6; color: cLIGHTGRAY; mass: 4.5;
      attack: 6; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Вилы'; name2: 'Вилы'; name3: 'Вилы';
      vid:6; color: cBROWN; mass: 19.2;
      attack: 11; defense: 0;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: 'Кекс'; name2: 'Кексы'; name3: 'Кекс';
      vid:14; color: cBROWN; mass: 0.4;
      attack: 1; defense: 100;
      flags : NOF;
    ),
    ( name1: 'Шляпа'; name2: 'Шляпы'; name3: 'Шляпу';
      vid:1; color: cGRAY; mass: 3.0;
      attack: 1; defense: 1;
      flags : NOF;
    ),
    ( name1: 'Лапти'; name2: 'Лапти'; name3: 'Лапти';
      vid:12; color: cBROWN; mass: 6.2;
      attack: 2; defense: 2;
      flags : NOF;
    ),
    ( name1: 'Труп'; name2: 'Трупы'; name3: 'Труп';
      vid:14; color: cRED; mass: 50.4;
      attack: 5; defense: 900;
      flags : NOF;
    ),
    ( name1: 'Каска'; name2: 'Каски'; name3: 'Каску';
      vid:1; color: cBROWN; mass: 13.0;
      attack: 3; defense: 5;
      flags : NOF;
    ),
    ( name1: 'Мантия'; name2: 'Мантии'; name3: 'Мантию';
      vid:4; color: cPURPLE; mass: 9.1;
      attack: 1; defense: 2;
      flags : NOF;
    ),
    ( name1: 'Куртка'; name2: 'Куртки'; name3: 'Куртку';
      vid:4; color: cBROWN; mass: 12.0;
      attack: 1; defense: 4;
      flags : NOF;
    ),
    ( name1: 'Кольчуга'; name2: 'Кольчуги'; name3: 'Кольчугу';
      vid:4; color: cLIGHTGRAY; mass: 25.5;
      attack: 4; defense: 8;
      flags : NOF;
    ),
    ( name1: 'Посох'; name2: 'Посохи'; name3: 'Посох';
      vid:6; color: cBROWN; mass: 10.7;
      attack: 15; defense: 0;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: 'Кинжал'; name2: 'Кинжалы'; name3: 'Кинжал';
      vid:6; color: cLIGHTGRAY; mass: 7.7;
      attack: 11; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Дубина'; name2: 'Дубины'; name3: 'Дубину';
      vid:6; color: cBROWN; mass: 16.0;
      attack: 18; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Короткий меч'; name2: 'Короткие мечи'; name3: 'Короткий Меч';
      vid:6; color: cWHITE; mass: 12.0;
      attack: 13; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Палица'; name2: 'Палицы'; name3: 'Палицу';
      vid:6; color: cLIGHTGRAY; mass: 14.0;
      attack: 20; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Длинный меч'; name2: 'Длинные мечи'; name3: 'Длинный Меч';
      vid:6; color: cCYAN; mass: 21.0;
      attack: 23; defense: 0;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: 'Щит'; name2: 'Щиты'; name3: 'Щит';
      vid:8; color: cBROWN; mass: 15.2;
      attack: 7; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Сапоги'; name2: 'Сапоги'; name3: 'Сапоги';
      vid:12; color: cGREEN; mass: 8.7;
      attack: 4; defense: 3;
      flags : NOF;
    ),
    ( name1: 'Лаваш'; name2: 'Лаваши'; name3: 'Лаваш';
      vid:14; color: cBROWN; mass: 1.4;
      attack: 2; defense: 250;
      flags : NOF;
    ),
    ( name1: 'Зеленое яблоко'; name2: 'Зеленые яблоки'; name3: 'Зеленое яблоко';
      vid:14; color: cLIGHTGREEN; mass: 0.5;
      attack: 2; defense: 90;
      flags : NOF;
    ),
    ( name1: 'Кусок мяса'; name2: 'Куски мяса'; name3: 'Кусок мяса';
      vid:14; color: cLIGHTRED; mass: 6.0;
      attack: 3; defense: 500;
      flags : NOF;
    ),
    ( name1: 'Зелье лечения'; name2: 'Зелья лечения'; name3: 'Зелье лечения';
      vid:19; color: cLIGHTBLUE; mass: 0.3;
      attack: 1; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Зелье исцеления'; name2: 'Зелья исцеления'; name3: 'Зелье исцеления';
      vid:19; color: cRED; mass: 0.3;
      attack: 1; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Бутылка дешевого пива'; name2: 'Бутылки дешевого пива'; name3: 'Бутылку дешевого пива';
      vid:19; color: cBROWN; mass: 0.5;
      attack: 2; defense: 0;
      flags : NOF;
    ),
    ( name1: 'Башка Слепой Зверюги'; name2: 'Бошки Слепой Зверюги'; name3: 'Башку Слепой Зверюги';
      vid:14; color: cBROWN; mass: 2.4;
      attack: 2; defense: 300;
      flags : NOF;
    )
  );

  { Уникальные идентификаторы предметов }
  idCOIN           = 1;
  idKITCHENKNIFE   = 2;
  idPITCHFORK      = 3;
  idKEKS           = 4;
  idJACKSONSHAT    = 5;
  idLAPTI          = 6;
  idCORPSE         = 7;
  idHELMET         = 8;
  idMANTIA         = 9;
  idJACKET         = 10;
  idCHAINARMOR     = 11;
  idSTAFF          = 12;
  idDAGGER         = 13;
  idDUBINA         = 14;
  idSHORTSWORD     = 15;
  idPALICA         = 16;
  idLONGSWORD      = 17;
  idSHIELD         = 18;
  idBOOTS          = 19;
  idLAVASH         = 20;
  idGREENAPPLE     = 21;
  idMEAT           = 22;
  idPOTIONCURE     = 23;
  idPOTIONHEAL     = 24;
  idCHEAPBEER      = 25;
  idBLINDBEASTHEAD = 26;

function CreateItem(n : byte; am : integer) : TItem;          // Создать предмет
function PutItem(px,py : byte; Item : TItem) : boolean;       // Положить предмет
function ItemSymbol(id : integer) : string;                   // Вернуть символ предмета
procedure WriteSomeAboutItem(Item : TItem);                   // Вывести некоторые хар-ки предмета
procedure ExamineItem(Item : TItem);                          // Внимательно осмотреть предмет
procedure ItemOnOff(Item : TItem; PutOn : boolean);           // Применить эффект предмета или убрать

implementation

uses
  Map, Player;

{ Создать предмет }
function CreateItem(n : byte; am : integer) : TItem;
var
  Item : TItem;
begin
  with Item do
  begin
    id := n;
    amount := am;
  end;
  Result := Item;
end;

{ Положить предмет }
function PutItem(px,py : byte; Item : TItem) : boolean;
begin
  Result := True;
  if M.Item[px,py].id > 0 then
  begin
    if M.Item[px,py].id = Item.id then
    begin
      inc(M.Item[px,py].amount, Item.amount);
      exit;
    end else
      Result := False;
  end else
    M.Item[px,py] := Item;
end;

{ Вернуть символ предмета }
function ItemSymbol(id : integer) : string;
begin
  case ItemsData[id].vid of
    1 : Result := '['; // Шлем
    2 : Result := '&'; // Амулет
    3 : Result := ']'; // Плащ
    4 : Result := '['; // Броня на тело
    5 : Result := '~'; // Ремень
    6 : Result := ')'; // Оружие ближнего боя
    7 : Result := '}'; // Оружие дальнего боя
    8 : Result := '['; // Щит
    9 : Result := '&'; // Браслет
    10 : Result := '='; // Кольцо
    11: Result := ']'; // Перчатки
    12: Result := '['; // Обувь
    13: Result := '`'; // Аммуниция
    14: Result := '%'; // Еда
    15: Result := '$'; // Монеты
    16: Result := '?'; // Свиток
    17: Result := '"'; // Книга
    18: Result := '\'; // Волшебная палочка
    19: Result := '!'; // Зелье
    20: Result := '{'; // Инструмент
  end;
end;

{ Вывести некоторые хар-ки предмета }
procedure WriteSomeAboutItem(Item : TItem);
begin
  if Item.id > 0 then
    with Screen.Canvas do
    begin
      DrawBorder(15,29,70,4);
      // Вывести некоторые характеристики предмета
      Font.Color := cWHITE;
      TextOut(17*CharX, 30*CharY, 'Атака: '+IntToStr(ItemsData[Item.id].attack)+'  Защита: '+IntToStr(ItemsData[Item.id].defense));
      TextOut(17*CharX, 32*CharY, 'Вес: '+FloatToStr(ItemsData[Item.id].mass));
      Font.Color := cGRAY;
      TextOut(81*CharX, 32*CharY, '[ ]');
      Font.Color := ItemsData[Item.id].color;
      TextOut(82*CharX, 32*CharY, ItemSymbol(Item.id));
    end;
end;

{ Внимательно осмотреть предмет }
procedure ExamineItem(Item : TItem);
begin
  if Item.amount = 1 then
    AddMsg('Ты внимательно рассматриваешь '+ItemsData[Item.id].name3+', но не видешь ничего особенного.') else
      AddMsg('Ты внимательно рассматриваешь '+ItemsData[Item.id].name2+', но не видешь ничего особенного.');
end;

{ Применить эффект предмета или убрать }
procedure ItemOnOff(Item : TItem; PutOn : boolean);
var
  n : shortint;
begin
  if puton then n := 1 else n := -1;
  pc.defense := pc.defense + n * ItemsData[Item.id].defense;
end;
end.
