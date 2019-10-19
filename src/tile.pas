unit tile;

interface

uses
  Cons, Utils;

type
  TTile = record
    name: string[30];
    hardy, void, blood, move, important: boolean;
    char: string[1];
    color: byte;
  end;

const
  { ��������� ���������� ������ }
  LevelTilesAmount = 27;

  { �������� ������ }
  TilesData: array [0 .. LevelTilesAmount] of TTile = (
    //
    (name: '������ �����'; hardy: TRUE; void: FALSE; blood: TRUE; move: TRUE; important: FALSE; char: ' '; color: crBLACK),
    //
    (name: '�������� �����'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crGRAY),
    //
    (name: '�������� �����'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '+'; color: crBROWN),
    //
    (name: '�������� �����'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: FALSE; char: '/'; color: crBROWN),
    //
    (name: '�������� �����'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: TRUE; char: '<'; color: crYELLOW),
    //
    (name: '�������� ����'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: TRUE; char: '>'; color: crYELLOW),
    //
    (name: '�������� ���'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: FALSE; char: '.'; color: crGRAY),
    //
    (name: '�������� �����'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: FALSE; char: '.'; color: crGREEN),
    //
    (name: '���'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: 'T'; color: crGREEN),
    //
    (name: '����'; hardy: TRUE; void: FALSE; blood: FALSE; move: FALSE; important: FALSE; char: '^'; color: crWHITE),
    //
    (name: '��������'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: FALSE; char: ':'; color: crBROWN),
    //
    (name: '����'; hardy: TRUE; void: TRUE; blood: FALSE; move: FALSE; important: FALSE; char: '='; color: crRANDOMBLUE),
    //
    (name: '�������� ��� �������� �����'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: FALSE; char: '.'; color: crLIGHTRED),
    //
    (name: '����������� �����'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crRANDOMRED),
    //
    (name: '�������� ���'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: TRUE; char: '�'; color: crBROWN),
    //
    (name: '�����'; hardy: TRUE; void: TRUE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crCYAN),
    //
    (name: '������ �������'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: FALSE; char: '.'; color: crLIGHTGREEN),
    //
    (name: '�������� ���'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: TRUE; char: '.'; color: crBROWN),
    //
    (name: '�������� �����'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crGRAY),
    //
    (name: '�������� �����'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBROWN),
    //
    (name: '�����'; hardy: FALSE; void: TRUE; move: TRUE; important: FALSE; char: '.'; color: crBROWN),
    //
    (name: '���� � ����������'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: TRUE; char: '*'; color: crGRAY),
    //
    (name: '������� ������'; hardy: FALSE; void: TRUE; blood: TRUE; move: TRUE; important: FALSE; char: '.'; color: crRANDOM),
    //
    (name: '�������� �����'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBROWN),
    //
    (name: '���'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: 'f'; color: crBLUEGREEN),
    //
    (name: '�����, �������� ����'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBLUEGREEN),
    //
    (name: '�����, �������� ����'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBLUEGREEN),
    //
    (name: '���'; hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '|'; color: crBROWN)
    //
    );

  { ���������� �������������� ������ }
  tdEMPTY = 0;
  tdROCK = 1;
  tdCDOOR = 2;
  tdODOOR = 3;
  tdUSTAIRS = 4;
  tdDSTAIRS = 5;
  tdFLOOR = 6;
  tdGRASS = 7;
  tdKLEN = 8;
  tdMOUNT = 9;
  tdROAD = 10;
  tdWATER = 11;
  tdREDFLOOR = 12;
  tdHOTROCK = 13;
  tdCHATCH = 14;
  tdBIGGATES = 15;
  tdLGRASS = 16;
  tdOHATCH = 17;
  tdSECSTONE = 18;
  tdEWALL = 19;
  tdEARTH = 20;
  tdDUNENTER = 21;
  tdSHFLOOR = 22;
  tdSECEARTH = 23;
  tdIVA = 24;
  tdGREENWALL = 25;
  tdSECGRWALL = 26;
  tdDUB = 27;

implementation

end.
