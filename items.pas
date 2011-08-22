unit items;

interface

uses
  Cons, Flags, Utils, Main, SysUtils, Msg, Tile, Ability;

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
    kind                       : byte;            // Вид оружия или брони
    flags                      : longword;        // Флажки:)
  end;

const
  { Константы количества предметов }
  ItemsAmount = 37;

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
      attack: 5; defense: 0; chance: 60; kind: CLOSE_BLADE;
      flags : NOF;
    ),
    ( name1: 'Вилы'; name2: 'Вилы'; name3: 'Вилы';
      vid:6; color: cBROWN; mass: 19.2;
      attack: 11; defense: 0;  chance: 30; kind: CLOSE_TWO;
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
      attack: 8; defense: 0;  chance: 35; kind: CLOSE_STAFF;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: 'Кинжал'; name2: 'Кинжалы'; name3: 'Кинжал';
      vid:6; color: cLIGHTGRAY; mass: 7.7;
      attack: 9; defense: 0;  chance: 60; kind: CLOSE_BLADE;
      flags : NOF;
    ),
    ( name1: 'Дубина'; name2: 'Дубины'; name3: 'Дубину';
      vid:6; color: cBROWN; mass: 16.0;
      attack: 12; defense: 0;  chance: 30; kind: CLOSE_CLUB;
      flags : NOF;
    ),
    ( name1: 'Короткий меч'; name2: 'Короткие мечи'; name3: 'Короткий Меч';
      vid:6; color: cWHITE; mass: 12.0;
      attack: 13; defense: 0;  chance: 30; kind: CLOSE_BLADE;
      flags : NOF;
    ),
    ( name1: 'Палица'; name2: 'Палицы'; name3: 'Палицу';
      vid:6; color: cLIGHTGRAY; mass: 14.0;
      attack: 15; defense: 0; chance: 23; kind: CLOSE_CLUB;
      flags : NOF;
    ),
    ( name1: 'Длинный меч'; name2: 'Длинные мечи'; name3: 'Длинный Меч';
      vid:6; color: cCYAN; mass: 21.0;
      attack: 17; defense: 0; chance: 15; kind: CLOSE_BLADE;
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
    ),
    ( name1: 'Топор'; name2: 'Топоры'; name3: 'Топор';
      vid:6; color: cWHITE; mass: 13.5;
      attack: 12; defense: 0;  chance: 30; kind: CLOSE_AXE;
      flags : NOF;
    ),
    ( name1: 'Лук'; name2: 'Луки'; name3: 'Лук';
      vid:7; color: cBROWN; mass: 5.2;
      attack: 4; defense: 0;  chance: 20; kind: FAR_BOW;
      flags : NOF;
    ),
    ( name1: 'Арбалет'; name2: 'Арбалеты'; name3: 'Арбалет';
      vid:7; color: cBROWN; mass: 8.2;
      attack: 6; defense: 0;  chance: 18; kind: FAR_CROSS;
      flags : NOF;
    ),
    ( name1: 'Праща'; name2: 'Пращи'; name3: 'Пращу';
      vid:7; color: cGRAY; mass: 0.4;
      attack: 0; defense: 0;  chance: 25; kind: FAR_SLING;
      flags : NOF;
    ),
    ( name1: 'Духовая трубка'; name2: 'Духовые трубки'; name3: 'Духовую трубку';
      vid:7; color: cCYAN; mass: 0.2;
      attack: 0; defense: 0;  chance: 23; kind: FAR_PIPE;
      flags : NOF;
    ),
    ( name1: 'Стрела'; name2: 'Стрелы'; name3: 'Стрелу';
      vid:13; color: cBROWN; mass: 0.08;
      attack: 4; defense: 0;  chance: 40; kind: FAR_BOW;
      flags : NOF;
    ),
    ( name1: 'Болт'; name2: 'Болты'; name3: 'Болт';
      vid:13; color: cRED; mass: 0.20;
      attack: 4; defense: 0;  chance: 35; kind: FAR_CROSS;
      flags : NOF;
    ),
    ( name1: 'Маленький Камень'; name2: 'Маленькие Камни'; name3: 'Мальнький Камень';
      vid:13; color: cRED; mass: 0.35;
      attack: 3; defense: 0;  chance: 50; kind: FAR_SLING;
      flags : NOF;
    ),
    ( name1: 'Игла'; name2: 'Иглы'; name3: 'Иглу';
      vid:13; color: cCYAN; mass: 0.01;
      attack: 3; defense: 0;  chance: 50; kind: FAR_PIPE;
      flags : NOF;
    ),
    ( name1: 'Накидка из шкуры зверя'; name2: 'Накидки из шкуры зверя'; name3: 'Накидку из шкуры зверя';
      vid:4; color: cBROWN; mass: 10.5;
      attack: 1; defense: 3;  chance: 45;
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
  idAXE            = 28;
  idBOW            = 29;
  idCROSSBOW       = 30;
  idSLING          = 31;
  idBLOWPIPE       = 32;
  idARROW          = 33;
  idBOLT           = 34;
  idLITTLEROCK     = 35;
  idIGLA           = 36;
  idCAPE           = 37;

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
procedure UseItem(n : byte);                                  // Использовать предмет

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
         Result := CreateItem(list[i], 1, 0)
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
    21: Result := ';'; // Барахло
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
      // Тип оружия, если это оружие
      Font.Color := cWHITE;
      if (ItemsData[Item.id].vid = 6) then
        TextOut((83-Length(CLOSEWPNNAME[ItemsData[Item.id].kind]))*CharX, 32*CharY, '"'+CLOSEWPNNAME[ItemsData[Item.id].kind]+'"');
      if (ItemsData[Item.id].vid = 7) or (ItemsData[Item.id].vid = 13) then
        TextOut((83-Length(FARWPNNAME[ItemsData[Item.id].kind]))*CharX, 32*CharY, '"'+FARWPNNAME[ItemsData[Item.id].kind]+'"');
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

{ Использовать предмет }
procedure UseItem(n : byte);
begin
  // Считать монетки (ворюши должны становиться агрессивными к тебе и орать "Отдай деньги!")
  if pc.Inv[N].id = idCOIN then
  begin
    if pc.Inv[N].amount = 1 then
      AddMsg('Что тут пересчитывать - у тебя ровно одна золотая монетка...') else
        AddMsg('Ты пересчитал'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[N],0, TRUE)+'.');
    pc.turn := 1;
  end else
    // Использовать предмет по назначению
    case ItemsData[pc.Inv[N].id].vid of
      // Надеть
      1..13:
      begin
        case pc.EquipItem(pc.Inv[N]) of
          0 :
          begin
            ItemOnOff(pc.Inv[N], TRUE);
            if (pc.Inv[N].amount > 1) and (ItemsData[pc.Inv[N].id].vid <> 13) then
              dec(pc.Inv[N].amount) else
                pc.Inv[N].id := 0;
            pc.RefreshInventory;
            N := Cell;
            GameState := gsEQUIPMENT;
          end;
          1 :
          begin
            ItemOnOff(pc.Inv[N], TRUE);
            GameState := gsPLAY;
          end;
        end;
      end;
      // Съесть
      14:
      begin
        if pc.status[stHUNGRY] >= 0 then
        begin
          pc.status[stHUNGRY] := pc.status[stHUNGRY] - Round(ItemsData[pc.Inv[N].id].defense * pc.Inv[N].mass * 1.3 * (1 + (pc.ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
          if pc.status[stHUNGRY] < -500 then
          begin
            AddMsg('[Ты не смог'+pc.HeSheIt(3)+' доесть '+ItemName(pc.Inv[N], 1, FALSE)+', потому что очень насытил'+pc.HeSheIt(2)+'... чересчур насытил'+pc.HeSheIt(2)+'...]');
            pc.status[stHUNGRY] := -500;
          end else
              AddMsg('[Ты съел'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[N], 1, FALSE)+'.]');
          pc.DeleteInvItem(pc.Inv[N], FALSE);
          pc.turn := 1;
        end else
          AddMsg('Тебе не хочется больше есть!');
      end;
      // Выпить
      19:
      begin
        AddMsg('Ты выпил'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[N], 1, FALSE)+'.');
        // Лечение
        if pc.Inv[N].id = idPOTIONCURE then
        begin
          if pc.Hp < pc.RHp then
          begin
            a := Random(11)+5;
            if pc.hp + a > pc.RHp then
              a := pc.RHp - pc.Hp;
            inc(pc.hp, a);
            if pc.Hp >= pc.RHp then
            begin
              AddMsg('[Ты полностью исцелил'+pc.HeSheIt(2)+'!] ({+'+IntToStr(a)+'})');
              pc.Hp := pc.RHp;
            end else
              AddMsg('[Тебе стало немного лучше] ({+'+IntToStr(a)+'})');
          end else
            AddMsg('Ничего не произошло.');
        end;
        // Исцеление
        if pc.Inv[N].id = idPOTIONHEAL then
        begin
          if pc.Hp < pc.RHp then
          begin
            AddMsg('[Ты полностью исцелил'+pc.HeSheIt(2)+'!] ({+'+IntToStr(pc.RHp-pc.Hp)+'})');
            pc.Hp := pc.RHp;
          end else
            AddMsg('Ничего не произошло.');
        end;
        // Пивасик
        if pc.Inv[N].id = idCHEAPBEER then
        begin
          if pc.status[stDRUNK] <= 500 then
          begin
            if pc.Hp < pc.RHp then
            begin
              a := Random(6)+1;
              inc(pc.hp, a);
              if pc.Hp >= pc.RHp then
              begin
                pc.Hp := pc.RHp;
                AddMsg('Это пиво - полная ерунда, но тем неменее ты теперь чувствуешь себя замечательно!');
              end else
                AddMsg('Не такое уж это пиво и плохое...');
            end else
              AddMsg('Ты довольно быстро осушил'+pc.HeSheIt(1)+' бутылку пива. Не плохо. Освежает!');
            inc(pc.status[stDRUNK], 130);
          end else
            AddMsg('Ты попытал'+pc.HeSheIt(2)+' выпить еще, но случайно бутылка выскользнула из твоих рук и разбилась!..');
        end;
        pc.DeleteInvItem(pc.Inv[N], FALSE);
        pc.turn := 1;
      end;
    end;
end;

end.
