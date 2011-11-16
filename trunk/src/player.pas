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
    warning     : boolean;                       // ������ � ���� ������

    procedure ClearPlayer;                       // ��������
    procedure Prepare;                           // ���������� � ����� ������ ����
    procedure Move(dx,dy : shortint);            // ������� �����
    procedure Run(dx,dy : shortint);             // Shift + ������� �����
    procedure FOV;                               // ���� ���������
    procedure AfterTurn;                         // �������� ����� ���� �����
    procedure AnalysePlace(px,py: byte;          // ������� �����
                        All : byte);
    procedure PlaceHere(px,py : byte);           // ��������� ����� � ��� �����
    procedure UseStairs;                         // ���������� ��� ��������� �� ��������
    procedure PlaceAtTile(t : byte);             // ����������� ����� �� ����
    procedure SearchForDoors;                    // ������� ������ �����
    procedure SearchForAlive
                        (whattodo : byte);       // ������� �������� ����� (1-���������, 2-��������, 3-������)
    function SearchForAliveField : byte;         // ����� ������ ���������� �������
    procedure CloseDoor(dx,dy : shortint);       // ������� �����
    procedure Open(dx,dy : shortint);            // �������
    procedure MoveLook(dx,dy : shortint);        // ������� ������ �������
    procedure MoveAim(dx,dy : shortint);         // ������� ������ �������
    procedure WriteInfo;                         // ������� ���������� �� ����� ������
    procedure Talk(Mon : TMonster);              // ��������
    procedure QuestList;                         // ������ �������
    procedure Equipment;                         // ����������
    procedure Inventory;                         // ���������
    function ItemsAmount : byte;                 // ����������� �����
    procedure GainLevel;                         // ��������� ������
    function ExpToNxtLvl : integer;              // ������� ����� ����� ��� ���������� ������
    procedure UseMenu;                           // ���� �������� � ���������
    procedure AfterDeath;                        // �������� ����� ������ �����
    function FindCoins : byte;                   // ����� ������ � ��������
    procedure Search;                            // ������
    function HaveItemVid(vid : byte) : boolean;  // ���� �� ���� ���� ������� ����� ����?
    procedure HeroRandom;                        // ������� ����������
    procedure StartHeroName;                     // ���� ����� �����
    procedure HeroName;                          // ���� ����� �����
    procedure HeroGender;                        // ���� ������ ����
    procedure HeroAtributes;                     // ����������� �����������
    procedure CreateClWList;
    procedure HeroCloseWeapon;                   // ������ �������� ���
    procedure CreateFrWList;
    procedure HeroFarWeapon;                     // ������ �������� ���
    procedure HeroCreateResult;                  // �����������
    procedure ChooseMode;                    // ������� ����� ����
  end;

var
  pc      : Tpc;
  lx, ly  : byte;                                // ���������� ������� �������
  autoaim : byte;                                // ID ������� �� �����������
  cell    : byte;
  crstep  : byte;
  InvList : array[1..MaxHandle] of byte;
  c_choose, f_choose : byte;                     // ��������� ��� ������
  wlist   : array[1..5] of byte;
  wlistsize : byte;


implementation

uses
  Map, MapEditor, conf, sutils, vars, script;

{ �������� }
procedure Tpc.ClearPlayer;
begin
  ClearMonster;
  id := 1;
  idinlist := 1;
  turn := 0;
  level := 0;
  enter := 0;
  depth := 0;
  fillchar(quest,sizeof(quest),0);
  color := 0;
  gender := 0;
  exp := 0;
  explevel := 1;
  fillchar(status,sizeof(status),0);
  warning := FALSE
end;

{ ���������� � ����� ������ ���� }
procedure Tpc.Prepare;
begin
  // �������� �������� ������ �� �����������
  Rstr := 5; Rdex := 5; Rint := 5;
  // ���������
  if pc.atr[1] = 1 then
    inc(Rstr, 6);
  if pc.atr[1] = 2 then
    inc(Rdex, 6);
  if pc.atr[1] = 3 then
    inc(Rint, 6);
  // ���������
  if pc.atr[2] = 1 then
    inc(Rstr, 3);
  if pc.atr[2] = 2 then
    inc(Rdex, 3);
  if pc.atr[2] = 3 then
    inc(Rint, 3);
  str := Rstr; dex := Rdex; int := Rint;
  // ��������
  Rhp := 20 + Round(str / 2);
  hp := Rhp;
  // ��������
  speed := 96 + Round(dex / 2);
  // ��������� ������
  los := 5 + Round(int / 5);
  // ����� ������ ������
  attack := Round(str / 2);
  defense := Round(str / 4) + Round(dex / 4);
  // �������� �������
  status[1] := 0;
  status[2] := 0;
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
          if Ask(GetMsg('������ ������� ��� ����{/����}?!',0) + ' #(Y/n)#') = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('�� �����{/a} ��������.',0);
        end else
          begin
            // ������ ��������� �� �����
            M.MonP[pc.x,pc.y] := 0;
            // ��������� �������
            if M.Save = False then AddMsg('�������� �� ������� *:(*',0);
            // ������  ����� �������
            pc.level := SpecialMaps[pc.level].Loc[3];
            // ���� ��������� �� ������� - ������ ��������� ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then M.MakeSpMap(pc.level);
            pc.x := MapX - 1;
            M.MonP[pc.x,pc.y] := 1;
            pc.turn := 2;
          end
      end else
      // �� ������
      if x + dx = MapX then
      begin
        if (SpecialMaps[pc.level].Loc[4] = 0) and (pc.level = 1) then
        begin
          if Ask(GetMsg('����������! �� ��������{/a} ������ ������ ������ ����! ������ ������ ����? #(Y/n)#',0)) = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('�� �����{/a} ��������.',0);
        end else
          begin
            // ������ ��������� �� �����
            M.MonP[pc.x,pc.y] := 0;
            // ��������� �������
            if M.Save = False then AddMsg('�������� �� ������� *:(*',0);
            // ������  ����� �������
            pc.level := SpecialMaps[pc.level].Loc[4];
            // ���� ��������� �� ������� - ������ ��������� ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then M.MakeSpMap(pc.level);
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
          if Ask(GetMsg('������ ������� ��� ����{/����}?! #(Y/n)#',0)) = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('�� �����{/a} ��������.',0);
        end else
          begin
            // ������ ��������� �� �����
            M.MonP[pc.x,pc.y] := 0;
            // ��������� �������
            if M.Save = False then AddMsg('�������� �� ������� *:(*',0);
            // ������  ����� �������
            pc.level := SpecialMaps[pc.level].Loc[1];
            // ���� ��������� �� ������� - ������ ��������� ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then M.MakeSpMap(pc.level);
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
          if Ask(GetMsg('������ ������� ��� ����{/����}?! #(Y/n)#',0)) = 'Y' then
          begin
            AskForQuit := FALSE;
            MainForm.Close;
          end else
            AddMsg('�� �����{/a} ��������.',0);
        end else
          begin
            // ������ ��������� �� �����
            M.MonP[pc.x,pc.y] := 0;
            // ��������� �������
            if M.Save = False then AddMsg('�������� �� ������� *:(*',0);
            // ������  ����� �������
            pc.level := SpecialMaps[pc.level].Loc[2];
            // ���� ��������� �� ������� - ������ ��������� ;)
            if M.Load(pc.level, pc.enter, pc.depth) = False then M.MakeSpMap(pc.level);
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
      AddMsg('�� ������{/a} �����.',0);
      pc.turn := 1;
    end;
    3 : // ���-�� �����
    begin
      if (M.MonL[M.MonP[x+dx,y+dy]].relation = 0) and (not M.MonL[M.MonP[x+dx,y+dy]].felldown) then
      begin
        // ������ ���������� �������
        AddMsg(Format('�� � %s ���������� �������.', [MonstersData[M.MonL[M.MonP[x+dx,y+dy]].id].name1]),0);
        M.MonP[x,y] := M.MonP[x+dx,y+dy];
        M.MonL[M.MonP[x,y]].x := x;
        M.MonL[M.MonP[x,y]].y := y;
        x := x + dx;
        y := y + dy;
        M.MonP[x,y] := 1;
        pc.turn := 2;
      end else
        // ����������� � �����
        if (M.MonL[M.MonP[x+dx,y+dy]].relation = 0) and (M.MonL[M.MonP[x+dx,y+dy]].felldown) then
        begin
          // �� ���� ���������� �������
          AddMsg(Format('�� � %s �� ������ ���������� �������!', [MonstersData[M.MonL[M.MonP[x+dx,y+dy]].id].name1]),0);
          pc.turn := 1;
        end else
          begin
            // ���������
            pc.Fight(M.MonL[M.MonP[x+dx,y+dy]], 0);
            pc.turn := 1;
          end;
    end;
  end;
end;

{ Shift + ������� ����� }
procedure Tpc.Run(dx,dy : shortint);
var
  a,b,count : byte;
  around    : array[1..3,1..3] of byte;
  stop      : boolean;
begin
  Move(dx,dy);
(*  // ���������
  for a:=1 to 3 do
    for b:=1 to 3 do
      around[a,b] := M.Tile[pc.x-2+a,pc.y-2+b];
  stop := FALSE;
  count := 0;
  repeat
    // ������� ���
    Move(dx,dy);
    pc.AfterTurn;
    sleep(40);
    // 1) ������ �������,
    if pc.warning then stop := TRUE;
    // 2) ������ ��������� ������,
    for a:=1 to 3 do
      for b:=1 to 3 do
        if M.Tile[pc.x-2+a,pc.y-2+b] <> around[a,b] then
          stop := TRUE;
    // 3) ������� ������������ ���-�� �����
    inc(count);
    if count = 20 then stop := TRUE;
    // 4) �������� �� �������
    if M.Item[pc.x,pc.y].id > 0 then stop := TRUE;
  until
    stop;*)
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
        if M.MonL[M.MonP[x,y]].relation = 1 then
          pc.warning := TRUE;
      M.MemBC[x,y] := TilesData[M.Tile[x,y]].Color;
      if M.MonP[x,y] > 0 then
      begin
        M.MemS[x,y] := MonstersData[M.MonL[M.MonP[x,y]].id].char;
        M.MemC[x,y] := M.MonL[M.MonP[x,y]].ClassColor;
      end else
        if M.Item[x,y].id > 0 then
        begin
          M.MemS[x,y] := ItemTypeData[ItemsData[M.Item[x,y].id].vid].symbol;;
          M.MemC[x,y] := ItemsData[M.Item[x,y].id].color;
        end else
          begin
            M.MemS[x,y] := TilesData[M.Tile[x,y]].Char;
            M.MemC[x,y] := TilesData[M.Tile[x,y]].Color;
          end;
    end;
  end;
begin
  pc.warning := FALSE;
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
    // ���� ��� �� ����
    if id > 0 then
    begin
      // ���� ������������ �� ������ ������ - ������� ��������, ���� ����
      if pc.turn = 2 then AnalysePlace(pc.x,pc.y,0);
      // ��������
      pc.turn := 0;
      // ����� ������
      inc(status[stHUNGRY]);
      // ������
      if status[stDRUNK] > 0 then
        dec(status[stDRUNK]);
      if status[stHUNGRY] = 1500 then
      begin
        AddMsg('*�� ���{/a} ������� �������{/a}...*',0);
        More;
        pc.hp := 0;
      end;
      // ����������� (���� �� ������� � ������)
      if (pc.hp < pc.Rhp) and (pc.status[stHUNGRY] <= 1200) then
        if Random(Round(40 / (1 + (pc.ability[abQUICKREGENERATION] * AbilitysData[abQUICKREGENERATION].koef)))) + 1 = 1 then
          inc(pc.hp);
      if pc.Hp <= 0 then Death;
      // �����������
      pc.Search;
    end;
  end;
  MainForm.OnPaint(NIL);
end;

{ ������� ����� }
procedure TPc.AnalysePlace(px,py : byte; All : byte);
var
  s : string;
begin
  // ����
  if (All=2)or(TilesData[M.Tile[px,py]].important) or ((M.Blood[px,py] > 0) and (All <> 1)) then
    if M.Blood[px,py] > 0 then
      AddMsg(TilesData[M.Tile[px,py]].name+' � �����.',0) else
        AddMsg(TilesData[M.Tile[px,py]].name+'.',0);
  // ������
  if All > 0 then
    if M.MonP[px,py] > 0 then
    begin
      if M.MonP[px,py] = 1 then
        AddMsg(Format('��� �� - %s. �� %s.', [pc.name, pc.WoundDescription]),0) else
          begin
            if M.MonL[M.MonP[px,py]].felldown then
              s := Format('����� ����� %s.', [M.MonL[M.MonP[px,py]].FullName(1, TRUE)]) else
                s := M.MonL[M.MonP[px,py]].FullName(1, TRUE);
            // ���������
            s := s + Format(' %s.', [M.MonL[M.MonP[px,py]].WoundDescription]);
            // �������
            if M.MonL[M.MonP[px,py]].tactic = 1 then
              s := s + ' ��������{/a} ������ ����������.';
            if M.MonL[M.MonP[px,py]].tactic = 2 then
              s := s + ' ����������.';
            // ������ � ����� � ������ ����
            if IsFlag(MonstersData[M.MonL[M.MonP[px,py]].id].flags, M_HAVEITEMS) then
            begin
              // ������
              if M.MonL[M.MonP[px,py]].eq[6].id = 0 then
                s := s + ' �������{��/��}.' else
                  s := s + Format(' � ����� ������ %s.', [ItemsData[M.MonL[M.MonP[px,py]].eq[6].id].name3]);
              // ���
              if M.MonL[M.MonP[px,py]].eq[8].id > 0 then
                s := s + Format(' � ����� ������ %s.', [ItemsData[M.MonL[M.MonP[px,py]].eq[6].id].name3]);
              // �����
              if M.MonL[M.MonP[px,py]].eq[4].id > 0 then
                  s := s + Format(' �� ��� �� ������ %s.', [ItemsData[M.MonL[M.MonP[px,py]].eq[4].id].name3]);
            end;
{    Font.Color := cBROWN;
    TextOut(5*CharX, 11*CharY, '[ ] - ������            :');
    TextOut(5*CharX, 12*CharY, '[ ] - ���               :');
    TextOut(5*CharX, 13*CharY, '[ ] - ����              :');
    TextOut(5*CharX, 14*CharY, '[ ] - ����              :');
    TextOut(5*CharX, 15*CharY, '[ ] - ����              :');
    TextOut(5*CharX, 16*CharY, '[ ] - ������            :');
    TextOut(5*CharX, 17*CharY, '[ ] - ������� ���       :');
    TextOut(5*CharX, 18*CharY, '[ ] - ���               :');
    TextOut(5*CharX, 19*CharY, '[ ] - ��������          :');
    TextOut(5*CharX, 20*CharY, '[ ] - ������            :');
    TextOut(5*CharX, 21*CharY, '[ ] - ��������          :');
    TextOut(5*CharX, 22*CharY, '[ ] - �����             :');
    TextOut(5*CharX, 23*CharY, '[ ] - ��������          :');}
            AddMsg(s,  M.MonL[M.MonP[px,py]].id);
          end;
     end;
  // �������
  if All <> 1 then
    if M.Item[px,py].id > 0 then
    begin
      if M.Item[px,py].amount = 1 then
        AddMsg(Format('����� ����� %s.', [ItemName(M.Item[px,py], 0, TRUE)]),0) else
          AddMsg(Format('����� ����� %s.', [ItemName(M.Item[px,py], 0, TRUE)]),0);
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
  dunname : string[17];
begin
  if (M.Tile[pc.x,pc.y] = tdDSTAIRS) or (M.Tile[pc.x,pc.y] = tdOHATCH) or (M.Tile[pc.x,pc.y] = tdDUNENTER) then
  begin
    // ������ ��������� �� �����
    M.MonP[pc.x,pc.y] := 0;
    // ��������� �������
    if M.Save = False then AddMsg('�������� �� ������� *:(*',0);
    // ���� ����� ������� ����� ������ ����� ��������
    if pc.enter = 0 then
    begin
      for i:=1 to MaxLadders do
        if (SpecialMaps[pc.level].Ladders[i].x = pc.x) and (SpecialMaps[pc.level].Ladders[i].y = pc.y) then
        begin
          pc.enter := i;
          if SpecialMaps[pc.level].Ladders[i].name = '' then
            dunname := GetDungeonModeMapName() else
              dunname := SpecialMaps[pc.level].Ladders[i].name;
          break;
        end;
    end else
      begin
        if M.name <> '' then
          dunname := M.name;
      end;
    // ���� ����
    inc(pc.depth);
    waslevel := pc.level;
    if SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel > 0 then
      pc.level := SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel;
    // ���� ��������� �� ������� - ���� �������, ���� ��������� ����. �������
    if M.Load(pc.level, pc.enter, pc.depth) = False then
    begin
      // ����������
      if SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel = 0 then
      begin
        // ��� ������� ����
        if (pc.depth = 10) or (SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth+1].IsHere = FALSE) then
          M.GenerateCave(SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].DungeonType, FALSE) else
            M.GenerateCave(SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].DungeonType, TRUE);
        M.name := DunName;
      end else
        // ����. �������
          M.MakeSpMap(pc.level);
      if DunName <> '' then M.name := DunName;
    end;
    PlaceAtTile(tdUSTAIRS);
    pc.turn := 2;
    AddMsg(Format('�� �������{��/���} ���� �� �������� �� ������� %d.', [pc.depth]),0);
  end else
    if M.Tile[pc.x,pc.y] = tdUSTAIRS then
    begin
      dunname := M.name;
      // ������ ��������� �� �����
      M.MonP[pc.x,pc.y] := 0;
      // ��������� �������
      if M.Save = False then AddMsg('�������� �� ������� <:(>',0);
      // ���� ����
      dec(pc.depth);
      wasenter := pc.enter;
      if pc.depth = 0 then pc.enter := 0;
      if SpecialMaps[pc.level].LadderUp > 0 then
        pc.level := SpecialMaps[pc.level].LadderUp;
      // ������� ���������...
      if M.Load(pc.level,pc.enter,pc.depth) = False then
      begin
        AddMsg('�� ������� ��������� �����. �������� ���� � ����������� ��� ������, ���� ��� �� ������� ��������.',0);
        More;
        AddMsg('*��� ����������� ������. ���� ��������.*',0);
        More;
        AskForQuit := FALSE;
        MainForm.Close;
      end;
      if SpecialMaps[M.Special].name = '' then M.name := DunName else M.name := SpecialMaps[M.Special].name;
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
        AddMsg(Format('�� ������{��/���} �� �������� �� ������� %d.', [pc.depth]),0) else
          AddMsg('�� ������{��/���} �� �������� � ����� ������{��/���} �� ������ �������.',0);
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
    0 : AddMsg('����� ��� �������� �����!',0);
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
        AddMsg('����� ������ ����� �� ������ �������?',0);
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
      1 : AddMsg('����� � ����� ������ ���!',0);  // ���������
      2 : AddMsg('����� �� � ��� ����������!',0); // ��������
      3 : AddMsg('����� � ����� ������ ���!',0);  // ������
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
          1 : AddMsg('�� ���� ������ �� ������ �������?',0);
          2 : AddMsg('� ��� ������ �� ������ ����������?',0);
          3 : AddMsg('���� ������ ������?',0);
        end;
        GameState := gsCHOOSEMONSTER;
        wtd := whattodo;
      end;
  end;
end;

{ ����� ������ ���������� ������� }
function Tpc.SearchForAliveField : byte;
var
  MList    : array[1..255] of byte;
  a, b, k  : integer;
begin
  FillMemory(@MList, SizeOf(MList), 0);
  k := 1;
  // �������� ������ ���������� ��������
  for a:=x-20 to x+20 do
    for b:=y-20 to y+20 do
      if (a>0) and (a<=MapX) and (b>0) and (b<=MapY) then
        if M.Saw[a,b] = 2 then
          if M.MonP[a,b] > 1 then
          begin
            MList[k] := M.MonP[a,b];
            inc(k);
          end;
  if MList[1] > 0 then
  begin
    // ������ ������ ��������
    b := 1;
    for a:=1 to 255 do
      if MList[a] > 0 then
      begin
        if (ABS(x - M.MonL[MList[a]].x) <= ABS(x - M.MonL[MList[b]].x)) and (ABS(y - M.MonL[MList[a]].y) <= ABS(y - M.MonL[MList[b]].y)) then
           b := a;
      end else
        break;
    Result := MList[b];
  end else
    Result := 0;
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
        AddMsg('�� ������{/a} �����.',0);
        M.Tile[a,b] := tdCDOOR;
        pc.turn := 1;
      end else
        AddMsg('����� ����� '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! �� �� ������ ������� �����!',0);
    end else
      AddMsg('����� ��� �������� �����!',0);
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
        AddMsg('�� ������{/a} �����.',0);
        M.Tile[a,b] := tdODOOR;
        pc.turn := 1;
      end else
        AddMsg('����� ����� '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! �� �� ������ ������� �����! ���� ��� �� ��� ����� ������?',0);
    end else
      if M.Tile[a,b] = tdCHATCH then
      begin
        if M.MonP[a,b] = 0 then
        begin
          AddMsg('�� � ������ ������{/a} ���.',0);
          M.Tile[a,b] := tdOHATCH;
          pc.turn := 1;
        end else
          AddMsg('����� ����� '+MonstersData[M.MonL[M.MonP[a,b]].id].name1+'! �� �� ������ ������� ���!',0);
      end else
        AddMsg('��� ����� ����� �������?',0);
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
        AnalysePlace(lx,ly,2);
      end;
end;

{ ������� ������ ������� }
procedure TPc.MoveAim(dx,dy : shortint);
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
        if M.MonP[lx,ly] > 0 then AddMsg('#�������� �:#',0);
        AnalysePlace(lx,ly,1);
      end;
end;

{ ������� ���������� �� ����� ������ }
procedure Tpc.WriteInfo;
var
  HLine: Byte;
  MB, WW: Integer;
begin
  with Screen.Canvas do
  begin
    // ������ ����
    WW := (98*CharX) - (82*CharX);
    // ���
    HLine := 1;
    Font.Color := cLIGHTGRAY;
    Brush.Color := pc.ColorOfTactic;
    Inc(HLine);
    TextOut((((20-length(name)) div 2)+80) * CharX, HLine*CharY, name);
    Font.Color := cGRAY;
    Inc(HLine);
    TextOut((((20-(length(CLName(1))+2)) div 2)+80) * CharX, HLine*CharY, '(');
    Font.Color := pc.ClassColor;
    TextOut((((20-(length(CLName(1))+2)) div 2)+80+1) * CharX, HLine*CharY, CLName(1));
    Font.Color := cGRAY;
    TextOut((((20-(length(CLName(1))+2)) div 2)+80+1+length(CLName(1))) * CharX, HLine*CharY, ')');
    Font.Color := cBROWN;
    Brush.Color := cBLACK;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Inc(HLine);
    Inc(HLine);
    if Hp < 0 then Hp := 0;
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, HLine*CharY, '�������� :');
    Font.Color := ReturnColor(Rhp, hp, 1);
    TextOut(92*CharX, HLine*CharY, IntToStr(hp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, HLine*CharY, '('+IntToStr(Rhp)+')');
    // ������ ��������
    if (ShowBars = 1) then begin
      Inc(HLine);
      Pen.Color := cGRAY;
      Pen.Width := 9;
      MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
      LineTo((98*CharX) + 4, Round((HLine + 0.5)*CharY));
      if (Hp > 0) then
      begin
        Pen.Color := cLIGHTRED;
        MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
        LineTo((82*CharX) + BarWidth(HP, RHP, WW) + 4, Round((HLine + 0.5)*CharY));
      end;
    end;
    //
    Inc(HLine);
    if Mp < 0 then Mp := 0;
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, HLine*CharY, '����     :');
    Font.Color := ReturnColor(Rmp, mp, 2);
    TextOut(92*CharX, HLine*CharY, IntToStr(mp));
    Font.Color := cLIGHTGRAY;
    TextOut(95*CharX, HLine*CharY, '('+IntToStr(Rmp)+')');
    // ������ ����
    if (ShowBars = 1) then begin
      Inc(HLine);
      Pen.Color := cGRAY;
      Pen.Width := 9;
      MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
      LineTo((98*CharX) + 4, Round((HLine + 0.5)*CharY));
      if (Mp > 0) then
      begin
        Pen.Color := cLIGHTBLUE;
        MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
        LineTo((82*CharX) + BarWidth(MP, RMP, WW) + 4, Round((HLine + 0.5)*CharY));
      end;
    end;
    //
    Font.Color := cBROWN;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Inc(HLine);
    Inc(HLine);
    Font.Color := cLIGHTGRAY;
    TextOut(82*CharX, HLine*CharY, '����     :');
    if str > Rstr then
      Font.Color := cLIGHTGREEN else
        if str < Rstr then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, HLine*CharY, IntToStr(str));
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, '�������� :');
    if dex > Rdex then
      Font.Color := cLIGHTGREEN else
        if dex < Rdex then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, HLine*CharY, IntToStr(dex));
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, '���������:');
    if int > Rint then
      Font.Color := cLIGHTGREEN else
        if int < Rint then
          Font.Color := cLIGHTRED else
            Font.Color := cLIGHTGRAY;
    TextOut(92*CharX, HLine*CharY, IntToStr(int));
    Font.Color := cBROWN;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Font.Color := cLIGHTGRAY;
    Inc(HLine);
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, '�������  :'+IntToStr(explevel));
    // ������ �����
    if (ShowBars = 1) then begin
      Inc(HLine);
      Pen.Color := cGRAY;
      Pen.Width := 9;
      MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
      LineTo((98*CharX) + 4, Round((HLine + 0.5)*CharY));
      if pc.exp < 0 then pc.exp := 0;
      if (pc.exp > 0) then
      begin
        Pen.Color := cBLUEGREEN;
        MoveTo((82*CharX) + 4, Round((HLine + 0.5)*CharY));
        LineTo((82*CharX) + BarWidth(pc.exp, pc.ExpToNxtLvl, WW) + 4, Round((HLine + 0.5)*CharY));
      end;
    end;
    //
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, '����     :'+IntToStr(pc.exp));
    Inc(HLine);
    TextOut(82*CharX, HLine*CharY, '�����    :'+IntToStr(pc.ExpToNxtLvl));
    Font.Color := cBROWN;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Inc(HLine);
    Inc(HLine);
    // �������� ������� �����
    Font.Color := cLIGHTGRAY;
    if (M.Special > 0) and (SpecialMaps[M.Special].ShowName) then
      TextOut(82*CharX, HLine*CharY, SpecialMaps[M.Special].name) else
    begin
      if ((M.Special > 0) and (SpecialMaps[M.Special].ShowName = False) and
        (pc.depth > 0)) or ((M.Special = 0) and (pc.depth > 0)) then
      begin
        // ���������� �������� ���������� � ��� �������
        TextOut(82*CharX, HLine*CharY, M.name);
        Inc(HLine);
        TextOut(82*CharX, HLine*CharY, '�������  : '+IntToStr(pc.depth))
      end else
          TextOut(82*CharX, HLine*CharY, '�������� �����...');
    end;
    Font.Color := cBROWN;
    Inc(HLine);
    Inc(HLine);
    TextOut(81*CharX, HLine*CharY, '-------------------');
    Inc(HLine);
    Inc(HLine);
    if (hp > 0) then
    case pc.status[stHUNGRY] of
      -500..-400:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, HLine*CharY, '������...');
      end;
      -399..-1  :
      begin
        Font.Color := cGREEN;
        TextOut(82*CharX, HLine*CharY, GetMsg('������{/a}...',gender));
      end;
      0..450    :
      begin
        Font.Color := cGRAY;
        TextOut(82*CharX, HLine*CharY, GetMsg('���{��/��}',gender));
      end;
      451..750  :
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, HLine*CharY, GetMsg('����������{��/���}',gender));
      end;
      751..1200  :
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, HLine*CharY, GetMsg('�����{��/��}',gender));
      end;
      1201..1500 :
      begin
        Font.Color := cRED;
        TextOut(82*CharX, HLine*CharY, GetMsg('�������� �� ������!',gender));
      end;
    end else
    begin
      Font.Color := cGRAY;
      TextOut(82*CharX, HLine*CharY, GetMsg('�����{��/��}',gender));
    end;
    if (hp > 0) then begin
      Inc(HLine);
      case pc.status[stDRUNK] of
      350..500:
      begin
        Font.Color := cYELLOW;
        TextOut(82*CharX, HLine*CharY, GetMsg('����{��/��}',gender));
      end;
      501..800:
      begin
        Font.Color := cLIGHTRED;
        TextOut(82*CharX, HLine*CharY, GetMsg('����{��/��}! ��!',gender));
      end;
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
    AddMsg('����� �� � ��� ����������!',0);
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
      TextOut(5*CharX,5*CharY,GetMsg('���� ��� �� �� ����{/a} �� ������ ������.',gender));
    end else
      // ������� ������
      for i:=1 to QuestsAmount do
      begin
        if (pc.quest[i] in [1..3]) then
        begin
          Font.Color := cLIGHTGREEN;
          case i of
            1 : TextOut(4*CharX,(4+i)*CharY,'����������� ��������� � ���������� ����� �� ���, ��������� � ��� (����������)');
            2 : TextOut(4*CharX,(4+i)*CharY,'����� ���� �� ��������� ���� ������� (����������)');
          end;
          case pc.quest[i] of
            1 :
            begin
              Font.Color := cRED;
              TextOut(2*CharX,(4+i)*CharY,'-');
            end;
            2 :
            begin
              Font.Color := cGREEN;
              TextOut(2*CharX,(4+i)*CharY,'+');
            end;
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
    TextOut(5*CharX, 17*CharY, '[ ] - ������� ���       :');
    TextOut(5*CharX, 18*CharY, '[ ] - ���               :');
    TextOut(5*CharX, 19*CharY, '[ ] - ��������          :');
    TextOut(5*CharX, 20*CharY, '[ ] - ������            :');
    TextOut(5*CharX, 21*CharY, '[ ] - ��������          :');
    TextOut(5*CharX, 22*CharY, '[ ] - �����             :');
    TextOut(5*CharX, 23*CharY, '[ ] - ��������          :');
    for i:=1 to EqAmount do
      if pc.eq[i].id = 0 then
      begin
        if HaveItemVid(Eq2Vid(i)) then
        begin
          Font.Color := cYELLOW;
          TextOut(31*CharX,(10+i)*CharY,'+');
        end else
            begin
              Font.Color := cGRAY;
              TextOut(31*CharX,(10+i)*CharY,'-');
            end;
        // ���������� ����� � ���������� �������
        if i = 6 then
        begin
          Font.Color := cLIGHTGRAY;
          TextOut(33*CharX, (10+i)*CharY, Format('{����� � ���������� �������: %d}', [pc.attack])); 
        end;
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
  i,k : byte;
begin
  // ���������
  if VidFilter = 0 then
    StartDecorating('<-���������->', FALSE) else
      StartDecorating('<-'+WhatToDo(VidFilter)+'->', FALSE);
  // �������� ���������
  for i:=1 to MaxHandle do InvList[i] := 0;
  // ������� ��������� �� �������
  k := 1;
  for i:=1 to ItemsAmount do
    if (VidFilter = 0) or (ItemsData[pc.inv[i].id].vid = VidFilter) then
    begin
      InvList[k] := i;
      inc(k);
    end;
  // ������� ������ ���������
  with Screen.Canvas do
  begin
    Font.Color := cGRAY;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 37*CharY, s1);
    TextOut(((WindowX-length(s2)) div 2) * CharX, 39*CharY, s2);
    for i:=1 to ItemsAmount do
      if InvList[i] > 0 then
      begin
        Font.Color := cBROWN;
        TextOut(5 * CharX, (2+i)*CharY, '[ ]');
        Font.Color := cLIGHTGRAY;
        TextOut(9 * CharX, (2+i)*CharY, ItemName(pc.inv[InvList[i]], 0, TRUE));
        Font.Color := cRED;
        TextOut(6*CharX, (2+MenuSelected)*CharY,'*');
      end else
        break;
    WriteSomeAboutItem(pc.Inv[InvList[MenuSelected]]);
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
  AddMsg('$����������! �� ������{/��} ������ ������ ��������!$',0);
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
      AddMsg('�� ������{/a} � ���� ����� ����������� - "$'+AbilitysData[i].name+'$"!',0) else
        AddMsg('���� ����������� "#'+AbilitysData[i].name+'#" ����� �� ������� �����!',0);
    Apply;
  end;
  // ������ ������ ������� ����� ������� �������� ���
  if pc.explevel mod 3 = 0 then
  begin
    AddMsg('#�� ������ �������� ���� �� ����� ���������!#',0);
    a := Ask('������ �����: (#S#) ����, (#D#) �������� ��� (#I#) ���������?');
    case a[1] of
      'S' :
      begin
        inc(pc.Rstr);
        pc.str := pc.Rstr;
        AddMsg('$�� ����{/a} �������.$',0);
        Apply;
      end;
      'D' :
      begin
        inc(pc.Rdex);
        pc.dex := pc.Rdex;
        AddMsg('$�� ����{/a} ����� ����{��/��}.$',0);
        Apply;
      end;
      'I' :
      begin
        inc(pc.Rint);
        pc.int := pc.Rint;
        AddMsg('$�� ����{/a} �����.$',0);
        Apply;
      end;
      ELSE
        // ��������� �����
        case Random(3)+1 of
          1 :
          begin
            inc(pc.Rstr);
            pc.str := pc.Rstr;
            AddMsg('$�� ����{/a} �������.$',0);
            Apply;
          end;
          2 :
          begin
            inc(pc.Rdex);
            pc.dex := pc.Rdex;
            AddMsg('$�� ����{/a} ����� ����{��/��}.$',0);
            Apply;
          end;
          3 :
          begin
            inc(pc.Rint);
            pc.int := pc.Rint;
            AddMsg('$�� ����{/a} �����.$',0);
            Apply;
          end;
        end;
    end;
  end;
  AddMsg('',0);
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
    DrawBorder(75,2,20,HOWMANYVARIANTS+1,crLIGHTGRAY);
    Font.Color := cBROWN;
    TextOut(77*CharX, 3*CharY, '[ ]');
    Font.Color := cWHITE;
    if WasEq then
      // � ����������
      TextOut(81*CharX, 3*CharY, '� ���������') else
        // � ���������
        TextOut(81*CharX, 3*CharY, WhatToDo(ItemsData[pc.Inv[MenuSelected].id].vid));
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
  AddMsg('*�� ����{/�a}!!!*',0);
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

{ ������ }
procedure Tpc.Search;
var
  a, b : integer;
begin
  for a:=pc.x-1 to pc.x+1 do
    for b:=pc.y-1 to pc.y+1 do
      if (a > 0) and (a <= MapX) and (b > 0) and (b <= MapY) then
        if (M.tile[a,b] = tdSECSTONE) or (M.tile[a,b] = tdSECEARTH) then
          if Random(8 - pc.ability[abATTENTION])+1 = 1 then
          begin
            M.tile[a,b] := tdCDOOR;
            AddMsg('$�� ���{��/�a} ��������� �����!$',0);
            More;
          end;
end;

{ ���� �� ���� ���� ������� ����� ����? }
function TPc.HaveItemVid(vid : byte) : boolean;
var
  i : byte;
  f : boolean;
begin
  f := FALSE;
  for i:=1 to ItemsAmount do
    if ItemsData[inv[i].id].vid = vid then
    begin
      f := TRUE;
      break;
    end;
  Result := f;
end;

{ ���� ����� ����� }
procedure TPc.StartHeroName;
begin
  GameState := gsHERONAME;
  Input(((WindowX-13) div 2), 17, '');
end;

{ ���� ����� ����� }
procedure TPc.HeroName;
const s2 = '^^^^^^^^^^^^^';
var
  n : string[13];
  s1: string;
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  s1 := GetMsg('����� ��� ����{�/���}:',gender);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s2)) div 2) * CharX, 18*CharY, s2);
    if (Inputing = FALSE) then
    begin
      if InputString = '' then
      begin
        case pc.gender of
          genMALE   : pc.name := GenerateName(FALSE);
          genFEMALE : pc.name := GenerateName(TRUE);
        end;
      end else
        pc.name := InputString;
      GameState := gsHEROATR;
      MainForm.OnPaint(NIL);
    end;
  end;
end;

{ ������� ���������� }
procedure TPc.HeroRandom;
const
  s1 = '������� �������� ��� ��� ���������� ���� ������?';
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, '������ ���');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, '��������� �����');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ���� ������ ���� }
procedure TPc.HeroGender;
const
  s1 = '������ ���� ����� ���� ��������?';
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, '��������');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, '��������');
    Font.Color := cBROWN;
    TextOut(40*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 17*CharY, '��� �������');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ����������� ����������� }
procedure TPc.HeroAtributes;
var
  s1, s2 : string;
begin
  s1 := Format('������ �������, � ������� %s ������ ����� ��������{/a}:', [pc.name]); //'������ �������, � ������� '+pc.name+' ������ ����� ��������{/a}:';
  s2 := Format('� ������ ������ �������, �������� %s ���� ������{/a} ��������:', [pc.name]); //'� ������ ������ �������, �������� '+pc.name+' ���� ������{/a} ��������:';
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    case MenuSelected2 of
      1 :
      TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(S1,gender));
      2 :
      TextOut(((WindowX-length(s2)) div 2) * CharX, 13*CharY, GetMsg(S2,gender));
    end;
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, '����');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, '��������');
    Font.Color := cBROWN;
    TextOut(40*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 17*CharY, '���������');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

procedure TPc.CreateClWList;
var
  i,k    : byte;
begin
  // ������� ������
  for i:=1 to CLOSEFIGHTAMOUNT do wlist[i] := 0;
  k := 0;
  for i:=2 to CLOSEFIGHTAMOUNT do
    if pc.closefight[i] > 0 then
    begin
      inc(k);
      wlist[k] := i;
    end;
  wlistsize := k;
end;

{ ���� ������ ���� ������ �������� ��� }
procedure TPc.HeroCloseWeapon;
var
  s1  : string;
  i   : byte;
begin
  CreateClWList;
  s1 := Format('������ ������ �������� ���, � ������� %s ����������{��/���} ������ �����:', [PC.Name]);
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(s1,gender));
    for i:=1 to CLOSEFIGHTAMOUNT-1 do
      if wlist[i] > 0 then
        if pc.closefight[wlist[i]] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(40*CharX, (14+i)*CharY, '[ ]');
          if OneOfTheBestWPNCL(wlist[i]) then
            Font.Color := cWHITE else
              Font.Color := cGRAY;
          case wlist[i] of
            2 : TextOut(44*CharX, (14+i)*CharY, '���');
            3 : TextOut(44*CharX, (14+i)*CharY, '������');
            4 : TextOut(44*CharX, (14+i)*CharY, '�����');
            5 : TextOut(44*CharX, (14+i)*CharY, '�����');
            6 : TextOut(44*CharX, (14+i)*CharY, '���������� ���');
          end;
        end;
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

procedure TPc.CreateFrWList;
var
  i,k    : byte;
begin
  // ������� ������
  for i:=1 to FARFIGHTAMOUNT do wlist[i] := 0;
  k := 0;
  for i:=2 to FARFIGHTAMOUNT do
    if pc.farfight[i] > 0 then
    begin
      inc(k);
      wlist[k] := i;
    end;
  wlistsize := k;
end;

{ ���� ������ ���� }
procedure TPc.HeroFarWeapon;
var
  S1     : string;
  I      : byte;
begin
  CreateFrWList;
  S1 := Format('����� ������ �������� ��� %s ��������{/a} �� ����� ����������?', [PC.Name]);
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(s1,gender));
    for i:=1 to FARFIGHTAMOUNT do
      if wlist[i] > 0 then
        if pc.farfight[wlist[i]] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(40*CharX, (14+i)*CharY, '[ ]');
          if OneOfTheBestWPNFR(wlist[i]) then
            Font.Color := cWHITE else
              Font.Color := cGRAY;
          case wlist[i] of
            2 : TextOut(44*CharX, (14+i)*CharY, '���');
            3 : TextOut(44*CharX, (14+i)*CharY, '�����');
            4 : TextOut(44*CharX, (14+i)*CharY, '������� ������');
            5 : TextOut(44*CharX, (14+i)*CharY, '�������');
          end;
      end;
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ����������� }
procedure Tpc.HeroCreateResult;
const
  s1 = 'ENTER - ���������, ESC - ������� ������';
var
  R, H, S : string;
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  Script.Run('CreatePC.pas');
  S := Format(V.GetStr('CreatePCStr'), [CLName(1), PC.Name]);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s)) div 2) * CharX, 13*CharY, GetMsg(S,gender));
    Font.Color := cYELLOW;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
  end;
end;

{ ������� ����� ���� }
procedure TPc.ChooseMode;
const
  s1 = '� ����� ������ ���� �� ������ ������?';
begin
  StartDecorating('<-����� ������ ����->', TRUE);
  with Screen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, '�����������');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, '����������');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

end.

