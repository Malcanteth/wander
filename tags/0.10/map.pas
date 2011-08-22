unit map;

interface

uses
  SysUtils, Cons, Main, Player, Tile, Monsters, Utils, Items;

type
  { ��������� ����� }
  TMap = object
    tip  : byte;                                // ��� ������
    Tile : array [1..MapX,1..MapY] of byte;     // �����
    Blood: array [1..MapX,1..MapY] of byte;     // �����
    Saw  : array [1..MapX,1..MapY] of byte;     // ���� �� ������ ������
    Mem  : array [1..MapX,1..MapY] of string[1];// ���������� ������
    MonL : array [1..255] of TMonster;          // ������ �������� �� ������
    MonP : array [1..MapX,1..MapY] of byte;     // ��������� �� �������
    Item : array [1..MapX,1..MapY] of TItem;    // ��������
  public
    procedure Clear;                            // �������� �����
    procedure DrawScene;                        // ������� �����
    function GenerateCave(vid : byte;
                   down : boolean) : boolean;   // ��������� ����������
    function Save : boolean;                    // ���������
    function Load(l,e,d : byte) : boolean;      // ���������
    function DungeonType : byte;                // ������ ���� ������� �������
  end;

var
  M         : TMap;

implementation

{ �������� ����� }
procedure TMap.Clear;
var
  x, y : integer;
  i    : byte;
begin
  with M do
  begin
    for x:=1 to MapX do
      for y:=1 to MapY do
        begin
          Tile[x,y]   := tdEMPTY;
          Blood[x,y]  := 0;
          Saw[x,y]    := 0;
          Mem[x,y]    := '';
          MonP[x,y]   := 0;
          for i:=1 to 255 do
            MonL[i].id := 0;
          Item[x,y].id := 0;
        end;
  end;
end;

{ ������� ����� }
procedure TMap.DrawScene;
var
  x, y    : integer;
  color      : longword;
  char       : string[1];
begin
  for x:=1 to MapX do
    for y:=1 to MapY do
      with Screen.Canvas do
      begin
        color := 255;
        Brush.Color := 0;
        if M.Saw[x,y] > 0 then
        begin
          if (GameState = gsLook) and (x=lx) and (y=ly) then
            Brush.Color := MyRGB(140, 140, 255);
          // ����
          case M.Blood[x,y] of
            0 : color := TilesData[M.Tile[x,y]].color;
            1 : color := cLIGHTRED;
            2 : color := cRED;
          end;
          char := TilesData[M.Tile[x,y]].char;
          // ��������
          if M.Item[x,y].id > 0 then
          begin
            color := ItemsData[M.Item[x,y].id].color;
            char := ItemSymbol(M.Item[x,y].id);
          end;
          // �������
          if M.MonP[x,y] > 0 then
          begin
            if M.MonP[x,y] = 1 then
            begin
              color := cLIGHTBLUE;
              char := '@';
              if pc.felldown then color:= cGRAY;
            end else
              begin
                color := MonstersData[M.MonL[M.MonP[x,y]].id].color;
                if color = cRANDOM then
                  color := MyRGB(Random(155)+100, Random(155)+100, Random(155)+100);
                if M.MonL[M.MonP[x,y]].felldown then color:= cGRAY;
                char := MonstersData[M.MonL[M.MonP[x,y]].id].char;
              end;
          end;
         // ���� ����� ���� �������, �� ������� �����
          if M.Saw[x,y] = 1 then
          begin
            char := M.Mem[x,y];
            color := MyRGB(70,70,70);
          end;
        end else
          begin
            char := ' ';
            color := 0;
          end;
        // ������� ������
        Font.Color := color;
        TextOut((x-1)*CharX, (y-1)*CharY, char);
      end;
end;

{ ��������� ���������� }
function TMap.GenerateCave(vid : byte; down : boolean) : boolean;
type
  TRoom = record
    exists : boolean;
    x1,y1,x2,y2 : byte;
    doorx : array[1..MaxDoors] of byte;
    doory : array[1..MaxDoors] of byte;
  end;
var
  x,y,i,j,r,q,ACounter,BCounter,a,b,d : byte;
  Room                                : array [1..MaxRooms+1] of TRoom;
  find                                : boolean;
  MaxRoomsAmount                      : integer;
  FloorTile,WallTile                  : byte;
  // ����� �� ����� ���� �������?
  function CheckBounds : boolean;
  var
    x,y : integer;
  begin
    CheckBounds := TRUE;
    for x:=Room[j].x1-2 to Room[j].x2+2 do
      for y:=Room[j].y1-2 to Room[j].y2+2 do
        if (x<1)or(y<1)or(x>=MapX)or(y>=MapY)then begin CheckBounds := FALSE; exit; end else
          if M.tile[x,y] <> tdEMPTY then begin CheckBounds := FALSE; exit; end;
  end;
  //����� �� ����� ���� �����?
  function CanDoor(x,y : byte) : boolean;
  var
    x2,y2 : byte;
  begin
    CanDoor := true;
    if TilesData[M.Tile[x,y]].move then CanDoor := false else
    begin
      for x2:=x-1 to x+1 do
        for y2:=y-1 to y+1 do
          if M.tile[x2,y2] = tdCDoor then
          begin
            CanDoor := false;
            exit;
          end;
    end;
  end;
  //��������� �������
  procedure BuildRoom;
  var
    x,y : word;
  begin
    Room[j].exists := True;
    for x:=Room[j].x1 to Room[j].x2 do
      for y:=Room[j].y1 to Room[j].y2 do
        if (x=Room[j].x1)or(x=Room[j].x2)or(y=Room[j].y1)or(y=Room[j].y2) then
          M.tile[x,y] := WallTile else
            M.tile[x,y] := FloorTile;
  end;
  //���������� ������. ������ #1 (��� ���������� �����������)
  procedure FreePassage;
  var
    i,k,r,bx,by,a,aimx,aimy : byte;
  begin
    for i:=1 to MaxRooms do
    begin
      if Room[i].exists then
      begin
        for k:=1 to MaxDoors do
        begin
          // ���� ����� ���������� (������ ������!)}
          if (Room[i].doorx[k]>0)and(Room[i].doory[k]>0) then
          begin
            // ���� ��� ������ ����� � ������ ������� - �� ���������, �����
            // ��������� �� ��������� ��������, ����� - ��������� �� ���������
            if (k=1)and(Room[i+1].exists)then
              r := i + 1 else
                repeat
                  r := Random(MaxRooms)+1;
                until
                  (r<>i)and(Room[r].exists);
            // ������ ������
            bx := Room[i].doorx[k];
            by := Room[i].doory[k];
            // ����� ����� � ������� ������� ����� ���������
            repeat
              a := Random(MaxDoors)+1;
            until
              (Room[r].doorx[a]>0)and(Room[r].doory[a]>0);
            // ����� ������
            aimx := Room[r].doorx[a];
            aimy := Room[r].doory[a];
            // ������ ������
            while (bx<>aimx)or(by<>aimy) do
            begin
              if bx < aimx then inc(bx) else
                if bx > aimx then dec(bx) else
                  if by < aimy then inc(by) else
                    if by > aimy then dec(by);
              if (M.tile[bx,by] <> tdUSTAIRS) and (M.tile[bx,by] <> tdDSTAIRS) then
                M.tile[bx,by] := FloorTile;
            end;
          end;
        end;
      end;
    end;
  end;
  //���������� ������. ������ #2 (� ����������� �����������)
  function TunnelPassage : boolean;
  var
    x,y,i,k,bx,by,aimx,aimy,turn : byte;
    z : integer;
    dx,dy : shortint;
    move : array[1..MapX,1..MapY] of boolean;
    // �������������
    procedure MoveTo(x,y : byte);
    begin
      if (move[x,y] = false)and(not((x=aimx)and(y=aimy))) then
      begin
        if bx <> x then
        begin
          if dy = 0 then
          begin
            if aimy < by  then
                dy := -1 else
            if aimy > by  then
                dy := 1 else
            begin
              if Move[x,by-1] = True then
                dy := -1 else
                  if Move[x,by+1] = True then
                    dy := 1 else
                      dy := 1;
            end;
          end;
          by := by + dy;
        end else
          if by <> y then
          begin
            if dx = 0 then
            begin
              if aimx < bx then
                dx := -1 else
              if aimx > bx then
                  dx := 1 else
              begin
                if Move[bx-1,y] = True then
                  dx := -1 else
                    if Move[bx+1,y] = True then
                      dx := 1 else
                        dx := 1;
              end;
            end;
            bx := bx + dx;
          end;
      end else
        if (move[x,y] = true)or((x=aimx)and(y=aimy)) then
        begin
          if by <> y then dx := 0;
          if bx <> x then dy := 0;
          bx := x;
          by := y;
        end;
      if M.tile[bx,by] <> tdCDoor then
        M.Tile[bx,by] := FloorTile;
    end;
  begin
    Result := True;
    // ��������� ������ ������������
    for x:=1 to MapX do
      for y:=1 to MapY do
        if M.Tile[x,y] = tdEMPTY then
          move[x,y] := true else
            move[x,y] := false;
    // �������� ���� ������
    for i:=1 to MaxRooms do
    begin
      if Room[i].exists then
      begin
        dx := 0;
        dy := 0;
        turn := 1;
        // ��������� ��� �����
        for k:=1 to MaxDoors do
        begin
          // ���� ����� ���������� (������ ������!)}
          if (Room[i].doorx[k]>0)and(Room[i].doory[k]>0) then
          begin
            // ���� ��� ������ ����� � ������ ������� - �� ���������, �����
            // ��������� �� ��������� ��������, ����� - ��������� �� ���������
            if (k=1)and(Room[i+1].exists)then
              r := i + 1 else
                repeat
                  r := Random(MaxRooms)+1;
                until
                 (r<>i)and(Room[r].exists);
            // ������ ������
            bx := Room[i].doorx[k];
            by := Room[i].doory[k];
            if move[bx-1,by] then bx := bx - 1 else
              if move[bx+1,by] then bx := bx + 1 else
                if move[bx,by-1] then by := by - 1 else
                  if move[bx,by+1] then by := by + 1;
            M.Tile[bx,by] := FloorTile;
            // ����� ����� � ������� ������� ����� ���������
            repeat
              a := Random(MaxDoors)+1;
            until
              (Room[r].doorx[a]>0)and(Room[r].doory[a]>0);
            // ����� ������
            aimx := Room[r].doorx[a];
            aimy := Room[r].doory[a];
            // ������ ������
            z := 0;
            while (z < 200) do
            begin
              if turn = 1 then
              begin
                if bx < aimx then MoveTo(bx+1,by) else
                  if bx > aimx then MoveTo(bx-1,by);
                if bx = aimx then turn := 2;
              end else
                begin
                  if by < aimy then MoveTo(bx,by+1) else
                    if by > aimy then MoveTo(bx,by-1);
                  if by = aimy then turn := 1;
                end;
              inc(z);
            end;
            if (aimx=bx)and(aimy=by) then
              Result := True else
                Result := False;
          end;
        end;
      end;
    end;
  end;
  // �������� ��������� �����
  procedure Changes;
  var
    x,y : byte;
  begin
    for x:=1 to MapX do
      for y:=1 to MapY do
        begin
          // �������� ������ ���� �� �����
          if M.Tile[x,y] = tdEMPTY then
            M.Tile[x,y] := WallTile;
          // �������� �������� ����� �� �������� ��� ��������
          if M.Tile[x,y] = tdCDOOR then
            case Random(100)+1 of
              1..35 : M.Tile[x,y] := tdODOOR;
            end;
        end;
  end;
  // ������� �����
  procedure MakeRuins;
  const
    Side = -1;
  var
    x,y,c : byte;
  begin
    // �������������
    c := Random(8)+1;
    for x:=4 to MapX-4 do
      for y:=5 to MapY-5 do
        if (Random(c)+1 = 1) and (M.Tile[x,y] <> tdEMPTY) then
          case Random(2)+1 of
            1 : begin {#1}
                  M.Tile[x,y] := FloorTile;
                  M.Tile[x+Side,y] := FloorTile;
                  M.Tile[x+2*Side,y] := FloorTile;
                  M.Tile[x,y+Side] := FloorTile;
                  M.Tile[x,y+2*Side] := FloorTile;
                  M.Tile[x,y+3*Side] := FloorTile;
                end;
            2 : begin {#2}
                  M.Tile[x,y] := FloorTile;
                  M.Tile[x+Side,y] := FloorTile;
                  M.Tile[x-Side,y] := FloorTile;
                  M.Tile[x,y+Side] := FloorTile;
                  M.Tile[x,y-Side] := FloorTile;
                end;
          end;
  end;
  // ��������� ��������
  procedure PlaceLadders;
  var
    a,c,d : byte;
  begin
    for a:=1 to 2 do
    begin
      repeat
        c := Random(MapX)+1;
        d := Random(MapY)+1;
      until
        M.Tile[c,d] = FloorTile;
      if a = 1 then
      begin
        if down then M.Tile[c,d] := tdDSTAIRS;
      end else
          M.Tile[c,d] := tdUSTAIRS;
    end;
  end;
  // ��������� ��������
  { TODO -oBMT -c������� : ��� ��������� ������� ���������� ��������� }
  procedure PlaceMonsters;
  var
    x,y : byte;
  begin
   for x:=1 to MapX do
     for y:=1 to MapY do
       if M.Tile[x,y] = tdFLOOR then
         if Random(80)+1 = 1 then
           case Random(100)+1 of
             1..29  : CreateMonster(mdRAT,x,y);      //�����
             30..50 : CreateMonster(mdBAT,x,y);      //���.����
             51..70 : CreateMonster(mdSPIDER,x,y);   //����
             71..84 : CreateMonster(mdGOBLIN,x,y);   //������
             85..94 : CreateMonster(mdORC,x,y);      //���
             95..100: CreateMonster(mdOGR,x,y);      //���
           end;{case}
  end;
  // ��������� ��������
  procedure PlaceItems;
  var
    x,y : byte;
  begin
    for x:=1 to MapX do
      for y:=1 to MapY do
        if (M.Tile[x,y] = tdFLOOR) and (Random(200)+1 = 1) then
          case Random(8)+1 of
            1 :
            case Random(100)+1 of
              1..70   : PutItem(x,y,CreateItem(idJACKSONSHAT, 1));
              71..100 : PutItem(x,y,CreateItem(idHELMET, 1));
            end;
            2 :
            case Random(100)+1 of
              1..50    : PutItem(x,y,CreateItem(idMANTIA, 1));
              51..80   : PutItem(x,y,CreateItem(idJACKET, 1));
              81..100  : PutItem(x,y,CreateItem(idCHAINARMOR, 1));
            end;
            3 :
            case Random(100)+1 of
              1..30    : PutItem(x,y,CreateItem(idKITCHENKNIFE, 1));
              31..50   : PutItem(x,y,CreateItem(idPITCHFORK, 1));
              51..65   : PutItem(x,y,CreateItem(idDAGGER, 1));
              66..75   : PutItem(x,y,CreateItem(idSTAFF, 1));
              76..85   : PutItem(x,y,CreateItem(idDUBINA, 1));
              86..90   : PutItem(x,y,CreateItem(idSHORTSWORD, 1));
              91..97   : PutItem(x,y,CreateItem(idPALICA, 1));
              98..100  : PutItem(x,y,CreateItem(idLONGSWORD, 1));
            end;
            4 :
            PutItem(x,y,CreateItem(idSHIELD, 1));
            5 :
            case Random(100)+1 of
              1..70   : PutItem(x,y,CreateItem(idLAPTI, 1));
              71..100 : PutItem(x,y,CreateItem(idBOOTS, 1));
            end;
            6 : PutItem(x,y,CreateItem(idCOIN, Random(30)+1));
            7 :
            case Random(100)+1 of
              1..40   : PutItem(x,y,CreateItem(idKEKS, 1));
              41..60  : PutItem(x,y,CreateItem(idLAVASH, 1));
              61..90  : PutItem(x,y,CreateItem(idGREENAPPLE, Random(5)+1));
              91..100 : PutItem(x,y,CreateItem(idMEAT, 1));
            end;
            8 :
            case Random(100)+1 of
              1..70   : PutItem(x,y,CreateItem(idPOTIONCURE, 1));
              71..100 : PutItem(x,y,CreateItem(idPOTIONHEAL, 1));
            end;
          end;
  end;
  begin
    Result := True;
    // ���� �� �������� ����������� ������
    repeat
      Clear;
      // ��� ������
      if vid = 0 then
        M.tip := Random(TipsAmount)+1 else
          M.tip := vid;
      // ��� ���� � ����
      FloorTile := tdFLOOR;
      WallTile := tdROCK;
      // ������������ ����������� ������
      case M.tip of
        tipRooms : MaxRoomsAmount := 10+Random(180);
        tipDestr : MaxRoomsAmount := 130+Random(40);
        tipRuins : MaxRoomsAmount := 130+Random(40);
        tipRuLab : MaxRoomsAmount := 100;
        tipDRoom : MaxRoomsAmount := 130+Random(40);
        else
           MaxRoomsAmount := 100;
      end;
      // �������� ���� ������
      for i:=1 to MaxRooms+1 do
       with Room[i] do
       begin
         exists := False;
         x1 := 0;
         y1 := 0;
         x2 := 0;
         y2 := 0;
         for q:=1 to MaxDoors do
         begin
           doorx[q] := 0;
           doory[q] := 0;
         end;
       end;
      // �����
      for x:=1 to MapX do
      begin
        M.Tile[x,1] := WallTile;
        M.Tile[x,MapY] := WallTile;
      end;
      for y:=1 to MapY do
      begin
        M.Tile[1,y] := WallTile;
        M.Tile[MapX,y] := WallTile;
      end;
      // ���������� ������
      j := 1;
      for i:=1 to MaxRoomsAmount do
      begin
        // ���� ������ ��������, �� ������� - �����
        if M.tip = tipRulab then
        begin
          // ���������� �����
          with room[j] do
          begin
            x1 := Random(MapX-1)+2;
            y1 := Random(MapY-1)+2;
          end;
          if M.Tile[Room[j].x1,Room[j].y1] = tdEMPTY then
          begin
            Room[j].exists := True;
            M.tile[Room[j].x1,Room[j].y1] := WallTile;
            Room[j].doorx[1] := Room[j].x1;
            Room[j].doory[1] := Room[j].y1;
          end;
        end else
          begin
            // ������ �������
            with room[j] do
            begin
              x1 := Random(MapX-MinWidth)+2;
              y1 := Random(MapY-MinHeight)+2;
              x2 := Random(MaxWidth-MinWidth)+MinWidth+x1;
              y2 := Random(MaxHeight-MinHeight)+MinHeight+y1;
            end;
            // ���� ������� �������, �� ������ ��
            if CheckBounds then BuildRoom else Continue;
            // ���� �����
            r:=1;
            d:=0;
            for q:=1 to MaxDoors do
            begin
              if Random(100)+1 <= 100/q then
              begin
                BCounter := 0;
                find := false;
                repeat
                  ACounter := 0;
                  a := 1;
                  b := 1;
                  // �������
                  case Random(MaxRooms)+1 of
                    1: // ����
                    if d<>1 then
                    begin
                      repeat
                        a := Random((Room[j].x2-1)-(Room[j].x1+1))+(Room[j].x1+1);
                        b := Room[j].y1;
                        inc(ACounter);
                      until
                        (CanDoor(a,b)=true)or(ACounter=20);
                      if ACounter<20 then
                      begin
                        d := 1;
                        find := true;
                      end;
                    end;
                    2: // ���
                    if d<>2 then
                    begin
                      repeat
                        a := Random((Room[j].x2-1)-(Room[j].x1+1))+(Room[j].x1+1);
                        b := Room[j].y2;
                        inc(ACounter);
                      until
                        (CanDoor(a,b)=true)or(ACounter=20);
                      if ACounter<20 then
                      begin
                        d := 2;
                        find := true;
                      end;
                    end;
                    3: // ����
                    if d<>3 then
                    begin
                      repeat
                        a := Room[j].x1;
                        b := Random((Room[j].y2-1)-(Room[j].y1+1))+Room[j].y1+1;
                        inc(ACounter);
                      until
                        (CanDoor(a,b)=true)or(ACounter=20);
                      if ACounter<20 then
                      begin
                        d := 3;
                        find := true;
                      end;
                    end;
                    4: // �����
                    if d<>4 then
                    begin
                      repeat
                        a := Room[j].x2;
                        b := Random((Room[j].y2-1)-(Room[j].y1+1))+Room[j].y1+1;
                        inc(ACounter);
                      until
                        (CanDoor(a,b)=true)or(ACounter=20);
                      if ACounter<20 then
                      begin
                        d := 4;
                        find := true;
                      end;
                    end;
                  end;
                  inc(BCounter);
                until
                  (BCounter=200)or(find);
                if BCounter = 200 then
                begin
                  result := false;
                  exit;
                end;
                if find then
                begin
                  if M.tip = tipRooms then
                    M.Tile[a,b] := tdCDOOR else
                      M.Tile[a,b] := FloorTile;
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
        if j = MaxRooms then break;
      end;
    until
      j >= MinRooms;
    case M.tip of
      tipRooms :
      begin
        PlaceLadders;
        Result := TunnelPassage;
      end;
      tipDestr :
      begin
        PlaceLadders;
        FreePassage;
      end;
      tipRuins :
      begin
        FreePassage;
        MakeRuins;
        PlaceLadders;
      end;
      tipRuLab :
      begin
        FreePassage;
        MakeRuins;
        PlaceLadders;
      end;
      tipDRoom :
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
function TMap.Save : boolean;
var
  f : file;
begin
  CreateDir('swap');
  CreateDir('swap/'+pc.name);
  AssignFile(f,'swap/'+pc.name+'/'+IntToStr(pc.level)+'_'+IntToStr(pc.enter)+'_'+IntToStr(pc.depth)+'.lev');
  {$I-}
  Rewrite(f,1);
  // �������� ���������� � ������
  BlockWrite(f,Tile,SizeOf(Tile));
  BlockWrite(f,Blood,SizeOf(Blood));
  BlockWrite(f,Saw,SizeOf(Saw));
  BlockWrite(f,Mem,SizeOf(Mem));
  // �������
  { TODO -oPD -cminor : ������� ����������� ����� ������� � ���������� ��� �� ����, � ������ ��������������� �������� }
  BlockWrite(f,MonL,SizeOf(MonL));
  BlockWrite(f,MonP,SizeOf(MonP));
  // ��������
  BlockWrite(f,Item,SizeOf(Item));
  CloseFile(f);
  {$I+}
  if IOResult <> 0 then
    Result := false else
      Result := true;
end;

{ ��������� }
function TMap.Load(l,e,d : byte) : boolean;
var
  f : file;
begin
  AssignFile(f,'swap/'+pc.name+'/'+IntToStr(pc.level)+'_'+IntToStr(pc.enter)+'_'+IntToStr(pc.depth)+'.lev');
  {$I-}
  Reset(f,1);
  {$I+}
  if IOResult = 0 then
  begin
    Result := true;
    // ��������� ���������� � ������
    BlockRead(f,Tile,SizeOf(Tile));
    BlockRead(f,Blood,SizeOf(Blood));
    BlockRead(f,Saw,SizeOf(Saw));
    BlockRead(f,Mem,SizeOf(Mem));
    // �������
    { TODO -oPD -cminor : ������� ����������� ����� ������� � ���������� ��� �� ����, � ������ ��������������� �������� }
    BlockRead(f,MonL,SizeOf(MonL));
    BlockRead(f,MonP,SizeOf(MonP));
    // ��������
    BlockRead(f,Item,SizeOf(Item));
    CloseFile(f);
  end else
    Result := false;
end;

{ ������ ���� ������� ������� }
function TMap.DungeonType : byte;
begin
  Result :=0;
  // �������
  if pc.level = 1 then
  begin
    // ���������
    if pc.enter = 1 then
      case pc.depth of
        1    : Result := tipRooms;
        2    : Result := tipDestr;
        3    : Result := tipDRoom;
        4    : Result := tipRuins;
      end;
  end;
end;
end.