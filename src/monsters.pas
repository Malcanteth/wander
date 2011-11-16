unit monsters;

interface

uses
  Utils, Cons, Tile, Flags, Msg, Items, SysUtils, Ability, Windows, Main, Conf;

type
  TMonster = object
    id              : byte;
    idinlist        : byte;
    name            : string[13];                  // �� ���������� ���
    x, y,                                          // ����������
    aim, aimx, aimy : byte;                        // ����, ��������� ��������� ����������
    energy          : integer;                     // �������
    Hp, RHp         : integer;                     // ��������
    Mp, RMp         : integer;                     // ����
    speed, Rspeed   : word;                        // ��������
    los, Rlos       : byte;                        // ����� ������
    relation        : byte;                        // ��������� � ����� (0�����,1��������)
    eq              : array[1..14] of TItem;       // ����������
    inv             : array[1..MaxHandle] of TItem;// �������� �������
    invmass         : real;                        // ����� ��������� � ����������
    //��������
    Rstr,str,                                      //����
    Rdex,dex,                                      //��������
    Rint,int        : byte;                        //���������
    //����� ������ ������, ��������� ������
    attack, defense : integer;
    //� �����, � ������
    todmg, todef    : integer;
    //����
    felldown        : boolean;
    //�������
    ability         : array[1..AbilitysAmount] of byte;// �����������
    //������� (0-�����������, 1-���������, 2-������
    tactic          : byte;
    //��������� ������
    closefight      : array[1..CLOSEFIGHTAMOUNT] of real;
    farfight        : array[1..FARFIGHTAMOUNT] of real;
    magicfight      : array[1..MAGICSCHOOLAMOUNT] of real;
    //
    atr             : array[1..2] of byte;             // ������������ ��������
    //
    status          : array[1..2] of integer;         // �������� (1-�����)


    procedure ClearMonster;                           // ��������
    function Replace(nx, ny : integer) : byte;        // ���������� �������������
    procedure DoTurn;                                 // AI
    function DoYouSeeThis(ax,ay : byte) : boolean;    // ����� �� ������ �����
    function MoveToAim(obstacle : boolean) : boolean; // ������� ��� � ����
    procedure MoveRandom;                             // ��������� ��������
    function Move(dx,dy : integer) : boolean;         // ����������� �������
    function WoundDescription : string;               // ������� �������� ��������� ��������
    procedure TalkToMe;                               // ���������� � ���-������
    procedure Fight(var Victim : TMonster; CA : byte);// ������� (CA: 1 - ����������, 2 - ������ ����!)
    procedure Fire(var Victim : TMonster);            // ��������
    procedure AttackNeutral(Victim : TMonster);       // ��������� ������������
    procedure KillSomeOne(Victim : byte);             // �������� ����� ��������
    procedure Death;                                  // �������
    procedure GiveItem(var Victim : TMonster;
                                 var GivenItem : TItem); // ������ ����
    procedure BloodStreem(dx,dy : shortint);
    function PickUp(Item : TItem;FromEq : boolean;
                             amount : integer) : byte;// ��������� ���� � ��������� (0-�������,1-������ ���,2-��� �����,3-����������
    function MaxMass : real;
    procedure DeleteInvItem(var I : TItem;
                      amount : integer);              // ������� ������� �� ���������
    procedure RefreshInventory;                       // ��������� ���������
    function ColorOfTactic: longword;                 // ������� ���� ������� ���� ������� ��� ������������� �������
    function TacticEffect(situation : byte) : real;   // ������� ��������� (0.5, 1 ��� 2 - ������ �� �������)
    function EquipItem(Item : TItem) : byte;          // ��������� ������� (0-�������,1-������ ������)
    function ExStatus(situation : byte) : string;     // ������� �������� ��������� ������� (���������, ��������� � ��)
    function FullName(situation : byte;
                   writename : boolean) : string;     // ������� ������ ��� �������
    procedure DecArrows;                              // ����� ������
    function WhatClass : byte;                        // �����
    function ClName(situation : byte) : string;       // ������� �������� ������
    procedure PrepareSkills;                          // ��������� ���� ������ � ����������� � ����������� �� ������
    procedure FavWPNSkill;                            // ������ �� ������� ��������� ������� - �� ��������� � ���� �����. ������
    function BestWPNCL : byte;                        // ����� ����������� ����� � ����. ���
    function HowManyBestWPNCL : byte;                 // ������� �������������������� � ����. ���
    function OneOfTheBestWPNCL(i : byte): boolean;    // ���� �� ����� ����. �������
    function BestWPNFR : byte;                        // ����� ����������� ����� � ������� ���
    function HowManyBestWPNFR : byte;                 // ������� �������������������� � ������� ���
    function OneOfTheBestWPNFR(i : byte): boolean;    // ���� �� ����� ����. �������
    function ClassColor : longword;                   // ���� ������
  end;

  TMonData = record
    name1, name2, name3, name4, name5, name6 : string[40];  // �������� (1���,2����,3����,4���,5���,6���)
    char                       : string[1];       // ������
    color                      : byte;            // ����
    gender                     : byte;
    hp                         : word;            // ��������
    speed                      : word;            // ��������
    los                        : byte;            // ����� ������
    str, dex, int, at, def     : byte;
    exp                        : byte;
    mass                       : real;
    coollevel                  : byte;
    flags                      : longlong;        // ������
  end;

  TMonClass = record
    name1m, name2m, name3m, name4m, name5m, name6m : string[40];  // �������� ������ (1���,2����,3����,4���,5���,6���) (���.)
    name1f, name2f, name3f, name4f, name5f, name6f : string[40];  // �������� ������ (1���,2����,3����,4���,5���,6���) (���.)
  end;

const
  { ��������� ���������� �������� }
  MonstersAmount = 23;

  {  �������� �������� }
  MonstersData : array[1..MonstersAmount] of TMonData =
  (
    ( name1 : '��'; name2 : '����'; name3 : '����'; name4 : '�����'; name5 : '����';
      char : '@'; color : crLIGHTBLUE; gender : 10;
      flags : NOF or M_NEUTRAL or M_CLASS;
    ),
    ( name1 : '������'; name2 : '������'; name3 : '������'; name4 : '�������'; name5 : '������'; name6 : '�������';
      char : 'h'; color : crBROWN; gender : genMALE;
      hp : 30; speed : 100; los : 6; str : 5; dex : 5; int : 3; at : 7; def : 7;
      exp : 5; mass : 60.4;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '����������'; name2 : '����������'; name3 : '����������'; name4 : '�����������'; name5 : '����������'; name6 : '���������';
      char : 'h'; color : crLIGHTRED; gender : genFEMALE;
      hp : 18; speed : 100; los : 6; str : 3; dex : 6; int : 4;  at : 4; def : 5;
      exp : 3; mass : 40.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '����������'; name2 : '����������'; name3 : '����������'; name4 : '�����������'; name5 : '����������'; name6 : '���������';
      char : 't'; color : crYELLOW; gender : genMALE;
      hp : 45; speed : 110; los : 6; str : 7; dex : 5; int : 7; at : 19; def : 20;
      exp : 15; mass : 55.3;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS  or M_TACTIC;
    ),
    ( name1 : '�����'; name2 : '������'; name3 : '������'; name4 : '�������'; name5 : '������'; name6 : '�������';
      char : 'P'; color : crRANDOM; gender : genMALE;
      hp : 666; speed : 200; los : 8; str : 99; dex : 99; int : 99;  at : 25; def : 50;
      exp : 255; mass : 58.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '�����'; name2 : '�����'; name3 : '�����'; name4 : '������'; name5 : '�����'; name6 : '����';
      char : 'r'; color : crBROWN; gender : genFEMALE;
      hp : 8; speed : 160; los : 5; str : 2; dex : 6; int : 1;  at : 2; def : 1;
      exp : 2; mass : 8.3; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '������� ����'; name2 : '������� ����'; name3 : '������� ����'; name4 : '������� �����'; name5 : '������� ����'; name6 : '������� �����';
      char : 'B'; color : crGRAY; gender : genFEMALE;
      hp : 6; speed : 220; los : 7; str : 3; dex : 8; int : 1;  at : 1; def : 2;
      exp : 4; mass : 6.8; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '����'; name2 : '�����'; name3 : '�����'; name4 : '������'; name5 : '�����'; name6 : '������';
      char : 's'; color : crWHITE; gender : genMALE;
      hp : 7; speed : 180; los : 5; str : 2; dex : 8; int : 1;  at : 2; def : 1;
      exp : 2; mass : 0.9; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '������'; name2 : '�������'; name3 : '�������'; name4 : '��������'; name5 : '�������'; name6 : '��������';
      char : 'g'; color : crGREEN; gender : genMALE;
      hp : 13; speed : 115; los : 6; str : 5; dex : 7; int : 2;  at : 5; def : 5;
      exp : 4; mass : 30.5; coollevel : 2;
      flags : NOF or M_HAVEITEMS or M_OPEN or M_TACTIC or M_CLASS;
    ),
    ( name1 : '���'; name2 : '����'; name3 : '����'; name4 : '�����'; name5 : '����'; name6 : '�����';
      char : 'o'; color : crLIGHTGREEN; gender : genMALE;
      hp : 15; speed : 105; los : 6; str : 6; dex : 6; int : 3;  at : 7; def : 7;
      exp : 5; mass : 55.0; coollevel : 3;
      flags : NOF or M_HAVEITEMS or M_OPEN or M_TACTIC or M_CLASS;
    ),
    ( name1 : '���'; name2 : '����'; name3 : '����'; name4 : '�����'; name5 : '����'; name6 : '�����';
      char : 'o'; color : crBROWN; gender : genMALE;
      hp : 20; speed : 85; los : 5; str : 9; dex : 6; int : 2;  at : 10; def : 9;
      exp : 6; mass : 70.9; coollevel : 4;
      flags : NOF or M_HAVEITEMS or M_OPEN or M_TACTIC or M_CLASS;
    ),
    ( name1 : '������ �������'; name2 : '������ �������'; name3 : '������ �������'; name4 : '������ ��������'; name5 : '������ �������'; name6 : '������ ������';
      char : 'M'; color : crCYAN; gender : genFEMALE;
      hp : 70; speed : 70; los : 2; str : 15; dex : 6; int : 3;  at : 15; def : 11;
      exp : 14; mass : 85.0; coollevel : 5;
      flags : NOF or M_ALWAYSANSWERED or M_TACTIC;
    ),
    ( name1 : '�������'; name2 : '�������'; name3 : '�������'; name4 : '��������'; name5 : '�������'; name6 : '������';
      char : 'h'; color : crBLUE; gender : genMALE;
      hp : 17; speed : 40; los : 4; str : 5; dex : 4; int : 4;  at : 6; def : 4;
      exp : 4; mass : 40.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '������'; name2 : '�������'; name3 : '�������'; name4 : '��������'; name5 : '�������'; name6 : '��������';
      char : 'b'; color : crRED; gender : genMALE;
      hp : 40; speed : 100; los : 6; str : 5; dex : 5; int : 5;  at : 7; def : 7;
      exp : 12; mass : 60.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '����������� ������ �����'; name2 : '����������� ������� ������'; name3 : '����������� ������� ������'; name4 : '����������� ������ �������'; name5 : '����������� ������� ������'; name6 : '����������� ������ �������';
      char : 'h'; color : crBLUE; gender : genMALE;
      hp : 5; speed : 20; los : 2; str : 3; dex : 2; int : 1; at : 1; def : 1;
      exp : 0; mass : 35.7;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_DRUNK or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '������������'; name2 : '������������'; name3 : '������������'; name4 : '�������������'; name5 : '������������'; name6 : '�����������';
      char : 'h'; color : crLIGHTGREEN; gender : genFEMALE;
      hp : 30; speed : 120; los : 6; str : 5; dex : 7; int : 9; at : 10; def : 10;
      exp : 10; mass : 45.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '������'; name2 : '�������'; name3 : '�������'; name4 : '��������'; name5 : '�������';  name6 : '��������';
      char : '@'; color : crRED; gender : genMALE;
      hp : 35; speed : 100; los : 5; str : 9; dex : 5; int : 4; at : 20; def : 15;
      exp : 20; mass : 67.2;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '�������'; name2 : '��������'; name3 : '��������'; name4 : '���������'; name5 : '��������'; name6 : '���������';
      char : 'c'; color : crORANGE; gender : genMALE;
      hp :7; speed : 130; los : 6; str : 1; dex : 7; int : 1;  at : 1; def : 2;
      exp : 1; mass : 1; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '������ �����'; name2 : '������� �����'; name3 : '������� �����'; name4 : '������ ������'; name5 : '������� �����'; name6 : '������ ������';
      char : 'w'; color : crYELLOW; gender : genMALE;
      hp : 8; speed : 90; los : 5; str : 2; dex : 7; int : 1;  at : 2; def : 3;
      exp : 2; mass : 2.5; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '��������'; name2 : '��������'; name3 : '��������'; name4 : '���������'; name5 : '��������';  name6 : '���������';
      char : '@'; color : crORANGE; gender : genMALE;
      hp : 30; speed : 110; los : 6; str : 7; dex : 7; int : 6; at : 15; def : 18;
      exp : 18; mass : 63.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '�������'; name2 : '��������'; name3 : '��������'; name4 : '���������'; name5 : '��������'; name6 : '���������';
      char : 'f'; color : crPURPLE; gender : genMALE;
      hp : 30; speed : 115; los : 6; str : 6; dex : 6; int : 5; at : 8; def : 8;
      exp : 8; mass : 55.0; coollevel : 4;
      flags : NOF or M_OPEN or M_NAME or M_HAVEITEMS or M_TACTIC;
    ),
    ( name1 : '���� ��������'; name2 : '���� ��������'; name3 : '���� ��������'; name4 : '����� ��������'; name5 : '���� ��������'; name6 : 'Ƹ� ��������';
      char : 'f'; color : crWHITE; gender : genFEMALE;
      hp : 20; speed : 90; los : 6; str : 3; dex : 6; int : 4;  at : 4; def : 5;
      exp : 5; mass : 45.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS or M_STAY or M_TACTIC;
    ),
    ( name1 : '�������'; name2 : '��������'; name3 : '��������'; name4 : '���������'; name5 : '��������'; name6 : '���������';
      char : 'k'; color : crRED; gender : genMALE;
      hp : 35; speed : 100; los : 6; str : 6; dex : 6; int : 3;  at : 6; def : 9;
      exp : 12; mass : 60.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS or M_TACTIC;
    )
  );

  { ���������� �������������� �������� }
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

  {�������� �������}
  MonsterClassNameAmount = 9;

  MonsterClassName : array[1..MonsterClassNameAmount] of TMonClass =
  (
    (name1m : '����'; name2m : '�����'; name3m : '�����'; name4m : '������'; name5m : '�����'; name6m : '������';
     name1f : '�����������'; name2f : '�����������'; name3f : '�����������'; name4f : '������������'; name5f : '�����������'; name6f : '����������'),
    (name1m : '������'; name2m : '�������'; name3m : '�������'; name4m : '��������'; name5m : '�������'; name6m : '��������';
     name1f : '��������'; name2f : '��������'; name3f : '��������'; name4f : '���������'; name5f : '��������'; name6f : '��������'),
    (name1m : '�������'; name2m : '��������'; name3m : '��������'; name4m : '���������'; name5m : '��������'; name6m : '���������';
     name1f : '�������'; name2f : '��������'; name3f : '��������'; name4f : '���������'; name5f : '��������'; name6f : '���������'),
    (name1m : '��������'; name2m : '���������'; name3m : '���������'; name4m : '����������'; name5m : '���������'; name6m : '����������';
     name1f : '���������'; name2f : '���������'; name3f : '���������'; name4f : '����������'; name5f : '���������'; name6f : '��������'),
    (name1m : '�������'; name2m : '�������'; name3m : '�������'; name4m : '��������'; name5m : '�������'; name6m : '�������';
     name1f : '�������'; name2f : '�������'; name3f : '�������'; name4f : '��������'; name5f : '�������'; name6f : '�������'),
    (name1m : '�����'; name2m : '������'; name3m : '������'; name4m : '�������'; name5m : '������'; name6m : '�������';
     name1f : '��������'; name2f : '��������'; name3f : '��������'; name4f : '���������'; name5f : '��������'; name6f : '��������'),
    (name1m : '����'; name2m : '�����'; name3m : '�����'; name4m : '������'; name5m : '�����'; name6m : '������';
     name1f : '�����'; name2f : '�����'; name3f : '�����'; name4f : '������'; name5f : '�����'; name6f : '����'),
    (name1m : '������'; name2m : '�������'; name3m : '�������'; name4m : '��������'; name5m : '�������'; name6m : '��������';
     name1f : '��������'; name2f : '��������'; name3f : '��������'; name4f : '���������'; name5f : '��������'; name6f : '��������'),
    (name1m : '���������'; name2m : '���������'; name3m : '���������'; name4m : '����������'; name5m : '���������'; name6m : '����������';
     name1f : '�������������'; name2f : '�������������'; name3f : '�������������'; name4f : '��������������'; name5f : '�������������'; name6f : '������������')
  );

var
  nx, ny : byte;

procedure CreateMonster(n,px,py : byte);   // ������� �������
procedure FillMonster(i,n,px,py : byte);
function RandomMonster(x,y : byte) : byte; // ������� ���������� �������
procedure MonstersTurn;                    // � ������� ������� ���� ����� �� ���

implementation

uses
  Map, Player, MapEditor, Script, Vars, SUtils, MBox, Liquid;

{ ������� ������� }
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

// ��������� �������
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
    // ���������� �����
    if IsFlag(MonstersData[id].flags, M_CLASS) then
    begin
      atr[1] := Rand(1,3);
      atr[2] := Rand(1,3);
      PrepareSkills;
      FavWPNSkill;
    end else
      begin
        // ��������� ������
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
    // �������
    tactic := 0;
    if IsFlag(MonstersData[id].flags, M_TACTIC) then
      if Random(5)+1 = 1 then
        tactic := Random(2)+1;
    // �����-�� ���������� ���� (�� ��������, ��� ��������� ���������� ��� ����������� ������!
    if IsFlag(MonstersData[id].flags, M_HAVEITEMS) then
    begin
      // ����������
      // ���������
      if id = mdKEYMAN then
      begin
        // ���� ��� ����
        PickUp(CreateItem(idGATESKEY, 1, 0), FALSE,1);
      end;
    end
  end;
end;

{ ������� ���������� ������� }
function RandomMonster(x,y : byte) : byte;
begin
  Result := 2;
end;

{ �������� }
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

{ ���������� ������������� : 0��� �������, 1��� ������,2������� ����,3������}
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

{ � ������� ������� ���� ����� �� ��� }
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
    // ���� ����, �� ������
    if FellDown then
    begin
      if NOT IsFlag(MonstersData[id].flags, M_DRUNK) then
        FellDown := False;
    end else
      // ���� ���� ����
      if Aim > 0 then
      begin
        // ������ ����� ���������� ����
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
              // ��������� � ����
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

{ ����� �� ������ ��� ����� }
{ TODO -oPD -cminor : �������� ������� �������. ������ ���� ��������� � �������-�� �������� ��� ������������. }
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

{ ������� ��� � ���� }
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
  // ��������� ����� ������������
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
  // �������� �������
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
  { ����� ����}
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

{ ����������� ������� �������� }
procedure TMonster.MoveRandom;
begin
  Move(nx+((Random(3)-1)), ny+((Random(3)-1)));
end;

{ ����������� ������� }
function TMonster.Move(dx,dy : integer) : boolean;
begin
  Result := True;
  if not M.MonL[M.MonP[nx,ny]].felldown then
    case M.MonL[M.MonP[nx,ny]].Replace(dx,dy) of
      0 : // ������ �������������
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
      2 : // ������� �����
      begin
        if IsFlag(MonstersData[id].flags, M_OPEN) then
          if M.Tile[dx,dy] = tdCDOOR then
            M.Tile[dx,dy] := tdODOOR;
      end;
      3 : // ���������
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

{ ������� �������� ��������� �������� }
function TMonster.WoundDescription : string;
var
  r : string;
begin
  if hp = Rhp then
  begin
    if id = 1 then
      r := '���������� ���� ������������' else
        r := '��������� ���� ������������';
  end else
    if hp <= Round(Rhp / 6) then
    begin
      r := '����� ����';
    end else
      if hp <= Round(Rhp / 4) then
      begin
        r := '������ �����{/a}';
      end else
        if hp <= Round(Rhp / 3) then
        begin
          r := '������ �����{/a}';
        end else
          if hp <= Round(Rhp / 2) then
          begin
            r := '���������{/a}';
          end else
            if hp <= Round(Rhp / 4)*3 then
            begin
              r := '����� �����{/a}';
            end else
              r :=  '������� �����{/a}';
  Result := GetMsg(r,MonstersData[id].gender);
end;

{ ���������� � ���-������ }
procedure TMonster.TalkToMe;
var
  s : string;
  w : boolean;
  p : integer;
  i: byte;
begin
  if relation = 0 then
  begin
    // ���������� ��� ������ �������
    for i := 1 to QuestsAmount do V.SetInt('PCQuest'+IntToStr(I)+'State', pc.quest[I]); // ��������� �������
    V.SetStr('NPCWeaponName', ItemsData[eq[6].id].name1);
    V.SetStr('PCName', PC.Name);
    V.SetStr('NPCName', Name);    // ��� �������
    V.SetInt('NPCID', ID);        // ������������� �������
    w := TRUE;
    s := FullName(1, TRUE) + ' �������: ';
    case id of
        mdMALECITIZEN, mdFEMALECITIZEN: // ������ ���������
        begin
          // ��������� ������
          Run('NPCTalk.pas');
          // ��������� ���������
          S := S + V.GetStr('TalkStr');
        end;
        mdELDER: // ����������
        begin
          // ���� ��� ������ �� ���������� ���������
          if (pc.quest[1] = 4) and (pc.quest[2] = 4) then
            s := s + '"��... ����.. ����. �������, � ���� ��� � �������..."' else
          case pc.quest[1] of
            0 :
            begin
              w := FALSE;
              AddMsg('�� ����������{��/���} '+MonstersData[id].name3+'.',0);
              More;
              AddMsg(MonstersData[id].name1 + ' �������: "����������, '+pc.name+'! ���� ����� '+name+'. � ���������� �������� � � ���� ���� � ���� �������."',0);
              More;
              AddMsg('"���������, � �������� ���� ��������� � ������� ��� ���� ������ ������ ���� ������ ��������������. ��� ��������� � ������-��������� ����� ������� � ������������ ����� ����� ���� ���� ��� �����."',0);
              More;
              AddMsg('"��� ������ ����� ���� ������� ���������� � ���������. ��� ������ �������� ������ ������� ����� � ��������� ������ ��� ����. �� ������ ����������� ���� ����� ������������ � ������ �������� �� �����!"',0);
              More;
              AddMsg('"����� ����, ������ ���� ������ ������� ���������� ������, ������� ���� ���������� �� ��� ���������! ������� ��������, ��� ������ �������� � ��������, ��... � �� ����� �� ����."',0);
              More;
              AddMsg('"������ �� ��� �������? � ������� �� ����� �� �����... �� �� �� ��� ����� �� ��� �������! � ����� ������ - � ��������� ������ ��� ������ ����������, ������ ��� �������������... �� ����, ��� ����� ������!"',0);
              More;
              AddMsg('"� ����� ����� ���� - �������� � ��������� � ������ ��� �� ����� �����!"',0);
              pc.quest[1] := 1;
            end;
            1 :
            begin
              case Random(3)+1 of
                1 : s := s + '"�� ���? �� ��� �� ����������{/�} ���������? ��� ����!"';
                2 : s := s + '"����������, '+pc.name+', ����������! ���� � ���������!"';
                3 : s := s + '"�� ��� �������� �� ����, '+pc.name+'!"';
              end;{case}
            end;
            2 : // ��������!
            begin
              w := FALSE;
              AddMsg('�� ���������{/�} '+MonstersData[id].name3+' � ����� ����������� � ���������.',0);
              More;
              AddMsg('�� ����� �������� ������ ��������, ��, �������, �� ����� ���� �������...',0);
              More;
              AddMsg('���� ����� ���� ��� �����-������ ��������������!',0);
            end;
            3 : // ��� ��������������!
            begin
              w := FALSE;
              AddMsg(MonstersData[id].name3+', ����� ���� ����, ������:',0);
              More;
              AddMsg('"�� �� �������������, ��� � ���� ����������! �� �������{/�} ��� �� ����� �������!"',0);
              More;
              AddMsg('"���, ������ ��� ������! �������, ��� ���� �������!"',0);
              More;
              AddMsg('�� ����{/�} ������� ������ � �������{/�} �� � ������.',0);
              pc.PickUp(CreateItem(idCOIN, 300, 0), FALSE,300);
              pc.quest[1] := 4;
              More;
              AddMsg('"���� � ���� ��� ���� ������! ������ �������������{/�} - ���������!"',0);
              More;
            end;
            4 : // �������� ����� �1
            begin
              // ����� � 2
              case pc.quest[2] of
                0 :
                begin
                  w := FALSE;
                  AddMsg(FullName(1, TRUE) + ' �������: "�� ���, � ���� �� �����{/�} ��� ������ �������. � ���� ��� � ���..."',0);
                  More;
                  AddMsg('"�� ���� �������{/�} �� ��� ���, �� ��������� ����� �� ������� ������. ��� ����� �����, ������� ������� �� ������� �����."',0);
                  More;
                  AddMsg('"������� ��� ���� ������� �� ������� ������������ ��������� � ������� ���������� ������..."',0);
                  More;
                  AddMsg('"������ ��� ������������� ������� ��� �����, ��� �� ������� ��������� � �������..."',0);
                  More;
                  AddMsg('"��, ���� �� �������, ���� ������� ����-�� ������!"',0);
                  More;
                  AddMsg('"��� ������ ���� �� ���� - ��� �� �������!"',0);
                  More;
                  if Ask('"�� ���? �����{/�} ������� �� ��� ������?"  [(Y/n)]') = 'Y' then
                  begin
                    AddMsg('"�������! � ����������� �� ����!"',0);
                    pc.quest[2] := 1;
                    More;
                  end else
                    begin
                      AddMsg('"����� ����... �������, �� ����������� � ��������� �����!"',0);
                      More;
                    end;
                end;
                // ���� �����...
                1 :
                begin
                  s := s + '"�� ��� �� ���{��/��} ����? ����� ����..."';
                end;
                // ����� ���-��� � �������� (���� ��� :)
                2 :
                begin
                  w := FALSE;
                  AddMsg(FullName(1, TRUE) + ' �������: "�, ����... ��� ����������... ����� ��������...."',0);
                  More;
                  AddMsg('"� ��� ����� �������, ��� ��� �������... ��� ��... ��� �� ����..."',0);
                  More;
                  AddMsg('"����������..."',0);
                  More;
                  AddMsg('"��... ��� �� ��� �� ����?"',0);
                  More;
                end;
                // ����� ����
                3 :
                begin
                  w := FALSE;
                  AddMsg(MonstersData[id].name3+', ����� ���� ����, ������:',0);
                  More;
                  AddMsg('"� ����� �� �������{/�} ���� ������� ��������! ������ ����� ������� ������� ��������� �����!"',0);
                  More;
                  AddMsg('"���, ������ ��� ������! ������ ����� ������������� � �� ��������, �� �����-������ � ��� ���� ���-�� ����� �������!"',0);
                  More;
                  AddMsg('�� ����{/�} ������� ������ � �������{/�} �� � ������.',0);
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
          // ��������� ������
          Run('NPCTalk.pas');
          // ��������� ���������
          S := S + V.GetStr('TalkStr');
        end;
        mdKEYWIFE:
        begin
          // ��������� ������
          Run('NPCTalk.pas');
          // ��������� ���������
          S := S + V.GetStr('TalkStr');
        end;
        mdBARTENDER:
        begin
          w := False;
          if (Ask(FullName(1, TRUE) + ' �������: "���� ���������� ������ ������� �������� ����� �� 15 �������, ������?" #(Y/n)#')) = 'Y' then
          begin
            if pc.FindCoins = 0 then
              AddMsg('� ���������, � ���� ������ ��� �����.',0) else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('� ���� ������������ ������� ����� ��� �������.',0) else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('�� ������������ '+FullName(3, FALSE)+' ������.',0);
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  pc.RefreshInventory;
                  More;
                  AddMsg('�� �� ������������� � ����������� ������� ��������� ����.',0);
                  if pc.PickUp(CreatePotion(lqCHEAPBEER, 1), FALSE,1) <> 0 then
                  begin
                    AddMsg('��� ����� �� ���.',0);
                    PutItem(pc.x,pc.y, CreatePotion(lqCHEAPBEER, 1),1);
                  end;
                  More;
                  AddMsg('"������ �� ����� - ����� ��� ��������! ������ �������� � ������ ������������..."',0);
                end;
            end else
              AddMsg('"�� ��� �... ��� ���� ����������!"',0);
        end;
        mdDRUNK:
        begin
          // ��������� ������
          Run('NPCTalk.pas');
          // ��������� ���������
          S := S + V.GetStr('TalkStr');
        end;
        mdHEALER:
        begin
          w := False;
          if pc.Hp < pc.RHp then
          begin
            if (Ask(FullName(1, TRUE) + ' �������: "������ � ������� ����?" #(Y/n)#')) = 'Y' then
            begin
              p := Round((pc.RHp - pc.Hp) * 1.1);
              if (Ask('"���� ������ ��������� ����� ������ {'+IntToStr(p)+'} �������. ����?" #(Y/n)#')) = 'Y' then
              begin
                if pc.FindCoins = 0 then
                  AddMsg('� ���������, � ���� ������ ��� �����.',0) else
                  if pc.inv[pc.FindCoins].amount < p then
                  begin
                    p := Round(pc.inv[pc.FindCoins].amount / 1.1);
                    if p > 0 then
                    begin
                      if (Ask('"������������ �����... ��, ���� ������, ���� ������� ��������� ���� � �� {'+IntToStr(pc.inv[pc.FindCoins].amount)+'} �������. ����?" #(Y/n)#')) = 'Y' then
                      begin
                        AddMsg('�� ������������ '+FullName(3, FALSE)+' ������.',0);
                        pc.inv[pc.FindCoins].amount := 0;
                        pc.RefreshInventory;
                        More;
                        AddMsg('��� ���������� ������������� � ������ ��. ����� ������� ������ � ������� ������� � ���� ���� ������... ',0);
                        More;
                        AddMsg('#������� ���� ������� ���������, �� ��������� ������ ������ ����� �����!# ($+'+IntToStr(p)+'$)',0);
                        inc(pc.Hp, p);
                      end else
                        AddMsg('"����� ��� ����� �������� �����������!"',0);
                    end else
                      AddMsg('� ���������, � ���� ������������ �����, ��� �� ���� ����-���� �����������.',0);
                  end else
                    if pc.inv[pc.FindCoins].amount >= p then
                    begin
                      AddMsg('�� ������������ '+FullName(3, FALSE)+' ������.',0);
                      dec(pc.inv[pc.FindCoins].amount, p);
                      pc.RefreshInventory;
                      More;
                      AddMsg('��� ���������� ������������� � ������ ��. ����� ����� ��� ����������� ��� ���� � ����� ������... ',0);
                      More;
                      AddMsg('#�� ������� �� ������� ��������, ��, ����� ��������� � ����, ���������� ���� �����������!#',0);
                      pc.Hp := pc.RHp;
                    end;
              end;
            end else
              AddMsg('"�� ������ - ��� ������..."',0);
          end else
            AddMsg(FullName(1, TRUE) + ' �������: "����������, '+pc.name+'! ���� ����� '+name+'. ���� ���� ����� - ������ �� ���, � ����� ���� ������."',0);
        end;
        mdMEATMAN:
        begin
          w := False;
          if (Ask(FullName(1, TRUE) + ' �������: "������ ������ ����� ��������� ������� ���� ����� �� 15 �������?" #(Y/n)#')) ='Y' then
          begin
            if pc.FindCoins = 0 then
              AddMsg('� ���������, � ���� ������ ��� �����.',0) else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('� ���� ������������ ������� ����� ��� �������.',0) else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('�� ������������ '+FullName(3, FALSE)+' ������.',0);
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  RefreshInventory;
                  More;
                  AddMsg('�� �� ������������� � ������ ����� ����.',0);
                  if pc.PickUp(CreateItem(idMEAT, 1, 0), FALSE,1) <> 0 then
                  begin
                    AddMsg('��� ����� �� ���.',0);
                    PutItem(pc.x,pc.y, CreateItem(idMEAT, 1, 0),1);
                  end;
                  More;
                  AddMsg('"����������� ���, ����� �������� ������!"',0);
                end;
            end else
              AddMsg('"���� ����� ����������� - ����������� ������ �� ���!"',0);
        end;
        else s := '�������� �������...';
      end;
      if W then AddMsg(s,id);
  end else
    AddMsg('��! �� �� � ����� ����������, ����� ����������!',0);
end;

{ ������� }
procedure TMonster.Fight(var Victim : TMonster; CA : byte);
var
  i,c : byte;
  dam, tempdam : integer;
  d : real;
begin
  // ���� ����������
  if CA = 1 then
    if id = 1 then
      AddMsg('#'+MonstersData[id].name1+' �������������!#',id) else
        AddMsg('*'+MonstersData[id].name1+' ������������!*',id);
  // ���� ������ ����
  if CA = 2 then
    if id = 1 then
      AddMsg('#'+MonstersData[id].name1+' ��������� ������� ��� ���� ����!#',id) else
        AddMsg('*'+MonstersData[id].name1+' �������� ������� ��� ���� ����!*',id);
  if M.MonP[Victim.x, victim.y] > 0 then
  begin
    { --��������� �����������-- }
    if ((Victim.relation = 1) and (id = 1)) or (id > 1)  then
    begin
      // ����������
      if Random(Round(TacticEffect(2)*(dex+(ability[abACCURACY]*AbilitysData[abACCURACY].koef))))+1 > Random(Round(Victim.TacticEffect(1)*(Victim.dex+(Victim.ability[abDODGER]*AbilitysData[abDODGER].koef))))+1 then
      begin
        // �������� �����
        if (Victim.eq[8].id > 0) and (Random(Round(Victim.dex*Victim.TacticEffect(1)) * 2)+1 = 1) then
          if Victim.id = 1 then
            AddMsg('#'+Victim.FullName(1, FALSE)+' ����������{/�} ����� ����� �����!#', Victim.id) else
              AddMsg('*'+Victim.FullName(1, FALSE)+' ����������{/�} ����� ����� �����!*', Victim.id)
        else
          // �����
          begin
            Dam := 0;
            // ���������� �����
            if Eq[6].id > 0 then
            begin
              if closefight[ItemsData[Eq[6].id].kind] > 0 then
                Dam := Round((Random(Round(ItemsData[Eq[6].id].attack+(str/4)))+1) * (closefight[ItemsData[Eq[6].id].kind] /100));
            end else
              // ����������
              if closefight[CLOSE_ARM] > 0 then Dam := Round((Random(Round(attack+(str/4)))+1) * (closefight[CLOSE_ARM] / 100)) + 1;
            TempDam := Dam;
            // ���������� ������ �� ���� �����
            Dam := (Round(Dam/(Random(Round(TacticEffect(1)*2))+1))) - Random(Round(Victim.defense/(Random(Round(Victim.TacticEffect(2)*2))+1)));
            // ��� ���������� ����� �����������
            if CA = 1 then Dam := Round(Dam / (1 + ((Random(Round(10*TacticEffect(2)))+1) / 10)));
            // �����, �� �� ������  
            if Dam <= 0 then
              AddMsg(FullName(1, FALSE)+' �����{/�} �� '+Victim.FullName(3, FALSE)+', �� �� ������{/�} �����.',id) else
                begin
                  if Dam > 1000 then
                  begin
                    AddMsg('*W*#H#$A$T $T$#H#*E* *FUCK*?! '+FloatToStr(closefight[CLOSE_ARM])+':'+IntToStr(attack)+':'+IntToStr(str)+':'+FloatToStr(TacticEffect(1)),id);
                    More;
                  end;
                  // ������ �����
                  Victim.hp := Victim.hp - Dam;
                  Victim.BloodStreem( -(x - Victim.x), -(y - Victim.y));
                  AddMsg(FullName(1, FALSE)+' �����{/�} �� '+Victim.FullName(3, FALSE)+'! (*'+IntToStr(Dam)+'*)',id);
                  // �����
                  if Victim.hp > 0 then
                  begin
                    if id = 1 then AddMsg(Victim.FullName(1, FALSE)+' '+Victim.WoundDescription+'.',Victim.id);
                  end else
                    // ����
                    begin
                      // ��������� ����� ����� ������
                      d := (TempDam * 0.03) / Dam;
                      if Eq[6].id > 0 then
                        c := ItemsData[Eq[6].id].kind else
                          c := CLOSE_ARM;
                      if IsInNewAreaSkill(closefight[c], closefight[c] +  d) then
                      begin
                        closefight[c] := closefight[c] +  d;
                        AddMsg('������ �� ����� �������� ������� "'+CLOSEWPNNAME[c]+'"! ������ �� �� �������� ������ '+RateToStr(RateSkill(pc.CloseFight[c]))+'!',id);
                        More;
                      end else
                        closefight[c] := closefight[c] +  d;
                      // � ���������� ������ ������ ������� ��
                      repeat
                        i := Random(CLOSEFIGHTAMOUNT)+1;
                      until
                        (i <> c);
                      if CloseFight[i] - d > 0 then
                      begin
                        if IsInNewAreaSkill(Closefight[i], closefight[i] -  d) then
                        begin
                          closefight[c] := closefight[c] +  d;
                          AddMsg('�� ����� �����, ��� ��-�� ������� ���������� ���������� ���� ����� "'+CLOSEWPNNAME[c]+'" ���� ����������. ������ �� �� �������� ������ '''+RateToStr(RateSkill(pc.CloseFight[i]))+'''.',id);
                          More;
                        end else
                          CloseFight[i] := CloseFight[i] - d;
                      end else
                          CloseFight[i] := 0;
                      // �����
                      KillSomeOne(Victim.idinlist);
                    end;
                end;
          end;
      end else
        begin
          AddMsg(FullName(1, FALSE)+' ���������{��/���} �� '+Victim.FullName(3, FALSE)+'.', id);
        end;
      // ���� ���� ��� �� ����
      if Victim.id > 0 then
      begin
        // ���� ����������!!!
        if Round(Victim.TacticEffect(1)) * Random(Round(Victim.dex / 2) + (Victim.ability[abQUICKREACTION]) * Round(AbilitysData[abQUICKREACTION].koef)) + 1 > Random(100)+1 then
          Victim.Fight(Self, 1);
        // ���� ������� ��� ���!!!
        if Round(TacticEffect(2)) * Random(Round(Victim.dex / 4) + (Victim.ability[abQUICKATTACK]) * Round(AbilitysData[abQUICKATTACK].koef)) + 1 > Random(100)+1 then
          Fight(Victim, 2);
      end;
    end;
    // ��������� ������������
    if  (id = 1) and (Victim.relation = 0)then
    begin
      if Ask('����� ������� �� '+Victim.FullName(2, TRUE)+'? #(Y/n)#') = 'Y' then
      begin
        Victim.relation := 1; // ��������!
        Fight(Victim, 0);
        AttackNeutral(Victim);
      end else
        AddMsg('�� ������� �������{/�} � �����{/�} ����� �� ������.',0);
    end;
  end else
    AddMsg('�� ����� �� ������ ���!',0);
end;

{ �������� }
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
      AddMsg(FullName(1, FALSE)+', ��������� '+ItemsData[eq[7].id].name3+', ���������{/a} � '+Victim.FullName(2, FALSE)+'!',id) else
        AddMsg(FullName(1, FALSE)+' �������{/a} '+ItemsData[eq[13].id].name3+' � '+Victim.FullName(2, FALSE)+'!',id);
    // ����������
    if Random(Round(TacticEffect(2)*(dex+(ability[abACCURACY]*AbilitysData[abACCURACY].koef))))+1 > Random(Round(Victim.TacticEffect(1)*((Victim.dex/4)+(Victim.ability[abDODGER]*AbilitysData[abDODGER].koef))))+1 then
    begin
      // �������� ����� (���� ������ ��� � ������� ���)
      if (Victim.eq[8].id > 0) and (Random(Round(Victim.dex*Victim.TacticEffect(1)) * 4)+1 = 1) then
        if Victim.id = 1 then
          AddMsg('#'+Victim.FullName(1, FALSE)+' ����������{/�} '+ItemsData[pc.eq[13].id].name3+' ����� �����!#',Victim.id) else
            AddMsg('*'+Victim.FullName(1, FALSE)+' ����������{/�} '+ItemsData[pc.eq[13].id].name3+' ����� �����!*',Victim.id)
      else
        // �����
        begin
          Dam := 0;
          // ���������� �����
          if Eq[7].id > 0 then
          begin
            if farfight[ItemsData[Eq[7].id].kind] > 0 then
              Dam := Round((Random(Round(ItemsData[Eq[13].id].attack+(str/3)))+1) * (farfight[ItemsData[Eq[7].id].kind] / 100));
          end else
            // ������ �������
            if farfight[FAR_THROW] > 0 then Dam := Round(Random(Round(ItemsData[Eq[13].id].attack+(str/3)))+1 * (farfight[FAR_THROW] / 100));
          TempDam := Dam;
          // ���������� ������ �� ���� �����
          Dam := (Round(Dam/(Random(Round(TacticEffect(1)*2))+1))) - Random(Round(Victim.defense/(Random(Round(Victim.TacticEffect(2)*2))+1)));
          // �����, �� �� ������
          if Dam <= 0 then
            AddMsg(FullName(1, FALSE)+' �����{/�} �� '+Victim.FullName(3, FALSE)+', �� �� ������{/�} �����.',id) else
              begin
                // ������ �����
                Victim.hp := Victim.hp - Dam;
                Victim.BloodStreem( -(x - Victim.x), -(y - Victim.y));
                // �����
                if Victim.hp > 0 then
                begin
                  AddMsg(FullName(1, FALSE)+' �����{/�} �� '+Victim.FullName(3, FALSE)+'! (*'+IntToStr(Dam)+'*)',id);
                  if id = 1 then AddMsg(Victim.FullName(1, FALSE)+' '+Victim.WoundDescription+'.',Victim.id);
                end else
                  // ����
                  begin
                    // ��������� ����� ����� ������
                    d := (TempDam * 0.03) / Dam;
                    if Eq[7].id > 0 then
                      c := ItemsData[Eq[7].id].kind else
                        c := FAR_THROW;
                    if IsInNewAreaSkill(farfight[c], farfight[c] +  d) then
                    begin
                      farfight[c] := farfight[c] +  d;
                      AddMsg('������ �� ����� �������� ������� "'+CLOSEWPNNAME[c]+'"! ������ �� �� �������� ������ '+RateToStr(RateSkill(pc.CloseFight[c]))+'!',id);
                      More;
                    end else
                      farfight[c] := farfight[c] +  d;
                    // � ���������� ������ ������ ������� ��
                    repeat
                      i := Random(FARFIGHTAMOUNT)+1;
                    until
                      (i <> c);
                    if FarFight[i] - d > 0 then
                    begin
                      if IsInNewAreaSkill(Farfight[i], Farfight[i] -  d) then
                      begin
                        Farfight[c] := Farfight[c] +  d;
                        AddMsg('�� ����� �����, ��� ��-�� ������� ���������� ���������� ���� ����� "'+CLOSEWPNNAME[c]+'" ���� ����������. ������ �� �� �������� ������ '''+RateToStr(RateSkill(pc.CloseFight[i]))+'''.',id);
                        More;
                      end else
                        FarFight[i] := FarFight[i] - d;
                    end else
                        FarFight[i] := 0;
                    // �����
                    KillSomeOne(Victim.idinlist);
                  end;
              end;
        end;
    end else
      begin
        AddMsg(FullName(1, FALSE)+' ���������{��/���} �� '+Victim.FullName(3, FALSE)+'.',id);
        Item := pc.eq[13];
        Item.amount := 1;
        PutItem(Victim.x, Victim.y, Item,1);
      end;
    // ���� ���������� �����������
    if  (id = 1) and (Victim.relation = 0)then
    begin
      Victim.relation := 1; // ��������!
      AttackNeutral(Victim);
    end;
  end else
    AddMsg('�� ����� ������ ���!',id);
end;

{ ��������� ������������ }
procedure TMonster.AttackNeutral(Victim : TMonster);
var
  i : byte;
begin
  if Victim.id = mdBREAKMT then
  begin
    More;
    AddMsg('�� ������������{/a}, ��� ��� ��� ������ ������ ���������...',0);
    More;
    AddMsg('� �� �������������� ����!',0);
    More;
    pc.level := 3;
    M.MakeSpMap(pc.level);
    pc.PlaceHere(30,23);
    pc.turn := 2;
  end else
    begin
      AddMsg(Victim.FullName(1, FALSE)+' � ������!',Victim.id);
      Victim.aim := 1;
      // ���� ��� ��������� � ����������... �� ����� #!^&#@
      if (pc.level = 1) and (pc.depth = 0) then
      begin
        for i:=1 to 255 do
          if (M.MonL[i].id > 0) and (M.MonL[i].relation = 0) then
          begin
            // ����� ���������� :))
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
        AddMsg('�� ������, ��� ��� ���������� �� ����...',0);
        More;
        AddMsg('� � ������� ������� �������� ������...',0);
        More;
        AddMsg('������� � �������� ������� ���� �������� �������!',0);
        More;
        AddMsg('*��� �� �������{/a}! ������ ��� ������� ������ ����!*',0);
        More;
      end;
    end;
end;

{ ����� }
procedure TMonster.KillSomeOne(Victim : byte);
begin
  if Victim = 1 then
    AddMsg('*'+FullName(1, TRUE)+' ����{/a} '+pc.FullName(2, TRUE)+'!*',id) else
      AddMsg('*'+FullName(1, TRUE)+' ����{/a} '+M.MonL[Victim].FullName(2, TRUE)+'!*',id);
  if id = 1 then
  begin
    inc(pc.exp, MonstersData[+M.MonL[Victim].id].exp);
    if pc.exp >= pc.ExpToNxtLvl then
      pc.GainLevel;
    if (M.MonL[Victim].id = mdBLINDBEAST) and (PlayMode = AdventureMode) then
    begin
      AddMsg('#�� ��������{/a} �����!!!#',0);
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

{ ������� }
procedure TMonster.Death;
var
  i : byte;
begin
  // ������� ���������
  M.MonP[x,y] := 0;
  // ����
  if idinlist = 1 then
    PutItem(x,y,CreateItem(idCORPSE, 1, id),1) else
      begin
        if id = mdBLINDBEAST then
          PutItem(x,y,CreateItem(idHEAD, 1, id),1) else
          begin
            // ����
            if Random(5)+1 = 1 then
              PutItem(x,y,CreateItem(idCORPSE, 1, id),1);
            // ������  
            if Random(15)+1 = 1 then
              PutItem(x,y,CreateItem(idHEAD, 1, id),1);
          end;
      end;
  // �������� ����
  for i:=1 to EqAmount do
    if Eq[i].id > 0 then
      PutItem(x,y, Eq[i], Eq[i].amount);
  for i:=1 to MaxHandle do
    if Inv[i].id > 0 then
      PutItem(x,y, Inv[i], Inv[i].amount);
  // ���� ��� �����, ��
  if idinlist = 1 then pc.AfterDeath;
  // ��.
  id := 0;
  idinlist := 0;
end;

{ ������ ���� }
procedure TMonster.GiveItem(var Victim : TMonster; var GivenItem : TItem);
begin
  if ((Victim.relation = 0) and (id = 1)) or (id > 1) then
  begin
    if Ask('����� ������ '+ItemName(GivenItem, 1, TRUE)+' '+Victim.FullName(3, TRUE)+'? #(Y/n)#') = 'Y' then
    begin
      // 0-�������,1-������ ���,2-��� �����,3-����������
      case Victim.PickUp(GivenItem, FALSE,GivenItem.amount) of
        0 :
        begin // ������� �����
          AddMsg(FullName(1, TRUE)+' �����{/�} '+Victim.FullName(3, TRUE)+' '+ItemName(GivenItem, 1, TRUE)+'.',id);
          // ����� ����� ����������
          if (GivenItem.id = idHEAD) and (GivenItem.owner = mdBLINDBEAST) then
            if pc.quest[1] > 1 then
              pc.quest[1] := 3;
          // ����� ���� ����������
          if GivenItem.id = idGATESKEY then
            if pc.quest[2] > 1 then
              pc.quest[2] := 3;
          DeleteInvItem(GivenItem, 1);
          RefreshInventory;
        end;
        1 : AddMsg(FullName(1, TRUE)+' �����{/�} '+Victim.FullName(3, TRUE)+' ����!',id);
        2 : AddMsg(Victim.FullName(1, TRUE)+' ��� ����� ����� ����� �����!',Victim.id);
        3 : AddMsg(Victim.FullName(1, TRUE)+' ����������{/�} ������!',Victim.id);
      end;
    end else
      AddMsg('������� �������, �� �����{/a} ����� �� ������.',0);
  end else
    AddMsg('�������, ��� �� ������ �������...',0);
end;

{ �����! }
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

{ ������� ���� }
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

{ ������� ����� ����� ������ }
function TMonster.MaxMass : real;
begin
  Result := str * 15.8;
end;

{ ������� ������� �� ��������� }
procedure TMonster.DeleteInvItem(var I : TItem; amount : integer);
begin
  // �����
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

{ ��������� ��������� }
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

{ ������� ���� ������� ���� ������� ��� ������������� ������� }
function TMonster.ColorOfTactic: longword;
begin
  Result := 0;
  case tactic of
    1 : Result := RGB(70,0,0);
    2 : Result := RGB(0,70,0);
  end;
end;

{ ������� ��������� (0.5, 1 ��� 1.5 - ������ �� �������) }
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

{ ��������� ������� }
function TMonster.EquipItem(Item : TItem) : byte;
var
  TempItem : TItem;
begin
  Result := 0;
  case ItemsData[Item.id].vid of
    1 : cell := 1; // ����
    2 : cell := 2; // ������
    3 : cell := 3; // ����
    4 : cell := 4; // ����� �� ����
    5 : cell := 5; // ������
    6 : cell := 6; // ������ �������� ���
    7 : cell := 7; // ������ �������� ���
    8 : cell := 8; // ���
    9 : cell := 9; // �������
    10: cell := 10; // ������
    11: cell := 11; // ��������
    12: cell := 12; // �����
    13: cell := 13; // ���������
  end;
  // ������ ������
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
            AddMsg('������ �� ����������� '+ItemName(eq[cell], 1, TRUE)+', � '+ItemName(TempItem, 1, TRUE)+' �� �����{/a} � ���������.',0) else
              AddMsg('������ �� ����������� '+ItemName(eq[cell], 1, FALSE)+', � '+ItemName(TempItem, 1, TRUE)+' �� �����{/a} � ���������.',0);
        end;
        2 : // ��� �����
          AddMsg('� ���������, � ��������� �� ���������� ����� ��� ����� ��������.',0);
      end;
    Result := 1;
  end else
    eq[cell] := Item;
  if cell <> EqAmount then
    if eq[cell].amount > 1 then eq[cell].amount := 1;
end;

{ ������� �������� ��������� ������� (���������, ��������� � ��) }
function TMonster.ExStatus(situation : byte) : string;
var s : string;
begin
  s := '';
  // ��� ����� ��� ��������� �� ��������������
  if id > 1 then
  begin
    // ����������
    if (Relation = 0) and (not IsFlag(MonstersData[id].flags, M_NEUTRAL)) then
      s := s + '��������{��/��}' else
    // ���������
    if (Relation = 1) and (IsFlag(MonstersData[id].flags, M_NEUTRAL)) then
      s := s + '�������{��/��}';
  end;
  // ������� ���������
  if s = '' then
    Result := s else
      Result := s+' ';
end;

{ ������� ������ ��� ������� }
function TMonster.FullName(situation : byte; writename : boolean) : string;
var s : string;
begin
  s := '';
  {(1���,2����,3����,4���,5���,6���)}
  // ������ �������
  case situation of
    1 : s := ExStatus(4);
    2 : s := ExStatus(7);
    3 : s := ExStatus(8);
    4 : s := ExStatus(9);
    5 : s := ExStatus(9);
    6 : s := ExStatus(10);
  end;
  // �������� �������
  case situation of
    1 : s := s + MonstersData[id].name1;
    2 : s := s + MonstersData[id].name2;
    3 : s := s + MonstersData[id].name3;
    4 : s := s + MonstersData[id].name4;
    5 : s := s + MonstersData[id].name5;
    6 : s := s + MonstersData[id].name6;
  end;
  // ����� �������
  if ((IsFlag(MonstersData[id].flags, M_ClASS))) and (id > 1) then
    s := s + '-' + ClName(situation);
  // ���� ���� ���
  if id > 1 then
    if ((IsFlag(MonstersData[id].flags, M_NAME))) and (writename) then
      s := s + ' �� ����� ' + name;
  Result := s;
end;

{ ����� ������ }
procedure TMonster.DecArrows;
begin
  dec(Eq[13].amount);
  if eq[13].amount = 0 then
  begin
    // ���� ��
    if id = 1 then
      AddMsg('*� ���� ����������� '+ItemsData[eq[13].id].name2+'!*',0) else
        if M.Saw[x,y] = 2 then
          AddMsg('$������� � '+FullName(2, FALSE)+' ����������� '+ItemsData[eq[13].id].name2+'!$',0);
    eq[13].id := 0;
  end;
end;

{ ������� ����� ������ ����� }
function TMonster.WhatClass : byte;
begin
  Result := 0;
  case atr[1] of
    1 : // ����
    case atr[2] of
      1 : Result := 1;
      2 : Result := 2;
      3 : Result := 3;
    end;
    2 : // ��������
    case atr[2] of
      1 : Result := 4;
      2 : Result := 5;
      3 : Result := 6;
    end;
    3 : // ���������
    case atr[2] of
      1 : Result := 7;
      2 : Result := 8;
      3 : Result := 9;
    end;
  end;
end;

{ ������� �������� ������ }
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

{ ��������� ���� ������ � ����������� � ����������� �� ������ }
procedure TMonster.PrepareSkills;
var
  i : byte;
begin
  for i:=1 to CLOSEFIGHTAMOUNT do closefight[i] := 0;
  for i:=1 to FARFIGHTAMOUNT do farfight[i] := 0;
  case WhatClass of
    1: //����
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
    2: //������
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
    3: //�������
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
    4: //��������
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
    5: //�������
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
    6: //�����
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
    7: //����
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
    8: //������
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
    9: //���������
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

{ ������ �� ������� ��������� ������� - �� ��������� � ���� �����. ������ }
procedure TMonster.FavWPNSkill;
var
  i : byte;
begin
  // ���� ���������� �������� ������ 1 ��������� �����, �� �� ������������� ���������� �������
  if HowManyBestWPNCL = 1 then
    c_choose := BestWPNCL;
  if HowManyBestWPNFR = 1 then
    f_choose := BestWPNFR;
  // ���� 2 ���������� � ������ - ��������� ������, �� ������� ���������� ������
  if (HowManyBestWPNCL = 2) and (OneOfTheBestWPNCL(1)) then
    for i:=2 to CLOSEFIGHTAMOUNT do
      if OneOfTheBestWPNCL(i) then
      begin
        c_choose := i;
        break;
      end;
  // ���� 2 ���������� � ������ - ������, �� ������� ���������� ������
  if (HowManyBestWPNFR = 2) and (OneOfTheBestWPNFR(1)) then
    for i:=2 to FARFIGHTAMOUNT do
      if OneOfTheBestWPNFR(i) then
      begin
        f_choose := i;
        break;
      end;
  case c_choose of
    // ���������
    1 :
    begin
      closefight[1] := closefight[1] + 25;
      EquipItem(CreateItem(idLONGSWORD, 1, 0));
    end;
    // ���
    2 :
    begin
      closefight[2] := closefight[2] + 25;
      EquipItem(CreateItem(idSHORTSWORD, 1, 0));
    end;
    // ������
    3 :
    begin
      closefight[3] := closefight[3] + 25;
      EquipItem(CreateItem(idDUBINA, 1, 0));
    end;
    // �����
    4 :
    begin
      closefight[4] := closefight[4] + 25;
      EquipItem(CreateItem(idSTAFF, 1, 0));
    end;
    // �����
    5 :
    begin
      closefight[5] := closefight[5] + 25;
      EquipItem(CreateItem(idAXE, 1, 0));
    end;
    // ���������� ���
    6 :
    begin
      closefight[6] := closefight[6] + 25;
      attack := attack * 2;
    end;
  end;
  case f_choose of
    // ������
    1 :
    begin
      farfight[1] := farfight[1] + 25;
    end;
    // ���
    2 :
    begin
      farfight[2] := farfight[2] + 25;
      EquipItem(CreateItem(idBOW, 1, 0));
      EquipItem(CreateItem(idARROW, 30, 0));
    end;
    // �����
    3 :
    begin
      farfight[3] := farfight[3] + 25;
      EquipItem(CreateItem(idSLING, 1, 0));
      EquipItem(CreateItem(idLITTLEROCK, 50, 0));
    end;
    // ������� ������
    4 :
    begin
      farfight[4] := farfight[4] + 25;
      EquipItem(CreateItem(idBLOWPIPE, 1, 0));
      EquipItem(CreateItem(idIGLA, 40, 0));
    end;
    // �������
    5 :
    begin
      farfight[5] := farfight[5] + 25;
      EquipItem(CreateItem(idCROSSBOW, 1, 0));
      EquipItem(CreateItem(idBOLT, 25, 0));
    end;
  end;
end;

{ ����� ����������� ����� � ����. ��� }
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

{ ������� �������������������� � ����. ��� }
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

{ ���� �� ����� ����. ������� }
function TMonster.OneOfTheBestWPNCL(i : byte): boolean;
begin
  Result := FALSE;
  if closefight[i] = closefight[BestWPNCL] then Result := TRUE;
end;

{ ����� ����������� ����� � ������� ��� }
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

{ ������� �������������������� � ������� ��� }
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

{ ���� �� ����� ����. ������� }
function TMonster.OneOfTheBestWPNFR(i : byte): boolean;
begin
  Result := FALSE;
  if farfight[i] = farfight[BestWPNFR] then Result := TRUE;
end;

{ ���� ������ }
function TMonster.ClassColor : longword;
begin
  Result := 0;
  if (id > 1) and not (IsFlag(MonstersData[id].flags, M_CLASS)) then
    // ������ ��� ������
    Result := RealColor(MonstersData[id].color) else
      // ���� ������
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
