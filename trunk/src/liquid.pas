unit liquid;

interface

uses
  Cons, Flags, Utils, Player, Monsters, Msg, SysUtils, Ability, Items;

type
  TAllLiquid = record
    name    : string[40];  // Если зелье, то "Зелье + name"; если другая жидкость, то "Бутылка + name"
    state   : byte;        // Если 0 - рандомное состояние, иначе фиксированное
    color   : byte;        // Если 0 - рандомный цвет, иначе фиксированный
    effect  : byte;        // Тип эффекта от зелья
    power   : byte;        // Мощность эффекта (% или единицы в зависимости от эффекта)
    chance  : byte;        // Шанс появления
    flags   : longword;    // Флаги
  end;

const
  {Состояние жидкости}
  LiquidStateAmount = 5;

  lsDENSE  = 1;
  lsGAS    = 2;
  lsSTINKY = 3;
  lsSMELLY = 4;
  lsGURGL  = 5;


  LiquidState : array[1..LiquidStateAmount] of string =
  ('густой', 'газированой', 'вонючей', 'ароматной', 'булькающей');

  {Цвет жидкости}
  LiquidColor : array[1..crAmount] of string =
  ('сияющей', 'синей', 'зеленой', 'красной', 'голубой', 'фиолетовой', 'коричневой', 'белой', 'серой', 'желтой',
   'светло-серой', 'светло-красной', 'светло-зеленой', 'светло-синей', 'оранжевой', 'изумрудной');

  {Эффекты}
  LiquidEffectsAmount = 3;

  leHEAL      = 1;
  leDRUNK     = 2;

  {Описание жидкостей}
  LiquidAmount = 4;

  AllLiquid : array[1..LiquidAmount] of TAllLiquid =
  (
    (name : 'лечения'; state : 0; color : 0; effect : leHEAL; power : 15; chance : 40; flags : NOF or L_RANDOMPOWER;),
    (name : 'исцеления'; state : 0; color : 0;  effect : leHEAL; power : 100; chance : 15; flags : NOF;),
    (name : 'дешевого пива'; state : lsGAS; color : crBROWN; effect : leDRUNK; power : 130; chance : 20; flags : NOF or L_LITTLEHEAL;),
    (name : 'кефира'; state : lsDENSE; color : crWHITE; effect : leDRUNK; power : 10; chance : 25; flags : NOF or L_LITTLEHEAL or L_WSATURATION;)
  );

  {Обычное насыщение жидкостью и ее масса}
  LiquidSaturation = 40;
  LiquidMass       = 0.3;

var
  NowLiquidState : array[1..LiquidAmount] of byte;
  NowLiquidColor : array[1..LiquidAmount] of byte;

procedure GenerateColorAndStateOfLiquids;                    // Создать список цветов и состояний напитков
function CreatePotion(what : byte; am : integer) : TItem;    // Создать напиток
procedure DrinkLiquid(LiquidId : byte; var Mon : TMonster);  // Применить эффект напитка

implementation

{ Создать список цветов и состояний напитков }
procedure GenerateColorAndStateOfLiquids;
var
  i,k,j : byte;
  yes   : boolean;
begin
  for i:=1 to LiquidAmount do
  begin
    // Состояние
    if AllLiquid[i].state = 0 then
    begin
      repeat
        k := Random(LiquidStateAmount)+1;
        yes := TRUE;
        for j:=1 to LiquidAmount do
          if NowLiquidState[j] = k then yes := FALSE;
        for j:=1 to LiquidAmount do
          if AllLiquid[j].state = k then yes := FALSE;
      until
        yes;
    end else
      k := AllLiquid[i].state;
    NowLiquidState[i] := k;
    // Цвет
    if AllLiquid[i].state = 0 then
    begin
      repeat
        k := Random(crAmount)+1;
        yes := TRUE;
        for j:=1 to LiquidAmount do
          if NowLiquidColor[j] = k then yes := FALSE;
        for j:=1 to LiquidAmount do
          if AllLiquid[j].color = k then yes := FALSE;
      until
        yes;
    end else
      k := AllLiquid[i].color;
    NowLiquidColor[i] := k;
  end;
end;

{ Создать напиток }
function CreatePotion(what : byte; am : integer) : TItem;
var
  I : TItem;
begin
  I := CreateItem(idBOTTLE, am, 0);
  I.liquidid := what;
  if (IsFlag(AllLiquid[I.LiquidId].flags, L_WMASS)) then
    I.mass := I.mass + (LiquidMass * 2) else
      I.mass := I.mass + LiquidMass;    
  Result := I;
end;

{ Применить эффект напитка }
procedure DrinkLiquid(LiquidId : byte; var Mon : TMonster);
var
  a : integer;
begin
  with AllLiquid[LiquidId] do
  begin
    // Выполнить эффект
    case effect of
      leHEAL :
      begin
        if (power = 100) and not (IsFlag(flags, L_RANDOMPOWER)) then
        begin
          //Исцелить
          a := Mon.Rhp - Mon.hp;
          if a > 0 then
          begin
            Mon.hp := Mon.RHp;
            if Mon.id = 1 then
              AddMsg('#Ты полностью исцелил{ся/ась}!# ($+'+IntToStr(a)+'$)',0);
          end else
            begin
              if Mon.id = 1 then
                AddMsg('Ничего не произошло.',0);
            end;
        end else
          begin
            // Подлечить
            a := Random(Power)+1;
            if Mon.Hp + a > Mon.RHp then
              a := Mon.RHp - Mon.Hp;
            inc(Mon.Hp, a);
            if Mon.Hp >= Mon.RHp then
            begin
              Mon.Hp := Mon.RHp;
              if Mon.id = 1 then
              begin
               if a > 0 then
                AddMsg('#Ты полностью исцелил{ся/ась}!# ($+'+IntToStr(a)+'$)',0) else
                  AddMsg('Ничего не произошло.',0);
              end;
            end else
              begin
                if Mon.id = 1 then
                  AddMsg('#Тебе стало немного лучше# ($+'+IntToStr(a)+'$)',0);
              end;
          end;
      end;
      leDRUNK :
      begin
        if Mon.status[stDRUNK] <= 500 then
        begin
          if Mon.id = 1 then
          begin
            case Random(3)+1 of
              1 : AddMsg('Ммм... Тебе понравилось!',0);
              2 : AddMsg('Пххх.. Отдаёт спиртом...',0);
              3 : AddMsg('Ты довольно быстро осушил{/a} бутылку до донышка. Не плохо. Освежает!',0);
            end;
          end;
          inc(Mon.status[stDRUNK], Power);
        end else
          begin
            if Mon.id = 1 then
              AddMsg('Ты попытал{ся/ась} выпить еще, но случайно бутылка выскользнула из твоих рук и разбилась!..',0);
          end;
      end;
    end;
    // Посмотреть дополнительные эффекты по флагам
    if (IsFlag(flags, L_LITTLEHEAL)) then
    begin
      a := Random(4)+1;
      if Mon.Hp + a > Mon.RHp then
        a := Mon.RHp - Mon.Hp;
      inc(Mon.Hp, a);
      if Mon.Hp >= Mon.RHp then
      begin
        Mon.Hp := Mon.RHp;
        if Mon.id = 1 then
        begin
         if a > 0 then
          AddMsg('#Ты полностью исцелил{ся/ась}!# ($+'+IntToStr(a)+'$)',0);
        end;
      end else
        begin
          if Mon.id = 1 then
            AddMsg('#Тебе стало немного лучше# ($+'+IntToStr(a)+'$)',0);
        end;
    end;
    // Немного утолить чувство голода
    if not (IsFlag(flags, L_NOSATURATION)) then
    begin
      if (IsFlag(flags, L_WSATURATION)) then
        // Двойное насыщение (жирный напиток)
        Mon.status[stHUNGRY] := Mon.status[stHUNGRY] - Round(LiquidSaturation * 2 * (1 + (Mon.ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100)) else
          // Обычное насыщение
          Mon.status[stHUNGRY] := Mon.status[stHUNGRY] - Round(LiquidSaturation * (1 + (Mon.ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
    end;
  end;
end;

end.
