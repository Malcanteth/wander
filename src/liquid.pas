unit liquid;

interface

uses
  Cons, Flags, Utils, Player, Monsters, Msg, SysUtils, Ability, Items;

type
  TAllLiquid = record
    name: string[40]; // ���� �����, �� "����� + name"; ���� ������ ��������, �� "������� + name"
    state: byte; // ���� 0 - ��������� ���������, ����� �������������
    color: byte; // ���� 0 - ��������� ����, ����� �������������
    effect: byte; // ��� ������� �� �����
    power: byte; // �������� ������� (% ��� ������� � ����������� �� �������)
    chance: byte; // ���� ���������
    Flags: longword; // �����
  end;

const
  { ��������� �������� }
  LiquidStateAmount = 5;

  lsDENSE = 1;
  lsGAS = 2;
  lsSTINKY = 3;
  lsSMELLY = 4;
  lsGURGL = 5;

  LiquidState: array [1 .. LiquidStateAmount] of string = ('������', '�����������', '�������', '���������', '����������');

  { ���� �������� }
  LiquidColor: array [1 .. crAmount] of string = ('�������', '�����', '�������', '�������', '�������', '����������', '����������', '�����', '�����',
    '������', '������-�����', '������-�������', '������-�������', '������-�����', '���������', '�������', '�����������', '��������', '����������');

  { ������� }
  LiquidEffectsAmount = 3;

  leHEAL = 1;
  leDRUNK = 2;

  { �������� ��������� }
  LiquidAmount = 4;

  AllLiquid: array [1 .. LiquidAmount] of TAllLiquid = (
    //
    (name: '�������'; state: 0; color: 0; effect: leHEAL; power: 15; chance: 40; Flags: NOF or L_RANDOMPOWER;),
    //
    (name: '���������'; state: 0; color: 0; effect: leHEAL; power: 100; chance: 15; Flags: NOF;),
    //
    (name: '�������� ����'; state: lsGAS; color: crBROWN; effect: leDRUNK; power: 130; chance: 20; Flags: NOF or L_LITTLEHEAL;),
    //
    (name: '������'; state: lsDENSE; color: crWHITE; effect: leDRUNK; power: 10; chance: 25; Flags: NOF or L_LITTLEHEAL or L_WSATURATION;)
    //
    );

  { ������� ��������� ��������� � �� ����� }
  LiquidSaturation = 40;
  LiquidMass = 0.3;

var
  NowLiquidState: array [1 .. LiquidAmount] of byte;
  NowLiquidColor: array [1 .. LiquidAmount] of byte;

procedure GenerateColorAndStateOfLiquids; // ������� ������ ������ � ��������� ��������
function CreatePotion(what: byte; am: integer): TItem; // ������� �������
procedure DrinkLiquid(LiquidId: byte; var Mon: TMonster); // ��������� ������ �������

implementation

{ ������� ������ ������ � ��������� �������� }
procedure GenerateColorAndStateOfLiquids;
var
  i, k, j: byte;
  yes: boolean;
begin
  for i := 1 to LiquidAmount do
  begin
    // ���������
    if AllLiquid[i].state = 0 then
    begin
      repeat
        k := Random(LiquidStateAmount) + 1;
        yes := TRUE;
        for j := 1 to LiquidAmount do
          if NowLiquidState[j] = k then
            yes := FALSE;
        for j := 1 to LiquidAmount do
          if AllLiquid[j].state = k then
            yes := FALSE;
      until yes;
    end
    else
      k := AllLiquid[i].state;
    NowLiquidState[i] := k;
    // ����
    if AllLiquid[i].state = 0 then
    begin
      repeat
        k := Random(crAmount) + 1;
        yes := TRUE;
        for j := 1 to LiquidAmount do
          if NowLiquidColor[j] = k then
            yes := FALSE;
        for j := 1 to LiquidAmount do
          if AllLiquid[j].color = k then
            yes := FALSE;
      until yes;
    end
    else
      k := AllLiquid[i].color;
    NowLiquidColor[i] := k;
  end;
end;

{ ������� ������� }
function CreatePotion(what: byte; am: integer): TItem;
var
  i: TItem;
begin
  i := CreateItem(idBOTTLE, am, 0);
  i.LiquidId := what;
  if (IsFlag(AllLiquid[i.LiquidId].Flags, L_WMASS)) then
    i.mass := i.mass + (LiquidMass * 2)
  else
    i.mass := i.mass + LiquidMass;
  Result := i;
end;

{ ��������� ������ ������� }
procedure DrinkLiquid(LiquidId: byte; var Mon: TMonster);
var
  a: integer;
begin
  with AllLiquid[LiquidId] do
  begin
    // ��������� ������
    case effect of
      leHEAL:
        begin
          if (power = 100) and not(IsFlag(Flags, L_RANDOMPOWER)) then
          begin
            // ��������
            a := Mon.Rhp - Mon.hp;
            if a > 0 then
            begin
              Mon.hp := Mon.Rhp;
              if Mon.id = 1 then
                AddMsg('#�� ��������� �������{��/���}!# ($+' + IntToStr(a) + '$)', 0);
            end
            else
            begin
              if Mon.id = 1 then
                AddMsg('������ �� ���������.', 0);
            end;
          end
          else
          begin
            // ���������
            a := Random(power) + 1;
            if Mon.hp + a > Mon.Rhp then
              a := Mon.Rhp - Mon.hp;
            inc(Mon.hp, a);
            if Mon.hp >= Mon.Rhp then
            begin
              Mon.hp := Mon.Rhp;
              if Mon.id = 1 then
              begin
                if a > 0 then
                  AddMsg('#�� ��������� �������{��/���}!# ($+' + IntToStr(a) + '$)', 0)
                else
                  AddMsg('������ �� ���������.', 0);
              end;
            end
            else
            begin
              if Mon.id = 1 then
                AddMsg('#���� ����� ������� �����# ($+' + IntToStr(a) + '$)', 0);
            end;
          end;
        end;
      leDRUNK:
        begin
          if Mon.status[stDRUNK] <= 500 then
          begin
            if Mon.id = 1 then
            begin
              case Random(3) + 1 of
                1:
                  AddMsg('���... ���� �����������!', 0);
                2:
                  AddMsg('����.. ����� �������...', 0);
                3:
                  AddMsg('�� �������� ������ ������{/a} ������� �� �������. �� �����. ��������!', 0);
              end;
            end;
            inc(Mon.status[stDRUNK], power);
          end
          else
          begin
            if Mon.id = 1 then
              AddMsg('�� �������{��/���} ������ ���, �� �������� ������� ������������ �� ����� ��� � ���������!..', 0);
          end;
        end;
    end;
    // ���������� �������������� ������� �� ������
    if (IsFlag(Flags, L_LITTLEHEAL)) then
    begin
      a := Random(4) + 1;
      if Mon.hp + a > Mon.Rhp then
        a := Mon.Rhp - Mon.hp;
      inc(Mon.hp, a);
      if Mon.hp >= Mon.Rhp then
      begin
        Mon.hp := Mon.Rhp;
        if Mon.id = 1 then
        begin
          if a > 0 then
            AddMsg('#�� ��������� �������{��/���}!# ($+' + IntToStr(a) + '$)', 0);
        end;
      end
      else
      begin
        if Mon.id = 1 then
          AddMsg('#���� ����� ������� �����# ($+' + IntToStr(a) + '$)', 0);
      end;
    end;
    // ������� ������� ������� ������
    if not(IsFlag(Flags, L_NOSATURATION)) then
    begin
      if (IsFlag(Flags, L_WSATURATION)) then
        // ������� ��������� (������ �������)
        Mon.status[stHUNGRY] := Mon.status[stHUNGRY] -
          Round(LiquidSaturation * 2 * (1 + (Mon.Ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100))
      else
        // ������� ���������
        Mon.status[stHUNGRY] := Mon.status[stHUNGRY] -
          Round(LiquidSaturation * (1 + (Mon.Ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
    end;
  end;
end;

end.
