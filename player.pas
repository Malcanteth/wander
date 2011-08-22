unit player;

interface

uses
  Main, Monsters, Cons, Tile, Utils, Msg, Flags, Items, SysUtils, Classes, Ability, Windows;

type
  Tpc = object (TMonster)
    turn        : byte;                          // ������ ���? (0���,1��,2��+�����������)
    level       : byte;                          // ����� �������
    enter       : byte;                          // ����� ����� � ������ �� �������
    depth       : byte;                          // ������� � ������
    quest       : array[1..QuestsAmount] of byte;// ������: 0�� ���� �����,1����,2��������,3��������� ���������,4��������
    color       : longword;                      // ����
    gender      : byte;                          // ���
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
    procedure SearchForAlive
                        (whattodo : byte); // ������� �������� ����� (1-���������, 2-��������, 3-������)
    procedure CloseDoor(dx,dy : shortint); // ������� �����
    procedure Open(dx,dy : shortint);      // ������� 
    procedure MoveLook(dx,dy : shortint);  // ������� ������ �������
    procedure WriteInfo;                   // ������� ���������� �� ����� ������
    procedure Talk(Mon : TMonster);      // ��������
    procedure QuestList;                   // ������ �������
    procedure Equipment;                   // ����������
    procedure Inventory;                   // ���������
    function ItemsAmount : byte;           // ����������� �����
    procedure GainLevel;                   // ��������� ������
    function ExpToNxtLvl : integer;        // ������� ����� ����� ��� ���������� ������
    procedure UseMenu;                     // ���� �������� � ���������
    procedure AfterDeath;                  // �������� ����� ������ �����
    function FindCoins : byte;             // ����� ������ � ��������
    procedure HeroName;                    // ���� ����� �����
    procedure HeroGender;                  // ���� ������ ����
    procedure Search(modif : byte);        // ������
  end;

var
  pc      : Tpc;
  lx, ly  : byte;                          // ���������� ������� �������
  cell    : byte;
  crstep  : byte;


implementation

uses
  Map, MapEditor;

{ ���������� � ����� ������ ���� }
procedure Tpc.Prepare;
begin
  id := 1;
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

  PickUp(CreateItem(idCOIN, 50, 0), FALSE);
  EquipItem(CreateItem(idDAGGER, 1, 0));
  EquipItem(CreateItem(idJACKSONSHAT, 1, 0));
  EquipItem(CreateItem(idJACKET, 1, 0));
  EquipItem(CreateItem(idLAPTI, 1, 0));
  PickUp(CreateItem(idPOTIONCURE, 2, 0), FALSE);
  PickUp(CreateItem(idPOTIONHEAL, 1, 0), FALSE);
  PickUp(CreateItem(idMEAT, 1, 0), FALSE);
  PickUp(CreateItem(idLAVASH, 2, 0), FALSE);
end;

{ ������� ����� }
procedure Tpc.Move(dx,dy : shortint);
begin
  case pc.Replace(x+dx,y+dy) of
    0 :
    // ������������� �� ������ �������
    if (x+dx = 1) or (x+dx = MapX) or (y+dy = 1) or (y+dy = MapY) then
    begin
      // �� �����
      if x + dx = 1 then
      begin
        if SpecialMaps[pc.level].Loc[3] = 0 then
        begin
          if Ask('������ ������� ��� ��������?! [(Y/n)]') = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('�� �����'+HeSheIt(1)+' ��������.');
        end else
          begin
            // ������ ��������� �� �����
            M.MonP[pc.x,pc.y] := 0;
            // ��������� �������
            if M.Save = False then AddMsg('�������� �� ������� <:(>');
            // ������  ����� �������
            pc.level := SpecialMaps[pc.level].Loc[3];
            // ���� ��������� �� ������� - ������ ��������� ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then
            begin
              M.Clear;
              M := SpecialMaps[pc.level].Map;
            end;
            pc.x := MapX - 1;
            M.MonP[pc.x,pc.y] := 1;
            pc.turn := 2;
          end
      end else
      // �� ������
      if x + dx = MapX then
      begin
        if SpecialMaps[pc.level].Loc[4] = 0 then
        begin
          if Ask('����������! �� ��������'+pc.HeSheIt(3)+' ������ ������ ������ ����! ������ ������ ����? [(Y/n)]') = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('�� �����'+HeSheIt(1)+' ��������.');
        end else
          begin
            // ������ ��������� �� �����
            M.MonP[pc.x,pc.y] := 0;
            // ��������� �������
            if M.Save = False then AddMsg('�������� �� ������� <:(>');
            // ������  ����� �������
            pc.level := SpecialMaps[pc.level].Loc[4];
            // ���� ��������� �� ������� - ������ ��������� ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then
            begin
              M.Clear;
              M := SpecialMaps[pc.level].Map;
            end;
            pc.x := 2;
            M.MonP[pc.x,pc.y] := 1;
            pc.turn := 2;
          end;
      end else
      // �� �����
      if y + dy = 1 then
      begin
        if SpecialMaps[pc.level].Loc[1] = 0 then
        begin
          if Ask('������ ������� ��� ��������?! [(Y/n)]') = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('�� �����'+HeSheIt(1)+' ��������.');
        end else
          begin
            // ������ ��������� �� �����
            M.MonP[pc.x,pc.y] := 0;
            // ��������� �������
            if M.Save = False then AddMsg('�������� �� ������� <:(>');
            // ������  ����� �������
            pc.level := SpecialMaps[pc.level].Loc[1];
            // ���� ��������� �� ������� - ������ ��������� ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then
            begin
              M.Clear;
              M := SpecialMaps[pc.level].Map;
            end;
            pc.y := MapY - 1;
            M.MonP[pc.x,pc.y] := 1;
            pc.turn := 2;
          end;
      end else
      // �� ��
      if y + dy = MapY then
      begin
        if SpecialMaps[pc.level].Loc[2] = 0 then
        begin
          if Ask('������ ������� ��� ��������?! [(Y/n)]') = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('�� �����'+HeSheIt(1)+' ��������.');
        end else
          begin
            // ������ ��������� �� �����
            M.MonP[pc.x,pc.y] := 0;
            // ��������� �������
            if M.Save = False then AddMsg('�������� �� ������� <:(>');
            // ������  ����� �������
            pc.level := SpecialMaps[pc.level].Loc[2];
            // ���� ��������� �� ������� - ������ ��������� ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then
            begin
              M.Clear;
              M := SpecialMaps[pc.level].Map;
            end;
            pc.y := 2;
            M.MonP[pc.x,pc.y] := 1;
            pc.turn := 2;
          end;
      end;
    end else
      // ����� �� �����
      if (x = x+dx)and(y = y+dy) then
      begin
        M.MonP[x,y] := 1;
        turn := 1;
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
      AddMsg('�� ������'+HeSheIt(1)+' �����.');
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
          pc.Fight(M.MonL[M.MonP[x+dx,y+dy]], 0);
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
  reallos : byte;
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
  reallos := los + (Ability[abGOODEYES] * Round(AbilitysData[abGOODEYES].koef));
  for a:=x-reallos-2 to x+reallos+2 do
    for b:=y-reallos-2 to y+reallos+2 do
      if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
         if M.Saw[a,b] > 0 then
           M.Saw[a,b] := 1;
  M.Saw[pc.x,pc.y] := 2;
  tx := x; repeat Inc(tx); PictureIt(tx,y) until (TilesData[M.Tile[tx,y]].void = False)or(InFov(x,y,tx,y,reallos) = False);
  tx := x; repeat Dec(tx); PictureIt(tx,y) until (TilesData[M.Tile[tx,y]].void = False)or(InFov(x,y,tx,y,reallos) = False);
  ty := y; repeat Inc(ty); PictureIt(x,ty) until (TilesData[M.Tile[x,ty]].void = False)or(InFov(x,y,x,ty,reallos) = False);
  ty := y; repeat Dec(ty); PictureIt(x,ty) until (TilesData[M.Tile[x,ty]].void = False)or(InFov(x,y,x,ty,reallos) = False);
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
          if (TilesData[M.Tile[quads[quad][1]*tx+x,quads[quad][2]*ty+y]].void = False)or(InFov(x,y,quads[quad][1]*tx+x,quads[quad][2]*ty+y,reallos)=false)then
            mini := cor;
        end;
        if maxi > cor then
        begin
          PictureIt(x+quads[quad][1]*(tx-1),y+quads[quad][2]*(ty+1));
          if (TilesData[M.Tile[x+quads[quad][1]*(tx-1),y+quads[quad][2]*(ty+1)]].void = False)or(InFov(x,y,x+quads[quad][1]*(tx-1),y+quads[quad][2]*(ty+1),reallos)=false)then
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
      AddMsg('<�� ���'+HeSheIt(1)+' ������� �������'+HeSheIt(1)+'...>');
      More;
      pc.hp := 0;
    end;
    // ����������� (���� �� ������� � ������)
    if (pc.hp < pc.Rhp) and (pc.status[stHUNGRY] <= 1200) then
      if Random(Round(50 / (1 + (pc.ability[abQUICKREGENERATION] * AbilitysData[abQUICKREGENERATION].koef)))) + 1 = 1 then
        inc(pc.hp);
    if pc.Hp <= 0 then Death;
    // �����������
    pc.Search(2);
  end;
  MainForm.OnPaint(NIL);
end;

{ ������� ����� }
procedure TPc.AnalysePlace(px,py : byte; All : boolean);
var
  s : string;
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
              s := '����� ����� '+M.MonL[M.MonP[px,py]].FullName(1, TRUE) else
                s := M.MonL[M.MonP[px,py]].FullName(1, TRUE);
            s := s + '. ��' + M.MonL[M.MonP[px,py]].HeSheIt(1) +' '+ M.MonL[M.MonP[px,py]].WoundDescription+'.';
            AddMsg(s);
          end;
     end;
  // �������
  if M.Item[px,py].id > 0 then
  begin
    if M.Item[px,py].amount = 1 then
      AddMsg('����� ����� '+ItemName(M.Item[px,py], 0, TRUE)+'.') else
        AddMsg('����� ����� '+ItemName(M.Item[px,py], 0, TRUE)+'.');
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
var
  i, wasenter, waslevel : byte;
begin
  if (M.Tile[pc.x,pc.y] = tdDSTAIRS) or (M.Tile[pc.x,pc.y] = tdOHATCH) or (M.Tile[pc.x,pc.y] = tdDUNENTER) then
  begin
    // ������ ��������� �� �����
    M.MonP[pc.x,pc.y] := 0;
    // ��������� �������
    if M.Save = False then AddMsg('�������� �� ������� <:(>');
    // ���� ����� ������� ����� ������ ����� ��������
    if pc.enter = 0 then
    begin
      for i:=1 to MaxLadders do
        if (SpecialMaps[pc.level].Ladders[i].x = pc.x) and (SpecialMaps[pc.level].Ladders[i].y = pc.y) then
        begin
          pc.enter := i;
          break;
        end;
    end;
    // ���� ����
    inc(pc.depth);
    waslevel := pc.level;
    if SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel > 0 then
      pc.level := SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel;
    // ���� ��������� �� ������� - ���� �������, ���� ��������� ����. �������
    if M.Load(pc.level, pc.enter, pc.depth) = False then
    begin
      if SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel = 0 then
      // ����������
      begin
        // ��� ������� ����
        if (pc.depth = 10) or (SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth+1].IsHere = FALSE) then
          M.GenerateCave(SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].DungeonType, FALSE) else
            M.GenerateCave(SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].DungeonType, TRUE);
      end else
        // ����. �������
        begin
          M.Clear;
          M := SpecialMaps[SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel].Map;
        end;
    end;
    PlaceAtTile(tdUSTAIRS);
    pc.turn := 2;
    AddMsg('�� �������'+HeSheIt(2)+' ���� �� �������� �� ������� '+IntToStr(pc.depth)+'.');
  end else
    if M.Tile[pc.x,pc.y] = tdUSTAIRS then
    begin
      // ������ ��������� �� �����
      M.MonP[pc.x,pc.y] := 0;
      // ��������� �������
      if M.Save = False then AddMsg('�������� �� ������� <:(>');
      // ���� ����
      dec(pc.depth);
      wasenter := pc.enter;
      if pc.depth = 0 then pc.enter := 0;
      if SpecialMaps[pc.level].LadderUp > 0 then
        pc.level := SpecialMaps[pc.level].LadderUp;
      // ������� ���������...
      if M.Load(pc.level,pc.enter,pc.depth) = False then
      begin
        AddMsg('�� ������� ��������� �����. �������� ���� � ����������� ��� ������, ���� ��� �� ������� ��������.');
        More;
        AddMsg('<��� ����������� ������. ���� ��������.>');
        More;
        AskForQuit := FALSE;
        MainForm.Close;
      end;
      if M.Special > 0 then
        pc.level := M.Special;
      // ��������� �����
      if pc.depth = 0 then
      begin
        pc.x := SpecialMaps[pc.level].Ladders[wasenter].x;
        pc.y := SpecialMaps[pc.level].Ladders[wasenter].y;
        M.MonP[pc.x, pc.y] := 1;
      end else
        PlaceAtTile(tdDSTAIRS);
      pc.turn := 2;
      if pc.depth > 0 then
        AddMsg('�� ������'+HeSheIt(2)+' �� ��������  �� ������� '+IntToStr(pc.depth)+'.') else
          AddMsg('�� ������'+HeSheIt(2)+' �� �������� � ����� ������'+HeSheIt(2)+' �� ������ �������.');
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
procedure Tpc.SearchForAlive(whattodo : byte);
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
    0 :
    case whattodo of
      1 : AddMsg('����� � ����� ������ ���!');  // ���������
      2 : AddMsg('����� �� � ��� ����������!'); // ��������
      3 : AddMsg('����� � ����� ������ ���!');  // ������
    end;
    1 :
    begin
      for a := pc.x - 1 to pc.x + 1 do
        for b := pc.y - 1 to pc.y + 1 do
          if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
            if M.MonP[a,b] > 1 then
            begin
              case whattodo of
                1 : Fight(M.MonL[M.MonP[a,b]], 0); // ���������
                2 : Talk(M.MonL[M.MonP[a,b]]);     // ��������
                3 : if waseq then GiveItem(M.MonL[M.MonP[a,b]], pc.Eq[MenuSelected]) else
                                        GiveItem(M.MonL[M.MonP[a,b]], pc.Inv[MenuSelected]);   // ������
              end;
              pc.turn := 1;
              Exit;
            end;
    end;
    else
      begin
        case whattodo of
          1 : AddMsg('�� ���� ������ �� ������ �������?');
          2 : AddMsg('� ��� ������ �� ������ ����������?');
          3 : AddMsg('���� ������ ������?');
        end;
        GameState := gsCHOOSEMONSTER;
        wtd := whattodo;
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
      if M.MonP[a,b] = 0 then
      begin
        AddMsg('�� ������'+HeSheIt(1)+' �����.');
        M.Tile[a,b] := tdCDOOR;
        pc.turn := 1;
      end else
        AddMsg('����� ����� '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! �� �� ������ ������� �����!');
    end else
      AddMsg('����� ��� �������� �����!');
  end;
end;

{ ������� }
procedure TPc.Open(dx,dy : shortint);
var
  a,b : integer;
begin
  a := pc.x + dx;
  b := pc.y + dy;
  if (a>0)and(a<=MapX)and(b>0)and(b<=MapY) then
  begin
    if M.Tile[a,b] = tdCDOOR then
    begin
      if M.MonP[a,b] = 0 then
      begin
        AddMsg('�� ������'+HeSheIt(1)+' �����.');
        M.Tile[a,b] := tdODOOR;
        pc.turn := 1;
      end else
        AddMsg('����� ����� '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! �� �� ������ ������� �����! ���� ��� �� ��� ����� ������?');
    end else
      if M.Tile[a,b] = tdCHATCH then
      begin
        if M.MonP[a,b] = 0 then
        begin
          AddMsg('�� � ������ ������'+HeSheIt(1)+' ���.');
          M.Tile[a,b] := tdOHATCH;
          pc.turn := 1;
        end else
          AddMsg('����� ����� '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! �� �� ������ ������� ���!');
      end else
        AddMsg('��� ����� ����� �������?');
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
    Brush.Color := pc.ColorOfTactic;
    // ���
    TextOut((((20-length(name)) div 2)+80) * CharX, 2*CharY, name);
    Font.Color := cBROWN;
    Brush.Color := cBLACK;
    TextOut(81*CharX, 4*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 6*CharY, '�������� :');
    Font.Color := ReturnColor(Rhp, hp, 1);
    TextOut(92*CharX, 6*CharY, IntToStr(hp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, 6*CharY, '('+IntToStr(Rhp)+')');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 7*CharY, '����     :');
    Font.Color := ReturnColor(Rmp, mp, 2);
    TextOut(92*CharX, 7*CharY, IntToStr(mp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, 7*CharY, '('+IntToStr(Rmp)+')');
    Font.Color := cLIGHTGRAY;
    Font.Color := cBROWN;
    TextOut(81*CharX, 9*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 11*CharY, '����     :');
    if st > Rst then
      Font.Color := cLIGHTGREEN else
        if st < Rst then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, 11*CharY, IntToStr(st));
    TextOut(82*CharX, 12*CharY, '�������� :');
    if dex > Rdex then
      Font.Color := cLIGHTGREEN else
        if dex < Rdex then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, 12*CharY, IntToStr(dex));
    TextOut(82*CharX, 13*CharY, '���������:');
    if int > Rint then
      Font.Color := cLIGHTGREEN else
        if int < Rint then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, 13*CharY, IntToStr(int));
    Font.Color := cBROWN;
    TextOut(81*CharX, 15*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, 17*CharY, '�������  :'+IntToStr(explevel));
    TextOut(82*CharX, 18*CharY, '����     :'+IntToStr(exp));
    TextOut(82*CharX, 19*CharY, '�����    :'+IntToStr(ExpToNxtLvl));
    Font.Color := cBROWN;
    TextOut(81*CharX, 21*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    if (M.Special > 0) and (SpecialMaps[M.Special].ShowName) then
      TextOut(82*CharX, 23*CharY, SpecialMaps[M.Special].name) else
        if pc.depth > 0 then
          TextOut(82*CharX, 23*CharY, '�������  : '+IntToStr(pc.depth)) else
            TextOut(82*CharX, 23*CharY, '�������� �����...'); 
    Font.Color := cBROWN;
    TextOut(81*CharX, 25*CharY, '-------------------');
    case pc.status[stHUNGRY] of
      -500..-400:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, 27*CharY, '������...');
      end;
      -399..-1  :
      begin
        Font.Color := cGREEN;
        TextOut(82*CharX, 27*CharY, '������'+HeSheIt(1)+'...');
      end;
      0..450    :
      begin
        Font.Color := cGRAY;
        TextOut(82*CharX, 27*CharY, '���'+HeSheIt(4));
      end;
      451..750  :
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, 27*CharY, '����������'+HeSheIt(2));
      end;
      751..1200  :
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, 27*CharY, '�����'+HeSheIt(5)+'!');
      end;
      1201..1500 :
      begin
        Font.Color := cRED;
        TextOut(82*CharX, 27*CharY, '�������� �� ������!');
      end;
    end;
    case pc.status[stDRUNK] of
      350..500:
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, 28*CharY, '����'+HeSheIt(4));
      end;
      501..800:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, 28*CharY, '����'+HeSheIt(4)+'! ��!');
      end;
    end;
  end;
end;

{ �������� }
procedure Tpc.Talk(Mon : TMonster);
begin
  if Mon.id > 1 then
  begin
    Mon.TalkToMe;
    pc.turn := 1;
  end else
    AddMsg('����� �� � ��� ����������!');
end;

{ ������ ������� }
procedure Tpc.QuestList;
var
  i, k : byte;
begin
  StartDecorating('<-������ ������� �������->', FALSE);
  with Screen.Canvas do
  begin
    k := 0;
    for i:=1 to QuestsAmount do
      if (pc.quest[i] in [1..3]) then
      begin
        k := 1;
        break;
      end;
    if k = 0 then
    begin
      Font.Color := cLIGHTGRAY;
      TextOut(5*CharX,5*CharY,'���� ��� �� �� ����'+HeSheIt(1)+' �� ������ ������.');
    end;
    // ����� 1
    if (pc.quest[1] in [1..3]) then
    begin
     Font.Color := cLIGHTGREEN;
     TextOut(4*CharX,5*CharY,'���������� ������� ������� �������� ����������� ��������� � ���������� ����� �� ���,');
     TextOut(4*CharX,6*CharY,'��������� � ���');
     case pc.quest[1] of
       1 :
       begin
         Font.Color := cRED;
         TextOut(2*CharX,5*CharY,'-');
       end;
       2 :
       begin
         Font.Color := cGREEN;
         TextOut(2*CharX,5*CharY,'+');
       end;
     end;
    end;
    // ����� 2
    if (pc.quest[2] in [1..3]) then
    begin
     Font.Color := cLIGHTGREEN;
     TextOut(4*CharX,5*CharY,'���������� ������� ������� �������� ����� ���� �� ��������� ���� �������');
     case pc.quest[2] of
       1 :
       begin
         Font.Color := cRED;
         TextOut(2*CharX,5*CharY,'-');
       end;
       2 :
       begin
         Font.Color := cGREEN;
         TextOut(2*CharX,5*CharY,'+');
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
  s3 = '< ����� ENTER ��� ����, ��� �� ������������ ������� >';
var
  i : byte;
begin
  StartDecorating('<-����������->', FALSE);
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
          TextOut(31 * CharX, (10+i)*CharY, ItemName(pc.eq[i], 0, TRUE));
        end;
    Font.Color := cGRAY;
    if ItemsAmount > 0 then
      TextOut(((WindowX-length(s1)) div 2) * CharX, 39*CharY, s1) else
        TextOut(((WindowX-length(s2)) div 2) * CharX, 39*CharY, s2);
    if pc.Eq[MenuSelected].id > 0 then
      TextOut(((WindowX-length(s3)) div 2) * CharX, 37*CharY, s3);
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
  StartDecorating('<-���������->', FALSE);
  with Screen.Canvas do
  begin
    Font.Color := cGRAY;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 37*CharY, s1);
    TextOut(((WindowX-length(s2)) div 2) * CharX, 39*CharY, s2);
    for i:=1 to ItemsAmount do
    begin
      Font.Color := cBROWN;
      TextOut(5 * CharX, (2+i)*CharY, '[ ]');
      Font.Color := cLIGHTGRAY;
      TextOut(9 * CharX, (2+i)*CharY, ItemName(pc.inv[i], 0, TRUE));
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
    if Inv[i].id > 0 then inc(k);
  Result := k;
end;

{ ��������� ������ }
procedure Tpc.GainLevel;
var
  a : string;
  i,b : byte;
begin
  AddMsg('{����������! �� ������'+HeSheIt(3)+' ������ ������ ��������!}');
  Apply;
  // �������� �������, �������� ������� �����
  inc(pc.explevel);
  pc.exp  := 0;
  // ���� ����� �����������
  b := 0;
  for i:=1 to AbilitysAmount do
    if pc.ability[i] < 4 then
      b := 1;
  // ���� ��� �������� �����������, ������� ����� ���������
  if b > 0 then
  begin
    repeat
      i := Random(AbilitysAmount)+1;
    until
      pc.ability[i] < 4;
    inc(pc.ability[i]);
    if pc.ability[i] = 1 then
      AddMsg('�� ������'+HeSheIt(1)+' � ���� ����� ����������� - "{'+AbilitysData[i].name+'}"!') else
        AddMsg('���� ����������� "{'+AbilitysData[i].name+'}" ����� �� ������� �����!');
    Apply;
  end;
  // ������ ������ ������� ����� ������� �������� ���
  if pc.explevel mod 3 = 0 then
  begin
    AddMsg('{�� ������ �������� ���� �� ����� ���������!}');
    a := Ask('������ �����: ([S]) ����, ([D]) �������� ��� ([I]) ���������?');
    case a[1] of
      'S' :
      begin
        inc(pc.Rst);
        pc.st := pc.Rst;
        AddMsg('[�� ���� ����� �������.]');
        Apply;
      end;
      'D' :
      begin
        inc(pc.Rdex);
        pc.dex := pc.Rdex;
        AddMsg('[�� ���� ����� ������.]');
        Apply;
      end;
      'I' :
      begin
        inc(pc.Rint);
        pc.int := pc.Rint;
        AddMsg('[�� ���������� ���� �����.]');
        Apply;
      end;
      ELSE
        // ��������� �����
        case Random(3)+1 of
          1 :
          begin
            inc(pc.Rst);
            pc.st := pc.Rst;
            AddMsg('[�� ���� ����� �������.]');
            Apply;
          end;
          2 :
          begin
            inc(pc.Rdex);
            pc.dex := pc.Rdex;
            AddMsg('[�� ���� ����� ������.]');
            Apply;
          end;
          3 :
          begin
            inc(pc.Rint);
            pc.int := pc.Rint;
            AddMsg('[�� ���������� ���� �����.]');
            Apply;
          end;
        end;
    end;
  end;
  AddMsg('');
  pc.Rhp := pc.Rhp + round(pc.Rhp/4);
end;

{ ������� ����� ����� ��� ���������� ������ }
function Tpc.ExpToNxtLvl : integer;
begin
  Result := Round((explevel * 20) - (int/1.5));
end;

{ ���� �������� � ��������� }
procedure Tpc.UseMenu;
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

{ �������� ����� ������ ����� }
procedure TPc.AfterDeath;
begin
  AddMsg('<�� ����'+HeSheIt(3)+'!!!>');
  Apply;
  AskForQuit := FALSE;
  MainForm.Close;
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

{ ���� ����� ����� }
procedure TPc.HeroName;
const
  s1 = '����� ��� �����';
  s2 = '^^^^^^^^^^^^^';
  s3 = '������ ��� �����';
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s2)) div 2) * CharX, 18*CharY, s2);
    MainForm.Edit.Left := (((WindowX*CharX)-MainForm.Edit.Width-8) div 2);
    MainForm.Edit.Top := 17*CharY;
    MainForm.Edit.Visible := TRUE;
    MainForm.Edit.SetFocus;
  end;
end;

{ ���� ������ ���� }
procedure TPc.HeroGender;
const
  s1 = '������ ��� �����';
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, '�������');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, '�������');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '*');
  end;
end;

{ ������ }
procedure Tpc.Search(modif : byte);
var
  a, b : integer;
begin
  for a:=pc.x-1 to pc.x+1 do
    for b:=pc.y-1 to pc.y+1 do
      if (a > 0) and (a <= MapX) and (b > 0) and (b <= MapY) then
        if M.tile[a,b] = tdSECRET then
         if Random(8 * Modif)+1 = 1 then
          begin
            M.tile[a,b] := tdCDOOR;
            AddMsg('{�� ���'+HeSheIt(6)+' ��������� �����!}');
            More;
          end;
end;

end.

