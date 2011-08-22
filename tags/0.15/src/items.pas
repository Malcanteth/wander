unit items;

interface

uses
  Cons, Flags, Utils, Main, SysUtils, Msg, Tile, Ability;

type
  TItem = record
    id               : byte;         // �������������
    amount           : word;         // �����������
    mass             : real;         // �����
    owner            : byte;         // ��������� �� �������
  end;

  TItemData = record
    name1, name2, name3        : string[40];      // �������� (1��.�����,2��.�����,3����)
    descr                      : string[100];     // �������� ��������
    vid                        : byte;            // ��� ��������
    color                      : byte;            // ����
    mass                       : real;
    attack, defense            : word;
    chance                     : byte;            // ���� ���������
    kind                       : byte;            // ��� ������ ��� �����
    flags                      : longword;        // ������:)
  end;

const
  { ��������� ���������� ��������� }
  ItemsAmount = 37;

  {  �������� ��������� }
  ItemsData : array[1..ItemsAmount] of TItemData =
  (
    ( name1: '������� ������'; name2: '������� ������'; name3: '������� ������';
      descr: '��� ��������� ������� ������� - ������� �������� ������� � ���� ����.';
      vid:15; color: crYELLOW; mass: 0.01;
      attack: 1; defense: 0; chance: 40;
      flags : NOF;
    ),
    ( name1: '�������� ���'; name2: '�������� ����'; name3: '�������� ���';
      vid:6; color: crLIGHTGRAY; mass: 4.5;
      attack: 5; defense: 0; chance: 60; kind: CLOSE_BLADE;
      flags : NOF;
    ),
    ( name1: '����'; name2: '����'; name3: '����';
      vid:6; color: crBROWN; mass: 19.2;
      attack: 11; defense: 0;  chance: 30; kind: CLOSE_TWO;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: '����'; name2: '�����'; name3: '����';
      vid:14; color: crBROWN; mass: 0.4;
      attack: 1; defense: 240; chance: 90;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:1; color: crGRAY; mass: 3.0;
      attack: 1; defense: 1;  chance: 80;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:12; color: crBROWN; mass: 6.2;
      attack: 1; defense: 1;  chance: 90;
      flags : NOF;
    ),
    ( name1: '����'; name2: '�����'; name3: '����';
      vid:14; color: crRED; mass: 50.4;
      attack: 5; defense: 15; chance: 20;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:1; color: crBROWN; mass: 13.0;
      attack: 3; defense: 4; chance: 35;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:4; color: crPURPLE; mass: 9.1;
      attack: 1; defense: 2;  chance: 65;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:4; color: crBROWN; mass: 12.0;
      attack: 1; defense: 4; chance: 55;
      flags : NOF;
    ),
    ( name1: '��������'; name2: '��������'; name3: '��������';
      vid:4; color: crLIGHTGRAY; mass: 25.5;
      attack: 4; defense: 8; chance: 10;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '������'; name3: '�����';
      vid:6; color: crBROWN; mass: 10.7;
      attack: 8; defense: 0;  chance: 35; kind: CLOSE_STAFF;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: '������'; name2: '�������'; name3: '������';
      vid:6; color: crLIGHTGRAY; mass: 7.7;
      attack: 9; defense: 0;  chance: 60; kind: CLOSE_BLADE;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:6; color: crBROWN; mass: 16.0;
      attack: 12; defense: 0;  chance: 30; kind: CLOSE_CLUB;
      flags : NOF;
    ),
    ( name1: '�������� ���'; name2: '�������� ����'; name3: '�������� ���';
      vid:6; color: crWHITE; mass: 12.0;
      attack: 13; defense: 0;  chance: 30; kind: CLOSE_BLADE;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:6; color: crLIGHTGRAY; mass: 14.0;
      attack: 15; defense: 0; chance: 23; kind: CLOSE_CLUB;
      flags : NOF;
    ),
    ( name1: '������� ���'; name2: '������� ����'; name3: '������� ���';
      vid:6; color: crCYAN; mass: 21.0;
      attack: 17; defense: 0; chance: 15; kind: CLOSE_BLADE;
      flags : NOF or I_TWOHANDED;
    ),
    ( name1: '���'; name2: '����'; name3: '���';
      vid:8; color: crBROWN; mass: 15.2;
      attack: 7; defense: 0; chance: 15;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:12; color: crGREEN; mass: 8.7;
      attack: 4; defense: 3; chance: 35;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '������'; name3: '�����';
      vid:14; color: crBROWN; mass: 1.4;
      attack: 2; defense: 110; chance: 60;
      flags : NOF;
    ),
    ( name1: '������� ������'; name2: '������� ������'; name3: '������� ������';
      vid:14; color: crLIGHTGREEN; mass: 0.5;
      attack: 2; defense: 150; chance: 90;
      flags : NOF;
    ),
    ( name1: '����� ����'; name2: '����� ����'; name3: '����� ����';
      vid:14; color: crLIGHTRED; mass: 6.0;
      attack: 3; defense: 50; chance: 35;
      flags : NOF;
    ),
    ( name1: '����� �������'; name2: '����� �������'; name3: '����� �������';
      vid:19; color: crLIGHTBLUE; mass: 0.3;
      attack: 1; defense: 0; chance: 40;
      flags : NOF;
    ),
    ( name1: '����� ���������'; name2: '����� ���������'; name3: '����� ���������';
      vid:19; color: crRED; mass: 0.3;
      attack: 1; defense: 0; chance: 15;
      flags : NOF;
    ),
    ( name1: '������� �������� ����'; name2: '������� �������� ����'; name3: '������� �������� ����';
      vid:19; color: crBROWN; mass: 0.5;
      attack: 2; defense: 0; chance: 20;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:14; color: crBROWN; mass: 5.0;
      attack: 2; defense: 40; chance: 0;
      flags : NOF;
    ),
    ( name1: '���� �� ��������� ���� ��������'; name2: '����� �� ��������� ���� ��������'; name3: '���� �� ��������� ���� ��������';
      vid:20; color: crCYAN; mass: 0.3;
      attack: 1; defense: 0; chance: 0;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '������'; name3: '�����';
      vid:6; color: crWHITE; mass: 13.5;
      attack: 12; defense: 0;  chance: 30; kind: CLOSE_AXE;
      flags : NOF;
    ),
    ( name1: '���'; name2: '����'; name3: '���';
      vid:7; color: crBROWN; mass: 5.2;
      attack: 4; defense: 0;  chance: 20; kind: FAR_BOW;
      flags : NOF;
    ),
    ( name1: '�������'; name2: '��������'; name3: '�������';
      vid:7; color: crBROWN; mass: 8.2;
      attack: 6; defense: 0;  chance: 18; kind: FAR_CROSS;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:7; color: crGRAY; mass: 0.4;
      attack: 0; defense: 0;  chance: 25; kind: FAR_SLING;
      flags : NOF;
    ),
    ( name1: '������� ������'; name2: '������� ������'; name3: '������� ������';
      vid:7; color: crCYAN; mass: 0.2;
      attack: 0; defense: 0;  chance: 23; kind: FAR_PIPE;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:13; color: crBROWN; mass: 0.08;
      attack: 4; defense: 0;  chance: 40; kind: FAR_BOW;
      flags : NOF;
    ),
    ( name1: '����'; name2: '�����'; name3: '����';
      vid:13; color: crRED; mass: 0.20;
      attack: 4; defense: 0;  chance: 35; kind: FAR_CROSS;
      flags : NOF;
    ),
    ( name1: '��������� ������'; name2: '��������� �����'; name3: '��������� ������';
      vid:13; color: crLIGHTGRAY; mass: 0.35;
      attack: 3; defense: 0;  chance: 60; kind: FAR_SLING;
      flags : NOF;
    ),
    ( name1: '����'; name2: '����'; name3: '����';
      vid:13; color: crCYAN; mass: 0.01;
      attack: 3; defense: 0;  chance: 50; kind: FAR_PIPE;
      flags : NOF;
    ),
    ( name1: '������� �� ����� �����'; name2: '������� �� ����� �����'; name3: '������� �� ����� �����';
      vid:4; color: crBROWN; mass: 10.5;
      attack: 1; defense: 3;  chance: 45;
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
  idGATESKEY       = 27;
  idAXE            = 28;
  idBOW            = 29;
  idCROSSBOW       = 30;
  idSLING          = 31;
  idBLOWPIPE       = 32;
  idARROW          = 33;
  idBOLT           = 34;
  idLITTLEROCK     = 35;
  idIGLA           = 36;
  idCAPE           = 37;

function GenerateItem(whatvid : byte) : TItem;                // ������������ ��������� ������� ������������� ����
function CreateItem(n : byte; am : integer;
                            OwnerId : byte) : TItem;          // ������� �������
function PutItem(px,py : byte; Item : TItem;
                           amount : integer) : boolean;       // �������� �������
function ItemSymbol(id : integer) : string;                   // ������� ������ ��������
procedure WriteSomeAboutItem(Item : TItem);                   // ������� ��������� ���-�� ��������
procedure ExamineItem(Item : TItem);                          // ����������� ��������� �������
procedure ItemOnOff(Item : TItem; PutOn : boolean);           // ��������� ������ �������� ��� ������
function ItemName(Item : TItem; skl : byte;
                             all : boolean) : string;         // ������� ������ �������� ��������
procedure UseItem(n : byte);                                  // ������������ �������

implementation

uses
  Map, Player, Monsters, conf;

{ ������������ ��������� ������� ������������� ���� }
function GenerateItem(whatvid : byte) : TItem;
var
  list : array[1..ItemsAmount] of integer;
  amount, i : integer;
begin
  amount := 0;
  // ������� ������ ����������
  for i:=1 to ItemsAmount do
    if ItemsData[i].vid = whatvid then
    begin
      inc(amount);
      list[amount] := i;
    end;
  if amount > 0 then
  begin
    if amount = 1 then
      Result := CreateItem(list[amount], 1, 0) else
      begin
        repeat
          i := Random(amount)+1;
        until
          (Random(100)+1 <= ItemsData[list[i]].chance);
         Result := CreateItem(list[i], 1, 0)
      end;
  end;
end;

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
function PutItem(px,py : byte; Item : TItem; amount : integer) : boolean;
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
          inc(M.Item[px,py].amount, amount);
          exit;
        end else
          Result := False;
      end else
        begin
          M.Item[px,py] := Item;
          M.Item[px,py].amount := amount;
        end;
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
                    inc(M.Item[x,y].amount, amount);
                    Result := True;
                    break;
                  end else
                    Result := False;
                end else
                  begin
                    M.Item[x,y] := Item;
                    M.Item[x,y].amount := amount;
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
    21: Result := ';'; // �������
  end;
end;

{ ������� ��������� ���-�� �������� }
procedure WriteSomeAboutItem(Item : TItem);
var
  s, weight : string;
begin
  if Item.id > 0 then
    with Screen.Canvas do
    begin
      DrawBorder(15,31,70,4);
      // ������ �������� ��������
      s := '';
      {����� - �������� ������ ���� ��� - ������ (�������� ��� � ������}
      case ItemsData[Item.id].vid of
        6,13 : s := s + '�����: '+IntToStr(ItemsData[Item.id].attack)+' ';
      end;
      {������ - ���� ��� ����� (����, ����, ����� �� ����, ��������, �����}
      case ItemsData[Item.id].vid of
        1,3,4,11,12 : s := s + '������: '+IntToStr(ItemsData[Item.id].defense)+' ';
      end;
      // ������� ��������� �������������� ��������
      Font.Color := cCYAN;
      // ����� ��� ������, ������ ��� ����� ��� ���������� � ��� � ��
      TextOut(17*CharX, 32*CharY, s);
      // ������� ������ ��������
      Font.Color := cGRAY;
      TextOut(49*CharX, 31*CharY, '| |');
      Font.Color := RealColor(ItemsData[Item.id].color);
      TextOut(50*CharX, 31*CharY, ItemSymbol(Item.id));
      // ��� ������, ���� ��� ������
      Font.Color := cWHITE;
      if (ItemsData[Item.id].vid = 6) then
        TextOut((83-Length(CLOSEWPNNAME[ItemsData[Item.id].kind]))*CharX, 32*CharY, '"'+CLOSEWPNNAME[ItemsData[Item.id].kind]+'"');
      if (ItemsData[Item.id].vid = 7) or (ItemsData[Item.id].vid = 13) then
        TextOut((83-Length(FARWPNNAME[ItemsData[Item.id].kind]))*CharX, 32*CharY, '"'+FARWPNNAME[ItemsData[Item.id].kind]+'"');
      // ������� ��� �������� � ����� ��� ���������
      Font.Color := cLIGHTGRAY;
      weight := '����� ��������: '+FloatToStr(Item.mass)+'  ����� ����� ���������: '+FloatToStr(pc.invmass);
      TextOut((15 + ((70 - length(weight)) div 2))*CharX, 35*CharY, weight);
    end;
end;

{ ����������� ��������� ������� }
procedure ExamineItem(Item : TItem);
begin
  if ItemsData[Item.id].descr <> '' then
    AddMsg(ItemsData[Item.id].descr) else
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

{ ������������ ������� }
procedure UseItem(n : byte);
begin
  // ������� ������� (������ ������ ����������� ������������ � ���� � ����� "����� ������!")
  if pc.Inv[N].id = idCOIN then
  begin
    if pc.Inv[N].amount = 1 then
      AddMsg('��� ��� ������������� - � ���� ����� ���� ������� �������...') else
        AddMsg('�� ����������'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[N],0, TRUE)+'.');
    pc.turn := 1;
  end else
    // ������������ ������� �� ����������
    case ItemsData[pc.Inv[N].id].vid of
      // ������
      1..13:
      begin
        case pc.EquipItem(pc.Inv[N]) of
          0 :
          begin
            ItemOnOff(pc.Inv[N], TRUE);
            if (pc.Inv[N].amount > 1) and (ItemsData[pc.Inv[N].id].vid <> 13) then
              dec(pc.Inv[N].amount) else
                pc.Inv[N].id := 0;
            pc.RefreshInventory;
            N := Cell;
            GameState := gsEQUIPMENT;
          end;
          1 :
          begin
            ItemOnOff(pc.Inv[N], TRUE);
            GameState := gsPLAY;
          end;
        end;
      end;
      // ������
      14:
      begin
        if pc.status[stHUNGRY] >= 0 then
        begin
          pc.status[stHUNGRY] := pc.status[stHUNGRY] - Round(ItemsData[pc.Inv[N].id].defense * pc.Inv[N].mass * 1.3 * (1 + (pc.ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
          if pc.status[stHUNGRY] < -500 then
          begin
            AddMsg('[�� �� ����'+pc.HeSheIt(3)+' ������ '+ItemName(pc.Inv[N], 1, FALSE)+' ������, ��� ����� �������'+pc.HeSheIt(2)+'... �������� �������'+pc.HeSheIt(2)+'...]');
            pc.status[stHUNGRY] := -500;
          end else
              AddMsg('[�� ����'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[N], 1, FALSE)+'.]');
          pc.DeleteInvItem(pc.Inv[N], 1);
          pc.turn := 1;
        end else
          AddMsg('���� �� ������� ������ ����!');
      end;
      // ������
      19:
      begin
        AddMsg('�� �����'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[N], 1, FALSE)+'.');
        // �������
        if pc.Inv[N].id = idPOTIONCURE then
        begin
          if pc.Hp < pc.RHp then
          begin
            a := Random(11)+5;
            if pc.hp + a > pc.RHp then
              a := pc.RHp - pc.Hp;
            inc(pc.hp, a);
            if pc.Hp >= pc.RHp then
            begin
              AddMsg('[�� ��������� �������'+pc.HeSheIt(2)+'!] ({+'+IntToStr(a)+'})');
              pc.Hp := pc.RHp;
            end else
              AddMsg('[���� ����� ������� �����] ({+'+IntToStr(a)+'})');
          end else
            AddMsg('������ �� ���������.');
        end;
        // ���������
        if pc.Inv[N].id = idPOTIONHEAL then
        begin
          if pc.Hp < pc.RHp then
          begin
            AddMsg('[�� ��������� �������'+pc.HeSheIt(2)+'!] ({+'+IntToStr(pc.RHp-pc.Hp)+'})');
            pc.Hp := pc.RHp;
          end else
            AddMsg('������ �� ���������.');
        end;
        // �������
        if pc.Inv[N].id = idCHEAPBEER then
        begin
          if pc.status[stDRUNK] <= 500 then
          begin
            if pc.Hp < pc.RHp then
            begin
              a := Random(6)+1;
              inc(pc.hp, a);
              if pc.Hp >= pc.RHp then
              begin
                pc.Hp := pc.RHp;
                AddMsg('��� ���� - ������ ������, �� ��� �� ����� �� ������ ���������� ���� ������������!');
              end else
                AddMsg('����.. ����� �������...');
            end else
              AddMsg('�� �������� ������ ������'+pc.HeSheIt(1)+' ������� ����. �� �����. ��������!');
            inc(pc.status[stDRUNK], 130);
          end else
            AddMsg('�� �������'+pc.HeSheIt(2)+' ������ ���, �� �������� ������� ������������ �� ����� ��� � ���������!..');
        end;
        pc.DeleteInvItem(pc.Inv[N], 1);
        pc.turn := 1;
      end;
    end;
end;

end.
