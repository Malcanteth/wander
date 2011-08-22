unit special;

interface

uses
  Map, Cons, Tile, Player, Monsters, Items;

procedure Eviliar;                // Создать деревеньку Эвилиар (Локация 1)
procedure LastLevelOfStoreHouse;  // Последний уровень хранилища
procedure Hell666You;             // АД                         (Локация 0) 

procedure PlaceOnStairs(l,e : byte);  // Разместить героя на правильный вход
function GetEnterNumber : byte;       // Вернуть номер входа

var
  radius   : real;

implementation

{ Построить комнату }
procedure BuildRoom(x1,y1,x2,y2,walltile,floortile,dx,dy,door : byte);
var
  x,y : byte;
begin
  // Комната
  for x:=x1 to x2 do
    for y:=y1 to y2 do
      if (x=x1)or(x=x2)or(y=y1)or(y=y2) then
        M.tile[x,y] := WallTile else
          M.tile[x,y] := FloorTile;
   // Дверь       
   M.Tile[dx,dy] := door;
end;

{ Создать деревеньку Эвилиар }
procedure Eviliar;
var
  x, y, i  : byte;
begin
  M.Clear;
  // Трава
  for x:=1 to MapX do
    for y:=1 to MapY do
      if Random(3)+1 = 3 then
        M.Tile[x,y] := tdLGRASS else
          M.Tile[x,y] := tdGRASS;
  // Леса
  for x:=11 to MapX do
    for y:=1 to Random(4)+1 do
      M.Tile[x,y] := tdTREE;
  for x:=11 to MapX do
    for y:=MapY downto MapY-(Random(4)+1) do
      M.Tile[x,y] := tdTREE;
  for y:=1 to 15 do
    for x:=11 to 11+(Random(4)+1) do
      M.Tile[x,y] := tdTREE;
  for y:=21 to MapY do
    for x:=11 to 11+Random(4)+1 do
      M.Tile[x,y] := tdTREE;
  for y:=1 to MapY do
    for x:=MapX downto MapX-(Random(4)+1) do
      M.Tile[x,y] := tdTREE;
  // Горы
  for x:=11 to MapX do
    for y:=1 to Random(3)+1 do
      M.Tile[x,y] := tdMOUNT;
  for x:=11 to MapX do
    for y:=MapY downto MapY-(Random(3)+1) do
      M.Tile[x,y] := tdMOUNT;
  for y:=1 to MapY do
    for x:=1 to 10 do
      M.Tile[x,y] := tdMOUNT;
  for y:=1 to MapY do
    for x:=11 to 11+(Random(3)+1) do
      M.Tile[x,y] := tdMOUNT;
  for y:=1 to MapY do
    for x:=MapX downto MapX-(Random(3)+1) do
      M.Tile[x,y] := tdMOUNT;
  // Тропинка
  for x:=1 to MapX do
    M.Tile[x,18] := tdROAD;
  // Забор
    M.Tile[MapX-1,18] := tdBIGGATES; 
  // Озеро
  for x:=40 to 52 do
    for y:=12 to 24 do
    begin
      radius := round(sqrt(sqr(46-x)+sqr(18-y)));
      if radius<=6 then
        M.Tile[x,y] := tdWATER;
    end;
  // Дом Старейшины
  BuildRoom(20, 6, 30, 11, tdROCK, tdFLOOR, 23, 11, tdODOOR);
  // Сарай для хранилища
  BuildRoom(MapX-6, 3, MapX-2, 6, tdROCK, tdFLOOR, MapX-6,5, tdODOOR);
  // Лестница вниз
  M.Tile[MapX-3, 5] := tdDSTAIRS;
  // Ключник
  BuildRoom(61, 9, 75, 15, tdROCK, tdFLOOR, 61,13, tdODOOR);
  // Мой домик:)
  BuildRoom(40, 5, 54, 9, tdROCK, tdFLOOR, 48,9, tdODOOR);
  // Бар
  BuildRoom(18, 22, 28, 30, tdROCK, tdFLOOR, 20,22, tdODOOR);
  // Его обитатели и бармен
  CreateMonster(mdBARTENDER,19,26);
  CreateMonster(mdDRUNK,24,24);
  CreateMonster(mdDRUNK,26,26);
  CreateMonster(mdDRUNK,24,28);
  CreateMonster(mdDRUNKKILLED,27,29);
  // Бойня
  BuildRoom(36, 27, 42, 31, tdROCK, tdFLOOR, 40,27, tdODOOR);
  CreateMonster(mdMEATMAN,39,29);
  // Лечилка
  BuildRoom(46, 27, 54, 30, tdROCK, tdFLOOR, 48,27, tdODOOR);
  CreateMonster(mdHEALER,50,29);
  // Просто домик №3
  BuildRoom(58, 20, 67, 28, tdROCK, tdFLOOR, 59,20, tdCDOOR);
  // Люк
  M.Tile[66,27] := tdHATCH;
  // Старейшина
  CreateMonster(mdELDER,22,8);
  // BREAKMT
  CreateMonster(mdBREAKMT,47,7);
  // Разместить жителей
  for i:=1 to 30 do
  begin
    repeat
      x := random(MapX)+1;
      y := random(MapY)+1;
    until
      (not TilesData[M.Tile[x,y]].hardy) and (M.MonP[x,y] = 0) and (X > 13);
    case random(2)+1 of
      1 : CreateMonster(mdMALECITIZEN,x,y);    // Житель
      2 : CreateMonster(mdFEMALECITIZEN,x,y);  // Жительница
    end;
  end;
  // Поместить героя
  pc.PlaceHere(6,18);
end;

{ Последний уровень хранилища }
procedure LastLevelOfStoreHouse;
var
  x,y : byte;
begin
  M.Clear;
  // Стены
  for x:=1 to MapX do
    for y:=1 to MapY do
      M.Tile[x,y] := tdROCK;
  // Пол
  for x:=30 to 60 do
    for y:=10 to 24 do
      M.Tile[x,y] := tdFLOOR;
  // Озерцо
  // Монстры
  CreateMonster(mdBLINDBEAST, 30, 10);    // Типа Главарь :)
  CreateMonster(mdOGR, 60, 10);
  CreateMonster(mdOGR, 30, 24);
  CreateMonster(mdORC, 40, 15);
  CreateMonster(mdORC, 35, 19);
  // Лестница
  M.Tile[60,24] := tdUSTAIRS;
  // Поместить героя на лестницу вверх
  pc.PlaceAtTile(tdUSTAIRS);
end;

{ АД }
procedure Hell666You;
var
  x,y : byte;
begin
  M.Clear;
  pc.level := 255;
  // Красный пол
  for x:=1 to MapX do
    for y:=1 to MapY do
      begin
        if Random(3)+1 = 3 then
           M.Tile[x,y] := tdREDFLOOR else
             begin
               M.Tile[x,y] := tdFLOOR;
               M.Blood[x,y] := Random(3);
             end;
        if (x<>30) and (y<>23) then     
        if Random(8)+1 = 1 then
        begin
          case Random(5)+1 of
            1 : CreateMonster(mdRAT, x, y);
            2 : CreateMonster(mdGOBLIN, x, y);
            3 : CreateMonster(mdORC, x, y);
            4 : CreateMonster(mdOGR, x, y);
            5 : CreateMonster(mdBLINDBEAST, x, y);
          end;
        end;
      end;
  // Забор
  for x:=1 to MapX do
  begin
    M.Tile[x,1] := tdHOTROCK;
    M.Tile[x,MapY] := tdHOTROCK;
  end;
  for y:=1 to MapY do
  begin
    M.Tile[1,y] := tdHOTROCK;
    M.Tile[MapX,y] := tdHOTROCK;
  end;
  // Поместить героя
  pc.PlaceHere(30,23);
end;

{ Разместить героя на правильный вход }
procedure PlaceOnStairs(l, e : byte);
begin
  case l of
    1: // Эвилиар
    begin
      case e of
        0: // Хранилище
        begin
          pc.x := MapX-3;
          pc.y := 5;
        end;
      end;
    end;
  end;
  M.MonP[pc.x, pc.y] := 1;
end;

{ Вернуть номер входа }
function GetEnterNumber : byte;
begin
  Result := 0;
  // Эвилиар
  if pc.level = 1 then
  begin
    // Хранилище
    if (pc.x = MapX-3) and (pc.y = 5) then
      Result := 1;
  end;
end;

end.
