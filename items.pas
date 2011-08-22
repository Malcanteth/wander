unit items;

interface

uses
  Cons, Flags, Utils, Main, SysUtils, Msg, Tile;

type
  TItem = record
    id               : byte;         // Идентификатор
    amount           : word;         // Колличество
    mass             : real;         // Масса
    owner            : byte;         // Указатель на монстра
  end;

  TItemData = record
    name1, name2, name3        : string[40];      // Название (1ед.число,2мн.число,3кого)
    descr                      : string[100];      // Короткое описание
    vid                        : byte;            // Вид предмета
    color                      : longword;        // Цвет
    mass                       : real;
    attack, defense            : word;
    chance                     : byte;            // Шанс появления
    flags                      : longword;        // Флажки:)
  end;

const
  { Константы количества предметов }
  ItemsAmount = 27;

  {  Описание предметов }
  ItemsData : array[1..ItemsAmount] of TItemData =
  (
    ( name1: 'Золотая Монета'; name2: 'Золотые Монеты'; name3: 'Золотую Монету';
      descr: 'Эта маленькая золотая монетка - ходовая денежная единица в этом мире.';
      vid:15; color: cYELLOW; mass: 0.01;
      attack: 1; defense: 0; chance: 40;
      flags : NOF;
    ),
    ( name1: 'Столовый Нож'; name2: 'Столовые Ножи'; name3: 'Столовый Нож';
      vid:6; color: cLIGHTGRAY; mass: 4.5;
      attack: 5; defense: 0; chance: 60;
      flags : NOF;
    ),
    ( name1: 'Вилы'; name2: 'Вилы'; name3: 'Вилы';
      vid:6; color: cBROWN; mass: 19.2;
      attack: 11; defense: 0;  chance: 30;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: 'Кекс'; name2: 'Кексы'; name3: 'Кекс';
      vid:14; color: cBROWN; mass: 0.4;
      attack: 1; defense: 240; chance: 90;
      flags : NOF;
    ),
    ( name1: 'Шляпа'; name2: 'Шляпы'; name3: 'Шляпу';
      vid:1; color: cGRAY; mass: 3.0;
      attack: 1; defense: 1;  chance: 80;
      flags : NOF;
    ),
    ( name1: 'Лапти'; name2: 'Лапти'; name3: 'Лапти';
      vid:12; color: cBROWN; mass: 6.2;
      attack: 1; defense: 1;  chance: 90;
      flags : NOF;
    ),
    ( name1: 'Труп'; name2: 'Трупы'; name3: 'Труп';
      vid:14; color: cRED; mass: 50.4;
      attack: 5; defense: 15; chance: 20;
      flags : NOF;
    ),
    ( name1: 'Каска'; name2: 'Каски'; name3: 'Каску';
      vid:1; color: cBROWN; mass: 13.0;
      attack: 3; defense: 4; chance: 35;
      flags : NOF;
    ),
    ( name1: 'Мантия'; name2: 'Мантии'; name3: 'Мантию';
      vid:4; color: cPURPLE; mass: 9.1;
      attack: 1; defense: 2;  chance: 65;
      flags : NOF;
    ),
    ( name1: 'Куртка'; name2: 'Куртки'; name3: 'Куртку';
      vid:4; color: cBROWN; mass: 12.0;
      attack: 1; defense: 4; chance: 55;
      flags : NOF;
    ),
    ( name1: 'Кольчуга'; name2: 'Кольчуги'; name3: 'Кольчугу';
      vid:4; color: cLIGHTGRAY; mass: 25.5;
      attack: 4; defense: 8; chance: 10;
      flags : NOF;
    ),
    ( name1: 'Посох'; name2: 'Посохи'; name3: 'Посох';
      vid:6; color: cBROWN; mass: 10.7;
      attack: 8; defense: 0;  chance: 35;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: 'Кинжал'; name2: 'Кинжалы'; name3: 'Кинжал';
      vid:6; color: cLIGHTGRAY; mass: 7.7;
      attack: 9; defense: 0;  chance: 60;
      flags : NOF;
    ),
    ( name1: 'Дубина'; name2: 'Дубины'; name3: 'Дубину';
      vid:6; color: cBROWN; mass: 16.0;
      attack: 12; defense: 0;  chance: 30;
      flags : NOF;
    ),
    ( name1: 'Короткий меч'; name2: 'Короткие мечи'; name3: 'Короткий Меч';
      vid:6; color: cWHITE; mass: 12.0;
      attack: 13; defense: 0;  chance: 30;
      flags : NOF;
    ),
    ( name1: 'Палица'; name2: 'Палицы'; name3: 'Палицу';
      vid:6; color: cLIGHTGRAY; mass: 14.0;
      attack: 15; defense: 0; chance: 23;
      flags : NOF;
    ),
    ( name1: 'Длинный меч'; name2: 'Длинные мечи'; name3: 'Длинный Меч';
      vid:6; color: cCYAN; mass: 21.0;
      attack: 17; defense: 0; chance: 15;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: 'Щит'; name2: 'Щиты'; name3: 'Щит';
      vid:8; color: cBROWN; mass: 15.2;
      attack: 7; defense: 0; chance: 15;
      flags : NOF;
    ),
    ( name1: 'Сапоги'; name2: 'Сапоги'; name3: 'Сапоги';
      vid:12; color: cGREEN; mass: 8.7;
      attack: 4; defense: 3; chance: 35;
      flags : NOF;
    ),
    ( name1: 'Лаваш'; name2: 'Лаваши'; name3: 'Лаваш';
      vid:14; color: cBROWN; mass: 1.4;
      attack: 2; defense: 110; chance: 60;
      flags : NOF;
    ),
    ( name1: 'Зеленое яблоко'; name2: 'Зеленые яблоки'; name3: 'Зеленое яблоко';
      vid:14; color: cLIGHTGREEN; mass: 0.5;
      attack: 2; defense: 150; chance: 90;
      flags : NOF;
    ),
    ( name1: 'Кусок мяса'; name2: 'Куски мяса'; name3: 'Кусок мяса';
      vid:14; color: cLIGHTRED; mass: 6.0;
      attack: 3; defense: 50; chance: 35;
      flags : NOF;
    ),
    ( name1: 'Зелье лечения'; name2: 'Зелья лечения'; name3: 'Зелье лечения';
      vid:19; color: cLIGHTBLUE; mass: 0.3;
      attack: 1; defense: 0; chance: 40;
      flags : NOF;
    ),
    ( name1: 'Зелье исцеления'; name2: 'Зелья исцеления'; name3: 'Зелье исцеления';
      vid:19; color: cRED; mass: 0.3;
      attack: 1; defense: 0; chance: 15;
      flags : NOF;
    ),
    ( name1: 'Бутылка дешевого пива'; name2: 'Бутылки дешевого пива'; name3: 'Бутылку дешевого пива';
      vid:19; color: cBROWN; mass: 0.5;
      attack: 2; defense: 0; chance: 20;
      flags : NOF;
    ),
    ( name1: 'Голова'; name2: 'Головы'; name3: 'Голову';
      vid:14; color: cBROWN; mass: 5.0;
      attack: 2; defense: 40; chance: 0;
      flags : NOF;
    ),
    ( name1: 'Ключ от восточных врат Эвилиара'; name2: 'Ключи от восточных врат Эвилиара'; name3: 'Ключ от восточных врат Эвилиара';
      vid:20; color: cCYAN; mass: 0.3;
      attack: 1; defense: 0; chance: 0;
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
  idHEAD           = 26;
  idGATESKEY       = 27;

function GenerateItem(whatvid : byte) : TItem;                // Генерировать случайный предмет определенного вида
function CreateItem(n : byte; am : integer;
                            OwnerId : byte) : TItem;          // Создать предмет
function PutItem(px,py : byte; Item : TItem) : boolean;       // Положить предмет
function ItemSymbol(id : integer) : string;                   // Вернуть символ предмета
procedure WriteSomeAboutItem(Item : TItem);                   // Вывести некоторые хар-ки предмета
procedure ExamineItem(Item : TItem);                          // Внимательно осмотреть предмет
procedure ItemOnOff(Item : TItem; PutOn : boolean);           // Применить эффект предмета или убрать
function ItemName(Item : TItem; skl : byte;
                             all : boolean) : string;         // Вернуть полное название предмета

implementation

uses
  Map, Player, Monsters;

{ Генерировать случайный предмет определенного вида }
function GenerateItem(whatvid : byte) : TItem;
var
  list : array[1..ItemsAmount] of integer;
  amount, i : integer;
begin
  amount := 0;
  // Создать список указателей
  for i:=1 to ItemsAmount do
    if ItemsData[i].vid = whatvid then
    begin
      inc(amount);
      list[amount] := i;
    end;
  if amount > 0 then
  begin
    if amount = 1 then
      Result := CreateItem(list[amount], 1, 0) else
      begin
        repeat
          i := Random(amount)+1;
        until
          (Random(100)+1 <= ItemsData[list[i]].chance);
         CreateItem(list[i], 1, 0)
      end;
  end;
end;

{ Создать предмет }
function CreateItem(n : byte; am : integer; OwnerId : byte) : TItem;
var
  Item : TItem;
begin
  with Item do
  begin
    id := n;
    amount := am;
    mass := ItemsData[id].mass;
    owner := OwnerId;
    // Меняем массу трупа, на массу убитого монстра (-20%)
    if id = idCORPSE then
      mass := MonstersData[owner].mass - Round(MonstersData[owner].mass * 0.20);
    // Меняем массу головы, на массу 15% веса трупа
    if id = idHEAD then
      mass := Round(MonstersData[owner].mass * 0.15);
  end;
  Result := Item;
end;

{ Положить предмет }
function PutItem(px,py : byte; Item : TItem) : boolean;
var
  x, y : integer;
begin
  Result := True;
  if not TilesData[M.Tile[px,py]].move then
    Result := False else
      if M.Item[px,py].id > 0 then
      begin
        if (M.Item[px,py].id = Item.id) and (M.Item[px,py].owner = Item.owner) then
        begin
          inc(M.Item[px,py].amount, Item.amount);
          exit;
        end else
          Result := False;
      end else
        M.Item[px,py] := Item;
  // Если нельзя кинуть предмет на указанном месте, попробовать кинуть его в окрестностях
  if Result = False then
  begin
    for x:=px-1 to px+1 do
    begin
      for y:=py-1 to py+1 do
        if (x > 0) and (x <=MapX) and (y > 0) and (y <= MapY) then
          if NOT ((x=px)and(y=py)) then
          begin
            if not TilesData[M.Tile[x,y]].move then
              Result := False else
                if M.Item[x,y].id > 0 then
                begin
                  if (M.Item[x,y].id = Item.id) and (M.Item[px,py].owner = Item.owner) then
                  begin
                    inc(M.Item[x,y].amount, Item.amount);
                    Result := True;
                    break;
                  end else
                    Result := False;
                end else
                  begin
                    M.Item[x,y] := Item;
                    Result := True;
                    break;
                  end;
          end;
      if Result = True then break;
    end;
  end;
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
var
  s, weight : string;
begin
  if Item.id > 0 then
    with Screen.Canvas do
    begin
      DrawBorder(15,31,70,4);
      // Начать описание предмета
      s := '';
      {Атака - выводить только если это - оружие (ближнего боя и стрела}
      case ItemsData[Item.id].vid of
        6,13 : s := s + 'Атака: '+IntToStr(ItemsData[Item.id].attack)+' ';
      end;
      {Защита - если это броня (шлем, плащ, броня на тело, перчатки, обувь}
      case ItemsData[Item.id].vid of
        1,3,4,11,12 : s := s + 'Защита: '+IntToStr(ItemsData[Item.id].defense)+' ';
      end;
      // Вывести некоторые характеристики предмета
      Font.Color := cCYAN;
      // Атака для оружия, защита для брони или информация о еде и тд
      TextOut(17*CharX, 32*CharY, s);
      // Вывести символ предмета
      Font.Color := cGRAY;
      TextOut(49*CharX, 31*CharY, '| |');
      Font.Color := ItemsData[Item.id].color;
      TextOut(50*CharX, 31*CharY, ItemSymbol(Item.id));
      // Вывести вес предмета и общий вес инвентаря
      Font.Color := cLIGHTGRAY;
      weight := 'Масса предмета: '+FloatToStr(Item.mass)+'  Общая масса инвентаря: '+FloatToStr(pc.invmass);
      TextOut((15 + ((70 - length(weight)) div 2))*CharX, 35*CharY, weight);
    end;
end;

{ Внимательно осмотреть предмет }
procedure ExamineItem(Item : TItem);
begin
  if ItemsData[Item.id].descr <> '' then
    AddMsg(ItemsData[Item.id].descr) else
      AddMsg('Ты внимательно рассматриваешь '+ItemName(Item, 1, TRUE)+', но не видешь ничего особенного.');
end;

{ Применить эффект предмета или убрать }
procedure ItemOnOff(Item : TItem; PutOn : boolean);
var
  n : shortint;
begin
  if puton then n := 1 else n := -1;
  pc.defense := pc.defense + n * ItemsData[Item.id].defense;
end;

{ Вернуть полное название предмета SKL = 0 ЧТО? SKL = 1 КОГО? ЧЕГО? }
function ItemName(Item : TItem;  skl : byte; all : boolean) : string;
var
  s : string;
begin
  case SKL of
    0 :
    if (Item.amount = 1) or (not ALL) then
     s := ItemsData[Item.id].name1 else
       s := ItemsData[Item.id].name2;
    1 :
    if (Item.amount = 1) or (not ALL) then
     s := ItemsData[Item.id].name3 else
       s := ItemsData[Item.id].name2;
  end;
  if Item.owner > 0 then
    if (Item.amount = 1) or (not ALL) then
      s := s + ' ' + MonstersData[Item.owner].name5 else
        s := s + ' ' + MonstersData[Item.owner].name6;
  if (Item.amount > 1) and (ALL) then
    s := s + ' ('+IntToStr(Item.amount)+' шт)';
  Result := s;
end;

end.
