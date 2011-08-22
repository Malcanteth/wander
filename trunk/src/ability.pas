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
                                  
function BestWPNCL : byte;                     // Самый прокаченный навык в ближ. бою
function HowManyBestWPNCL : byte;              // Сколько одинаковопрокаченных в ближ. бою
function OneOfTheBestWPNCL(i : byte): boolean; // Один из лучше прок. навыков
function BestWPNFR : byte;                     // Самый прокаченный навык в дальнем бою
function HowManyBestWPNFR : byte;              // Сколько одинаковопрокаченных в дальнем бою
function OneOfTheBestWPNFR(i : byte): boolean; // Один из лучше прок. навыков

procedure ShowAbilitys;                        // Показать окно со способностями

implementation

uses
  Player, Main, Conf;

{ Показать меню 'Навыки и способности' }
procedure SkillsAndAbilitys;
begin
  StartDecorating('<-НАВЫКИ И СПОСОБНОСТИ->', FALSE);
  with Screen.Canvas do
  begin
    Font.Color := cBROWN;
    TextOut(38*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(42*CharX, 15*CharY, 'Использовать навык');
    Font.Color := cBROWN;
    TextOut(38*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(42*CharX, 16*CharY, 'Список пассивных навыков');
    Font.Color := cBROWN;
    TextOut(38*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(42*CharX, 17*CharY, 'Оружейные навыки');
    Font.Color := cBROWN;
    TextOut(38*CharX, 18*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(42*CharX, 18*CharY, 'Особенные способности');
    Font.Color := cYELLOW;
    TextOut(39*CharX, (14+MenuSelected)*CharY, '>');
  end;
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
  with Screen.Canvas do
  begin
    For i:=1 to Round(WindowX/2) do
    begin
      Font.Color := Darker(cGRAY, 100-i);
      TextOut((i-1)*CharX,y,'-');
    end;
    For i:=Round(WindowX/2) to WindowX do
    begin
      Font.Color := Darker(cGRAY, i);
      TextOut((i-1)*CharX,y,'-');
    end;
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
  with Screen.Canvas do
  begin
    // Ближнеий бой
    DrawStyleLine(top*CharY);
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, top*CharY, s1);
    if c > 0 then
    begin
      for i:=1 to CLOSEFIGHTAMOUNT do
        if pc.closefight[i] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(15*CharX, (top+i)*CharY, CLOSEWPNNAME[i]+':');
          Font.Color := ColorRateSkill(pc.CloseFight[i]);
          if ShowProc then
            TextOut(33*CharX, (top+i)*CharY, RateToStr(RateSkill(pc.CloseFight[i])) +' = ' +FloatToStr(pc.CloseFight[i])+'%') else
              TextOut(33*CharX, (top+i)*CharY, RateToStr(RateSkill(pc.CloseFight[i])));
        end;
    end else
      begin
        Font.Color := cBLUEGREEN;
        TextOut(15*CharX, (top+1)*CharY, 'У тебя нет никаких навыков в этой области.');
      end;
    // Дальний бой
    DrawStyleLine((top+10)*CharY);
    Font.Color := cCYAN;
    TextOut(((WindowX-length(s2)) div 2) * CharX, (top+10)*CharY, s2);
    if f > 0 then
    begin
      for i:=1 to FARFIGHTAMOUNT do
        if pc.farfight[i] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(15*CharX, ((top+10)+i)*CharY, FARWPNNAME[i]+':');
          Font.Color := ColorRateSkill(pc.FarFight[i]);
          if ShowProc then
            TextOut(33*CharX, ((top+10)+i)*CharY, RateToStr(RateSkill(pc.FarFight[i]))+' = '+FloatToStr(pc.FarFight[i])+'%') else
              TextOut(33*CharX, ((top+10)+i)*CharY, RateToStr(RateSkill(pc.FarFight[i])));
        end;
    end else
      begin
        Font.Color := cBLUEGREEN;
        TextOut(15*CharX, ((top+10)+1)*CharY, 'У тебя нет никаких навыков в этой области.');
      end;
    // Магические навыки
    DrawStyleLine((top+20)*CharY);
    Font.Color := cPURPLE;
    TextOut(((WindowX-length(s3)) div 2) * CharX, (top+20)*CharY, s3);
    if m > 0 then
    begin
      for i:=1 to MAGICSCHOOLAMOUNT do
        if pc.farfight[i] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(15*CharX, ((top+20)+i)*CharY, FARWPNNAME[i]+':');
          Font.Color := ColorRateSkill(pc.FarFight[i]);
          if ShowProc then
            TextOut(33*CharX, ((top+20)+i)*CharY, RateToStr(RateSkill(pc.FarFight[i]))+' = '+FloatToStr(pc.FarFight[i])+'%') else
              TextOut(33*CharX, ((top+20)+i)*CharY, RateToStr(RateSkill(pc.FarFight[i])));
        end;
    end else
      begin
        Font.Color := cBLUEGREEN;
        TextOut(15*CharX, ((top+20)+1)*CharY, 'У тебя нет никаких навыков в этой области.');
      end;
  end;
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

{ Самый прокаченный навык в ближ. бою }
function BestWPNCL : byte;
var
  best, i : byte;
begin
  best := 1;
  for i:=1 to CLOSEFIGHTAMOUNT do
    if pc.closefight[i] > pc.closefight[best] then
      best := i;
  Result := best;
end;

{ Сколько одинаковопрокаченных в ближ. бою }
function HowManyBestWPNCL : byte;
var
  i, bestone, amount : byte;
begin
  bestone := BestWPNCL;
  amount := 1;
  for i:=1 to CLOSEFIGHTAMOUNT do
    if (i <> bestone) and (pc.closefight[i] = pc.closefight[bestone]) then
      inc(amount);
  Result := amount;
end;

{ Один из лучше прок. навыков }
function OneOfTheBestWPNCL(i : byte): boolean;
begin
  Result := FALSE;
  if pc.closefight[i] = pc.closefight[BestWPNCL] then Result := TRUE;
end;

{ Самый прокаченный навык в дальнем бою }
function BestWPNFR : byte;
var
  best, i : byte;
begin
  best := 1;
  for i:=1 to FARFIGHTAMOUNT do
    if pc.farfight[i] > pc.farfight[best] then
      best := i;
  Result := best;
end;

{ Сколько одинаковопрокаченных в дальнем бою }
function HowManyBestWPNFR : byte;
var
  i, bestone, amount : byte;
begin
  bestone := BestWPNFR;
  amount := 1;
  for i:=1 to FARFIGHTAMOUNT do
    if (i <> bestone) and (pc.farfight[i] = pc.farfight[bestone]) then
      inc(amount);
  Result := amount;
end;

{ Один из лучше прок. навыков }
function OneOfTheBestWPNFR(i : byte): boolean;
begin
  Result := FALSE;
  if pc.farfight[i] = pc.farfight[BestWPNFR] then Result := TRUE;
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
  with Screen.Canvas do
  begin
    // Если способности есть
    if FullAbilitys[1] > 0 then
    begin
      for i:=1 to AbilitysAmount do
        if FullAbilitys[i] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(5*CharX, (2+i)*CharY, '[ ]');
          Font.Color := cORANGE;
          TextOut(9*CharX, (2+i)*CharY, AbilitysData[FullAbilitys[i]].name);
          Font.Color := cGRAY;
          TextOut((9+Length(AbilitysData[FullAbilitys[i]].name)+1)*CharX, (2+i)*CharY, '(');
          Font.Color := cLIGHTGRAY;
          TextOut((9+Length(AbilitysData[FullAbilitys[i]].name)+2)*CharX, (2+i)*CharY, IntToStr(pc.ability[FullAbilitys[i]])+' уровень');
          Font.Color := cGRAY;
          TextOut((9+Length(AbilitysData[FullAbilitys[i]].name)+11)*CharX, (2+i)*CharY, ')');
        end;
      Font.Color := cRED;
      TextOut(6*CharX, (2+MenuSelected)*CharY, '*');
      // Описание
      DrawBorder(5,37,90,2);
      Font.Color := cWHITE;
      TextOut((((85-length(AbilitysData[FullAbilitys[MenuSelected]].descr)) div 2) + 8) * CharX, 38*CharY, AbilitysData[FullAbilitys[MenuSelected]].descr);
    end else
      // Способностей пока нет
      begin
        Font.Color := cLIGHTGRAY;
        TextOut(5*CharX, 5*CharY, 'Пока у тебя нет никаких особенных способностей.');
      end;
  end;
end;


end.
