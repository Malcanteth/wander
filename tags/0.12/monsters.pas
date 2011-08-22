unit monsters;

interface

uses
  Utils, Cons, Tile, Flags, Msg, Items, SysUtils, Ability, Windows, Main;

type
  TMonster = object
    id              : byte;
    name            : string[13];                  // Ну собственно имя
    x, y,                                          // Координаты
    aim, aimx, aimy : byte;                        // Цель, последние увиденные координаты
    energy          : integer;                     // Энергия
    Hp, RHp         : integer;                     // Здоровье
    Mp, RMp         : integer;                     // Мана
    speed, Rspeed   : word;                        // Скорость
    los, Rlos       : byte;                        // Длина зрения
    relation        : byte;                        // Отношение к герою (0Никак,1Агрессия)
    eq              : array[1..14] of TItem;       // Экипировка
    inv             : array[1..MaxHandle] of TItem;  // Предметы монстра
    invmass         : real;                          // Масса инвентаря и экипировки
    //Атрибуты
    Rst,st,                                        //сила
    Rdex,dex,                                      //ловкость
    Rint,int        : byte;                        //интеллект
    //Атака голыми руками, суммарная защита
    attack, defense : integer;
    //К атаке, к защите
    todmg, todef    : integer;
    //Упал
    felldown        : boolean;
    //Таланты
    ability         : array[1..AbilitysAmount] of byte;// Способности
    //Тактика (0-стандартная, 1-нападения, 2-защиты
    tactic          : byte;

    function Replace(nx, ny : integer) : byte;        // Попытаться передвинуться
    procedure DoTurn;                                 // AI
    function DoYouSeeThis(ax,ay : byte) : boolean;    // Видит ли монстр точку
    function MoveToAim(obstacle : boolean) : boolean; // Сделать шаг к цели
    procedure MoveRandom;                             // Двинуться рандомно
    function Move(dx,dy : integer) : boolean;         // Переместить монстра
    function WoundDescription : string;               // Вернуть описание состояния здоровья
    procedure TalkToMe;                               // Поговорить с кем-нибудь
    procedure Fight(var Victim : TMonster; CA : byte);// Драться (CA: 1 - контратака, 2 - второй удар!)
    procedure GiveItem(var Victim : TMonster;
                                 var GivenItem : TItem); // Отдать вещь
    procedure Death;                                  // Умереть
    procedure BloodStreem(dx,dy : shortint);
    function PickUp(Item : TItem;
                             FromEq : boolean) : byte;// Поместить вещь в инвентарь (0-успешно,1-ничего нет,2-нет места,3-перегружен
    function MaxMass : real;
    procedure DeleteInvItem(var I : TItem;
                      full : boolean);                // Удалить предмет из инвентаря
    procedure RefreshInventory;                       // Перебрать инвентарь
    function ColorOfTactic: longword;                 // Вернуть цвет заднего фона монстра при использовании тактики
    function TacticEffect(situation : byte) : real;   // Вернуть множитель (0.5, 1 или 2 - эффект от тактики)
    function EquipItem(Item : TItem) : byte;          // Снарядить предмет (0-успешно,1-ячейка занята)
    function ExStatus(situation : byte) : string;     // Вернуть описание состояние монстра (одержимый, проклятый и тд)
    function FullName(situation : byte; writename : boolean) : string;     // Вернуть полное имя монстра
    function HeSheIt(situation : byte) : string;      // Вернуть окончание в зависимости от пола и ситуации
  end;

  TMonData = record
    name1, name2, name3, name4, name5, name6 : string[40];  // Названия (1Кто,2Кого,3Кому,4Кем,5Чей,6Чьи)
    char                       : string[1];       // Символ
    color                      : longword;        // Цвет
    gender                     : byte;
    hp                         : word;            // Здоровье
    speed                      : word;            // Скорость
    los                        : byte;            // Длина зрения
    st, dex, int, at, def      : byte;
    exp                        : byte;
    mass                       : real;
    coollevel                  : byte;
    flags                      : longword;        // Флажки:)
  end;

const
  { Константы количества монстров }
  MonstersAmount = 23;

  {  Описание монстров }
  MonstersData : array[1..MonstersAmount] of TMonData =
  (
    ( name1 : 'Ты'; name2 : 'Тебя'; name3 : 'Тебе'; name4 : 'Тобой'; name5 : 'Тебя';
      char : '@'; color : cLIGHTBLUE; gender : genMALE;
      flags : NOF or M_NEUTRAL;
    ),
    ( name1 : 'Житель'; name2 : 'Жителя'; name3 : 'Жителю'; name4 : 'Жителем'; name5 : 'Жителя'; name6 : 'Жителей';
      char : 'h'; color : cBROWN; gender : genMALE;
      hp : 30; speed : 100; los : 6; st : 5; dex : 5; int : 3; at : 7; def : 7;
      exp : 5; mass : 60.4;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS;
    ),
    ( name1 : 'Жительница'; name2 : 'Жительницу'; name3 : 'Жительнице'; name4 : 'Жительницей'; name5 : 'Жительницы'; name6 : 'Жительниц';
      char : 'h'; color : cLIGHTRED; gender : genFEMALE;
      hp : 18; speed : 100; los : 6; st : 3; dex : 6; int : 4;  at : 4; def : 5;
      exp : 3; mass : 40.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS;
    ),
    ( name1 : 'Старейшина'; name2 : 'Старейшину'; name3 : 'Старейшине'; name4 : 'Старейшиной'; name5 : 'Старейшины'; name6 : 'Старейшин';
      char : 't'; color : cYELLOW; gender : genMALE;
      hp : 45; speed : 110; los : 6; st : 7; dex : 5; int : 7; at : 19; def : 20;
      exp : 15; mass : 55.3;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Автор'; name2 : 'Автора'; name3 : 'Автору'; name4 : 'Автором'; name5 : 'Автора'; name6 : 'Авторов';
      char : 'P'; color : cRANDOM; gender : genMALE;
      hp : 666; speed : 200; los : 8; st : 99; dex : 99; int : 99;  at : 25; def : 50;
      exp : 255; mass : 58.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Крыса'; name2 : 'Крысу'; name3 : 'Крысе'; name4 : 'Крысой'; name5 : 'Крысы'; name6 : 'Крыс';
      char : 'r'; color : cBROWN; gender : genFEMALE;
      hp : 8; speed : 160; los : 5; st : 2; dex : 6; int : 1;  at : 2; def : 1;
      exp : 2; mass : 8.3; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Летучая Мышь'; name2 : 'Летучую Мышь'; name3 : 'Летучей Мыши'; name4 : 'Летучей Мышью'; name5 : 'Летучей Мыши'; name6 : 'Летучих Мышей';
      char : 'B'; color : cGRAY; gender : genFEMALE;
      hp : 6; speed : 220; los : 7; st : 3; dex : 8; int : 1;  at : 1; def : 2;
      exp : 4; mass : 6.8; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Паук'; name2 : 'Паука'; name3 : 'Пауку'; name4 : 'Пауком'; name5 : 'Паука'; name6 : 'Пауков';
      char : 's'; color : cWHITE; gender : genMALE;
      hp : 7; speed : 180; los : 5; st : 2; dex : 8; int : 1;  at : 2; def : 1;
      exp : 2; mass : 0.9; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Гоблин'; name2 : 'Гоблина'; name3 : 'Гоблину'; name4 : 'Гоблином'; name5 : 'Гоблина'; name6 : 'Гоблинов';
      char : 'g'; color : cGREEN; gender : genMALE;
      hp : 13; speed : 115; los : 6; st : 5; dex : 7; int : 2;  at : 5; def : 5;
      exp : 4; mass : 30.5; coollevel : 1;
      flags : NOF or M_HAVEITEMS or M_OPEN;
    ),
    ( name1 : 'Орк'; name2 : 'Орка'; name3 : 'Орку'; name4 : 'Орком'; name5 : 'Орка'; name6 : 'Орков';
      char : 'o'; color : cLIGHTGREEN; gender : genMALE;
      hp : 15; speed : 105; los : 6; st : 6; dex : 6; int : 3;  at : 7; def : 7;
      exp : 5; mass : 55.0; coollevel : 2;
      flags : NOF or M_HAVEITEMS or M_OPEN;
    ),
    ( name1 : 'Огр'; name2 : 'Огра'; name3 : 'Огру'; name4 : 'Огром'; name5 : 'Огра'; name6 : 'Огров';
      char : 'o'; color : cBROWN; gender : genMALE;
      hp : 20; speed : 85; los : 5; st : 9; dex : 6; int : 2;  at : 10; def : 9;
      exp : 6; mass : 70.9; coollevel : 3;
      flags : NOF or M_HAVEITEMS or M_OPEN;
    ),
    ( name1 : 'Слепая Зверюга'; name2 : 'Слепую Зверюгу'; name3 : 'Слепой Зверюге'; name4 : 'Слепой Зверюгой'; name5 : 'Слепой Зверюги'; name6 : 'Слепых Зверюг';
      char : 'M'; color : cCYAN; gender : genFEMALE;
      hp : 70; speed : 70; los : 2; st : 15; dex : 6; int : 3;  at : 15; def : 11;
      exp : 14; mass : 85.0; coollevel : 4;
      flags : NOF or M_ALWAYSANSWERED;
    ),
    ( name1 : 'Пьяница'; name2 : 'Пьяницу'; name3 : 'Пьянице'; name4 : 'Пьяницой'; name5 : 'Пьяницы'; name6 : 'Пьяниц';
      char : 'h'; color : cBLUE; gender : genMALE;
      hp : 17; speed : 40; los : 4; st : 5; dex : 4; int : 4;  at : 6; def : 4;
      exp : 4; mass : 40.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Бармен'; name2 : 'Бармена'; name3 : 'Бармену'; name4 : 'Барменом'; name5 : 'Бармена'; name6 : 'Барменов';
      char : 'b'; color : cRED; gender : genMALE;
      hp : 40; speed : 100; los : 6; st : 5; dex : 5; int : 5;  at : 7; def : 7;
      exp : 12; mass : 60.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Убийственно пьяный мужик'; name2 : 'Убийственно пьяного мужика'; name3 : 'Убийственно пьяному мужику'; name4 : 'Убийственно пьяным мужиком'; name5 : 'Убийственно пьяного мужика'; name6 : 'Убийственно пьяных мужиков';
      char : 'h'; color : cBLUE; gender : genMALE;
      hp : 5; speed : 20; los : 2; st : 3; dex : 2; int : 1; at : 1; def : 1;
      exp : 0; mass : 35.7;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_FELLDOWN or M_HAVEITEMS;
    ),
    ( name1 : 'Целительница'; name2 : 'Целительницу'; name3 : 'Целительнице'; name4 : 'Целительницой'; name5 : 'Целительницы'; name6 : 'Целительниц';
      char : 'h'; color : cLIGHTGREEN; gender : genFEMALE;
      hp : 30; speed : 120; los : 6; st : 5; dex : 7; int : 9; at : 10; def : 10;
      exp : 10; mass : 45.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Мясник'; name2 : 'Мясника'; name3 : 'Мяснику'; name4 : 'Мясником'; name5 : 'Мясника';  name6 : 'Мясников';
      char : '@'; color : cRED; gender : genMALE;
      hp : 35; speed : 100; los : 5; st : 9; dex : 5; int : 4; at : 20; def : 15;
      exp : 20; mass : 67.2;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Таракан'; name2 : 'Таракана'; name3 : 'Таракану'; name4 : 'Тараканом'; name5 : 'Таракана'; name6 : 'Тараканов';
      char : 'c'; color : cORANGE; gender : genMALE;
      hp :7; speed : 130; los : 6; st : 1; dex : 7; int : 1;  at : 1; def : 2;
      exp : 1; mass : 1; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Мелкий червь'; name2 : 'Мелкого червя'; name3 : 'Мелкому червю'; name4 : 'Мелким червем'; name5 : 'Мелкого червя'; name6 : 'Мелких червей';
      char : 'w'; color : cYELLOW; gender : genMALE;
      hp : 8; speed : 90; los : 5; st : 2; dex : 7; int : 1;  at : 2; def : 3;
      exp : 2; mass : 2.5; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Торговец'; name2 : 'Торговца'; name3 : 'Торговцу'; name4 : 'Торговцем'; name5 : 'Тогровца';  name6 : 'Торговцев';
      char : '@'; color : cORANGE; gender : genMALE;
      hp : 30; speed : 110; los : 6; st : 7; dex : 7; int : 6; at : 15; def : 18;
      exp : 18; mass : 63.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Фанатик'; name2 : 'Фанатика'; name3 : 'Фанатику'; name4 : 'Фанатиком'; name5 : 'Фанатика'; name6 : 'Фанатиков';
      char : 'f'; color : cPURPLE; gender : genMALE;
      hp : 30; speed : 115; los : 6; st : 6; dex : 6; int : 5; at : 8; def : 8;
      exp : 8; mass : 55.0; coollevel : 4;
      flags : NOF or M_OPEN or M_NAME or M_HAVEITEMS;
    ),
    ( name1 : 'Жена ключника'; name2 : 'Жену ключника'; name3 : 'Жене ключника'; name4 : 'Женой ключника'; name5 : 'Жены ключника'; name6 : 'Жён ключника';
      char : 'f'; color : cWHITE; gender : genFEMALE;
      hp : 20; speed : 90; los : 6; st : 3; dex : 6; int : 4;  at : 4; def : 5;
      exp : 5; mass : 45.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS or M_STAY;
    ),
    ( name1 : 'Ключник'; name2 : 'Ключника'; name3 : 'Ключнику'; name4 : 'Ключником'; name5 : 'Ключника'; name6 : 'Ключников';
      char : 'k'; color : cRED; gender : genMALE;
      hp : 35; speed : 100; los : 6; st : 6; dex : 6; int : 3;  at : 6; def : 9;
      exp : 12; mass : 60.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS;
    )
  );

  { Уникальные идентификаторы монстров }
  mdHERO               = 1;
  mdMALECITIZEN        = 2;
  mdFEMALECITIZEN      = 3;
  mdELDER              = 4;
  mdBREAKMT            = 5;
  mdRAT                = 6;
  mdBAT                = 7;
  mdSPIDER             = 8;
  mdGOBLIN             = 9;
  mdORC                = 10;
  mdOGR                = 11;
  mdBLINDBEAST         = 12;
  mdDRUNK              = 13;
  mdBARTENDER          = 14;
  mdDRUNKKILLED        = 15;
  mdHEALER             = 16;
  mdMEATMAN            = 17;
  mdCOCKROACH          = 18;
  mdLITTLEWORM         = 19;
  mdSELLER             = 20;
  mdFANATIK            = 21;
  mdKEYWIFE            = 22;
  mdKEYMAN             = 23;

var
  nx, ny : byte;

procedure CreateMonster(n,px,py : byte);   // Создать монстра
function RandomMonster(x,y : byte) : byte; // Создать случайного монстра
procedure MonstersTurn;                    // У каждого монстра есть право на ход

implementation

uses
  Map, Player, MapEditor;

{ Создать монстра }
procedure CreateMonster(n,px,py : byte);
var
  i : byte;
begin
  if M.MonP[px,py] = 0 then
  begin
    for i:=2 to 255 do
      if M.MonL[i].id = 0 then
        break;
    if (i = 255) and (M.MonL[i].id > 0) then exit;
    M.MonP[px,py] := i;
    with M.MonL[i] do
    begin
      id := n;
      if IsFlag(MonstersData[id].flags, M_NAME) then
        if MonstersData[id].gender = genMALE then
          name := GenerateName(FALSE) else
            name := GenerateName(TRUE) else
              name := GenerateName(FALSE);
      x := px;
      y := py;
      if not IsFlag(MonstersData[id].flags, M_NEUTRAL) then
      begin
        aim := 1;
        relation := 1;
      end;
      Rhp := MonstersData[id].hp;
      hp := Rhp;
      Rspeed := MonstersData[id].speed;
      speed := Rspeed;
      Rlos := MonstersData[id].los;
      los := Rlos;
      if IsFlag(MonstersData[id].flags, M_FELLDOWN) then
        felldown := True else
          felldown := False;
      Rst := MonstersData[id].st;
      st := Rst;
      Rdex := MonstersData[id].dex;
      dex := Rdex;
      Rint := MonstersData[id].int;
      int := Rint;
      attack := MonstersData[id].at;
      defense := MonstersData[id].def;
      // Тактика
      if Random(5)+1 = 1 then
        tactic := Random(2)+1 else
          tactic := 0;
      // Вещи
      if IsFlag(MonstersData[id].flags, M_HAVEITEMS) then
      begin
        // Экипировка
        // Инвентарь
        if id = mdKEYMAN then
        begin
          // Дать ему ключ
          PickUp(CreateItem(idGATESKEY, 1, 0), FALSE);
        end;
      end
    end;
  end;
end;

{ Создать случайного монстра }
function RandomMonster(x,y : byte) : byte;
begin
  Result := 2;
end;

{ Попытаться передвинуться : 0Нет проблем, 1Вне границ,2Твердый тайл,3Монстр}
function TMonster.Replace(nx, ny : integer) : byte;
begin
  Result := 0;
  if not((x=nx)and(y=ny)) then
  begin
    if not((nx>0)and(nx<=MapX)and(ny>0)and(ny<=MapY)) then Result := 1 else
      if TilesData[M.Tile[nx,ny]].move = False then Result := 2 else
        if M.MonP[nx,ny] > 0 then Result := 3;
  end;
end;

{ У каждого монстра есть право на ход }
procedure MonstersTurn;
var
  i : byte;
begin
  for i:=2 to 255 do
    if M.MonL[i].id > 1 then
      M.MonL[i].doturn;
end;

{ AI }
procedure TMonster.DoTurn;
var
  a, b : integer;
begin
  energy := energy + speed;
  while energy >= speed  do
  begin
    nx := x;
    ny := y;
    // Если упал, то встать
    if FellDown then
      FellDown := False else
      // Если есть цель
      if Aim > 0 then
      begin
        // Узнать новые координаты цели
        for a:= nx - los to nx + los do
          for b:= ny - los to ny + los do
            if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
              if M.MonP[a,b] = Aim then
                if (DoYouSeeThis(a,b)) then
                begin
                  AimX := a;
                  AimY := b;
                  break;
                end;
          if (AimX > 0) and (AimY > 0) then
          begin
            // Двигаться к цели
            if MoveToAim(false) = false then
              if MoveToAim(true) = false then
                if Random(10) <= 8 then
                  MoveRandom;
          end else
            MoveRandom;
      end else
        begin
          if relation = 1 then
            Aim := 1 else
              MoveRandom;
        end;
    energy := energy - speed + (speed - (pc.speed + Round(pc.ability[abENERGETIC] * AbilitysData[abENERGETIC].koef)));
  end;
end;

{ Видит ли монстр эту точку }
{ TODO -oPD -cminor : Довольно корявая функция. Делает кучу ненужного и вообщем-то копирует уже существующую. }
function TMonster.DoYouSeeThis(ax,ay : byte) : boolean;
const
  quads : array[1..4] of array[1..2] of ShortInt = ((1,1),(-1,-1),(-1,+1),(+1,-1));
  RayNumber = 32;
  RayWidthCorrection = 10;
var
  tx, ty, mini, maxi, cor, u, v : integer;
  quad, slope : byte;
procedure PictureIt(x,y : byte);
begin
  if (ax = x) and (ay = y) then
  begin
    Result := True;
    exit;
  end;
end;
begin
  Result := False;
  tx := x; repeat Inc(tx); PictureIt(tx,y) until (TilesData[M.Tile[tx,y]].void = False)or(InFov(x,y,tx,y,los) = False);
  tx := x; repeat Dec(tx); PictureIt(tx,y) until (TilesData[M.Tile[tx,y]].void = False)or(InFov(x,y,tx,y,los) = False);
  ty := y; repeat Inc(ty); PictureIt(x,ty) until (TilesData[M.Tile[x,ty]].void = False)or(InFov(x,y,x,ty,los) = False);
  ty := y; repeat Dec(ty); PictureIt(x,ty) until (TilesData[M.Tile[x,ty]].void = False)or(InFov(x,y,x,ty,los) = False);
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
          if (TilesData[M.Tile[quads[quad][1]*tx+x,quads[quad][2]*ty+y]].void = False)or(InFov(x,y,quads[quad][1]*tx+x,quads[quad][2]*ty+y,los)=false)then
            mini := cor;
        end;
        if maxi > cor then
        begin
          PictureIt(x+quads[quad][1]*(tx-1),y+quads[quad][2]*(ty+1));
          if (TilesData[M.Tile[x+quads[quad][1]*(tx-1),y+quads[quad][2]*(ty+1)]].void = False)or(InFov(x,y,x+quads[quad][1]*(tx-1),y+quads[quad][2]*(ty+1),los)=false)then
            maxi := cor;
        end;
        v := v + slope;
      until
        mini > maxi;
    end;
end;

{ Сделать шаг к цели }
function TMonster.MoveToAim(obstacle : boolean) : boolean;
const
  NK = 100;
var
  nmap : array[1..MapX,1..MapY] of byte;
  j,min : byte;
  mx,my : shortint;
  a,b : integer;
  find : boolean;
begin
  Result := true;
  // Заполнить карту проходимости
  for a:=nx-los to nx+los do
    for b:=ny-los to ny+los do
      if (a>0)and(a<=MapX)and(b>0)and(b<=MapY)then
      begin
        if M.MonP[a,b] > 0 then
        begin
          if obstacle then
            nmap[a,b] := 254 else
              nmap[a,b] := 255;
        end else
          if (TilesData[M.Tile[a,b]].move)or((M.Tile[a,b] = tdCDOOR)and(IsFlag(MonstersData[id].flags, M_OPEN)))then
            nmap[a,b] := 254 else
              nmap[a,b] := 255;
      end;
  nmap[nx,ny] := 253;
  nmap[aimx,aimy] := 0;
  // Проверка массива
  j := 0;
  Find := False;
  repeat
    for a:=nx-los to nx+los do
      for b:=ny-los to ny+los do
        if (a>0)and(a<=MapX)and(b>0)and(b<=MapY)then
          if nmap[a,b] = j then
          begin
            if a-1 > 0 then
            begin
              if nmap[a-1,b] = 253 then Find := True;
              if nmap[a-1,b] = 254 then nmap[a-1,b] := j+1;
            end;
            if a+1 <= MapX then
            begin
              if nmap[a+1,b] = 253 then Find := True;
              if nmap[a+1,b] = 254 then nmap[a+1,b] := j+1;
            end;
            if b-1 > 0 then
            begin
              if nmap[a,b-1] = 253 then Find := True;
              if nmap[a,b-1] = 254 then nmap[a,b-1] := j+1;
            end;
            if b+1 <= MapY then
            begin
              if nmap[a,b+1] = 253 then Find := True;
              if nmap[a,b+1] = 254 then nmap[a,b+1] := j+1;
            end;
            if (b+1<MapY)and(a-1>1)then
            begin
              if nmap[a-1,b+1] = 253 then Find := True;
              if nmap[a-1,b+1] = 254 then nmap[a-1,b+1] := j+1;
            end;
            if (b+1<MapY)and(a+1<MapX)then
            begin
              if nmap[a+1,b+1] = 253 then Find := True;
              if nmap[a+1,b+1] = 254 then nmap[a+1,b+1] := j+1;
            end;
            if (b-1>1)and(a-1>1)then
            begin
              if nmap[a-1,b-1] = 253 then Find := True;
              if nmap[a-1,b-1] = 254 then nmap[a-1,b-1] := j+1;
            end;
            if (b-1>1)and(a+1<MapX)then
            begin
              if nmap[a+1,b-1] = 253 then Find := True;
              if nmap[a+1,b-1] = 254 then nmap[a+1,b-1] := j+1;
            end;
          end;
    j := j + 1;
    if j > NK then
    begin
      Result := false;
      exit;
    end;
  until
    Find;
  { Найти путь}
  min := 255;
  mx := 0;
  my := 0;
  if nx-1 > 0 then
  begin
    min := nmap[nx-1,ny];
    mx := -1;
    my := 0;
  end;
  if nx+1 <= MapX then
    if nmap[nx+1,ny] < min then
    begin
      min := nmap[nx+1,ny];
      mx := 1;
      my := 0;
    end;
  if ny-1 > 0 then
    if nmap[nx,ny-1] < min then
    begin
      min := nmap[nx,ny-1];
      mx := 0;
      my := -1;
    end;
  if ny+1 <= MapY then
    if nmap[nx,ny+1] < min then
    begin
      min := nmap[nx,ny+1];
      mx := 0;
      my := 1;
    end;
  if (nx-1 > 0)and(ny+1 <= MapY) then
    if nmap[nx-1,ny+1] < min then
    begin
      min := nmap[nx-1,ny+1];
      mx := -1;
      my := 1;
    end;
  if (nx+1 <= MapX)and(ny+1 <= MapY) then
    if nmap[nx+1,ny+1] < min then
    begin
      min := nmap[nx+1,ny+1];
      mx := 1;
      my := 1;
    end;
  if (nx-1 > 0)and(ny-1 > 0) then
    if nmap[nx-1,ny-1] < min then
    begin
      min := nmap[nx-1,ny-1];
      mx := -1;
      my := -1;
    end;
  if (nx+1 <= MapX)and(ny-1 > 0) then
    if nmap[nx+1,ny-1] < min then
    begin
      mx := 1;
      my := -1;
    end;
  Result :=  M.MonL[M.MonP[nx,ny]].Move(nx+mx,ny+my);
end;

{ Переместить монстра хаотично }
procedure TMonster.MoveRandom;
begin
  Move(nx+((Random(3)-1)), ny+((Random(3)-1)));
end;

{ Переместить монстра }
function TMonster.Move(dx,dy : integer) : boolean;
begin
  Result := True;
  if not M.MonL[M.MonP[nx,ny]].felldown then
    case M.MonL[M.MonP[nx,ny]].Replace(dx,dy) of
      0 : // Просто передвинуться
      begin
        if not ((IsFlag(MonstersData[id].flags, M_STAY)) and (aim = 0)) then
        begin
          if not((M.MonP[dx,dy] > 0) and (aim <> M.MonP[dx,dy])) then
          begin
            if not((dx=nx)and(dy=ny)) then
            begin
              M.MonP[dx,dy] := M.MonP[nx,ny];
              M.MonL[M.MonP[dx,dy]].x := dx;
              M.MonL[M.MonP[dx,dy]].y := dy;
              M.MonP[nx,ny] := 0;
            end else
              Result := False;
          end else
            Result := False;
        end else
          Result := False;
      end;
      2 : // Открыть дверь
      begin
        if IsFlag(MonstersData[id].flags, M_OPEN) then
          if M.Tile[dx,dy] = tdCDOOR then
            M.Tile[dx,dy] := tdODOOR;
      end;
      3 : // Атаковать
      begin
        if M.MonP[dx,dy] = Aim then
        begin
          if Aim = 1 then
            Fight(pc, 0) else
              Fight(M.MonL[aim], 0);
        end else
          Result := False;
      end else
        Result := False
    end;
end;

{ Вернуть описание состояния здоровья }
function TMonster.WoundDescription : string;
var
  r : string;
begin
  if hp = Rhp then
  begin
    if id = 1 then
      r := 'чувствуешь себя замечательно' else
        r := 'чувствует себя замечательно';
  end else
    if hp <= Round(Rhp / 6) then
    begin
      r := 'почти труп';
    end else
      if hp <= Round(Rhp / 4) then
      begin
        r := 'ужасно ранен' + HeSheIt(1);
      end else
        if hp <= Round(Rhp / 3) then
        begin
          r := 'тяжело ранен' + HeSheIt(1);
        end else
          if hp <= Round(Rhp / 2) then
          begin
            r := 'полумертв' + HeSheIt(1);
          end else
            if hp <= Round(Rhp / 4)*3 then
            begin
              r := 'легко ранен' + HeSheIt(1);
            end else
              r :=  'в легкую задет' + HeSheIt(1);
  Result := r;
end;

{ Поговорить с кем-нибудь }
procedure TMonster.TalkToMe;
var
  s : string;
  w : boolean;
  p : integer;
begin
  if relation = 0 then
  begin
      w := TRUE;
      s := FullName(1, TRUE) + ' говорит: ';
      case id of
        mdMALECITIZEN, mdFEMALECITIZEN:
        begin
          case Random(4)+1 of
            1 : if pc.name = name then
                  s := '"Тебя зовут '+pc.name+'? И меня так же!"' else
                    s := s + '"Меня зовут '+name+'. Рад'+HeSheIt(1)+' познакомится с тобой, '+pc.name+'!"';
            2 :
            case pc.quest[1] of
              0 : s := s + '"Старейшина ждёт таких как ты. Поторопись!"';
              1 : s := s + '"Ох... нет! Я не за что не спущусь в хранилище!"';
              2 : s := s + '"Ты был в хранилище? О, боже! Быстрее беги к старейшине! Вот это новость!"';
              3 : s := s + '"Спасибо, за то что спас нас! Мы все тебе очень благодарны!"';
            end;
            3 : s := s + '"Прости, но мне нужно идти!"';
            4 : s := s + '"Сегодня хорошая погода не так ли?"';
          end;
        end;
        mdELDER:
        begin
          case pc.quest[1] of
            0 :
            begin
              w := FALSE;
              AddMsg('Ты представил'+pc.HeSheIt(2)+' '+MonstersData[id].name3+'.');
              More;
              AddMsg(MonstersData[id].name1 + ' говорит: "Здравствуй, '+pc.name+'! Меня зовут '+name+'. Я старейшина Эвилиара и у меня есть к тебе просьба."');
              More;
              AddMsg('"Понимаешь, в Эвилиаре есть хранилище в котором все наши жители держат свои запасы продовольствия. Оно находится в северо-восточной части деревни и представляет собой всего один этаж под землёй."');
              More;
              AddMsg('"Две недели назад пара жителей спустилась в хранилище. Они хотели заменить старые несущие балки и раскинуть отраву для крыс. Но только спустившись вниз крысы ожесточились и начали кидаться на людей!"');
              More;
              AddMsg('"Более того, сквозь мрак жители увидели нескольких тварей, которые были агрессивно на них настроены! Бедняги говорили, что видели гоблинов и кобольда, но... я не особо им верю."');
              More;
              AddMsg('"Откуда им там взяться? В деревне их никто не видел... Уж не из под земли же они взялись! В любом случае - в хранилище теперь все боятся спускаться, запасы еды заканчиваются... Не знаю, что будет дальше!"');
              More;
              AddMsg('"Я очень прошу тебя - спустись в хранилище и избавь нас от этого ужаса!"');
              pc.quest[1] := 1;
            end;
            1 :
            begin
              case Random(3)+1 of
                1 : s := s + '"Ну как? Ты еще не исследовал'+pc.HeSheIt(1)+' хранилище? Как жаль!"';
                2 : s := s + '"Пожалуйста, '+pc.name+',поторопись! Люди в опасности!"';
                3 : s := s + '"Мы все надеемся на тебя, '+pc.name+'!"';
              end;{case}
            end;
            2 : // Выполнил!
            begin
              w := FALSE;
              AddMsg('Ты рассказал'+pc.HeSheIt(1)+' '+MonstersData[id].name3+' о своем приключении в хранилище.');
              More;
              AddMsg('Он очень удивился твоему рассказу, но, кажется, не особо тебе поверил...');
              More;
              AddMsg('Тебе нужно дать ему какие-нибудь доказательства!');
            end;
            3 : // Дал доказательство!
            begin
              w := FALSE;
              AddMsg(MonstersData[id].name3+', пожав тебе руку, сказал:');
              More;
              AddMsg('"Ты не представляешь, как я тебе благодарен! Ты избавил'+pc.HeSheIt(1)+' нас от этого кошмара!"');
              More;
              AddMsg('"Вот, возьми эти деньги! Надеюсь, они тебе помогут!"');
              More;
              AddMsg('Ты взял'+pc.HeSheIt(1)+' золотые монеты и положил'+pc.HeSheIt(1)+' их в карман.');
              pc.PickUp(CreateItem(idCOIN, 300, 0), FALSE);
              pc.quest[1] := 4;
              More;
              AddMsg('"Есть у меня еще одно дельце! Будешь заинтересован'+pc.HeSheIt(1)+' - обращайся!"');
              More;
            end;
            4 : // Выполнен квест №1
            begin
              // Квест № 2
              case pc.quest[2] of
                0 :
                begin
                  w := FALSE;
                  AddMsg(FullName(1, TRUE) + ' говорит: "Ну что, я вижу ты готов'+pc.HeSheIt(1)+' для нового задания. А дело вот в чем..."');
                  More;
                  AddMsg('"Не знаю заметил'+pc.HeSheIt(1)+' ты или нет, но восточный выход из деревни закрыт. Там стоят врата, которые закрыты на тяжелый замок."');
                  More;
                  AddMsg('"Сделано это было недавно по причине участившихся нападений и визитов нежеланных гостей..."');
                  More;
                  AddMsg('"Сейчас нам потребовалось открыть эти врата, что бы пустить торговцев с востока..."');
                  More;
                  AddMsg('"Но, будь он проклят, этот ключник куда-то пропал!"');
                  More;
                  AddMsg('"Где искать ключ от врат - ума не приложу!"');
                  More;
                  if Ask('"Ну что? Готов'+pc.HeSheIt(1)+' взяться за это дельце?"  [(Y/n)]') = 'Y' then
                  begin
                    AddMsg('"Отлично! Я рассчитываю на тебя!"');
                    pc.quest[2] := 1;
                    More;
                  end else
                    begin
                      AddMsg('"Очень жаль... Надеюсь ты передумаешь в ближайшее время!"');
                      More;
                    end;
                end;
                // Взял квест...
                1 :
                begin
                  s := s + '"Ты еше не наш'+pc.HeSheIt(6)+' ключ? Очень жаль..."';
                end;
                // Узнал кое-что о ключнике (убил его :)
                2 :
                begin
                  w := FALSE;
                  AddMsg(FullName(1, TRUE) + ' говорит: "О, боже... Это невероятно... Какая трагедия...."');
                  More;
                  AddMsg('"Я уже давно заметил, что наш ключник... как бы... сам не свой..."');
                  More;
                  AddMsg('"Невероятно..."');
                  More;
                  AddMsg('"Но... Был ли при нём ключ?"');
                  More;
                end;
                // Отдал ключ
                3 :
                begin
                  w := FALSE;
                  AddMsg(MonstersData[id].name3+', пожав тебе руку, сказал:');
                  More;
                  AddMsg('"И снова ты выручил'+pc.HeSheIt(1)+' всех жителей Эвилиара! Теперь можно наконец открыть восточные врата!"');
                  More;
                  AddMsg('"Вот, возьми эти деньги! Ничего более оригинального я не придумал, но когда-нибудь я дам тебе что-то более весомое!"');
                  More;
                  AddMsg('Ты взял'+pc.HeSheIt(1)+' золотые монеты и положил'+pc.HeSheIt(1)+' их в карман.');
                  pc.PickUp(CreateItem(idCOIN, 500, 0), FALSE);
                  pc.quest[2] := 4;
                  M.Tile[79,18] := tdROAD;
                  More;
                end;
              end; {case quest 2}
            end;
          end;
        end;
        mdBREAKMT:
        begin
          case Random(3)+1 of
            1 : s := s + '"Не советую меня бить... Впрочем... Можешь попробовать разок, если уж очень хочется!"';
            2 : s := s + '"Я тут вообще не игровой персонаж. Но все-равно у меня есть кое-что... Гм... Нет. Тебе рановато!"';
            3 : s := s + '"Читерские вещи не продаю. Хотя следовало бы... Надо подумать над этим."';
          end;
        end;
        mdKEYWIFE:
        begin
          case Random(3)+1 of
            1 : s := s + '"Я очень беспокоюсь за своего мужа... Он пропал!"';
            2 : s := s + '"В нашем подвале полным-полно крыс и тараканов! Я боюсь туда спускаться... Но вдруг мой муж там..."';
            3 : s := s + '"В последнее время мой муж очень странно себя вёл! Надеюсь, с ним ничего не случилось!"';
          end;
        end;
        mdBARTENDER:
        begin
          w := False;
          if (Ask(FullName(1, TRUE) + ' говорит: "Могу предложить бутылёк свежего пивасика всего за 15 золотых, хочешь?" [(Y/n)]')) = 'Y' then
          begin
            if pc.FindCoins = 0 then
              AddMsg('К сожалению, у тебя совсем нет денег.') else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('У тебя недостаточно золотых монет для покупки.') else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('Ты протягиваешь '+FullName(3, FALSE)+' деньги.');
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  pc.RefreshInventory;
                  More;
                  AddMsg('Он их пересчитывает и протягивает бутылку холодного пива.');
                  if pc.PickUp(CreateItem(idCHEAPBEER, 1, 0), FALSE) <> 0 then
                  begin
                    AddMsg('Оно упало на пол.');
                    PutItem(pc.x,pc.y, CreateItem(idMEAT, 1, 0));
                  end;
                  More;
                  AddMsg('"Далеко не уходи - вдруг еще захочешь! Можешь посидеть с нашими постояльцами..."');
                end;
            end else
              AddMsg('"Ну что ж... Мое дело предложить!"');
        end;
        mdDRUNK:
        begin
          s := s + '"Ик! ... Пфф... Ик!"';
        end;
        mdHEALER:
        begin
          w := False;
          if pc.Hp < pc.RHp then
          begin
            if (Ask(FullName(1, TRUE) + ' говорит: "Хочешь я подлечу тебя?" [(Y/n)]')) = 'Y' then
            begin
              p := Round((pc.RHp - pc.Hp) * 1.5);
              if (Ask('"Твое полное исцеление будет стоить {'+IntToStr(p)+'} золотых. Идет?" [(Y/n)]')) = 'Y' then
              begin
                if pc.FindCoins = 0 then
                  AddMsg('К сожалению, у тебя совсем нет денег.') else
                  if pc.inv[pc.FindCoins].amount < p then
                  begin
                    p := Round(pc.inv[pc.FindCoins].amount / 1.5);
                    if p > 0 then
                    begin
                      if (Ask('"Недостаточно монет... Но, если хочешь, могу немного подлечить тебя и за {'+IntToStr(pc.inv[pc.FindCoins].amount)+'} золотых. Идет?" [(Y/n)]')) = 'Y' then
                      begin
                        AddMsg('Ты протягиваешь '+FullName(3, FALSE)+' деньги.');
                        pc.inv[pc.FindCoins].amount := 0;
                        pc.RefreshInventory;
                        More;
                        AddMsg('Она быстренько пересчитывает и прячет их. Затем достает фляжку с горячим отваром и дает тебе выпить... ');
                        More;
                        AddMsg('[Сначала тебя немного затошнило, но несколько секунд спустя стало лучше!] ({+'+IntToStr(p)+'})');
                        inc(pc.Hp, p);
                      end else
                        AddMsg('"Тогда ищи более выгодные предложения!"');
                    end else
                      AddMsg('К сожалению, у тебя недостаточно монет, что бы хоть чуть-чуть подлечиться.');
                  end else
                    if pc.inv[pc.FindCoins].amount >= p then
                    begin
                      AddMsg('Ты протягиваешь '+FullName(3, FALSE)+' деньги.');
                      dec(pc.inv[pc.FindCoins].amount, p);
                      pc.RefreshInventory;
                      More;
                      AddMsg('Она быстренько пересчитывает и прячет их. После этого она протягивает обе руки к твоей голове... ');
                      More;
                      AddMsg('[На секунду ты теряешь сознание, но, когда приходишь в себя, чувствуешь себя великолепно!]');
                      pc.Hp := pc.RHp;
                    end;
              end;
            end else
              AddMsg('"Не хочешь - как хочешь..."');
          end else
            AddMsg(FullName(1, TRUE) + ' говорит: "Здравствуй, '+pc.name+'! Меня зовут '+name+'. Если тебя ранят - заходи ко мне, я смогу тебе помочь."');
        end;
        mdMEATMAN:
        begin
          w := False;
          if (Ask(FullName(1, TRUE) + ' говорит: "Хочешь купить кусок отличного свежего мяса всего за 15 золотых?" [(Y/n)]')) ='Y' then
          begin
            if pc.FindCoins = 0 then
              AddMsg('К сожалению, у тебя совсем нет денег.') else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('У тебя недостаточно золотых монет для покупки.') else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('Ты протягиваешь '+FullName(3, FALSE)+' деньги.');
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  RefreshInventory;
                  More;
                  AddMsg('Он их пересчитывает и отдает кусок мяса.');
                  if pc.PickUp(CreateItem(idMEAT, 1, 0), FALSE) <> 0 then
                  begin
                    AddMsg('Оно упало на пол.');
                    PutItem(pc.x,pc.y, CreateItem(idMEAT, 1, 0));
                  end;
                  More;
                  AddMsg('"Возвращайся еще, когда захочешь кушать!"');
                end;
            end else
              AddMsg('"Если передумаешь - обязательно заходи ко мне!"');
        end;
        else s := 'Говорить впустую...';
      end;
      if w then AddMsg(s);
  end else
    AddMsg('Ох! Вы не в таких отношениях, чтобы беседовать!');
end;

{ Драться }
procedure TMonster.Fight(var Victim : TMonster; CA : byte);
var
  i : byte;
  dam : integer;
begin
  // Если контратака
  if CA = 1 then
    if id = 1 then
      AddMsg('<'+MonstersData[id].name1+' контратакуешь!>') else
        AddMsg('<'+MonstersData[id].name1+' контратакует!>');
  // Если второй удар
  if CA = 2 then
    if id = 1 then
      AddMsg('<'+MonstersData[id].name1+' успеваешь нанести еще один удар!>') else
        AddMsg('<'+MonstersData[id].name1+' успевает нанести еще один удар!>');
  if M.MonP[Victim.x, victim.y] > 0 then
  begin
    { --Атаковать враждебного-- }
    if ((Victim.relation = 1) and (id = 1)) or (id > 1)  then
    begin
      if Random(Round(TacticEffect(2)*(dex+(ability[abACCURACY]*AbilitysData[abACCURACY].koef))))+1 > Random(Round(Victim.TacticEffect(1)*(Victim.dex+(Victim.ability[abDODGER]*AbilitysData[abDODGER].koef))))+1 then
      begin
        // Щит
        if (Victim.eq[7].id > 0) and (Random(Round(Victim.dex*Victim.TacticEffect(1)))+1 = 1) then
          AddMsg('{'+Victim.FullName(1, FALSE)+' блокировал'+Victim.HeSheIt(1)+' атаку своим щитом!}')
        else
          begin
            if Eq[6].id > 0 then
              Dam := Random(Round(ItemsData[Eq[6].id].attack+(st/4)))+1 else
                Dam := Random(attack)+1;
            Dam := (Round(Dam/(Random(Round(TacticEffect(1)*2))+1) + Round(st/4))) - Random(Round(Victim.defense/(Random(Round(Victim.TacticEffect(2)*2))+1)));
            if CA = 1 then
              Dam := Round(Dam / (1 + ((Random(Round(10*TacticEffect(2)))+1) / 10)));
            if Dam <= 0 then // Попал, но не пробил
              AddMsg(FullName(1, FALSE)+' попал'+HeSheIt(1)+' по '+Victim.FullName(3, FALSE)+', но не пробил'+HeSheIt(1)+' броню.') else
                begin
                  Victim.hp := Victim.hp - Dam;
                  Victim.BloodStreem( -(x - Victim.x), -(y - Victim.y));
                  if Victim.hp > 0 then
                  begin
                    AddMsg(FullName(1, FALSE)+' попал'+HeSheIt(1)+' по '+Victim.FullName(3, FALSE)+'! (<'+IntToStr(Dam)+'>)');
                    if id = 1 then
                      AddMsg(Victim.FullName(1, TRUE)+' '+Victim.WoundDescription+'.');
                  end else
                    begin
                      AddMsg('<'+FullName(1, TRUE)+' убил'+HeSheIt(1)+' '+Victim.FullName(2, TRUE)+'!>');
                      if id = 1 then
                      begin
                        inc(pc.exp, MonstersData[Victim.id].exp);
                        if pc.exp >= pc.ExpToNxtLvl then
                          pc.GainLevel;
                        if Victim.id = mdBLINDBEAST then
                        begin
                          AddMsg('[Ты выполнил'+HeSheIt(1)+' квест!!!]');
                          pc.quest[1] := 2;
                          More;
                        end;
                        if Victim.id = mdKEYMAN then
                        begin
                          AddMsg('<Чёртов ключник спятил!!!>');
                          pc.quest[2] := 2;
                          More;
                        end;
                      end;
                      Victim.Death;
                    end;
                end;
          end;
      end else
        begin
          AddMsg(FullName(1, FALSE)+' промахнул'+HeSheIt(2)+' по '+Victim.FullName(3, FALSE)+'.');
        end;
      // Если враг еще не умер
      if Victim.id > 0 then
      begin
        // Шанс контратаки!!!
        if Round(Victim.TacticEffect(1)) * Random(Round(Victim.dex / 2) + (Victim.ability[abQUICKREACTION]) * Round(AbilitysData[abQUICKREACTION].koef)) + 1 > Random(100)+1 then
          Victim.Fight(Self, 1);
        // Шанс ударить еще раз!!!
        if Round(TacticEffect(2)) * Random(Round(Victim.dex / 4) + (Victim.ability[abQUICKATTACK]) * Round(AbilitysData[abQUICKATTACK].koef)) + 1 > Random(100)+1 then
          Fight(Victim, 2);
      end;
    end;
    { -- Атаковать нейтрального --}
    if  (id = 1) and (Victim.relation = 0)then
    begin
      if Ask('Точно напасть на '+Victim.FullName(2, TRUE)+'? [(Y/n)]') = 'Y' then
      begin
        AddMsg('Ты неожиданно напал'+HeSheIt(1)+' на '+Victim.FullName(2, FALSE)+'!');
        if Victim.id = mdBREAKMT then
        begin
          More;
          AddMsg('<Ты почувствовал'+HeSheIt(1)+', что пол под твоими ногами развергся...>');
          More;
          AddMsg('<И ты проваливаешься вниз!>');
          More;
          M := SpecialMaps[3].Map;
          pc.PlaceHere(30,23);
          pc.turn := 2;
        end else
          begin
            AddMsg(Victim.FullName(1, FALSE)+' в ярости!');
            Victim.relation := 1; // Агрессия!
            Victim.aim := 1;
            // Если это произошло в деревеньке... то герою #!^&#@
            if (pc.level = 1) and (pc.depth = 0) then
            begin
              for i:=1 to 255 do
                if (M.MonL[i].id > 0) and (M.MonL[i].relation = 0) then
                begin
                  // Автор испаряется :))
                  if M.MonL[i].id = mdBREAKMT then
                  begin
                    M.MonP[M.MonL[i].x,M.MonL[i].y] := 0;
                    M.MonL[i].id := 0;
                  end else
                    begin
                      M.MonL[i].relation := 1;
                      M.MonL[i].aim := 1;
                    end;
                end;
              More;
              AddMsg('<Ты видишь, что все посмотрели на тебя...>');
              More;
              AddMsg('<И в воздухе зависла недобрая тишина...>');
              More;
              AddMsg('<Которая в следущую секунду была прервана криками!>');
              More;
              AddMsg('Что ты наделал'+HeSheIt(1)+'! Теперь вся деревня против тебя!');
              More;
              Fight(Victim, 0);
            end;
          end;
      end else
        AddMsg('Ты немного подумал'+HeSheIt(1)+' и решил'+HeSheIt(1)+' этого не делать.');
    end;
  end else
    AddMsg('Но здесь никого нет!');
end;

{ Отдать вещь }
procedure TMonster.GiveItem(var Victim : TMonster; var GivenItem : TItem);
begin
  if ((Victim.relation = 0) and (id = 1)) or (id > 1) then
  begin
    if Ask('Точно отдать '+ItemName(GivenItem, 1, TRUE)+' '+Victim.FullName(3, TRUE)+'? [(Y/n)]') = 'Y' then
    begin
      // 0-успешно,1-ничего нет,2-нет места,3-перегружен
      case Victim.PickUp(GivenItem, FALSE) of
        0 :
        begin // Успешно отдал
          AddMsg(FullName(1, TRUE)+' отдал'+HeSheIt(1)+' '+Victim.FullName(3, TRUE)+' '+ItemName(GivenItem, 1, TRUE)+'.');
          // Отдал башку старейшине
          if (GivenItem.id = idHEAD) and (GivenItem.owner = mdBLINDBEAST) then
            if pc.quest[1] > 1 then
              pc.quest[1] := 3;
          // Отдал ключ старейшине
          if GivenItem.id = idGATESKEY then
            if pc.quest[2] > 1 then
              pc.quest[2] := 3;
          DeleteInvItem(GivenItem, TRUE);
          RefreshInventory;
        end;
        1 : AddMsg(FullName(1, TRUE)+' отдал'+HeSheIt(1)+' '+Victim.FullName(3, TRUE)+' глюк!');
        2 : AddMsg(Victim.FullName(1, TRUE)+' уже несет очень много вещей!');
        3 : AddMsg(Victim.FullName(1, TRUE)+' перегружен'+Victim.HeSheIt(1)+' вещами!');
      end;
    end else
      AddMsg('Немного подумав, ты решил'+HeSheIt(1)+' этого не делать.');
  end else
    AddMsg('Кажется, это не совсем уместно...');
end;

{ Умереть }
procedure TMonster.Death;
var
  i : byte;
begin
  // Удалить указатель
  M.MonP[x,y] := 0;
  // Труп
  if id = 1 then
    PutItem(x,y,CreateItem(idCORPSE, 1, id)) else
      begin
        if id = mdBLINDBEAST then
          PutItem(x,y,CreateItem(idHEAD, 1, id)) else
          begin
            // Тело
            if Random(5)+1 = 1 then
              PutItem(x,y,CreateItem(idCORPSE, 1, id));
            // Голова  
            if Random(15)+1 = 1 then
              PutItem(x,y,CreateItem(idHEAD, 1, id));
          end;
      end;
  // Выкинуть вещи
  for i:=1 to EqAmount do
    if Eq[i].id > 0 then
      PutItem(x,y, Eq[i]);
  for i:=1 to MaxHandle do
    if Inv[i].id > 0 then
      PutItem(x,y, Inv[i]);
  // Если это герой, то
  if id = 1 then pc.AfterDeath;
  // Всё.
  id := 0;
end;

{ Кровь! }
procedure TMonster.BloodStreem(dx,dy : shortint);
var
  i : shortint;
begin
  if hp > 0  then
  begin
    for i:=0 to Random(Random(3)+1)+1 do
    begin
      M.blood[x+(dx*i),y+(dy*i)] := Random(2)+1;
      if TilesData[M.Tile[x+(dx*i),y+(dy*i)]].move = False then
        break;
    end;
  end else
    M.blood[x,y] := Random(2)+1;
end;

{ Поднять вещи }
function TMonster.PickUp(Item : TItem; FromEq : boolean) : byte;
var
  i : byte;
  f : boolean;
begin
  Result := 0;
  if Item.id = 0 then
    Result := 1 else
      begin
        f := false;
        for i:=1 to MaxHandle do
          if (Inv[i].id = Item.id) and (Inv[i].owner = Item.owner) then
          begin
            inc(Inv[i].amount, Item.amount);
            f := TRUE;
            break;
          end;
        if f = false then
          for i:=1 to MaxHandle do
            if Inv[i].id = 0 then
            begin
              if (invmass + (Item.mass*Item.amount) < MaxMass) or (FromEq) then
              begin
                Inv[i] := Item;
                invmass := invmass + (Item.mass*Item.amount);
                break;
              end else
                begin
                  Result := 3;
                  break;
                end;
            end else
              if (i = MaxHandle) and(Inv[i].id <> 0) then
                Result := 2;
      end;
end;

{ Сколько может нести монстр }
function TMonster.MaxMass : real;
begin
  Result := st * 15.8;
end;

{ Удалить предмет из инвентаря }
procedure TMonster.DeleteInvItem(var I : TItem; full : boolean);
begin
  // Масса
  invmass := invmass - (I.mass*I.amount);
  if (I.amount > 1) and (not full) then
    dec(I.amount) else
      FillMemory(@I, SizeOf(TItem), 0);
  RefreshInventory;
end;

{ Перебрать инвентарь }
procedure TMonster.RefreshInventory;
var
  i : byte;
begin
  for i:=1 to MaxHandle do
    if inv[i].amount <= 0 then
      FillMemory(@inv[i], SizeOf(TItem), 0);
  for i:=1 to MaxHandle-1 do
    if inv[i].id = 0 then
    begin
      inv[i] := inv[i+1];
      FillMemory(@inv[i+1], SizeOf(TItem), 0);
    end;
end;

{ Вернуть цвет заднего фона монстра при использовании тактики }
function TMonster.ColorOfTactic: longword;
begin
  Result := 0;
  case tactic of
    1 : Result := RGB(40,0,0);
    2 : Result := RGB(0,40,0);
  end;
end;

{ Вернуть множитель (0.5, 1 или 2 - эффект от тактики) }
function TMonster.TacticEffect(situation : byte) : real;
begin
  Result := 1;
  case situation of
    1 :
    case tactic of
      1 : Result := 0.5;
      2 : Result := 2;
    end;
    2 :
    case tactic of
      1 : Result := 2;
      2 : Result := 0.5;
    end;
  end;
end;

{ Снарядить предмет }
function TMonster.EquipItem(Item : TItem) : byte;
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
  if (eq[cell].id > 0) then
  begin
    TempItem := eq[cell];
    ItemOnOff(eq[cell], FALSE);
    eq[cell] := Item;
    DeleteInvItem(inv[MenuSelected], FALSE);
    if (id = 1) then
      case PickUp(TempItem, TRUE) of
        0 :
        begin
          AddMsg('Теперь ты используешь '+ItemName(eq[cell], 1, FALSE)+', а '+ItemName(TempItem, 1, TRUE)+' ты убрал'+HeSheIt(1)+' в инвентарь.');
        end;
        2 : // Нет места
          AddMsg('К сожалению, в инвентаре не достаточно места для такой операции.');
      end;
    Result := 1;
  end else
    eq[cell] := Item;
  if cell <> 12 then
    if eq[cell].amount > 1 then eq[cell].amount := 1;
end;

{ Вернуть описание состояние монстра (одержимый, проклятый и тд) }
function TMonster.ExStatus(situation : byte) : string;
var s : string;
begin
  s := '';
  // Для героя эти состояния не распределяются
  if id > 1 then
  begin
    // Отрешенный
    if (Relation = 0) and (not IsFlag(MonstersData[id].flags, M_NEUTRAL)) then
      s := s + 'Отрешенн'+HeSheIt(situation) else
    // Одержимый
    if (Relation = 1) and (IsFlag(MonstersData[id].flags, M_NEUTRAL)) then
      s := s + 'Одержим'+HeSheIt(situation);
  end;
  // Вернуть результат
  if s = '' then
    Result := s else
      Result := s+' ';
end;

{ Вернуть полное имя монстра }
function TMonster.FullName(situation : byte; writename : boolean) : string;
var s : string;
begin
  s := '';
  {(1Кто,2Кого,3Кому,4Кем,5Чей,6Чьи)}
  // Статус монстра
  case situation of
    1 : s := ExStatus(4);
    2 : s := ExStatus(7);
    3 : s := ExStatus(8);
    4 : s := ExStatus(9);
    5 : s := ExStatus(9);
    6 : s := ExStatus(10);
  end;
  // Название монстра
  case situation of
    1 : s := s + MonstersData[id].name1;
    2 : s := s + MonstersData[id].name2;
    3 : s := s + MonstersData[id].name3;
    4 : s := s + MonstersData[id].name4;
    5 : s := s + MonstersData[id].name5;
    6 : s := s + MonstersData[id].name6;
  end;
  // Если есть имя
  if id > 1 then
    if ((IsFlag(MonstersData[id].flags, M_NAME))) and (writename) then
      s := s + ' по имени '+name;
  Result := s;
end;

{ Вернуть окончание в зависимости от пола героя }
function TMonster.HeSheIt(situation : byte) :string;
var g : byte;
begin
  if id = 1 then
    g := pc.gender else
      g := MonstersData[id].gender;
  case situation of
    1 :
    case g of
      genMALE : Result := '';
      genFEMALE : Result := 'а';
    end;
    2 :
    case g of
      genMALE : Result := 'ся';
      genFEMALE : Result := 'ась';
    end;
    3 :
    case g of
      genMALE : Result := '';
      genFEMALE : Result := 'ла';
    end;
    4 :
    case g of
      genMALE : Result := 'ый';
      genFEMALE : Result := 'ая';
    end;
    5 :
    case g of
      genMALE : Result := 'ен';
      genFEMALE : Result := 'на';
    end;
    6 :
    case g of
      genMALE : Result := 'ел';
      genFEMALE : Result := 'ла';
    end;
    7 :
    case g of
      genMALE : Result := 'ого';
      genFEMALE : Result := 'ую';
    end;
    8 :
    case g of
      genMALE : Result := 'ому';
      genFEMALE : Result := 'ой';
    end;
    9 :
    case g of
      genMALE : Result := 'ым';
      genFEMALE : Result := 'ой';
    end;
    10 :
    case g of
      genMALE : Result := 'ых';
      genFEMALE : Result := 'ых';
    end;
  end;
end;

end.
