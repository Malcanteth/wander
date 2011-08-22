unit ability;

interface

uses
  Cons, Utils, Windows, SysUtils;

type
  TAbility = record
    name : string[50];
    descr : string;
    koef : real;      // ����������
  end;

const
  { ���-�� �����������}
  AbilitysAmount            = 9;

  AbilitysData : array[1..AbilitysAmount] of TAbility =
  (
    (name  : '������� ���������';
     descr : '������� ��������� �� ���� �� �������';
     koef  : 20;),
    (name  : '��������������';
     descr : '�� ������ ������ ��� ������';
     koef  : 1;),
    (name  : '������������ �������';
     descr : '���������� ���� �������� ����������';
     koef  : 2;),
    (name  : '���������� �����������';
     descr : '���� ���� ������������ ������� �������, ��� ������';
     koef  : 0.5;),
    (name  : '��������';
     descr : '������� ���� ������� �� ���������� �� ����� �����';
     koef  : 1;),
    (name  : '����������';
     descr : '�� ���� ����������� �� ���� ����������';
     koef  : 1;),
    (name  : '������� �����';
     descr : '���� ���� ������� ������� ���������� ������ �� ���';
     koef  : 1;),
    (name  : '������������';
     descr : '���������� �������� ���������� ����� ��������';
     koef  : 5;),
    (name  : '��������������';
     descr : '�� ������� �������� ��������� �����';
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

  { ������ � ���� ������}
  CLOSEFIGHTAMOUNT         = 6;

  CLOSE_TWO               = 1;      // ���������
  CLOSE_BLADE             = 2;      // ������
  CLOSE_CLUB              = 3;      // ������
  CLOSE_STAFF             = 4;      // ����� � ������
  CLOSE_AXE               = 5;      // ������
  CLOSE_ARM               = 6;      // ��� ������

  FARFIGHTAMOUNT          = 5;

  FAR_THROW               = 1;      // ��������
  FAR_BOW                 = 2;      // ���
  FAR_SLING               = 3;      // �����
  FAR_PIPE                = 4;      // ������
  FAR_CROSS               = 5;      // �������

  { ���� ����� }
  ARMORTYPEAMOUNT         = 3;

  ARMOR_CLOTHES           = 1;
  ARMOR_LIGHT             = 2;
  ARMOR_HEAVY             = 3;

  { ����� }
  MAGICSCHOOLAMOUNT       = 5;      // ���-�� ������������� �����

  MAGICSCHOOLOFFIRE       = 1;      // ����� ������ ����
  MAGICSCHOOLOFWATER      = 2;      // ����� ������ ����
  MAGICSCHOOLOFEARTH      = 3;      // ����� ������ �����
  MAGICSCHOOLOFAIR        = 4;      // ����� ������ �������
  MAGICSCHOOLOFDEATH      = 5;      // ����� ������

  CLOSEWPNNAME : array[1..CLOSEFIGHTAMOUNT] of string =
  (
    '��������� ������', '������', '������', '����� � ������',
    '������', '���������� ���'
  );
  FARWPNNAME : array[1..FARFIGHTAMOUNT] of string =
  (
    '������/��������', '����', '�����', '������� ������', '��������'
  );
  ARMORTYPENAME : array[1..ARMORTYPEAMOUNT] of string =
  (
    '������', '������ �����', '������� �����'
  );

var
  FullAbilitys : array[1..AbilitysAmount] of byte;
  ShowProc : boolean;                          // ���������� ��������

procedure SkillsAndAbilitys;                   // �������� ���� '������ � �����������'

procedure WpnSkills;                           // ���������� ��������� ������
function RateSkill(n : real) : byte;           // �������� �������� ������
function RateToStr(n : byte) : string;         // ������ �������� ������
function ColorRateSkill(n : real) : longword;  // ���� ������� ��������
function IsInNewAreaSkill(was, now : real)     // ���� ������� �������� ������ ������� � ������ ������
                                  : boolean;
                                  
function BestWPNCL : byte;                     // ����� ����������� ����� � ����. ���
function HowManyBestWPNCL : byte;              // ������� �������������������� � ����. ���
function OneOfTheBestWPNCL(i : byte): boolean; // ���� �� ����� ����. �������
function BestWPNFR : byte;                     // ����� ����������� ����� � ������� ���
function HowManyBestWPNFR : byte;              // ������� �������������������� � ������� ���
function OneOfTheBestWPNFR(i : byte): boolean; // ���� �� ����� ����. �������

procedure ShowAbilitys;                        // �������� ���� �� �������������

implementation

uses
  Player, Main, Conf;

{ �������� ���� '������ � �����������' }
procedure SkillsAndAbilitys;
begin
  StartDecorating('<-������ � �����������->', FALSE);
  with Screen.Canvas do
  begin
    Font.Color := cBROWN;
    TextOut(38*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(42*CharX, 15*CharY, '������������ �����');
    Font.Color := cBROWN;
    TextOut(38*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(42*CharX, 16*CharY, '������ ��������� �������');
    Font.Color := cBROWN;
    TextOut(38*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(42*CharX, 17*CharY, '��������� ������');
    Font.Color := cBROWN;
    TextOut(38*CharX, 18*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(42*CharX, 18*CharY, '��������� �����������');
    Font.Color := cYELLOW;
    TextOut(39*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ��������� ������ }
procedure WpnSkills;
const
  s1 = ' ������� ��� ';
  s2 = ' ������� ��� ';
  s3 = ' ����� ';
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
  StartDecorating('<-��������� ������->', FALSE);
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
  // ������� ������
  with Screen.Canvas do
  begin
    // �������� ���
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
        TextOut(15*CharX, (top+1)*CharY, '� ���� ��� ������� ������� � ���� �������.');
      end;
    // ������� ���
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
        TextOut(15*CharX, ((top+10)+1)*CharY, '� ���� ��� ������� ������� � ���� �������.');
      end;
    // ���������� ������
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
        TextOut(15*CharX, ((top+20)+1)*CharY, '� ���� ��� ������� ������� � ���� �������.');
      end;
  end;
end;

{ �������� �������� ������ }
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
    1 : Result := '�����������';
    2 : Result := '���������';
    3 : Result := '�������';
    4 : Result := '������';
    5 : Result := '������';
    6 : Result := '���������';
    7 : Result := '�����';
    8 : Result := '������';
  end;
end;

{ ���� }
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

{ ����� ����������� ����� � ����. ��� }
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

{ ������� �������������������� � ����. ��� }
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

{ ���� �� ����� ����. ������� }
function OneOfTheBestWPNCL(i : byte): boolean;
begin
  Result := FALSE;
  if pc.closefight[i] = pc.closefight[BestWPNCL] then Result := TRUE;
end;

{ ����� ����������� ����� � ������� ��� }
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

{ ������� �������������������� � ������� ��� }
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

{ ���� �� ����� ����. ������� }
function OneOfTheBestWPNFR(i : byte): boolean;
begin
  Result := FALSE;
  if pc.farfight[i] = pc.farfight[BestWPNFR] then Result := TRUE;
end;

{ �������� ���� �� ������������� }
procedure ShowAbilitys;
var
  i, a         : byte;
begin
  StartDecorating('<-�����������->', FALSE);
  // �������� ������ ������������
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
    // ���� ����������� ����
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
          TextOut((9+Length(AbilitysData[FullAbilitys[i]].name)+2)*CharX, (2+i)*CharY, IntToStr(pc.ability[FullAbilitys[i]])+' �������');
          Font.Color := cGRAY;
          TextOut((9+Length(AbilitysData[FullAbilitys[i]].name)+11)*CharX, (2+i)*CharY, ')');
        end;
      Font.Color := cRED;
      TextOut(6*CharX, (2+MenuSelected)*CharY, '*');
      // ��������
      DrawBorder(5,37,90,2);
      Font.Color := cWHITE;
      TextOut((((85-length(AbilitysData[FullAbilitys[MenuSelected]].descr)) div 2) + 8) * CharX, 38*CharY, AbilitysData[FullAbilitys[MenuSelected]].descr);
    end else
      // ������������ ���� ���
      begin
        Font.Color := cLIGHTGRAY;
        TextOut(5*CharX, 5*CharY, '���� � ���� ��� ������� ��������� ������������.');
      end;
  end;
end;


end.
