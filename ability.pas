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
  AbilitysAmount            = 8;

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
     koef  : 5;)
  );

  abEATINSIDE              = 1;
  abGOODEYES               = 2;
  abQUICKREACTION          = 3;
  abQUICKREGENERATION      = 4;
  abACCURACY               = 5;
  abDODGER                 = 6;
  abQUICKATTACK            = 7;
  abENERGETIC              = 8;

var
  FullAbilitys : array[1..AbilitysAmount] of byte;

procedure ShowAbilitys;           // Показать окно со способностями

implementation

uses
  Player, Main;

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
