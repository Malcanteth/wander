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
  ShowProc : boolean;                          // ���������� ��������

procedure SkillsAndAbilitys;                   // �������� ���� '������ � �����������'

procedure WpnSkills;                           // ���������� ��������� ������
function RateSkill(n : real) : byte;           // �������� �������� ������
function RateToStr(n : byte) : string;         // ������ �������� ������
function ColorRateSkill(n : real) : longword;  // ���� ������� ��������
function IsInNewAreaSkill(was, now : real)     // ���� ������� �������� ������ ������� � ������ ������
                                  : boolean;
procedure ShowAbilitys;                        // �������� ���� �� �������������

implementation

uses
  Player, Main, Conf, msg;

{ �������� ���� '������ � �����������' }
procedure SkillsAndAbilitys;
var j: byte;
begin
  MainForm.Cls;
  StartDecorating('<-������ � �����������->', FALSE);
  GameMenu := true;
  with TMenu.Create(38,14) do
  begin
    Add('������������ �����');
    Add('������ ��������� �������');
    Add('��������� ������');
    Add('��������� �����������');
    addBreakKey(32);
    j := Run;
    Free;
  end;
  GameMenu := false;
  case j of
    3 : // ��������� �����������
      WpnSkills;
    4 : // ��������� �����������
      ShowAbilitys;
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
  Key: word;

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
  GameMenu := true;
  repeat
    MainForm.Cls;
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
    // ������� ���
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
        MainForm.DrawString(15, (top+1), cBLUEGREEN, '� ���� ��� ������� ������� � ���� �������.');
      end;
    // ������� ���
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
        MainForm.DrawString(15, ((top+10)+1), cBLUEGREEN, '� ���� ��� ������� ������� � ���� �������.');
      end;
    // ���������� ������
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
      MainForm.DrawString(15, ((top+20)+1), cBLUEGREEN, '� ���� ��� ������� ������� � ���� �������.');
    MainForm.Redraw;
    repeat
      Key :=  getKey;
    until Key in [13,27,32,220];
    case Key of
      13,27,32: break;
      220: ShowProc := not ShowProc;
    end;
  until false;
  GameMenu := false;
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

{ �������� ���� �� ������������� }
procedure ShowAbilitys;

  procedure ShowAbilityDesc(Index: byte);
  var
    i, j: byte;
    s: string;
  begin
    j := 0;
    for i:=1 to AbilitysAmount do
    begin
      if pc.ability[i]>0 then inc(j);
      if j = Index then
      begin
        s := AbilitysData[i].descr;
        break;
      end;
    end;
    DrawBorder(5,37,90,2,crLIGHTGRAY);
    MainForm.DrawString((((85-length(s)) div 2) + 8) , 38, cWHITE, s);
  end;

var
  i: byte;
  s: string;

begin
  MainForm.Cls;
  StartDecorating('<-�����������->', FALSE);
  // �������� ������ ������������
  GameMenu := true;
  s := '';
  with TMenu.Create(5,3,'*', cORANGE, cBROWN, cRED) do
  begin
    for i:=1 to AbilitysAmount do
      if pc.Ability[i] > 0 then
      begin
        s := AbilitysData[i].name;
        Add(s);
        MainForm.DrawString(10+Length(s), (2+Count), cGRAY, '(');
        MainForm.DrawString(11+Length(s), (2+Count), cLIGHTGRAY, IntToStr(pc.ability[i])+' �������');
        MainForm.DrawString(20+Length(s), (2+Count), cGRAY, ')');
      end;
    if Count > 0 then
    begin
      addBreakKey(32);
      setCallback(@ShowAbilityDesc);
      Run;
    end
    else
    begin
      // ������������ ���� ���
      MainForm.DrawString(5, 5, cLIGHTGRAY, '���� � ���� ��� ������� ��������� ������������.');
      Mainform.Redraw;
      repeat
      until getKey in [13,27,32];
    end;
    Free;
  end;
  GameMenu := false;
end;


end.
