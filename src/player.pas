unit player;

interface

uses
  Main, Monsters, Cons, Tile, Utils, Msg, Flags, Items, SysUtils, Classes, Ability, Windows;

type
  Tpc = object(TMonster)
    turn: byte; // ������ ���? (0���,1��,2��+�����������)
    level: byte; // ����� �������
    enter: byte; // ����� ����� � ������ �� �������
    depth: byte; // ������� � ������
    quest: array [1 .. QuestsAmount] of byte; // ������: 0�� ���� �����,1����,2��������,3��������� ���������,4��������
    color: longword; // ����
    gender: byte; // ���
    exp: integer; // ���-�� �����
    explevel: byte; // ������� ��������
    warning: boolean; // ������ � ���� ������

    procedure ClearPlayer; // ��������
    procedure Prepare; // ���������� � ����� ������ ����
    procedure Move(dx, dy: shortint); // ������� �����
    procedure Run(dx, dy: shortint); // Shift + ������� �����
    procedure FOV; // ���� ���������
    procedure AfterTurn; // �������� ����� ���� �����
    procedure AnalysePlace(px, py: byte; All: byte); // ������� �����
    procedure PlaceHere(px, py: byte); // ��������� ����� � ��� �����
    procedure UseStairs; // ���������� ��� ��������� �� ��������
    procedure PlaceAtTile(t: byte); // ����������� ����� �� ����
    procedure SearchForDoors; // ������� ������ �����
    procedure SearchForAlive(whattodo: byte); // ������� �������� ����� (1-���������, 2-��������, 3-������)
    function SearchForAliveField: byte; // ����� ������ ���������� �������
    procedure CloseDoor(dx, dy: shortint); // ������� �����
    procedure Open(dx, dy: shortint); // �������
    procedure MoveLook(dx, dy: shortint); // ������� ������ �������
    procedure MoveAim(dx, dy: shortint); // ������� ������ �������
    procedure WriteInfo; // ������� ���������� �� ����� ������
    procedure Talk(Mon: TMonster); // ��������
    procedure QuestList; // ������ �������
    procedure Equipment; // ����������
    procedure Inventory; // ���������
    function ItemsAmount: byte; // ����������� �����
    procedure GainLevel; // ��������� ������
    function ExpToNxtLvl: integer; // ������� ����� ����� ��� ���������� ������
    procedure UseMenu; // ���� �������� � ���������
    procedure AfterDeath; // �������� ����� ������ �����
    function FindCoins: byte; // ����� ������ � ��������
    procedure Search; // ������
    function HaveItemVid(vid: byte): boolean; // ���� �� ���� ���� ������� ����� ����?
    procedure CreateClWList; // ������� ������ ������� �������� ���
    procedure CreateFrWList; // ������� ������ ������� �������� ���
    procedure WriteAboutInvMass; // �������� ����� ����� ��������� � ����. ����������� ��
    procedure PrepareShooting(B, A: TItem; Mode: byte); // ����� � ����� ������������
    function getGold(): word; // ������ ���������� ����� � ���������
    function removeGold(amount: word): boolean; // �������� � ������ amount �����. ���������� false � �� �������� ������, ���� �� �� �������.
    procedure Randommy; // ��������� �����
    procedure HeroInfoWindow; // ���� � ����������� � ����� (���, ���, ���� � ��)
  end;

var
  pc: Tpc;
  lx, ly: byte; // ���������� ������� �������
  autoaim: byte; // ID ������� �� �����������
  crstep: byte;
  InvList: array [1 .. MaxHandle] of byte;
  c_choose, f_choose: byte; // ��������� ��� ������
  wlist: array [1 .. 5] of byte;
  wlistsize: byte;

implementation

uses
  Map, MapEditor, conf, sutils, vars;

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
  fillchar(quest, sizeof(quest), 0);
  color := 0;
  gender := 0;
  exp := 0;
  explevel := 1;
  fillchar(status, sizeof(status), 0);
  warning := FALSE
end;

{ ���������� � ����� ������ ���� }
procedure Tpc.Prepare;
begin
  // �������� �������� ������ �� �����������
  Rstr := 5;
  Rdex := 5;
  Rint := 5;
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
  str := Rstr;
  dex := Rdex;
  int := Rint;
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
procedure Tpc.Move(dx, dy: shortint);
begin
  case pc.Replace(x + dx, y + dy) of
    0:
      // ������������� �� ������ �������
      if (x + dx = 1) or (x + dx = MapX) or (y + dy = 1) or (y + dy = MapY) then
      begin
        // �� �����
        if x + dx = 1 then
        begin
          if SpecialMaps[pc.level].Loc[3] = 0 then
          begin
            if Ask(GetMsg('������ ������� ��� ����{/����}?!', 0) + ' #(Y/n)#') = 'Y' then
            begin
              AskForQuit := FALSE;
              MainForm.Close;
            end
            else
              AddMsg('�� �����{/a} ��������.', 0);
          end
          else
          begin
            // ������ ��������� �� �����
            M.MonP[pc.x, pc.y] := 0;
            // ��������� �������
            if M.Save = FALSE then
              AddMsg('���������� �� ������� *:(*', 0);
            // ������  ����� �������
            pc.level := SpecialMaps[pc.level].Loc[3];
            // ���� ��������� �� ������� - ������ ��������� ;)
            if M.Load(pc.level, pc.enter, pc.depth) = FALSE then
              M.MakeSpMap(pc.level);
            pc.x := MapX - 1;
            M.MonP[pc.x, pc.y] := 1;
            pc.turn := 2;
          end
        end
        else
          // �� ������
          if x + dx = MapX then
          begin
            if (SpecialMaps[pc.level].Loc[4] = 0) and (pc.level = 1) then
            begin
              if Ask(GetMsg('����������! �� ��������{/a} ������ ������ ������ ����! ������ ������ ����? #(Y/n)#', 0)) = 'Y' then
              begin
                AskForQuit := FALSE;
                MainForm.Close;
              end
              else
                AddMsg('�� �����{/a} ��������.', 0);
            end
            else
            begin
              // ������ ��������� �� �����
              M.MonP[pc.x, pc.y] := 0;
              // ��������� �������
              if M.Save = FALSE then
                AddMsg('���������� �� ������� *:(*', 0);
              // ������  ����� �������
              pc.level := SpecialMaps[pc.level].Loc[4];
              // ���� ��������� �� ������� - ������ ��������� ;)
              if M.Load(pc.level, pc.enter, pc.depth) = FALSE then
                M.MakeSpMap(pc.level);
              pc.x := 2;
              M.MonP[pc.x, pc.y] := 1;
              pc.turn := 2;
            end;
          end
          else
            // �� �����
            if y + dy = 1 then
            begin
              if SpecialMaps[pc.level].Loc[1] = 0 then
              begin
                if Ask(GetMsg('������ ������� ��� ����{/����}?! #(Y/n)#', 0)) = 'Y' then
                begin
                  AskForQuit := FALSE;
                  MainForm.Close;
                end
                else
                  AddMsg('�� �����{/a} ��������.', 0);
              end
              else
              begin
                // ������ ��������� �� �����
                M.MonP[pc.x, pc.y] := 0;
                // ��������� �������
                if M.Save = FALSE then
                  AddMsg('���������� �� ������� *:(*', 0);
                // ������  ����� �������
                pc.level := SpecialMaps[pc.level].Loc[1];
                // ���� ��������� �� ������� - ������ ��������� ;)
                if M.Load(pc.level, pc.enter, pc.depth) = FALSE then
                  M.MakeSpMap(pc.level);
                pc.y := MapY - 1;
                M.MonP[pc.x, pc.y] := 1;
                pc.turn := 2;
              end;
            end
            else
              // �� ��
              if y + dy = MapY then
              begin
                if SpecialMaps[pc.level].Loc[2] = 0 then
                begin
                  if Ask(GetMsg('������ ������� ��� ����{/����}?! #(Y/n)#', 0)) = 'Y' then
                  begin
                    AskForQuit := FALSE;
                    MainForm.Close;
                  end
                  else
                    AddMsg('�� �����{/a} ��������.', 0);
                end
                else
                begin
                  // ������ ��������� �� �����
                  M.MonP[pc.x, pc.y] := 0;
                  // ��������� �������
                  if M.Save = FALSE then
                    AddMsg('���������� �� ������� *:(*', 0);
                  // ������  ����� �������
                  pc.level := SpecialMaps[pc.level].Loc[2];
                  // ���� ��������� �� ������� - ������ ��������� ;)
                  if M.Load(pc.level, pc.enter, pc.depth) = FALSE then
                    M.MakeSpMap(pc.level);
                  pc.y := 2;
                  M.MonP[pc.x, pc.y] := 1;
                  pc.turn := 2;
                end;
              end;
      end
      else
        // ����� �� �����
        if (x = x + dx) and (y = y + dy) then
        begin
          M.MonP[x, y] := 1;
          turn := 1;
        end
        else
        // ������ �������������
        begin
          turn := 2;
          M.MonP[x, y] := 0;
          x := x + dx;
          y := y + dy;
          M.MonP[x, y] := 1;
        end;
    2: // �����
      if M.Tile[x + dx, y + dy] = tdCDOOR then
      begin
        M.Tile[x + dx, y + dy] := tdODOOR;
        AddMsg('�� ������{/a} �����.', 0);
        pc.turn := 1;
      end;
    3: // ���-�� �����
      begin
        if (M.MonL[M.MonP[x + dx, y + dy]].relation = 0) and (not M.MonL[M.MonP[x + dx, y + dy]].felldown) then
        begin
          // ������ ���������� �������
          AddMsg(Format('�� � %s ���������� �������.', [MonstersData[M.MonL[M.MonP[x + dx, y + dy]].id].name1]), 0);
          M.MonP[x, y] := M.MonP[x + dx, y + dy];
          M.MonL[M.MonP[x, y]].x := x;
          M.MonL[M.MonP[x, y]].y := y;
          x := x + dx;
          y := y + dy;
          M.MonP[x, y] := 1;
          pc.turn := 2;
        end
        else
          // ����������� � �����
          if (M.MonL[M.MonP[x + dx, y + dy]].relation = 0) and (M.MonL[M.MonP[x + dx, y + dy]].felldown) then
          begin
            // �� ���� ���������� �������
            AddMsg(Format('�� � %s �� ������ ���������� �������!', [MonstersData[M.MonL[M.MonP[x + dx, y + dy]].id].name1]), 0);
            pc.turn := 1;
          end
          else
          begin
            // ���������
            pc.Fight(M.MonL[M.MonP[x + dx, y + dy]], 0);
            pc.turn := 1;
          end;
      end;
  end;
end;

{ Shift + ������� ����� }
procedure Tpc.Run(dx, dy: shortint);
var
  around: array [1 .. 3, 1 .. 3] of byte;
  stop: boolean;
begin
  Move(dx, dy);
  (* // ���������
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
    stop; *)
end;

{ ���� ��������� }
procedure Tpc.FOV;
var
  A, B: integer;
  reallos: byte;
begin
  pc.warning := FALSE;
  reallos := los + (Ability[abGOODEYES] * Round(AbilitysData[abGOODEYES].koef));
  for A := x - reallos - 2 to x + reallos + 2 do
    for B := y - reallos - 2 to y + reallos + 2 do
      if M.Saw[A, B] > 0 then
        M.Saw[A, B] := 1;
  for A := x - reallos to x + reallos do
    for B := y - reallos to y + reallos do
    begin
      if InFov(x, y, A, B, reallos) then
        if LosLine(A, B) then
        begin
          M.Saw[A, B] := 2;
          if M.MonP[A, B] > 0 then
            if M.MonL[M.MonP[A, B]].relation = 1 then
              pc.warning := TRUE;
          // ��������� ����
          M.MemBC[A, B] := TilesData[M.Tile[A, B]].color;
          if M.MonP[A, B] > 0 then
          begin
            M.MemS[A, B] := MonstersData[M.MonL[M.MonP[A, B]].id].char;
            M.MemC[A, B] := M.MonL[M.MonP[A, B]].ClassColor;
          end
          else if M.Item[A, B].id > 0 then
          begin
            M.MemS[A, B] := ItemTypeData[ItemsData[M.Item[A, B].id].vid].symbol;;
            M.MemC[A, B] := ItemsData[M.Item[A, B].id].color;
          end
          else
          begin
            M.MemS[A, B] := TilesData[M.Tile[A, B]].char;
            M.MemC[A, B] := TilesData[M.Tile[A, B]].color;
          end;
        end;
    end;
end;

{ �������� ����� ���� ����� }
procedure Tpc.AfterTurn;
begin
  if pc.turn > 0 then
  begin
    // ��� ��������
    MonstersTurn;
    // ����� ��������� �����:)
    pc.FOV;
    // ���� ��� �� ����
    if id > 0 then
    begin
      // ���� ������������ �� ������ ������ - ������� ��������, ���� ����
      if pc.turn = 2 then
        AnalysePlace(pc.x, pc.y, 0);
      // ��������
      pc.turn := 0;
      // ����� ������
      inc(status[stHUNGRY]);
      // ������
      if status[stDRUNK] > 0 then
        dec(status[stDRUNK]);
      if status[stHUNGRY] = 1500 then
      begin
        AddMsg('*�� ���{/a} ������� �������{/a}...*', 0);
        More;
        pc.hp := 0;
      end;
      // ����������� (���� �� ������� � ������)
      if (pc.hp < pc.Rhp) and (pc.status[stHUNGRY] <= 1200) then
        if Random(Round(40 / (1 + (pc.Ability[abQUICKREGENERATION] * AbilitysData[abQUICKREGENERATION].koef)))) + 1 = 1 then
          inc(pc.hp);
      if pc.hp <= 0 then
        Death;
      // �����������
      pc.Search;
    end;
  end;
  MainForm.OnPaint(NIL);
end;

{ ������� ����� }
procedure Tpc.AnalysePlace(px, py: byte; All: byte);
var
  s: string;
begin
  // ����
  if (All = 2) or (TilesData[M.Tile[px, py]].important) or ((M.Blood[px, py] > 0) and (All <> 1)) then
    if M.Blood[px, py] > 0 then
      AddMsg('*' + TilesData[M.Tile[px, py]].name + ' � �����.*', 0)
    else
      AddMsg(TilesData[M.Tile[px, py]].name + '.', 0);
  // ������
  if All > 0 then
    if M.MonP[px, py] > 0 then
    begin
      if M.MonP[px, py] = 1 then
        AddMsg(Format('��� �� - %s. �� %s.', [pc.name, pc.WoundDescription(FALSE)]), 0)
      else
      begin
        s := M.MonL[M.MonP[px, py]].FullName(1, TRUE) + '.';
        // �����
        if M.MonL[M.MonP[px, py]].felldown then
          s := s + ' �����.';
        // ���������
        s := s + ' ' + M.MonL[M.MonP[px, py]].WoundDescription(TRUE) + '.';
        // �������
        if M.MonL[M.MonP[px, py]].tactic = 1 then
          s := s + ' ��������{/a} ������ ����������.';
        if M.MonL[M.MonP[px, py]].tactic = 2 then
          s := s + ' ����������.';
        // ������ � ����� � ������ ����
        if IsFlag(MonstersData[M.MonL[M.MonP[px, py]].id].Flags, M_HAVEITEMS) then
        begin
          // ������
          if M.MonL[M.MonP[px, py]].eq[6].id = 0 then
            s := s + ' �������{��/��}.'
          else
            s := s + Format(' � ����� ������ %s.', [ItemsData[M.MonL[M.MonP[px, py]].eq[6].id].name3]);
          // ���
          if M.MonL[M.MonP[px, py]].eq[8].id > 0 then
            s := s + Format(' � ����� ������ %s.', [ItemsData[M.MonL[M.MonP[px, py]].eq[6].id].name3]);
          // �����
          if M.MonL[M.MonP[px, py]].eq[4].id > 0 then
            s := s + Format(' �� ��� �� ������ %s.', [ItemsData[M.MonL[M.MonP[px, py]].eq[4].id].name3]);
        end;
        { Font.Color := cBROWN;
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
          TextOut(5*CharX, 23*CharY, '[ ] - ��������          :'); }
        AddMsg(s, M.MonL[M.MonP[px, py]].id);
      end;
    end;
  // �������
  if All <> 1 then
    if M.Item[px, py].id > 0 then
    begin
      if M.Item[px, py].amount = 1 then
        AddMsg(Format('����� ����� %s.', [ItemName(M.Item[px, py], 0, TRUE)]), 0)
      else
        AddMsg(Format('����� ����� %s.', [ItemName(M.Item[px, py], 0, TRUE)]), 0);
    end;
end;

{ ��������� ����� � ��� ����� }
procedure Tpc.PlaceHere(px, py: byte);
begin
  M.MonP[px, py] := 1;
  pc.x := px;
  pc.y := py;
end;

{ ���������� ��� ��������� �� �������� }
procedure Tpc.UseStairs;
var
  i, wasenter, waslevel: byte;
  dunname: string[17];
begin
  if (M.Tile[pc.x, pc.y] = tdDSTAIRS) or (M.Tile[pc.x, pc.y] = tdOHATCH) or (M.Tile[pc.x, pc.y] = tdDUNENTER) then
  begin
    // ������ ��������� �� �����
    M.MonP[pc.x, pc.y] := 0;
    // ��������� �������
    if M.Save = FALSE then
      AddMsg('�������� �� ������� *:(*', 0);
    // ���� ����� ������� ����� ������ ����� ��������
    if pc.enter = 0 then
    begin
      for i := 1 to MaxLadders do
        if (SpecialMaps[pc.level].Ladders[i].x = pc.x) and (SpecialMaps[pc.level].Ladders[i].y = pc.y) then
        begin
          pc.enter := i;
          if SpecialMaps[pc.level].Ladders[i].name = '' then
            dunname := GetDungeonModeMapName()
          else
            dunname := SpecialMaps[pc.level].Ladders[i].name;
          break;
        end;
    end
    else
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
    if M.Load(pc.level, pc.enter, pc.depth) = FALSE then
    begin
      // ����������
      if SpecialMaps[waslevel].Ladders[pc.enter].Levels[pc.depth].PregenLevel = 0 then
      begin
        // ��� ������� ����
        if (pc.depth = 10) or (SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth + 1].IsHere = FALSE) then
          M.GenerateCave(SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].DungeonType, FALSE)
        else
          M.GenerateCave(SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].DungeonType, TRUE);
        M.name := dunname;
      end
      else
        // ����. �������
        M.MakeSpMap(pc.level);
      if dunname <> '' then
        M.name := dunname;
    end;
    PlaceAtTile(tdUSTAIRS);
    pc.turn := 2;
    AddMsg(Format('�� �������{��/���} ���� �� �������� �� ������� %d.', [pc.depth]), 0);
  end
  else if M.Tile[pc.x, pc.y] = tdUSTAIRS then
  begin
    // dunname := M.name;
    // ������ ��������� �� �����
    M.MonP[pc.x, pc.y] := 0;
    // ��������� �������
    if M.Save = FALSE then
      AddMsg('�������� �� ������� <:(>', 0);
    // ���� ����
    dec(pc.depth);
    wasenter := pc.enter;
    if pc.depth = 0 then
      pc.enter := 0;
    if SpecialMaps[pc.level].LadderUp > 0 then
      pc.level := SpecialMaps[pc.level].LadderUp;
    // ������� ���������...
    if M.Load(pc.level, pc.enter, pc.depth) = FALSE then
    begin
      AddMsg('�� ������� ��������� �����. �������� ���� � ����������� ��� ������, ���� ��� �� ������� ��������.', 0);
      More;
      AddMsg('*��� ����������� ������. ���� ��������.*', 0);
      More;
      AskForQuit := FALSE;
      MainForm.Close;
    end;
    if (M.Special <> 0) and (SpecialMaps[M.Special].name <> '') then
      M.name := SpecialMaps[M.Special].name;
    if M.Special > 0 then
      pc.level := M.Special;
    // ��������� �����
    if pc.depth = 0 then
    begin
      pc.x := SpecialMaps[pc.level].Ladders[wasenter].x;
      pc.y := SpecialMaps[pc.level].Ladders[wasenter].y;
      M.MonP[pc.x, pc.y] := 1;
    end
    else
      PlaceAtTile(tdDSTAIRS);
    pc.turn := 2;
    if pc.depth > 0 then
      AddMsg(Format('�� ������{��/���} �� �������� �� ������� %d.', [pc.depth]), 0)
    else
      AddMsg('�� ������{��/���} �� �������� � ����� ������{��/���} �� ������ �������.', 0);
  end;
end;

{ ����������� ����� �� ���� }
procedure Tpc.PlaceAtTile(t: byte);
var
  A, B: byte;
begin
  for A := 1 to MapX do
    for B := 1 to MapY do
      if M.Tile[A, B] = t then
      begin
        pc.x := A;
        pc.y := B;
        M.MonP[x, y] := 1;
        exit;
      end;
end;

{ ������� ������ ����� }
procedure Tpc.SearchForDoors;
var
  A, B, i: shortint;
begin
  i := 0;
  for A := pc.x - 1 to pc.x + 1 do
    for B := pc.y - 1 to pc.y + 1 do
      if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
        if M.Tile[A, B] = tdODOOR then
          inc(i);
  case i of
    0:
      AddMsg('����� ��� �������� �����!', 0);
    1:
      begin
        for A := pc.x - 1 to pc.x + 1 do
          for B := pc.y - 1 to pc.y + 1 do
            if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
              if M.Tile[A, B] = tdODOOR then
              begin
                CloseDoor(A - pc.x, B - pc.y);
                exit;
              end;
      end;
  else
    begin
      AddMsg('����� ������ ����� �� ������ �������?', 0);
      GameState := gsCLOSE;
    end;
  end;
end;

{ ������� �������� ����� }
procedure Tpc.SearchForAlive(whattodo: byte);
var
  A, B, i: shortint;
begin
  i := 0;
  for A := pc.x - 1 to pc.x + 1 do
    for B := pc.y - 1 to pc.y + 1 do
      if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
        if M.MonP[A, B] > 1 then
          inc(i);
  case i of
    0:
      case whattodo of
        1:
          AddMsg('����� � ����� ������ ���!', 0); // ���������
        2:
          AddMsg('����� �� � ��� ����������!', 0); // ��������
        3:
          AddMsg('����� � ����� ������ ���!', 0); // ������
      end;
    1:
      begin
        for A := pc.x - 1 to pc.x + 1 do
          for B := pc.y - 1 to pc.y + 1 do
            if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
              if M.MonP[A, B] > 1 then
              begin
                case whattodo of
                  1:
                    Fight(M.MonL[M.MonP[A, B]], 0); // ���������
                  2:
                    Talk(M.MonL[M.MonP[A, B]]); // ��������
                  3:
                    if LastGameState = gsEQUIPMENT then
                      GiveItem(MenuSelected, 2, M.MonL[M.MonP[A, B]])
                    else
                      GiveItem(MenuSelected, 1, M.MonL[M.MonP[A, B]]); // ������
                end;
                pc.turn := 1;
                exit;
              end;
      end;
  else
    begin
      case whattodo of
        1:
          AddMsg('�� ���� ������ �� ������ �������?', 0);
        2:
          AddMsg('� ��� ������ �� ������ ����������?', 0);
        3:
          AddMsg('���� ������ ������?', 0);
      end;
      GameState := gsCHOOSEMONSTER;
      wtd := whattodo;
    end;
  end;
end;

{ ����� ������ ���������� ������� }
function Tpc.SearchForAliveField: byte;
var
  MList: array [1 .. 255] of byte;
  A, B, k: integer;
begin
  FillMemory(@MList, sizeof(MList), 0);
  k := 1;
  // �������� ������ ���������� ��������
  for A := x - 20 to x + 20 do
    for B := y - 20 to y + 20 do
      if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
        if M.Saw[A, B] = 2 then
          if M.MonP[A, B] > 1 then
          begin
            MList[k] := M.MonP[A, B];
            inc(k);
          end;
  if MList[1] > 0 then
  begin
    // ������ ������ ��������
    B := 1;
    for A := 1 to 255 do
      if MList[A] > 0 then
      begin
        if (ABS(x - M.MonL[MList[A]].x) <= ABS(x - M.MonL[MList[B]].x)) and (ABS(y - M.MonL[MList[A]].y) <= ABS(y - M.MonL[MList[B]].y)) then
          B := A;
      end
      else
        break;
    Result := MList[B];
  end
  else
    Result := 0;
end;

{ ������� ����� }
procedure Tpc.CloseDoor(dx, dy: shortint);
var
  A, B: integer;
begin
  A := pc.x + dx;
  B := pc.y + dy;
  if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
  begin
    if M.Tile[A, B] = tdODOOR then
    begin
      if M.MonP[A, B] = 0 then
      begin
        AddMsg('�� ������{/a} �����.', 0);
        M.Tile[A, B] := tdCDOOR;
        pc.turn := 1;
      end
      else
        AddMsg('����� ����� ' + MonstersData[M.MonL[M.MonP[A, B]].id].name1 + '! �� �� ������ ������� �����!', 0);
    end
    else
      AddMsg('����� ��� �������� �����!', 0);
  end;
end;

{ ������� }
procedure Tpc.Open(dx, dy: shortint);
var
  A, B: integer;
begin
  A := pc.x + dx;
  B := pc.y + dy;
  if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
  begin
    if M.Tile[A, B] = tdCDOOR then
    begin
      if M.MonP[A, B] = 0 then
      begin
        AddMsg('�� ������{/a} �����.', 0);
        M.Tile[A, B] := tdODOOR;
        pc.turn := 1;
      end
      else
        AddMsg('����� ����� ' + MonstersData[M.MonL[M.MonP[A, B]].id].name1 + '! �� �� ������ ������� �����! ���� ��� �� ��� ����� ������?', 0);
    end
    else if M.Tile[A, B] = tdCHATCH then
    begin
      if M.MonP[A, B] = 0 then
      begin
        AddMsg('�� � ������ ������{/a} ���.', 0);
        M.Tile[A, B] := tdOHATCH;
        pc.turn := 1;
      end
      else
        AddMsg('����� ����� ' + MonstersData[M.MonL[M.MonP[A, B]].id].name1 + '! �� �� ������ ������� ���!', 0);
    end
    else
      AddMsg('��� ����� ����� �������?', 0);
  end;
end;

{ ������� ������ ������� }
procedure Tpc.MoveLook(dx, dy: shortint);
var
  A, B: integer;
begin
  A := lx + dx;
  B := ly + dy;
  if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
    if M.Saw[A, B] = 2 then
    begin
      lx := A;
      ly := B;
      AnalysePlace(lx, ly, 2);
    end;
end;

{ ������� ������ ������� }
procedure Tpc.MoveAim(dx, dy: shortint);
var
  A, B: integer;
begin
  A := lx + dx;
  B := ly + dy;
  if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
    if M.Saw[A, B] = 2 then
    begin
      lx := A;
      ly := B;
      if M.MonP[lx, ly] > 0 then
        AddMsg('#�������� �:#', 0);
      AnalysePlace(lx, ly, 1);
    end;
end;

{ ������� ���������� �� ����� ������ }
procedure Tpc.WriteInfo;
var
  HLine: byte;
  MB, WW: integer;
begin
  with GScreen.Canvas do
  begin
    // ������ ����
    WW := (98 * CharX) - (82 * CharX);
    HLine := 1;
    // ��������
    if hp < 0 then
      hp := 0;
    Font.color := cLIGHTGRAY;
    TextOut(82 * CharX, HLine * CharY, '�������� :');
    Font.color := ReturnColor(Rhp, hp, 1);
    TextOut(92 * CharX, HLine * CharY, IntToStr(hp));
    Font.color := cLIGHTGRAY;
    TextOut(95 * CharX, HLine * CharY, '(' + IntToStr(Rhp) + ')');
    if (ShowBars = 1) then
    begin
      inc(HLine);
      Pen.color := cGRAY;
      Pen.Width := 9;
      MoveTo((82 * CharX) + 4, Round((HLine + 0.5) * CharY));
      LineTo((98 * CharX) + 4, Round((HLine + 0.5) * CharY));
      if (hp > 0) then
      begin
        Pen.color := cLIGHTRED;
        MoveTo((82 * CharX) + 4, Round((HLine + 0.5) * CharY));
        LineTo((82 * CharX) + BarWidth(hp, Rhp, WW) + 4, Round((HLine + 0.5) * CharY));
      end;
    end;
    // �������
    inc(HLine);
    if Ep < 0 then
      Ep := 0;
    Font.color := cLIGHTGRAY;
    TextOut(82 * CharX, HLine * CharY, '�������  :');
    Font.color := ReturnColor(Rep, Ep, 2);
    TextOut(92 * CharX, HLine * CharY, IntToStr(Ep));
    Font.color := cLIGHTGRAY;
    TextOut(95 * CharX, HLine * CharY, '(' + IntToStr(Rep) + ')');
    if (ShowBars = 1) then
    begin
      inc(HLine);
      Pen.color := cGRAY;
      Pen.Width := 9;
      MoveTo((82 * CharX) + 4, Round((HLine + 0.5) * CharY));
      LineTo((98 * CharX) + 4, Round((HLine + 0.5) * CharY));
      if (Ep > 0) then
      begin
        Pen.color := cLIGHTBLUE;
        MoveTo((82 * CharX) + 4, Round((HLine + 0.5) * CharY));
        LineTo((82 * CharX) + BarWidth(Ep, Rep, WW) + 4, Round((HLine + 0.5) * CharY));
      end;
    end;
    inc(HLine);
    // ������
    Font.color := cLIGHTGRAY;
    TextOut(82 * CharX, HLine * CharY, '������   :' + IntToStr(getGold));
    inc(HLine);
    inc(HLine);
    Font.color := cBROWN;
    TextOut(81 * CharX, HLine * CharY, '-------------------');
    inc(HLine);
    inc(HLine);
    Font.color := cLIGHTGRAY;
    TextOut(82 * CharX, HLine * CharY, '����     :');
    if str > Rstr then
      Font.color := cLIGHTGREEN
    else if str < Rstr then
      Font.color := cLIGHTRED
    else
      Font.color := cLIGHTGRAY;
    TextOut(92 * CharX, HLine * CharY, IntToStr(str));
    inc(HLine);
    TextOut(82 * CharX, HLine * CharY, '�������� :');
    if dex > Rdex then
      Font.color := cLIGHTGREEN
    else if dex < Rdex then
      Font.color := cLIGHTRED
    else
      Font.color := cLIGHTGRAY;
    TextOut(92 * CharX, HLine * CharY, IntToStr(dex));
    inc(HLine);
    TextOut(82 * CharX, HLine * CharY, '���������:');
    if int > Rint then
      Font.color := cLIGHTGREEN
    else if int < Rint then
      Font.color := cLIGHTRED
    else
      Font.color := cLIGHTGRAY;
    TextOut(92 * CharX, HLine * CharY, IntToStr(int));
    Font.color := cBROWN;
    inc(HLine);
    inc(HLine);
    TextOut(81 * CharX, HLine * CharY, '-------------------');
    Font.color := cLIGHTGRAY;
    inc(HLine);
    inc(HLine);
    TextOut(82 * CharX, HLine * CharY, '�������  :' + IntToStr(explevel));
    // ������ �����
    if (ShowBars = 1) then
    begin
      inc(HLine);
      Pen.color := cGRAY;
      Pen.Width := 9;
      MoveTo((82 * CharX) + 4, Round((HLine + 0.5) * CharY));
      LineTo((98 * CharX) + 4, Round((HLine + 0.5) * CharY));
      if pc.exp < 0 then
        pc.exp := 0;
      if (pc.exp > 0) then
      begin
        Pen.color := cBLUEGREEN;
        MoveTo((82 * CharX) + 4, Round((HLine + 0.5) * CharY));
        LineTo((82 * CharX) + BarWidth(pc.exp, pc.ExpToNxtLvl, WW) + 4, Round((HLine + 0.5) * CharY));
      end;
    end;
    //
    inc(HLine);
    TextOut(82 * CharX, HLine * CharY, '����     :' + IntToStr(pc.exp));
    inc(HLine);
    TextOut(82 * CharX, HLine * CharY, '�����    :' + IntToStr(pc.ExpToNxtLvl));
    Font.color := cBROWN;
    inc(HLine);
    inc(HLine);
    TextOut(81 * CharX, HLine * CharY, '-------------------');
    inc(HLine);
    inc(HLine);
    // �������� ������� �����
    Font.color := cLIGHTGRAY;
    if (M.Special > 0) and (SpecialMaps[M.Special].ShowName) then
      TextOut(82 * CharX, HLine * CharY, SpecialMaps[M.Special].name)
    else
    begin
      if ((M.Special > 0) and (SpecialMaps[M.Special].ShowName = FALSE) and (pc.depth > 0)) or ((M.Special = 0) and (pc.depth > 0)) then
      begin
        // ���������� �������� ���������� � ��� �������
        TextOut(82 * CharX, HLine * CharY, M.name);
        inc(HLine);
        TextOut(82 * CharX, HLine * CharY, '�������  : ' + IntToStr(pc.depth))
      end
      else
        TextOut(82 * CharX, HLine * CharY, '�������� �����...');
    end;
    Font.color := cBROWN;
    inc(HLine);
    inc(HLine);
    TextOut(81 * CharX, HLine * CharY, '-------------------');
    inc(HLine);
    inc(HLine);
    if (hp > 0) then
      case pc.status[stHUNGRY] of
        - 500 .. -400:
          begin
            Font.color := cLIGHTRED;
            TextOut(82 * CharX, HLine * CharY, '������...');
          end;
        -399 .. -1:
          begin
            Font.color := cGREEN;
            TextOut(82 * CharX, HLine * CharY, GetMsg('������{/a}...', gender));
          end;
        0 .. 450:
          begin
            Font.color := cGRAY;
            TextOut(82 * CharX, HLine * CharY, GetMsg('���{��/��}', gender));
          end;
        451 .. 750:
          begin
            Font.color := cYELLOW;
            TextOut(82 * CharX, HLine * CharY, GetMsg('����������{��/���}', gender));
          end;
        751 .. 1200:
          begin
            Font.color := cLIGHTRED;
            TextOut(82 * CharX, HLine * CharY, GetMsg('�����{��/��}', gender));
          end;
        1201 .. 1500:
          begin
            Font.color := cRED;
            TextOut(82 * CharX, HLine * CharY, GetMsg('�������� �� ������!', gender));
          end;
      end
    else
    begin
      Font.color := cGRAY;
      TextOut(82 * CharX, HLine * CharY, GetMsg('�����{��/��}', gender));
    end;
    if (hp > 0) then
    begin
      inc(HLine);
      case pc.status[stDRUNK] of
        350 .. 500:
          begin
            Font.color := cYELLOW;
            TextOut(82 * CharX, HLine * CharY, GetMsg('����{��/��}', gender));
          end;
        501 .. 800:
          begin
            Font.color := cLIGHTRED;
            TextOut(82 * CharX, HLine * CharY, GetMsg('����{��/��}! ��!', gender));
          end;
      end;
    end;
  end;
end;

{ �������� }
procedure Tpc.Talk(Mon: TMonster);
begin
  if Mon.id > 1 then
  begin
    Mon.TalkToMe;
    pc.turn := 1;
  end
  else
    AddMsg('����� �� � ��� ����������!', 0);
end;

{ ������ ������� }
procedure Tpc.QuestList;
var
  i, k: byte;
begin
  StartDecorating('<-������ ������� �������->', FALSE);
  with GScreen.Canvas do
  begin
    k := 0;
    for i := 1 to QuestsAmount do
      if (pc.quest[i] in [1 .. 3]) then
      begin
        k := 1;
        break;
      end;
    if k = 0 then
    begin
      Font.color := cLIGHTGRAY;
      TextOut(5 * CharX, 5 * CharY, GetMsg('���� ��� �� �� ����{/a} �� ������ ������.', gender));
    end
    else
      // ������� ������
      for i := 1 to QuestsAmount do
      begin
        if (pc.quest[i] in [1 .. 3]) then
        begin
          Font.color := cLIGHTGREEN;
          case i of
            1:
              TextOut(4 * CharX, (4 + i) * CharY, '����������� ��������� � ���������� ����� �� ���, ��������� � ��� (����������)');
            2:
              TextOut(4 * CharX, (4 + i) * CharY, '����� ���� �� ��������� ���� ������� (����������)');
            3:
              TextOut(4 * CharX, (4 + i) * CharY, '�������� ������������ ������ ���������� (��������)');
          end;
          case pc.quest[i] of
            1:
              begin
                Font.color := cRED;
                TextOut(2 * CharX, (4 + i) * CharY, '-');
              end;
            2:
              begin
                Font.color := cGREEN;
                TextOut(2 * CharX, (4 + i) * CharY, '+');
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
  i: byte;
begin
  StartDecorating('<-����������->', FALSE);
  with GScreen.Canvas do
  begin
    Font.color := cBROWN;
    TextOut(5 * CharX, 11 * CharY, '[ ] - ������            :');
    TextOut(5 * CharX, 12 * CharY, '[ ] - ���               :');
    TextOut(5 * CharX, 13 * CharY, '[ ] - ����              :');
    TextOut(5 * CharX, 14 * CharY, '[ ] - ����              :');
    TextOut(5 * CharX, 15 * CharY, '[ ] - ����              :');
    TextOut(5 * CharX, 16 * CharY, '[ ] - ������            :');
    TextOut(5 * CharX, 17 * CharY, '[ ] - ������� ���       :');
    TextOut(5 * CharX, 18 * CharY, '[ ] - ���               :');
    TextOut(5 * CharX, 19 * CharY, '[ ] - ��������          :');
    TextOut(5 * CharX, 20 * CharY, '[ ] - ������            :');
    TextOut(5 * CharX, 21 * CharY, '[ ] - ��������          :');
    TextOut(5 * CharX, 22 * CharY, '[ ] - �����             :');
    TextOut(5 * CharX, 23 * CharY, '[ ] - ��������          :');
    for i := 1 to EqAmount do
      if pc.eq[i].id = 0 then
      begin
        if HaveItemVid(Eq2Vid(i)) then
        begin
          Font.color := cYELLOW;
          TextOut(31 * CharX, (10 + i) * CharY, '+');
        end
        else
        begin
          Font.color := cGRAY;
          TextOut(31 * CharX, (10 + i) * CharY, '-');
        end;
        // ���������� ����� � ���������� �������
        if i = 6 then
        begin
          Font.color := cLIGHTGRAY;
          TextOut(33 * CharX, (10 + i) * CharY, Format('{����� � ���������� �������: %d}', [pc.attack]));
        end;
      end
      else
      begin
        Font.color := cLIGHTGRAY;
        TextOut(31 * CharX, (10 + i) * CharY, ItemName(pc.eq[i], 0, TRUE));
      end;
    Font.color := cGRAY;
    if ItemsAmount > 0 then
      TextOut(((WindowX - length(s1)) div 2) * CharX, 39 * CharY, s1)
    else
      TextOut(((WindowX - length(s2)) div 2) * CharX, 39 * CharY, s2);
    if pc.eq[MenuSelected].id > 0 then
      TextOut(((WindowX - length(s3)) div 2) * CharX, 37 * CharY, s3);
    Font.color := cRED;
    TextOut(6 * CharX, (10 + MenuSelected) * CharY, '*');
  end;
  WriteSomeAboutItem(pc.eq[MenuSelected]);
  WriteAboutInvMass;
end;

{ ��������� }
procedure Tpc.Inventory;
const
  s1 = '< ����� ENTER ��� ����, ��� �� ������������ ������� >';
  s2 = '< ����� ''i'' ����� ������� � ����� ����������  >';
var
  i, k: byte;
begin
  // ���������
  if VidFilter = 0 then
    StartDecorating('<-���������->', FALSE)
  else
    StartDecorating('<-' + whattodo(VidFilter) + '->', FALSE);
  // �������� ���������
  for i := 1 to MaxHandle do
    InvList[i] := 0;
  // ������� ��������� �� �������
  k := 1;
  for i := 1 to ItemsAmount do
    if (VidFilter = 0) or (ItemsData[pc.inv[i].id].vid = VidFilter) then
    begin
      InvList[k] := i;
      inc(k);
    end;
  // ������� ������ ���������
  with GScreen.Canvas do
  begin
    Font.color := cGRAY;
    TextOut(((WindowX - length(s1)) div 2) * CharX, 37 * CharY, s1);
    TextOut(((WindowX - length(s2)) div 2) * CharX, 39 * CharY, s2);
    for i := 1 to ItemsAmount do
      if InvList[i] > 0 then
      begin
        Font.color := cBROWN;
        TextOut(5 * CharX, (2 + i) * CharY, '[ ]');
        Font.color := cLIGHTGRAY;
        TextOut(9 * CharX, (2 + i) * CharY, ItemName(pc.inv[InvList[i]], 0, TRUE));
        Font.color := cRED;
        TextOut(6 * CharX, (2 + MenuSelected) * CharY, '*');
      end
      else
        break;
    WriteSomeAboutItem(pc.inv[InvList[MenuSelected]], TRUE);
    WriteAboutInvMass;
  end;
end;

{ ����������� ����� }
function Tpc.ItemsAmount: byte;
var
  i, k: byte;
begin
  k := 0;
  for i := 1 to MaxHandle do
    if inv[i].id > 0 then
      inc(k);
  Result := k;
end;

{ ��������� ������ }
procedure Tpc.GainLevel;
var
  A: string;
  i, B: byte;
begin
  AddMsg('$����������! �� ������{/��} ������ ������ ��������!$', 0);
  Apply;
  // �������� �������, �������� ������� �����
  inc(pc.explevel);
  pc.exp := 0;
  // ���� ����� �����������
  B := 0;
  for i := 1 to AbilitysAmount do
    if pc.Ability[i] < 4 then
      B := 1;
  // ���� ��� �������� �����������, ������� ����� ���������
  if B > 0 then
  begin
    repeat
      i := Random(AbilitysAmount) + 1;
    until pc.Ability[i] < 4;
    inc(pc.Ability[i]);
    if pc.Ability[i] = 1 then
      AddMsg('�� ������{/a} � ���� ����� ����������� - "$' + AbilitysData[i].name + '$"!', 0)
    else
      AddMsg('���� ����������� "#' + AbilitysData[i].name + '#" ����� �� ������� �����!', 0);
    Apply;
  end;
  // ������ ������ ������� ����� ������� �������� ���
  if pc.explevel mod 3 = 0 then
  begin
    AddMsg('#�� ������ �������� ���� �� ����� ���������!#', 0);
    A := Ask('������ �����: (#S#) ����, (#D#) �������� ��� (#I#) ���������?');
    case A[1] of
      'S':
        begin
          inc(pc.Rstr);
          pc.str := pc.Rstr;
          AddMsg('$�� ����{/a} �������.$', 0);
          Apply;
        end;
      'D':
        begin
          inc(pc.Rdex);
          pc.dex := pc.Rdex;
          AddMsg('$�� ����{/a} ����� ����{��/��}.$', 0);
          Apply;
        end;
      'I':
        begin
          inc(pc.Rint);
          pc.int := pc.Rint;
          AddMsg('$�� ����{/a} �����.$', 0);
          Apply;
        end;
    ELSE
      // ��������� �����
      case Random(3) + 1 of
        1:
          begin
            inc(pc.Rstr);
            pc.str := pc.Rstr;
            AddMsg('$�� ����{/a} �������.$', 0);
            Apply;
          end;
        2:
          begin
            inc(pc.Rdex);
            pc.dex := pc.Rdex;
            AddMsg('$�� ����{/a} ����� ����{��/��}.$', 0);
            Apply;
          end;
        3:
          begin
            inc(pc.Rint);
            pc.int := pc.Rint;
            AddMsg('$�� ����{/a} �����.$', 0);
            Apply;
          end;
      end;
    end;
  end;
  AddMsg('', 0);
  pc.Rhp := pc.Rhp + Round(pc.Rhp / 4);
end;

{ ������� ����� ����� ��� ���������� ������ }
function Tpc.ExpToNxtLvl: integer;
begin
  Result := Round((explevel * 20) - (int / 1.5));
end;

{ ���� �������� � ��������� }
procedure Tpc.UseMenu;
begin
  with GScreen.Canvas do
  begin
    DrawBorder(75, 2, 20, HOWMANYVARIANTS + 1, crLIGHTGRAY);
    Font.color := cBROWN;
    TextOut(77 * CharX, 3 * CharY, '[ ]');
    Font.color := cWHITE;
    if LastGameState = gsEQUIPMENT then
      // � ����������
      TextOut(81 * CharX, 3 * CharY, '� ���������')
    else
      // � ���������
      TextOut(81 * CharX, 3 * CharY, whattodo(ItemsData[pc.inv[MenuSelected].id].vid));
    Font.color := cBROWN;
    TextOut(77 * CharX, 4 * CharY, '[ ]');
    Font.color := cWHITE;
    TextOut(81 * CharX, 4 * CharY, '�����������');
    Font.color := cBROWN;
    TextOut(77 * CharX, 5 * CharY, '[ ]');
    Font.color := cWHITE;
    TextOut(81 * CharX, 5 * CharY, '�������');
    Font.color := cBROWN;
    TextOut(77 * CharX, 6 * CharY, '[ ]');
    Font.color := cWHITE;
    TextOut(81 * CharX, 6 * CharY, '������');
    Font.color := cBROWN;
    TextOut(77 * CharX, 7 * CharY, '[ ]');
    Font.color := cRED;
    TextOut(81 * CharX, 7 * CharY, '��������');
    Font.color := cYELLOW;
    TextOut(78 * CharX, (2 + MenuSelected2) * CharY, '*');
  end;
end;

{ �������� ����� ������ ����� }
procedure Tpc.AfterDeath;
begin
  AddMsg('*�� ����{/�a}!!!*', 0);
  Apply;
  ChangeGameState(gsINTRO);
end;

{ ����� ������ � �������� }
function Tpc.FindCoins: byte;
var
  i: byte;
begin
  Result := 0;
  for i := 1 to MaxHandle do
    if pc.inv[i].id = idCOIN then
    begin
      Result := i;
      break;
    end;
end;

function Tpc.getGold: word;
var
  slot: byte;
begin
  slot := FindCoins();
  if (slot = 0) then
    Result := 0
  else
    Result := inv[slot].amount;
end;

function Tpc.removeGold(amount: word): boolean;
var
  slot: byte;
begin
  slot := FindCoins();
  if (slot = 0) then
    Result := FALSE
  else if (inv[slot].amount >= amount) then
  begin
    dec(inv[slot].amount, amount);
    Result := TRUE;
    RefreshInventory;
  end
  else
    Result := FALSE;
end;

{ ������ }
procedure Tpc.Search;
var
  A, B: integer;
begin
  for A := pc.x - 1 to pc.x + 1 do
    for B := pc.y - 1 to pc.y + 1 do
      if (A > 0) and (A <= MapX) and (B > 0) and (B <= MapY) then
        if (M.Tile[A, B] = tdSECSTONE) or (M.Tile[A, B] = tdSECEARTH) then
          if Random(8 - pc.Ability[abATTENTION]) + 1 = 1 then
          begin
            M.Tile[A, B] := tdCDOOR;
            AddMsg('$�� ���{��/�a} ��������� �����!$', 0);
            More;
          end;
end;

{ ���� �� ���� ���� ������� ����� ����? }
function Tpc.HaveItemVid(vid: byte): boolean;
var
  i: byte;
  f: boolean;
begin
  f := FALSE;
  for i := 1 to ItemsAmount do
    if ItemsData[inv[i].id].vid = vid then
    begin
      f := TRUE;
      break;
    end;
  Result := f;
end;

{ ������� ������ ������� �������� ��� }
procedure Tpc.CreateClWList;
var
  i, k: byte;
begin
  // ������� ������
  for i := 1 to CLOSEFIGHTAMOUNT do
    wlist[i] := 0;
  k := 0;
  for i := 2 to CLOSEFIGHTAMOUNT do
    if pc.closefight[i] > 0 then
    begin
      inc(k);
      wlist[k] := i;
    end;
  wlistsize := k;
end;

{ ������� ������ ������� �������� ��� }
procedure Tpc.CreateFrWList;
var
  i, k: byte;
begin
  // ������� ������
  for i := 1 to FARFIGHTAMOUNT do
    wlist[i] := 0;
  k := 0;
  for i := 2 to FARFIGHTAMOUNT do
    if pc.farfight[i] > 0 then
    begin
      inc(k);
      wlist[k] := i;
    end;
  wlistsize := k;
end;

{ �������� ����� ����� ��������� � ����. ����������� �� }
procedure Tpc.WriteAboutInvMass;
var
  weight: string;
  tx, ty: word;
begin
  with GScreen.Canvas do
  begin
    Font.color := cLIGHTGRAY;
    weight := '����� ���� ���������: ' + FloatToStr(invmass) + ' ������������ �����: ' + FloatToStr(maxmass);
    tx := (15 + ((70 - length(weight)) div 2)) * CharX;
    ty := 35 * CharY;
    TextOut(tx, ty, weight);
    if (ShowBars = 1) then
    begin
      Pen.color := cGRAY;
      Pen.Width := 9;
      inc(ty, CharY);
      MoveTo(tx + 4, ty + CharY div 2);
      LineTo(tx + 4 + (length(weight) - 1) * CharX, ty + CharY div 2);
      if (invmass > 0) then
      begin
        Pen.color := cBROWN;
        MoveTo(tx + 4, ty + CharY div 2);
        LineTo(tx + 4 + BarWidth(Round(invmass), Round(maxmass), (length(weight) - 1) * CharX), ty + CharY div 2);
      end;
    end;
  end;
end;

{ ����� � ����� ������������ Mode - 1 ��������, 2 ������ }
procedure Tpc.PrepareShooting(B, A: TItem; Mode: byte);
var
  i: byte;
  MayShoot: boolean;
begin
  MayShoot := TRUE;
  ShootingMode := Mode;
  Bow := B;
  Arrow := A;
  // ���� ��������
  if Mode = 1 then
  begin
    MenuSelected := 13;
    if (Arrow.id = 0) then
    begin
      MayShoot := FALSE;
      AddMsg('���� �������� � ���������� ����!', 0);
    end
    else if (Bow.id = 0) and (Arrow.id <> idLITTLEROCK) then
    begin
      MayShoot := FALSE;
      AddMsg('� ���������� �� ������� ������ ��� ��������!', 0);
    end
    else if (ItemsData[Bow.id].kind <> ItemsData[Arrow.id].kind) and (Bow.id <> 0) then
    begin
      MayShoot := FALSE;
      AddMsg(ItemsData[Bow.id].name2 + ' � ' + ItemsData[Arrow.id].name1 + ' - �� ����������!', 0);
    end;
  end;
  if MayShoot then
  begin
    // �������������
    AddMsg('$�������� �:$', 0);
    i := pc.SearchForAliveField;
    if autoaim > 0 then
      if (M.Saw[M.MonL[autoaim].x, M.MonL[autoaim].y] = 2) and (M.MonL[autoaim].id > 0) then
        i := autoaim;
    if i > 0 then
    begin
      lx := M.MonL[i].x;
      ly := M.MonL[i].y;
      pc.AnalysePlace(lx, ly, 1);
      ChangeGameState(gsAIM);
    end
    else
    begin
      lx := pc.x;
      ly := pc.y;
      pc.AnalysePlace(lx, ly, 1);
      ChangeGameState(gsAIM);
    end;
  end;
end;

{ ��������� ����� }
procedure Tpc.Randommy;
begin
  gender := Rand(1, 2); // ���
  if YourName = '' then // ���
  begin
    case gender of
      genMALE:
        name := GenerateName(FALSE);
      genFEMALE:
        name := GenerateName(TRUE);
    end;
  end
  else
    pc.name := YourName;
  atr[1] := Rand(1, 3); // ��������
  atr[2] := Rand(1, 3);
  // �������� ���� ������ ������ �� ������
  Prepare;
  PrepareSkills;
  if (HowManyBestWPNCL > 1) and not((HowManyBestWPNCL < 3) and (OneOfTheBestWPNCL(CLOSE_TWO))) then
  begin
    CreateClWList;
    c_choose := wlist[Random(wlistsize) + 1];
  end;
  if (HowManyBestWPNFR > 1) and not((HowManyBestWPNFR < 3) and (OneOfTheBestWPNFR(FAR_THROW))) then
  begin
    CreateFrWList;
    f_choose := wlist[Random(wlistsize) + 1];
  end;
end;

{ ���� � ����������� � ����� (���, ���, ���� � ��) }
procedure Tpc.HeroInfoWindow;
begin
  StartDecorating('<-� �����->', FALSE);
  with GScreen.Canvas do
  begin
    AddTextLine(3, 2, pc.name);
    AddTextLine(3, 3, pc.ClName(1));
  end;
end;

end.
