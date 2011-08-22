unit player;

interface

uses
  Main, Monsters, Cons, Tile, Utils, Msg, Flags, Items, SysUtils, Classes, Ability, Windows;

type
  Tpc = object (TMonster)
    turn        : byte;                          // Сделан ход? (0Нет,1Да,2Да+Перемещение)
    level       : byte;                          // Номер локации
    enter       : byte;                          // Номер входа в пещеру на локации
    depth       : byte;                          // Глубина в пещере
    cool        : byte;                          // Крутота пещеры 
    quest       : array[1..QuestsAmount] of byte;// Квесты: 0не взял квест,1взял,2выполнил,3рассказал заказчику,4выполнил
    color       : longword;                      // Цвет
    gender      : byte;                          // Пол
    //
    exp         : integer;                       // Кол-во опыта
    explevel    : byte;                          // Уровень развития
    //
    status      : array[1..2] of integer;        // Счетчики (1-Голод)

    procedure Prepare;                     // Подготовка в самом начале игры
    procedure Move(dx,dy : shortint);      // Двигать героя
    procedure FOV;                         // Поле видимости
    procedure AfterTurn;                   // Действия после хода героя
    procedure AnalysePlace(px,py: byte;    // Описать место
                        All : boolean);
    procedure PlaceHere(px,py : byte);     // Поставить героя в это место
    procedure UseStairs;                   // Спуститься или подняться по лестнице
    procedure PlaceAtTile(t : byte);       // Переместить героя на тайл
    procedure SearchForDoors;              // Сколько дверей рядом
    procedure SearchForAlive
                        (whattodo : byte); // Сколько монстров рядом (1-Атаковать, 2-Говорить, 3-Отдать)
    procedure CloseDoor(dx,dy : shortint); // Закрыть дверь
    procedure Open(dx,dy : shortint);      // Открыть 
    procedure MoveLook(dx,dy : shortint);  // Двигать курсор осмотра
    procedure WriteInfo;                   // Вывести информацию на экран справа
    procedure Talk(Mon : TMonster);      // Говорить
    procedure QuestList;                   // Список квестов
    procedure Equipment;                   // Экипировка
    procedure Inventory;                   // Инвентарь
    function ItemsAmount : byte;           // Колличество вещей
    procedure GainLevel;                   // Повышение уровня
    function ExpToNxtLvl : integer;        // Сколько нужно опыта для следующего уровня
    procedure UseMenu;                     // Меню действия с предметом
    function EquipItem(Item : TItem) : byte;// Снарядить предмет (0-успешно,1-ячейка занята)
    procedure AfterDeath;                  // Действия после смерти героя
    function FindCoins : byte;             // Найти ячейку с монетами
    procedure HeroName;                    // Окно ввода имени
    procedure HeroGender;                  // Окно выбора пола
    procedure Search(modif : byte);        // Искать
  end;

var
  pc      : Tpc;
  lx, ly  : byte;                          // Координаты курсора осмотра
  cell    : byte;
  crstep  : byte;


implementation

uses
  Map, Special;

{ Подготовка в самом начале игры }
procedure Tpc.Prepare;
begin
  id := 1;
  level := 1; // Эвилиар
  depth := 0; 
  los := 6;
  speed := 100;
  Rhp := 25;
  hp := Rhp;
  exp := 0;
  explevel := 1;
  Rst := 8;
  st := Rst;
  Rdex := 7;
  dex := Rdex;
  Rint := 5;
  int := Rint;
  status[1] := 0;
  status[2] := 0;
  attack := 4;  // Голыми руками

  PickUp(CreateItem(idCOIN, 50, 0), FALSE);
  EquipItem(CreateItem(idDAGGER, 1, 0));
  EquipItem(CreateItem(idJACKSONSHAT, 1, 0));
  EquipItem(CreateItem(idJACKET, 1, 0));
  EquipItem(CreateItem(idLAPTI, 1, 0));
  PickUp(CreateItem(idPOTIONCURE, 2, 0), FALSE);
  PickUp(CreateItem(idPOTIONHEAL, 1, 0), FALSE);
  PickUp(CreateItem(idMEAT, 1, 0), FALSE);
  PickUp(CreateItem(idLAVASH, 2, 0), FALSE);
end;

{ Двигать героя }
procedure Tpc.Move(dx,dy : shortint);
begin
  case pc.Replace(x+dx,y+dy) of
    0 : // Просто идем
    if (x = x+dx)and(y = y+dy) then
    begin
      M.MonP[x,y] := 1;
      turn := 1;
    end else
      // Покинуть Эвилиар
      if (pc.level = 1) and(pc.depth = 0) and (x+dx = 1) and (y+dy = 18) then
      begin
        if Ask('Хочешь покинуть Эвилиар и выйти из игры? [(Y/n)]') = 'Y' then
        begin
          AskForQuit := FALSE;
          MainForm.Close;
        end else
          AddMsg('Ты решил'+HeroHS(1)+' остаться.');
      end else
        // Просто передвинуться
        begin
          turn := 2;
          M.MonP[x,y] := 0;
          x := x + dx;
          y := y + dy;
          M.MonP[x,y] := 1;
        end;
    2 : // Дверь
    if M.Tile[x+dx,y+dy] = tdCDOOR then
    begin
      M.Tile[x+dx,y+dy] := tdODOOR;
      AddMsg('Ты открыл'+HeroHS(1)+' дверь.');
      pc.turn := 1;
    end;
    3 : // Кто-то живой
    begin
      if (M.MonL[M.MonP[x+dx,y+dy]].relation = 0) and (not M.MonL[M.MonP[x+dx,y+dy]].felldown) then
      begin
        // Просто поменяться местами
        AddMsg('Ты и '+MonstersData[M.MonL[M.MonP[x+dx,y+dy]].id].name1+' поменялись местами.');
        M.MonP[x,y] := M.MonP[x+dx,y+dy];
        M.MonL[M.MonP[x,y]].x := x;
        M.MonL[M.MonP[x,y]].y := y;
        x := x + dx;
        y := y + dy;
        M.MonP[x,y] := 1;
        pc.turn := 2;
      end else
        begin
          // Атаковать
          pc.Fight(M.MonL[M.MonP[x+dx,y+dy]], 0);
          pc.turn := 1;
        end;
    end;
  end;
end;

{ Поле видимости }
procedure TPc.Fov;
const
  quads : array[1..4] of array[1..2] of ShortInt = ((1,1),(-1,-1),(-1,+1),(+1,-1));
  RayNumber = 32;
  RayWidthCorrection = 10;
var
  a, b, tx, ty, mini, maxi, cor, u, v : integer;
  quad, slope : byte;
  reallos : byte;
  // Запомнить тайл
  procedure PictureIt(x,y : byte);
  begin
    if (x>0)and(x<=MapX)and(y>0)and(y<=MapY)then
    begin
      M.Saw[x,y] := 2;
      if M.MonP[x,y] > 0 then
        M.Mem[x,y] := MonstersData[M.MonL[M.MonP[x,y]].id].char else
          if M.Item[x,y].id > 0 then
            M.Mem[x,y] := ItemSymbol(M.Item[x,y].id) else
              M.Mem[x,y] := TilesData[M.Tile[x,y]].Char;
    end;
  end;
begin
  reallos := los + (Ability[abGOODEYES] * Round(AbilitysData[abGOODEYES].koef));
  for a:=x-reallos-2 to x+reallos+2 do
    for b:=y-reallos-2 to y+reallos+2 do
      if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
         if M.Saw[a,b] > 0 then
           M.Saw[a,b] := 1;
  M.Saw[pc.x,pc.y] := 2;
  tx := x; repeat Inc(tx); PictureIt(tx,y) until (TilesData[M.Tile[tx,y]].void = False)or(InFov(x,y,tx,y,reallos) = False);
  tx := x; repeat Dec(tx); PictureIt(tx,y) until (TilesData[M.Tile[tx,y]].void = False)or(InFov(x,y,tx,y,reallos) = False);
  ty := y; repeat Inc(ty); PictureIt(x,ty) until (TilesData[M.Tile[x,ty]].void = False)or(InFov(x,y,x,ty,reallos) = False);
  ty := y; repeat Dec(ty); PictureIt(x,ty) until (TilesData[M.Tile[x,ty]].void = False)or(InFov(x,y,x,ty,reallos) = False);
  for quad:= 1 to 4 do
    for slope:= 1 to RayNumber-1 do
    begin
      v := slope;
      u := 0;
      mini := RayWidthCorrection;
      maxi := RayNumber-RayWidthCorrection;
      repeat
        Inc(u);
        ty := v div RayNumber;
        tx := u - ty;
        cor := RayNumber-(v mod RayNumber);
        if mini < cor then
        begin
          PictureIt(quads[quad][1]*tx+x,quads[quad][2]*ty+y);
          if (TilesData[M.Tile[quads[quad][1]*tx+x,quads[quad][2]*ty+y]].void = False)or(InFov(x,y,quads[quad][1]*tx+x,quads[quad][2]*ty+y,reallos)=false)then
            mini := cor;
        end;
        if maxi > cor then
        begin
          PictureIt(x+quads[quad][1]*(tx-1),y+quads[quad][2]*(ty+1));
          if (TilesData[M.Tile[x+quads[quad][1]*(tx-1),y+quads[quad][2]*(ty+1)]].void = False)or(InFov(x,y,x+quads[quad][1]*(tx-1),y+quads[quad][2]*(ty+1),reallos)=false)then
            maxi := cor;
        end;
        v := v + slope;
      until
        mini > maxi;
    end;
end;

{ Действия после хода героя }
procedure TPc.AfterTurn;
begin
  if pc.turn > 0 then
  begin
    // Ход монстров
    MonstersTurn;
    // Снова открываем глаза:)
    Pc.Fov;
    // Если переместился на другую клетку - выводим описание, если надо
    if pc.turn = 2 then AnalysePlace(pc.x,pc.y,False);
    // Обнулить
    pc.turn := 0;
    // Голод растет
    inc(status[stHUNGRY]);
    // Пьяный
    if status[stDRUNK] > 0 then
      dec(status[stDRUNK]);
    if status[stHUNGRY] = 1500 then
    begin
      AddMsg('<Ты был слишком истощен'+HeroHS(1)+'...>');
      More;
      pc.hp := 0;
    end;
    // Регенерация (если не умирает с голода)
    if (pc.hp < pc.Rhp) and (pc.status[stHUNGRY] <= 1200) then
      if Random(Round(50 / (1 + (pc.ability[abQUICKREGENERATION] * AbilitysData[abQUICKREGENERATION].koef)))) + 1 = 1 then
        inc(pc.hp);
    if pc.Hp <= 0 then Death;
    // Осмотреться
    pc.Search(2);
  end;
  MainForm.OnPaint(NIL);
end;

{ Описать место }
procedure TPc.AnalysePlace(px,py : byte; All : boolean);
var
  s : string;
begin
  // Тайл
  if (All)or(TilesData[M.Tile[px,py]].important) or (M.Blood[px,py] > 0) then
    if M.Blood[px,py] > 0 then
      AddMsg(TilesData[M.Tile[px,py]].name+' в крови.') else
        AddMsg(TilesData[M.Tile[px,py]].name+'.');
  // Монстр
  if All then
    if M.MonP[px,py] > 0 then
    begin
      if M.MonP[px,py] = 1 then
        AddMsg('Это ты - '+pc.name+'. Ты ' + pc.WoundDescription + '.') else
          begin
            if M.MonL[M.MonP[px,py]].felldown then
              s := 'Здесь лежит '+MonstersData[M.MonL[M.MonP[px,py]].id].name1 else
                s := MonstersData[M.MonL[M.MonP[px,py]].id].name1;
            if IsFlag(MonstersData[M.MonL[M.MonP[px,py]].id].flags, M_NAME) then
              s := s + ' по имени ' + M.MonL[M.MonP[px,py]].name;
            s := s + '. Он' + HeSheIt(M.MonL[M.MonP[px,py]].id, 1) +' '+ M.MonL[M.MonP[px,py]].WoundDescription+'.';
            AddMsg(s);
          end;
     end;
  // Предмет
  if M.Item[px,py].id > 0 then
  begin
    if M.Item[px,py].amount = 1 then
      AddMsg('Здесь лежит '+ItemName(M.Item[px,py], 0, TRUE)+'.') else
        AddMsg('Здесь лежат '+ItemName(M.Item[px,py], 0, TRUE)+'.');
  end;
end;

{ Поставить героя в это место }
procedure TPc.PlaceHere(px,py : byte);
begin
  M.MonP[px,py] := 1;
  pc.x := px;
  pc.y := py;
end;

{ Спуститься или подняться по лестнице}
procedure TPc.UseStairs;
var
  wasenter : byte;
begin
  if (M.Tile[pc.x,pc.y] = tdDSTAIRS) or (M.Tile[pc.x,pc.y] = tdOHATCH) then
  begin
    M.MonP[pc.x,pc.y] := 0;
    if M.Save = False then AddMsg('Сохрание не удалось. Тем не менее, я позволю тебе играть дальше.');
    if pc.enter = 0 then
    begin
      pc.enter := GetEnterNumber;
      pc.cool := GetDungeonCool;
    end;
    inc(pc.depth);
    if M.Load(pc.level, pc.enter, pc.depth) = False then
    begin
      if (pc.enter = 1) then
      begin
        if pc.depth < 5 then
          M.GenerateCave(M.DungeonType, TRUE) else
            if pc.depth = 5 then
              LastLevelOfStoreHouse;
      end else
        if (pc.enter = 2) then
          Basement;
    end;
    PlaceAtTile(tdUSTAIRS);
    pc.turn := 2;
    AddMsg('Ты спустил'+HeroHS(2)+' вниз по лестнице на уровень '+IntToStr(pc.depth)+'.');
  end else
    if M.Tile[pc.x,pc.y] = tdUSTAIRS then
    begin
      M.MonP[pc.x,pc.y] := 0;
      if M.Save = False then AddMsg('Сохрание не удалось. Тем не менее, я позволю тебе играть дальше.');
      dec(pc.depth);
      wasenter := pc.enter;
      if pc.depth = 0 then pc.enter := 0;
      if M.Load(pc.level,pc.enter,pc.depth) = False then
      begin
        AddMsg('Не удалось загрузить карту. Возможно файл с сохранением был удален, либо его не удалось записать.');
        More;
        AddMsg('<Это критическая ошибка. Игра окончена.>');
        More;
        AskForQuit := FALSE;
        MainForm.Close;
      end;
      if pc.depth = 0 then PlaceOnStairs(pc.level, wasenter) else PlaceAtTile(tdDSTAIRS);
      pc.turn := 2;
      if pc.depth > 0 then
        AddMsg('Ты поднял'+HeroHS(2)+' по лестнице  на уровень '+IntToStr(pc.depth)+'.') else
          AddMsg('Ты поднял'+HeroHS(2)+' по лестнице и снова оказал'+HeroHS(2)+' на свежем воздухе.');
    end;
end;

{ Переместить героя на тайл }
procedure TPc.PlaceAtTile(t : byte);
var
  a, b : byte;
begin
  for a:=1 to MapX do
    for b:=1 to MapY do
      if M.Tile[a,b] = t then
      begin
        pc.x := a;
        pc.y := b;
        M.MonP[x,y] := 1;
        exit;
      end;
end;

{ Сколько дверей рядом }
procedure Tpc.SearchForDoors;
var
  a,b,i : shortint;
begin
  i := 0;
  for a := pc.x - 1 to pc.x + 1 do
    for b := pc.y - 1 to pc.y + 1 do
      if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
        if M.Tile[a,b] = tdODOOR then
          inc(i);
  case i of
    0 : AddMsg('Здесь нет открытой двери!');
    1 :
    begin
      for a := pc.x - 1 to pc.x + 1 do
        for b := pc.y - 1 to pc.y + 1 do
          if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
            if M.Tile[a,b] = tdODOOR then
            begin
              CloseDoor(a - pc.x, b - pc.y);
              exit;
            end;
    end;
    else
      begin
        AddMsg('Какую именно дверь ты хочешь закрыть?');
        GameState := gsCLOSE;
      end;
  end;
end;

{ Сколько монстров рядом }
procedure Tpc.SearchForAlive(whattodo : byte);
var
  a,b,i : shortint;
begin
  i := 0;
  for a := pc.x - 1 to pc.x + 1 do
    for b := pc.y - 1 to pc.y + 1 do
      if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
        if M.MonP[a,b] > 1 then
          inc(i);
  case i of
    0 :
    case whattodo of
      1 : AddMsg('Рядом с тобой никого нет!');  // Атаковать
      2 : AddMsg('Здесь не с кем поговорить!'); // Говорить
      3 : AddMsg('Рядом с тобой никого нет!');  // Отдать
    end;
    1 :
    begin
      for a := pc.x - 1 to pc.x + 1 do
        for b := pc.y - 1 to pc.y + 1 do
          if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
            if M.MonP[a,b] > 1 then
            begin
              case whattodo of
                1 : Fight(M.MonL[M.MonP[a,b]], 0); // Атаковать
                2 : Talk(M.MonL[M.MonP[a,b]]);     // Говорить
                3 : if waseq then GiveItem(M.MonL[M.MonP[a,b]], pc.Eq[MenuSelected]) else
                                        GiveItem(M.MonL[M.MonP[a,b]], pc.Inv[MenuSelected]);   // Отдать
              end;
              Exit;
            end;
    end;
    else
      begin
        case whattodo of
          1 : AddMsg('На кого именно ты хочешь напасть?');
          2 : AddMsg('С кем именно ты хочешь поговорить?');
          3 : AddMsg('Кому именно отдать?');
        end;
        GameState := gsCHOOSEMONSTER;
        wtd := whattodo;
      end;
  end;
end;

{ Закрыть дверь }
procedure TPc.CloseDoor(dx,dy : shortint);
var
  a,b : integer;
begin
  a := pc.x + dx;
  b := pc.y + dy;
  if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
  begin
    if M.Tile[a,b] = tdODOOR then
    begin
      if M.MonP[a,b] = 0 then
      begin
        AddMsg('Ты закрыл'+HeroHS(1)+' дверь.');
        M.Tile[a,b] := tdCDOOR;
        pc.turn := 1;
      end else
        AddMsg('Здесь стоит '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! Ты не можешь закрыть дверь!');
    end else
      AddMsg('Здесь нет открытой двери!');
  end;
end;

{ Открыть }
procedure TPc.Open(dx,dy : shortint);
var
  a,b : integer;
begin
  a := pc.x + dx;
  b := pc.y + dy;
  if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
  begin
    if M.Tile[a,b] = tdCDOOR then
    begin
      if M.MonP[a,b] = 0 then
      begin
        AddMsg('Ты открыл'+HeroHS(1)+' дверь.');
        M.Tile[a,b] := tdODOOR;
        pc.turn := 1;
      end else
        AddMsg('Здесь стоит '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! Ты не можешь открыть дверь! Хотя как он тут может стоять?');
    end else
      if M.Tile[a,b] = tdCHATCH then
      begin
        if M.MonP[a,b] = 0 then
        begin
          AddMsg('Ты с трудом открыл'+HeroHS(1)+' люк.');
          M.Tile[a,b] := tdOHATCH;
          pc.turn := 1;
        end else
          AddMsg('Здесь стоит '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! Ты не можешь открыть люк!');
      end else
        AddMsg('Что здесь можно открыть?');
  end;
end;

{ Двигать курсор осмотра }
procedure TPc.MoveLook(dx,dy : shortint);
var
  a,b : integer;
begin
  a := lx + dx;
  b := ly + dy;
  if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
    if M.Saw[a,b] = 2 then
      begin
        lx := a;
        ly := b;
        AnalysePlace(lx,ly,True);
      end;
end;

{ Вывести информацию на экран справа }
procedure Tpc.WriteInfo;
begin
  with Screen.Canvas do
  begin
    Font.Color := cLIGHTGRAY;
    // Имя
    TextOut((((20-length(name)) div 2)+80) * CharX, 2*CharY, name);
    Font.Color := cBROWN;
    TextOut(81*CharX, 4*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 6*CharY, 'ЗДОРОВЬЕ :');
    Font.Color := ReturnColor(Rhp, hp, 1);
    TextOut(92*CharX, 6*CharY, IntToStr(hp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, 6*CharY, '('+IntToStr(Rhp)+')');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 7*CharY, 'МАНА     :');
    Font.Color := ReturnColor(Rmp, mp, 2);
    TextOut(92*CharX, 7*CharY, IntToStr(mp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, 7*CharY, '('+IntToStr(Rmp)+')');
    Font.Color := cLIGHTGRAY;
    Font.Color := cBROWN;
    TextOut(81*CharX, 9*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 11*CharY, 'СИЛА     :');
    if st > Rst then
      Font.Color := cLIGHTGREEN else
        if st < Rst then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, 11*CharY, IntToStr(st));
    TextOut(82*CharX, 12*CharY, 'ЛОВКОСТЬ :');
    if dex > Rdex then
      Font.Color := cLIGHTGREEN else
        if dex < Rdex then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, 12*CharY, IntToStr(dex));
    TextOut(82*CharX, 13*CharY, 'ИНТЕЛЛЕКТ:');
    if int > Rint then
      Font.Color := cLIGHTGREEN else
        if int < Rint then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, 13*CharY, IntToStr(int));
    Font.Color := cBROWN;
    TextOut(81*CharX, 15*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 17*CharY, 'УРОВЕНЬ  :'+IntToStr(explevel));
    TextOut(82*CharX, 18*CharY, 'ОПЫТ     :'+IntToStr(exp));
    TextOut(82*CharX, 19*CharY, 'НУЖНО    :'+IntToStr(ExpToNxtLvl));
    Font.Color := cBROWN;
    TextOut(81*CharX, 21*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    if (pc.enter = 2) and (pc.depth = 1) then
      TextOut(82*CharX, 23*CharY, 'Подвал') else
        if pc.depth > 0 then
          TextOut(82*CharX, 23*CharY, 'ГЛУБИНА  : '+IntToStr(pc.depth)) else
            case pc.level of
              1   : TextOut(82*CharX, 23*CharY, 'Деревня Эвилиар');
              255 : TextOut(82*CharX, 23*CharY, 'Ад!');
            end;
    Font.Color := cBROWN;
    TextOut(81*CharX, 25*CharY, '-------------------');
    case pc.status[stHUNGRY] of
      -500..-400:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, 27*CharY, 'Тошнит...');
      end;
      -399..-1  :
      begin
        Font.Color := cGREEN;
        TextOut(82*CharX, 27*CharY, 'Переел'+HeroHS(1)+'...');
      end;
      0..450    :
      begin
        Font.Color := cGRAY;
        TextOut(82*CharX, 27*CharY, 'Сыт'+HeroHS(4));
      end;
      451..750  :
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, 27*CharY, 'Проголодал'+HeroHS(2));
      end;
      751..1200  :
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, 27*CharY, 'Голод'+HeroHS(5)+'!');
      end;
      1201..1500 :
      begin
        Font.Color := cRED;
        TextOut(82*CharX, 27*CharY, 'Умираешь от голода!');
      end;
    end;
    case pc.status[stDRUNK] of
      350..500:
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, 28*CharY, 'Пьян'+HeroHS(4));
      end;
      501..800:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, 28*CharY, 'Пьян'+HeroHS(4)+'! Ик!');
      end;
    end;
  end;
end;

{ Говорить }
procedure Tpc.Talk(Mon : TMonster);
begin
  if Mon.id > 1 then
  begin
    Mon.TalkToMe;
    pc.turn := 1;
  end else
    AddMsg('Здесь не с кем поговорить!');
end;

{ Список квестов }
procedure Tpc.QuestList;
begin
  StartDecorating('<-СПИСОК ТЕКУЩИХ КВЕСТОВ->', FALSE);
  with Screen.Canvas do
  begin
    if (pc.quest[1] = 0) or (pc.quest[1] = 3) then
    begin
      Font.Color := cLIGHTGRAY;
      TextOut(5*CharX,5*CharY,'Пока что ты не взял'+HeroHS(1)+' ни одного квеста.');
    end;
    if (pc.quest[1] = 1)or(pc.quest[1] = 2) then
    begin
     Font.Color := cLIGHTGREEN;
     TextOut(4*CharX,5*CharY,'Старейшина поселка Эвилиар попросил исследовать хранилище и освободить людей от зла,');
     TextOut(4*CharX,6*CharY,'таящегося в нем');
     case pc.quest[1] of
       1 :
       begin
         Font.Color := cRED;
         TextOut(2*CharX,5*CharY,'-');
       end;
       2 :
       begin
         Font.Color := cGREEN;
         TextOut(2*CharX,5*CharY,'+');
       end;
     end;
    end;
  end;
end;

{ Экипировка }
procedure Tpc.Equipment;
const
  s1 = '< Нажми ''i'' чтобы увидеть все вещи, которые ты несешь >';
  s2 = '< Твой инвентарь пуст! >';
var
  i : byte;
begin
  StartDecorating('<-ЭКИПИРОВКА->', FALSE);
  with Screen.Canvas do
  begin
    Font.Color := cBROWN;
    TextOut(5*CharX, 11*CharY, '[ ] - Голова            :');
    TextOut(5*CharX, 12*CharY, '[ ] - Шея               :');
    TextOut(5*CharX, 13*CharY, '[ ] - Плащ              :');
    TextOut(5*CharX, 14*CharY, '[ ] - Тело              :');
    TextOut(5*CharX, 15*CharY, '[ ] - Пояс              :');
    TextOut(5*CharX, 16*CharY, '[ ] - Оружие            :');
    TextOut(5*CharX, 17*CharY, '[ ] - Щит               :');
    TextOut(5*CharX, 18*CharY, '[ ] - Запястье          :');
    TextOut(5*CharX, 19*CharY, '[ ] - Кольцо            :');
    TextOut(5*CharX, 20*CharY, '[ ] - Перчатки          :');
    TextOut(5*CharX, 21*CharY, '[ ] - Обувь             :');
    TextOut(5*CharX, 22*CharY, '[ ] - Аммуниция         :');
    for i:=1 to EqAmount do
      if pc.eq[i].id = 0 then
      begin
        Font.Color := cWHITE;
        TextOut(31*CharX,(10+i)*CharY,'-');
      end else
        begin
          Font.Color := cLIGHTGRAY;
          TextOut(31 * CharX, (10+i)*CharY, ItemName(pc.eq[i], 0, TRUE));
        end;
    Font.Color := cGRAY;
    if ItemsAmount > 0 then
      TextOut(((WindowX-length(s1)) div 2) * CharX, 39*CharY, s1) else
        TextOut(((WindowX-length(s2)) div 2) * CharX, 39*CharY, s2);
    Font.Color := cRED;
    TextOut(6*CharX, (10+MenuSelected)*CharY,'*');
  end;
  WriteSomeAboutItem(pc.Eq[MenuSelected]);
end;

{ Инвентарь }
procedure Tpc.Inventory;
const
  s1 = '< Нажми ENTER для того, что бы использовать предмет >';
  s2 = '< Нажми ''i'' чтобы перейти в экран экипировки  >';
var
  i : byte;
begin
  StartDecorating('<-ИНВЕНТАРЬ->', FALSE);
  with Screen.Canvas do
  begin
    Font.Color := cGRAY;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 37*CharY, s1);
    TextOut(((WindowX-length(s2)) div 2) * CharX, 39*CharY, s2);
    for i:=1 to ItemsAmount do
    begin
      Font.Color := cBROWN;
      TextOut(5 * CharX, (2+i)*CharY, '[ ]');
      Font.Color := cLIGHTGRAY;
      TextOut(9 * CharX, (2+i)*CharY, ItemName(pc.inv[i], 0, TRUE));
      Font.Color := cRED;
      TextOut(6*CharX, (2+MenuSelected)*CharY,'*');
    end;
    WriteSomeAboutItem(pc.Inv[MenuSelected]);
  end;
end;

{ Колличество вещей }
function Tpc.ItemsAmount : byte;
var
  i,k : byte;
begin
  k := 0;
  for i:=1 to MaxHandle do
    if Inv[i].id > 0 then inc(k);
  Result := k;
end;

{ Повышение уровня }
procedure Tpc.GainLevel;
var
  a : string;
  i,b : byte;
begin
  AddMsg('{Поздравляю! Ты достиг'+HeroHS(3)+' нового уровня развития!}');
  Apply;
  // Повысить уровень, обнулить счетчик опыта
  inc(pc.explevel);
  pc.exp  := 0;
  // Дать новую способность
  b := 0;
  for i:=1 to AbilitysAmount do
    if pc.ability[i] < 4 then
      b := 1;
  // Если еще остались способности, которые можно прокачать
  if b > 0 then
  begin
    repeat
      i := Random(AbilitysAmount)+1;
    until
      pc.ability[i] < 4;
    inc(pc.ability[i]);
    if pc.ability[i] = 1 then
      AddMsg('Ты открыл'+HeroHS(1)+' в себе новую способность - "{'+AbilitysData[i].name+'}"!') else
        AddMsg('Твоя способность "{'+AbilitysData[i].name+'}" стала на уровень лучше!');
    Apply;
  end;
  // Каждый третий уровень можно выбрать пракачку СЛИ
  if pc.explevel mod 3 = 0 then
  begin
    AddMsg('{Ты можешь повысить один из своих атрибутов!}');
    a := Ask('Выбери какой: ([S]) Сила, ([D]) Ловкость или ([I]) Интеллект?');
    case a[1] of
      'S' :
      begin
        inc(pc.Rst);
        pc.st := pc.Rst;
        AddMsg('[Ты стал более сильным.]');
        Apply;
      end;
      'D' :
      begin
        inc(pc.Rdex);
        pc.dex := pc.Rdex;
        AddMsg('[Ты стал более ловким.]');
        Apply;
      end;
      'I' :
      begin
        inc(pc.Rint);
        pc.int := pc.Rint;
        AddMsg('[Ты чувствуешь себя умнее.]');
        Apply;
      end;
      ELSE
        // Рандомный выбор
        case Random(3)+1 of
          1 :
          begin
            inc(pc.Rst);
            pc.st := pc.Rst;
            AddMsg('[Ты стал более сильным.]');
            Apply;
          end;
          2 :
          begin
            inc(pc.Rdex);
            pc.dex := pc.Rdex;
            AddMsg('[Ты стал более ловким.]');
            Apply;
          end;
          3 :
          begin
            inc(pc.Rint);
            pc.int := pc.Rint;
            AddMsg('[Ты чувствуешь себя умнее.]');
            Apply;
          end;
        end;
    end;
  end;
  AddMsg('');
  pc.Rhp := pc.Rhp + round(pc.Rhp/4);
end;

{ Сколько нужно опыта для следующего уровня }
function Tpc.ExpToNxtLvl : integer;
begin
  Result := Round((explevel * 20) - (int/1.5));
end;

{ Меню действия с предметом }
procedure Tpc.UseMenu;
begin
  with Screen.Canvas do
  begin
    DrawBorder(75,2,20,HOWMANYVARIANTS+1);
    Font.Color := cBROWN;
    TextOut(77*CharX, 3*CharY, '[ ]');
    Font.Color := cWHITE;
    if WasEq then
      // В экипировке
      TextOut(81*CharX, 3*CharY, 'В инвентарь') else
        // В инвентаре
        TextOut(81*CharX, 3*CharY, WhatToDo(pc.Inv[MenuSelected].id));
    Font.Color := cBROWN;
    TextOut(77*CharX, 4*CharY, '[ ]');
    Font.Color := cWHITE;
    TextOut(81*CharX, 4*CharY, 'Рассмотреть');
    Font.Color := cBROWN;
    TextOut(77*CharX, 5*CharY, '[ ]');
    Font.Color := cWHITE;
    TextOut(81*CharX, 5*CharY, 'Бросить');
    Font.Color := cBROWN;
    TextOut(77*CharX, 6*CharY, '[ ]');
    Font.Color := cWHITE;
    TextOut(81*CharX, 6*CharY, 'Отдать');
    Font.Color := cBROWN;
    TextOut(77*CharX, 7*CharY, '[ ]');
    Font.Color := cRED;
    TextOut(81*CharX, 7*CharY, 'Выкинуть');
    Font.Color := cYELLOW;
    TextOut(78*CharX, (2+MenuSelected2)*CharY, '*');
  end;
end;

{ Снарядить предмет }
function Tpc.EquipItem(Item : TItem) : byte;
var
  TempItem : TItem;
begin
  Result := 0;
  case ItemsData[Item.id].vid of
    1 : cell := 1; // Шлем
    2 : cell := 2; // Амулет
    3 : cell := 3; // Плащ
    4 : cell := 4; // Броня на тело
    5 : cell := 5; // Ремень
    6 : cell := 6; // Оружие ближнего боя
    7 : cell := 6; // Оружие дальнего боя
    8 : cell := 7; // Щит
    9 : cell := 8; // Браслет
    10: cell := 9; // Кольцо
    11: cell := 10; // Перчатки
    12: cell := 11; // Обувь
    13: cell := 12; // Аммуниция
  end;
  // Ячейка занята
  if pc.eq[cell].id > 0 then
  begin
    TempItem := pc.eq[cell];
    ItemOnOff(pc.eq[cell], FALSE);
    pc.eq[cell] := Item;
    pc.DeleteInvItem(pc.inv[MenuSelected], FALSE);
    case PickUp(TempItem, TRUE) of
      0 :
      begin
        AddMsg('Теперь ты используешь '+ItemName(pc.eq[cell], 1, FALSE)+', а '+ItemName(TempItem, 1, TRUE)+' ты убрал'+HeroHS(1)+' в инвентарь.');
      end;
      2 : // Нет места
        AddMsg('К сожалению, в инвентаре не достаточно места для такой операции.');
    end;
    Result := 1;
  end else
      pc.eq[cell] := Item;
  if cell <> 12 then
    if pc.eq[cell].amount > 1 then pc.eq[cell].amount := 1;
end;

{ Действия после смерти героя }
procedure TPc.AfterDeath;
begin
  AddMsg('<Ты умер'+HeroHS(3)+'!!!>');
  Apply;
  AskForQuit := FALSE;
  MainForm.Close;
end;

{ Найти ячейку с монетами }
function TPc.FindCoins : byte;
var
  i : byte;
begin
  Result := 0;
  for i:=1 to MaxHandle do
    if pc.Inv[i].id = idCOIN then
      begin
        Result := i;
        break;
      end;
end;

{ Окно ввода имени }
procedure TPc.HeroName;
const
  s1 = 'Введи имя героя';
  s2 = '^^^^^^^^^^^^^';
  s3 = 'Выбери пол героя';
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s2)) div 2) * CharX, 18*CharY, s2);
    MainForm.Edit.Left := (((WindowX*CharX)-MainForm.Edit.Width-8) div 2);
    MainForm.Edit.Top := 17*CharY;
    MainForm.Edit.Visible := TRUE;
    MainForm.Edit.SetFocus;
  end;
end;

{ Окно выбора пола }
procedure TPc.HeroGender;
const
  s1 = 'Выбери пол героя';
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, 'Мужской');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, 'Женский');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '*');
  end;
end;

{ Искать }
procedure Tpc.Search(modif : byte);
var
  a, b : integer;
begin
  for a:=pc.x-1 to pc.x+1 do
    for b:=pc.y-1 to pc.y+1 do
      if (a > 0) and (a <= MapX) and (b > 0) and (b <= MapY) then
        if M.tile[a,b] = tdSECRET then
          if Random(3 * Modif)+1 = 1 then
          begin
            M.tile[a,b] := tdCDOOR;
            AddMsg('{Ты наш'+HeroHS(6)+' секретную дверь!}');
            More;
          end;
end;

end.

