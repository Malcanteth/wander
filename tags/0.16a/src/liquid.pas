unit liquid;

interface

uses
  Cons, Flags, Utils, Player, Monsters, Msg, SysUtils, Ability, Items;

type
  TAllLiquid = record
    name    : string[40];  // ���� �����, �� "����� + name"; ���� ������ ��������, �� "������� + name"
    state   : byte;        // ���� 0 - ��������� ���������, ����� �������������
    color   : byte;        // ���� 0 - ��������� ����, ����� �������������
    effect  : byte;        // ��� ������� �� �����
    power   : byte;        // �������� ������� (% ��� ������� � ����������� �� �������)
    chance  : byte;        // ���� ���������
    flags   : longword;    // �����
  end;

const
  {��������� ��������}
  LiquidStateAmount = 5;

  lsDENSE  = 1;
  lsGAS    = 2;
  lsSTINKY = 3;
  lsSMELLY = 4;
  lsGURGL  = 5;


  LiquidState : array[1..LiquidStateAmount] of string =
  ('������', '�����������', '�������', '���������', '����������');

  {���� ��������}
  LiquidColor : array[1..crAmount] of string =
  ('�������', '�����', '�������', '�������', '�������', '����������', '����������', '�����', '�����', '������',
   '������-�����', '������-�������', '������-�������', '������-�����', '���������', '����������');

  {�������}
  LiquidEffectsAmount = 3;

  leHEAL      = 1;
  leDRUNK     = 2;

  {�������� ���������}
  LiquidAmount = 4;

  AllLiquid : array[1..LiquidAmount] of TAllLiquid =
  (
    (name : '�������'; state : 0; color : 0; effect : leHEAL; power : 15; chance : 40; flags : NOF or L_RANDOMPOWER;),
    (name : '���������'; state : 0; color : 0;  effect : leHEAL; power : 100; chance : 15; flags : NOF;),
    (name : '�������� ����'; state : lsGAS; color : crBROWN; effect : leDRUNK; power : 130; chance : 20; flags : NOF or L_LITTLEHEAL;),
    (name : '������'; state : lsDENSE; color : crWHITE; effect : leDRUNK; power : 10; chance : 25; flags : NOF or L_LITTLEHEAL or L_WSATURATION;)
  );

  {������� ��������� ��������� � �� �����}
  LiquidSaturation = 40;
  LiquidMass       = 0.3;

var
  NowLiquidState : array[1..LiquidAmount] of byte;
  NowLiquidColor : array[1..LiquidAmount] of byte;

procedure GenerateColorAndStateOfLiquids;                    // ������� ������ ������ � ��������� ��������
function CreatePotion(what : byte; am : integer) : TItem;    // ������� �������
procedure DrinkLiquid(LiquidId : byte; var Mon : TMonster);  // ��������� ������ �������

implementation

{ ������� ������ ������ � ��������� �������� }
procedure GenerateColorAndStateOfLiquids;
var
  i,k,j : byte;
  yes   : boolean;
begin
  for i:=1 to LiquidAmount do
  begin
    // ���������
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
    // ����
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

{ ������� ������� }
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

{ ��������� ������ ������� }
procedure DrinkLiquid(LiquidId : byte; var Mon : TMonster);
var
  a : integer;
begin
  with AllLiquid[LiquidId] do
  begin
    // ��������� ������
    case effect of
      leHEAL :
      begin
        if (power = 100) and not (IsFlag(flags, L_RANDOMPOWER)) then
        begin
          //��������
          a := Mon.Rhp - Mon.hp;
          if a > 0 then
          begin
            Mon.hp := Mon.RHp;
            if Mon.id = 1 then
              AddMsg('#�� ��������� �������{��/���}!# ($+'+IntToStr(a)+'$)',0);
          end else
            begin
              if Mon.id = 1 then
                AddMsg('������ �� ���������.',0);
            end;
        end else
          begin
            // ���������
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
                AddMsg('#�� ��������� �������{��/���}!# ($+'+IntToStr(a)+'$)',0) else
                  AddMsg('������ �� ���������.',0);
              end;
            end else
              begin
                if Mon.id = 1 then
                  AddMsg('#���� ����� ������� �����# ($+'+IntToStr(a)+'$)',0);
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
              1 : AddMsg('���... ���� �����������!',0);
              2 : AddMsg('����.. ����� �������...',0);
              3 : AddMsg('�� �������� ������ ������{/a} ������� �� �������. �� �����. ��������!',0);
            end;
          end;
          inc(Mon.status[stDRUNK], Power);
        end else
          begin
            if Mon.id = 1 then
              AddMsg('�� �������{��/���} ������ ���, �� �������� ������� ������������ �� ����� ��� � ���������!..',0);
          end;
      end;
    end;
    // ���������� �������������� ������� �� ������
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
          AddMsg('#�� ��������� �������{��/���}!# ($+'+IntToStr(a)+'$)',0);
        end;
      end else
        begin
          if Mon.id = 1 then
            AddMsg('#���� ����� ������� �����# ($+'+IntToStr(a)+'$)',0);
        end;
    end;
    // ������� ������� ������� ������
    if not (IsFlag(flags, L_NOSATURATION)) then
    begin
      if (IsFlag(flags, L_WSATURATION)) then
        // ������� ��������� (������ �������)
        Mon.status[stHUNGRY] := Mon.status[stHUNGRY] - Round(LiquidSaturation * 2 * (1 + (Mon.ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100)) else
          // ������� ���������
          Mon.status[stHUNGRY] := Mon.status[stHUNGRY] - Round(LiquidSaturation * (1 + (Mon.ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
    end;
  end;
end;

end.
