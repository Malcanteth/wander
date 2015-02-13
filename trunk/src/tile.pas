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
  { ��������� ���������� ������ }
  LevelTilesAmount    = 27;

  { �������� ������ }
  TilesData : array [0..LevelTilesAmount] of TTile =
  (
    (name: '������ �����';   hardy: TRUE;  void: FALSE; blood: TRUE; move: TRUE; important: FALSE; char: ' '; color: crBLACK),
    (name: '�������� �����'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crGRAY),
    (name: '�������� �����'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '+'; color: crBROWN),
    (name: '�������� �����'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '/'; color: crBROWN),
    (name: '�������� �����'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: TRUE;  char: '<'; color: crYELLOW),
    (name: '�������� ����';  hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: TRUE;  char: '>'; color: crYELLOW),
    (name: '�������� ���';   hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '.'; color: crGRAY),
    (name: '�������� �����'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '.'; color: crGREEN),
    (name: '���';           hardy: TRUE;  void: FALSe; blood: TRUE; move: FALSE; important: FALSE; char: 'T'; color: crGREEN),
    (name: '����';           hardy: TRUE;  void: FALSE; blood: FALSE; move: FALSE; important: FALSE; char: '^'; color: crWHITE),
    (name: '��������';       hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: ':'; color: crBROWN),
    (name: '����';           hardy: TRUE;  void: TRUE;  blood: FALSE; move: FALSE; important: FALSE; char: '='; color: crRANDOMBLUE),
    (name: '�������� ��� �������� �����';  hardy: FALSE;void: TRUE;  blood: TRUE; move: TRUE; important: FALSE; char: '.'; color: crLIGHTRED),
    (name: '����������� �����';            hardy: TRUE; void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crRANDOMRED),
    (name: '�������� ���';   hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: TRUE;  char: '�'; color: crBROWN),
    (name: '�����';          hardy: TRUE;  void: TRUE;  blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crCYAN),
    (name: '������ �������'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '.'; color: crLIGHTGREEN),
    (name: '�������� ���';   hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: TRUE;  char: '.'; color: crBROWN),
    (name: '�������� �����'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crGRAY),
    (name: '�������� �����'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBROWN),
    (name: '�����';          hardy: FALSE; void: TRUE;  move: TRUE;  important: FALSE; char: '.'; color: crBROWN),
    (name: '���� � ����������';            hardy: FALSE;void: TRUE;  blood: TRUE; move: TRUE; important: TRUE; char: '*'; color: crGRAY),
    (name: '������� ������'; hardy: FALSE; void: TRUE;  blood: TRUE; move: TRUE;  important: FALSE; char: '.'; color: crRANDOM),
    (name: '�������� �����'; hardy: TRUE;  void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBROWN),
    (name: '���';            hardy: TRUE;  void: FALSe; blood: TRUE; move: FALSE; important: FALSE; char: 'f'; color: crBLUEGREEN),
    (name: '�����, �������� ����';         hardy:  TRUE;void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBLUEGREEN),
    (name: '�����, �������� ����';         hardy:  TRUE;void: FALSE; blood: TRUE; move: FALSE; important: FALSE; char: '#'; color: crBLUEGREEN),
    (name: '���';            hardy: TRUE;  void: FALSe; blood: TRUE; move: FALSE; important: FALSE; char: '|'; color: crBROWN)
  );

{$include ../Data/Scripts/Tiles.pas}

implementation

end.
