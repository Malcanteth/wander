unit monsters;

interface

uses
  Utils, Cons, Tile, Flags, Msg, Items, SysUtils, Ability, Windows;

type
  TMonster = object
    id              : byte;
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
    inv             : array[1..MaxHandle] of TItem;  // �������� �������
    invmass         : real;                          // ����� ��������� � ����������
    //��������
    Rst,st,                                        //����
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

    function Replace(nx, ny : integer) : byte;        // ���������� �������������
    procedure DoTurn;                                 // AI
    function DoYouSeeThis(ax,ay : byte) : boolean;    // ����� �� ������ �����
    function MoveToAim(obstacle : boolean) : boolean; // ������� ��� � ����
    procedure MoveRandom;                             // ��������� ��������
    function Move(dx,dy : integer) : boolean;         // ����������� �������
    function WoundDescription : string;               // ������� �������� ��������� ��������
    procedure TalkToMe;                               // ���������� � ���-������
    procedure Fight(var Victim : TMonster; CA : byte);// ������� (CA: 1 - ����������, 2 - ������ ����!)
    procedure GiveItem(var Victim : TMonster;
                                 var GivenItem : TItem); // ������ ����
    procedure Death;                                  // �������
    procedure BloodStreem(dx,dy : shortint);
    function PickUp(Item : TItem;
                             FromEq : boolean) : byte;// ��������� ���� � ��������� (0-�������,1-������ ���,2-��� �����,3-����������
    function MaxMass : real;
    procedure DeleteInvItem(var I : TItem;
                      full : boolean);                // ������� ������� �� ���������
    procedure RefreshInventory;                       // ��������� ���������
  end;

  TMonData = record
    name1, name2, name3, name4, name5, name6 : string[40];  // �������� (1���,2����,3����,4���,5���,6���)
    char                       : string[1];       // ������
    color                      : longword;        // ����
    gender                     : byte;
    hp                         : word;            // ��������
    speed                      : word;            // ��������
    los                        : byte;            // ����� ������
    st, dex, int, at, def      : byte;
    exp                        : byte;
    mass                       : real;
    coollevel                  : byte;
    flags                      : longword;        // ������:)
  end;

const
  { ��������� ���������� �������� }
  MonstersAmount = 20;

  {  �������� �������� }
  MonstersData : array[1..MonstersAmount] of TMonData =
  (
    ( name1 : '��'; name2 : '����'; name3 : '����'; name4 : '�����'; name5 : '����';
      char : '@'; color : cLIGHTBLUE; gender : genMALE;
      flags : NOF or M_NEUTRAL;
    ),
    ( name1 : '������'; name2 : '������'; name3 : '������'; name4 : '�������'; name5 : '������'; name6 : '�������';
      char : 'h'; color : cBROWN; gender : genMALE;
      hp : 30; speed : 100; los : 6; st : 5; dex : 5; int : 3; at : 7; def : 7;
      exp : 5; mass : 60.4;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS;
    ),
    ( name1 : '����������'; name2 : '����������'; name3 : '����������'; name4 : '�����������'; name5 : '����������'; name6 : '���������';
      char : 'h'; color : cLIGHTRED; gender : genFEMALE;
      hp : 18; speed : 100; los : 6; st : 3; dex : 6; int : 4;  at : 4; def : 5;
      exp : 3; mass : 40.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_HAVEITEMS;
    ),
    ( name1 : '����������'; name2 : '����������'; name3 : '����������'; name4 : '�����������'; name5 : '����������'; name6 : '���������';
      char : 't'; color : cYELLOW; gender : genMALE;
      hp : 45; speed : 110; los : 6; st : 7; dex : 5; int : 7; at : 19; def : 20;
      exp : 15; mass : 55.3;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : '�����'; name2 : '������'; name3 : '������'; name4 : '�������'; name5 : '������'; name6 : '�������';
      char : 'P'; color : cRANDOM; gender : genMALE;
      hp : 666; speed : 200; los : 8; st : 99; dex : 99; int : 99;  at : 25; def : 50;
      exp : 255; mass : 58.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : '�����'; name2 : '�����'; name3 : '�����'; name4 : '������'; name5 : '�����'; name6 : '����';
      char : 'r'; color : cBROWN; gender : genFEMALE;
      hp : 10; speed : 160; los : 5; st : 2; dex : 6; int : 1;  at : 3; def : 1;
      exp : 2; mass : 8.3; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '������� ����'; name2 : '������� ����'; name3 : '������� ����'; name4 : '������� �����'; name5 : '������� ����'; name6 : '������� �����';
      char : 'B'; color : cGRAY; gender : genFEMALE;
      hp : 6; speed : 220; los : 7; st : 3; dex : 8; int : 1;  at : 1; def : 2;
      exp : 4; mass : 6.8; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '����'; name2 : '�����'; name3 : '�����'; name4 : '������'; name5 : '�����'; name6 : '������';
      char : 's'; color : cWHITE; gender : genMALE;
      hp : 9; speed : 180; los : 5; st : 2; dex : 8; int : 1;  at : 3; def : 1;
      exp : 2; mass : 0.9; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '������'; name2 : '�������'; name3 : '�������'; name4 : '��������'; name5 : '�������'; name6 : '��������';
      char : 'g'; color : cGREEN; gender : genMALE;
      hp : 13; speed : 115; los : 6; st : 5; dex : 7; int : 2;  at : 5; def : 5;
      exp : 4; mass : 30.5; coollevel : 1;
      flags : NOF or M_HAVEITEMS or M_OPEN;
    ),
    ( name1 : '���'; name2 : '����'; name3 : '����'; name4 : '�����'; name5 : '����'; name6 : '�����';
      char : 'o'; color : cLIGHTGREEN; gender : genMALE;
      hp : 15; speed : 105; los : 6; st : 6; dex : 6; int : 3;  at : 7; def : 7;
      exp : 5; mass : 55.0; coollevel : 2;
      flags : NOF or M_HAVEITEMS or M_OPEN;
    ),
    ( name1 : '���'; name2 : '����'; name3 : '����'; name4 : '�����'; name5 : '����'; name6 : '�����';
      char : 'o'; color : cBROWN; gender : genMALE;
      hp : 20; speed : 85; los : 5; st : 9; dex : 6; int : 2;  at : 10; def : 9;
      exp : 6; mass : 70.9; coollevel : 3;
      flags : NOF or M_HAVEITEMS or M_OPEN;
    ),
    ( name1 : '������ �������'; name2 : '������ �������'; name3 : '������ �������'; name4 : '������ ��������'; name5 : '������ �������'; name6 : '������ ������';
      char : 'M'; color : cCYAN; gender : genFEMALE;
      hp : 70; speed : 70; los : 2; st : 15; dex : 6; int : 3;  at : 15; def : 11;
      exp : 14; mass : 85.0; coollevel : 4;
      flags : NOF or M_ALWAYSANSWERED;
    ),
    ( name1 : '�������'; name2 : '�������'; name3 : '�������'; name4 : '��������'; name5 : '�������'; name6 : '������';
      char : 'h'; color : cBLUE; gender : genMALE;
      hp : 17; speed : 40; los : 4; st : 5; dex : 4; int : 4;  at : 6; def : 4;
      exp : 4; mass : 40.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : '������'; name2 : '�������'; name3 : '�������'; name4 : '��������'; name5 : '�������'; name6 : '��������';
      char : 'b'; color : cRED; gender : genMALE;
      hp : 40; speed : 100; los : 6; st : 5; dex : 5; int : 5;  at : 7; def : 7;
      exp : 12; mass : 60.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : '����������� ������ �����'; name2 : '����������� ������� ������'; name3 : '����������� ������� ������'; name4 : '����������� ������ �������'; name5 : '����������� ������� ������'; name6 : '����������� ������ �������';
      char : 'h'; color : cBLUE; gender : genMALE;
      hp : 5; speed : 20; los : 2; st : 3; dex : 2; int : 1; at : 1; def : 1;
      exp : 0; mass : 35.7;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_FELLDOWN or M_HAVEITEMS;
    ),
    ( name1 : '������������'; name2 : '������������'; name3 : '������������'; name4 : '�������������'; name5 : '������������'; name6 : '�����������';
      char : 'h'; color : cLIGHTGREEN; gender : genFEMALE;
      hp : 30; speed : 120; los : 6; st : 5; dex : 7; int : 9; at : 10; def : 10;
      exp : 10; mass : 45.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : '������'; name2 : '�������'; name3 : '�������'; name4 : '��������'; name5 : '�������';  name6 : '��������';
      char : '@'; color : cRED; gender : genMALE;
      hp : 35; speed : 100; los : 5; st : 9; dex : 5; int : 4; at : 20; def : 15;
      exp : 20; mass : 67.2;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
    ),
    ( name1 : '�������'; name2 : '��������'; name3 : '��������'; name4 : '���������'; name5 : '��������'; name6 : '���������';
      char : 'c'; color : cORANGE; gender : genMALE;
      hp :7; speed : 130; los : 6; st : 1; dex : 7; int : 1;  at : 1; def : 2;
      exp : 1; mass : 1; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '������ �����'; name2 : '������� �����'; name3 : '������� �����'; name4 : '������ ������'; name5 : '������� �����'; name6 : '������ ������';
      char : 'w'; color : cYELLOW; gender : genMALE;
      hp : 8; speed : 90; los : 5; st : 2; dex : 7; int : 1;  at : 2; def : 3;
      exp : 2; mass : 2.5; coollevel : 1;
      flags : NOF;
    ),
    ( name1 : '��������'; name2 : '��������'; name3 : '��������'; name4 : '���������'; name5 : '��������';  name6 : '���������';
      char : '@'; color : cORANGE; gender : genMALE;
      hp : 30; speed : 110; los : 6; st : 7; dex : 7; int : 6; at : 15; def : 18;
      exp : 18; mass : 63.0;
      flags : NOF or M_OPEN or M_NEUTRAL or M_NAME or M_STAY or M_HAVEITEMS;
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

var
  nx, ny : byte;

procedure CreateMonster(n,px,py : byte);   // ������� �������
function RandomMonster(x,y : byte) : byte; // ������� ���������� �������
procedure MonstersTurn;                    // � ������� ������� ���� ����� �� ���

implementation

uses
  Map, Player, Special;

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
    with M.MonL[i] do
    begin
      id := n;
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
      Rhp := MonstersData[id].hp;
      hp := Rhp;
      Rspeed := MonstersData[id].speed;
      speed := Rspeed;
      Rlos := MonstersData[id].los;
      los := Rlos;
      if IsFlag(MonstersData[id].flags, M_FELLDOWN) then
        felldown := True else
          felldown := False;
      Rst := MonstersData[id].st;
      st := Rst;
      Rdex := MonstersData[id].dex;
      dex := Rdex;
      Rint := MonstersData[id].int;
      int := Rint;
      attack := MonstersData[id].at;
      defense := MonstersData[id].def;
    end;
  end;
end;

{ ������� ���������� ������� }
function RandomMonster(x,y : byte) : byte;
begin
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
        // ��������� � ����
        if MoveToAim(false) = false then
          if MoveToAim(true) = false then
            if Random(10) <= 8 then
              MoveRandom;
      end else
        MoveRandom;
    end else
      MoveRandom;
    energy := energy - speed + (speed - pc.speed);
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
  {Find the way}
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
        r := '������ �����' + HeSheIt(id, 1);
      end else
        if hp <= Round(Rhp / 3) then
        begin
          r := '������ �����' + HeSheIt(id, 1);
        end else
          if hp <= Round(Rhp / 2) then
          begin
            r := '���������' + HeSheIt(id, 1);
          end else
            if hp <= Round(Rhp / 4)*3 then
            begin
              r := '����� �����' + HeSheIt(id, 1);
            end else
              r :=  '� ������ �����' + HeSheIt(id, 1);
  Result := r;
end;

{ ���������� � ���-������ }
procedure TMonster.TalkToMe;
var
  s : string;
  w : boolean;
  p : integer;
begin
  if relation = 0 then
  begin
      w := TRUE;
      s := MonstersData[id].name1 + ' �������: ';
      case id of
        mdMALECITIZEN, mdFEMALECITIZEN:
        begin
          case Random(4)+1 of
            1 : if pc.name = name then
                  s := '"���� ����� '+pc.name+'? � ���� ��� ��!"' else
                    s := s + '"���� ����� '+name+'. ���'+HeSheIt(id,1)+' ������������ � �����, '+pc.name+'!"';
            2 :
            case pc.quest[1] of
              0 : s := s + '"���������� ��� ����� ��� ��. ����������!"';
              1 : s := s + '"��... ���! � �� �� ��� �� ������� � ���������!"';
              2 : s := s + '"�� ��� � ���������? �, ����! ������� ���� � ����������! ��� ��� �������!"';
              3 : s := s + '"�������, �� �� ��� ���� ���! �� ��� ���� ����� ����������!"';
            end;
            3 : s := s + '"������, �� ��� ����� ����!"';
            4 : s := s + '"������� ������� ������ �� ��� ��?"';
          end;
        end;
        mdELDER:
        begin
          case pc.quest[1] of
            0 :
            begin
              w := FALSE;
              AddMsg('�� ����������'+HeroHS(2)+' '+MonstersData[id].name3+'.');
              More;
              AddMsg(MonstersData[id].name1 + ' �������: "����������, '+pc.name+'! ���� ����� '+name+'. � ���������� �������� � � ���� ���� � ���� �������."');
              More;
              AddMsg('"���������, � �������� ���� ��������� � ������� ��� ���� ������ ������ ���� ������ ��������������. ��� ��������� � ������-��������� ����� ������� � ������������ ����� ����� ���� ���� ��� �����."');
              More;
              AddMsg('"��� ������ ����� ���� ������� ���������� � ���������. ��� ������ �������� ������ ������� ����� � ��������� ������ ��� ����. �� ������ ����������� ���� ����� ������������ � ������ �������� �� �����!"');
              More;
              AddMsg('"����� ����, ������ ���� ������ ������� ���������� ������, ������� ���� ���������� �� ��� ���������! ������� ��������, ��� ������ �������� � ��������, ��... � �� ����� �� ����."');
              More;
              AddMsg('"������ �� ��� �������? � ������� �� ����� �� �����... �� �� �� ��� ����� �� ��� �������! � ����� ������ - � ��������� ������ ��� ������ ����������, ������ ��� �������������... �� ����, ��� ����� ������!"');
              More;
              AddMsg('"� ����� ����� ���� - �������� � ��������� � ������ ��� �� ����� �����!"');
              pc.quest[1] := 1;
            end;
            1 :
            begin
              case Random(3)+1 of
                1 : s := s + '"�� ���? �� ��� �� ����������'+HeroHS(1)+' ���������? ��� ����!"';
                2 : s := s + '"����������, '+pc.name+',����������! ���� � ���������!"';
                3 : s := s + '"�� ��� �������� �� ����, '+pc.name+'!"';
              end;{case}
            end;
            2 : // ��������!
            begin
              w := FALSE;
              AddMsg('�� ���������'+HeroHS(1)+' '+MonstersData[id].name3+' � ����� ����������� � ���������.');
              More;
              AddMsg('�� ����� �������� ������ ��������, ��, �������, �� ����� ���� �������...');
              More;
              AddMsg('���� ����� ���� ��� �����-������ ��������������!');
            end;
            3 : // ��� ��������������!
            begin
              w := FALSE;
              AddMsg(MonstersData[id].name3+', ����� ���� ����, ������:');
              More;
              AddMsg('"�� �� �������������, ��� � ���� ����������! �� �������'+HeroHS(1)+' ��� �� ����� �������!"');
              More;
              AddMsg('"���, ������ ��� ������, � ��������� ������� � ����� ���� ��� ���� ���-�� ����� ������� :)"');
              More;
              AddMsg('�� ����'+HeroHS(1)+' ������� ������ � �������'+HeroHS(1)+' �� � ������.');
              pc.PickUp(CreateItem(idCOIN, 500, 0), FALSE);
              pc.quest[1] := 4;
            end;
            4 : // ������� �����
            case Random(3)+1 of
              1 : s := s + '"������� ���� �������� ��� �������. �������� ���� ��� ����!"';
              2 : s := s + '"������, ��� ��� ��������!"';
              3 : s := s + '"�� ���� ������ ��������� �����!"';
            end;
          end;
        end;
        mdBREAKMT:
        begin
          case Random(3)+1 of
            1 : s := s + '"�� ������� ���� ����... �������... ������ ����������� �����, ���� �� ����� �������!"';
            2 : s := s + '"� ��� ������ �� ������� ��������. �� ���-����� � ���� ���� ���-���... ��... ���. ���� ��������!"';
            3 : s := s + '"��������� ���� �� ������. ���� ��������� ��... ���� �������� ��� ����."';
          end;
        end;
        mdBARTENDER:
        begin
          w := False;
          if (Ask(MonstersData[id].name1 + ' �������: "���� ���������� ������ ������� �������� ����� �� 15 �������, ������?" [(Y/n)]')) = 'Y' then
          begin
            if pc.FindCoins = 0 then
              AddMsg('� ���������, � ���� ������ ��� �����.') else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('� ���� ������������ ������� ����� ��� �������.') else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('�� ������������ '+MonstersData[id].name3+' ������.');
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  pc.RefreshInventory;
                  More;
                  AddMsg('�� �� ������������� � ����������� ������� ��������� ����.');
                  if pc.PickUp(CreateItem(idCHEAPBEER, 1, 0), FALSE) <> 0 then
                  begin
                    AddMsg('��� ����� �� ���.');
                    PutItem(pc.x,pc.y, CreateItem(idMEAT, 1, 0));
                  end;
                  More;
                  AddMsg('"������ �� ����� - ����� ��� ��������! ������ �������� � ������ ������������..."');
                end;
            end else
              AddMsg('"�� ��� �... ��� ���� ����������!"');
        end;
        mdDRUNK:
        begin
          s := s + '"��! ... ���... ��!"';
        end;
        mdHEALER:
        begin
          w := False;
          if pc.Hp < pc.RHp then
          begin
            if (Ask(MonstersData[id].name1 + ' �������: "������ � ������� ����?" [(Y/n)]')) = 'Y' then
            begin
              p := Round((pc.RHp - pc.Hp) * 1.5);
              if (Ask('"���� ������ ��������� ����� ������ {'+IntToStr(p)+'} �������. ����?" [(Y/n)]')) = 'Y' then
              begin
                if pc.FindCoins = 0 then
                  AddMsg('� ���������, � ���� ������ ��� �����.') else
                  if pc.inv[pc.FindCoins].amount < p then
                  begin
                    p := Round(pc.inv[pc.FindCoins].amount / 1.5);
                    if p > 0 then
                    begin
                      if (Ask('"������������ �����... ��, ���� ������, ���� ������� ��������� ���� � �� {'+IntToStr(pc.inv[pc.FindCoins].amount)+'} �������. ����?" [(Y/n)]')) = 'Y' then
                      begin
                        AddMsg('�� ������������ '+MonstersData[id].name3+' ������.');
                        pc.inv[pc.FindCoins].amount := 0;
                        pc.RefreshInventory;
                        More;
                        AddMsg('��� ���������� ������������� � ������ ��. ����� ������� ������ � ������� ������� � ���� ���� ������... ');
                        More;
                        AddMsg('[������� ���� ������� ���������, �� ��������� ������ ������ ����� �����!] ({+'+IntToStr(p)+'})');
                        inc(pc.Hp, p);
                      end else
                        AddMsg('"����� ��� ����� �������� �����������!"');
                    end else
                      AddMsg('� ���������, � ���� ������������ �����, ��� �� ���� ����-���� �����������.');
                  end else
                    if pc.inv[pc.FindCoins].amount >= p then
                    begin
                      AddMsg('�� ������������ '+MonstersData[id].name3+' ������.');
                      dec(pc.inv[pc.FindCoins].amount, p);
                      pc.RefreshInventory;
                      More;
                      AddMsg('��� ���������� ������������� � ������ ��. ����� ����� ��� ����������� ��� ���� � ����� ������... ');
                      More;
                      AddMsg('[�� ������� �� ������� ��������, ��, ����� ��������� � ����, ���������� ���� �����������!]');
                      pc.Hp := pc.RHp;
                    end;
              end;
            end else
              AddMsg('"�� ������ - ��� ������..."');
          end else
            AddMsg(MonstersData[id].name1 + ' �������: "����������, '+pc.name+'! ���� ����� '+name+'. ���� ���� ����� - ������ �� ���, � ����� ���� ������."');
        end;
        mdMEATMAN:
        begin
          w := False;
          if (Ask(MonstersData[id].name1 + ' �������: "������ ������ ����� ��������� ������� ���� ����� �� 15 �������?" [(Y/n)]')) ='Y' then
          begin
            if pc.FindCoins = 0 then
              AddMsg('� ���������, � ���� ������ ��� �����.') else
              if pc.inv[pc.FindCoins].amount < 15 then
                AddMsg('� ���� ������������ ������� ����� ��� �������.') else
                if pc.inv[pc.FindCoins].amount >= 15 then
                begin
                  AddMsg('�� ������������ '+MonstersData[id].name3+' ������.');
                  dec(pc.inv[pc.FindCoins].amount, 15);
                  RefreshInventory;
                  More;
                  AddMsg('�� �� ������������� � ������ ����� ����.');
                  if pc.PickUp(CreateItem(idMEAT, 1, 0), FALSE) <> 0 then
                  begin
                    AddMsg('��� ����� �� ���.');
                    PutItem(pc.x,pc.y, CreateItem(idMEAT, 1, 0));
                  end;
                  More;
                  AddMsg('"����������� ���, ����� �������� ������!"');
                end;
            end else
              AddMsg('"���� ����������� - ����������� ������ �� ���!"');
        end;
        else s := '�������� �������...';
      end;
      if w then AddMsg(s);
  end else
    AddMsg('��! �� �� � ����� ����������, ����� ����������!');
end;

{ ������� }
procedure TMonster.Fight(var Victim : TMonster; CA : byte);
var
  i : byte;
  dam : integer;
begin
  // ���� ����������
  if CA = 1 then
    if id = 1 then
      AddMsg('<'+MonstersData[id].name1+' �������������!>') else
        AddMsg('<'+MonstersData[id].name1+' ������������!>');
  // ���� ������ ����
  if CA = 2 then
    if id = 1 then
      AddMsg('<'+MonstersData[id].name1+' ��������� ������� ��� ���� ����!>') else
        AddMsg('<'+MonstersData[id].name1+' �������� ������� ��� ���� ����!>');
  if M.MonP[Victim.x, victim.y] > 0 then
  begin
    { --��������� �����������-- }
    if ((Victim.relation = 1) and (id = 1)) or (id > 1)  then
    begin
      if Random(dex + (ability[abACCURACY] * Round(AbilitysData[abACCURACY].koef)))+1 > Random(Victim.dex + (Victim.ability[abDODGER] * Round(AbilitysData[abDODGER].koef)))+1 then
      begin
        // ���
        if (Victim.eq[7].id > 0) and (Random(Victim.dex)+1 = 1) then
          AddMsg('{'+MonstersData[Victim.id].name1+' ����������'+HeSheIt(Victim.id,1)+' ����� ����� �����!}')
        else
          begin
            if Eq[6].id > 0 then
              Dam := Random(Round(ItemsData[Eq[6].id].attack+(st/4)))+1 else
                Dam := Random(attack)+1;
            Dam := (Dam + Round(st/4)) - Random(Round(Victim.defense/(Random(2)+1)));
            // ���� ���������� - �� ��������� ����� (� 1,1 - 2 ����)
            if CA = 1 then
              Dam := Round(Dam / (1 + ((Random(10)+1) / 10)));
            if Dam <= 0 then // �����, �� �� ������
              AddMsg(MonstersData[id].name1+' �����'+HeSheIt(id,1)+' �� '+MonstersData[Victim.id].name3+', �� �� ������'+HeSheIt(id,1)+' �����.') else
                begin
                  Victim.hp := Victim.hp - Dam;
                  Victim.BloodStreem( -(x - Victim.x), -(y - Victim.y));
                  if Victim.hp > 0 then
                  begin
                    AddMsg(MonstersData[id].name1+' �����'+HeSheIt(id,1)+' �� '+MonstersData[Victim.id].name3+'! (<'+IntToStr(Dam)+'>)');
                    if id = 1 then
                      AddMsg(MonstersData[Victim.id].name1+' '+Victim.WoundDescription+'.');
                  end else
                    begin
                      AddMsg('<'+MonstersData[id].name1+' ����'+HeSheIt(id,1)+' '+MonstersData[Victim.id].name2+'!>');
                      if id = 1 then
                      begin
                        inc(pc.exp, MonstersData[Victim.id].exp);
                        if pc.exp >= pc.ExpToNxtLvl then
                          pc.GainLevel;
                        if Victim.id = mdBLINDBEAST then
                        begin
                          AddMsg('[�� ��������'+HeroHS(1)+' �����!!!]');
                          pc.quest[1] := 2;
                          More;
                        end;
                      end;
                      Victim.Death;
                    end;
                end;
          end;
      end else
        begin
          AddMsg(MonstersData[id].name1+' ���������'+HeSheIt(id,2)+' �� '+MonstersData[Victim.id].name3+'.');
        end;
      // ���� ���� ��� �� ����
      if Victim.id > 0 then
      begin
        // ���� ����������!!!
        if Random(Round(Victim.dex / 2) + (Victim.ability[abQUICKREACTION]) * Round(AbilitysData[abQUICKREACTION].koef)) + 1 > Random(100)+1 then
          Victim.Fight(Self, 1);
        // ���� ������� ��� ���!!!
        if Random(Round(Victim.dex / 4) + (Victim.ability[abQUICKATTACK]) * Round(AbilitysData[abQUICKATTACK].koef)) + 1 > Random(100)+1 then
          Fight(Victim, 2);
      end;
    end;
    { -- ��������� ������������ --}
    if  (id = 1) and (Victim.relation = 0)then
    begin
      if Ask('����� ������� �� '+MonstersData[Victim.id].name2+'? [(Y/n)]') = 'Y' then
      begin
        AddMsg('�� ���������� �����'+HeroHS(1)+' �� '+MonstersData[Victim.id].name2+'!');
        if Victim.id = mdBREAKMT then
        begin
          More;
          AddMsg('<�� ������������'+HeroHS(1)+', ��� ��� ��� ������ ������ ���������...>');
          More;
          AddMsg('<� �� �������������� ����!>');
          More;
          Hell666You;
          pc.turn := 2;
        end else
          begin
            Victim.relation := 1; // ��������!
            AddMsg(MonstersData[Victim.id].name1+' � ������!');
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
              AddMsg('<�� ������, ��� ��� ���������� �� ����...>');
              More;
              AddMsg('<� � ������� ������� �������� ������...>');
              More;
              AddMsg('<������� � �������� ������� ���� �������� �������!>');
              More;
              AddMsg('��� �� �������'+HeroHS(1)+'! ������ ��� ������� ������ ����!');
              More;
              Fight(Victim, 0);
            end;
          end;
      end else
        AddMsg('�� ������� �������'+HeroHS(1)+' � �����'+HeroHS(1)+' ����� �� ������.');
    end;
  end else
    AddMsg('�� ����� ������ ���!');
end;

{ ������ ���� }
procedure TMonster.GiveItem(var Victim : TMonster; var GivenItem : TItem);
begin
  if ((Victim.relation = 0) and (id = 1)) or (id > 1) then
  begin
    if Ask('����� ������ '+ItemName(GivenItem, 1, TRUE)+' '+MonstersData[Victim.id].name3+'? [(Y/n)]') = 'Y' then
    begin
      // 0-�������,1-������ ���,2-��� �����,3-����������
      case Victim.PickUp(GivenItem, FALSE) of
        0 :
        begin // ������� �����
          AddMsg(MonstersData[id].name1+' �����'+HeSheIt(id,1)+' '+MonstersData[Victim.id].name3+' '+ItemName(GivenItem, 1, TRUE)+'.');
          // ����� ����� ����������
          if (GivenItem.id = idHEAD) and (GivenItem.owner = mdBLINDBEAST) then
            if pc.quest[1] > 1 then
              pc.quest[1] := 3;
          DeleteInvItem(GivenItem, TRUE);
          RefreshInventory;
        end;
        1 : AddMsg(MonstersData[id].name1+' �����'+HeSheIt(id,1)+' '+MonstersData[Victim.id].name3+' ����!');
        2 : AddMsg(MonstersData[Victim.id].name1+' ��� ����� ����� ����� �����!');
        3 : AddMsg(MonstersData[Victim.id].name1+' ����������'+HeSheIt(id,1)+' ������!');
      end;
    end else
      AddMsg('������� �������, �� �����'+HeroHS(1)+' ����� �� ������.');
  end else
    AddMsg('�������, ��� �� ������ �������...');
end;

{ ������� }
procedure TMonster.Death;
var
  i : byte;
begin
  // ������� ���������
  M.MonP[x,y] := 0;
  // ����
  if id = 1 then
    PutItem(x,y,CreateItem(idCORPSE, 1, id)) else
      begin
        if id = mdBLINDBEAST then
          PutItem(x,y,CreateItem(idHEAD, 1, id)) else
            if Random(5)+1 = 1 then
              PutItem(x,y,CreateItem(idCORPSE, 1, id));
      end;
  // �������� ����
  for i:=1 to EqAmount do
    if Eq[i].id > 0 then
    begin
      PutItem(x,y, Eq[i]);
      FillMemory(@Eq[i], SizeOf(TItem), 0);
    end;
  for i:=1 to MaxHandle do
    if Inv[i].id > 0 then
    begin
      PutItem(x,y, Inv[i]);
      FillMemory(@Inv[i], SizeOf(TItem), 0);
    end;
  // ���� ��� �����, ��
  if id = 1 then
  begin
    id := 0;
    pc.AfterDeath;
  end else
    id := 0;
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
      M.blood[x+(dx*i),y+(dy*i)] := Random(2)+1;
      if TilesData[M.Tile[x+(dx*i),y+(dy*i)]].move = False then
        break;
    end;
  end else
    M.blood[x,y] := Random(2)+1;
end;

{ ������� ���� }
function TMonster.PickUp(Item : TItem; FromEq : boolean) : byte;
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
          if (Inv[i].id = Item.id) and (Inv[i].owner = Item.owner) then
          begin
            inc(Inv[i].amount, Item.amount);
            f := TRUE;
            break;
          end;
        if f = false then
          for i:=1 to MaxHandle do
            if Inv[i].id = 0 then
            begin
              if (invmass + (Item.mass*Item.amount) < MaxMass) or (FromEq) then
              begin
                Inv[i] := Item;
                invmass := invmass + (Item.mass*Item.amount);
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
  Result := st * 15.8;
end;

{ ������� ������� �� ��������� }
procedure TMonster.DeleteInvItem(var I : TItem; full : boolean);
begin
  // �����
  invmass := invmass - (I.mass*I.amount);
  if (I.amount > 1) and (not full) then
    dec(I.amount) else
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

end.