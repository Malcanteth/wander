unit map;

interface

uses
  SysUtils, Cons, Main, Player, Tile, Monsters, Utils, Items, Flags, Windows, Graphics, Math;

type
  { ��������� ����� }
  TMap = object
    Special: byte; // ������� ����. �����
    name: string[17]; // ��� �����
    tip: byte; // ��� ������
    Tile: array [1 .. MapX, 1 .. MapY] of byte; // �����
    Blood: array [1 .. MapX, 1 .. MapY] of byte; // �����
    Saw: array [1 .. MapX, 1 .. MapY] of byte; // ���� �� ������ ������
    MemS: array [1 .. MapX, 1 .. MapY] of string[1]; // ���������� ������ (������)
    MemC: array [1 .. MapX, 1 .. MapY] of byte; // ���������� ������ (����)
    MemBC: array [1 .. MapX, 1 .. MapY] of byte; // ���������� ������ (���)
    MonL: array [1 .. 255] of TMonster; // ������ �������� �� ������
    MonP: array [1 .. MapX, 1 .. MapY] of byte; // ��������� �� �������
    Item: array [1 .. MapX, 1 .. MapY] of TItem; // ��������
  public
    procedure Clear; // �������� �����
    procedure DrawScene; // ������� �����
    function GenerateCave(vid: byte; down: boolean): boolean; // ��������� ����������
    function Save: boolean; // ���������
    function Load(l, e, d: byte): boolean; // ���������
    function DungeonType: byte; // ������ ���� ������� �������
    procedure MakeSpMap(n: byte); // ������� ����������� �����
  end;

var
  DungeonModeMapName: string[20] = '';
  M: TMap;
  FlyX, FlyY: byte;
  FlyS: string[1];
  FlyC: byte;

implementation

uses
  MapEditor, conf, mbox;

{ �������� ����� }
procedure TMap.Clear;
begin
  FillMemory(@M, SizeOf(TMap), 0);
end;

{ ������� ����� }
procedure TMap.DrawScene;
var
  x, y, i: integer;
  color, back: longword;
  char: string[1];
  dx, dy, sx, sy, check, e: integer;
  onway: boolean;
begin
  with GScreen.Canvas do
  begin
    Font.name := FontMap;
    for x := 1 to MapX do
      for y := 1 to MapY do
      begin
        color := 255;
        back := 0;
        if M.Saw[x, y] > 0 then
        begin
          // ����
          case M.Blood[x, y] of
            0:
              color := RealColor(TilesData[M.Tile[x, y]].color);
            1:
              color := cLIGHTRED;
            2:
              color := cRED;
          end;
          char := TilesData[M.Tile[x, y]].char;
          back := Darker(RealColor(TilesData[M.Tile[x, y]].color), 92);
          // ��������
          if M.Item[x, y].id > 0 then
          begin
            color := RealColor(ItemColor(M.Item[x, y]));
            char := ItemTypeData[ItemsData[M.Item[x, y].id].vid].symbol;
          end;
          // �������
          if M.MonP[x, y] > 0 then
          begin
            if M.MonP[x, y] = 1 then
            begin
              color := RealColor(pc.ClassColor);
              char := '@';
              if pc.tactic > 0 then
                back := pc.ColorOfTactic;
              if pc.felldown then
                color := cGRAY;
              if pc.underhit then
              begin
                case Random(2) + 1 of
                  1:
                    color := cLIGHTRED;
                  2:
                    color := cRED;
                end;
                pc.underhit := FALSE;
              end;
            end
            else
            begin
              color := RealColor(M.MonL[M.MonP[x, y]].ClassColor);
              if (M.MonL[M.MonP[x, y]].relation = 1) and (M.MonL[M.MonP[x, y]].tactic > 0) then
                back := M.MonL[M.MonP[x, y]].ColorOfTactic;
              if M.MonL[M.MonP[x, y]].felldown then
                color := cGRAY;
              char := MonstersData[M.MonL[M.MonP[x, y]].id].char;
              if M.MonL[M.MonP[x, y]].underhit then
              begin
                case Random(2) + 1 of
                  1:
                    color := cLIGHTRED;
                  2:
                    color := cRED;
                end;
                M.MonL[M.MonP[x, y]].underhit := FALSE;
              end;
            end;
          end;
          // ������ ���������
          if (GameState = gsLook) and (x = lx) and (y = ly) then
            back := MyRGB(140, 140, 255);
          // ������ �������
          if (GameState = gsAim) and (x = lx) and (y = ly) then
            back := MyRGB(140, 0, 0);
          // �������� ������
          if (FlyX = x) and (FlyY = y) then
          begin
            char := FlyS;
            color := RealColor(FlyC);
          end;
          // ���� ����� ���� �������, �� ������� ������
          if M.Saw[x, y] = 1 then
          begin
            char := M.MemS[x, y];
            color := Darker(RealColor(M.MemC[x, y]), 60);
            back := Darker(RealColor(M.MemBC[x, y]), 95);
          end;
        end
        else
        begin
          char := ' ';
          color := 0;
        end;
        // ������� ������
        Font.color := color;
        Brush.color := back;
        TextOut((x - 1) * CharX, (y - 1) * CharY, char);
      end;
    // ����-����
    for x := pc.x - pc.los to pc.x + pc.los do
      for y := pc.y - pc.los to pc.y + pc.los do
        if (x > 0) and (x <= MapX) and (y > 0) and (y <= MapY) then
        begin
          // ����-���
          if (M.Saw[x, y] = 2) and (M.MonP[x, y] > 0) then
            if (M.MonL[M.MonP[x, y]].relation = 1) or ((ShowPCBar = 1) and (x = pc.x) and (y = pc.y)) then
            begin
              Pen.color := cGRAY;
              Pen.Width := 3;
              MoveTo((x - 1) * CharX + 1, (y - 1) * CharY - 2);
              LineTo((x) * CharX - 1, (y - 1) * CharY - 2);
              Pen.color := cLIGHTRED;
              MoveTo((x - 1) * CharX + 1, (y - 1) * CharY - 2);
              if M.MonP[x, y] = 1 then
              begin
                if pc.Hp > 0 then
                  LineTo((x - 1) * CharX + 1 + Round((pc.Hp * (CharX - 2)) / pc.RHp), (y - 1) * CharY - 2);
              end
              else if M.MonL[M.MonP[x, y]].Hp > 0 then
                LineTo((x - 1) * CharX + 1 + Round((M.MonL[M.MonP[x, y]].Hp * (CharX - 2)) / M.MonL[M.MonP[x, y]].RHp), (y - 1) * CharY - 2);
            end;
        end;
    Font.name := FontMsg;
    // ���� ����� ������������
    if (GameState = gsAim) and NOT((pc.x = lx) and (pc.y = ly)) then
    begin
      dx := abs(pc.x - lx);
      dy := abs(pc.y - ly);
      sx := Sign(lx - pc.x);
      sy := Sign(ly - pc.y);
      x := pc.x;
      y := pc.y;
      check := 0;
      onway := FALSE;
      if dy > dx then
      begin
        dx := dx + dy;
        dy := dx - dy;
        dx := dx - dy;
        check := 1;
      end;
      e := 2 * dy - dx;
      for i := 0 to dx - 2 do
      begin
        if e >= 0 then
        begin
          if check = 1 then
            x := x + sx
          else
            y := y + sy;
          e := e - 2 * dx;
        end;
        if check = 1 then
          y := y + sy
        else
          x := x + sx;
        e := e + 2 * dy;
        if onway then
          Font.color := cRED
        else
          Font.color := cYELLOW;
        Brush.Style := bsClear;
        TextOut((x - 1) * CharX, (y - 1) * CharY, '*');
        // � ������ ��������� �� ������������ � ���� ��� ���� �������� ��� ������� ������
        if (not TilesData[M.Tile[x, y]].void) or (M.MonP[x, y] > 0) then
          inc(onway);
      end;
    end;
  end;
end;

{ ��������� ���������� }
function TMap.GenerateCave(vid: byte; down: boolean): boolean;
type
  TRoom = record
    exists: boolean;
    x1, y1, x2, y2: byte;
    doorx: array [1 .. MaxDoors] of byte;
    doory: array [1 .. MaxDoors] of byte;
  end;
var
  x, y, i, j, r, q, ACounter, BCounter, a, b, d: byte;
  Room: array [1 .. MaxRooms + 1] of TRoom;
  find: boolean;
  MaxRoomsAmount: integer;
  FloorTile, WallTile: byte;
  // ����� �� ����� ���� �������?
  function CheckBounds: boolean;
  var
    x, y: integer;
  begin
    CheckBounds := TRUE;
    for x := Room[j].x1 - 2 to Room[j].x2 + 2 do
      for y := Room[j].y1 - 2 to Room[j].y2 + 2 do
        if (x < 1) or (y < 1) or (x >= MapX) or (y >= MapY) then
        begin
          CheckBounds := FALSE;
          exit;
        end
        else if M.Tile[x, y] <> tdEMPTY then
        begin
          CheckBounds := FALSE;
          exit;
        end;
  end;
// ����� �� ����� ���� �����?
  function CanDoor(x, y: byte): boolean;
  var
    x2, y2: byte;
  begin
    CanDoor := TRUE;
    if TilesData[M.Tile[x, y]].move then
      CanDoor := FALSE
    else
    begin
      for x2 := x - 1 to x + 1 do
        for y2 := y - 1 to y + 1 do
          if M.Tile[x2, y2] = tdCDoor then
          begin
            CanDoor := FALSE;
            exit;
          end;
    end;
  end;
// ��������� �������
  procedure BuildRoom;
  var
    x, y: word;
  begin
    Room[j].exists := TRUE;
    for x := Room[j].x1 to Room[j].x2 do
      for y := Room[j].y1 to Room[j].y2 do
        if (x = Room[j].x1) or (x = Room[j].x2) or (y = Room[j].y1) or (y = Room[j].y2) then
          M.Tile[x, y] := WallTile
        else
          M.Tile[x, y] := FloorTile;
  end;
// ���������� ������. ������ #1 (��� ���������� �����������)
  procedure FreePassage;
  var
    i, k, r, bx, by, a, aimx, aimy: byte;
  begin
    for i := 1 to MaxRooms do
    begin
      if Room[i].exists then
      begin
        for k := 1 to MaxDoors do
        begin
          // ���� ����� ���������� (������ ������!)}
          if (Room[i].doorx[k] > 0) and (Room[i].doory[k] > 0) then
          begin
            // ���� ��� ������ ����� � ������ ������� - �� ���������, �����
            // ��������� �� ��������� ��������, ����� - ��������� �� ���������
            if (k = 1) and (Room[i + 1].exists) then
              r := i + 1
            else
              repeat
                r := Random(MaxRooms) + 1;
              until (r <> i) and (Room[r].exists);
            // ������ ������
            bx := Room[i].doorx[k];
            by := Room[i].doory[k];
            // ����� ����� � ������� ������� ����� ���������
            repeat
              a := Random(MaxDoors) + 1;
            until (Room[r].doorx[a] > 0) and (Room[r].doory[a] > 0);
            // ����� ������
            aimx := Room[r].doorx[a];
            aimy := Room[r].doory[a];
            // ������ ������
            while (bx <> aimx) or (by <> aimy) do
            begin
              if bx < aimx then
                inc(bx)
              else if bx > aimx then
                dec(bx)
              else if by < aimy then
                inc(by)
              else if by > aimy then
                dec(by);
              if (M.Tile[bx, by] <> tdUSTAIRS) and (M.Tile[bx, by] <> tdDSTAIRS) then
                M.Tile[bx, by] := FloorTile;
            end;
          end;
        end;
      end;
    end;
  end;
// ���������� ������. ������ #2 (� ����������� �����������)
  function TunnelPassage: boolean;
  var
    x, y, i, k, bx, by, aimx, aimy, turn: byte;
    z: integer;
    dx, dy: shortint;
    move: array [1 .. MapX, 1 .. MapY] of boolean;
    // �������������
    procedure MoveTo(x, y: byte);
    begin
      if (move[x, y] = FALSE) and (not((x = aimx) and (y = aimy))) then
      begin
        if bx <> x then
        begin
          if dy = 0 then
          begin
            if aimy < by then
              dy := -1
            else if aimy > by then
              dy := 1
            else
            begin
              if move[x, by - 1] = TRUE then
                dy := -1
              else if move[x, by + 1] = TRUE then
                dy := 1
              else
                dy := 1;
            end;
          end;
          by := by + dy;
        end
        else if by <> y then
        begin
          if dx = 0 then
          begin
            if aimx < bx then
              dx := -1
            else if aimx > bx then
              dx := 1
            else
            begin
              if move[bx - 1, y] = TRUE then
                dx := -1
              else if move[bx + 1, y] = TRUE then
                dx := 1
              else
                dx := 1;
            end;
          end;
          bx := bx + dx;
        end;
      end
      else if (move[x, y] = TRUE) or ((x = aimx) and (y = aimy)) then
      begin
        if by <> y then
          dx := 0;
        if bx <> x then
          dy := 0;
        bx := x;
        by := y;
      end;
      if M.Tile[bx, by] <> tdCDoor then
        M.Tile[bx, by] := FloorTile;
    end;

  begin
    Result := TRUE;
    // ��������� ������ ������������
    for x := 1 to MapX do
      for y := 1 to MapY do
        if M.Tile[x, y] = tdEMPTY then
          move[x, y] := TRUE
        else
          move[x, y] := FALSE;
    // �������� ���� ������
    for i := 1 to MaxRooms do
    begin
      if Room[i].exists then
      begin
        dx := 0;
        dy := 0;
        turn := 1;
        // ��������� ��� �����
        for k := 1 to MaxDoors do
        begin
          // ���� ����� ���������� (������ ������!)}
          if (Room[i].doorx[k] > 0) and (Room[i].doory[k] > 0) then
          begin
            // ���� ��� ������ ����� � ������ ������� - �� ���������, �����
            // ��������� �� ��������� ��������, ����� - ��������� �� ���������
            if (k = 1) and (Room[i + 1].exists) then
              r := i + 1
            else
              repeat
                r := Random(MaxRooms) + 1;
              until (r <> i) and (Room[r].exists);
            // ������ ������
            bx := Room[i].doorx[k];
            by := Room[i].doory[k];
            if move[bx - 1, by] then
              bx := bx - 1
            else if move[bx + 1, by] then
              bx := bx + 1
            else if move[bx, by - 1] then
              by := by - 1
            else if move[bx, by + 1] then
              by := by + 1;
            M.Tile[bx, by] := FloorTile;
            // ����� ����� � ������� ������� ����� ���������
            repeat
              a := Random(MaxDoors) + 1;
            until (Room[r].doorx[a] > 0) and (Room[r].doory[a] > 0);
            // ����� ������
            aimx := Room[r].doorx[a];
            aimy := Room[r].doory[a];
            // ������ ������
            z := 0;
            while (z < 200) do
            begin
              if turn = 1 then
              begin
                if bx < aimx then
                  MoveTo(bx + 1, by)
                else if bx > aimx then
                  MoveTo(bx - 1, by);
                if bx = aimx then
                  turn := 2;
              end
              else
              begin
                if by < aimy then
                  MoveTo(bx, by + 1)
                else if by > aimy then
                  MoveTo(bx, by - 1);
                if by = aimy then
                  turn := 1;
              end;
              inc(z);
            end;
            if (aimx = bx) and (aimy = by) then
              Result := TRUE
            else
              Result := FALSE;
          end;
        end;
      end;
    end;
  end;
// �������� ��������� �����
  procedure Changes;
  var
    x, y: byte;
  begin
    for x := 1 to MapX do
      for y := 1 to MapY do
      begin
        // �������� ������ ���� �� �����
        if M.Tile[x, y] = tdEMPTY then
          M.Tile[x, y] := WallTile;
        // �������� �������� ����� �� �������� ��� ���������... ��� ��������
        if M.Tile[x, y] = tdCDoor then
          case Random(100) + 1 of
            1 .. 35:
              M.Tile[x, y] := tdODOOR;
            36 .. 40:
              case WallTile of
                tdROCK:
                  M.Tile[x, y] := tdSECSTONE;
                tdEWALL:
                  M.Tile[x, y] := tdSECEARTH;
              end;
          end;
      end;
  end;
// ������� �����
  procedure MakeRuins;
  const
    Side = -1;
  var
    x, y, c: byte;
  begin
    // �������������
    c := Random(8) + 1;
    for x := 4 to MapX - 4 do
      for y := 5 to MapY - 5 do
        if (Random(c) + 1 = 1) and (M.Tile[x, y] <> tdEMPTY) then
          case Random(2) + 1 of
            1:
              begin { #1 }
                M.Tile[x, y] := FloorTile;
                M.Tile[x + Side, y] := FloorTile;
                M.Tile[x + 2 * Side, y] := FloorTile;
                M.Tile[x, y + Side] := FloorTile;
                M.Tile[x, y + 2 * Side] := FloorTile;
                M.Tile[x, y + 3 * Side] := FloorTile;
              end;
            2:
              begin { #2 }
                M.Tile[x, y] := FloorTile;
                M.Tile[x + Side, y] := FloorTile;
                M.Tile[x - Side, y] := FloorTile;
                M.Tile[x, y + Side] := FloorTile;
                M.Tile[x, y - Side] := FloorTile;
              end;
          end;
  end;
// ��������� ��������
  procedure PlaceLadders;
  var
    a, c, d: byte;
  begin
    for a := 1 to 2 do
    begin
      repeat
        c := Random(MapX) + 1;
        d := Random(MapY) + 1;
      until M.Tile[c, d] = FloorTile;
      if a = 1 then
      begin
        if down then
          M.Tile[c, d] := tdDSTAIRS;
      end
      else
        M.Tile[c, d] := tdUSTAIRS;
    end;
  end;
// ��������� ��������
{ TODO -oBMT -c������� : ��� ��������� ������� ���������� ��������� }
  procedure PlaceMonsters;
  var
    x, y, i: byte;
  begin
    for x := 1 to MapX do
      for y := 1 to MapY do
        if (M.Tile[x, y] = FloorTile) then
          if Random(75) + 1 = 1 then
          begin
            repeat
              i := Random(MonstersAmount) + 1;
            until (not IsFlag(MonstersData[i].Flags, M_NEUTRAL)) and
              ((SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].CoolLevel >= MonstersData[i].CoolLevel) or
              ((SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].CoolLevel = MonstersData[i].CoolLevel + 1) and (Random(10) + 1 = 10)));
            CreateMonster(i, x, y);
          end;
  end;
// ��������� ��������
  procedure PlaceItems;
  var
    x, y, t: byte;
  begin
    for x := 1 to MapX do
      for y := 1 to MapY do
        if (M.Tile[x, y] = FloorTile) and (Random(200) + 1 = 1) then
        begin
          repeat
            t := Random(ItemTypeAmount) + 1;
          until (ItemTypeData[t].chance >= Random(100) + 1) and (HaveItemTypeInDB(t));
          PutItem(x, y, GenerateItem(t), Random(ItemTypeData[t].maxamount) + 1);
        end;
  end;

begin
  Result := TRUE;
  // ���� �� �������� ����������� ������
  repeat
    Clear;
    // ��� ������
    if vid = 0 then
      M.tip := Random(TipsAmount) + 1
    else
      M.tip := vid;
    // ��� ���� � ����
    case Random(3) + 1 of
      1:
        FloorTile := tdFLOOR;
      2:
        FloorTile := tdGRASS;
      3:
        FloorTile := tdEARTH;
    end;
    case Random(3) + 1 of
      1:
        WallTile := tdROCK;
      2:
        WallTile := tdEWALL;
      3:
        WallTile := tdGREENWALL;
    end;
    // ������������ ����������� ������
    case M.tip of
      tipRooms:
        MaxRoomsAmount := 10 + Random(180);
      tipDestr:
        MaxRoomsAmount := 130 + Random(40);
      tipRuins:
        MaxRoomsAmount := 130 + Random(40);
      tipRuLab:
        MaxRoomsAmount := 100;
      tipDRoom:
        MaxRoomsAmount := 130 + Random(40);
    else
      MaxRoomsAmount := 100;
    end;
    // �������� ���� ������
    for i := 1 to MaxRooms + 1 do
      with Room[i] do
      begin
        exists := FALSE;
        x1 := 0;
        y1 := 0;
        x2 := 0;
        y2 := 0;
        for q := 1 to MaxDoors do
        begin
          doorx[q] := 0;
          doory[q] := 0;
        end;
      end;
    // �����
    for x := 1 to MapX do
    begin
      M.Tile[x, 1] := WallTile;
      M.Tile[x, MapY] := WallTile;
    end;
    for y := 1 to MapY do
    begin
      M.Tile[1, y] := WallTile;
      M.Tile[MapX, y] := WallTile;
    end;
    // ���������� ������
    j := 1;
    for i := 1 to MaxRoomsAmount do
    begin
      // ���� ������ ��������, �� ������� - �����
      if M.tip = tipRuLab then
      begin
        // ���������� �����
        with Room[j] do
        begin
          x1 := Random(MapX - 1) + 2;
          y1 := Random(MapY - 1) + 2;
        end;
        if M.Tile[Room[j].x1, Room[j].y1] = tdEMPTY then
        begin
          Room[j].exists := TRUE;
          M.Tile[Room[j].x1, Room[j].y1] := WallTile;
          Room[j].doorx[1] := Room[j].x1;
          Room[j].doory[1] := Room[j].y1;
        end;
      end
      else
      begin
        // ������ �������
        with Room[j] do
        begin
          x1 := Random(MapX - MinWidth) + 2;
          y1 := Random(MapY - MinHeight) + 2;
          x2 := Random(MaxWidth - MinWidth) + MinWidth + x1;
          y2 := Random(MaxHeight - MinHeight) + MinHeight + y1;
        end;
        // ���� ������� �������, �� ������ ��
        if CheckBounds then
          BuildRoom
        else
          Continue;
        // ���� �����
        r := 1;
        d := 0;
        for q := 1 to MaxDoors do
        begin
          if Random(100) + 1 <= 100 / q then
          begin
            BCounter := 0;
            find := FALSE;
            repeat
              ACounter := 0;
              a := 1;
              b := 1;
              // �������
              case Random(MaxRooms) + 1 of
                1: // ����
                  if d <> 1 then
                  begin
                    repeat
                      a := Random((Room[j].x2 - 1) - (Room[j].x1 + 1)) + (Room[j].x1 + 1);
                      b := Room[j].y1;
                      inc(ACounter);
                    until (CanDoor(a, b) = TRUE) or (ACounter = 20);
                    if ACounter < 20 then
                    begin
                      d := 1;
                      find := TRUE;
                    end;
                  end;
                2: // ���
                  if d <> 2 then
                  begin
                    repeat
                      a := Random((Room[j].x2 - 1) - (Room[j].x1 + 1)) + (Room[j].x1 + 1);
                      b := Room[j].y2;
                      inc(ACounter);
                    until (CanDoor(a, b) = TRUE) or (ACounter = 20);
                    if ACounter < 20 then
                    begin
                      d := 2;
                      find := TRUE;
                    end;
                  end;
                3: // ����
                  if d <> 3 then
                  begin
                    repeat
                      a := Room[j].x1;
                      b := Random((Room[j].y2 - 1) - (Room[j].y1 + 1)) + Room[j].y1 + 1;
                      inc(ACounter);
                    until (CanDoor(a, b) = TRUE) or (ACounter = 20);
                    if ACounter < 20 then
                    begin
                      d := 3;
                      find := TRUE;
                    end;
                  end;
                4: // �����
                  if d <> 4 then
                  begin
                    repeat
                      a := Room[j].x2;
                      b := Random((Room[j].y2 - 1) - (Room[j].y1 + 1)) + Room[j].y1 + 1;
                      inc(ACounter);
                    until (CanDoor(a, b) = TRUE) or (ACounter = 20);
                    if ACounter < 20 then
                    begin
                      d := 4;
                      find := TRUE;
                    end;
                  end;
              end;
              inc(BCounter);
            until (BCounter = 200) or (find);
            if BCounter = 200 then
            begin
              Result := FALSE;
              exit;
            end;
            if find then
            begin
              if M.tip = tipRooms then
                M.Tile[a, b] := tdCDoor
              else
                M.Tile[a, b] := FloorTile;
              Room[j].doorx[r] := a;
              Room[j].doory[r] := b;
              inc(r);
            end
            else
            begin
              Room[j].doorx[q] := 0;
              Room[j].doory[q] := 0;
            end;
          end;
        end;
      end;
      inc(j);
      // �������� ���� - ���� ������� ����� ������
      if j = MaxRooms then
        break;
    end;
  until j >= MinRooms;
  case M.tip of
    tipRooms:
      begin
        PlaceLadders;
        Result := TunnelPassage;
      end;
    tipDestr:
      begin
        PlaceLadders;
        FreePassage;
      end;
    tipRuins:
      begin
        FreePassage;
        MakeRuins;
        PlaceLadders;
      end;
    tipRuLab:
      begin
        FreePassage;
        MakeRuins;
        PlaceLadders;
      end;
    tipDRoom:
      begin
        MakeRuins;
        FreePassage;
        PlaceLadders;
      end;
  end;
  Changes;
  PlaceMonsters;
  PlaceItems;
end;

{ ��������� }
function TMap.Save: boolean;
var
  f: file;
  x, y, k, l: byte;
begin
  CreateDir('swap');
  CreateDir('swap/' + pc.name);
  AssignFile(f, 'swap/' + pc.name + '/' + IntToStr(pc.level) + '_' + IntToStr(pc.enter) + '_' + IntToStr(pc.depth) + '.lev');
{$I-}
  Rewrite(f, 1);
  BlockWrite(f, name, SizeOf(name));
  BlockWrite(f, Special, SizeOf(Special));
  // ������ ���������
  for x := 1 to MapX do
    for y := 1 to MapY do
      if M.Saw[x, y] = 2 then
        M.Saw[x, y] := 1;
  // �������� ���������� � ������
  BlockWrite(f, Tile, SizeOf(Tile));
  BlockWrite(f, Blood, SizeOf(Blood));
  BlockWrite(f, Saw, SizeOf(Saw));
  BlockWrite(f, MemS, SizeOf(MemS));
  BlockWrite(f, MemC, SizeOf(MemC));
  BlockWrite(f, MemBC, SizeOf(MemBC));
  // ���������� ��������
  for x := 2 to 255 do
  begin
    if MonL[x].id = 0 then
      l := 0
    else
      l := 1;
    BlockWrite(f, l, SizeOf(l));
    if l = 1 then
      BlockWrite(f, MonL[x], SizeOf(MonL[x]));
  end;
  // ���������� ��������� �� ��������
  BlockWrite(f, MonP, SizeOf(MonP));
  // ��������
  BlockWrite(f, Item, SizeOf(Item));
  CloseFile(f);
{$I+}
  if IOResult <> 0 then
    Result := FALSE
  else
    Result := TRUE;
end;

{ ��������� }
function TMap.Load(l, e, d: byte): boolean;
var
  f: file;
  x, k, j: byte;
begin
  AssignFile(f, 'swap/' + pc.name + '/' + IntToStr(pc.level) + '_' + IntToStr(pc.enter) + '_' + IntToStr(pc.depth) + '.lev');
{$I-}
  Reset(f, 1);
{$I+}
  if IOResult = 0 then
  begin
    Result := TRUE;
    M.Clear;
    BlockRead(f, name, SizeOf(name));
    BlockRead(f, Special, SizeOf(Special));
    // ��������� ���������� � ������
    BlockRead(f, Tile, SizeOf(Tile));
    BlockRead(f, Blood, SizeOf(Blood));
    BlockRead(f, Saw, SizeOf(Saw));
    BlockRead(f, MemS, SizeOf(MemS));
    BlockRead(f, MemC, SizeOf(MemC));
    BlockRead(f, MemBC, SizeOf(MemBC));
    // �������� ������ ���������
    for x := 2 to 255 do
    begin
      BlockRead(f, j, SizeOf(j));
      if j = 1 then
        BlockRead(f, MonL[x], SizeOf(MonL[x]));
    end;
    // ������ ��������� �� ��������
    BlockRead(f, MonP, SizeOf(MonP));
    // ��������
    BlockRead(f, Item, SizeOf(Item));
    CloseFile(f);
  end
  else
    Result := FALSE;
end;

{ ������ ���� ������� ������� }
function TMap.DungeonType: byte;
begin
  Result := 0;
  // �������
  if pc.level = 1 then
  begin
    // ���������
    if pc.enter = 1 then
      case pc.depth of
        1:
          Result := tipRooms;
        2:
          Result := tipDestr;
        3:
          Result := tipDRoom;
        4:
          Result := tipRuins;
      end;
  end;
end;

{ ������� ����������� ����� }
procedure TMap.MakeSpMap(n: byte);
var
  i, x, y: byte;
begin
  M.Clear;
  M := SpecialMaps[n].map;
  // ��������� �������� �����������
  for i := 1 to 255 do
    if M.MonL[i].id > 0 then
    begin
      for x := 1 to MapX do
        for y := 1 to MapY do
          if M.MonP[x, y] = i then
            FillMonster(i, M.MonL[i].id, x, y);
    end;
end;

end.
