unit map;

interface

uses
  SysUtils, Cons, Main, Player, Tile, Monsters, Utils, Items, Flags, Windows, Graphics, Math;

type
  { Структура карты }
  TMap = object
    Special  : byte;                            // Текущая спец. карта 
    tip  : byte;                                // Тип пещеры
    Tile : array [1..MapX,1..MapY] of byte;     // Тайлы
    Blood: array [1..MapX,1..MapY] of byte;     // Кровь
    Saw  : array [1..MapX,1..MapY] of byte;     // Была ли видима клетка
    MemS  : array [1..MapX,1..MapY] of string[1];// Зрительная память (символ)
    MemC  : array [1..MapX,1..MapY] of byte;    // Зрительная память (цвет)
    MemBC : array [1..MapX,1..MapY] of byte;    // Зрительная память (фон)
    MonL : array [1..255] of TMonster;          // Список монстров на уровне
    MonP : array [1..MapX,1..MapY] of byte;     // Указатели на монстра
    Item : array [1..MapX,1..MapY] of TItem;    // Предметы
  public
    procedure Clear;                            // Очистить карту
    procedure DrawScene;                        // Вывести карту
    function GenerateCave(vid : byte;
                   down : boolean) : boolean;   // Генерация подземелья
    function Save : boolean;                    // Сохранить
    function Load(l,e,d : byte) : boolean;      // Загрузить
    function DungeonType : byte;                // Какого типа сделать уровень
    procedure MakeSpMap(n : byte);              // Сделать специальную карту
  end;

var
  M         : TMap;
  FlyX,FlyY : byte;
  FlyS      : string[1];
  FlyC      : byte;

implementation

uses
  MapEditor, conf;

{ Очистить карту }
procedure TMap.Clear;
begin
  FillMemory(@M, SizeOf(TMap), 0);
end;

{ Вывести карту }
procedure TMap.DrawScene;
var
  x, y    : integer;
  color,
  back       : longword;
  char       : string[1];
  dx,dy,i,sx,sy,check,e:integer;
  onway      : boolean;
begin
  with Screen.Canvas do
  begin
    Font.Name := FontMap;
    for x:=1 to MapX do
      for y:=1 to MapY do
        begin
          color := 255;
          back := 0;
          if M.Saw[x,y] > 0 then
          begin
            // Тайл
            case M.Blood[x,y] of
              0 : color := RealColor(TilesData[M.Tile[x,y]].color);
              1 : color := cLIGHTRED;
              2 : color := cRED;
            end;
            char := TilesData[M.Tile[x,y]].char;
            back := Darker(RealColor(TilesData[M.Tile[x,y]].color), 92);
            // Предметы
            if M.Item[x,y].id > 0 then
            begin
              color := RealColor(ItemsData[M.Item[x,y].id].color);
              char := ItemSymbol(M.Item[x,y].id);
            end;
            // Монстры
            if M.MonP[x,y] > 0 then
            begin
              if M.MonP[x,y] = 1 then
              begin
                color := ClassColor;
                char := '@';
                if pc.tactic > 0 then back := pc.ColorOfTactic;
                if pc.felldown then color:= cGRAY;
              end else
                begin
                  color := RealColor(MonstersData[M.MonL[M.MonP[x,y]].id].color);
                  if (M.MonL[M.MonP[x,y]].relation = 1) and (M.MonL[M.MonP[x,y]].tactic > 0) then
                    back := M.MonL[M.MonP[x,y]].ColorOfTactic;
                  if M.MonL[M.MonP[x,y]].felldown then color:= cGRAY;
                  char := MonstersData[M.MonL[M.MonP[x,y]].id].char;
                end;
            end;
            // Курсор просмотра
            if (GameState = gsLook) and (x=lx) and (y=ly) then
              Back := MyRGB(140, 140, 255);
            // Курсор прицела
            if (GameState = gsAim) and (x=lx) and (y=ly) then
              Back := MyRGB(140, 0, 0);
            // Летающий объект
            if (FlyX = X) and (FlyY = Y) then
            begin
              char := FlyS;
              color := RealColor(FlyC);
            end;
            // Если место было увидено, то вывести темнее
            if M.Saw[x,y] = 1 then
            begin
              char := M.MemS[x,y];
              color := Darker(RealColor(M.MemC[x,y]), 60);
              back := Darker(RealColor(M.MemBC[x,y]), 95);
            end;
          end else
            begin
              char := ' ';
              color := 0;
            end;
          // Вывести символ
          Font.Color := color;
          Brush.Color := back;
          TextOut((x-1)*CharX, (y-1)*CharY, char);
        end;
     // Хелс-бары
     for x:=pc.x - pc.los to pc.x + pc.los do
       for y:=pc.y - pc.los to pc.y + pc.los do
         if (x > 0) and (x <= MapX) and (y > 0) and (y <= MapY) then
         begin
            // Хелс-бар
            if (M.Saw[x,y] = 2) and (M.MonP[x,y] > 0)  then
              if (M.MonL[M.MonP[x,y]].relation = 1) or ((x=pc.x)and(y=pc.y)) then
              begin
                Pen.Color := cGRAY;
                Pen.Width := 3;
                MoveTo((x-1)*CharX+1, (y-1)*CharY - 2);
                LineTo((x)*CharX-1, (y-1)*CharY - 2);
                Pen.Color := cLIGHTRED;
                MoveTo((x-1)*CharX+1, (y-1)*CharY - 2);
                if M.MonP[x,y] = 1 then
                begin
                  if pc.Hp > 0 then
                    LineTo((x-1)*CharX+1 + Round( (pc.Hp * (CharX-2)) / pc.RHp), (y-1)*CharY - 2);
                end else
                  if M.MonL[M.MonP[x,y]].Hp > 0 then
                    LineTo((x-1)*CharX+1 + Round( (M.MonL[M.MonP[x,y]].Hp * (CharX-2)) / M.MonL[M.MonP[x,y]].RHp), (y-1)*CharY - 2);
              end;
        end;
    Font.Name := FontMsg;
    // Если режим прицеливания
    if (GameState = gsAIM) and NOT ((pc.x=lx)and(pc.y=ly)) then
    begin
      dx:=abs(pc.x-lx);
      dy:=abs(pc.y-ly);
      sx:=Sign(lx-pc.x);
      sy:=Sign(ly-pc.y);
      x := pc.x;
      y := pc.y;
      check:=0;
      onway := FALSE;
      if dy>dx then
      begin
        dx:=dx+dy;
        dy:=dx-dy;
        dx:=dx-dy;
        check:=1;
      end;
      e:= 2*dy - dx;
      for i:=0 to dx-2 do
      begin
        if e>=0 then
        begin
          if check=1 then x:=x+sx else y:=y+sy;
          e:=e-2*dx;
        end;
        if check=1 then y:=y+sy else x:=x+sx;
        e:=e+2*dy;
        if onway then
          Font.Color := cRED else
            Font.Color := cYELLOW;
        Brush.Style := bsClear;
        TextOut((x-1)*CharX, (y-1)*CharY, '*');
        // А теперь проверить на столкновение и если оно есть выводить уже красным цветом
        if (not TilesData[M.Tile[x,y]].void) or (M.MonP[x,y] > 0) then inc(onway);
      end;
    end;
  end;
end;

{ Генерация подземелья }
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
  // Может ли здесь быть комната?
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
  //Может ли здесь быть дверь?
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
  //Построить комнату
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
  //Соединение комнат. Способ #1 (без обхождения препитствий)
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
          // Если дверь существует (первая должна!)}
          if (Room[i].doorx[k]>0)and(Room[i].doory[k]>0) then
          begin
            // Если это первая дверь и данная комната - не последняя, тогда
            // соединить со следующей комнатой, иначе - соединить со случайной
            if (k=1)and(Room[i+1].exists)then
              r := i + 1 else
                repeat
                  r := Random(MaxRooms)+1;
                until
                  (r<>i)and(Room[r].exists);
            // Начало тунеля
            bx := Room[i].doorx[k];
            by := Room[i].doory[k];
            // Найти дверь с которой комната будет соединина
            repeat
              a := Random(MaxDoors)+1;
            until
              (Room[r].doorx[a]>0)and(Room[r].doory[a]>0);
            // Конец тунеля
            aimx := Room[r].doorx[a];
            aimy := Room[r].doory[a];
            // Делать тунель
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
  //Соединение комнат. Способ #2 (с обхождением препятствий)
  function TunnelPassage : boolean;
  var
    x,y,i,k,bx,by,aimx,aimy,turn : byte;
    z : integer;
    dx,dy : shortint;
    move : array[1..MapX,1..MapY] of boolean;
    // Переместиться
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
    // Заполнить массив проходимости
    for x:=1 to MapX do
      for y:=1 to MapY do
        if M.Tile[x,y] = tdEMPTY then
          move[x,y] := true else
            move[x,y] := false;
    // Проверка всех комнат
    for i:=1 to MaxRooms do
    begin
      if Room[i].exists then
      begin
        dx := 0;
        dy := 0;
        turn := 1;
        // Проверить все двери
        for k:=1 to MaxDoors do
        begin
          // Если дверь существует (первая должна!)}
          if (Room[i].doorx[k]>0)and(Room[i].doory[k]>0) then
          begin
            // Если это первая дверь и данная комната - не последняя, тогда
            // соединить со следующей комнатой, иначе - соединить со случайной
            if (k=1)and(Room[i+1].exists)then
              r := i + 1 else
                repeat
                  r := Random(MaxRooms)+1;
                until
                 (r<>i)and(Room[r].exists);
            // Начало тунеля
            bx := Room[i].doorx[k];
            by := Room[i].doory[k];
            if move[bx-1,by] then bx := bx - 1 else
              if move[bx+1,by] then bx := bx + 1 else
                if move[bx,by-1] then by := by - 1 else
                  if move[bx,by+1] then by := by + 1;
            M.Tile[bx,by] := FloorTile;
            // Найти дверь с которой комната будет соединина
            repeat
              a := Random(MaxDoors)+1;
            until
              (Room[r].doorx[a]>0)and(Room[r].doory[a]>0);
            // Конец тунеля
            aimx := Room[r].doorx[a];
            aimy := Room[r].doory[a];
            // Делать тунель
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
  // Поменять некоторые тайлы
  procedure Changes;
  var
    x,y : byte;
  begin
    for x:=1 to MapX do
      for y:=1 to MapY do
        begin
          // Заменить пустой тайл на стену
          if M.Tile[x,y] = tdEMPTY then
            M.Tile[x,y] := WallTile;
          // Поменять закрытую дверь на открытую или секретную... или оставить
          if M.Tile[x,y] = tdCDOOR then
            case Random(100)+1 of
              1..35  : M.Tile[x,y] := tdODOOR;
              36..40 :
              case WallTile of
                tdROCK  : M.Tile[x,y] := tdSECSTONE;
                tdEWALL : M.Tile[x,y] := tdSECEARTH;
              end;
            end;
        end;
  end;
  // Сделать руины
  procedure MakeRuins;
  const
    Side = -1;
  var
    x,y,c : byte;
  begin
    // Интенсивность
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
  // Поместить лестницы
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
  // Поместить монстров
  { TODO -oBMT -cСрочное : Эта процедура требует серьезного улучшения }
  procedure PlaceMonsters;
  var
    x,y,i : byte;
  begin
   for x:=1 to MapX do
     for y:=1 to MapY do
       if (M.Tile[x,y] = FloorTile) then
         if Random(75)+1 = 1 then
         begin
           repeat
             i:= Random(MonstersAmount)+1;
           until
             (not IsFlag(MonstersData[i].flags, M_NEUTRAL)) and ((SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].CoolLevel >= MonstersData[i].coollevel) or ((SpecialMaps[pc.level].Ladders[pc.enter].Levels[pc.depth].CoolLevel = MonstersData[i].coollevel+1) and (Random(10)+1=10)));
           CreateMonster(i,x,y);
         end;
  end;
  // Поместить предметы
  procedure PlaceItems;
  var
    x,y : byte;
  begin
    for x:=1 to MapX do
      for y:=1 to MapY do
        if (M.Tile[x,y] = FloorTile) and (Random(200)+1 = 1) then
          case Random(10)+1 of
            1 :
            case Random(100)+1 of
              1..70   : PutItem(x,y,CreateItem(idJACKSONSHAT, 1, 0),1);
              71..100 : PutItem(x,y,CreateItem(idHELMET, 1, 0),1);
            end;
            2 :
            case Random(100)+1 of
              1..50    : PutItem(x,y,CreateItem(idMANTIA, 1, 0),1);
              51..80   : PutItem(x,y,CreateItem(idJACKET, 1, 0),1);
              81..100  : PutItem(x,y,CreateItem(idCHAINARMOR, 1, 0),1);
            end;
            3 :
            case Random(100)+1 of
              1..30    : PutItem(x,y,CreateItem(idKITCHENKNIFE, 1, 0),1);
              31..50   : PutItem(x,y,CreateItem(idPITCHFORK, 1, 0),1);
              51..65   : PutItem(x,y,CreateItem(idDAGGER, 1, 0),1);
              66..75   : PutItem(x,y,CreateItem(idSTAFF, 1, 0),1);
              76..85   : PutItem(x,y,CreateItem(idDUBINA, 1, 0),1);
              86..90   : PutItem(x,y,CreateItem(idSHORTSWORD, 1, 0),1);
              91..97   : PutItem(x,y,CreateItem(idPALICA, 1, 0),1);
              98..100  : PutItem(x,y,CreateItem(idLONGSWORD, 1, 0),1);
            end;
            4 :
            PutItem(x,y,CreateItem(idSHIELD, 1, 0),1);
            5 :
            case Random(100)+1 of
              1..70   : PutItem(x,y,CreateItem(idLAPTI, 1, 0),1);
              71..100 : PutItem(x,y,CreateItem(idBOOTS, 1, 0),1);
            end;
            6 : PutItem(x,y,CreateItem(idCOIN, Random(30)+1, 0),Random(30)+1);
            7 :
            case Random(100)+1 of
              1..40   : PutItem(x,y,CreateItem(idKEKS, 1, 0),1);
              41..60  : PutItem(x,y,CreateItem(idLAVASH, 1, 0),1);
              61..90  : PutItem(x,y,CreateItem(idGREENAPPLE, Random(5)+1, 0),Random(5)+1);
              91..100 : PutItem(x,y,CreateItem(idMEAT, 1, 0),1);
            end;
            8 :
            case Random(100)+1 of
              1..60   : PutItem(x,y,CreateItem(idPOTIONCURE, 1, 0),1);
              61..90  : PutItem(x,y,CreateItem(idPOTIONHEAL, 1, 0),1);
              91..100 : PutItem(x,y,CreateItem(idCHEAPBEER, 1, 0),1);
            end;
            9 :
            case Random(100)+1 of
              1..50   : PutItem(x,y,CreateItem(idSLING, 1, 0),1);
              51..80  : PutItem(x,y,CreateItem(idBLOWPIPE, 1, 0),1);
              81..90  : PutItem(x,y,CreateItem(idBOW, 1, 0),1);
              91..100 : PutItem(x,y,CreateItem(idCROSSBOW, 1, 0),1);
            end;
            10 :
            case Random(100)+1 of
              1..50   : PutItem(x,y,CreateItem(idLITTLEROCK, Random(15)+1, 0),1);
              51..80  : PutItem(x,y,CreateItem(idIGLA, Random(10)+1, 0),1);
              81..90  : PutItem(x,y,CreateItem(idARROW, Random(10)+1, 0),1);
              91..100 : PutItem(x,y,CreateItem(idBOLT, Random(10)+1, 0),1);
            end;
          end;
  end;
  begin
    Result := True;
    // Цикл на проверку колличества комнат
    repeat
      Clear;
      // Тип пещеры
      if vid = 0 then
        M.tip := Random(TipsAmount)+1 else
          M.tip := vid;
      // Тип стен и пола
      case Random(3)+1 of
        1 : FloorTile := tdFLOOR;
        2 : FloorTile := tdGRASS;
        3 : FloorTile := tdEARTH;
      end;
      case Random(3)+1 of
        1 : WallTile := tdROCK;
        2 : WallTile := tdEWALL;
        3 : WallTile := tdGREENWALL;
      end;
      // Максимальное колличество комнат
      case M.tip of
        tipRooms : MaxRoomsAmount := 10+Random(180);
        tipDestr : MaxRoomsAmount := 130+Random(40);
        tipRuins : MaxRoomsAmount := 130+Random(40);
        tipRuLab : MaxRoomsAmount := 100;
        tipDRoom : MaxRoomsAmount := 130+Random(40);
        else
           MaxRoomsAmount := 100;
      end;
      // Очистить поля комнат
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
      // Рамка
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
      // Построение комнат
      j := 1;
      for i:=1 to MaxRoomsAmount do
      begin
        // Если делаем лабиринт, то комната - точка
        if M.tip = tipRulab then
        begin
          // Координаты точки
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
            // Размер комнаты
            with room[j] do
            begin
              x1 := Random(MapX-MinWidth)+2;
              y1 := Random(MapY-MinHeight)+2;
              x2 := Random(MaxWidth-MinWidth)+MinWidth+x1;
              y2 := Random(MaxHeight-MinHeight)+MinHeight+y1;
            end;
            // Если комната влазиет, то строем ее
            if CheckBounds then BuildRoom else Continue;
            // Ищем двери
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
                  // Сторона
                  case Random(MaxRooms)+1 of
                    1: // верх
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
                    2: // низ
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
                    3: // лево
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
                    4: // право
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
        // Прервать цикл - если слишком много комнат
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

{ Сохранить }
function TMap.Save : boolean;
var
  f : file;
  x,y,k,l : byte;
begin
  CreateDir('swap');
  CreateDir('swap/'+pc.name);
  AssignFile(f,'swap/'+pc.name+'/'+IntToStr(pc.level)+'_'+IntToStr(pc.enter)+'_'+IntToStr(pc.depth)+'.lev');
  {$I-}
  Rewrite(f,1);
  BlockWrite(f,Special,SizeOf(Special));
  // Убрать видимость
  for x:=1 to MapX do
    for y:=1 to MapY do
      if M.Saw[x,y] = 2 then
        M.Saw[x,y] := 1;
  // Записать информацию о тайлах
  BlockWrite(f,Tile,SizeOf(Tile));
  BlockWrite(f,Blood,SizeOf(Blood));
  BlockWrite(f,Saw,SizeOf(Saw));
  BlockWrite(f,MemS,SizeOf(MemS));
  BlockWrite(f,MemC,SizeOf(MemC));
  BlockWrite(f,MemBC,SizeOf(MemBC));
  // Записываем монстров
  for x:=2 to 255 do
  begin
    if MonL[x].id = 0 then l := 0 else l := 1;
    BlockWrite(f, l, SizeOf(l));
    if l = 1 then
      BlockWrite(f, MonL[x], SizeOf(MonL[x]));
  end;
  // Записываем указатели на монстров
  BlockWrite(f,MonP,SizeOf(MonP));
  // Предметы
  BlockWrite(f,Item,SizeOf(Item));
  CloseFile(f);
  {$I+}
  if IOResult <> 0 then
    Result := false else
      Result := true;
end;

{ Загрузить }
function TMap.Load(l,e,d : byte) : boolean;
var
  f : file;
  x,k,j : byte;
begin
  AssignFile(f,'swap/'+pc.name+'/'+IntToStr(pc.level)+'_'+IntToStr(pc.enter)+'_'+IntToStr(pc.depth)+'.lev');
  {$I-}
  Reset(f,1);
  {$I+}
  if IOResult = 0 then
  begin
    Result := true;
    M.Clear;
    BlockRead(f,Special,SizeOf(Special));
    // Прочитать информацию о тайлах
    BlockRead(f,Tile,SizeOf(Tile));
    BlockRead(f,Blood,SizeOf(Blood));
    BlockRead(f,Saw,SizeOf(Saw));
    BlockRead(f,MemS,SizeOf(MemS));
    BlockRead(f,MemC,SizeOf(MemC));
    BlockRead(f,MemBC,SizeOf(MemBC));
    // Монстров читаем поочереди
    for x:=2 to 255 do
    begin
      BlockRead(f, j, SizeOf(j));
      if j = 1 then
        BlockRead(f, MonL[x], SizeOf(MonL[x]));
    end;
    // Читаем указатели на монстров
    BlockRead(f,MonP,SizeOf(MonP));
    // Предметы
    BlockRead(f,Item,SizeOf(Item));
    CloseFile(f);
  end else
    Result := false;
end;

{ Какого типа сделать уровень }
function TMap.DungeonType : byte;
begin
  Result :=0;
  // Эвилиар
  if pc.level = 1 then
  begin
    // Хранилище
    if pc.enter = 1 then
      case pc.depth of
        1    : Result := tipRooms;
        2    : Result := tipDestr;
        3    : Result := tipDRoom;
        4    : Result := tipRuins;
      end;
  end;
end;

{ Создать специальную карту}
procedure TMap.MakeSpMap(n : byte);
var
  i,x,y : byte;
begin
  M.Clear;
  M := SpecialMaps[n].Map;
  // Заполнить монстров информацией
  for i:=1 to 255 do
    if M.MonL[i].id > 0 then
    begin
      for x:=1 to MapX do
        for y:=1 to MapY do
          if M.MonP[x,y] = i then
            FillMonster(i, M.MonL[i].id, x, y);
    end;
end;

end.
