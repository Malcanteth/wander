unit tile;

interface

uses
  Cons, Utils;

type
  TTile = record
    name              : string[30];
    hardy, void, move, important : boolean;
    char              : string[1];
    color             : longword;
  end;

const
  { Константы количества тайлов }
  LevelTilesAmount    = 17;

  { Описание тайлов }
  TilesData : array [1..LevelTilesAmount] of TTile =
  (
    (name: 'Пустое место'; hardy: TRUE; void: FALSE; move: TRUE; important: FALSE; char: ' '; color: cBLACK),
    (name: 'Каменная стена'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '#'; color: cGRAY),
    (name: 'Закрытая дверь'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '+'; color: cBROWN),
    (name: 'Открытая дверь'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '/'; color: cBROWN),
    (name: 'Лестница вверх'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '<'; color: cYELLOW),
    (name: 'Лестница вниз'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '>'; color: cYELLOW),
    (name: 'Каменный пол'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cGRAY),
    (name: 'Трава'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cGREEN),
    (name: 'Дерево'; hardy: TRUE; void: FALSe; move: FALSE; important: FALSE; char: 'T'; color: cGREEN),
    (name: 'Горы'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '^'; color: cWHITE),
    (name: 'Тропинка'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: ':'; color: cBROWN),
    (name: 'Вода'; hardy: TRUE; void: TRUE; move: FALSE; important: FALSE; char: '='; color: cBLUE),
    (name: 'Странный пол красного цвета'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cLIGHTRED),
    (name: 'Раскаленная стена'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '#'; color: cLIGHTRED),
    (name: 'Люк'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '.'; color: cBROWN),
    (name: 'Врата'; hardy: TRUE; void: TRUE; move: FALSE; important: FALSE; char: '#'; color: cCYAN),
    (name: 'Трава'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cLIGHTGREEN)
  );

  { Уникальные идентификаторы тайлов }
  tdEMPTY    = 1;
  tdROCK     = 2;
  tdCDOOR    = 3;
  tdODOOR    = 4;
  tdUSTAIRS  = 5;
  tdDSTAIRS  = 6;
  tdFLOOR    = 7;
  tdGRASS    = 8;
  tdTREE     = 9;
  tdMOUNT    = 10;
  tdROAD     = 11;
  tdWATER    = 12;
  tdREDFLOOR = 13;
  tdHOTROCK  = 14;
  tdHATCH    = 15;
  tdBIGGATES = 16;
  tdLGRASS   = 17;

implementation

end.
