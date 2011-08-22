unit player;

interface

uses
  Main, Monsters, Cons, Tile, Utils, Msg, Flags, Items, SysUtils, Classes;

type
  Tpc = object (TMonster)
    turn        : byte;                          // ������ ���? (0���,1��,2��+�����������)
    level       : byte;                          // ����� �������
    enter       : byte;                          // ����� ����� � ������ �� �������
    depth       : byte;                          // ������� � ������
    quest       : array[1..QuestsAmount] of byte;// ������: 0�� ���� �����,1����,2��������,3��������� ���������
    inv         : array[1..MaxHandle] of TItem;  // �������� �����
    invmass     : real;                          // ����� ��������� � ����������
    color       : longword;                      // ����
    //
    exp         : integer;                       // ���-�� �����
    explevel    : byte;                          // ������� ��������
    //
    status      : array[1..2] of integer;        // �������� (1-�����)

    procedure Prepare;                     // ���������� � ����� ������ ����
    procedure Move(dx,dy : shortint);      // ������� �����
    procedure FOV;                         // ���� ���������
    procedure AfterTurn;                   // �������� ����� ���� �����
    procedure AnalysePlace(px,py: byte;    // ������� �����
                        All : boolean);
    procedure PlaceHere(px,py : byte);     // ��������� ����� � ��� �����
    procedure UseStairs;                   // ���������� ��� ��������� �� ��������
    procedure PlaceAtTile(t : byte);       // ����������� ����� �� ����
    procedure SearchForDoors;              // ������� ������ �����
    procedure SearchForAlive;              // ������� �������� �����
    procedure CloseDoor(dx,dy : shortint); // ������� �����
    procedure MoveLook(dx,dy : shortint);  // ������� ������ �������
    procedure WriteInfo;                   // ������� ���������� �� ����� ������
    procedure SearchForTalk;               // ������� ����� �����
    procedure Talk(dx,dy : shortint);      // ��������
    procedure QuestList;                   // ������ �������
    procedure Equipment;                   // ����������
    procedure Inventory;                   // ���������
    function ItemsAmount : byte;           // ����������� �����
    function PickUp(Item : TItem;
                FromEq : boolean) : byte;  // ��������� ���� � ��������� (0-�������,1-������ ���,2-��� �����,3-����������
    procedure GainLevel;                   // ��������� ������
    function GiveRang : string;            // ���� ����� ������ �� ��� ������ � ������
    function ExpToNxtLvl : integer;        // ������� ����� ����� ��� ���������� ������
    procedure UseMenu;                     // ���� �������� � ���������
    function MaxMass : real;               // ������� ����� ����� �����
    function EquipItem(Item : TItem) : byte;// ��������� ������� (0-�������,1-������ ������)
    procedure RefreshInventory;            // ��������� ���������
    procedure AfterDeath;                  // �������� ����� ������ �����
    procedure DeleteInvItem(var I : TItem;
                      full : boolean);     // ������� ������� �� ���������
    function FindCoins : byte;             // ����� ������ � ��������
  end;

var
  pc      : Tpc;
  lx, ly  : byte;                          // ���������� ������� �������
  cell : byte;


implementation

uses
  Map, Special;

{ ���������� � ����� ������ ���� }
procedure Tpc.Prepare;
begin
  name := GenerateName(FALSE);
  level := 1; // �������
  depth := 0; 
  los := 6;
  speed := 100;
  Rhp := 25;
  hp := Rhp;
  exp := 0;
  explevel := 1;
  Rst := 8;
  st := Rst;
  Rdex := 7;
  dex := Rdex;
  Rint := 5;
  int := Rint;
  status[1] := 0;
  status[2] := 0;
  attack := 4;  // ������ ������

  PickUp(CreateItem(idCOIN, 50), FALSE);
  EquipItem(CreateItem(idKITCHENKNIFE, 1));
  EquipItem(CreateItem(idJACKSONSHAT, 1));
  EquipItem(CreateItem(idLAPTI, 1));
  PickUp(CreateItem(idPOTIONCURE, 2), FALSE);
  PickUp(CreateItem(idPOTIONHEAL, 1), FALSE);
  PickUp(CreateItem(idMEAT, 1), FALSE);
  PickUp(CreateItem(idGREENAPPLE, 3), FALSE);
end;

{ ������� ����� }
procedure Tpc.Move(dx,dy : shortint);
begin
  case pc.Replace(x+dx,y+dy) of
    0 : // ������ ����
    if (x = x+dx)and(y = y+dy) then
    begin
      M.MonP[x,y] := 1;
      turn := 1;
    end else
      // �������� �������
      if (pc.level = 1) and(pc.depth = 0) and (x+dx = 1) and (y+dy = 18) then
      begin
        if Ask('������ �������� ������� � ����� �� ����? [(Y/n)]') then
        begin
          AskForQuit := FALSE;
          MainForm.Close;
        end else
          AddMsg('�� ����� ��������.');
      end else
        // ������ �������������
        begin
          turn := 2;
          M.MonP[x,y] := 0;
          x := x + dx;
          y := y + dy;
          M.MonP[x,y] := 1;
        end;
    2 : // �����
    if M.Tile[x+dx,y+dy] = tdCDOOR then
    begin
      M.Tile[x+dx,y+dy] := tdODOOR;
      AddMsg('�� ������ �����.');
      pc.turn := 1;
    end;
    3 : // ���-�� �����
    begin
      if (M.MonL[M.MonP[x+dx,y+dy]].relation = 0) and (not M.MonL[M.MonP[x+dx,y+dy]].felldown) then
      begin
        // ������ ���������� �������
        AddMsg('�� � '+MonstersData[M.MonL[M.MonP[x+dx,y+dy]].id].name1+' ���������� �������.');
        M.MonP[x,y] := M.MonP[x+dx,y+dy];
        M.MonL[M.MonP[x,y]].x := x;
        M.MonL[M.MonP[x,y]].y := y;
        x := x + dx;
        y := y + dy;
        M.MonP[x,y] := 1;
        pc.turn := 2;
      end else
        begin
          // ���������
          pc.Fight(M.MonL[M.MonP[x+dx,y+dy]]);
          pc.turn := 1;
        end;
    end;
  end;
end;

{ ���� ��������� }
procedure TPc.Fov;
const
  quads : array[1..4] of array[1..2] of ShortInt = ((1,1),(-1,-1),(-1,+1),(+1,-1));
  RayNumber = 32;
  RayWidthCorrection = 10;
var
  a, b, tx, ty, mini, maxi, cor, u, v : integer;
  quad, slope : byte;
  // ��������� ����
  procedure PictureIt(x,y : byte);
  begin
    if (x>0)and(x<=MapX)and(y>0)and(y<=MapY)then
    begin
      M.Saw[x,y] := 2;
      if M.MonP[x,y] > 0 then
        M.Mem[x,y] := MonstersData[M.MonL[M.MonP[x,y]].id].char else
          if M.Item[x,y].id > 0 then
            M.Mem[x,y] := ItemSymbol(M.Item[x,y].id) else
              M.Mem[x,y] := TilesData[M.Tile[x,y]].Char;
    end;
  end;
begin
  for a:=x-los-2 to x+los+2 do
    for b:=y-los-2 to y+los+2 do
      if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
         if M.Saw[a,b] > 0 then
           M.Saw[a,b] := 1;
  M.Saw[pc.x,pc.y] := 2;
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

{ �������� ����� ���� ����� }
procedure TPc.AfterTurn;
begin
  if pc.turn > 0 then
  begin
    // ��� ��������
    MonstersTurn;
    // ����� ��������� �����:)
    Pc.Fov;
    // ���� ������������ �� ������ ������ - ������� ��������, ���� ����
    if pc.turn = 2 then AnalysePlace(pc.x,pc.y,False);
    // ��������
    pc.turn := 0;
    // ����� ������
    inc(status[stHUNGRY]);
    // ������
    if status[stDRUNK] > 0 then
      dec(status[stDRUNK]);
    if status[stHUNGRY] = 1500 then
    begin
      AddMsg('<�� ��� ������� �������...>');
      More;
      pc.hp := 0;
    end;
    // ����������� (���� �� ������� � ������)
    if (pc.hp < pc.Rhp) and (pc.status[stHUNGRY] <= 1200) then
      if Random(50)+1 = 50 then
        inc(pc.hp);
    if pc.Hp <= 0 then Death;
  end;
  MainForm.OnPaint(NIL);
end;

{ ������� ����� }
procedure TPc.AnalysePlace(px,py : byte; All : boolean);
var
  s : string;
  n : byte;
begin
  // ����
  if (All)or(TilesData[M.Tile[px,py]].important) or (M.Blood[px,py] > 0) then
    if M.Blood[px,py] > 0 then
      AddMsg(TilesData[M.Tile[px,py]].name+' � �����.') else
        AddMsg(TilesData[M.Tile[px,py]].name+'.');
  // ������
  if All then
    if M.MonP[px,py] > 0 then
    begin
      if M.MonP[px,py] = 1 then
        AddMsg('��� �� - '+pc.name+'. �� ' + pc.WoundDescription + '.') else
          begin
            if M.MonL[M.MonP[px,py]].felldown then
              s := '����� ����� '+MonstersData[M.MonL[M.MonP[px,py]].id].name1 else
                s := MonstersData[M.MonL[M.MonP[px,py]].id].name1;
            if IsFlag(MonstersData[M.MonL[M.MonP[px,py]].id].flags, M_NAME) then
              s := s + ' �� ����� ' + M.MonL[M.MonP[px,py]].name;
            s := s + '. ��' + HeSheIt(M.MonL[M.MonP[px,py]].id, 1) +' '+ M.MonL[M.MonP[px,py]].WoundDescription+'.';
            AddMsg(s);
          end;
     end;
  // �������
  if M.Item[px,py].id > 0 then
  begin
    if M.Item[px,py].amount = 1 then
      AddMsg('����� ����� '+ItemsData[M.Item[px,py].id].name1+'.') else
        AddMsg('����� ����� '+ItemsData[M.Item[px,py].id].name2+' ('+IntToStr(M.Item[px,py].amount)+' ��).');
  end;
end;

{ ��������� ����� � ��� ����� }
procedure TPc.PlaceHere(px,py : byte);
begin
  M.MonP[px,py] := 1;
  pc.x := px;
  pc.y := py;
end;

{ ���������� ��� ��������� �� ��������}
procedure TPc.UseStairs;
begin
  if M.Tile[pc.x,pc.y] = tdDSTAIRS then
  begin
    M.MonP[pc.x,pc.y] := 0;
    if M.Save = False then AddMsg('�������� �� �������. ��� �� �����, � ������� ���� ������ ������.');
    if pc.enter = 0 then pc.enter := GetEnterNumber;
    inc(pc.depth);
    if M.Load(pc.level, pc.enter, pc.depth) = False then
      if (pc.enter = 1) and (pc.depth < 5) then
        M.GenerateCave(M.DungeonType, TRUE) else
          if (pc.enter = 1) and (pc.depth = 5) then
            LastLevelOfStoreHouse;
    PlaceAtTile(tdUSTAIRS);
    pc.turn := 2;
    AddMsg('�� ��������� ���� �� �������� �� ������� '+IntToStr(pc.depth)+'.');
  end else
    if M.Tile[pc.x,pc.y] = tdUSTAIRS then
    begin
      M.MonP[pc.x,pc.y] := 0;
      if M.Save = False then AddMsg('�������� �� �������. ��� �� �����, � ������� ���� ������ ������.');
      dec(pc.depth);
      if pc.depth = 0 then pc.enter := 0;
      if M.Load(pc.level,pc.enter,pc.depth) = False then
      begin
        AddMsg('�� ������� ��������� �����. �������� ���� � ����������� ��� ������, ���� ��� �� ������� ��������.');
        More;
        AddMsg('<��� ����������� ������. ���� ��������.>');
        More;
        AskForQuit := FALSE;
        MainForm.Close;
      end;
      if pc.depth = 0 then PlaceOnStairs(pc.level, pc.enter) else PlaceAtTile(tdDSTAIRS);
      pc.turn := 2;
      if pc.depth > 0 then
        AddMsg('�� �������� �� ��������  �� ������� '+IntToStr(pc.depth)+'.') else
          AddMsg('�� �������� �� �������� � ����� �������� �� ������ �������.');
    end;
end;

{ ����������� ����� �� ���� }
procedure TPc.PlaceAtTile(t : byte);
var
  a, b : byte;
begin
  for a:=1 to MapX do
    for b:=1 to MapY do
      if M.Tile[a,b] = t then
      begin
        pc.x := a;
        pc.y := b;
        M.MonP[x,y] := 1;
        exit;
      end;
end;

{ ������� ������ ����� }
procedure Tpc.SearchForDoors;
var
  a,b,i : shortint;
begin
  i := 0;
  for a := pc.x - 1 to pc.x + 1 do
    for b := pc.y - 1 to pc.y + 1 do
      if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
        if M.Tile[a,b] = tdODOOR then
          inc(i);
  case i of
    0 : AddMsg('����� ��� �������� �����!');
    1 :
    begin
      for a := pc.x - 1 to pc.x + 1 do
        for b := pc.y - 1 to pc.y + 1 do
          if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
            if M.Tile[a,b] = tdODOOR then
            begin
              CloseDoor(a - pc.x, b - pc.y);
              exit;
            end;
    end;
    else
      begin
        AddMsg('����� ������ ����� �� ������ �������?');
        GameState := gsCLOSE;
      end;
  end;
end;

{ ������� �������� ����� }
procedure Tpc.SearchForAlive;
var
  a,b,i : shortint;
begin
  i := 0;
  for a := pc.x - 1 to pc.x + 1 do
    for b := pc.y - 1 to pc.y + 1 do
      if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
        if M.MonP[a,b] > 1 then
          inc(i);
  case i of
    0 : AddMsg('����� � ����� ������ ���!');
    1 :
    begin
      for a := pc.x - 1 to pc.x + 1 do
        for b := pc.y - 1 to pc.y + 1 do
          if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
            if M.MonP[a,b] > 1 then
              pc.Fight(M.MonL[M.MonP[a,b]]);
    end;
    else
      begin
        AddMsg('�� ���� ������ �� ������ �������?');
        GameState := gsATACK;
      end;
  end;
end;

{ ������� ����� }
procedure TPc.CloseDoor(dx,dy : shortint);
var
  a,b : integer;
begin
  a := pc.x + dx;
  b := pc.y + dy;
  if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
  begin
    if M.Tile[a,b] = tdODOOR then
    begin
      AddMsg('�� ������ �����.');
      M.Tile[a,b] := tdCDOOR;
      pc.turn := 1;
    end else
      AddMsg('����� ��� �������� �����!');
  end;
end;

{ ������� ������ ������� }
procedure TPc.MoveLook(dx,dy : shortint);
var
  a,b : integer;
begin
  a := lx + dx;
  b := ly + dy;
  if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
    if M.Saw[a,b] = 2 then
      begin
        lx := a;
        ly := b;
        AnalysePlace(lx,ly,True);
      end;
end;

{ ������� ���������� �� ����� ������ }
procedure Tpc.WriteInfo;
begin
  with Screen.Canvas do
  begin
    Font.Color := cLIGHTGRAY;
    // ���
    TextOut(82*CharX, 2*CharY, '��� :'+name);
    // ����
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 3*CharY, '����:');
    Font.Color := cBROWN;
    TextOut(87*CharX, 3*CharY, GiveRang);
    Font.Color := cBROWN;
    TextOut(81*CharX, 5*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 7*CharY, '�������� :');
    Font.Color := ReturnColor(Rhp, hp, 1);
    TextOut(92*CharX, 7*CharY, IntToStr(hp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, 7*CharY, '('+IntToStr(Rhp)+')');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 8*CharY, '����     :');
    Font.Color := ReturnColor(Rmp, mp, 2);
    TextOut(92*CharX, 8*CharY, IntToStr(mp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, 8*CharY, '('+IntToStr(Rmp)+')');
    Font.Color := cLIGHTGRAY;
    Font.Color := cBROWN;
    TextOut(81*CharX, 10*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 12*CharY, '����     :');
    if st > Rst then
      Font.Color := cLIGHTGREEN else
        if st < Rst then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, 12*CharY, IntToStr(st));
    TextOut(82*CharX, 13*CharY, '�������� :');
    if dex > Rdex then
      Font.Color := cLIGHTGREEN else
        if dex < Rdex then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, 13*CharY, IntToStr(dex));
    TextOut(82*CharX, 14*CharY, '���������:');
    if int > Rint then
      Font.Color := cLIGHTGREEN else
        if int < Rint then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, 14*CharY, IntToStr(int));
    Font.Color := cBROWN;
    TextOut(81*CharX, 16*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 18*CharY, '�������  :'+IntToStr(explevel));
    TextOut(82*CharX, 19*CharY, '����     :'+IntToStr(exp));
    TextOut(82*CharX, 20*CharY, '�����    :'+IntToStr(ExpToNxtLvl));
    Font.Color := cBROWN;
    TextOut(81*CharX, 22*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    if pc.depth > 0 then
      TextOut(82*CharX, 24*CharY, '�������  : '+IntToStr(pc.depth)) else
        case pc.level of
          1 : TextOut(82*CharX, 24*CharY, '������� �������');
        end;
    Font.Color := cBROWN;
    TextOut(81*CharX, 26*CharY, '-------------------');
    case pc.status[stHUNGRY] of
      -500..-400:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, 28*CharY, '������...');
      end;
      -399..-1  :
      begin
        Font.Color := cGREEN;
        TextOut(82*CharX, 28*CharY, '������...');
      end;
      0..450    :
      begin
        Font.Color := cGRAY;
        TextOut(82*CharX, 28*CharY, '�����');
      end;
      451..750  :
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, 28*CharY, '������������');
      end;
      751..1200  :
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, 28*CharY, '�������!');
      end;
      1201..1500 :
      begin
        Font.Color := cRED;
        TextOut(82*CharX, 28*CharY, '������ �� ������!');
      end;
    end;
    case pc.status[stDRUNK] of
      350..500:
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, 29*CharY, '����������');
      end;
      501..800:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, 29*CharY, '������! ��!');
      end;
    end;
  end;
end;

{ ������� ����� ����� }
procedure Tpc.SearchForTalk;
var
  a,b,i : shortint;
begin
  i := 0;
  for a := pc.x - 1 to pc.x + 1 do
    for b := pc.y - 1 to pc.y + 1 do
      if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
        if M.MonP[a,b] > 1 then
          inc(i);
  case i of
    0 : AddMsg('����� �� � ��� ����������!');
    1 :
    begin
      for a := pc.x - 1 to pc.x + 1 do
        for b := pc.y - 1 to pc.y + 1 do
          if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
            if M.MonP[a,b] > 1 then
            begin
              Talk(a - pc.x, b - pc.y);
              exit;
            end;
    end;
    else
      begin
        AddMsg('� ��� ������ �� ������ ����������?');
        GameState := gsTALK;
      end;
  end;
end;

{ �������� }
procedure Tpc.Talk(dx,dy : shortint);
var
  a,b : integer;
begin
  a := pc.x + dx;
  b := pc.y + dy;
  if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
  begin
    if M.MonP[a,b] > 1 then
    begin
      M.MonL[M.MonP[a,b]].TalkToMe;
      pc.turn := 1;
    end else
      AddMsg('����� �� � ��� ����������!');
  end;
end;

{ ������ ������� }
procedure Tpc.QuestList;
begin
  StartDecorating('<-������ ������� �������->');
  with Screen.Canvas do
  begin
    if (pc.quest[1] = 0) or (pc.quest[1] = 3) then
    begin
      Font.Color := cYELLOW;
      TextOut(5*CharX,5*CharY,'( ��� ������� )');
    end;
    if (pc.quest[1] = 1)or(pc.quest[1] = 2) then
    begin
     Font.Color := cLIGHTGRAY;
     TextOut(4*CharX,5*CharY,'���������� ������� ������� �������� ��� ����������� ��������� � ���������� ����� �� ���,');
     TextOut(3*CharX,6*CharY,' ��������� � ���');
     case pc.quest[1] of
       1 :
       begin
         Font.Color := cRED;
         TextOut(3*CharX,5*CharY,'-');
       end;
       2 :
       begin
         Font.Color := cLIGHTGREEN;
         TextOut(3*CharX,5*CharY,'+');
       end;
     end;
    end;
  end;
end;

{ ���������� }
procedure Tpc.Equipment;
const
  s1 = '< ����� ''i'' ����� ������� ��� ����, ������� �� ������ >';
  s2 = '< ���� ��������� ����! >';
var
  i : byte;
begin
  StartDecorating('<-����������->');
  with Screen.Canvas do
  begin
    Font.Color := cBROWN;
    TextOut(5*CharX, 11*CharY, '[ ] - ������            :');
    TextOut(5*CharX, 12*CharY, '[ ] - ���               :');
    TextOut(5*CharX, 13*CharY, '[ ] - ����              :');
    TextOut(5*CharX, 14*CharY, '[ ] - ����              :');
    TextOut(5*CharX, 15*CharY, '[ ] - ����              :');
    TextOut(5*CharX, 16*CharY, '[ ] - ������            :');
    TextOut(5*CharX, 17*CharY, '[ ] - ���               :');
    TextOut(5*CharX, 18*CharY, '[ ] - ��������          :');
    TextOut(5*CharX, 19*CharY, '[ ] - ������            :');
    TextOut(5*CharX, 20*CharY, '[ ] - ��������          :');
    TextOut(5*CharX, 21*CharY, '[ ] - �����             :');
    TextOut(5*CharX, 22*CharY, '[ ] - ���������         :');
    for i:=1 to EqAmount do
      if pc.eq[i].id = 0 then
      begin
        Font.Color := cWHITE;
        TextOut(31*CharX,(10+i)*CharY,'-');
      end else
        begin
          Font.Color := cLIGHTGRAY;
          if pc.eq[i].amount = 1 then
            TextOut(31 * CharX, (10+i)*CharY, ItemsData[pc.eq[i].id].name1) else
              TextOut(31 * CharX, (10+i)*CharY, ItemsData[pc.eq[i].id].name2+' ('+IntToStr(pc.eq[i].amount)+' ��)');
        end;
    Font.Color := cGRAY;
    if ItemsAmount > 0 then
      TextOut(((WindowX-length(s1)) div 2) * CharX, 37*CharY, s1) else
        TextOut(((WindowX-length(s2)) div 2) * CharX, 37*CharY, s2);
    Font.Color := cRED;
    TextOut(6*CharX, (10+MenuSelected)*CharY,'*');
  end;
  WriteSomeAboutItem(pc.Eq[MenuSelected]);
end;

{ ��������� }
procedure Tpc.Inventory;
const
  s1 = '< ����� ENTER ��� ����, ��� �� ������������ ������� >';
  s2 = '< ����� ''i'' ����� ������� � ����� ����������  >';
var
  i : byte;
begin
  StartDecorating('<-���������->');
  with Screen.Canvas do
  begin
    Font.Color := cGRAY;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 35*CharY, s1);
    TextOut(((WindowX-length(s2)) div 2) * CharX, 37*CharY, s2);
    for i:=1 to ItemsAmount do
    begin
      Font.Color := cBROWN;
      TextOut(5 * CharX, (2+i)*CharY, '[ ]');
      Font.Color := cLIGHTGRAY;
      if pc.inv[i].amount = 1 then
        TextOut(9 * CharX, (2+i)*CharY, ItemsData[pc.inv[i].id].name1) else
          TextOut(9 * CharX, (2+i)*CharY, ItemsData[pc.inv[i].id].name2+' ('+IntToStr(pc.inv[i].amount)+' ��)');
      Font.Color := cRED;
      TextOut(6*CharX, (2+MenuSelected)*CharY,'*');
    end;
    WriteSomeAboutItem(pc.Inv[MenuSelected]);
  end;
end;

{ ����������� ����� }
function Tpc.ItemsAmount : byte;
var
  i,k : byte;
begin
  k := 0;
  for i:=1 to MaxHandle do
  begin
    if Inv[i].id > 0 then inc(k);
  end;
  Result := k;
end;

{ ������� ���� }
function Tpc.PickUp(Item : TItem; FromEq : boolean) : byte;
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
          if pc.Inv[i].id = Item.id then
          begin
            inc(pc.Inv[i].amount, Item.amount);
            f := TRUE;
            break;
          end;
        if f = false then
          for i:=1 to MaxHandle do
            if pc.Inv[i].id = 0 then
            begin
              if (pc.invmass + (ItemsData[Item.id].mass*Item.amount) < pc.MaxMass) or (FromEq) then
              begin
                pc.Inv[i] := Item;
                pc.invmass := pc.invmass + (ItemsData[Item.id].mass*Item.amount);
                break;
              end else
                begin
                  Result := 3;
                  break;
                end;
            end else
              if (i = MaxHandle) and(pc.Inv[i].id <> 0) then
                Result := 2;
      end;
end;

{ ��������� ������ }
procedure Tpc.GainLevel;
begin
  AddMsg('{����������! �� ������ ������ ������ ��������!}');
  More;
  pc.Rhp := pc.Rhp + round(pc.Rhp/4);
  // �������� �������, �������� ������� �����
  inc(pc.explevel);
  pc.exp  := 0;
end;

{ ���� ����� ������ �� ��� ������ � ������ }
function Tpc.GiveRang : string;
begin
  case pc.explevel of
    1 : Result := '��������';
    else
      Result := '�����������';
  end;
  // ���� ����� � ���
  if pc.level = 0 then
    Result := '�������';
end;

{ ������� ����� ����� ��� ���������� ������ }
function Tpc.ExpToNxtLvl : integer;
begin
  Result := Round((explevel * 20) - (int/1.5));
end;

{ ���� �������� � ��������� }
procedure Tpc.UseMenu;
var
  i : byte;
begin
  with Screen.Canvas do
  begin
    DrawBorder(75,2,20,HOWMANYVARIANTS+1);
    Font.Color := cBROWN;
    TextOut(77*CharX, 3*CharY, '[ ]');
    Font.Color := cWHITE;
    if WasEq then
      // � ����������
      TextOut(81*CharX, 3*CharY, '� ���������') else
        // � ���������
        TextOut(81*CharX, 3*CharY, WhatToDo(pc.Inv[MenuSelected].id));
    Font.Color := cBROWN;
    TextOut(77*CharX, 4*CharY, '[ ]');
    Font.Color := cWHITE;
    TextOut(81*CharX, 4*CharY, '�����������');
    Font.Color := cBROWN;
    TextOut(77*CharX, 5*CharY, '[ ]');
    Font.Color := cWHITE;
    TextOut(81*CharX, 5*CharY, '�������');
    Font.Color := cBROWN;
    TextOut(77*CharX, 6*CharY, '[ ]');
    Font.Color := cWHITE;
    TextOut(81*CharX, 6*CharY, '������');
    Font.Color := cBROWN;
    TextOut(77*CharX, 7*CharY, '[ ]');
    Font.Color := cRED;
    TextOut(81*CharX, 7*CharY, '��������');
    Font.Color := cYELLOW;
    TextOut(78*CharX, (2+MenuSelected2)*CharY, '*');
  end;
end;

{ ������� ����� ����� ����� }
function Tpc.MaxMass : real;
begin
  Result := pc.st * 15.8;
end;

{ ��������� ������� }
function Tpc.EquipItem(Item : TItem) : byte;
begin
  Result := 0;
  case ItemsData[Item.id].vid of
    1 : cell := 1; // ����
    2 : cell := 2; // ������
    3 : cell := 3; // ����
    4 : cell := 4; // ����� �� ����
    5 : cell := 5; // ������
    6 : cell := 6; // ������ �������� ���
    7 : cell := 6; // ������ �������� ���
    8 : cell := 7; // ���
    9 : cell := 8; // �������
    10: cell := 9; // ������
    11: cell := 10; // ��������
    12: cell := 11; // �����
    13: cell := 12; // ���������
  end;
  // ������ ������
  if pc.eq[cell].id > 0 then Result := 1 else
  begin
    pc.eq[cell] := Item;
    if cell <> 12 then
      if pc.eq[cell].amount > 1 then pc.eq[cell].amount := 1; 
  end;
end;

{ ��������� ��������� }
procedure TPc.RefreshInventory;
var
  i : byte;
begin
  for i:=1 to MaxHandle-1 do
    if pc.inv[i].id = 0 then
    begin
      pc.inv[i] := pc.inv[i+1];
      pc.inv[i+1].id := 0;
    end;
end;

{ �������� ����� ������ ����� }
procedure TPc.AfterDeath;
begin
  AddMsg('<�� ����!!!>');
  More;
  AskForQuit := FALSE;
  MainForm.Close;
end;

{ ������� ������� �� ��������� }
procedure TPc.DeleteInvItem(var I : TItem; full : boolean);
begin
  // �����
  pc.invmass := pc.invmass - (ItemsData[I.id].mass*I.amount);
  if (I.amount > 1) and (not full) then
    dec(I.amount) else
      I.id := 0;
  RefreshInventory;
end;

{ ����� ������ � �������� }
function TPc.FindCoins : byte;
var
  i : byte;
begin
  Result := 0;
  for i:=1 to MaxHandle do
    if pc.Inv[i].id = idCOIN then
      begin
        Result := i;
        break;
      end;
end;
end.

