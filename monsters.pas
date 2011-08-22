unit monsters;

interface

uses
  Utils, Cons, Tile, Flags, Msg, Items, SysUtils;

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

    function Replace(nx, ny : integer) : byte;        // Попытаться передвинуться
    procedure DoTurn;                                 // AI
    function DoYouSeeThis(ax,ay : byte) : boolean;    // Видит ли монстр точку
    function MoveToAim(obstacle : boolean) : boolean; // Сделать шаг к цели
    procedure MoveRandom;                             // Двинуться рандомно
    function Move(dx,dy : integer) : boolean;         // Переместить монстра
    function WoundDescription : string;               // Вернуть описание состояния здоровья
    procedure TalkToMe;                               // Поговорить с кем-нибудь
    procedure Fight(var Victim : TMonster);           // Драться
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
  end;

  TMonData = record
    name1, name2, name3, name4 : string[40];      // Названия (1Кто,2Кого,3Кому,4Кем)
    char                       : string[1];       // Символ
    color                      : longword;        // Цвет
    gender                     : byte;
    hp                         : word;            // Здоровье
    speed                      : word;            // Скорость
    los                        : byte;            // Длина зрения
    st, dex, int, at, def      : byte;
    exp                        : byte;
    flags                      : longword;        // Флажки:)
  end;

const
  { Константы количества монстров }
  MonstersAmount = 17;

  {  Описание монстров }
  MonstersData : array[1..MonstersAmount] of TMonData =
  (
    ( name1 : 'Ты'; name2 : 'Тебя'; name3 : 'Тебе'; name4 : 'Тобой';
      gender : genMALE;
    ),
    ( name1 : 'Житель'; name2 : 'Жителя'; name3 : 'Жителю'; name4 : 'Жителем';
      char : 'h'; color : cBROWN; gender : genMALE;
      hp : 30; speed : 100; los : 6; st : 5; dex : 5; int : 3; at : 7; def : 7;
      exp : 5;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS;
    ),
    ( name1 : 'Жительница'; name2 : 'Жительницу'; name3 : 'Жительнице'; name4 : 'Жительницей';
      char : 'h'; color : cLIGHTRED; gender : genFEMALE;
      hp : 18; speed : 100; los : 6; st : 3; dex : 6; int : 4;  at : 4; def : 5;
      exp : 3;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS;
    ),
    ( name1 : 'Старейшина'; name2 : 'Старейшину'; name3 : 'Старейшине'; name4 : 'Старейшиной';
      char : 't'; color : cYELLOW; gender : genMALE;
      hp : 45; speed : 110; los : 6; st : 7; dex : 5; int : 7; at : 19; def : 20;
      exp : 15;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Автор'; name2 : 'Автора'; name3 : 'Автору'; name4 : 'Автором';
      char : 'P'; color : cRANDOM; gender : genMALE;
      hp : 666; speed : 200; los : 8; st : 99; dex : 99; int : 99;  at : 25; def : 50;
      exp : 255;
      flags : NOF or M_OPEN or M_NEUTRAL or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Крыса'; name2 : 'Крысу'; name3 : 'Крысе'; name4 : 'Крысой';
      char : 'r'; color : cBROWN; gender : genFEMALE;
      hp : 10; speed : 150; los : 5; st : 2; dex : 6; int : 1;  at : 3; def : 1;
      exp : 2;
      flags : NOF;
    ),
    ( name1 : 'Летучая Мышь'; name2 : 'Летучую Мышь'; name3 : 'Летучей Мыши'; name4 : 'Летучей Мышью';
      char : 'B'; color : cGRAY; gender : genFEMALE;
      hp : 7; speed : 220; los : 7; st : 3; dex : 9; int : 1;  at : 1; def : 2;
      exp : 4;
      flags : NOF;
    ),
    ( name1 : 'Паук'; name2 : 'Паука'; name3 : 'Пауку'; name4 : 'Пауком';
      char : 's'; color : cWHITE; gender : genMALE;
      hp : 9; speed : 180; los : 5; st : 2; dex : 8; int : 1;  at : 3; def : 1;
      exp : 2;
      flags : NOF;
    ),
    ( name1 : 'Гоблин'; name2 : 'Гоблина'; name3 : 'Гоблину'; name4 : 'Гоблином';
      char : 'g'; color : cGREEN; gender : genMALE;
      hp : 13; speed : 100; los : 6; st : 5; dex : 7; int : 2;  at : 6; def : 5;
      exp : 4;
      flags : NOF or M_HAVEITEMS or M_OPEN;
    ),
    ( name1 : 'Орк'; name2 : 'Орка'; name3 : 'Орку'; name4 : 'Орком';
      char : 'o'; color : cLIGHTGREEN; gender : genMALE;
      hp : 15; speed : 105; los : 6; st : 6; dex : 6; int : 3;  at : 7; def : 7;
      exp : 5;
      flags : NOF or M_HAVEITEMS or M_OPEN;
    ),
    ( name1 : 'Огр'; name2 : 'Огра'; name3 : 'Огру'; name4 : 'Огром';
      char : 'o'; color : cBROWN; gender : genMALE;
      hp : 20; speed : 85; los : 5; st : 9; dex : 6; int : 2;  at : 10; def : 9;
      exp : 6;
      flags : NOF or M_HAVEITEMS or M_OPEN;
    ),
    ( name1 : 'Слепая Зверюга'; name2 : 'Слепую Зверюгу'; name3 : 'Слепой Зверюге'; name4 : 'Слепой Зверюгой';
      char : 'M'; color : cCYAN; gender : genFEMALE;
      hp : 70; speed : 50; los : 2; st : 15; dex : 6; int : 3;  at : 15; def : 11;
      exp : 14;
      flags : NOF or M_ALWAYSANSWERED;
    ),
    ( name1 : 'Пьяница'; name2 : 'Пьяницу'; name3 : 'Пьянице'; name4 : 'Пьяницой';
      char : 'h'; color : cBLUE; gender : genMALE;
      hp : 17; speed : 40; los : 4; st : 5; dex : 4; int : 4;  at : 6; def : 4;
      exp : 4;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Бармен'; name2 : 'Бармена'; name3 : 'Бармену'; name4 : 'Барменом';
      char : 'b'; color : cRED; gender : genMALE;
      hp : 40; speed : 100; los : 6; st : 5; dex : 5; int : 5;  at : 7; def : 7;
      exp : 12;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Убийственно пьяный мужик'; name2 : 'Убийственно пьяного мужика'; name3 : 'Убийственно пьяному мужику'; name4 : 'Убийственно пьяным мужиком';
      char : 'h'; color : cBLUE; gender : genMALE;
      hp : 5; speed : 20; los : 2; st : 3; dex : 2; int : 1; at : 1; def : 1;
      exp : 0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_FELLDOWN or M_HAVEITEMS;
    ),
    ( name1 : 'Целительница'; name2 : 'Целительницу'; name3 : 'Целительнице'; name4 : 'Целительницой';
      char : 'h'; color : cLIGHTGREEN; gender : genFEMALE;
      hp : 30; speed : 120; los : 6; st : 5; dex : 7; int : 9; at : 10; def : 10;
      exp : 10;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : 'Мясник'; name2 : 'Мясника'; name3 : 'Мяснику'; name4 : 'Мясником';
      char : '@'; color : cRED; gender : genMALE;
      hp : 35; speed : 100; los : 5; st : 9; dex : 5; int : 4; at : 20; def : 15;
      exp : 20;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
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

var
  nx, ny : byte;

procedure CreateMonster(n,px,py : byte);   // Создать монстра
function RandomMonster(x,y : byte) : byte; // Создать случайного монстра
procedure MonstersTurn;                    // У каждого монстра есть право на ход

implementation

uses
  Map, Player, Special;

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
    end;
  end;
end;

{ Создать случайного монстра }
function RandomMonster(x,y : byte) : byte;
begin
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
    begin
      if M.MonL[i].hp <= 0 then M.MonL[i].Death else M.MonL[i].doturn;
    end;
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
      if (aimx > 0) and (aimy > 0) then
      begin
        // Двигаться к цели
        if MoveToAim(false) = false then
          if MoveToAim(true) = false then
            if Random(10) <= 8 then
              MoveRandom;
      end else
        MoveRandom;
    end else
      MoveRandom;
    energy := energy - speed + (speed - pc.speed);
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
  {Find the way}
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
  Move(nx+((Random(3)-1)),ny+((Random(3)-1)));
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
            Fight(pc) else
              Fight(M.MonL[aim]);
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
        r := 'ужасно ранен' + HeSheIt(id, 1);
      end else
        if hp <= Round(Rhp / 3) then
        begin
          r := 'тяжело ранен' + HeSheIt(id, 1);
        end else
          if hp <= Round(Rhp / 2) then
          begin
            r := 'полумёртв' + HeSheIt(id, 1);
          end else
            if hp <= Round(Rhp / 4)*3 then
            begin
              r := 'легко ранен' + HeSheIt(id, 1);
            end else
              r :=  'в легкую задет' + HeSheIt(id, 1);
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
      s := MonstersData[id].name1 + ' говорит: ';
      case id of
        mdMALECITIZEN, mdFEMALECITIZEN:
        begin
          case Random(4)+1 of
            1 : if pc.name = name then
                  s := '"Тебя зовут '+pc.name+'? И меня так же!"' else
                    s := s + '"Меня зовут '+name+'. Рад'+HeSheIt(id,1)+' познакомится с тобой, '+pc.name+'!"';
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
              AddMsg('Ты подошел к '+MonstersData[id].name3+' и представился.');
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
                1 : s := s + '"Ну как? Ты еще не исследовал хранилище? Как жаль!"';
                2 : s := s + '"Пожалуйста, '+pc.name+',поторопись! Люди в опасности!"';
                3 : s := s + '"Мы все надеемся на тебя, '+pc.name+'!"';
              end;{case}
            end;
            2 : // Выполнил!
            begin
              w := FALSE;
              AddMsg('Ты подошел к '+MonstersData[id].name3+' и рассказал о своем приключении в хранилище.');
              More;
              AddMsg('Он очень удивился твоему рассказу, но, кажется, не особо тебе поверил...');
              More;
              AddMsg('Тебе нужно дать ему какие-нибудь доказательства!');
            end;
            3 : // Дал доказательство!
            begin
              AddMsg(MonstersData[id].name3+' , пожав тебе руку, сказал:');
              More;
              AddMsg('"Ты не представляешь, как я тебе благодарен! Ты избавил нас от этого кошмара!"');
              More;
              AddMsg('"Вот, возьми эти деньги, в следующих версиях я может быть дам тебе что-то более весомое :)"');
              More;
              AddMsg('Ты взял золотые монеты и положил их в карман.');
              pc.PickUp(CreateItem(idCOIN, 500), FALSE);
              pc.quest[1] := 4;
            end;
            4 : // Выолнен квест
            case Random(3)+1 of
              1 : s := s + '"Надеюсь тебе нравится наш Эвилиар. Чувствуй себя как дома!"';
              2 : s := s + '"Хорошо, что все спокойно!"';
              3 : s := s + '"Из тебя выйдет настоящий герой!"';
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
        mdBARTENDER:
        begin
          w := False;
          if (Ask(MonstersData[id].name1 + ' говорит: "Могу предложить бутылёк свежего пивасика всего за 15 золотых, хочешь?" [(Y/n)]')) then
          begin
            if pc.FindCoins = 0 then
              AddMsg('К сожалению, у тебя совсем нет денег.') else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('У тебя недостаточно золотых монет для покупки.') else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('Ты протягиваешь '+MonstersData[id].name3+' деньги.');
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  More;
                  AddMsg('Он их пересчитывает и протягивает бутылку холодного пива.');
                  if pc.PickUp(CreateItem(idCHEAPBEER, 1), FALSE) <> 0 then
                  begin
                    AddMsg('Оно упало на пол.');
                    PutItem(pc.x,pc.y, CreateItem(idMEAT, 1));
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
            if (Ask(MonstersData[id].name1 + ' говорит: "Хочешь я подлечу тебя?" [(Y/n)]')) then
            begin
              p := Round((pc.RHp - pc.Hp) * 1.5);
              if (Ask('Твое полное исцеление будет стоить {'+IntToStr(p)+'} золотых. Согласен?" [(Y/n)]')) then
              begin
                if pc.FindCoins = 0 then
                  AddMsg('К сожалению, у тебя совсем нет денег.') else
                  if pc.inv[pc.FindCoins].amount < p then
                    AddMsg('У тебя недостаточно золотых монет для полного исцеления.') else
                    if pc.inv[pc.FindCoins].amount >= p then
                    begin
                      AddMsg('Ты протягиваешь '+MonstersData[id].name3+' деньги.');
                      dec(pc.inv[pc.FindCoins].amount, p);
                      More;
                      AddMsg('Она быстренько пересчитывает и прячет их. После этого она протягивает обе руки к твоей голове... ');
                      More;
                      AddMsg('На секунду ты теряешь сознание, но, когда приходишь в себя, чувствуешь себя великолепно!');
                      pc.Hp := pc.RHp;
                    end;
              end;
            end else
              AddMsg('"Не хочешь - как хочешь..."');
          end else
            AddMsg(MonstersData[id].name1 + ' говорит: "Здравствуй, '+pc.name+'! Меня зовут '+name+'. Если тебя ранят - заходи ко мне, я смогу тебе помочь."');
        end;
        mdMEATMAN:
        begin
          w := False;
          if (Ask(MonstersData[id].name1 + ' говорит: "Хочешь купить кусок отличного свежего мяса всего за 15 золотых?" [(Y/n)]')) then
          begin
            if pc.FindCoins = 0 then
              AddMsg('К сожалению, у тебя совсем нет денег.') else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('У тебя недостаточно золотых монет для покупки.') else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('Ты протягиваешь '+MonstersData[id].name3+' деньги.');
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  More;
                  AddMsg('Он их пересчитывает и отдает кусок мяса.');
                  if pc.PickUp(CreateItem(idMEAT, 1), FALSE) <> 0 then
                  begin
                    AddMsg('Оно упало на пол.');
                    PutItem(pc.x,pc.y, CreateItem(idMEAT, 1));
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
procedure TMonster.Fight(var Victim : TMonster);
var
  i : byte;
  dam : integer;
begin
  if M.MonP[Victim.x, victim.y] > 0 then
  begin
    // Атаковать враждебного
    if ((Victim.relation = 1) and (id = 1)) or (id > 1)  then
    begin
      if Random(dex)+1 > Random(Victim.dex)+1 then
      begin
        // Щит
        if (Victim.eq[7].id > 0) and (Random(Victim.dex)+1 = 1) then
          AddMsg(MonstersData[Victim.id].name1+' блокировал'+HeSheIt(Victim.id,1)+' атаку своим щитом!')
        else
          begin
            if Eq[6].id > 0 then
              Dam := Random(Round(ItemsData[Eq[6].id].attack+(st/4)))+1 else
                Dam := Random(attack)+1;
            Dam := (Dam + Round(st/4)) - Random(Round(Victim.defense/(Random(2)+1)));
            if Dam <= 0 then // Попал, но не пробил
              AddMsg(MonstersData[id].name1+' попал'+HeSheIt(id,1)+' по '+MonstersData[Victim.id].name3+', но не пробил'+HeSheIt(id,1)+' броню.') else
                begin
                  Victim.hp := Victim.hp - Dam;
                  Victim.BloodStreem( -(x - Victim.x), -(y - Victim.y));
                  if Victim.hp > 0 then
                  begin
                    AddMsg(MonstersData[id].name1+' попал'+HeSheIt(id,1)+' по '+MonstersData[Victim.id].name3+'! (<'+IntToStr(Dam)+'>)');
                    if id = 1 then
                      AddMsg(MonstersData[Victim.id].name1+' '+Victim.WoundDescription+'.');
                  end else
                    begin
                      AddMsg('<'+MonstersData[id].name1+' убил'+HeSheIt(id,1)+' '+MonstersData[Victim.id].name2+'!>');
                      M.MonP[Victim.x, victim.y] := 0;
                      if id = 1 then
                      begin
                        inc(pc.exp, MonstersData[Victim.id].exp);
                        if pc.exp >= pc.ExpToNxtLvl then
                          pc.GainLevel;
                        if Victim.id = mdBLINDBEAST then
                        begin
                          AddMsg('[Ты выполнил квест!!!]');
                          pc.quest[1] := 2;
                          More;
                        end;
                      end;
                    end;
                end;
          end;
      end else
        begin
          AddMsg(MonstersData[id].name1+' промахнул'+HeSheIt(id,2)+' по '+MonstersData[Victim.id].name3+'.');
        end;
    end;
    // Атаковать нейтрального
    if  (id = 1) and (Victim.relation = 0)then
    begin
      if Ask('Точно напасть на '+MonstersData[Victim.id].name2+'? [(Y/n)]') then
      begin
        AddMsg('Ты неожиданно напал на '+MonstersData[Victim.id].name2+'!');
        if Victim.id = mdBREAKMT then
        begin
          More;
          AddMsg('<Ты почувствовал, что пол под твоими ногами развергся...>');
          More;
          AddMsg('<И ты проваливаешься вниз!>');
          More;
          Hell666You;
          pc.turn := 2;
        end else
          begin
            Victim.relation := 1; // Агрессия!
            AddMsg(MonstersData[Victim.id].name1+' в ярости!');
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
              AddMsg('Что ты наделал! Теперь вся деревня против тебя!');
              More;
              Fight(Victim);
            end;
          end;
      end else
        AddMsg('Ты немного подумал и решил этого не делать.');
    end;
  end else
    AddMsg('Но здесь никого нет!');
end;

{ Отдать вещь }
procedure TMonster.GiveItem(var Victim : TMonster; var GivenItem : TItem);
begin
  if ((Victim.relation = 0) and (id = 1)) or (id > 1) then
  begin
    if Ask('Точно отдать '+ItemsData[GivenItem.id].name3+' '+MonstersData[Victim.id].name3+'? [(Y/n)]') then
    begin
      // 0-успешно,1-ничего нет,2-нет места,3-перегружен
      case Victim.PickUp(GivenItem, FALSE) of
        0 :
        begin // Успешно отдал
          if GivenItem.amount = 1 then
            AddMsg(MonstersData[id].name1+' отдал'+HeSheIt(id,1)+' '+MonstersData[Victim.id].name3+' '+ItemsData[GivenItem.id].name3+'.') else
              AddMsg(MonstersData[id].name1+' отдал'+HeSheIt(id,1)+' '+MonstersData[Victim.id].name3+' '+ItemsData[GivenItem.id].name2+' ('+IntToStr(GivenItem.amount)+' шт.)');
          // Отдал башку старейшине
          if GivenItem.id = idBLINDBEASTHEAD then
            if pc.quest[1] > 1 then
              pc.quest[1] := 3;
          DeleteInvItem(GivenItem, TRUE);
          RefreshInventory;
        end;
        1 : AddMsg(MonstersData[id].name1+' отдал'+HeSheIt(id,1)+' '+MonstersData[Victim.id].name3+' глюк!');
        2 : AddMsg(MonstersData[Victim.id].name1+' уже несет очень много вещей!');
        3 : AddMsg(MonstersData[Victim.id].name1+' перегружен'+HeSheIt(id,1)+' вещами!');
      end;
    end else
      AddMsg('Немного подумав, ты решил этого не делать.');
  end else
    AddMsg('Кажется, это не совсем уместно...');
end;

{ Умереть }
procedure TMonster.Death;
begin
  // Удалить указатель
  M.MonP[x,y] := 0;
  // Выкинуть вещи

  // Если это герой, то
  if id = 1 then
  begin
    id := 0;
    PutItem(x,y,CreateItem(idCORPSE, 1));
    pc.AfterDeath;
  end else
    begin
      if id = mdBLINDBEAST then
        PutItem(x,y,CreateItem(idBLINDBEASTHEAD, 1)) else
          if Random(5)+1 = 1 then
            PutItem(x,y,CreateItem(idCORPSE, 1));
      // Монстра больше нет
      id := 0;
    end;
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
          if Inv[i].id = Item.id then
          begin
            inc(Inv[i].amount, Item.amount);
            f := TRUE;
            break;
          end;
        if f = false then
          for i:=1 to MaxHandle do
            if Inv[i].id = 0 then
            begin
              if (invmass + (ItemsData[Item.id].mass*Item.amount) < MaxMass) or (FromEq) then
              begin
                Inv[i] := Item;
                invmass := invmass + (ItemsData[Item.id].mass*Item.amount);
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
  invmass := invmass - (ItemsData[I.id].mass*I.amount);
  if (I.amount > 1) and (not full) then
    dec(I.amount) else
      I.id := 0;
  RefreshInventory;
end;

{ Перебрать инвентарь }
procedure TMonster.RefreshInventory;
var
  i : byte;
begin
  for i:=1 to MaxHandle-1 do
    if inv[i].id = 0 then
    begin
      inv[i] := inv[i+1];
      inv[i+1].id := 0;
    end;
end;

end.
