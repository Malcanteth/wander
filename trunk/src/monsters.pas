unit monsters;

interface

uses
  Utils, Cons, Tile, Flags, Msg, Items, SysUtils, Ability, Windows, Main, Conf;

type
  TMonster = object
    id              : byte;
    idinlist        : byte;
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
    inv             : array[1..MaxHandle] of TItem;// Предметы монстра
    invmass         : real;                        // Масса инвентаря и экипировки
    //Атрибуты
    Rstr,str,                                      //сила
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
    //Оружейные навыки
    closefight      : array[1..CLOSEFIGHTAMOUNT] of real;
    farfight        : array[1..FARFIGHTAMOUNT] of real;
    magicfight      : array[1..MAGICSCHOOLAMOUNT] of real;
    //
    atr             : array[1..2] of byte;             // Приоритетные атрибуты
    //
    status          : array[1..2] of integer;         // Счетчики (1-Голод)


    procedure ClearMonster;                           // Очистить
    function Replace(nx, ny : integer) : byte;        // Попытаться передвинуться
    procedure DoTurn;                                 // AI
    function DoYouSeeThis(ax,ay : byte) : boolean;    // Видит ли монстр точку
    function MoveToAim(obstacle : boolean) : boolean; // Сделать шаг к цели
    procedure MoveRandom;                             // Двинуться рандомно
    function Move(dx,dy : integer) : boolean;         // Переместить монстра
    function WoundDescription : string;               // Вернуть описание состояния здоровья
    procedure TalkToMe;                               // Поговорить с кем-нибудь
    procedure Fight(var Victim : TMonster; CA : byte);// Драться (CA: 1 - контратака, 2 - второй удар!)
    procedure Fire(var Victim : TMonster);            // Стрелять
    procedure AttackNeutral(Victim : TMonster);       // Атаковать нейтрального
    procedure KillSomeOne(Victim : byte);             // Действия после убийства
    procedure Death;                                  // Умереть
    procedure GiveItem(var Victim : TMonster;
                                 var GivenItem : TItem); // Отдать вещь
    procedure BloodStreem(dx,dy : shortint);
    function PickUp(Item : TItem;FromEq : boolean;
                             amount : integer) : byte;// Поместить вещь в инвентарь (0-успешно,1-ничего нет,2-нет места,3-перегружен
    function MaxMass : real;
    procedure DeleteInvItem(var I : TItem;
                      amount : integer);              // Удалить предмет из инвентаря
    procedure RefreshInventory;                       // Перебрать инвентарь
    function ColorOfTactic: longword;                 // Вернуть цвет заднего фона монстра при использовании тактики
    function TacticEffect(situation : byte) : real;   // Вернуть множитель (0.5, 1 или 2 - эффект от тактики)
    function EquipItem(Item : TItem) : byte;          // Снарядить предмет (0-успешно,1-ячейка занята)
    function ExStatus(situation : byte) : string;     // Вернуть описание состояние монстра (одержимый, проклятый и тд)
    function FullName(situation : byte;
                   writename : boolean) : string;     // Вернуть полное имя монстра
    procedure DecArrows;                              // Минус стрела
    function WhatClass : byte;                        // Класс
    function ClName(situation : byte) : string;       // Вернуть название класса
    procedure PrepareSkills;                          // Раставить очки умений и экипировать в зависимости от класса
    procedure FavWPNSkill;                            // Исходя из любимых оружейных навыков - их прокачать и дать соотв. оружие
    function BestWPNCL : byte;                        // Самый прокаченный навык в ближ. бою
    function HowManyBestWPNCL : byte;                 // Сколько одинаковопрокаченных в ближ. бою
    function OneOfTheBestWPNCL(i : byte): boolean;    // Один из лучше прок. навыков
    function BestWPNFR : byte;                        // Самый прокаченный навык в дальнем бою
    function HowManyBestWPNFR : byte;                 // Сколько одинаковопрокаченных в дальнем бою
    function OneOfTheBestWPNFR(i : byte): boolean;    // Один из лучше прок. навыков
    function ClassColor : longword;                   // Цвет класса
  end;

  TMonData = record
    name1, name2, name3, name4, name5, name6 : string[40];  // Названия (1Кто,2Кого,3Кому,4Кем,5Чей,6Чьи)
    char                       : string[1];       // Символ
    color                      : byte;            // Цвет
    gender                     : byte;
    hp                         : word;            // Здоровье
    speed                      : word;            // Скорость
    los                        : byte;            // Длина зрения
    str, dex, int, at, def     : byte;
    exp                        : byte;
    mass                       : real;
    coollevel                  : byte;
    flags                      : longlong;        // Флажки
  end;

  TMonClass = record
    name1m, name2m, name3m, name4m, name5m, name6m : string[40];  // Названия класса (1Кто,2Кого,3Кому,4Кем,5Чей,6Чьи) (муж.)
    name1f, name2f, name3f, name4f, name5f, name6f : string[40];  // Названия класса (1Кто,2Кого,3Кому,4Кем,5Чей,6Чьи) (жен.)
  end;

const
  { Константы количества монстров }
  MonstersAmount = 23;

  {  Описание монстров }
  MonstersData : array[1..MonstersAmount] of TMonData =
  (
    ( name1 : 'Ты'; name2 : 'Тебя'; name3 : 'Тебе'; name4 : 'Тобой'; name5 : 'Тебя';
      char : '@'; color : crLIGHTBLUE; gender : 10;
      flags : NOF or M_NEUTRAL or M_CLASS;
    ),
    ( name1 : 'Житель'; name2 : 'Жителя'; name3 : 'Жителю'; name4 : 'Жителем'; name5 : 'Жителя'; name6 : 'Жителей';
      char : 'h'; color : crBROWN; gender : genMALE;
      hp : 30; speed : 100; los : 6; str : 5; dex : 5; int : 3; at : 7; def : 7;
      exp : 5; mass : 60.4;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Жительница'; name2 : 'Жительницу'; name3 : 'Жительнице'; name4 : 'Жительницей'; name5 : 'Жительницы'; name6 : 'Жительниц';
      char : 'h'; color : crLIGHTRED; gender : genFEMALE;
      hp : 18; speed : 100; los : 6; str : 3; dex : 6; int : 4;  at : 4; def : 5;
      exp : 3; mass : 40.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Старейшина'; name2 : 'Старейшину'; name3 : 'Старейшине'; name4 : 'Старейшиной'; name5 : 'Старейшины'; name6 : 'Старейшин';
      char : 't'; color : crYELLOW; gender : genMALE;
      hp : 45; speed : 110; los : 6; str : 7; dex : 5; int : 7; at : 19; def : 20;
      exp : 15; mass : 55.3;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS  or M_TACTIC;
    ),
    ( name1 : 'Автор'; name2 : 'Автора'; name3 : 'Автору'; name4 : 'Автором'; name5 : 'Автора'; name6 : 'Авторов';
      char : 'P'; color : crRANDOM; gender : genMALE;
      hp : 666; speed : 200; los : 8; str : 99; dex : 99; int : 99;  at : 25; def : 50;
      exp : 255; mass : 58.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Крыса'; name2 : 'Крысу'; name3 : 'Крысе'; name4 : 'Крысой'; name5 : 'Крысы'; name6 : 'Крыс';
      char : 'r'; color : crBROWN; gender : genFEMALE;
      hp : 8; speed : 160; los : 5; str : 2; dex : 6; int : 1;  at : 2; def : 1;
      exp : 2; mass : 8.3; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Летучая Мышь'; name2 : 'Летучую Мышь'; name3 : 'Летучей Мыши'; name4 : 'Летучей Мышью'; name5 : 'Летучей Мыши'; name6 : 'Летучих Мышей';
      char : 'B'; color : crGRAY; gender : genFEMALE;
      hp : 6; speed : 220; los : 7; str : 3; dex : 8; int : 1;  at : 1; def : 2;
      exp : 4; mass : 6.8; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Паук'; name2 : 'Паука'; name3 : 'Пауку'; name4 : 'Пауком'; name5 : 'Паука'; name6 : 'Пауков';
      char : 's'; color : crWHITE; gender : genMALE;
      hp : 7; speed : 180; los : 5; str : 2; dex : 8; int : 1;  at : 2; def : 1;
      exp : 2; mass : 0.9; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Гоблин'; name2 : 'Гоблина'; name3 : 'Гоблину'; name4 : 'Гоблином'; name5 : 'Гоблина'; name6 : 'Гоблинов';
      char : 'g'; color : crGREEN; gender : genMALE;
      hp : 13; speed : 115; los : 6; str : 5; dex : 7; int : 2;  at : 5; def : 5;
      exp : 4; mass : 30.5; coollevel : 2;
      flags : NOF or M_HAVEITEMS or M_OPEN or M_TACTIC or M_CLASS;
    ),
    ( name1 : 'Орк'; name2 : 'Орка'; name3 : 'Орку'; name4 : 'Орком'; name5 : 'Орка'; name6 : 'Орков';
      char : 'o'; color : crLIGHTGREEN; gender : genMALE;
      hp : 15; speed : 105; los : 6; str : 6; dex : 6; int : 3;  at : 7; def : 7;
      exp : 5; mass : 55.0; coollevel : 3;
      flags : NOF or M_HAVEITEMS or M_OPEN or M_TACTIC or M_CLASS;
    ),
    ( name1 : 'Огр'; name2 : 'Огра'; name3 : 'Огру'; name4 : 'Огром'; name5 : 'Огра'; name6 : 'Огров';
      char : 'o'; color : crBROWN; gender : genMALE;
      hp : 20; speed : 85; los : 5; str : 9; dex : 6; int : 2;  at : 10; def : 9;
      exp : 6; mass : 70.9; coollevel : 4;
      flags : NOF or M_HAVEITEMS or M_OPEN or M_TACTIC or M_CLASS;
    ),
    ( name1 : 'Слепая Зверюга'; name2 : 'Слепую Зверюгу'; name3 : 'Слепой Зверюге'; name4 : 'Слепой Зверюгой'; name5 : 'Слепой Зверюги'; name6 : 'Слепых Зверюг';
      char : 'M'; color : crCYAN; gender : genFEMALE;
      hp : 70; speed : 70; los : 2; str : 15; dex : 6; int : 3;  at : 15; def : 11;
      exp : 14; mass : 85.0; coollevel : 5;
      flags : NOF or M_ALWAYSANSWERED or M_TACTIC;
    ),
    ( name1 : 'Пьяница'; name2 : 'Пьяницу'; name3 : 'Пьянице'; name4 : 'Пьяницой'; name5 : 'Пьяницы'; name6 : 'Пьяниц';
      char : 'h'; color : crBLUE; gender : genMALE;
      hp : 17; speed : 40; los : 4; str : 5; dex : 4; int : 4;  at : 6; def : 4;
      exp : 4; mass : 40.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Бармен'; name2 : 'Бармена'; name3 : 'Бармену'; name4 : 'Барменом'; name5 : 'Бармена'; name6 : 'Барменов';
      char : 'b'; color : crRED; gender : genMALE;
      hp : 40; speed : 100; los : 6; str : 5; dex : 5; int : 5;  at : 7; def : 7;
      exp : 12; mass : 60.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Убийственно пьяный мужик'; name2 : 'Убийственно пьяного мужика'; name3 : 'Убийственно пьяному мужику'; name4 : 'Убийственно пьяным мужиком'; name5 : 'Убийственно пьяного мужика'; name6 : 'Убийственно пьяных мужиков';
      char : 'h'; color : crBLUE; gender : genMALE;
      hp : 5; speed : 20; los : 2; str : 3; dex : 2; int : 1; at : 1; def : 1;
      exp : 0; mass : 35.7;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_DRUNK or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Целительница'; name2 : 'Целительницу'; name3 : 'Целительнице'; name4 : 'Целительницой'; name5 : 'Целительницы'; name6 : 'Целительниц';
      char : 'h'; color : crLIGHTGREEN; gender : genFEMALE;
      hp : 30; speed : 120; los : 6; str : 5; dex : 7; int : 9; at : 10; def : 10;
      exp : 10; mass : 45.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Мясник'; name2 : 'Мясника'; name3 : 'Мяснику'; name4 : 'Мясником'; name5 : 'Мясника';  name6 : 'Мясников';
      char : '@'; color : crRED; gender : genMALE;
      hp : 35; speed : 100; los : 5; str : 9; dex : 5; int : 4; at : 20; def : 15;
      exp : 20; mass : 67.2;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Таракан'; name2 : 'Таракана'; name3 : 'Таракану'; name4 : 'Тараканом'; name5 : 'Таракана'; name6 : 'Тараканов';
      char : 'c'; color : crORANGE; gender : genMALE;
      hp :7; speed : 130; los : 6; str : 1; dex : 7; int : 1;  at : 1; def : 2;
      exp : 1; mass : 1; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Мелкий червь'; name2 : 'Мелкого червя'; name3 : 'Мелкому червю'; name4 : 'Мелким червем'; name5 : 'Мелкого червя'; name6 : 'Мелких червей';
      char : 'w'; color : crYELLOW; gender : genMALE;
      hp : 8; speed : 90; los : 5; str : 2; dex : 7; int : 1;  at : 2; def : 3;
      exp : 2; mass : 2.5; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : 'Торговец'; name2 : 'Торговца'; name3 : 'Торговцу'; name4 : 'Торговцем'; name5 : 'Тогровца';  name6 : 'Торговцев';
      char : '@'; color : crORANGE; gender : genMALE;
      hp : 30; speed : 110; los : 6; str : 7; dex : 7; int : 6; at : 15; def : 18;
      exp : 18; mass : 63.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Фанатик'; name2 : 'Фанатика'; name3 : 'Фанатику'; name4 : 'Фанатиком'; name5 : 'Фанатика'; name6 : 'Фанатиков';
      char : 'f'; color : crPURPLE; gender : genMALE;
      hp : 30; speed : 115; los : 6; str : 6; dex : 6; int : 5; at : 8; def : 8;
      exp : 8; mass : 55.0; coollevel : 4;
      flags : NOF or M_OPEN or M_NAME or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : 'Жена ключника'; name2 : 'Жену ключника'; name3 : 'Жене ключника'; name4 : 'Женой ключника'; name5 : 'Жены ключника'; name6 : 'Жён ключника';
      char : 'f'; color : crWHITE; gender : genFEMALE;
      hp : 20; speed : 90; los : 6; str : 3; dex : 6; int : 4;  at : 4; def : 5;
      exp : 5; mass : 45.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS or M_STAY or M_TACTIC;
    ),
    ( name1 : 'Ключник'; name2 : 'Ключника'; name3 : 'Ключнику'; name4 : 'Ключником'; name5 : 'Ключника'; name6 : 'Ключников';
      char : 'k'; color : crRED; gender : genMALE;
      hp : 35; speed : 100; los : 6; str : 6; dex : 6; int : 3;  at : 6; def : 9;
      exp : 12; mass : 60.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS or M_TACTIC;
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

  {Названия классов}
  MonsterClassNameAmount = 9;

  MonsterClassName : array[1..MonsterClassNameAmount] of TMonClass =
  (
    (name1m : 'Воин'; name2m : 'Воина'; name3m : 'Воину'; name4m : 'Воином'; name5m : 'Воина'; name6m : 'Воинов';
     name1f : 'Воительница'; name2f : 'Воительницу'; name3f : 'Воительнице'; name4f : 'Воительницой'; name5f : 'Воительницы'; name6f : 'Воительниц'),
    (name1m : 'Варвар'; name2m : 'Варвара'; name3m : 'Варвару'; name4m : 'Варваром'; name5m : 'Варвара'; name6m : 'Варваров';
     name1f : 'Амазонка'; name2f : 'Амазонку'; name3f : 'Амазонке'; name4f : 'Амазонкой'; name5f : 'Амазонки'; name6f : 'Амазонок'),
    (name1m : 'Паладин'; name2m : 'Паладина'; name3m : 'Паладину'; name4m : 'Паладином'; name5m : 'Паладина'; name6m : 'Паладинов';
     name1f : 'Паладин'; name2f : 'Паладина'; name3f : 'Паладину'; name4f : 'Паладином'; name5f : 'Паладина'; name6f : 'Паладинов'),
    (name1m : 'Странник'; name2m : 'Странника'; name3m : 'Страннику'; name4m : 'Странником'; name5m : 'Странника'; name6m : 'Странников';
     name1f : 'Странница'; name2f : 'Странницу'; name3f : 'Страннице'; name4f : 'Странницой'; name5f : 'Странницы'; name6f : 'Странниц'),
    (name1m : 'Воришка'; name2m : 'Воришку'; name3m : 'Воришке'; name4m : 'Воришкой'; name5m : 'Воришки'; name6m : 'Воришек';
     name1f : 'Воришка'; name2f : 'Воришку'; name3f : 'Воришке'; name4f : 'Воришкой'; name5f : 'Воришки'; name6f : 'Воришек'),
    (name1m : 'Монах'; name2m : 'Монаха'; name3m : 'Монаху'; name4m : 'Монахом'; name5m : 'Монаха'; name6m : 'Монахов';
     name1f : 'Монахиня'; name2f : 'Монахиню'; name3f : 'Монахине'; name4f : 'Монахиней'; name5f : 'Монахини'; name6f : 'Монахинь'),
    (name1m : 'Жрец'; name2m : 'Жреца'; name3m : 'Жрецу'; name4m : 'Жрецом'; name5m : 'Жреца'; name6m : 'Жрецов';
     name1f : 'Жрица'; name2f : 'Жрицу'; name3f : 'Жрице'; name4f : 'Жрицей'; name5f : 'Жрицы'; name6f : 'Жриц'),
    (name1m : 'Колдун'; name2m : 'Колдуна'; name3m : 'Колдуну'; name4m : 'Колдуном'; name5m : 'Колдуна'; name6m : 'Колдунов';
     name1f : 'Колдунья'; name2f : 'Колдунью'; name3f : 'Колдунье'; name4f : 'Колдуньей'; name5f : 'Колдуньи'; name6f : 'Колдуний'),
    (name1m : 'Мыслитель'; name2m : 'Мыслителя'; name3m : 'Мыслителю'; name4m : 'Мыслителем'; name5m : 'Мыслителя'; name6m : 'Мыслителей';
     name1f : 'Мыслительница'; name2f : 'Мыслительницу'; name3f : 'Мыслительнице'; name4f : 'Мыслительницей'; name5f : 'Мыслительницы'; name6f : 'Мыслительниц')
  );

var
  nx, ny : byte;

procedure CreateMonster(n,px,py : byte);   // Создать монстра
procedure FillMonster(i,n,px,py : byte);
function RandomMonster(x,y : byte) : byte; // Создать случайного монстра
procedure MonstersTurn;                    // У каждого монстра есть право на ход

implementation

uses
  Map, Player, MapEditor, Script, Vars, SUtils, MBox, Liquid;

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
    FillMonster(i,n,px,py);
  end;
end;

// Наполнить монстра
procedure FillMonster(i,n,px,py : byte);
begin
  with M.MonL[i] do
  begin
    id := n;
    idinlist := i;
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
    if IsFlag(MonstersData[id].flags, M_DRUNK) then
      felldown := TRUE else
        felldown := FALSE;
    Rhp := MonstersData[id].hp;
    hp := Rhp;
    Rspeed := MonstersData[id].speed;
    speed := Rspeed;
    Rlos := MonstersData[id].los;
    los := Rlos;
    Rstr := MonstersData[id].str;
    str := Rstr;
    Rdex := MonstersData[id].dex;
    dex := Rdex;
    Rint := MonstersData[id].int;
    int := Rint;
    attack := MonstersData[id].at;
    defense := MonstersData[id].def;
    // Определить класс
    if IsFlag(MonstersData[id].flags, M_CLASS) then
    begin
      atr[1] := Rand(1,3);
      atr[2] := Rand(1,3);
      PrepareSkills;
      FavWPNSkill;
    end else
      begin
        // Оружейные навыки
        if eq[6].id = 0 then
        begin
          closefight[CLOSE_ARM] := (Rint*10) + Random(60);
          if closefight[CLOSE_ARM] > 100 then closefight[CLOSE_ARM] := 100;
        end else
          begin
            closefight[ItemsData[eq[6].id].kind] := (Rint*10) + Random(60);
            if closefight[ItemsData[eq[6].id].kind] > 100 then closefight[CLOSE_ARM] := 100;
          end;
      end;
    // Тактика
    tactic := 0;
    if IsFlag(MonstersData[id].flags, M_TACTIC) then
      if Random(5)+1 = 1 then
        tactic := Random(2)+1;
    // Какие-то уникальные вещи (не забывать, что некоторые генеряться при определении класса!
    if IsFlag(MonstersData[id].flags, M_HAVEITEMS) then
    begin
      // Экипировка
      // Инвентарь
      if id = mdKEYMAN then
      begin
        // Дать ему ключ
        PickUp(CreateItem(idGATESKEY, 1, 0), FALSE,1);
      end;
    end
  end;
end;

{ Создать случайного монстра }
function RandomMonster(x,y : byte) : byte;
begin
  Result := 2;
end;

{ Очистить }
procedure TMonster.ClearMonster;
begin
  id := 0;
  idinlist := 0;
  name := '';
  x := 0;
  y := 0;
  aim := 0;
  aimx := 0;
  aimy := 0;
  energy := 0;
  hp := 0;
  Rhp := 0;
  mp := 0;
  Rmp := 0;
  speed := 0;
  Rspeed := 0;
  los := 0;
  Rlos := 0;
  relation := 0;
  fillchar(eq,sizeof(eq),0);
  fillchar(inv,sizeof(inv),0);
  invmass := 0;
  str := 0;
  Rstr := 0;
  dex := 0;
  Rdex := 0;
  int := 0;
  Rint := 0;
  attack := 0;
  defense := 0;
  todmg := 0;
  todef := 0;
  felldown := FALSE;
  fillchar(ability,sizeof(ability),0);
  tactic := 0;
  fillchar(closefight,sizeof(closefight),0);
  fillchar(farfight,sizeof(farfight),0);
  fillchar(magicfight,sizeof(magicfight),0);
  fillchar(atr,sizeof(atr),0);
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
    begin
      if NOT IsFlag(MonstersData[id].flags, M_DRUNK) then
        FellDown := False;
    end else
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
           // if (M.MonL[M.MonP[AimX,AimY]].id > 0) then
            begin
              // Двигаться к цели
              if MoveToAim(false) = false then
                if MoveToAim(true) = false then
                  if Random(10) <= 8 then
                    MoveRandom;
            end;
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
        r := 'ужасно ранен{/a}';
      end else
        if hp <= Round(Rhp / 3) then
        begin
          r := 'тяжело ранен{/a}';
        end else
          if hp <= Round(Rhp / 2) then
          begin
            r := 'полумертв{/a}';
          end else
            if hp <= Round(Rhp / 4)*3 then
            begin
              r := 'легко ранен{/a}';
            end else
              r :=  'влегкую задет{/a}';
  Result := GetMsg(r,MonstersData[id].gender);
end;

{ Поговорить с кем-нибудь }
procedure TMonster.TalkToMe;
var
  s : string;
  w : boolean;
  p : integer;
  i: byte;
begin
  if relation = 0 then
  begin
    // Переменные для работы скрипта
    for i := 1 to QuestsAmount do V.SetInt('PCQuest'+IntToStr(I)+'State', pc.quest[I]); // Состояние квестов
    V.SetStr('NPCWeaponName', ItemsData[eq[6].id].name1);
    V.SetStr('PCName', PC.Name);
    V.SetStr('NPCName', Name);    // Имя монстра
    V.SetInt('NPCID', ID);        // Идентификатор монстра
    w := TRUE;
    s := FullName(1, TRUE) + ' говорит: ';
    case id of
        mdMALECITIZEN, mdFEMALECITIZEN: // Жители деревушки
        begin
          // Выполняем скрипт
          Run('NPCTalk.pas');
          // Сохраняем результат
          S := S + V.GetStr('TalkStr');
        end;
        mdELDER: // Старейшина
        begin
          // Если оба квеста от старейшины выполнены
          if (pc.quest[1] = 4) and (pc.quest[2] = 4) then
            s := s + '"Ох... дела.. дела. Надеюсь, у тебя все в порядке..."' else
          case pc.quest[1] of
            0 :
            begin
              w := FALSE;
              AddMsg('Ты представил{ся/ась} '+MonstersData[id].name3+'.',0);
              More;
              AddMsg(MonstersData[id].name1 + ' говорит: "Здравствуй, '+pc.name+'! Меня зовут '+name+'. Я старейшина Эвилиара и у меня есть к тебе просьба."',0);
              More;
              AddMsg('"Понимаешь, в Эвилиаре есть хранилище в котором все наши жители держат свои запасы продовольствия. Оно находится в северо-восточной части деревни и представляет собой всего один этаж под землёй."',0);
              More;
              AddMsg('"Две недели назад пара жителей спустилась в хранилище. Они хотели заменить старые несущие балки и раскинуть отраву для крыс. Но только спустившись вниз крысы ожесточились и начали кидаться на людей!"',0);
              More;
              AddMsg('"Более того, сквозь мрак жители увидели нескольких тварей, которые были агрессивно на них настроены! Бедняги говорили, что видели гоблинов и кобольда, но... я не особо им верю."',0);
              More;
              AddMsg('"Откуда им там взяться? В деревне их никто не видел... Уж не из под земли же они взялись! В любом случае - в хранилище теперь все боятся спускаться, запасы еды заканчиваются... Не знаю, что будет дальше!"',0);
              More;
              AddMsg('"Я очень прошу тебя - спустись в хранилище и избавь нас от этого ужаса!"',0);
              pc.quest[1] := 1;
            end;
            1 :
            begin
              case Random(3)+1 of
                1 : s := s + '"Ну как? Ты еще не исследовал{/а} хранилище? Как жаль!"';
                2 : s := s + '"Пожалуйста, '+pc.name+', поторопись! Люди в опасности!"';
                3 : s := s + '"Мы все надеемся на тебя, '+pc.name+'!"';
              end;{case}
            end;
            2 : // Выполнил!
            begin
              w := FALSE;
              AddMsg('Ты рассказал{/а} '+MonstersData[id].name3+' о своем приключении в хранилище.',0);
              More;
              AddMsg('Он очень удивился твоему рассказу, но, кажется, не особо тебе поверил...',0);
              More;
              AddMsg('Тебе нужно дать ему какие-нибудь доказательства!',0);
            end;
            3 : // Дал доказательство!
            begin
              w := FALSE;
              AddMsg(MonstersData[id].name3+', пожав тебе руку, сказал:',0);
              More;
              AddMsg('"Ты не представляешь, как я тебе благодарен! Ты избавил{/а} нас от этого кошмара!"',0);
              More;
              AddMsg('"Вот, возьми эти деньги! Надеюсь, они тебе помогут!"',0);
              More;
              AddMsg('Ты взял{/а} золотые монеты и положил{/а} их в карман.',0);
              pc.PickUp(CreateItem(idCOIN, 300, 0), FALSE,300);
              pc.quest[1] := 4;
              More;
              AddMsg('"Есть у меня еще одно дельце! Будешь заинтересован{/а} - обращайся!"',0);
              More;
            end;
            4 : // Выполнен квест №1
            begin
              // Квест № 2
              case pc.quest[2] of
                0 :
                begin
                  w := FALSE;
                  AddMsg(FullName(1, TRUE) + ' говорит: "Ну что, я вижу ты готов{/а} для нового задания. А дело вот в чем..."',0);
                  More;
                  AddMsg('"Не знаю заметил{/а} ты или нет, но восточный выход из деревни закрыт. Там стоят врата, которые закрыты на тяжелый замок."',0);
                  More;
                  AddMsg('"Сделано это было недавно по причине участившихся нападений и визитов нежеланных гостей..."',0);
                  More;
                  AddMsg('"Сейчас нам потребовалось открыть эти врата, что бы пустить торговцев с востока..."',0);
                  More;
                  AddMsg('"Но, будь он проклят, этот ключник куда-то пропал!"',0);
                  More;
                  AddMsg('"Где искать ключ от врат - ума не приложу!"',0);
                  More;
                  if Ask('"Ну что? Готов{/а} взяться за это дельце?"  [(Y/n)]') = 'Y' then
                  begin
                    AddMsg('"Отлично! Я рассчитываю на тебя!"',0);
                    pc.quest[2] := 1;
                    More;
                  end else
                    begin
                      AddMsg('"Очень жаль... Надеюсь, ты передумаешь в ближайшее время!"',0);
                      More;
                    end;
                end;
                // Взял квест...
                1 :
                begin
                  s := s + '"Ты еше не наш{ел/ла} ключ? Очень жаль..."';
                end;
                // Узнал кое-что о ключнике (убил его :)
                2 :
                begin
                  w := FALSE;
                  AddMsg(FullName(1, TRUE) + ' говорит: "О, боже... Это невероятно... Какая трагедия...."',0);
                  More;
                  AddMsg('"Я уже давно заметил, что наш ключник... как бы... сам не свой..."',0);
                  More;
                  AddMsg('"Невероятно..."',0);
                  More;
                  AddMsg('"Но... Был ли при нём ключ?"',0);
                  More;
                end;
                // Отдал ключ
                3 :
                begin
                  w := FALSE;
                  AddMsg(MonstersData[id].name3+', пожав тебе руку, сказал:',0);
                  More;
                  AddMsg('"И снова ты выручил{/а} всех жителей Эвилиара! Теперь можно наконец открыть восточные врата!"',0);
                  More;
                  AddMsg('"Вот, возьми эти деньги! Ничего более оригинального я не придумал, но когда-нибудь я дам тебе что-то более весомое!"',0);
                  More;
                  AddMsg('Ты взял{/а} золотые монеты и положил{/а} их в карман.',0);
                  pc.PickUp(CreateItem(idCOIN, 500, 0), FALSE,500);
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
          // Выполняем скрипт
          Run('NPCTalk.pas');
          // Сохраняем результат
          S := S + V.GetStr('TalkStr');
        end;
        mdKEYWIFE:
        begin
          // Выполняем скрипт
          Run('NPCTalk.pas');
          // Сохраняем результат
          S := S + V.GetStr('TalkStr');
        end;
        mdBARTENDER:
        begin
          w := False;
          if (Ask(FullName(1, TRUE) + ' говорит: "Могу предложить бутылёк свежего пивасика всего за 15 золотых, хочешь?" #(Y/n)#')) = 'Y' then
          begin
            if pc.FindCoins = 0 then
              AddMsg('К сожалению, у тебя совсем нет денег.',0) else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('У тебя недостаточно золотых монет для покупки.',0) else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('Ты протягиваешь '+FullName(3, FALSE)+' деньги.',0);
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  pc.RefreshInventory;
                  More;
                  AddMsg('Он их пересчитывает и протягивает бутылку холодного пива.',0);
                  if pc.PickUp(CreatePotion(lqCHEAPBEER, 1), FALSE,1) <> 0 then
                  begin
                    AddMsg('Оно упало на пол.',0);
                    PutItem(pc.x,pc.y, CreatePotion(lqCHEAPBEER, 1),1);
                  end;
                  More;
                  AddMsg('"Далеко не уходи - вдруг еще захочешь! Можешь посидеть с нашими постояльцами..."',0);
                end;
            end else
              AddMsg('"Ну что ж... Мое дело предложить!"',0);
        end;
        mdDRUNK:
        begin
          // Выполняем скрипт
          Run('NPCTalk.pas');
          // Сохраняем результат
          S := S + V.GetStr('TalkStr');
        end;
        mdHEALER:
        begin
          w := False;
          if pc.Hp < pc.RHp then
          begin
            if (Ask(FullName(1, TRUE) + ' говорит: "Хочешь я подлечу тебя?" #(Y/n)#')) = 'Y' then
            begin
              p := Round((pc.RHp - pc.Hp) * 1.1);
              if (Ask('"Твое полное исцеление будет стоить {'+IntToStr(p)+'} золотых. Идет?" #(Y/n)#')) = 'Y' then
              begin
                if pc.FindCoins = 0 then
                  AddMsg('К сожалению, у тебя совсем нет денег.',0) else
                  if pc.inv[pc.FindCoins].amount < p then
                  begin
                    p := Round(pc.inv[pc.FindCoins].amount / 1.1);
                    if p > 0 then
                    begin
                      if (Ask('"Недостаточно монет... Но, если хочешь, могу немного подлечить тебя и за {'+IntToStr(pc.inv[pc.FindCoins].amount)+'} золотых. Идет?" #(Y/n)#')) = 'Y' then
                      begin
                        AddMsg('Ты протягиваешь '+FullName(3, FALSE)+' деньги.',0);
                        pc.inv[pc.FindCoins].amount := 0;
                        pc.RefreshInventory;
                        More;
                        AddMsg('Она быстренько пересчитывает и прячет их. Затем достает фляжку с горячим отваром и дает тебе выпить... ',0);
                        More;
                        AddMsg('#Сначала тебя немного затошнило, но несколько секунд спустя стало лучше!# ($+'+IntToStr(p)+'$)',0);
                        inc(pc.Hp, p);
                      end else
                        AddMsg('"Тогда ищи более выгодные предложения!"',0);
                    end else
                      AddMsg('К сожалению, у тебя недостаточно монет, что бы хоть чуть-чуть подлечиться.',0);
                  end else
                    if pc.inv[pc.FindCoins].amount >= p then
                    begin
                      AddMsg('Ты протягиваешь '+FullName(3, FALSE)+' деньги.',0);
                      dec(pc.inv[pc.FindCoins].amount, p);
                      pc.RefreshInventory;
                      More;
                      AddMsg('Она быстренько пересчитывает и прячет их. После этого она протягивает обе руки к твоей голове... ',0);
                      More;
                      AddMsg('#На секунду ты теряешь сознание, но, когда приходишь в себя, чувствуешь себя великолепно!#',0);
                      pc.Hp := pc.RHp;
                    end;
              end;
            end else
              AddMsg('"Не хочешь - как хочешь..."',0);
          end else
            AddMsg(FullName(1, TRUE) + ' говорит: "Здравствуй, '+pc.name+'! Меня зовут '+name+'. Если тебя ранят - заходи ко мне, я смогу тебе помочь."',0);
        end;
        mdMEATMAN:
        begin
          w := False;
          if (Ask(FullName(1, TRUE) + ' говорит: "Хочешь купить кусок отличного свежего мяса всего за 15 золотых?" #(Y/n)#')) ='Y' then
          begin
            if pc.FindCoins = 0 then
              AddMsg('К сожалению, у тебя совсем нет денег.',0) else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('У тебя недостаточно золотых монет для покупки.',0) else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('Ты протягиваешь '+FullName(3, FALSE)+' деньги.',0);
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  RefreshInventory;
                  More;
                  AddMsg('Он их пересчитывает и отдает кусок мяса.',0);
                  if pc.PickUp(CreateItem(idMEAT, 1, 0), FALSE,1) <> 0 then
                  begin
                    AddMsg('Оно упало на пол.',0);
                    PutItem(pc.x,pc.y, CreateItem(idMEAT, 1, 0),1);
                  end;
                  More;
                  AddMsg('"Возвращайся еще, когда захочешь кушать!"',0);
                end;
            end else
              AddMsg('"Если вдруг передумаешь - обязательно заходи ко мне!"',0);
        end;
        else s := 'Говорить впустую...';
      end;
      if W then AddMsg(s,id);
  end else
    AddMsg('Ох! Вы не в таких отношениях, чтобы беседовать!',0);
end;

{ Драться }
procedure TMonster.Fight(var Victim : TMonster; CA : byte);
var
  i,c : byte;
  dam, tempdam : integer;
  d : real;
begin
  // Если контратака
  if CA = 1 then
    if id = 1 then
      AddMsg('#'+MonstersData[id].name1+' контратакуешь!#',id) else
        AddMsg('*'+MonstersData[id].name1+' контратакует!*',id);
  // Если второй удар
  if CA = 2 then
    if id = 1 then
      AddMsg('#'+MonstersData[id].name1+' успеваешь нанести еще один удар!#',id) else
        AddMsg('*'+MonstersData[id].name1+' успевает нанести еще один удар!*',id);
  if M.MonP[Victim.x, victim.y] > 0 then
  begin
    { --Атаковать враждебного-- }
    if ((Victim.relation = 1) and (id = 1)) or (id > 1)  then
    begin
      // Уклониться
      if Random(Round(TacticEffect(2)*(dex+(ability[abACCURACY]*AbilitysData[abACCURACY].koef))))+1 > Random(Round(Victim.TacticEffect(1)*(Victim.dex+(Victim.ability[abDODGER]*AbilitysData[abDODGER].koef))))+1 then
      begin
        // Отразить щитом
        if (Victim.eq[8].id > 0) and (Random(Round(Victim.dex*Victim.TacticEffect(1)) * 2)+1 = 1) then
          if Victim.id = 1 then
            AddMsg('#'+Victim.FullName(1, FALSE)+' блокировал{/а} атаку своим щитом!#', Victim.id) else
              AddMsg('*'+Victim.FullName(1, FALSE)+' блокировал{/а} атаку своим щитом!*', Victim.id)
        else
          // Попал
          begin
            Dam := 0;
            // Рассчитать дамаг
            if Eq[6].id > 0 then
            begin
              if closefight[ItemsData[Eq[6].id].kind] > 0 then
                Dam := Round((Random(Round(ItemsData[Eq[6].id].attack+(str/4)))+1) * (closefight[ItemsData[Eq[6].id].kind] /100));
            end else
              // Рукопашный
              if closefight[CLOSE_ARM] > 0 then Dam := Round((Random(Round(attack+(str/4)))+1) * (closefight[CLOSE_ARM] / 100)) + 1;
            TempDam := Dam;
            // Уменьшение дамага за счет брони
            Dam := (Round(Dam/(Random(Round(TacticEffect(1)*2))+1))) - Random(Round(Victim.defense/(Random(Round(Victim.TacticEffect(2)*2))+1)));
            // Для контратаки дамаг уменьшается
            if CA = 1 then Dam := Round(Dam / (1 + ((Random(Round(10*TacticEffect(2)))+1) / 10)));
            // Попал, но не пробил  
            if Dam <= 0 then
              AddMsg(FullName(1, FALSE)+' попал{/а} по '+Victim.FullName(3, FALSE)+', но не пробил{/а} броню.',id) else
                begin
                  if Dam > 1000 then
                  begin
                    AddMsg('*W*#H#$A$T $T$#H#*E* *FUCK*?! '+FloatToStr(closefight[CLOSE_ARM])+':'+IntToStr(attack)+':'+IntToStr(str)+':'+FloatToStr(TacticEffect(1)),id);
                    More;
                  end;
                  // Отнять жизни
                  Victim.hp := Victim.hp - Dam;
                  Victim.BloodStreem( -(x - Victim.x), -(y - Victim.y));
                  AddMsg(FullName(1, FALSE)+' попал{/а} по '+Victim.FullName(3, FALSE)+'! (*'+IntToStr(Dam)+'*)',id);
                  // Ранил
                  if Victim.hp > 0 then
                  begin
                    if id = 1 then AddMsg(Victim.FullName(1, FALSE)+' '+Victim.WoundDescription+'.',Victim.id);
                  end else
                    // Убил
                    begin
                      // Увеличить навык этого оружия
                      d := (TempDam * 0.03) / Dam;
                      if Eq[6].id > 0 then
                        c := ItemsData[Eq[6].id].kind else
                          c := CLOSE_ARM;
                      if IsInNewAreaSkill(closefight[c], closefight[c] +  d) then
                      begin
                        closefight[c] := closefight[c] +  d;
                        AddMsg('Теперь ты лучше владеешь навыком "'+CLOSEWPNNAME[c]+'"! Теперь ты им владеешь просто '+RateToStr(RateSkill(pc.CloseFight[c]))+'!',id);
                        More;
                      end else
                        closefight[c] := closefight[c] +  d;
                      // У рандомного навыка отнять столько же
                      repeat
                        i := Random(CLOSEFIGHTAMOUNT)+1;
                      until
                        (i <> c);
                      if CloseFight[i] - d > 0 then
                      begin
                        if IsInNewAreaSkill(Closefight[i], closefight[i] -  d) then
                        begin
                          closefight[c] := closefight[c] +  d;
                          AddMsg('Ты вдруг понял, что из-за долгого отсутствия тренировок твой навык "'+CLOSEWPNNAME[c]+'" стал забываться. Теперь ты им владеешь просто '''+RateToStr(RateSkill(pc.CloseFight[i]))+'''.',id);
                          More;
                        end else
                          CloseFight[i] := CloseFight[i] - d;
                      end else
                          CloseFight[i] := 0;
                      // Убить
                      KillSomeOne(Victim.idinlist);
                    end;
                end;
          end;
      end else
        begin
          AddMsg(FullName(1, FALSE)+' промахнул{ся/ась} по '+Victim.FullName(3, FALSE)+'.', id);
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
    // Атаковать нейтрального
    if  (id = 1) and (Victim.relation = 0)then
    begin
      if Ask('Точно напасть на '+Victim.FullName(2, TRUE)+'? #(Y/n)#') = 'Y' then
      begin
        Victim.relation := 1; // Агрессия!
        Fight(Victim, 0);
        AttackNeutral(Victim);
      end else
        AddMsg('Ты немного подумал{/а} и решил{/а} этого не делать.',0);
    end;
  end else
    AddMsg('Но здесь же никого нет!',0);
end;

{ Стрелять }
procedure TMonster.Fire(var Victim : TMonster);
var
  i,c : byte;
  dam, tempdam : integer;
  d : real;
  Item : TItem;
begin
  if M.MonP[Victim.x, victim.y] > 0 then
  begin
    if Eq[7].id > 0 then
      AddMsg(FullName(1, FALSE)+', используя '+ItemsData[eq[7].id].name3+', выстрелил{/a} в '+Victim.FullName(2, FALSE)+'!',id) else
        AddMsg(FullName(1, FALSE)+' швырнул{/a} '+ItemsData[eq[13].id].name3+' в '+Victim.FullName(2, FALSE)+'!',id);
    // Уклониться
    if Random(Round(TacticEffect(2)*(dex+(ability[abACCURACY]*AbilitysData[abACCURACY].koef))))+1 > Random(Round(Victim.TacticEffect(1)*((Victim.dex/4)+(Victim.ability[abDODGER]*AbilitysData[abDODGER].koef))))+1 then
    begin
      // Отразить щитом (шанс меньше чем в ближнем бою)
      if (Victim.eq[8].id > 0) and (Random(Round(Victim.dex*Victim.TacticEffect(1)) * 4)+1 = 1) then
        if Victim.id = 1 then
          AddMsg('#'+Victim.FullName(1, FALSE)+' блокировал{/а} '+ItemsData[pc.eq[13].id].name3+' своим щитом!#',Victim.id) else
            AddMsg('*'+Victim.FullName(1, FALSE)+' блокировал{/а} '+ItemsData[pc.eq[13].id].name3+' своим щитом!*',Victim.id)
      else
        // Попал
        begin
          Dam := 0;
          // Рассчитать дамаг
          if Eq[7].id > 0 then
          begin
            if farfight[ItemsData[Eq[7].id].kind] > 0 then
              Dam := Round((Random(Round(ItemsData[Eq[13].id].attack+(str/3)))+1) * (farfight[ItemsData[Eq[7].id].kind] / 100));
          end else
            // Бросок предета
            if farfight[FAR_THROW] > 0 then Dam := Round(Random(Round(ItemsData[Eq[13].id].attack+(str/3)))+1 * (farfight[FAR_THROW] / 100));
          TempDam := Dam;
          // Уменьшение дамага за счет брони
          Dam := (Round(Dam/(Random(Round(TacticEffect(1)*2))+1))) - Random(Round(Victim.defense/(Random(Round(Victim.TacticEffect(2)*2))+1)));
          // Попал, но не пробил
          if Dam <= 0 then
            AddMsg(FullName(1, FALSE)+' попал{/а} по '+Victim.FullName(3, FALSE)+', но не пробил{/а} броню.',id) else
              begin
                // Отнять жизни
                Victim.hp := Victim.hp - Dam;
                Victim.BloodStreem( -(x - Victim.x), -(y - Victim.y));
                // Ранил
                if Victim.hp > 0 then
                begin
                  AddMsg(FullName(1, FALSE)+' попал{/а} по '+Victim.FullName(3, FALSE)+'! (*'+IntToStr(Dam)+'*)',id);
                  if id = 1 then AddMsg(Victim.FullName(1, FALSE)+' '+Victim.WoundDescription+'.',Victim.id);
                end else
                  // Убил
                  begin
                    // Увеличить навык этого оружия
                    d := (TempDam * 0.03) / Dam;
                    if Eq[7].id > 0 then
                      c := ItemsData[Eq[7].id].kind else
                        c := FAR_THROW;
                    if IsInNewAreaSkill(farfight[c], farfight[c] +  d) then
                    begin
                      farfight[c] := farfight[c] +  d;
                      AddMsg('Теперь ты лучше владеешь навыком "'+CLOSEWPNNAME[c]+'"! Теперь ты им владеешь просто '+RateToStr(RateSkill(pc.CloseFight[c]))+'!',id);
                      More;
                    end else
                      farfight[c] := farfight[c] +  d;
                    // У рандомного навыка отнять столько же
                    repeat
                      i := Random(FARFIGHTAMOUNT)+1;
                    until
                      (i <> c);
                    if FarFight[i] - d > 0 then
                    begin
                      if IsInNewAreaSkill(Farfight[i], Farfight[i] -  d) then
                      begin
                        Farfight[c] := Farfight[c] +  d;
                        AddMsg('Ты вдруг понял, что из-за долгого отсутствия тренеровок твой навык "'+CLOSEWPNNAME[c]+'" стал забываться. Теперь ты им владеешь просто '''+RateToStr(RateSkill(pc.CloseFight[i]))+'''.',id);
                        More;
                      end else
                        FarFight[i] := FarFight[i] - d;
                    end else
                        FarFight[i] := 0;
                    // Убить
                    KillSomeOne(Victim.idinlist);
                  end;
              end;
        end;
    end else
      begin
        AddMsg(FullName(1, FALSE)+' промахнул{ся/ась} по '+Victim.FullName(3, FALSE)+'.',id);
        Item := pc.eq[13];
        Item.amount := 1;
        PutItem(Victim.x, Victim.y, Item,1);
      end;
    // Если пристрелен нейтральный
    if  (id = 1) and (Victim.relation = 0)then
    begin
      Victim.relation := 1; // Агрессия!
      AttackNeutral(Victim);
    end;
  end else
    AddMsg('Но здесь никого нет!',id);
end;

{ Атаковать нейтрального }
procedure TMonster.AttackNeutral(Victim : TMonster);
var
  i : byte;
begin
  if Victim.id = mdBREAKMT then
  begin
    More;
    AddMsg('Ты почувствовал{/a}, что пол под твоими ногами развергся...',0);
    More;
    AddMsg('И ты проваливаешься вниз!',0);
    More;
    pc.level := 3;
    M.MakeSpMap(pc.level);
    pc.PlaceHere(30,23);
    pc.turn := 2;
  end else
    begin
      AddMsg(Victim.FullName(1, FALSE)+' в ярости!',Victim.id);
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
        AddMsg('Ты видишь, что все посмотрели на тебя...',0);
        More;
        AddMsg('И в воздухе зависла недобрая тишина...',0);
        More;
        AddMsg('Которая в следущую секунду была прервана криками!',0);
        More;
        AddMsg('*Что ты наделал{/a}! Теперь вся деревня против тебя!*',0);
        More;
      end;
    end;
end;

{ Убить }
procedure TMonster.KillSomeOne(Victim : byte);
begin
  if Victim = 1 then
    AddMsg('*'+FullName(1, TRUE)+' убил{/a} '+pc.FullName(2, TRUE)+'!*',id) else
      AddMsg('*'+FullName(1, TRUE)+' убил{/a} '+M.MonL[Victim].FullName(2, TRUE)+'!*',id);
  if id = 1 then
  begin
    inc(pc.exp, MonstersData[+M.MonL[Victim].id].exp);
    if pc.exp >= pc.ExpToNxtLvl then
      pc.GainLevel;
    if (M.MonL[Victim].id = mdBLINDBEAST) and (PlayMode = AdventureMode) then
    begin
      AddMsg('#Ты выполнил{/a} квест!!!#',0);
      pc.quest[1] := 2;
      More;
    end;
    if M.MonL[Victim].id = mdKEYMAN then
    begin
      if pc.quest[2] = 1 then pc.quest[2] := 2;
      More;
    end;
  end;
  M.MonL[Victim].Death;
end;

{ Умереть }
procedure TMonster.Death;
var
  i : byte;
begin
  // Удалить указатель
  M.MonP[x,y] := 0;
  // Труп
  if idinlist = 1 then
    PutItem(x,y,CreateItem(idCORPSE, 1, id),1) else
      begin
        if id = mdBLINDBEAST then
          PutItem(x,y,CreateItem(idHEAD, 1, id),1) else
          begin
            // Тело
            if Random(5)+1 = 1 then
              PutItem(x,y,CreateItem(idCORPSE, 1, id),1);
            // Голова  
            if Random(15)+1 = 1 then
              PutItem(x,y,CreateItem(idHEAD, 1, id),1);
          end;
      end;
  // Выкинуть вещи
  for i:=1 to EqAmount do
    if Eq[i].id > 0 then
      PutItem(x,y, Eq[i], Eq[i].amount);
  for i:=1 to MaxHandle do
    if Inv[i].id > 0 then
      PutItem(x,y, Inv[i], Inv[i].amount);
  // Если это герой, то
  if idinlist = 1 then pc.AfterDeath;
  // Всё.
  id := 0;
  idinlist := 0;
end;

{ Отдать вещь }
procedure TMonster.GiveItem(var Victim : TMonster; var GivenItem : TItem);
begin
  if ((Victim.relation = 0) and (id = 1)) or (id > 1) then
  begin
    if Ask('Точно отдать '+ItemName(GivenItem, 1, TRUE)+' '+Victim.FullName(3, TRUE)+'? #(Y/n)#') = 'Y' then
    begin
      // 0-успешно,1-ничего нет,2-нет места,3-перегружен
      case Victim.PickUp(GivenItem, FALSE,GivenItem.amount) of
        0 :
        begin // Успешно отдал
          AddMsg(FullName(1, TRUE)+' отдал{/а} '+Victim.FullName(3, TRUE)+' '+ItemName(GivenItem, 1, TRUE)+'.',id);
          // Отдал башку старейшине
          if (GivenItem.id = idHEAD) and (GivenItem.owner = mdBLINDBEAST) then
            if pc.quest[1] > 1 then
              pc.quest[1] := 3;
          // Отдал ключ старейшине
          if GivenItem.id = idGATESKEY then
            if pc.quest[2] > 1 then
              pc.quest[2] := 3;
          DeleteInvItem(GivenItem, 1);
          RefreshInventory;
        end;
        1 : AddMsg(FullName(1, TRUE)+' отдал{/а} '+Victim.FullName(3, TRUE)+' глюк!',id);
        2 : AddMsg(Victim.FullName(1, TRUE)+' уже несет очень много вещей!',Victim.id);
        3 : AddMsg(Victim.FullName(1, TRUE)+' перегружен{/а} вещами!',Victim.id);
      end;
    end else
      AddMsg('Немного подумав, ты решил{/a} этого не делать.',0);
  end else
    AddMsg('Кажется, это не совсем уместно...',0);
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
      if TilesData[M.Tile[x+(dx*i),y+(dy*i)]].blood then
        M.blood[x+(dx*i),y+(dy*i)] := Random(2)+1;
      if not(TilesData[M.Tile[x+(dx*i),y+(dy*i)]].move) then
        break;
    end;
  end else
    M.blood[x,y] := Random(2)+1;
end;

{ Поднять вещи }
function TMonster.PickUp(Item : TItem; FromEq : boolean; amount : integer) : byte;
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
          if SameItems(Inv[i], Item) then
          begin
            if (invmass + (Item.mass*amount) < MaxMass) then
            begin
              inc(Inv[i].amount, amount);
              invmass := invmass + (Item.mass*amount);
              f := TRUE;
              break;
            end else
              begin
                Result := 3;
                break;
              end;
          end;
        if f = false then
          for i:=1 to MaxHandle do
            if Inv[i].id = 0 then
            begin
              if (invmass + (Item.mass*amount) < MaxMass) or (FromEq) then
              begin
                Inv[i] := Item;
                Inv[i].amount := amount;
                invmass := invmass + (Item.mass*amount);
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
  Result := str * 15.8;
end;

{ Удалить предмет из инвентаря }
procedure TMonster.DeleteInvItem(var I : TItem; amount : integer);
begin
  // Масса
  invmass := invmass - (I.mass*I.amount);
  if (I.amount > 1) and (amount > 0) then
  begin
    dec(I.amount,amount);
    if I.amount < 1 then
      FillMemory(@I, SizeOf(TItem), 0);
  end else
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
    1 : Result := RGB(70,0,0);
    2 : Result := RGB(0,70,0);
  end;
end;

{ Вернуть множитель (0.5, 1 или 1.5 - эффект от тактики) }
function TMonster.TacticEffect(situation : byte) : real;
begin
  Result := 1;
  case situation of
    1 :
    case tactic of
      1 : Result := 0.5;
      2 : Result := 1.5;
    end;
    2 :
    case tactic of
      1 : Result := 1.5;
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
    7 : cell := 7; // Оружие дальнего боя
    8 : cell := 8; // Щит
    9 : cell := 9; // Браслет
    10: cell := 10; // Кольцо
    11: cell := 11; // Перчатки
    12: cell := 12; // Обувь
    13: cell := 13; // Аммуниция
  end;
  // Ячейка занята
  if (eq[cell].id > 0) then
  begin
    TempItem := eq[cell];
    ItemOnOff(eq[cell], FALSE);
    eq[cell] := Item;
    DeleteInvItem(inv[MenuSelected], 0);
    if (id = 1) then
      case PickUp(TempItem, TRUE,TempItem.amount) of
        0 :
        begin
          if cell = 13 then
            AddMsg('Теперь ты используешь '+ItemName(eq[cell], 1, TRUE)+', а '+ItemName(TempItem, 1, TRUE)+' ты убрал{/a} в инвентарь.',0) else
              AddMsg('Теперь ты используешь '+ItemName(eq[cell], 1, FALSE)+', а '+ItemName(TempItem, 1, TRUE)+' ты убрал{/a} в инвентарь.',0);
        end;
        2 : // Нет места
          AddMsg('К сожалению, в инвентаре не достаточно места для такой операции.',0);
      end;
    Result := 1;
  end else
    eq[cell] := Item;
  if cell <> EqAmount then
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
      s := s + 'Отрешенн{ый/ая}' else
    // Одержимый
    if (Relation = 1) and (IsFlag(MonstersData[id].flags, M_NEUTRAL)) then
      s := s + 'Одержим{ый/ая}';
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
  // Класс монстра
  if ((IsFlag(MonstersData[id].flags, M_ClASS))) and (id > 1) then
    s := s + '-' + ClName(situation);
  // Если есть имя
  if id > 1 then
    if ((IsFlag(MonstersData[id].flags, M_NAME))) and (writename) then
      s := s + ' по имени ' + name;
  Result := s;
end;

{ Минус стрела }
procedure TMonster.DecArrows;
begin
  dec(Eq[13].amount);
  if eq[13].amount = 0 then
  begin
    // Если ГГ
    if id = 1 then
      AddMsg('*У тебя закончились '+ItemsData[eq[13].id].name2+'!*',0) else
        if M.Saw[x,y] = 2 then
          AddMsg('$Кажется у '+FullName(2, FALSE)+' закончились '+ItemsData[eq[13].id].name2+'!$',0);
    eq[13].id := 0;
  end;
end;

{ Вернуть цифру класса героя }
function TMonster.WhatClass : byte;
begin
  Result := 0;
  case atr[1] of
    1 : // сила
    case atr[2] of
      1 : Result := 1;
      2 : Result := 2;
      3 : Result := 3;
    end;
    2 : // ловкость
    case atr[2] of
      1 : Result := 4;
      2 : Result := 5;
      3 : Result := 6;
    end;
    3 : // интеллект
    case atr[2] of
      1 : Result := 7;
      2 : Result := 8;
      3 : Result := 9;
    end;
  end;
end;

{ Вернуть название класса }
function TMonster.ClName(situation : byte) : string;
var
  g : byte;
begin
  if id = 1 then
    g := pc.gender else
      g := MonstersData[id].gender;
  case situation of
    1 :
      case g of
        1 : Result := MonsterClassName[WhatClass].name1m;
        2 : Result := MonsterClassName[WhatClass].name1f;
      end;
    2 :
      case g of
        1 : Result := MonsterClassName[WhatClass].name2m;
        2 : Result := MonsterClassName[WhatClass].name2f;
      end;
    3 :
      case g of
        1 : Result := MonsterClassName[WhatClass].name3m;
        2 : Result := MonsterClassName[WhatClass].name3f;
      end;
    4 :
      case g of
        1 : Result := MonsterClassName[WhatClass].name4m;
        2 : Result := MonsterClassName[WhatClass].name4f;
      end;
    5 :
      case g of
        1 : Result := MonsterClassName[WhatClass].name5m;
        2 : Result := MonsterClassName[WhatClass].name5f;
      end;
    6 :
      case g of
        1 : Result := MonsterClassName[WhatClass].name6m;
        2 : Result := MonsterClassName[WhatClass].name6f;
      end;
  end;
end;

{ Раставить очки умений и экипировать в зависимости от класса }
procedure TMonster.PrepareSkills;
var
  i : byte;
begin
  for i:=1 to CLOSEFIGHTAMOUNT do closefight[i] := 0;
  for i:=1 to FARFIGHTAMOUNT do farfight[i] := 0;
  case WhatClass of
    1: //Воин
    begin
      closefight[1] := 50;
      closefight[2] := 50;
      closefight[5] := 50;
      closefight[6] := 50;
      farfight[1] := 40;
      farfight[2] := 40;

      EquipItem(CreateItem(idBOOTS, 1, 0));
      EquipItem(CreateItem(idCHAINARMOR , 1, 0));
      PickUp(CreatePotion(lqCURE, 2), FALSE,2);
      PickUp(CreatePotion(lqHEAL, 1), FALSE,1);
      PickUp(CreateItem(idMEAT, 1, 0), FALSE,1);
      PickUp(CreateItem(idLAVASH, 2, 0), FALSE,2);
      PickUp(CreateItem(idCOIN, 60, 0), FALSE,60);
    end;
    2: //Варвар
    begin
      closefight[3] := 50;
      closefight[4] := 40;
      closefight[6] := 50;
      farfight[1] := 50;
      farfight[3] := 40;
      farfight[4] := 40;

      EquipItem(CreateItem(idCAPE, 1, 0));
      PickUp(CreateItem(idMEAT, 5, 0), FALSE,5);
      PickUp(CreateItem(idCOIN, 5, 0), FALSE,5);
    end;
    3: //Паладин
    begin
      closefight[2] := 50;
      farfight[1] := 40;
      farfight[2] := 40;

      EquipItem(CreateItem(idBOOTS, 1, 0));
      EquipItem(CreateItem(idCHAINARMOR , 1, 0));
      PickUp(CreatePotion(lqCURE, 2), FALSE,2);
      PickUp(CreatePotion(lqHEAL, 1), FALSE,1);
      PickUp(CreateItem(idLAVASH, 3, 0), FALSE,3);
      PickUp(CreateItem(idCOIN, 30, 0), FALSE,30);
    end;
    4: //Странник
    begin
      closefight[2] := 40;
      closefight[4] := 40;
      closefight[6] := 40;
      farfight[1] := 40;
      farfight[3] := 40;

      EquipItem(CreateItem(idBOOTS, 1, 0));
      EquipItem(CreateItem(idJACKET , 1, 0));
      PickUp(CreatePotion(lqCURE, 4), FALSE,4);
      PickUp(CreatePotion(lqHEAL, 2), FALSE,1);
      PickUp(CreateItem(idMEAT, 1, 0), FALSE,1);
      PickUp(CreateItem(idLAVASH, 4, 0), FALSE,4);
      PickUp(CreateItem(idCOIN, 70, 0), FALSE,70);
    end;
    5: //Воришка
    begin
      closefight[2] := 30;
      closefight[6] := 40;
      farfight[1] := 30;
      farfight[2] := 30;
      farfight[3] := 30;
      farfight[4] := 30;

      EquipItem(CreateItem(idLAPTI, 1, 0));
      EquipItem(CreateItem(idJACKET , 1, 0));
      EquipItem(CreateItem(idDAGGER , 1, 0));
      PickUp(CreatePotion(lqCURE, 2), FALSE,2);
      PickUp(CreatePotion(lqCURE, 3), FALSE,3);
      PickUp(CreateItem(idMEAT, 1, 0), FALSE,1);
      PickUp(CreateItem(idLAVASH, 5, 0), FALSE,5);
      PickUp(CreateItem(idCOIN, 90, 0), FALSE,90);
    end;
    6: //Монах
    begin
      closefight[6] := 60;
      farfight[1] := 40;
      farfight[4] := 50;

      EquipItem(CreateItem(idBOOTS, 1, 0));
      EquipItem(CreateItem(idMANTIA , 1, 0));
      PickUp(CreatePotion(lqCURE, 3), FALSE,3);
      PickUp(CreatePotion(lqHEAL, 2), FALSE,2);
      PickUp(CreatePotion(lqKEFIR, 2), FALSE,2);
      PickUp(CreateItem(idLAVASH, 8, 0), FALSE,8);
      PickUp(CreateItem(idCOIN, 25, 0), FALSE,25);
    end;
    7: //Жрец
    begin
      closefight[4] := 30;
      farfight[1] := 30;
      farfight[3] := 30;

      EquipItem(CreateItem(idBOOTS, 1, 0));
      EquipItem(CreateItem(idMANTIA , 1, 0));
      PickUp(CreatePotion(lqCURE, 5), FALSE,5);
      PickUp(CreatePotion(lqHEAL, 2), FALSE,2);
      PickUp(CreateItem(idLAVASH, 4, 0), FALSE,4);
      PickUp(CreateItem(idMEAT, 2, 0), FALSE,2);
      PickUp(CreateItem(idCOIN, 35, 0), FALSE,35);
    end;
    8: //Колдун
    begin
      closefight[4] := 25;
      farfight[3]   := 25;

      EquipItem(CreateItem(idLAPTI, 1, 0));
      EquipItem(CreateItem(idMANTIA , 1, 0));
      PickUp(CreatePotion(lqCURE, 5), FALSE,5);
      PickUp(CreatePotion(lqHEAL, 2), FALSE,2);
      PickUp(CreateItem(idLAVASH, 5, 0), FALSE,5);
      PickUp(CreateItem(idMEAT, 1, 0), FALSE,1);
      PickUp(CreateItem(idCOIN, 30, 0), FALSE,30);
    end;
    9: //Мыслитель
    begin
      closefight[4] := 25;
      farfight[3] := 25;

      EquipItem(CreateItem(idLAPTI, 1, 0));
      EquipItem(CreateItem(idMANTIA , 1, 0));
      PickUp(CreatePotion(lqCURE, 2), FALSE,2);
      PickUp(CreatePotion(lqHEAL, 2), FALSE,4);
      PickUp(CreateItem(idLAVASH, 6, 0), FALSE,6);
      PickUp(CreateItem(idMEAT, 1, 0), FALSE,1);
      PickUp(CreateItem(idCOIN, 50, 0), FALSE,50);
    end;
  end;
end;

{ Исходя из любимых оружейных навыков - их прокачать и дать соотв. оружие }
procedure TMonster.FavWPNSkill;
var
  i : byte;
begin
  // Если изначально прокачен только 1 оружейный навык, то он автоматически становится любимым
  if HowManyBestWPNCL = 1 then
    c_choose := BestWPNCL;
  if HowManyBestWPNFR = 1 then
    f_choose := BestWPNFR;
  // Если 2 одинаковых и первое - двуручное оружие, то любимым становится второе
  if (HowManyBestWPNCL = 2) and (OneOfTheBestWPNCL(1)) then
    for i:=2 to CLOSEFIGHTAMOUNT do
      if OneOfTheBestWPNCL(i) then
      begin
        c_choose := i;
        break;
      end;
  // Если 2 одинаковых и первое - кидать, то любимым становится второе
  if (HowManyBestWPNFR = 2) and (OneOfTheBestWPNFR(1)) then
    for i:=2 to FARFIGHTAMOUNT do
      if OneOfTheBestWPNFR(i) then
      begin
        f_choose := i;
        break;
      end;
  case c_choose of
    // Двуручное
    1 :
    begin
      closefight[1] := closefight[1] + 25;
      EquipItem(CreateItem(idLONGSWORD, 1, 0));
    end;
    // Меч
    2 :
    begin
      closefight[2] := closefight[2] + 25;
      EquipItem(CreateItem(idSHORTSWORD, 1, 0));
    end;
    // Дубина
    3 :
    begin
      closefight[3] := closefight[3] + 25;
      EquipItem(CreateItem(idDUBINA, 1, 0));
    end;
    // Посох
    4 :
    begin
      closefight[4] := closefight[4] + 25;
      EquipItem(CreateItem(idSTAFF, 1, 0));
    end;
    // Топор
    5 :
    begin
      closefight[5] := closefight[5] + 25;
      EquipItem(CreateItem(idAXE, 1, 0));
    end;
    // Рукопашный бой
    6 :
    begin
      closefight[6] := closefight[6] + 25;
      attack := attack * 2;
    end;
  end;
  case f_choose of
    // Кидать
    1 :
    begin
      farfight[1] := farfight[1] + 25;
    end;
    // Лук
    2 :
    begin
      farfight[2] := farfight[2] + 25;
      EquipItem(CreateItem(idBOW, 1, 0));
      EquipItem(CreateItem(idARROW, 30, 0));
    end;
    // Праща
    3 :
    begin
      farfight[3] := farfight[3] + 25;
      EquipItem(CreateItem(idSLING, 1, 0));
      EquipItem(CreateItem(idLITTLEROCK, 50, 0));
    end;
    // Духовая трубка
    4 :
    begin
      farfight[4] := farfight[4] + 25;
      EquipItem(CreateItem(idBLOWPIPE, 1, 0));
      EquipItem(CreateItem(idIGLA, 40, 0));
    end;
    // Арбалет
    5 :
    begin
      farfight[5] := farfight[5] + 25;
      EquipItem(CreateItem(idCROSSBOW, 1, 0));
      EquipItem(CreateItem(idBOLT, 25, 0));
    end;
  end;
end;

{ Самый прокаченный навык в ближ. бою }
function TMonster.BestWPNCL : byte;
var
  best, i : byte;
begin
  best := 1;
  for i:=1 to CLOSEFIGHTAMOUNT do
    if closefight[i] > closefight[best] then
      best := i;
  Result := best;
end;

{ Сколько одинаковопрокаченных в ближ. бою }
function TMonster.HowManyBestWPNCL : byte;
var
  i, bestone, amount : byte;
begin
  bestone := BestWPNCL;
  amount := 1;
  for i:=1 to CLOSEFIGHTAMOUNT do
    if (i <> bestone) and (closefight[i] = closefight[bestone]) then
      inc(amount);
  Result := amount;
end;

{ Один из лучше прок. навыков }
function TMonster.OneOfTheBestWPNCL(i : byte): boolean;
begin
  Result := FALSE;
  if closefight[i] = closefight[BestWPNCL] then Result := TRUE;
end;

{ Самый прокаченный навык в дальнем бою }
function TMonster.BestWPNFR : byte;
var
  best, i : byte;
begin
  best := 1;
  for i:=1 to FARFIGHTAMOUNT do
    if farfight[i] > farfight[best] then
      best := i;
  Result := best;
end;

{ Сколько одинаковопрокаченных в дальнем бою }
function TMonster.HowManyBestWPNFR : byte;
var
  i, bestone, amount : byte;
begin
  bestone := BestWPNFR;
  amount := 1;
  for i:=1 to FARFIGHTAMOUNT do
    if (i <> bestone) and (farfight[i] = farfight[bestone]) then
      inc(amount);
  Result := amount;
end;

{ Один из лучше прок. навыков }
function TMonster.OneOfTheBestWPNFR(i : byte): boolean;
begin
  Result := FALSE;
  if farfight[i] = farfight[BestWPNFR] then Result := TRUE;
end;

{ Цвет класса }
function TMonster.ClassColor : longword;
begin
  Result := 0;
  if (id > 1) and not (IsFlag(MonstersData[id].flags, M_CLASS)) then
    // Монстр без класса
    Result := RealColor(MonstersData[id].color) else
      // Цвет класса
      case WhatClass of
        1 : Result := cLIGHTBLUE;
        2 : Result := cORANGE;
        3 : Result := cLIGHTGRAY;
        4 : Result := cGREEN;
        5 : Result := cGRAY;
        6 : Result := cYELLOW;
        7 : Result := cBROWN;
        8 : Result := cPURPLE;
        9 : Result := cCYAN;
      end;
end;

end.
