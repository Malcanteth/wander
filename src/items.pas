unit items;

interface

uses
  Cons, Flags, Utils, Main, SysUtils, Msg, Tile, Ability;

type
  TItemType = record
    Name: string[20];
    Symbol: Char;
    Chance: Byte; // Как часто предметы данного типа будут появляться на карте
    MaxAmount: Integer;
  end;

  TItem = record
    Id: Byte; // Идентификатор
    Amount: word; // Колличество
    Mass: real; // Масса
    Owner: Byte; // Указатель на монстра
    LiquidId: Byte; // ID напитка
  end;

const
  { Кол-во типов предметов }
  ItemTypeAmount = 22;

  ItemTypeData: array [1 .. ItemTypeAmount] of TItemType = (
    //
    (name: 'Шлем'; Symbol: '['; Chance: 15; MaxAmount: 1),
    //
    (name: 'Амулет'; Symbol: '&'; Chance: 5; MaxAmount: 1),
    //
    (name: 'Накидка'; Symbol: ']'; Chance: 20; MaxAmount: 1),
    //
    (name: 'Броня'; Symbol: '['; Chance: 20; MaxAmount: 1),
    //
    (name: 'Ремень'; Symbol: '~'; Chance: 10; MaxAmount: 1),
    //
    (name: 'Оружие ближнего боя'; Symbol: ')'; Chance: 30; MaxAmount: 1),
    //
    (name: 'Оружие дальнего боя'; Symbol: '}'; Chance: 30; MaxAmount: 1),
    //
    (name: 'Щит'; Symbol: '['; Chance: 15; MaxAmount: 1),
    //
    (name: 'Браслет'; Symbol: '&'; Chance: 5; MaxAmount: 1),
    //
    (name: 'Кольцо'; Symbol: '='; Chance: 4; MaxAmount: 1),
    //
    (name: 'Перчатки'; Symbol: ']'; Chance: 10; MaxAmount: 1),
    //
    (name: 'Обувь'; Symbol: '['; Chance: 20; MaxAmount: 1),

    (name: 'Амуниция'; Symbol: '`'; Chance: 50; MaxAmount: 15),
    //
    (name: 'Еда'; Symbol: '%'; Chance: 70; MaxAmount: 4),
    //
    (name: 'Монеты'; Symbol: '$'; Chance: 40; MaxAmount: 30),
    //
    (name: 'Свиток'; Symbol: '?'; Chance: 20; MaxAmount: 1),
    //
    (name: 'Книга'; Symbol: '"'; Chance: 7; MaxAmount: 1),
    //
    (name: 'Волшебная палочка'; Symbol: '\'; Chance: 9; MaxAmount: 1),
    //
    (name: 'Зелье'; Symbol: '!'; Chance: 25; MaxAmount: 1),
    //
    (name: 'Инструмент'; Symbol: '{'; Chance: 5; MaxAmount: 1),
    //
    (name: 'Барахло'; Symbol: ';'; Chance: 40; MaxAmount: 1),
    //
    (name: 'Растение'; Symbol: '^'; Chance: 50; MaxAmount: 1)
    //
    );

type
  TItemData = record
    Name1, Name2, Name3: string[40]; // Название (1ед.число,2мн.число,3кого)
    Descr: string[100]; // Короткое описание
    Vid: Byte; // Вид предмета
    Color: Byte; // Цвет
    Mass: real;
    Attack, Defense: word;
    Chance: Byte; // Шанс появления
    Kind: Byte; // Вид оружия или брони
    DmgType: Byte; // Тип урона
    Flags: LongWord; // Флажки:)
  end;

const
  { Кол-во предметов }
  ItemsAmount = 36;
  { Описание предметов }
  ItemsData: array [1 .. ItemsAmount] of TItemData = (
    //
    (Name1: 'Золотая Монета'; Name2: 'Золотые Монеты'; Name3: 'Золотую Монету';
    Descr: 'Эта маленькая золотая монетка - ходовая денежная единица в этом мире.'; Vid: 15; Color: crYELLOW; Mass: 0.01; Attack: 1; Defense: 0;
    Chance: 40; Flags: NOF;),
    //
    (Name1: 'Столовый Нож'; Name2: 'Столовые Ножи'; Name3: 'Столовый Нож'; Vid: 6; Color: crLIGHTGRAY; Mass: 4.5; Attack: 5; Defense: 0; Chance: 60;
    Kind: CLOSE_BLADE; Flags: NOF;),
    //
    (Name1: 'Вилы'; Name2: 'Вилы'; Name3: 'Вилы'; Vid: 6; Color: crBROWN; Mass: 19.2; Attack: 11; Defense: 0; Chance: 30; Kind: CLOSE_TWO;
    Flags: NOF or I_TWOHANDED;),
    //
    (Name1: 'Кекс'; Name2: 'Кексы'; Name3: 'Кекс'; Vid: 14; Color: crBROWN; Mass: 0.4; Attack: 1; Defense: 240; Chance: 90; Flags: NOF;),
    //
    (Name1: 'Шляпа'; Name2: 'Шляпы'; Name3: 'Шляпу'; Vid: 1; Color: crGRAY; Mass: 3.0; Attack: 1; Defense: 1; Chance: 80; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: 'Лапти'; Name2: 'Лапти'; Name3: 'Лапти'; Vid: 12; Color: crBROWN; Mass: 6.2; Attack: 1; Defense: 1; Chance: 90; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: 'Труп'; Name2: 'Трупы'; Name3: 'Труп'; Vid: 14; Color: crRED; Mass: 50.4; Attack: 5; Defense: 15; Chance: 20; Flags: NOF;),
    //
    (Name1: 'Каска'; Name2: 'Каски'; Name3: 'Каску'; Vid: 1; Color: crBROWN; Mass: 13.0; Attack: 3; Defense: 4; Chance: 35; Kind: ARMOR_LIGHT;
    Flags: NOF;),
    //
    (Name1: 'Мантия'; Name2: 'Мантии'; Name3: 'Мантию'; Vid: 3; Color: crPURPLE; Mass: 9.1; Attack: 1; Defense: 2; Chance: 65; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: 'Куртка'; Name2: 'Куртки'; Name3: 'Куртку'; Vid: 4; Color: crBROWN; Mass: 12.0; Attack: 1; Defense: 4; Chance: 55; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: 'Кольчуга'; Name2: 'Кольчуги'; Name3: 'Кольчугу'; Vid: 4; Color: crLIGHTGRAY; Mass: 25.5; Attack: 4; Defense: 8; Chance: 10;
    Kind: ARMOR_LIGHT; Flags: NOF;),
    //
    (Name1: 'Посох'; Name2: 'Посохи'; Name3: 'Посох'; Vid: 6; Color: crBROWN; Mass: 10.7; Attack: 8; Defense: 0; Chance: 35; Kind: CLOSE_STAFF;
    Flags: NOF or I_TWOHANDED;),
    //
    (Name1: 'Кинжал'; Name2: 'Кинжалы'; Name3: 'Кинжал'; Vid: 6; Color: crLIGHTGRAY; Mass: 7.7; Attack: 9; Defense: 0; Chance: 60; Kind: CLOSE_BLADE;
    Flags: NOF;),
    //
    (Name1: 'Дубина'; Name2: 'Дубины'; Name3: 'Дубину'; Vid: 6; Color: crBROWN; Mass: 16.0; Attack: 12; Defense: 0; Chance: 30; Kind: CLOSE_CLUB;
    Flags: NOF;),
    //
    (Name1: 'Короткий меч'; Name2: 'Короткие мечи'; Name3: 'Короткий Меч'; Vid: 6; Color: crWHITE; Mass: 12.0; Attack: 13; Defense: 0; Chance: 30;
    Kind: CLOSE_BLADE; Flags: NOF;),
    //
    (Name1: 'Палица'; Name2: 'Палицы'; Name3: 'Палицу'; Vid: 6; Color: crLIGHTGRAY; Mass: 14.0; Attack: 15; Defense: 0; Chance: 23; Kind: CLOSE_CLUB;
    Flags: NOF;),
    //
    (Name1: 'Длинный меч'; Name2: 'Длинные мечи'; Name3: 'Длинный Меч'; Vid: 6; Color: crCYAN; Mass: 21.0; Attack: 17; Defense: 0; Chance: 15;
    Kind: CLOSE_BLADE; Flags: NOF or I_TWOHANDED;),
    //
    (Name1: 'Щит'; Name2: 'Щиты'; Name3: 'Щит'; Vid: 8; Color: crBROWN; Mass: 15.2; Attack: 7; Defense: 0; Chance: 15; Flags: NOF;),
    //
    (Name1: 'Сапоги'; Name2: 'Сапоги'; Name3: 'Сапоги'; Vid: 12; Color: crGREEN; Mass: 8.7; Attack: 4; Defense: 3; Chance: 35; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: 'Лаваш'; Name2: 'Лаваши'; Name3: 'Лаваш'; Vid: 14; Color: crBROWN; Mass: 1.4; Attack: 2; Defense: 110; Chance: 60; Flags: NOF;),
    //
    (Name1: 'Зеленое яблоко'; Name2: 'Зеленые яблоки'; Name3: 'Зеленое яблоко'; Vid: 14; Color: crLIGHTGREEN; Mass: 0.5; Attack: 2; Defense: 150;
    Chance: 90; Flags: NOF;),
    //
    (Name1: 'Кусок мяса'; Name2: 'Куски мяса'; Name3: 'Кусок мяса'; Vid: 14; Color: crLIGHTRED; Mass: 6.0; Attack: 3; Defense: 50; Chance: 35;
    Flags: NOF;),
    //
    (Name1: 'Голова'; Name2: 'Головы'; Name3: 'Голову'; Vid: 14; Color: crBROWN; Mass: 5.0; Attack: 2; Defense: 40; Chance: 0; Flags: NOF;),
    //
    (Name1: 'Ключ от восточных врат Эвилиара'; Name2: 'Ключи от восточных врат Эвилиара'; Name3: 'Ключ от восточных врат Эвилиара'; Vid: 20;
    Color: crCYAN; Mass: 0.3; Attack: 1; Defense: 0; Chance: 0; Flags: NOF;),
    //
    (Name1: 'Топор'; Name2: 'Топоры'; Name3: 'Топор'; Vid: 6; Color: crWHITE; Mass: 13.5; Attack: 12; Defense: 0; Chance: 30; Kind: CLOSE_AXE;
    Flags: NOF;),
    //
    (Name1: 'Лук'; Name2: 'Луки'; Name3: 'Лук'; Vid: 7; Color: crBROWN; Mass: 5.2; Attack: 4; Defense: 0; Chance: 20; Kind: FAR_BOW; Flags: NOF;),
    //
    (Name1: 'Арбалет'; Name2: 'Арбалеты'; Name3: 'Арбалет'; Vid: 7; Color: crBROWN; Mass: 8.2; Attack: 6; Defense: 0; Chance: 18; Kind: FAR_CROSS;
    Flags: NOF;),
    //
    (Name1: 'Праща'; Name2: 'Пращи'; Name3: 'Пращу'; Vid: 7; Color: crGRAY; Mass: 0.4; Attack: 0; Defense: 0; Chance: 25; Kind: FAR_SLING;
    Flags: NOF;),
    //
    (Name1: 'Духовая трубка'; Name2: 'Духовые трубки'; Name3: 'Духовую трубку'; Vid: 7; Color: crCYAN; Mass: 0.2; Attack: 0; Defense: 0; Chance: 23;
    Kind: FAR_PIPE; Flags: NOF;),
    //
    (Name1: 'Стрела'; Name2: 'Стрелы'; Name3: 'Стрелу'; Vid: 13; Color: crBROWN; Mass: 0.08; Attack: 4; Defense: 0; Chance: 40; Kind: FAR_BOW;
    Flags: NOF;),
    //
    (Name1: 'Болт'; Name2: 'Болты'; Name3: 'Болт'; Vid: 13; Color: crRED; Mass: 0.20; Attack: 4; Defense: 0; Chance: 35; Kind: FAR_CROSS;
    Flags: NOF;),
    //
    (Name1: 'Маленький Камень'; Name2: 'Маленькие Камни'; Name3: 'Маленький Камень'; Vid: 13; Color: crLIGHTGRAY; Mass: 0.35; Attack: 3; Defense: 0;
    Chance: 60; Kind: FAR_SLING; Flags: NOF;),
    //
    (Name1: 'Игла'; Name2: 'Иглы'; Name3: 'Иглу'; Vid: 13; Color: crCYAN; Mass: 0.01; Attack: 3; Defense: 0; Chance: 50; Kind: FAR_PIPE; Flags: NOF;),
    //
    (Name1: 'Накидка из шкуры зверя'; Name2: 'Накидки из шкуры зверя'; Name3: 'Накидку из шкуры зверя'; Vid: 4; Color: crBROWN; Mass: 10.5; Attack: 1;
    Defense: 3; Chance: 45; Kind: ARMOR_CLOTHES; Flags: NOF;),
    //
    (Name1: 'Бутылка'; Name2: 'Бутылки'; Name3: 'Бутылку'; Vid: 19; Color: crCYAN; Mass: 0.1; Attack: 1; Defense: 0; Chance: 40; Flags: NOF;),
    //
    (Name1: 'Корень Мандрагоры'; Name2: 'Корни Мандрагоры'; Name3: 'Корень Мандрагоры'; Vid: 22; Color: crBROWN; Mass: 4; Attack: 0; Defense: 0;
    Chance: 5; Flags: NOF;)
    //
    );

  { Уникальные идентификаторы предметов }
  idCOIN = 1;
  idKITCHENKNIFE = 2;
  idPITCHFORK = 3;
  idKEKS = 4;
  idJACKSONSHAT = 5;
  idLAPTI = 6;
  idCORPSE = 7;
  idHELMET = 8;
  idMANTIA = 9;
  idJACKET = 10;
  idCHAINARMOR = 11;
  idSTAFF = 12;
  idDAGGER = 13;
  idDUBINA = 14;
  idSHORTSWORD = 15;
  idPALICA = 16;
  idLONGSWORD = 17;
  idSHIELD = 18;
  idBOOTS = 19;
  idLAVASH = 20;
  idGREENAPPLE = 21;
  idMEAT = 22;
  idHEAD = 23;
  idGATESKEY = 24;
  idAXE = 25;
  idBOW = 26;
  idCROSSBOW = 27;
  idSLING = 28;
  idBLOWPIPE = 29;
  idARROW = 30;
  idBOLT = 31;
  idLITTLEROCK = 32;
  idIGLA = 33;
  idCAPE = 34;
  idBOTTLE = 35;
  idMANDAGORAROOT = 36;

  { Уникальные идентификаторы жидкостей }
  lqCURE = 1;
  lqHEAL = 2;
  lqCHEAPBEER = 3;
  lqKEFIR = 4;

function HaveItemTypeInDB(wtype: Byte): boolean; // Есть ли предмет данного типа в базе (убрать функцию, после добавления всех типов предметов)
function GenerateItem(wtype: Byte): TItem; // Генерировать случайный предмет определенного вида
function CreateItem(n: Byte; am: Integer; OwnerId: Byte): TItem; // Создать предмет
function PutItem(px, py: Byte; Item: TItem; Amount: Integer): boolean; // Положить предмет
procedure WriteSomeAboutItem(Item: TItem; compare: boolean = false); // Вывести некоторые хар-ки предмета
procedure ExamineItem(Item: TItem); // Внимательно осмотреть предмет
procedure ItemOnOff(Item: TItem; PutOn: boolean); // Применить эффект предмета или убрать
function ItemName(Item: TItem; skl: Byte; all: boolean): string; // Вернуть полное название предмета
procedure UseItem(SelectedItem: Byte); // Использовать предмет в инвентаре
function SameItems(I1, I2: TItem): boolean; // Сравнить два предмета - одинаковы ли они?
function ItemColor(I: TItem): Byte; // Вернуть цвет предмета

implementation

uses
  Map, Player, Monsters, Conf, Liquid;

{ Есть ли предмет данного типа в базе (убрать функцию, после добавления всех типов предметов) }
function HaveItemTypeInDB(wtype: Byte): boolean;
var
  I: Integer;
  e: boolean;
begin
  e := false;
  for I := 1 to ItemsAmount do
    if (ItemsData[I].Vid = wtype) and (ItemsData[I].Chance > 0) then
    begin
      e := TRUE;
      break;
    end;
  Result := e;
end;

{ Генерировать случайный предмет определенного вида }
function GenerateItem(wtype: Byte): TItem;
var
  List: array [1 .. ItemsAmount] of Integer;
  Amount, I: Integer;
begin
  Amount := 0;
  // Создать список указателей
  for I := 1 to ItemsAmount do
    if ItemsData[I].Vid = wtype then
    begin
      inc(Amount);
      List[Amount] := I;
    end;
  if Amount > 0 then
  begin
    if Amount = 1 then
      I := Amount
    else
    begin
      repeat
        I := Random(Amount) + 1;
      until (Random(100) + 1 <= ItemsData[List[I]].Chance);
    end;
  end;
  if I <> idBOTTLE then
    Result := CreateItem(List[I], 1, 0)
  else
    Result := CreatePotion(List[I], 1);
end;

{ Создать предмет }
function CreateItem(n: Byte; am: Integer; OwnerId: Byte): TItem;
var
  Item: TItem;
  I: Integer;
begin
  with Item do
  begin
    Id := n;
    Amount := am;
    Mass := ItemsData[Id].Mass;
    Owner := OwnerId;
    // Меняем массу трупа, на массу убитого монстра (-20%)
    if Id = idCORPSE then
      Mass := Round(MonstersData[Owner].Mass * 0.8);
    // Меняем массу головы, на массу 15% веса трупа
    if Id = idHEAD then
      Mass := Round(MonstersData[Owner].Mass * 0.15);
    // Если бутылка, то заполнить ее напитком
    if Id = idBOTTLE then
    begin
      repeat
        I := Random(LiquidAmount) + 1;
      until (Random(100) + 1 <= AllLiquid[I].Chance);
      LiquidId := I;
    end;
  end;
  Result := Item;
end;

{ Положить предмет }
function PutItem(px, py: Byte; Item: TItem; Amount: Integer): boolean;
var
  x, y: Integer;
begin
  Result := TRUE;
  if Amount > 0 then
    Item.Amount := Amount;
  if not TilesData[M.Tile[px, py]].move then
    Result := false
  else if M.Item[px, py].Id > 0 then
  begin
    if SameItems(M.Item[px, py], Item) then
    begin
      inc(M.Item[px, py].Amount, Item.Amount);
      exit;
    end
    else
      Result := false;
  end
  else
    M.Item[px, py] := Item;
  // Если нельзя кинуть предмет на указанном месте, попробовать кинуть его в окрестностях
  if Result = false then
  begin
    for x := px - 1 to px + 1 do
    begin
      for y := py - 1 to py + 1 do
        if (x > 0) and (x <= MapX) and (y > 0) and (y <= MapY) then
          if NOT((x = px) and (y = py)) then
          begin
            if not TilesData[M.Tile[x, y]].move then
              Result := false
            else if M.Item[x, y].Id > 0 then
            begin
              if SameItems(M.Item[x, y], Item) then
              begin
                inc(M.Item[x, y].Amount, Item.Amount);
                Result := TRUE;
                break;
              end
              else
                Result := false;
            end
            else
            begin
              M.Item[x, y] := Item;
              Result := TRUE;
              break;
            end;
          end;
      if Result = TRUE then
        break;
    end;
  end;
end;

{ Вывести некоторые хар-ки предмета }
procedure WriteSomeAboutItem(Item: TItem; compare: boolean = false);
var
  s: string;
  cell: Byte;
  t: shortint;
begin
  if Item.Id > 0 then
    with GScreen.Canvas do
    begin
      DrawBorder(15, 31, 70, 4, crLIGHTGRAY);
      // Начать описание предмета
      s := '';
      case ItemsData[Item.Id].Vid of
        { Защита - если это броня (шлем, плащ, броня на тело, перчатки, обувь }
        1, 3, 4, 11, 12:
          begin
            t := ItemsData[Item.Id].Defense;
            s := s + 'Защита: ' + IntToStr(t) + ' ';
            if compare then
            begin
              s := s + '(';
              cell := Vid2Eq(ItemsData[Item.Id].Vid);
              if (pc.eq[cell].Id <> 0) then
                dec(t, ItemsData[pc.eq[cell].Id].Defense);
              if t > 0 then
                s := s + '+';
              s := s + IntToStr(t) + ') ';
            end;
          end;
        { Атака - выводить только если это - оружие (ближнего боя и стрела }
        6, 13:
          begin
            t := ItemsData[Item.Id].Attack;
            s := s + 'Атака: ' + IntToStr(t) + ' ';
            if compare then
            begin
              s := s + '(';
              cell := Vid2Eq(ItemsData[Item.Id].Vid);
              if (pc.eq[cell].Id <> 0) then
                dec(t, ItemsData[pc.eq[cell].Id].Attack);
              if t > 0 then
                s := s + '+';
              s := s + IntToStr(t) + ') ';
            end;
          end;
      end;
      // Масса предмета
      s := s + 'Масса: ' + FloatToStr(Item.Mass);
      // Вывести некоторые характеристики предмета
      Font.Color := cCYAN;
      // Атака для оружия, защита для брони или информация о еде и тд
      TextOut(17 * CharX, 32 * CharY, s);
      // Вывести символ предмета
      Font.Color := cLIGHTGRAY;
      TextOut(49 * CharX, 31 * CharY, '| |');
      Font.Color := RealColor(ItemColor(Item));
      TextOut(50 * CharX, 31 * CharY, ItemTypeData[ItemsData[Item.Id].Vid].Symbol);
      // Тип оружия, если это оружие
      Font.Color := cGREEN;
      if (ItemsData[Item.Id].Vid = 6) then
        TextOut((83 - Length(CLOSEWPNNAME[ItemsData[Item.Id].Kind])) * CharX, 32 * CharY, '"' + CLOSEWPNNAME[ItemsData[Item.Id].Kind] + '"');
      if (ItemsData[Item.Id].Vid = 7) or (ItemsData[Item.Id].Vid = 13) then
        TextOut((83 - Length(FARWPNNAME[ItemsData[Item.Id].Kind])) * CharX, 32 * CharY, '"' + FARWPNNAME[ItemsData[Item.Id].Kind] + '"');
      // Тип брони, если это броня или обувь
      if (ItemsData[Item.Id].Vid = 4) or (ItemsData[Item.Id].Vid = 12) then
        TextOut((83 - Length(ARMORTYPENAME[ItemsData[Item.Id].Kind])) * CharX, 32 * CharY, '"' + ARMORTYPENAME[ItemsData[Item.Id].Kind] + '"');
    end;
end;

{ Внимательно осмотреть предмет }
procedure ExamineItem(Item: TItem);
begin
  if ItemsData[Item.Id].Descr <> '' then
    AddMsg(ItemsData[Item.Id].Descr, 0)
  else
    AddMsg('Ты внимательно рассматриваешь ' + ItemName(Item, 1, TRUE) + ', но не видешь ничего особенного.', 0);
end;

{ Применить эффект предмета или убрать }
procedure ItemOnOff(Item: TItem; PutOn: boolean);
var
  n: shortint;
begin
  if PutOn then
    n := 1
  else
    n := -1;
  pc.Defense := pc.Defense + n * ItemsData[Item.Id].Defense;
end;

{ Вернуть полное название предмета SKL = 0 ЧТО? SKL = 1 КОГО? ЧЕГО? }
function ItemName(Item: TItem; skl: Byte; all: boolean): string;
var
  s: string;
begin
  case skl of
    0:
      if (Item.Amount = 1) or (not all) then
        s := ItemsData[Item.Id].Name1
      else
        s := ItemsData[Item.Id].Name2;
    1:
      if (Item.Amount = 1) or (not all) then
        s := ItemsData[Item.Id].Name3
      else
        s := ItemsData[Item.Id].Name2;
  end;
  // Напиток
  if Item.Id = idBOTTLE then
  begin
    // Название для идентифицированного напитка:
    s := s + ' ' + AllLiquid[Item.LiquidId].Name;
    // Название для не идентифицированного напитка:
    // s := s + ' с ' + LiquidState[NowLiquidState[Item.liquidid]] + ' ' + LiquidColor[NowLiquidColor[Item.liquidid]] + ' жидкостью';
  end;
  if Item.Owner > 0 then
  begin
    // Если обладатель - ГГ
    if Item.Owner = 1 then
    begin
    end
    else
    begin
      if (Item.Amount = 1) or (not all) then
        s := s + ' ' + MonstersData[Item.Owner].name5
      else
        s := s + ' ' + MonstersData[Item.Owner].name6;
    end;
  end;
  if (Item.Amount > 1) and (all) then
    s := s + ' (' + IntToStr(Item.Amount) + ' шт)';
  Result := s;
end;

{ Использовать предмет в инвентаре }
procedure UseItem(SelectedItem: Byte);
begin
  // Считать монетки (ворюши должны становиться агрессивными к тебе и орать "Отдай деньги!")
  if pc.Inv[SelectedItem].Id = idCOIN then
  begin
    if pc.Inv[SelectedItem].Amount = 1 then
      AddMsg('Что тут пересчитывать - у тебя ровно одна золотая монетка...', 0)
    else
      AddMsg('Ты пересчитал{/a} ' + ItemName(pc.Inv[SelectedItem], 0, TRUE) + '.', 0);
    ChangeGameState(gsPLAY);
  end
  else
    // Использовать предмет по назначению
    case ItemsData[pc.Inv[SelectedItem].Id].Vid of
      // Надеть
      1 .. 13:
        begin
          MenuSelected := Vid2Eq(ItemsData[pc.Inv[SelectedItem].Id].Vid);
          case pc.EquipItem(pc.Inv[SelectedItem], TRUE) of
            0:
              begin
                ItemOnOff(pc.Inv[SelectedItem], TRUE);
                if (pc.Inv[SelectedItem].Amount > 1) and (ItemsData[pc.Inv[SelectedItem].Id].Vid <> 13) then
                  dec(pc.Inv[SelectedItem].Amount)
                else
                  pc.Inv[SelectedItem].Id := 0;
                pc.RefreshInventory;
              end;
            1:
              begin
                ItemOnOff(pc.Inv[SelectedItem], TRUE);
                GameState := gsPLAY;
              end;
          end;
          ChangeGameState(gsEQUIPMENT);
        end;
      // Съесть
      14:
        begin
          if pc.status[stHUNGRY] >= 0 then
          begin
            pc.status[stHUNGRY] := pc.status[stHUNGRY] - Round(ItemsData[pc.Inv[SelectedItem].Id].Defense * pc.Inv[SelectedItem].Mass * 1.3 *
              (1 + (pc.Ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
            if pc.status[stHUNGRY] < -500 then
            begin
              AddMsg('#Ты не смог{/ла} доесть ' + ItemName(pc.Inv[SelectedItem], 1, false) +
                ' потому, что очень насытил{ся/ась}... чересчур насытил{ся/ась}...#', 0);
              pc.status[stHUNGRY] := -500;
            end
            else
              AddMsg('#Ты съел{/a} ' + ItemName(pc.Inv[SelectedItem], 1, false) + '.#', 0);
            pc.DeleteItemInv(SelectedItem, 1, 1);
            pc.turn := 1;
          end
          else
            AddMsg('Тебе не хочется больше есть!', 0);
          ChangeGameState(gsPLAY);
        end;
      // Выпить
      19:
        begin
          AddMsg('Ты выпил{/a} ' + ItemName(pc.Inv[SelectedItem], 1, false) + '.', 0);
          DrinkLiquid(pc.Inv[SelectedItem].LiquidId, pc);
          pc.DeleteItemInv(SelectedItem, 1, 1);
          pc.turn := 1;
          ChangeGameState(gsPLAY);
        end;
    end;
end;

{ Сравнить два предмета - одинаковы ли они? }
function SameItems(I1, I2: TItem): boolean;
begin
  Result := false;
  if (I1.Id = I2.Id) and (I1.Owner = I2.Owner) then
  begin
    // Если это бутылка то сравнить еще по содержимому
    if I1.Id = idBOTTLE then
    begin
      if (I1.LiquidId = I2.LiquidId) then
        Result := TRUE;
    end
    else
      Result := TRUE;
  end;
end;

{ Вернуть цвет предмета }
function ItemColor(I: TItem): Byte;
begin
  Result := 3;
  Result := ItemsData[I.Id].Color;
  // Если напиток
  if (I.Id = idBOTTLE) and (I.LiquidId > 0) then
    Result := NowLiquidColor[I.LiquidId];
end;

end.
