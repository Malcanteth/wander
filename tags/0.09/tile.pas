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
  { ��������� ���������� ������ }
  LevelTilesAmount    = 17;

  { �������� ������ }
  TilesData : array [1..LevelTilesAmount] of TTile =
  (
    (name: '������ �����'; hardy: TRUE; void: FALSE; move: TRUE; important: FALSE; char: ' '; color: cBLACK),
    (name: '�������� �����'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '#'; color: cGRAY),
    (name: '�������� �����'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '+'; color: cBROWN),
    (name: '�������� �����'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '/'; color: cBROWN),
    (name: '�������� �����'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '<'; color: cYELLOW),
    (name: '�������� ����'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '>'; color: cYELLOW),
    (name: '�������� ���'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cGRAY),
    (name: '�����'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cGREEN),
    (name: '������'; hardy: TRUE; void: FALSe; move: FALSE; important: FALSE; char: 'T'; color: cGREEN),
    (name: '����'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '^'; color: cWHITE),
    (name: '��������'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: ':'; color: cBROWN),
    (name: '����'; hardy: TRUE; void: TRUE; move: FALSE; important: FALSE; char: '='; color: cBLUE),
    (name: '�������� ��� �������� �����'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cLIGHTRED),
    (name: '����������� �����'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '#'; color: cLIGHTRED),
    (name: '���'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '.'; color: cBROWN),
    (name: '�����'; hardy: TRUE; void: TRUE; move: FALSE; important: FALSE; char: '#'; color: cCYAN),
    (name: '�����'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cLIGHTGREEN)
  );

  { ���������� �������������� ������ }
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
