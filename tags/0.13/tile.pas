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
  LevelTilesAmount    = 22;

  { Описание тайлов }
  TilesData : array [0..LevelTilesAmount] of TTile =
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
    (name: 'Закрытый Люк'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '€'; color: cBROWN),
    (name: 'Врата'; hardy: TRUE; void: TRUE; move: FALSE; important: FALSE; char: '#'; color: cCYAN),
    (name: 'Трава'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cLIGHTGREEN),
    (name: 'Открытый Люк'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '.'; color: cBROWN),
    (name: 'Каменная стена'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '#'; color: cGRAY),
    (name: 'Земляная стена'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '#'; color: cBROWN),
    (name: 'Земля'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cBROWN),
    (name: 'Вход в подземелье'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '*'; color: cGRAY),
    (name: 'Сияющая плитка'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cRANDOM)
  );

  { Уникальные идентификаторы тайлов }
  tdEMPTY    = 0;
  tdROCK     = 1;
  tdCDOOR    = 2;
  tdODOOR    = 3;
  tdUSTAIRS  = 4;
  tdDSTAIRS  = 5;
  tdFLOOR    = 6;
  tdGRASS    = 7;
  tdTREE     = 8;
  tdMOUNT    = 9;
  tdROAD     = 10;
  tdWATER    = 11;
  tdREDFLOOR = 12;
  tdHOTROCK  = 13;
  tdCHATCH   = 14;
  tdBIGGATES = 15;
  tdLGRASS   = 16;
  tdOHATCH   = 17;
  tdSECRET   = 18;
  tdEWALL    = 19;
  tdEARTH    = 20;
  tdDUNENTER = 21;
  tdSHFLOOR  = 22;

implementation

end.
