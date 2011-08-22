unit items;

interface

uses
  Cons, Flags, Utils, Main, SysUtils, Msg;

type
  TItem = record
    id               : byte;         // �������������
    amount           : word;         // �����������
  end;

  TItemData = record
    name1, name2, name3        : string[40];      // �������� (1��.�����,2��.�����,3����)
    vid                        : byte;            // ��� ��������
    color                      : longword;        // ����
    mass                       : real;
    attack, defense            : word;
    flags                      : longword;        // ������:)
  end;

const
  { ��������� ���������� ��������� }
  ItemsAmount = 26;

  {  �������� ��������� }
  ItemsData : array[1..ItemsAmount] of TItemData =
  (
    ( name1: '������� ������'; name2: '������� ������'; name3: '������� ������';
      vid:15; color: cYELLOW; mass: 0.01;
      attack: 1; defense: 0;
      flags : NOF;
    ),
    ( name1: '�������� ���'; name2: '�������� ����'; name3: '�������� ���';
      vid:6; color: cLIGHTGRAY; mass: 4.5;
      attack: 6; defense: 0;
      flags : NOF;
    ),
    ( name1: '����'; name2: '����'; name3: '����';
      vid:6; color: cBROWN; mass: 19.2;
      attack: 11; defense: 0;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: '����'; name2: '�����'; name3: '����';
      vid:14; color: cBROWN; mass: 0.4;
      attack: 1; defense: 100;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:1; color: cGRAY; mass: 3.0;
      attack: 1; defense: 1;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:12; color: cBROWN; mass: 6.2;
      attack: 2; defense: 2;
      flags : NOF;
    ),
    ( name1: '����'; name2: '�����'; name3: '����';
      vid:14; color: cRED; mass: 50.4;
      attack: 5; defense: 900;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:1; color: cBROWN; mass: 13.0;
      attack: 3; defense: 5;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:4; color: cPURPLE; mass: 9.1;
      attack: 1; defense: 2;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:4; color: cBROWN; mass: 12.0;
      attack: 1; defense: 4;
      flags : NOF;
    ),
    ( name1: '��������'; name2: '��������'; name3: '��������';
      vid:4; color: cLIGHTGRAY; mass: 25.5;
      attack: 4; defense: 8;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '������'; name3: '�����';
      vid:6; color: cBROWN; mass: 10.7;
      attack: 15; defense: 0;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: '������'; name2: '�������'; name3: '������';
      vid:6; color: cLIGHTGRAY; mass: 7.7;
      attack: 11; defense: 0;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:6; color: cBROWN; mass: 16.0;
      attack: 18; defense: 0;
      flags : NOF;
    ),
    ( name1: '�������� ���'; name2: '�������� ����'; name3: '�������� ���';
      vid:6; color: cWHITE; mass: 12.0;
      attack: 13; defense: 0;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:6; color: cLIGHTGRAY; mass: 14.0;
      attack: 20; defense: 0;
      flags : NOF;
    ),
    ( name1: '������� ���'; name2: '������� ����'; name3: '������� ���';
      vid:6; color: cCYAN; mass: 21.0;
      attack: 23; defense: 0;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: '���'; name2: '����'; name3: '���';
      vid:8; color: cBROWN; mass: 15.2;
      attack: 7; defense: 0;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:12; color: cGREEN; mass: 8.7;
      attack: 4; defense: 3;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '������'; name3: '�����';
      vid:14; color: cBROWN; mass: 1.4;
      attack: 2; defense: 250;
      flags : NOF;
    ),
    ( name1: '������� ������'; name2: '������� ������'; name3: '������� ������';
      vid:14; color: cLIGHTGREEN; mass: 0.5;
      attack: 2; defense: 90;
      flags : NOF;
    ),
    ( name1: '����� ����'; name2: '����� ����'; name3: '����� ����';
      vid:14; color: cLIGHTRED; mass: 6.0;
      attack: 3; defense: 500;
      flags : NOF;
    ),
    ( name1: '����� �������'; name2: '����� �������'; name3: '����� �������';
      vid:19; color: cLIGHTBLUE; mass: 0.3;
      attack: 1; defense: 0;
      flags : NOF;
    ),
    ( name1: '����� ���������'; name2: '����� ���������'; name3: '����� ���������';
      vid:19; color: cRED; mass: 0.3;
      attack: 1; defense: 0;
      flags : NOF;
    ),
    ( name1: '������� �������� ����'; name2: '������� �������� ����'; name3: '������� �������� ����';
      vid:19; color: cBROWN; mass: 0.5;
      attack: 2; defense: 0;
      flags : NOF;
    ),
    ( name1: '����� ������ �������'; name2: '����� ������ �������'; name3: '����� ������ �������';
      vid:14; color: cBROWN; mass: 2.4;
      attack: 2; defense: 300;
      flags : NOF;
    )
  );

  { ���������� �������������� ��������� }
  idCOIN           = 1;
  idKITCHENKNIFE   = 2;
  idPITCHFORK      = 3;
  idKEKS           = 4;
  idJACKSONSHAT    = 5;
  idLAPTI          = 6;
  idCORPSE         = 7;
  idHELMET         = 8;
  idMANTIA         = 9;
  idJACKET         = 10;
  idCHAINARMOR     = 11;
  idSTAFF          = 12;
  idDAGGER         = 13;
  idDUBINA         = 14;
  idSHORTSWORD     = 15;
  idPALICA         = 16;
  idLONGSWORD      = 17;
  idSHIELD         = 18;
  idBOOTS          = 19;
  idLAVASH         = 20;
  idGREENAPPLE     = 21;
  idMEAT           = 22;
  idPOTIONCURE     = 23;
  idPOTIONHEAL     = 24;
  idCHEAPBEER      = 25;
  idBLINDBEASTHEAD = 26;

function CreateItem(n : byte; am : integer) : TItem;          // ������� �������
function PutItem(px,py : byte; Item : TItem) : boolean;       // �������� �������
function ItemSymbol(id : integer) : string;                   // ������� ������ ��������
procedure WriteSomeAboutItem(Item : TItem);                   // ������� ��������� ���-�� ��������
procedure ExamineItem(Item : TItem);                          // ����������� ��������� �������
procedure ItemOnOff(Item : TItem; PutOn : boolean);           // ��������� ������ �������� ��� ������

implementation

uses
  Map, Player;

{ ������� ������� }
function CreateItem(n : byte; am : integer) : TItem;
var
  Item : TItem;
begin
  with Item do
  begin
    id := n;
    amount := am;
  end;
  Result := Item;
end;

{ �������� ������� }
function PutItem(px,py : byte; Item : TItem) : boolean;
begin
  Result := True;
  if M.Item[px,py].id > 0 then
  begin
    if M.Item[px,py].id = Item.id then
    begin
      inc(M.Item[px,py].amount, Item.amount);
      exit;
    end else
      Result := False;
  end else
    M.Item[px,py] := Item;
end;

{ ������� ������ �������� }
function ItemSymbol(id : integer) : string;
begin
  case ItemsData[id].vid of
    1 : Result := '['; // ����
    2 : Result := '&'; // ������
    3 : Result := ']'; // ����
    4 : Result := '['; // ����� �� ����
    5 : Result := '~'; // ������
    6 : Result := ')'; // ������ �������� ���
    7 : Result := '}'; // ������ �������� ���
    8 : Result := '['; // ���
    9 : Result := '&'; // �������
    10 : Result := '='; // ������
    11: Result := ']'; // ��������
    12: Result := '['; // �����
    13: Result := '`'; // ���������
    14: Result := '%'; // ���
    15: Result := '$'; // ������
    16: Result := '?'; // ������
    17: Result := '"'; // �����
    18: Result := '\'; // ��������� �������
    19: Result := '!'; // �����
    20: Result := '{'; // ����������
  end;
end;

{ ������� ��������� ���-�� �������� }
procedure WriteSomeAboutItem(Item : TItem);
begin
  if Item.id > 0 then
    with Screen.Canvas do
    begin
      DrawBorder(15,29,70,4);
      // ������� ��������� �������������� ��������
      Font.Color := cWHITE;
      TextOut(17*CharX, 30*CharY, '�����: '+IntToStr(ItemsData[Item.id].attack)+'  ������: '+IntToStr(ItemsData[Item.id].defense));
      TextOut(17*CharX, 32*CharY, '���: '+FloatToStr(ItemsData[Item.id].mass));
      Font.Color := cGRAY;
      TextOut(81*CharX, 32*CharY, '[ ]');
      Font.Color := ItemsData[Item.id].color;
      TextOut(82*CharX, 32*CharY, ItemSymbol(Item.id));
    end;
end;

{ ����������� ��������� ������� }
procedure ExamineItem(Item : TItem);
begin
  if Item.amount = 1 then
    AddMsg('�� ����������� �������������� '+ItemsData[Item.id].name3+', �� �� ������ ������ ����������.') else
      AddMsg('�� ����������� �������������� '+ItemsData[Item.id].name2+', �� �� ������ ������ ����������.');
end;

{ ��������� ������ �������� ��� ������ }
procedure ItemOnOff(Item : TItem; PutOn : boolean);
var
  n : shortint;
begin
  if puton then n := 1 else n := -1;
  pc.defense := pc.defense + n * ItemsData[Item.id].defense;
end;
end.
