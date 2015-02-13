unit items;

interface

uses
  Cons, Flags, Utils, Main, SysUtils, Msg, Tile, Ability;

type
  TItemType = record
    name     : string[20];
    symbol   : char;
    chance   : byte;                 // ��� ����� �������� ������� ���� ����� ���������� �� �����
    maxamount: integer;
  end;

  TItem = record
    id               : byte;         // �������������
    amount           : word;         // �����������
    mass             : real;         // �����
    owner            : byte;         // ��������� �� �������
    liquidid         : byte;         // ID �������
  end;

const
  { ���-�� ����� ���������}
  ItemTypeAmount = 22;

  ItemTypeData : array[1..ItemTypeAmount] of TItemType =
  (
    (name: '����'; symbol: '['; chance:15;maxamount:1),
    (name: '������'; symbol: '&'; chance:5;maxamount:1),
    (name: '�������'; symbol: ']'; chance:20;maxamount:1),
    (name: '�����'; symbol: '['; chance:20;maxamount:1),
    (name: '������'; symbol: '~'; chance:10;maxamount:1),
    (name: '������ �������� ���'; symbol: ')'; chance:30;maxamount:1),
    (name: '������ �������� ���'; symbol: '}'; chance:30;maxamount:1),
    (name: '���'; symbol: '['; chance:15;maxamount:1),
    (name: '�������'; symbol: '&'; chance:5;maxamount:1),
    (name: '������'; symbol: '='; chance:4;maxamount:1),
    (name: '��������'; symbol: ']'; chance:10;maxamount:1),
    (name: '�����'; symbol: '['; chance:20;maxamount:1),
    (name: '��������'; symbol: '`'; chance:50;maxamount:15),
    (name: '���'; symbol: '%'; chance:70;maxamount:4),
    (name: '������'; symbol: '$'; chance:40;maxamount:30),
    (name: '������'; symbol: '?'; chance:20;maxamount:1),
    (name: '�����'; symbol: '"'; chance:7;maxamount:1),
    (name: '��������� �������'; symbol: '\'; chance:9;maxamount:1),
    (name: '�����'; symbol: '!'; chance:25;maxamount:1),
    (name: '����������'; symbol: '{'; chance:5;maxamount:1),
    (name: '�������'; symbol: ';'; chance:40;maxamount:1),
    (name: '��������'; symbol: '^'; chance:10;maxamount:1)
  );
  
type
  TItemData = record
    name1, name2, name3        : string[40];      // �������� (1��.�����,2��.�����,3����)
    descr                      : string[100];     // �������� ��������
    vid                        : byte;            // ��� ��������
    color                      : byte;            // ����
    mass                       : real;
    attack, defense            : word;
    chance                     : byte;            // ���� ���������
    kind                       : byte;            // ��� ������ ��� �����
    dmgtype                    : byte;            // ��� �����
    flags                      : longword;        // ������:)
  end;

const
 { ���-�� ��������� }
  ItemsAmount = 36;
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
      attack: 1; defense: 1;  chance: 80; kind: ARMOR_CLOTHES;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:12; color: crBROWN; mass: 6.2;
      attack: 1; defense: 1;  chance: 90; kind: ARMOR_CLOTHES;
      flags : NOF;
    ),
    ( name1: '����'; name2: '�����'; name3: '����';
      vid:14; color: crRED; mass: 50.4;
      attack: 5; defense: 15; chance: 20;
      flags : NOF;
    ),
    ( name1: '�����'; name2: '�����'; name3: '�����';
      vid:1; color: crBROWN; mass: 13.0;
      attack: 3; defense: 4; chance: 35; kind: ARMOR_LIGHT;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:3; color: crPURPLE; mass: 9.1;
      attack: 1; defense: 2;  chance: 65; kind: ARMOR_CLOTHES;
      flags : NOF;
    ),
    ( name1: '������'; name2: '������'; name3: '������';
      vid:4; color: crBROWN; mass: 12.0;
      attack: 1; defense: 4; chance: 55; kind: ARMOR_CLOTHES;
      flags : NOF;
    ),
    ( name1: '��������'; name2: '��������'; name3: '��������';
      vid:4; color: crLIGHTGRAY; mass: 25.5;
      attack: 4; defense: 8; chance: 10; kind: ARMOR_LIGHT;
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
      attack: 4; defense: 3; chance: 35; kind: ARMOR_CLOTHES;
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
      attack: 1; defense: 3;  chance: 45; kind: ARMOR_CLOTHES;
      flags : NOF;
    ),
    ( name1: '�������'; name2: '�������'; name3: '�������';
      vid:19; color: crCYAN; mass: 0.1;
      attack: 1; defense: 0; chance: 40;
      flags : NOF;
    ),
    ( name1: '������ ����������'; name2: '����� ����������'; name3: '������ ����������';
      vid:22; color: crBROWN; mass: 4;
      attack: 0; defense: 0; chance: 5;
      flags : NOF;
    )
  );

{$include ../Data/Scripts/Items.pas}

function HaveItemTypeInDB(wtype : byte) : boolean;            // ���� �� ������� ������� ���� � ���� (������ �������, ����� ���������� ���� ����� ���������)
function GenerateItem(wtype : byte) : TItem;                  // ������������ ��������� ������� ������������� ����
function CreateItem(n : byte; am : integer;
                            OwnerId : byte) : TItem;          // ������� �������
function PutItem(px,py : byte; Item : TItem;
                           amount : integer) : boolean;       // �������� �������
procedure WriteSomeAboutItem(Item : TItem; compare: boolean = false); // ������� ��������� ���-�� ��������
procedure ExamineItem(Item : TItem);                          // ����������� ��������� �������
procedure ItemOnOff(Item : TItem; PutOn : boolean);           // ��������� ������ �������� ��� ������
function ItemName(Item : TItem; skl : byte;
                             all : boolean) : string;         // ������� ������ �������� ��������
procedure UseItem(SelectedItem : byte);                       // ������������ ������� � ���������
function SameItems(I1, I2 : TItem) : boolean;                 // �������� ��� �������� - ��������� �� ���?
function ItemColor(I : TItem) : byte;                         // ������� ���� ��������

implementation

uses
  Map, Player, Monsters, Conf, Liquid;

{ ���� �� ������� ������� ���� � ���� (������ �������, ����� ���������� ���� ����� ���������) }
function HaveItemTypeInDB(wtype : byte) : boolean;
var
  i : integer;
  e : boolean;
begin
  e := FALSE;
  for i:=1 to ItemsAmount do
    if (ItemsData[i].vid = wtype) and (ItemsData[i].chance > 0) then
    begin
      e := TRUE;
      break;
    end;
  Result := e;
end;

{ ������������ ��������� ������� ������������� ���� }
function GenerateItem(wtype : byte) : TItem;
var
  list : array[1..ItemsAmount] of integer;
  amount, i : integer;
begin
  amount := 0;
  // ������� ������ ����������
  for i:=1 to ItemsAmount do
    if ItemsData[i].vid = wtype then
    begin
      inc(amount);
      list[amount] := i;
    end;
  if amount > 0 then
  begin
    if amount = 1 then
      i := amount else
      begin
        repeat
          i := Random(amount)+1;
        until
          (Random(100)+1 <= ItemsData[list[i]].chance);
      end;
  end;
  if i <> idBOTTLE then
    Result := CreateItem(list[i], 1, 0) else
      Result := CreatePotion(list[i], 1);    
end;

{ ������� ������� }
function CreateItem(n : byte; am : integer; OwnerId : byte) : TItem;
var
  Item : TItem;
  i    : integer;
begin
  with Item do
  begin
    id := n;
    amount := am;
    mass := ItemsData[id].mass;
    owner := OwnerId;
    // ������ ����� �����, �� ����� ������� ������� (-20%)
    if id = idCORPSE then
      mass := Round(MonstersData[owner].mass * 0.8);
    // ������ ����� ������, �� ����� 15% ���� �����
    if id = idHEAD then
      mass := Round(MonstersData[owner].mass * 0.15);
    // ���� �������, �� ��������� �� ��������
    if id = idBOTTLE then
    begin
      repeat
        i := Random(LiquidAmount)+1;
      until
        (Random(100)+1 <= AllLiquid[i].chance);
      liquidid := i;
    end;
  end;
  Result := Item;
end;

{ �������� ������� }
function PutItem(px,py : byte; Item : TItem; amount : integer) : boolean;
var
  x, y : integer;
begin
  Result := True;
  if Amount > 0 then Item.amount := amount;
  if not TilesData[M.Tile[px,py]].move then
    Result := False else
      if M.Item[px,py].id > 0 then
      begin
        if SameItems(M.Item[px,py], Item) then
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
                  if SameItems(M.Item[x,y], Item) then
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

{ ������� ��������� ���-�� �������� }
procedure WriteSomeAboutItem(Item : TItem; compare: boolean = false);
var
  s : string;
  cell: byte;
  t : shortint;
begin
  if Item.id > 0 then
    with Screen.Canvas do
    begin
      DrawBorder(15,31,70,4,crLIGHTGRAY);
      // ������ �������� ��������
      s := '';
      case ItemsData[Item.id].vid of
      {������ - ���� ��� ����� (����, ����, ����� �� ����, ��������, �����}
        1,3,4,11,12 : begin
          t := ItemsData[Item.id].defense;
          s := s + '������: '+IntToStr(t)+' ';
          if compare then begin
            s := s + '(';
            cell := Vid2Eq(ItemsData[Item.id].vid);
            if (pc.eq[cell].id<>0) then dec(t,ItemsData[pc.eq[cell].id].defense);
            if t > 0 then s:= s + '+';
            s := s + inttostr(t)+') ';
          end;
        end;
      {����� - �������� ������ ���� ��� - ������ (�������� ��� � ������}
        6,13 : begin
          t := ItemsData[Item.id].attack;
          s := s + '�����: '+IntToStr(t)+' ';
          if compare then begin
            s := s + '(';          
            cell := Vid2Eq(ItemsData[Item.id].vid);
            if (pc.eq[cell].id<>0) then dec(t,ItemsData[pc.eq[cell].id].attack);
            if t > 0 then s:= s + '+';
            s := s + inttostr(t)+') ';
          end;
        end;
      end;
      // ����� ��������
      s := s + '�����: '+FloatToStr(Item.mass);
      // ������� ��������� �������������� ��������
      Font.Color := cCYAN;
      // ����� ��� ������, ������ ��� ����� ��� ���������� � ��� � ��
      TextOut(17*CharX, 32*CharY, s);
      // ������� ������ ��������
      Font.Color := cLIGHTGRAY;
      TextOut(49*CharX, 31*CharY, '| |');
      Font.Color := RealColor(ItemColor(Item));
      TextOut(50*CharX, 31*CharY, ItemTypeData[ItemsData[Item.id].vid].symbol);
      // ��� ������, ���� ��� ������
      Font.Color := cGREEN;
      if (ItemsData[Item.id].vid = 6) then
        TextOut((83-Length(CLOSEWPNNAME[ItemsData[Item.id].kind]))*CharX, 32*CharY, '"'+CLOSEWPNNAME[ItemsData[Item.id].kind]+'"');
      if (ItemsData[Item.id].vid = 7) or (ItemsData[Item.id].vid = 13) then
        TextOut((83-Length(FARWPNNAME[ItemsData[Item.id].kind]))*CharX, 32*CharY, '"'+FARWPNNAME[ItemsData[Item.id].kind]+'"');
      // ��� �����, ���� ��� ����� ��� �����
      if (ItemsData[Item.id].vid = 4) or (ItemsData[Item.id].vid = 12) then
        TextOut((83-Length(ARMORTYPENAME[ItemsData[Item.id].kind]))*CharX, 32*CharY, '"'+ARMORTYPENAME[ItemsData[Item.id].kind]+'"');
    end;
end;

{ ����������� ��������� ������� }
procedure ExamineItem(Item : TItem);
begin
  if ItemsData[Item.id].descr <> '' then
    AddMsg(ItemsData[Item.id].descr,0) else
      AddMsg('�� ����������� �������������� '+ItemName(Item, 1, TRUE)+', �� �� ������ ������ ����������.',0);
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
  // �������
  if Item.id = idBOTTLE then
  begin
    // �������� ��� ������������������� �������:
    s := s + ' ' + AllLiquid[Item.liquidid].name;
    // �������� ��� �� ������������������� �������:
    //s := s + ' � ' + LiquidState[NowLiquidState[Item.liquidid]] + ' ' + LiquidColor[NowLiquidColor[Item.liquidid]] + ' ���������';
  end;
  if Item.owner > 0 then
  begin
    // ���� ���������� - ��
    if Item.owner = 1 then
    begin
    end else
      begin
        if (Item.amount = 1) or (not ALL) then
          s := s + ' ' + MonstersData[Item.owner].name5 else
            s := s + ' ' + MonstersData[Item.owner].name6;
      end;
  end;
  if (Item.amount > 1) and (ALL) then
    s := s + ' ('+IntToStr(Item.amount)+' ��)';
  Result := s;
end;

{ ������������ ������� � ���������}
procedure UseItem(SelectedItem : byte);
begin
  // ������� ������� (������ ������ ����������� ������������ � ���� � ����� "����� ������!")
  if pc.Inv[SelectedItem].id = idCOIN then
  begin
    if pc.Inv[SelectedItem].amount = 1 then
      AddMsg('��� ��� ������������� - � ���� ����� ���� ������� �������...',0) else
        AddMsg('�� ����������{/a} '+ItemName(pc.Inv[SelectedItem],0, TRUE)+'.',0);
    ChangeGameState(gsPLAY);
  end else
    // ������������ ������� �� ����������
    case ItemsData[pc.Inv[SelectedItem].id].vid of
      // ������
      1..13:
      begin
        MenuSelected := Vid2Eq(ItemsData[pc.Inv[SelectedItem].id].vid);
        case pc.EquipItem(pc.Inv[SelectedItem], TRUE) of
          0 :
          begin
            ItemOnOff(pc.Inv[SelectedItem], TRUE);
            if (pc.Inv[SelectedItem].amount > 1) and (ItemsData[pc.Inv[SelectedItem].id].vid <> 13) then
              dec(pc.Inv[SelectedItem].amount) else
                pc.Inv[SelectedItem].id := 0;
            pc.RefreshInventory;
          end;
          1 :
          begin
            ItemOnOff(pc.Inv[SelectedItem], TRUE);
            GameState := gsPLAY;
          end;
        end;
        ChangeGameState(gsEQUIPMENT);
      end;
      // ������
      14, 22:
      begin
        if pc.status[stHUNGRY] >= 0 then
        begin
          pc.status[stHUNGRY] := pc.status[stHUNGRY] - Round(ItemsData[pc.Inv[SelectedItem].id].defense * pc.Inv[SelectedItem].mass * 1.3 * (1 + (pc.ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
          if pc.status[stHUNGRY] < -500 then
          begin
            AddMsg('#�� �� ����{/��} ������ '+ItemName(pc.Inv[SelectedItem], 1, FALSE)+' ������, ��� ����� �������{��/���}... �������� �������{��/���}...#',0);
            pc.status[stHUNGRY] := -500;
          end else
              AddMsg('#�� ����{/a} '+ItemName(pc.Inv[SelectedItem], 1, FALSE)+'.#',0);
          pc.DeleteItemInv(SelectedItem, 1, 1);
          pc.turn := 1;
        end else
          AddMsg('���� �� ������� ������ ����!',0);
        ChangeGameState(gsPLAY);
      end;
      // ������
      19:
      begin
        AddMsg('�� �����{/a} '+ItemName(pc.Inv[SelectedItem], 1, FALSE)+'.',0);
        DrinkLiquid(pc.Inv[SelectedItem].liquidid, pc);
        pc.DeleteItemInv(SelectedItem, 1, 1);
        pc.turn := 1;
        ChangeGameState(gsPLAY);
      end;
    end;
end;

{ �������� ��� �������� - ��������� �� ���? }
function SameItems(I1, I2 : TItem) : boolean;
begin
  Result := FALSE;
  if (I1.id = I2.id) and (I1.owner = I2.owner) then
  begin
    // ���� ��� ������� �� �������� ��� �� �����������
    if I1.id = idBOTTLE then
    begin
      if (I1.liquidid = I2.liquidid) then
        Result := TRUE;
    end else
      Result := TRUE;
  end;
end;

{ ������� ���� �������� }
function ItemColor(I : TItem) : byte;
begin
  Result := 3;
  Result := ItemsData[I.id].color;
  // ���� �������
  if (I.id = idBOTTLE) and (I.liquidid > 0) then
    Result := NowLiquidColor[I.liquidid];
end;

end.
