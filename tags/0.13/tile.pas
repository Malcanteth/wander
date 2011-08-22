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
  LevelTilesAmount    = 22;

  { �������� ������ }
  TilesData : array [0..LevelTilesAmount] of TTile =
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
    (name: '�������� ���'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '�'; color: cBROWN),
    (name: '�����'; hardy: TRUE; void: TRUE; move: FALSE; important: FALSE; char: '#'; color: cCYAN),
    (name: '�����'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cLIGHTGREEN),
    (name: '�������� ���'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '.'; color: cBROWN),
    (name: '�������� �����'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '#'; color: cGRAY),
    (name: '�������� �����'; hardy: TRUE; void: FALSE; move: FALSE; important: FALSE; char: '#'; color: cBROWN),
    (name: '�����'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cBROWN),
    (name: '���� � ����������'; hardy: FALSE; void: TRUE; move: TRUE; important: TRUE; char: '*'; color: cGRAY),
    (name: '������� ������'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: cRANDOM)
  );

  { ���������� �������������� ������ }
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
