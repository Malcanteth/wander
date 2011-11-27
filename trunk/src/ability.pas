unit ability;

interface

uses
  Cons, Utils, Windows, SysUtils;

type
  TAbility = record
    name : string[50];
    descr : string;
    koef : real;      // Коэфициент
  end;

const
  { Кол-во способности}
  AbilitysAmount            = 9;

  AbilitysData : array[1..AbilitysAmount] of TAbility =
  (
    (name  : 'Быстрое насыщение';
     descr : 'Большее насыщение от того же рациона';
     koef  : 20;),
    (name  : 'Дальнозоркость';
     descr : 'Ты видишь дальше чем обычно';
     koef  : 1;),
    (name  : 'Молниеносная реакция';
     descr : 'Повышенный шанс провести контратаку';
     koef  : 2;),
    (name  : 'Повышенная регенерация';
     descr : 'Твои раны затягиваются гораздо быстрее, чем раньше';
     koef  : 0.5;),
    (name  : 'Меткость';
     descr : 'Больший шанс попасть по противнику во время атаки';
     koef  : 1;),
    (name  : 'Увертливый';
     descr : 'Ты чаще уклоняешься от атак противника';
     koef  : 1;),
    (name  : 'Быстрая атака';
     descr : 'Тебе чаще удается ударить противника дважды за ход';
     koef  : 1;),
    (name  : 'Энергичность';
     descr : 'Повышенная скорость выполнения любых действий';
     koef  : 5;),
    (name  : 'Внимательность';
     descr : 'Ты быстрее находишь секретные двери';
     koef  : 1;)
  );

  abEATINSIDE              = 1;
  abGOODEYES               = 2;
  abQUICKREACTION          = 3;
  abQUICKREGENERATION      = 4;
  abACCURACY               = 5;
  abDODGER                 = 6;
  abQUICKATTACK            = 7;
  abENERGETIC              = 8;
  abATTENTION              = 9;

  { Навыки и типы оружия}
  CLOSEFIGHTAMOUNT         = 6;

  CLOSE_TWO               = 1;      // Двуручное
  CLOSE_BLADE             = 2;      // Клинок
  CLOSE_CLUB              = 3;      // Дубины
  CLOSE_STAFF             = 4;      // Жезлы и посохи
  CLOSE_AXE               = 5;      // Топоры
  CLOSE_ARM               = 6;      // Без оружия

  FARFIGHTAMOUNT          = 5;

  FAR_THROW               = 1;      // Швыряние
  FAR_BOW                 = 2;      // Лук
  FAR_SLING               = 3;      // Праща
  FAR_PIPE                = 4;      // Трубка
  FAR_CROSS               = 5;      // Арбалет

  { Типы брони }
  ARMORTYPEAMOUNT         = 3;

  ARMOR_CLOTHES           = 1;
  ARMOR_LIGHT             = 2;
  ARMOR_HEAVY             = 3;

  { Магия }
  MAGICSCHOOLAMOUNT       = 5;      // Кол-во разновидности магии

  MAGICSCHOOLOFFIRE       = 1;      // Школа стихии огня
  MAGICSCHOOLOFWATER      = 2;      // Школа стихии воды
  MAGICSCHOOLOFEARTH      = 3;      // Школа стихии земли
  MAGICSCHOOLOFAIR        = 4;      // Школа стихии воздуха
  MAGICSCHOOLOFDEATH      = 5;      // Школа смерти

  CLOSEWPNNAME : array[1..CLOSEFIGHTAMOUNT] of string =
  (
    'Двуручное оружие', 'Клинки', 'Дубины', 'Жезлы и посохи',
    'Топоры', 'Рукопашный бой'
  );
  FARWPNNAME : array[1..FARFIGHTAMOUNT] of string =
  (
    'Кинуть/швырнуть', 'Луки', 'Пращи', 'Духовые трубки', 'Арбалеты'
  );
  ARMORTYPENAME : array[1..ARMORTYPEAMOUNT] of string =
  (
    'Одежда', 'Легкая броня', 'Тяжелая броня'
  );

var
  FullAbilitys : array[1..AbilitysAmount] of byte;
  ShowProc : boolean;                          // Отобразить проценты

procedure SkillsAndAbilitys;                   // Показать меню 'Навыки и способности'

procedure WpnSkills;                           // Отобразить оружейные навыки
function RateSkill(n : real) : byte;           // Описание прокачки умения
function RateToStr(n : byte) : string;         // Статус раскачки навыка
function ColorRateSkill(n : real) : longword;  // Цвет статуса раскачки
function IsInNewAreaSkill(was, now : real)     // Если уровень развития навыка перешел в другой статус
                                  : boolean;
procedure ShowAbilitys;                        // Показать окно со способностями

implementation

uses
  Player, Main, Conf;

{ Показать меню 'Навыки и способности' }
procedure SkillsAndAbilitys;
begin
  StartDecorating('<-НАВЫКИ И СПОСОБНОСТИ->', FALSE);
  MainForm.DrawString(38, 15, cBROWN, '[ ]');
  MainForm.DrawString(42, 15, cCYAN, 'Использовать навык');
  MainForm.DrawString(38, 16, cBROWN, '[ ]');
  MainForm.DrawString(42, 16, cCYAN, 'Список пассивных навыков');
  MainForm.DrawString(38, 17, cBROWN, '[ ]');
  MainForm.DrawString(42, 17, cCYAN, 'Оружейные навыки');
  MainForm.DrawString(38, 18, cBROWN, '[ ]');
  MainForm.DrawString(42, 18, cCYAN, 'Особенные способности');
  MainForm.DrawString(39, (14+MenuSelected), cYELLOW, '>');
end;

{ Оружейные навыки }
procedure WpnSkills;
const
  s1 = ' Ближний бой ';
  s2 = ' Дальний бой ';
  s3 = ' Магия ';
  top = 6;
var
  i,c,f,m : byte;

  procedure DrawStyleLine(y:integer);
  var
    i : byte;
  begin
    For i:=1 to (WindowX div 2) do
    begin
      MainForm.DrawString(i-1,y,Darker(cGRAY, 100-i),'-');
      MainForm.DrawString((WindowX div 2)+i-2,y,Darker(cGRAY, 100-i),'-');
    end;
  end;

begin
  StartDecorating('<-ОРУЖЕЙНЫЕ НАВЫКИ->', FALSE);
  c := 0; f := 0;
  for i:=1 to CLOSEFIGHTAMOUNT do
    if pc.closefight[i] > 0 then
      c := 1;
  for i:=1 to FARFIGHTAMOUNT do
    if pc.farfight[i] > 0 then
      f := 1;
  for i:=1 to MAGICSCHOOLAMOUNT do
    if pc.magicfight[i] > 0 then
      m := 1;
  // Вывести навыки
  // Ближний бой
  DrawStyleLine(top);
  MainForm.DrawString(((WindowX-length(s1)) div 2) , top, cWHITE, s1);
  if c > 0 then
  begin
    for i:=1 to CLOSEFIGHTAMOUNT do
      if pc.closefight[i] > 0 then
      begin
        MainForm.DrawString(15, (top+i), cBROWN, CLOSEWPNNAME[i]+':');
        if ShowProc then
          MainForm.DrawString(33, (top+i), ColorRateSkill(pc.CloseFight[i]), RateToStr(RateSkill(pc.CloseFight[i])) +' = ' +FloatToStr(pc.CloseFight[i])+'%')
        else
          MainForm.DrawString(33, (top+i), ColorRateSkill(pc.CloseFight[i]), RateToStr(RateSkill(pc.CloseFight[i])));
      end;
  end else
    begin
      MainForm.DrawString(15, (top+1), cBLUEGREEN, 'У тебя нет никаких навыков в этой области.');
    end;
  // Дальний бой
  DrawStyleLine((top+10));
  MainForm.DrawString(((WindowX-length(s2)) div 2) , (top+10), cCYAN, s2);
  if f > 0 then
  begin
    for i:=1 to FARFIGHTAMOUNT do
      if pc.farfight[i] > 0 then
      begin
        MainForm.DrawString(15, ((top+10)+i), cBROWN, FARWPNNAME[i]+':');
        if ShowProc then
          MainForm.DrawString(33, ((top+10)+i), ColorRateSkill(pc.FarFight[i]), RateToStr(RateSkill(pc.FarFight[i]))+' = '+FloatToStr(pc.FarFight[i])+'%')
        else
          MainForm.DrawString(33, ((top+10)+i), ColorRateSkill(pc.FarFight[i]), RateToStr(RateSkill(pc.FarFight[i])));
      end;
  end else
    begin
      MainForm.DrawString(15, ((top+10)+1), cBLUEGREEN, 'У тебя нет никаких навыков в этой области.');
    end;
  // Магические навыки
  DrawStyleLine((top+20));
  MainForm.DrawString(((WindowX-length(s3)) div 2) , (top+20), cPURPLE, s3);
  if m > 0 then
  begin
    for i:=1 to MAGICSCHOOLAMOUNT do
      if pc.farfight[i] > 0 then
     begin
        MainForm.DrawString(15, ((top+20)+i), cBROWN, FARWPNNAME[i]+':');
        if ShowProc then
          MainForm.DrawString(33, ((top+20)+i), ColorRateSkill(pc.FarFight[i]), RateToStr(RateSkill(pc.FarFight[i]))+' = '+FloatToStr(pc.FarFight[i])+'%')
        else
          MainForm.DrawString(33, ((top+20)+i), ColorRateSkill(pc.FarFight[i]), RateToStr(RateSkill(pc.FarFight[i])));
      end;
  end else
    MainForm.DrawString(15, ((top+20)+1), cBLUEGREEN, 'У тебя нет никаких навыков в этой области.');
end;

{ Описание прокачки умения }
function RateSkill(n : real) : byte;
begin
  Result := 0;
  case Round(n) of
    99..100 : Result := 1;
    90..98  : Result := 2;
    80..89  : Result := 3;
    61..79  : Result := 4;
    50..60  : Result := 5;
    32..49  : Result := 6;
    11..31  : Result := 7;
    1..10   : Result := 8;
  end;
end;

function RateToStr(n : byte) : string;
begin
  Result := '';
  case n of
    1 : Result := 'Превосходно';
    2 : Result := 'Мастерски';
    3 : Result := 'Отлично';
    4 : Result := 'Хорошо';
    5 : Result := 'Средне';
    6 : Result := 'Нормально';
    7 : Result := 'Плохо';
    8 : Result := 'Ужасно';
  end;
end;

{ Цвет }
function ColorRateSkill(n : real) : longword;
begin
  Result := 0;
  case Round(n) of
    99..100 : Result := cWHITE;
    90..98  : Result := cYELLOW;
    80..89  : Result := cLIGHTGREEN;
    61..79  : Result := cGREEN;
    50..60  : Result := cLIGHTGRAY;
    32..49  : Result := cGRAY;
    11..31  : Result := cBROWN;
    1..10   : Result := cRED;
  end;
end;

function IsInNewAreaSkill(was, now : real)
                                  : boolean;
begin
  Result := FALSE;
  if RateSkill(was) <> RateSkill(now) then Result := TRUE;
end;

{ Показать окно со способностями }
procedure ShowAbilitys;
var
  i, a         : byte;
begin
  StartDecorating('<-СПОСОБНОСТИ->', FALSE);
  // Создание списка способностей
  a := 1;
  FillMemory(@FullAbilitys, SizeOf(FullAbilitys), 0);
  for i:=1 to AbilitysAmount do
    if pc.Ability[i] > 0 then
    begin
      FullAbilitys[a] := i;
      inc(a);
    end;      
  // Если способности есть
  if FullAbilitys[1] > 0 then
  begin
    for i:=1 to AbilitysAmount do
      if FullAbilitys[i] > 0 then
      begin
        MainForm.DrawString(5, (2+i), cBROWN, '[ ]');
        MainForm.DrawString(9, (2+i), cORANGE, AbilitysData[FullAbilitys[i]].name);
        MainForm.DrawString((9+Length(AbilitysData[FullAbilitys[i]].name)+1), (2+i), cGRAY, '(');
        MainForm.DrawString((9+Length(AbilitysData[FullAbilitys[i]].name)+2), (2+i), cLIGHTGRAY, IntToStr(pc.ability[FullAbilitys[i]])+' уровень');
        MainForm.DrawString((9+Length(AbilitysData[FullAbilitys[i]].name)+11), (2+i), cGRAY, ')');
      end;
    MainForm.DrawString(6, (2+MenuSelected), cRED, '*');
    // Описание
    DrawBorder(5,37,90,2,crLIGHTGRAY);
    MainForm.DrawString((((85-length(AbilitysData[FullAbilitys[MenuSelected]].descr)) div 2) + 8) , 38, cWHITE, AbilitysData[FullAbilitys[MenuSelected]].descr);
  end else
    // Способностей пока нет
      MainForm.DrawString(5, 5, cLIGHTGRAY, 'Пока у тебя нет никаких особенных способностей.');
end;


end.
