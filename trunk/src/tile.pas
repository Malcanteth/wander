unit tile;

interface

uses
  Cons, Utils;

type
  TTile = record
    name              : string[30];
    hardy, void, blood,
    move, important   : boolean;
    char              : string[1];
    color             : byte;
  end;

const
  { Константы количества тайлов }
  LevelTilesAmount    = 27;

  { Описание тайлов }
  TilesData : array [0..LevelTilesAmount] of TTile =
  (
    (name: 'Пустое место';   hardy: TRUE;  void: FALSE; blood: TRUE; move: TRUE; important: FALSE; char: ' '; color: crBLACK),
    (name: 'Каменная стена'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crGRAY),
    (name: 'Закрытая дверь'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '+'; color: crBROWN),
    (name: 'Открытая дверь'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '/'; color: crBROWN),
    (name: 'Лестница вверх'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: TRUE;  char: '<'; color: crYELLOW),
    (name: 'Лестница вниз';  hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: TRUE;  char: '>'; color: crYELLOW),
    (name: 'Каменный пол';   hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '.'; color: crGRAY),
    (name: 'Полевица белая'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '.'; color: crGREEN),
    (name: 'Клён';           hardy: TRUE;  void: FALSe; blood: TRUE; move: FALSE; important: FALSE; char: 'T'; color: crGREEN),
    (name: 'Горы';           hardy: TRUE;  void: FALSE; blood: FALSE; move: FALSE; important: FALSE; char: '^'; color: crWHITE),
    (name: 'Тропинка';       hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: ':'; color: crBROWN),
    (name: 'Вода';           hardy: TRUE;  void: TRUE;  blood: FALSE; move: FALSE; important: FALSE; char: '='; color: crRANDOMBLUE),
    (name: 'Странный пол красного цвета';  hardy: FALSE;void: TRUE;  blood: TRUE; move: TRUE; important: FALSE; char: '.'; color: crLIGHTRED),
    (name: 'Раскаленная стена';            hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crRANDOMRED),
    (name: 'Закрытый Люк';   hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: TRUE;  char: '€'; color: crBROWN),
    (name: 'Врата';          hardy: TRUE;  void: TRUE;  blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crCYAN),
    (name: 'Мятлик луговой'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '.'; color: crLIGHTGREEN),
    (name: 'Открытый Люк';   hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: TRUE;  char: '.'; color: crBROWN),
    (name: 'Каменная стена'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crGRAY),
    (name: 'Земляная стена'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBROWN),
    (name: 'Земля';          hardy: FALSE; void: TRUE;  move: TRUE;  important: FALSE; char: '.'; color: crBROWN),
    (name: 'Вход в подземелье';            hardy: FALSE;void: TRUE;  blood: TRUE; move: TRUE; important: TRUE; char: '*'; color: crGRAY),
    (name: 'Сияющая плитка'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '.'; color: crRANDOM),
    (name: 'Земляная стена'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBROWN),
    (name: 'Ива';            hardy: TRUE;  void: FALSe; blood: TRUE; move: FALSE; important: FALSE; char: 'f'; color: crBLUEGREEN),
    (name: 'Стена, заросшая мхом';         hardy:  TRUE;void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBLUEGREEN),
    (name: 'Стена, заросшая мхом';         hardy:  TRUE;void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBLUEGREEN),
    (name: 'Дуб';            hardy: TRUE;  void: FALSe; blood: TRUE; move: FALSE; important: FALSE; char: '|'; color: crBROWN)
  );

{$include ../Data/Scripts/Tiles.pas}

implementation

end.
