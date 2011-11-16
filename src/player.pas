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
    quest       : array[1..QuestsAmount] of byte;// Квесты: 0не взял квест,1взял,2выполнил,3рассказал заказчику,4выполнил
    color       : longword;                      // Цвет
    gender      : byte;                          // Пол
    //
    exp         : integer;                       // Кол-во опыта
    explevel    : byte;                          // Уровень развития
    //
    warning     : boolean;                       // Монстр в поле зрения

    procedure ClearPlayer;                       // Очистить
    procedure Prepare;                           // Подготовка в самом начале игры
    procedure Move(dx,dy : shortint);            // Двигать героя
    procedure Run(dx,dy : shortint);             // Shift + Двигать героя
    procedure FOV;                               // Поле видимости
    procedure AfterTurn;                         // Действия после хода героя
    procedure AnalysePlace(px,py: byte;          // Описать место
                        All : byte);
    procedure PlaceHere(px,py : byte);           // Поставить героя в это место
    procedure UseStairs;                         // Спуститься или подняться по лестнице
    procedure PlaceAtTile(t : byte);             // Переместить героя на тайл
    procedure SearchForDoors;                    // Сколько дверей рядом
    procedure SearchForAlive
                        (whattodo : byte);       // Сколько монстров рядом (1-Атаковать, 2-Говорить, 3-Отдать)
    function SearchForAliveField : byte;         // Найти самого ближайщего монстра
    procedure CloseDoor(dx,dy : shortint);       // Закрыть дверь
    procedure Open(dx,dy : shortint);            // Открыть
    procedure MoveLook(dx,dy : shortint);        // Двигать курсор осмотра
    procedure MoveAim(dx,dy : shortint);         // Двигать курсор прицела
    procedure WriteInfo;                         // Вывести информацию на экран справа
    procedure Talk(Mon : TMonster);              // Говорить
    procedure QuestList;                         // Список квестов
    procedure Equipment;                         // Экипировка
    procedure Inventory;                         // Инвентарь
    function ItemsAmount : byte;                 // Колличество вещей
    procedure GainLevel;                         // Повышение уровня
    function ExpToNxtLvl : integer;              // Сколько нужно опыта для следующего уровня
    procedure UseMenu;                           // Меню действия с предметом
    procedure AfterDeath;                        // Действия после смерти героя
    function FindCoins : byte;                   // Найти ячейку с монетами
    procedure Search;                            // Искать
    function HaveItemVid(vid : byte) : boolean;  // Есть ли хоть один предмет этого вида?
    procedure HeroRandom;                        // Сделать рандомного
    procedure StartHeroName;                     // Окно ввода имени
    procedure HeroName;                          // Окно ввода имени
    procedure HeroGender;                        // Окно выбора пола
    procedure HeroAtributes;                     // Расстановка приоритетов
    procedure CreateClWList;
    procedure HeroCloseWeapon;                   // Оружие ближнего боя
    procedure CreateFrWList;
    procedure HeroFarWeapon;                     // Оружие дальнего боя
    procedure HeroCreateResult;                  // Подтвердить
    procedure ChooseMode;                    // Выбрать режим игры
  end;

var
  pc      : Tpc;
  lx, ly  : byte;                                // Координаты курсора осмотра
  autoaim : byte;                                // ID монстра на автоприцеле
  cell    : byte;
  crstep  : byte;
  InvList : array[1..MaxHandle] of byte;
  c_choose, f_choose : byte;                     // Выбранный тип оружия
  wlist   : array[1..5] of byte;
  wlistsize : byte;


implementation

uses
  Map, MapEditor, conf, sutils, vars, script;

{ Очистить }
procedure Tpc.ClearPlayer;
begin
  ClearMonster;
  id := 1;
  idinlist := 1;
  turn := 0;
  level := 0;
  enter := 0;
  depth := 0;
  fillchar(quest,sizeof(quest),0);
  color := 0;
  gender := 0;
  exp := 0;
  explevel := 1;
  fillchar(status,sizeof(status),0);
  warning := FALSE
end;

{ Подготовка в самом начале игры }
procedure Tpc.Prepare;
begin
  // Изменить атрибуты исходя из приоритетов
  Rstr := 5; Rdex := 5; Rint := 5;
  // Первичный
  if pc.atr[1] = 1 then
    inc(Rstr, 6);
  if pc.atr[1] = 2 then
    inc(Rdex, 6);
  if pc.atr[1] = 3 then
    inc(Rint, 6);
  // Вторичный
  if pc.atr[2] = 1 then
    inc(Rstr, 3);
  if pc.atr[2] = 2 then
    inc(Rdex, 3);
  if pc.atr[2] = 3 then
    inc(Rint, 3);
  str := Rstr; dex := Rdex; int := Rint;
  // Здоровье
  Rhp := 20 + Round(str / 2);
  hp := Rhp;
  // Скорость
  speed := 96 + Round(dex / 2);
  // Дальность зрения
  los := 5 + Round(int / 5);
  // Атака голыми руками
  attack := Round(str / 2);
  defense := Round(str / 4) + Round(dex / 4);
  // Обнулить статусы
  status[1] := 0;
  status[2] := 0;
end;

{ Двигать героя }
procedure Tpc.Move(dx,dy : shortint);
begin
  case pc.Replace(x+dx,y+dy) of
    0 :
    // Переместиться на другую локацию
    if (x+dx = 1) or (x+dx = MapX) or (y+dy = 1) or (y+dy = MapY) then
    begin
      // На запад
      if x + dx = 1 then
      begin
        if SpecialMaps[pc.level].Loc[3] = 0 then
        begin
          if Ask(GetMsg('Хочешь сбежать как трус{/ишка}?!',0) + ' #(Y/n)#') = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('Ты решил{/a} остаться.',0);
        end else
          begin
            // Убрать указатель на героя
            M.MonP[pc.x,pc.y] := 0;
            // Сохранить уровень
            if M.Save = False then AddMsg('Сохрание не удалось *:(*',0);
            // Меняем  номер локации
            pc.level := SpecialMaps[pc.level].Loc[3];
            // Если загрузить не удастся - ничего страшного ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then M.MakeSpMap(pc.level);
            pc.x := MapX - 1;
            M.MonP[pc.x,pc.y] := 1;
            pc.turn := 2;
          end
      end else
      // На восток
      if x + dx = MapX then
      begin
        if (SpecialMaps[pc.level].Loc[4] = 0) and (pc.level = 1) then
        begin
          if Ask(GetMsg('Поздравляю! Ты выполнил{/a} задачу данной версии игры! Хочешь теперь уйти? #(Y/n)#',0)) = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('Ты решил{/a} остаться.',0);
        end else
          begin
            // Убрать указатель на героя
            M.MonP[pc.x,pc.y] := 0;
            // Сохранить уровень
            if M.Save = False then AddMsg('Сохрание не удалось *:(*',0);
            // Меняем  номер локации
            pc.level := SpecialMaps[pc.level].Loc[4];
            // Если загрузить не удастся - ничего страшного ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then M.MakeSpMap(pc.level);
            pc.x := 2;
            M.MonP[pc.x,pc.y] := 1;
            pc.turn := 2;
          end;
      end else
      // На север
      if y + dy = 1 then
      begin
        if SpecialMaps[pc.level].Loc[1] = 0 then
        begin
          if Ask(GetMsg('Хочешь сбежать как трус{/ишка}?! #(Y/n)#',0)) = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('Ты решил{/a} остаться.',0);
        end else
          begin
            // Убрать указатель на героя
            M.MonP[pc.x,pc.y] := 0;
            // Сохранить уровень
            if M.Save = False then AddMsg('Сохрание не удалось *:(*',0);
            // Меняем  номер локации
            pc.level := SpecialMaps[pc.level].Loc[1];
            // Если загрузить не удастся - ничего страшного ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then M.MakeSpMap(pc.level);
            pc.y := MapY - 1;
            M.MonP[pc.x,pc.y] := 1;
            pc.turn := 2;
          end;
      end else
      // На юг
      if y + dy = MapY then
      begin
        if SpecialMaps[pc.level].Loc[2] = 0 then
        begin
          if Ask(GetMsg('Хочешь сбежать как трус{/ишка}?! #(Y/n)#',0)) = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('Ты решил{/a} остаться.',0);
        end else
          begin
            // Убрать указатель на героя
            M.MonP[pc.x,pc.y] := 0;
            // Сохранить уровень
            if M.Save = False then AddMsg('Сохрание не удалось *:(*',0);
            // Меняем  номер локации
            pc.level := SpecialMaps[pc.level].Loc[2];
            // Если загрузить не удастся - ничего страшного ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then M.MakeSpMap(pc.level);
            pc.y := 2;
            M.MonP[pc.x,pc.y] := 1;
            pc.turn := 2;
          end;
      end;
    end else
      // Стоим на месте
      if (x = x+dx)and(y = y+dy) then
      begin
        M.MonP[x,y] := 1;
        turn := 1;
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
      AddMsg('Ты открыл{/a} дверь.',0);
      pc.turn := 1;
    end;
    3 : // Кто-то живой
    begin
      if (M.MonL[M.MonP[x+dx,y+dy]].relation = 0) and (not M.MonL[M.MonP[x+dx,y+dy]].felldown) then
      begin
        // Просто поменяться местами
        AddMsg(Format('Ты и %s поменялись местами.', [MonstersData[M.MonL[M.MonP[x+dx,y+dy]].id].name1]),0);
        M.MonP[x,y] := M.MonP[x+dx,y+dy];
        M.MonL[M.MonP[x,y]].x := x;
        M.MonL[M.MonP[x,y]].y := y;
        x := x + dx;
        y := y + dy;
        M.MonP[x,y] := 1;
        pc.turn := 2;
      end else
        // Нейтральный и лежит
        if (M.MonL[M.MonP[x+dx,y+dy]].relation = 0) and (M.MonL[M.MonP[x+dx,y+dy]].felldown) then
        begin
          // Не смог поменяться местами
          AddMsg(Format('Ты и %s не смогли поменяться местами!', [MonstersData[M.MonL[M.MonP[x+dx,y+dy]].id].name1]),0);
          pc.turn := 1;
        end else
          begin
            // Атаковать
            pc.Fight(M.MonL[M.MonP[x+dx,y+dy]], 0);
            pc.turn := 1;
          end;
    end;
  end;
end;

{ Shift + Двигать героя }
procedure Tpc.Run(dx,dy : shortint);
var
  a,b,count : byte;
  around    : array[1..3,1..3] of byte;
  stop      : boolean;
begin
  Move(dx,dy);
(*  // Окружение
  for a:=1 to 3 do
    for b:=1 to 3 do
      around[a,b] := M.Tile[pc.x-2+a,pc.y-2+b];
  stop := FALSE;
  count := 0;
  repeat
    // Сделать шаг
    Move(dx,dy);
    pc.AfterTurn;
    sleep(40);
    // 1) Увидел монстра,
    if pc.warning then stop := TRUE;
    // 2) Другое окружение тайлов,
    for a:=1 to 3 do
      for b:=1 to 3 do
        if M.Tile[pc.x-2+a,pc.y-2+b] <> around[a,b] then
          stop := TRUE;
    // 3) Сделать максимальное кол-во шагов
    inc(count);
    if count = 20 then stop := TRUE;
    // 4) Наступил на предмет
    if M.Item[pc.x,pc.y].id > 0 then stop := TRUE;
  until
    stop;*)
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
        if M.MonL[M.MonP[x,y]].relation = 1 then
          pc.warning := TRUE;
      M.MemBC[x,y] := TilesData[M.Tile[x,y]].Color;
      if M.MonP[x,y] > 0 then
      begin
        M.MemS[x,y] := MonstersData[M.MonL[M.MonP[x,y]].id].char;
        M.MemC[x,y] := M.MonL[M.MonP[x,y]].ClassColor;
      end else
        if M.Item[x,y].id > 0 then
        begin
          M.MemS[x,y] := ItemTypeData[ItemsData[M.Item[x,y].id].vid].symbol;;
          M.MemC[x,y] := ItemsData[M.Item[x,y].id].color;
        end else
          begin
            M.MemS[x,y] := TilesData[M.Tile[x,y]].Char;
            M.MemC[x,y] := TilesData[M.Tile[x,y]].Color;
          end;
    end;
  end;
begin
  pc.warning := FALSE;
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
    // Если еще не умер
    if id > 0 then
    begin
      // Если переместился на другую клетку - выводим описание, если надо
      if pc.turn = 2 then AnalysePlace(pc.x,pc.y,0);
      // Обнулить
      pc.turn := 0;
      // Голод растет
      inc(status[stHUNGRY]);
      // Пьяный
      if status[stDRUNK] > 0 then
        dec(status[stDRUNK]);
      if status[stHUNGRY] = 1500 then
      begin
        AddMsg('*Ты был{/a} слишком истощен{/a}...*',0);
        More;
        pc.hp := 0;
      end;
      // Регенерация (если не умирает с голода)
      if (pc.hp < pc.Rhp) and (pc.status[stHUNGRY] <= 1200) then
        if Random(Round(40 / (1 + (pc.ability[abQUICKREGENERATION] * AbilitysData[abQUICKREGENERATION].koef)))) + 1 = 1 then
          inc(pc.hp);
      if pc.Hp <= 0 then Death;
      // Осмотреться
      pc.Search;
    end;
  end;
  MainForm.OnPaint(NIL);
end;

{ Описать место }
procedure TPc.AnalysePlace(px,py : byte; All : byte);
var
  s : string;
begin
  // Тайл
  if (All=2)or(TilesData[M.Tile[px,py]].important) or ((M.Blood[px,py] > 0) and (All <> 1)) then
    if M.Blood[px,py] > 0 then
      AddMsg(TilesData[M.Tile[px,py]].name+' в крови.',0) else
        AddMsg(TilesData[M.Tile[px,py]].name+'.',0);
  // Монстр
  if All > 0 then
    if M.MonP[px,py] > 0 then
    begin
      if M.MonP[px,py] = 1 then
        AddMsg(Format('Это ты - %s. Ты %s.', [pc.name, pc.WoundDescription]),0) else
          begin
            if M.MonL[M.MonP[px,py]].felldown then
              s := Format('Здесь лежит %s.', [M.MonL[M.MonP[px,py]].FullName(1, TRUE)]) else
                s := M.MonL[M.MonP[px,py]].FullName(1, TRUE);
            // Состояние
            s := s + Format(' %s.', [M.MonL[M.MonP[px,py]].WoundDescription]);
            // Тактика
            if M.MonL[M.MonP[px,py]].tactic = 1 then
              s := s + ' Настроен{/a} весьма агрессивно.';
            if M.MonL[M.MonP[px,py]].tactic = 2 then
              s := s + ' Защищается.';
            // Оружие в руках и другие вещи
            if IsFlag(MonstersData[M.MonL[M.MonP[px,py]].id].flags, M_HAVEITEMS) then
            begin
              // Оружие
              if M.MonL[M.MonP[px,py]].eq[6].id = 0 then
                s := s + ' Безоруж{ен/на}.' else
                  s := s + Format(' В руках держит %s.', [ItemsData[M.MonL[M.MonP[px,py]].eq[6].id].name3]);
              // Щит
              if M.MonL[M.MonP[px,py]].eq[8].id > 0 then
                s := s + Format(' В руках держит %s.', [ItemsData[M.MonL[M.MonP[px,py]].eq[6].id].name3]);
              // Броня
              if M.MonL[M.MonP[px,py]].eq[4].id > 0 then
                  s := s + Format(' На нем ты видишь %s.', [ItemsData[M.MonL[M.MonP[px,py]].eq[4].id].name3]);
            end;
{    Font.Color := cBROWN;
    TextOut(5*CharX, 11*CharY, '[ ] - Голова            :');
    TextOut(5*CharX, 12*CharY, '[ ] - Шея               :');
    TextOut(5*CharX, 13*CharY, '[ ] - Плащ              :');
    TextOut(5*CharX, 14*CharY, '[ ] - Тело              :');
    TextOut(5*CharX, 15*CharY, '[ ] - Пояс              :');
    TextOut(5*CharX, 16*CharY, '[ ] - Оружие            :');
    TextOut(5*CharX, 17*CharY, '[ ] - Дальний бой       :');
    TextOut(5*CharX, 18*CharY, '[ ] - Щит               :');
    TextOut(5*CharX, 19*CharY, '[ ] - Запястье          :');
    TextOut(5*CharX, 20*CharY, '[ ] - Кольцо            :');
    TextOut(5*CharX, 21*CharY, '[ ] - Перчатки          :');
    TextOut(5*CharX, 22*CharY, '[ ] - Обувь             :');
    TextOut(5*CharX, 23*CharY, '[ ] - Амуниция          :');}
            AddMsg(s,  M.MonL[M.MonP[px,py]].id);
          end;
     end;
  // Предмет
  if All <> 1 then
    if M.Item[px,py].id > 0 then
    begin
      if M.Item[px,py].amount = 1 then
        AddMsg(Format('Здесь лежит %s.', [ItemName(M.Item[px,py], 0, TRUE)]),0) else
          AddMsg(Format('Здесь лежат %s.', [ItemName(M.Item[px,py], 0, TRUE)]),0);
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
  i, wasenter, waslevel : byte;
  dunname : string[17];
begin
  if (M.Tile[pc.x,pc.y] = tdDSTAIRS) or (M.Tile[pc.x,pc.y] = tdOHATCH) or (M.Tile[pc.x,pc.y] = tdDUNENTER) then
  begin
    // Убрать указатель на героя
    M.MonP[pc.x,pc.y] := 0;
    // Сохранить уровень
    if M.Save = False then AddMsg('Сохрание не удалось *:(*',0);
    // Если герой снаружи нужно узнать номер лестницы
    if pc.enter = 0 then
    begin
      for i:=1 to MaxLadders do
        if (SpecialMaps[pc.level].Ladders[i].x = pc.x) and (SpecialMaps[pc.level].Ladders[i].y = pc.y) then
        begin
          pc.enter := i;
          if SpecialMaps[pc.level].Ladders[i].name = '' then
            dunname := GetDungeonModeMapName() else
              dunname := SpecialMaps[pc.level].Ladders[i].name;
          break;
        end;
    end else
      begin
        if M.name <> '' then
          dunname := M.name;
      end;
    // Этаж ниже
    inc(pc.depth);
    waslevel := pc.level;
    if SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel > 0 then
      pc.level := SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel;
    // Если загрузить не удастся - либо генерим, либо загружаем спец. уровень
    if M.Load(pc.level, pc.enter, pc.depth) = False then
    begin
      // Генерируем
      if SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel = 0 then
      begin
        // Без лестицы вниз
        if (pc.depth = 10) or (SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth+1].IsHere = FALSE) then
          M.GenerateCave(SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].DungeonType, FALSE) else
            M.GenerateCave(SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].DungeonType, TRUE);
        M.name := DunName;
      end else
        // Спец. уровень
          M.MakeSpMap(pc.level);
      if DunName <> '' then M.name := DunName;
    end;
    PlaceAtTile(tdUSTAIRS);
    pc.turn := 2;
    AddMsg(Format('Ты спустил{ся/ась} вниз по лестнице на уровень %d.', [pc.depth]),0);
  end else
    if M.Tile[pc.x,pc.y] = tdUSTAIRS then
    begin
      dunname := M.name;
      // Убрать указатель на героя
      M.MonP[pc.x,pc.y] := 0;
      // Сохранить уровень
      if M.Save = False then AddMsg('Сохрание не удалось <:(>',0);
      // Этаж выше
      dec(pc.depth);
      wasenter := pc.enter;
      if pc.depth = 0 then pc.enter := 0;
      if SpecialMaps[pc.level].LadderUp > 0 then
        pc.level := SpecialMaps[pc.level].LadderUp;
      // Пробуем загрузить...
      if M.Load(pc.level,pc.enter,pc.depth) = False then
      begin
        AddMsg('Не удалось загрузить карту. Возможно файл с сохранением был удален, либо его не удалось записать.',0);
        More;
        AddMsg('*Это критическая ошибка. Игра окончена.*',0);
        More;
        AskForQuit := FALSE;
        MainForm.Close;
      end;
      if SpecialMaps[M.Special].name = '' then M.name := DunName else M.name := SpecialMaps[M.Special].name;
      if M.Special > 0 then
        pc.level := M.Special;
      // Поместить героя
      if pc.depth = 0 then
      begin
        pc.x := SpecialMaps[pc.level].Ladders[wasenter].x;
        pc.y := SpecialMaps[pc.level].Ladders[wasenter].y;
        M.MonP[pc.x, pc.y] := 1;
      end else
        PlaceAtTile(tdDSTAIRS);
      pc.turn := 2;
      if pc.depth > 0 then
        AddMsg(Format('Ты поднял{ся/ась} по лестнице на уровень %d.', [pc.depth]),0) else
          AddMsg('Ты поднял{ся/ась} по лестнице и снова оказал{ся/ась} на свежем воздухе.',0);
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
    0 : AddMsg('Здесь нет открытой двери!',0);
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
        AddMsg('Какую именно дверь ты хочешь закрыть?',0);
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
      1 : AddMsg('Рядом с тобой никого нет!',0);  // Атаковать
      2 : AddMsg('Здесь не с кем поговорить!',0); // Говорить
      3 : AddMsg('Рядом с тобой никого нет!',0);  // Отдать
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
              pc.turn := 1;
              Exit;
            end;
    end;
    else
      begin
        case whattodo of
          1 : AddMsg('На кого именно ты хочешь напасть?',0);
          2 : AddMsg('С кем именно ты хочешь поговорить?',0);
          3 : AddMsg('Кому именно отдать?',0);
        end;
        GameState := gsCHOOSEMONSTER;
        wtd := whattodo;
      end;
  end;
end;

{ Найти самого ближайщего монстра }
function Tpc.SearchForAliveField : byte;
var
  MList    : array[1..255] of byte;
  a, b, k  : integer;
begin
  FillMemory(@MList, SizeOf(MList), 0);
  k := 1;
  // Составим список окружающих монстров
  for a:=x-20 to x+20 do
    for b:=y-20 to y+20 do
      if (a>0) and (a<=MapX) and (b>0) and (b<=MapY) then
        if M.Saw[a,b] = 2 then
          if M.MonP[a,b] > 1 then
          begin
            MList[k] := M.MonP[a,b];
            inc(k);
          end;
  if MList[1] > 0 then
  begin
    // Найдем самого близкого
    b := 1;
    for a:=1 to 255 do
      if MList[a] > 0 then
      begin
        if (ABS(x - M.MonL[MList[a]].x) <= ABS(x - M.MonL[MList[b]].x)) and (ABS(y - M.MonL[MList[a]].y) <= ABS(y - M.MonL[MList[b]].y)) then
           b := a;
      end else
        break;
    Result := MList[b];
  end else
    Result := 0;
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
        AddMsg('Ты закрыл{/a} дверь.',0);
        M.Tile[a,b] := tdCDOOR;
        pc.turn := 1;
      end else
        AddMsg('Здесь стоит '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! Ты не можешь закрыть дверь!',0);
    end else
      AddMsg('Здесь нет открытой двери!',0);
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
        AddMsg('Ты открыл{/a} дверь.',0);
        M.Tile[a,b] := tdODOOR;
        pc.turn := 1;
      end else
        AddMsg('Здесь стоит '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! Ты не можешь открыть дверь! Хотя как он тут может стоять?',0);
    end else
      if M.Tile[a,b] = tdCHATCH then
      begin
        if M.MonP[a,b] = 0 then
        begin
          AddMsg('Ты с трудом открыл{/a} люк.',0);
          M.Tile[a,b] := tdOHATCH;
          pc.turn := 1;
        end else
          AddMsg('Здесь стоит '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! Ты не можешь открыть люк!',0);
      end else
        AddMsg('Что здесь можно открыть?',0);
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
        AnalysePlace(lx,ly,2);
      end;
end;

{ Двигать курсор прицела }
procedure TPc.MoveAim(dx,dy : shortint);
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
        if M.MonP[lx,ly] > 0 then AddMsg('#Целиться в:#',0);
        AnalysePlace(lx,ly,1);
      end;
end;

{ Вывести информацию на экран справа }
procedure Tpc.WriteInfo;
var
  HLine: Byte;
  MB, WW: Integer;
begin
  with Screen.Canvas do
  begin
    // Ширина бара
    WW := (98*CharX) - (82*CharX);
    // Имя
    HLine := 1;
    Font.Color := cLIGHTGRAY;
    Brush.Color := pc.ColorOfTactic;
    Inc(HLine);
    TextOut((((20-length(name)) div 2)+80) * CharX, HLine*CharY, name);
    Font.Color := cGRAY;
    Inc(HLine);
    TextOut((((20-(length(CLName(1))+2)) div 2)+80) * CharX, HLine*CharY, '(');
    Font.Color := pc.ClassColor;
    TextOut((((20-(length(CLName(1))+2)) div 2)+80+1) * CharX, HLine*CharY, CLName(1));
    Font.Color := cGRAY;
    TextOut((((20-(length(CLName(1))+2)) div 2)+80+1+length(CLName(1))) * CharX, HLine*CharY, ')');
    Font.Color := cBROWN;
    Brush.Color := cBLACK;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Inc(HLine);
    Inc(HLine);
    if Hp < 0 then Hp := 0;
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, HLine*CharY, 'ЗДОРОВЬЕ :');
    Font.Color := ReturnColor(Rhp, hp, 1);
    TextOut(92*CharX, HLine*CharY, IntToStr(hp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, HLine*CharY, '('+IntToStr(Rhp)+')');
    // Полоса здоровья
    if (ShowBars = 1) then begin
      Inc(HLine);
      Pen.Color := cGRAY;
      Pen.Width := 9;
      MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
      LineTo((98*CharX) + 4, Round((HLine + 0.5)*CharY));
      if (Hp > 0) then
      begin
        Pen.Color := cLIGHTRED;
        MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
        LineTo((82*CharX) + BarWidth(HP, RHP, WW) + 4, Round((HLine + 0.5)*CharY));
      end;
    end;
    //
    Inc(HLine);
    if Mp < 0 then Mp := 0;
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, HLine*CharY, 'МАНА     :');
    Font.Color := ReturnColor(Rmp, mp, 2);
    TextOut(92*CharX, HLine*CharY, IntToStr(mp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, HLine*CharY, '('+IntToStr(Rmp)+')');
    // Полоса маны
    if (ShowBars = 1) then begin
      Inc(HLine);
      Pen.Color := cGRAY;
      Pen.Width := 9;
      MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
      LineTo((98*CharX) + 4, Round((HLine + 0.5)*CharY));
      if (Mp > 0) then
      begin
        Pen.Color := cLIGHTBLUE;
        MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
        LineTo((82*CharX) + BarWidth(MP, RMP, WW) + 4, Round((HLine + 0.5)*CharY));
      end;
    end;
    //
    Font.Color := cBROWN;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Inc(HLine);
    Inc(HLine);
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, HLine*CharY, 'СИЛА     :');
    if str > Rstr then
      Font.Color := cLIGHTGREEN else
        if str < Rstr then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, HLine*CharY, IntToStr(str));
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, 'ЛОВКОСТЬ :');
    if dex > Rdex then
      Font.Color := cLIGHTGREEN else
        if dex < Rdex then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, HLine*CharY, IntToStr(dex));
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, 'ИНТЕЛЛЕКТ:');
    if int > Rint then
      Font.Color := cLIGHTGREEN else
        if int < Rint then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, HLine*CharY, IntToStr(int));
    Font.Color := cBROWN;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    Inc(HLine);
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, 'УРОВЕНЬ  :'+IntToStr(explevel));
    // Полоса опыта
    if (ShowBars = 1) then begin
      Inc(HLine);
      Pen.Color := cGRAY;
      Pen.Width := 9;
      MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
      LineTo((98*CharX) + 4, Round((HLine + 0.5)*CharY));
      if pc.exp < 0 then pc.exp := 0;
      if (pc.exp > 0) then
      begin
        Pen.Color := cBLUEGREEN;
        MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
        LineTo((82*CharX) + BarWidth(pc.exp, pc.ExpToNxtLvl, WW) + 4, Round((HLine + 0.5)*CharY));
      end;
    end;
    //
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, 'ОПЫТ     :'+IntToStr(pc.exp));
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, 'НУЖНО    :'+IntToStr(pc.ExpToNxtLvl));
    Font.Color := cBROWN;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Inc(HLine);
    Inc(HLine);
    // Название текущей карты
    Font.Color := cLIGHTGRAY;
    if (M.Special > 0) and (SpecialMaps[M.Special].ShowName) then
      TextOut(82*CharX, HLine*CharY, SpecialMaps[M.Special].name) else
    begin
      if ((M.Special > 0) and (SpecialMaps[M.Special].ShowName = False) and
        (pc.depth > 0)) or ((M.Special = 0) and (pc.depth > 0)) then
      begin
        // Отображаем название подземелья и его глубину
        TextOut(82*CharX, HLine*CharY, M.name);
        Inc(HLine);
        TextOut(82*CharX, HLine*CharY, 'ГЛУБИНА  : '+IntToStr(pc.depth))
      end else
          TextOut(82*CharX, HLine*CharY, 'Странное место...');
    end;
    Font.Color := cBROWN;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Inc(HLine);
    Inc(HLine);
    if (hp > 0) then
    case pc.status[stHUNGRY] of
      -500..-400:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, HLine*CharY, 'Тошнит...');
      end;
      -399..-1  :
      begin
        Font.Color := cGREEN;
        TextOut(82*CharX, HLine*CharY, GetMsg('Переел{/a}...',gender));
      end;
      0..450    :
      begin
        Font.Color := cGRAY;
        TextOut(82*CharX, HLine*CharY, GetMsg('Сыт{ый/ая}',gender));
      end;
      451..750  :
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, HLine*CharY, GetMsg('Проголодал{ся/ась}',gender));
      end;
      751..1200  :
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, HLine*CharY, GetMsg('Голод{ен/на}',gender));
      end;
      1201..1500 :
      begin
        Font.Color := cRED;
        TextOut(82*CharX, HLine*CharY, GetMsg('Умираешь от голода!',gender));
      end;
    end else
    begin
      Font.Color := cGRAY;
      TextOut(82*CharX, HLine*CharY, GetMsg('Мертв{ый/ая}',gender));
    end;
    if (hp > 0) then begin
      Inc(HLine);
      case pc.status[stDRUNK] of
      350..500:
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, HLine*CharY, GetMsg('Пьян{ый/ая}',gender));
      end;
      501..800:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, HLine*CharY, GetMsg('Пьян{ый/ая}! Ик!',gender));
      end;
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
    AddMsg('Здесь не с кем поговорить!',0);
end;

{ Список квестов }
procedure Tpc.QuestList;
var
  i, k : byte;
begin
  StartDecorating('<-СПИСОК ТЕКУЩИХ КВЕСТОВ->', FALSE);
  with Screen.Canvas do
  begin
    k := 0;
    for i:=1 to QuestsAmount do
      if (pc.quest[i] in [1..3]) then
      begin
        k := 1;
        break;
      end;
    if k = 0 then
    begin
      Font.Color := cLIGHTGRAY;
      TextOut(5*CharX,5*CharY,GetMsg('Пока что ты не взял{/a} ни одного квеста.',gender));
    end else
      // Вывести квесты
      for i:=1 to QuestsAmount do
      begin
        if (pc.quest[i] in [1..3]) then
        begin
          Font.Color := cLIGHTGREEN;
          case i of
            1 : TextOut(4*CharX,(4+i)*CharY,'Исследовать хранилище и освободить людей от зла, таящегося в нем (Старейшина)');
            2 : TextOut(4*CharX,(4+i)*CharY,'Найти ключ от восточных врат деревни (Старейшина)');
          end;
          case pc.quest[i] of
            1 :
            begin
              Font.Color := cRED;
              TextOut(2*CharX,(4+i)*CharY,'-');
            end;
            2 :
            begin
              Font.Color := cGREEN;
              TextOut(2*CharX,(4+i)*CharY,'+');
            end;
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
  s3 = '< Нажми ENTER для того, что бы использовать предмет >';
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
    TextOut(5*CharX, 17*CharY, '[ ] - Дальний бой       :');
    TextOut(5*CharX, 18*CharY, '[ ] - Щит               :');
    TextOut(5*CharX, 19*CharY, '[ ] - Запястье          :');
    TextOut(5*CharX, 20*CharY, '[ ] - Кольцо            :');
    TextOut(5*CharX, 21*CharY, '[ ] - Перчатки          :');
    TextOut(5*CharX, 22*CharY, '[ ] - Обувь             :');
    TextOut(5*CharX, 23*CharY, '[ ] - Амуниция          :');
    for i:=1 to EqAmount do
      if pc.eq[i].id = 0 then
      begin
        if HaveItemVid(Eq2Vid(i)) then
        begin
          Font.Color := cYELLOW;
          TextOut(31*CharX,(10+i)*CharY,'+');
        end else
            begin
              Font.Color := cGRAY;
              TextOut(31*CharX,(10+i)*CharY,'-');
            end;
        // Отобразить атаку в рукопашной схватке
        if i = 6 then
        begin
          Font.Color := cLIGHTGRAY;
          TextOut(33*CharX, (10+i)*CharY, Format('{Атака в рукопашной схватке: %d}', [pc.attack])); 
        end;
      end else
        begin
          Font.Color := cLIGHTGRAY;
          TextOut(31 * CharX, (10+i)*CharY, ItemName(pc.eq[i], 0, TRUE));
        end;
    Font.Color := cGRAY;
    if ItemsAmount > 0 then
      TextOut(((WindowX-length(s1)) div 2) * CharX, 39*CharY, s1) else
        TextOut(((WindowX-length(s2)) div 2) * CharX, 39*CharY, s2);
    if pc.Eq[MenuSelected].id > 0 then
      TextOut(((WindowX-length(s3)) div 2) * CharX, 37*CharY, s3);
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
  i,k : byte;
begin
  // Интерфейс
  if VidFilter = 0 then
    StartDecorating('<-ИНВЕНТАРЬ->', FALSE) else
      StartDecorating('<-'+WhatToDo(VidFilter)+'->', FALSE);
  // Очистить указатели
  for i:=1 to MaxHandle do InvList[i] := 0;
  // Занести указатели по фильтру
  k := 1;
  for i:=1 to ItemsAmount do
    if (VidFilter = 0) or (ItemsData[pc.inv[i].id].vid = VidFilter) then
    begin
      InvList[k] := i;
      inc(k);
    end;
  // Вывести список предметов
  with Screen.Canvas do
  begin
    Font.Color := cGRAY;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 37*CharY, s1);
    TextOut(((WindowX-length(s2)) div 2) * CharX, 39*CharY, s2);
    for i:=1 to ItemsAmount do
      if InvList[i] > 0 then
      begin
        Font.Color := cBROWN;
        TextOut(5 * CharX, (2+i)*CharY, '[ ]');
        Font.Color := cLIGHTGRAY;
        TextOut(9 * CharX, (2+i)*CharY, ItemName(pc.inv[InvList[i]], 0, TRUE));
        Font.Color := cRED;
        TextOut(6*CharX, (2+MenuSelected)*CharY,'*');
      end else
        break;
    WriteSomeAboutItem(pc.Inv[InvList[MenuSelected]]);
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
  AddMsg('$Поздравляю! Ты достиг{/ла} нового уровня развития!$',0);
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
      AddMsg('Ты открыл{/a} в себе новую способность - "$'+AbilitysData[i].name+'$"!',0) else
        AddMsg('Твоя способность "#'+AbilitysData[i].name+'#" стала на уровень лучше!',0);
    Apply;
  end;
  // Каждый третий уровень можно выбрать пракачку СЛИ
  if pc.explevel mod 3 = 0 then
  begin
    AddMsg('#Ты можешь повысить один из своих атрибутов!#',0);
    a := Ask('Выбери какой: (#S#) Сила, (#D#) Ловкость или (#I#) Интеллект?');
    case a[1] of
      'S' :
      begin
        inc(pc.Rstr);
        pc.str := pc.Rstr;
        AddMsg('$Ты стал{/a} сильнее.$',0);
        Apply;
      end;
      'D' :
      begin
        inc(pc.Rdex);
        pc.dex := pc.Rdex;
        AddMsg('$Ты стал{/a} более ловк{им/ой}.$',0);
        Apply;
      end;
      'I' :
      begin
        inc(pc.Rint);
        pc.int := pc.Rint;
        AddMsg('$Ты стал{/a} умнее.$',0);
        Apply;
      end;
      ELSE
        // Рандомный выбор
        case Random(3)+1 of
          1 :
          begin
            inc(pc.Rstr);
            pc.str := pc.Rstr;
            AddMsg('$Ты стал{/a} сильнее.$',0);
            Apply;
          end;
          2 :
          begin
            inc(pc.Rdex);
            pc.dex := pc.Rdex;
            AddMsg('$Ты стал{/a} более ловк{им/ой}.$',0);
            Apply;
          end;
          3 :
          begin
            inc(pc.Rint);
            pc.int := pc.Rint;
            AddMsg('$Ты стал{/a} умнее.$',0);
            Apply;
          end;
        end;
    end;
  end;
  AddMsg('',0);
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
    DrawBorder(75,2,20,HOWMANYVARIANTS+1,crLIGHTGRAY);
    Font.Color := cBROWN;
    TextOut(77*CharX, 3*CharY, '[ ]');
    Font.Color := cWHITE;
    if WasEq then
      // В экипировке
      TextOut(81*CharX, 3*CharY, 'В инвентарь') else
        // В инвентаре
        TextOut(81*CharX, 3*CharY, WhatToDo(ItemsData[pc.Inv[MenuSelected].id].vid));
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

{ Действия после смерти героя }
procedure TPc.AfterDeath;
begin
  AddMsg('*Ты умер{/лa}!!!*',0);
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

{ Искать }
procedure Tpc.Search;
var
  a, b : integer;
begin
  for a:=pc.x-1 to pc.x+1 do
    for b:=pc.y-1 to pc.y+1 do
      if (a > 0) and (a <= MapX) and (b > 0) and (b <= MapY) then
        if (M.tile[a,b] = tdSECSTONE) or (M.tile[a,b] = tdSECEARTH) then
          if Random(8 - pc.ability[abATTENTION])+1 = 1 then
          begin
            M.tile[a,b] := tdCDOOR;
            AddMsg('$Ты наш{ел/лa} секретную дверь!$',0);
            More;
          end;
end;

{ Есть ли хоть один предмет этого вида? }
function TPc.HaveItemVid(vid : byte) : boolean;
var
  i : byte;
  f : boolean;
begin
  f := FALSE;
  for i:=1 to ItemsAmount do
    if ItemsData[inv[i].id].vid = vid then
    begin
      f := TRUE;
      break;
    end;
  Result := f;
end;

{ Окно ввода имени }
procedure TPc.StartHeroName;
begin
  GameState := gsHERONAME;
  Input(((WindowX-13) div 2), 17, '');
end;

{ Окно ввода имени }
procedure TPc.HeroName;
const s2 = '^^^^^^^^^^^^^';
var
  n : string[13];
  s1: string;
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  s1 := GetMsg('Введи имя геро{я/ини}:',gender);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s2)) div 2) * CharX, 18*CharY, s2);
    if (Inputing = FALSE) then
    begin
      if InputString = '' then
      begin
        case pc.gender of
          genMALE   : pc.name := GenerateName(FALSE);
          genFEMALE : pc.name := GenerateName(TRUE);
        end;
      end else
        pc.name := InputString;
      GameState := gsHEROATR;
      MainForm.OnPaint(NIL);
    end;
  end;
end;

{ Сделать рандомного }
procedure TPc.HeroRandom;
const
  s1 = 'Создашь персонаж сам или доверишься воле случая?';
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, 'Создам сам');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, 'Рандомный герой');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ Окно выбора пола }
procedure TPc.HeroGender;
const
  s1 = 'Какого пола будет твой персонаж?';
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, 'Мужского');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, 'Женского');
    Font.Color := cBROWN;
    TextOut(40*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 17*CharY, 'Без разницы');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ Расстановка приоритетов }
procedure TPc.HeroAtributes;
var
  s1, s2 : string;
begin
  s1 := Format('Выбери атрибут, в котором %s больше всего преуспел{/a}:', [pc.name]); //'Выбери атрибут, в котором '+pc.name+' больше всего преуспел{/a}:';
  s2 := Format('А теперь выбери атрибут, которому %s тоже уделял{/a} внимание:', [pc.name]); //'А теперь выбери атрибут, которому '+pc.name+' тоже уделял{/a} внимание:';
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    case MenuSelected2 of
      1 :
      TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(S1,gender));
      2 :
      TextOut(((WindowX-length(s2)) div 2) * CharX, 13*CharY, GetMsg(S2,gender));
    end;
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, 'Сила');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, 'Ловкость');
    Font.Color := cBROWN;
    TextOut(40*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 17*CharY, 'Интеллект');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

procedure TPc.CreateClWList;
var
  i,k    : byte;
begin
  // Создать список
  for i:=1 to CLOSEFIGHTAMOUNT do wlist[i] := 0;
  k := 0;
  for i:=2 to CLOSEFIGHTAMOUNT do
    if pc.closefight[i] > 0 then
    begin
      inc(k);
      wlist[k] := i;
    end;
  wlistsize := k;
end;

{ Окно выбора типа оружия ближнего боя }
procedure TPc.HeroCloseWeapon;
var
  s1  : string;
  i   : byte;
begin
  CreateClWList;
  s1 := Format('Выбери оружие ближнего боя, с которым %s тренировал{ся/ась} больше всего:', [PC.Name]);
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(s1,gender));
    for i:=1 to CLOSEFIGHTAMOUNT-1 do
      if wlist[i] > 0 then
        if pc.closefight[wlist[i]] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(40*CharX, (14+i)*CharY, '[ ]');
          if OneOfTheBestWPNCL(wlist[i]) then
            Font.Color := cWHITE else
              Font.Color := cGRAY;
          case wlist[i] of
            2 : TextOut(44*CharX, (14+i)*CharY, 'Меч');
            3 : TextOut(44*CharX, (14+i)*CharY, 'Дубина');
            4 : TextOut(44*CharX, (14+i)*CharY, 'Посох');
            5 : TextOut(44*CharX, (14+i)*CharY, 'Топор');
            6 : TextOut(44*CharX, (14+i)*CharY, 'Рукопашный бой');
          end;
        end;
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

procedure TPc.CreateFrWList;
var
  i,k    : byte;
begin
  // Создать список
  for i:=1 to FARFIGHTAMOUNT do wlist[i] := 0;
  k := 0;
  for i:=2 to FARFIGHTAMOUNT do
    if pc.farfight[i] > 0 then
    begin
      inc(k);
      wlist[k] := i;
    end;
  wlistsize := k;
end;

{ Окно выбора пола }
procedure TPc.HeroFarWeapon;
var
  S1     : string;
  I      : byte;
begin
  CreateFrWList;
  S1 := Format('Какое оружие дальнего боя %s осваивал{/a} во время тренировок?', [PC.Name]);
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(s1,gender));
    for i:=1 to FARFIGHTAMOUNT do
      if wlist[i] > 0 then
        if pc.farfight[wlist[i]] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(40*CharX, (14+i)*CharY, '[ ]');
          if OneOfTheBestWPNFR(wlist[i]) then
            Font.Color := cWHITE else
              Font.Color := cGRAY;
          case wlist[i] of
            2 : TextOut(44*CharX, (14+i)*CharY, 'Лук');
            3 : TextOut(44*CharX, (14+i)*CharY, 'Праща');
            4 : TextOut(44*CharX, (14+i)*CharY, 'Духовая трубка');
            5 : TextOut(44*CharX, (14+i)*CharY, 'Арбалет');
          end;
      end;
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ Подтвердить }
procedure Tpc.HeroCreateResult;
const
  s1 = 'ENTER - продожить, ESC - создать заново';
var
  R, H, S : string;
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  Script.Run('CreatePC.pas');
  S := Format(V.GetStr('CreatePCStr'), [CLName(1), PC.Name]);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s)) div 2) * CharX, 13*CharY, GetMsg(S,gender));
    Font.Color := cYELLOW;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
  end;
end;

{ Выбрать режим игры }
procedure TPc.ChooseMode;
const
  s1 = 'В каком режиме игры ты хочешь играть?';
begin
  StartDecorating('<-ВЫБОР РЕЖИМА ИГРЫ->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, 'Приключение');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, 'Подземелье');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

end.

