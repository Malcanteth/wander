unit items;

interface

uses
  Cons, Flags, Utils, Main, SysUtils, Msg, Tile;

type
  TItem = record
    id               : byte;         // �������������
    amount           : word;         // �����������
    mass             : real;         // �����
    owner            : byte;         // ��������� �� �������
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
      attack: 5; defense: 0;
      flags : NOF;
    ),
    ( name1: '����'; name2: '����'; name3: '����';
      vid:6; color: cBROWN; mass: 19.2;
      attack: 9; defense: 0;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: '����'; name2: '�����'; name3: '����';
      vid:14; color: cBROWN; mass: 0.4;
      attack: 1; defense: 240;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:1; color: cGRAY; mass: 3.0;
      attack: 1; defense: 1;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:12; color: cBROWN; mass: 6.2;
      attack: 1; defense: 1;
      flags : NOF;
    ),
    ( name1: '����'; name2: '�����'; name3: '����';
      vid:14; color: cRED; mass: 50.4;
      attack: 5; defense: 15;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:1; color: cBROWN; mass: 13.0;
      attack: 3; defense: 4;
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
      attack: 8; defense: 0;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: '������'; name2: '�������'; name3: '������';
      vid:6; color: cLIGHTGRAY; mass: 7.7;
      attack: 9; defense: 0;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:6; color: cBROWN; mass: 16.0;
      attack: 12; defense: 0;
      flags : NOF;
    ),
    ( name1: '�������� ���'; name2: '�������� ����'; name3: '�������� ���';
      vid:6; color: cWHITE; mass: 12.0;
      attack: 13; defense: 0;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:6; color: cLIGHTGRAY; mass: 14.0;
      attack: 15; defense: 0;
      flags : NOF;
    ),
    ( name1: '������� ���'; name2: '������� ����'; name3: '������� ���';
      vid:6; color: cCYAN; mass: 21.0;
      attack: 17; defense: 0;
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
      attack: 2; defense: 110;
      flags : NOF;
    ),
    ( name1: '������� ������'; name2: '������� ������'; name3: '������� ������';
      vid:14; color: cLIGHTGREEN; mass: 0.5;
      attack: 2; defense: 150;
      flags : NOF;
    ),
    ( name1: '����� ����'; name2: '����� ����'; name3: '����� ����';
      vid:14; color: cLIGHTRED; mass: 6.0;
      attack: 3; defense: 50;
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
    ( name1: '������'; name2: '������'; name3: '������';
      vid:14; color: cBROWN; mass: 5.0;
      attack: 2; defense: 40;
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
  idHEAD           = 26;

function CreateItem(n : byte; am : integer;
                            OwnerId : byte) : TItem;          // ������� �������
function PutItem(px,py : byte; Item : TItem) : boolean;       // �������� �������
function ItemSymbol(id : integer) : string;                   // ������� ������ ��������
procedure WriteSomeAboutItem(Item : TItem);                   // ������� ��������� ���-�� ��������
procedure ExamineItem(Item : TItem);                          // ����������� ��������� �������
procedure ItemOnOff(Item : TItem; PutOn : boolean);           // ��������� ������ �������� ��� ������
function ItemName(Item : TItem; skl : byte;
                             all : boolean) : string;         // ������� ������ �������� ��������

implementation

uses
  Map, Player, Monsters;

{ ������� ������� }
function CreateItem(n : byte; am : integer; OwnerId : byte) : TItem;
var
  Item : TItem;
begin
  with Item do
  begin
    id := n;
    amount := am;
    mass := ItemsData[id].mass;
    owner := OwnerId;
    // ������ ����� �����, �� ����� ������� ������� (-20%)
    if id = idCORPSE then
      mass := MonstersData[owner].mass - Round(MonstersData[owner].mass * 0.20);
    // ������ ����� ������, �� ����� 15% ���� �����
    if id = idHEAD then
      mass := Round(MonstersData[owner].mass * 0.15);
  end;
  Result := Item;
end;

{ �������� ������� }
function PutItem(px,py : byte; Item : TItem) : boolean;
var
  x, y : integer;
begin
  Result := True;
  if not TilesData[M.Tile[px,py]].move then
    Result := False else
      if M.Item[px,py].id > 0 then
      begin
        if (M.Item[px,py].id = Item.id) and (M.Item[px,py].owner = Item.owner) then
        begin
          inc(M.Item[px,py].amount, Item.amount);
          exit;
        end else
          Result := False;
      end else
        M.Item[px,py] := Item;
  // ���� ������ ������ ������� �� ��������� �����, ����������� ������ ��� � ������������
  if Result = False then
  begin
    for x:=px-1 to px+1 do
    begin
      for y:=py-1 to py+1 do
        if (x > 0) and (x <=MapX) and (y > 0) and (y <= MapY) then
          if NOT ((x=px)and(y=py)) then
          begin
            if not TilesData[M.Tile[x,y]].move then
              Result := False else
                if M.Item[x,y].id > 0 then
                begin
                  if (M.Item[x,y].id = Item.id) and (M.Item[px,py].owner = Item.owner) then
                  begin
                    inc(M.Item[x,y].amount, Item.amount);
                    Result := True;
                    break;
                  end else
                    Result := False;
                end else
                  begin
                    M.Item[x,y] := Item;
                    Result := True;
                    break;
                  end;
          end;
      if Result = True then break;
    end;
  end;
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
      DrawBorder(15,31,70,4);
      // ������� ��������� �������������� ��������
      Font.Color := cWHITE;
      TextOut(17*CharX, 32*CharY, '�����: '+IntToStr(ItemsData[Item.id].attack)+'  ������: '+IntToStr(ItemsData[Item.id].defense));
      TextOut(17*CharX, 34*CharY, '���: '+FloatToStr(Item.mass));
      Font.Color := cGRAY;
      TextOut(81*CharX, 34*CharY, '| |');
      Font.Color := ItemsData[Item.id].color;
      TextOut(82*CharX, 34*CharY, ItemSymbol(Item.id));
    end;
end;

{ ����������� ��������� ������� }
procedure ExamineItem(Item : TItem);
begin
  AddMsg('�� ����������� �������������� '+ItemName(Item, 1, TRUE)+', �� �� ������ ������ ����������.');
end;

{ ��������� ������ �������� ��� ������ }
procedure ItemOnOff(Item : TItem; PutOn : boolean);
var
  n : shortint;
begin
  if puton then n := 1 else n := -1;
  pc.defense := pc.defense + n * ItemsData[Item.id].defense;
end;

{ ������� ������ �������� �������� SKL = 0 ���? SKL = 1 ����? ����? }
function ItemName(Item : TItem;  skl : byte; all : boolean) : string;
var
  s : string;
begin
  case SKL of
    0 :
    if (Item.amount = 1) or (not ALL) then
     s := ItemsData[Item.id].name1 else
       s := ItemsData[Item.id].name2;
    1 :
    if (Item.amount = 1) or (not ALL) then
     s := ItemsData[Item.id].name3 else
       s := ItemsData[Item.id].name2;
  end;
  if Item.owner > 0 then
    if (Item.amount = 1) or (not ALL) then
      s := s + ' ' + MonstersData[Item.owner].name5 else
        s := s + ' ' + MonstersData[Item.owner].name6;
  if (Item.amount > 1) and (ALL) then
    s := s + ' ('+IntToStr(Item.amount)+' ��)';
  Result := s;
end;

end.