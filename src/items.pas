unit items;

interface

uses
  Cons, Flags, Utils, Main, SysUtils, Msg, Tile, Ability;

type
  TItemType = record
    Name: string[20];
    Symbol: Char;
    Chance: Byte; // ��� ����� �������� ������� ���� ����� ���������� �� �����
    MaxAmount: Integer;
  end;

  TItem = record
    Id: Byte; // �������������
    Amount: word; // �����������
    Mass: real; // �����
    Owner: Byte; // ��������� �� �������
    LiquidId: Byte; // ID �������
  end;

const
  { ���-�� ����� ��������� }
  ItemTypeAmount = 22;

  ItemTypeData: array [1 .. ItemTypeAmount] of TItemType = (
    //
    (name: '����'; Symbol: '['; Chance: 15; MaxAmount: 1),
    //
    (name: '������'; Symbol: '&'; Chance: 5; MaxAmount: 1),
    //
    (name: '�������'; Symbol: ']'; Chance: 20; MaxAmount: 1),
    //
    (name: '�����'; Symbol: '['; Chance: 20; MaxAmount: 1),
    //
    (name: '������'; Symbol: '~'; Chance: 10; MaxAmount: 1),
    //
    (name: '������ �������� ���'; Symbol: ')'; Chance: 30; MaxAmount: 1),
    //
    (name: '������ �������� ���'; Symbol: '}'; Chance: 30; MaxAmount: 1),
    //
    (name: '���'; Symbol: '['; Chance: 15; MaxAmount: 1),
    //
    (name: '�������'; Symbol: '&'; Chance: 5; MaxAmount: 1),
    //
    (name: '������'; Symbol: '='; Chance: 4; MaxAmount: 1),
    //
    (name: '��������'; Symbol: ']'; Chance: 10; MaxAmount: 1),
    //
    (name: '�����'; Symbol: '['; Chance: 20; MaxAmount: 1),

    (name: '��������'; Symbol: '`'; Chance: 50; MaxAmount: 15),
    //
    (name: '���'; Symbol: '%'; Chance: 70; MaxAmount: 4),
    //
    (name: '������'; Symbol: '$'; Chance: 40; MaxAmount: 30),
    //
    (name: '������'; Symbol: '?'; Chance: 20; MaxAmount: 1),
    //
    (name: '�����'; Symbol: '"'; Chance: 7; MaxAmount: 1),
    //
    (name: '��������� �������'; Symbol: '\'; Chance: 9; MaxAmount: 1),
    //
    (name: '�����'; Symbol: '!'; Chance: 25; MaxAmount: 1),
    //
    (name: '����������'; Symbol: '{'; Chance: 5; MaxAmount: 1),
    //
    (name: '�������'; Symbol: ';'; Chance: 40; MaxAmount: 1),
    //
    (name: '��������'; Symbol: '^'; Chance: 50; MaxAmount: 1)
    //
    );

type
  TItemData = record
    Name1, Name2, Name3: string[40]; // �������� (1��.�����,2��.�����,3����)
    Descr: string[100]; // �������� ��������
    Vid: Byte; // ��� ��������
    Color: Byte; // ����
    Mass: real;
    Attack, Defense: word;
    Chance: Byte; // ���� ���������
    Kind: Byte; // ��� ������ ��� �����
    DmgType: Byte; // ��� �����
    Flags: LongWord; // ������:)
  end;

const
  { ���-�� ��������� }
  ItemsAmount = 36;
  { �������� ��������� }
  ItemsData: array [1 .. ItemsAmount] of TItemData = (
    //
    (Name1: '������� ������'; Name2: '������� ������'; Name3: '������� ������';
    Descr: '��� ��������� ������� ������� - ������� �������� ������� � ���� ����.'; Vid: 15; Color: crYELLOW; Mass: 0.01; Attack: 1; Defense: 0;
    Chance: 40; Flags: NOF;),
    //
    (Name1: '�������� ���'; Name2: '�������� ����'; Name3: '�������� ���'; Vid: 6; Color: crLIGHTGRAY; Mass: 4.5; Attack: 5; Defense: 0; Chance: 60;
    Kind: CLOSE_BLADE; Flags: NOF;),
    //
    (Name1: '����'; Name2: '����'; Name3: '����'; Vid: 6; Color: crBROWN; Mass: 19.2; Attack: 11; Defense: 0; Chance: 30; Kind: CLOSE_TWO;
    Flags: NOF or I_TWOHANDED;),
    //
    (Name1: '����'; Name2: '�����'; Name3: '����'; Vid: 14; Color: crBROWN; Mass: 0.4; Attack: 1; Defense: 240; Chance: 90; Flags: NOF;),
    //
    (Name1: '�����'; Name2: '�����'; Name3: '�����'; Vid: 1; Color: crGRAY; Mass: 3.0; Attack: 1; Defense: 1; Chance: 80; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: '�����'; Name2: '�����'; Name3: '�����'; Vid: 12; Color: crBROWN; Mass: 6.2; Attack: 1; Defense: 1; Chance: 90; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: '����'; Name2: '�����'; Name3: '����'; Vid: 14; Color: crRED; Mass: 50.4; Attack: 5; Defense: 15; Chance: 20; Flags: NOF;),
    //
    (Name1: '�����'; Name2: '�����'; Name3: '�����'; Vid: 1; Color: crBROWN; Mass: 13.0; Attack: 3; Defense: 4; Chance: 35; Kind: ARMOR_LIGHT;
    Flags: NOF;),
    //
    (Name1: '������'; Name2: '������'; Name3: '������'; Vid: 3; Color: crPURPLE; Mass: 9.1; Attack: 1; Defense: 2; Chance: 65; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: '������'; Name2: '������'; Name3: '������'; Vid: 4; Color: crBROWN; Mass: 12.0; Attack: 1; Defense: 4; Chance: 55; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: '��������'; Name2: '��������'; Name3: '��������'; Vid: 4; Color: crLIGHTGRAY; Mass: 25.5; Attack: 4; Defense: 8; Chance: 10;
    Kind: ARMOR_LIGHT; Flags: NOF;),
    //
    (Name1: '�����'; Name2: '������'; Name3: '�����'; Vid: 6; Color: crBROWN; Mass: 10.7; Attack: 8; Defense: 0; Chance: 35; Kind: CLOSE_STAFF;
    Flags: NOF or I_TWOHANDED;),
    //
    (Name1: '������'; Name2: '�������'; Name3: '������'; Vid: 6; Color: crLIGHTGRAY; Mass: 7.7; Attack: 9; Defense: 0; Chance: 60; Kind: CLOSE_BLADE;
    Flags: NOF;),
    //
    (Name1: '������'; Name2: '������'; Name3: '������'; Vid: 6; Color: crBROWN; Mass: 16.0; Attack: 12; Defense: 0; Chance: 30; Kind: CLOSE_CLUB;
    Flags: NOF;),
    //
    (Name1: '�������� ���'; Name2: '�������� ����'; Name3: '�������� ���'; Vid: 6; Color: crWHITE; Mass: 12.0; Attack: 13; Defense: 0; Chance: 30;
    Kind: CLOSE_BLADE; Flags: NOF;),
    //
    (Name1: '������'; Name2: '������'; Name3: '������'; Vid: 6; Color: crLIGHTGRAY; Mass: 14.0; Attack: 15; Defense: 0; Chance: 23; Kind: CLOSE_CLUB;
    Flags: NOF;),
    //
    (Name1: '������� ���'; Name2: '������� ����'; Name3: '������� ���'; Vid: 6; Color: crCYAN; Mass: 21.0; Attack: 17; Defense: 0; Chance: 15;
    Kind: CLOSE_BLADE; Flags: NOF or I_TWOHANDED;),
    //
    (Name1: '���'; Name2: '����'; Name3: '���'; Vid: 8; Color: crBROWN; Mass: 15.2; Attack: 7; Defense: 0; Chance: 15; Flags: NOF;),
    //
    (Name1: '������'; Name2: '������'; Name3: '������'; Vid: 12; Color: crGREEN; Mass: 8.7; Attack: 4; Defense: 3; Chance: 35; Kind: ARMOR_CLOTHES;
    Flags: NOF;),
    //
    (Name1: '�����'; Name2: '������'; Name3: '�����'; Vid: 14; Color: crBROWN; Mass: 1.4; Attack: 2; Defense: 110; Chance: 60; Flags: NOF;),
    //
    (Name1: '������� ������'; Name2: '������� ������'; Name3: '������� ������'; Vid: 14; Color: crLIGHTGREEN; Mass: 0.5; Attack: 2; Defense: 150;
    Chance: 90; Flags: NOF;),
    //
    (Name1: '����� ����'; Name2: '����� ����'; Name3: '����� ����'; Vid: 14; Color: crLIGHTRED; Mass: 6.0; Attack: 3; Defense: 50; Chance: 35;
    Flags: NOF;),
    //
    (Name1: '������'; Name2: '������'; Name3: '������'; Vid: 14; Color: crBROWN; Mass: 5.0; Attack: 2; Defense: 40; Chance: 0; Flags: NOF;),
    //
    (Name1: '���� �� ��������� ���� ��������'; Name2: '����� �� ��������� ���� ��������'; Name3: '���� �� ��������� ���� ��������'; Vid: 20;
    Color: crCYAN; Mass: 0.3; Attack: 1; Defense: 0; Chance: 0; Flags: NOF;),
    //
    (Name1: '�����'; Name2: '������'; Name3: '�����'; Vid: 6; Color: crWHITE; Mass: 13.5; Attack: 12; Defense: 0; Chance: 30; Kind: CLOSE_AXE;
    Flags: NOF;),
    //
    (Name1: '���'; Name2: '����'; Name3: '���'; Vid: 7; Color: crBROWN; Mass: 5.2; Attack: 4; Defense: 0; Chance: 20; Kind: FAR_BOW; Flags: NOF;),
    //
    (Name1: '�������'; Name2: '��������'; Name3: '�������'; Vid: 7; Color: crBROWN; Mass: 8.2; Attack: 6; Defense: 0; Chance: 18; Kind: FAR_CROSS;
    Flags: NOF;),
    //
    (Name1: '�����'; Name2: '�����'; Name3: '�����'; Vid: 7; Color: crGRAY; Mass: 0.4; Attack: 0; Defense: 0; Chance: 25; Kind: FAR_SLING;
    Flags: NOF;),
    //
    (Name1: '������� ������'; Name2: '������� ������'; Name3: '������� ������'; Vid: 7; Color: crCYAN; Mass: 0.2; Attack: 0; Defense: 0; Chance: 23;
    Kind: FAR_PIPE; Flags: NOF;),
    //
    (Name1: '������'; Name2: '������'; Name3: '������'; Vid: 13; Color: crBROWN; Mass: 0.08; Attack: 4; Defense: 0; Chance: 40; Kind: FAR_BOW;
    Flags: NOF;),
    //
    (Name1: '����'; Name2: '�����'; Name3: '����'; Vid: 13; Color: crRED; Mass: 0.20; Attack: 4; Defense: 0; Chance: 35; Kind: FAR_CROSS;
    Flags: NOF;),
    //
    (Name1: '��������� ������'; Name2: '��������� �����'; Name3: '��������� ������'; Vid: 13; Color: crLIGHTGRAY; Mass: 0.35; Attack: 3; Defense: 0;
    Chance: 60; Kind: FAR_SLING; Flags: NOF;),
    //
    (Name1: '����'; Name2: '����'; Name3: '����'; Vid: 13; Color: crCYAN; Mass: 0.01; Attack: 3; Defense: 0; Chance: 50; Kind: FAR_PIPE; Flags: NOF;),
    //
    (Name1: '������� �� ����� �����'; Name2: '������� �� ����� �����'; Name3: '������� �� ����� �����'; Vid: 4; Color: crBROWN; Mass: 10.5; Attack: 1;
    Defense: 3; Chance: 45; Kind: ARMOR_CLOTHES; Flags: NOF;),
    //
    (Name1: '�������'; Name2: '�������'; Name3: '�������'; Vid: 19; Color: crCYAN; Mass: 0.1; Attack: 1; Defense: 0; Chance: 40; Flags: NOF;),
    //
    (Name1: '������ ����������'; Name2: '����� ����������'; Name3: '������ ����������'; Vid: 22; Color: crBROWN; Mass: 4; Attack: 0; Defense: 0;
    Chance: 5; Flags: NOF;)
    //
    );

  { ���������� �������������� ��������� }
  idCOIN = 1;
  idKITCHENKNIFE = 2;
  idPITCHFORK = 3;
  idKEKS = 4;
  idJACKSONSHAT = 5;
  idLAPTI = 6;
  idCORPSE = 7;
  idHELMET = 8;
  idMANTIA = 9;
  idJACKET = 10;
  idCHAINARMOR = 11;
  idSTAFF = 12;
  idDAGGER = 13;
  idDUBINA = 14;
  idSHORTSWORD = 15;
  idPALICA = 16;
  idLONGSWORD = 17;
  idSHIELD = 18;
  idBOOTS = 19;
  idLAVASH = 20;
  idGREENAPPLE = 21;
  idMEAT = 22;
  idHEAD = 23;
  idGATESKEY = 24;
  idAXE = 25;
  idBOW = 26;
  idCROSSBOW = 27;
  idSLING = 28;
  idBLOWPIPE = 29;
  idARROW = 30;
  idBOLT = 31;
  idLITTLEROCK = 32;
  idIGLA = 33;
  idCAPE = 34;
  idBOTTLE = 35;
  idMANDAGORAROOT = 36;

  { ���������� �������������� ��������� }
  lqCURE = 1;
  lqHEAL = 2;
  lqCHEAPBEER = 3;
  lqKEFIR = 4;

function HaveItemTypeInDB(wtype: Byte): boolean; // ���� �� ������� ������� ���� � ���� (������ �������, ����� ���������� ���� ����� ���������)
function GenerateItem(wtype: Byte): TItem; // ������������ ��������� ������� ������������� ����
function CreateItem(n: Byte; am: Integer; OwnerId: Byte): TItem; // ������� �������
function PutItem(px, py: Byte; Item: TItem; Amount: Integer): boolean; // �������� �������
procedure WriteSomeAboutItem(Item: TItem; compare: boolean = false); // ������� ��������� ���-�� ��������
procedure ExamineItem(Item: TItem); // ����������� ��������� �������
procedure ItemOnOff(Item: TItem; PutOn: boolean); // ��������� ������ �������� ��� ������
function ItemName(Item: TItem; skl: Byte; all: boolean): string; // ������� ������ �������� ��������
procedure UseItem(SelectedItem: Byte); // ������������ ������� � ���������
function SameItems(I1, I2: TItem): boolean; // �������� ��� �������� - ��������� �� ���?
function ItemColor(I: TItem): Byte; // ������� ���� ��������

implementation

uses
  Map, Player, Monsters, Conf, Liquid;

{ ���� �� ������� ������� ���� � ���� (������ �������, ����� ���������� ���� ����� ���������) }
function HaveItemTypeInDB(wtype: Byte): boolean;
var
  I: Integer;
  e: boolean;
begin
  e := false;
  for I := 1 to ItemsAmount do
    if (ItemsData[I].Vid = wtype) and (ItemsData[I].Chance > 0) then
    begin
      e := TRUE;
      break;
    end;
  Result := e;
end;

{ ������������ ��������� ������� ������������� ���� }
function GenerateItem(wtype: Byte): TItem;
var
  List: array [1 .. ItemsAmount] of Integer;
  Amount, I: Integer;
begin
  Amount := 0;
  // ������� ������ ����������
  for I := 1 to ItemsAmount do
    if ItemsData[I].Vid = wtype then
    begin
      inc(Amount);
      List[Amount] := I;
    end;
  if Amount > 0 then
  begin
    if Amount = 1 then
      I := Amount
    else
    begin
      repeat
        I := Random(Amount) + 1;
      until (Random(100) + 1 <= ItemsData[List[I]].Chance);
    end;
  end;
  if I <> idBOTTLE then
    Result := CreateItem(List[I], 1, 0)
  else
    Result := CreatePotion(List[I], 1);
end;

{ ������� ������� }
function CreateItem(n: Byte; am: Integer; OwnerId: Byte): TItem;
var
  Item: TItem;
  I: Integer;
begin
  with Item do
  begin
    Id := n;
    Amount := am;
    Mass := ItemsData[Id].Mass;
    Owner := OwnerId;
    // ������ ����� �����, �� ����� ������� ������� (-20%)
    if Id = idCORPSE then
      Mass := Round(MonstersData[Owner].Mass * 0.8);
    // ������ ����� ������, �� ����� 15% ���� �����
    if Id = idHEAD then
      Mass := Round(MonstersData[Owner].Mass * 0.15);
    // ���� �������, �� ��������� �� ��������
    if Id = idBOTTLE then
    begin
      repeat
        I := Random(LiquidAmount) + 1;
      until (Random(100) + 1 <= AllLiquid[I].Chance);
      LiquidId := I;
    end;
  end;
  Result := Item;
end;

{ �������� ������� }
function PutItem(px, py: Byte; Item: TItem; Amount: Integer): boolean;
var
  x, y: Integer;
begin
  Result := TRUE;
  if Amount > 0 then
    Item.Amount := Amount;
  if not TilesData[M.Tile[px, py]].move then
    Result := false
  else if M.Item[px, py].Id > 0 then
  begin
    if SameItems(M.Item[px, py], Item) then
    begin
      inc(M.Item[px, py].Amount, Item.Amount);
      exit;
    end
    else
      Result := false;
  end
  else
    M.Item[px, py] := Item;
  // ���� ������ ������ ������� �� ��������� �����, ����������� ������ ��� � ������������
  if Result = false then
  begin
    for x := px - 1 to px + 1 do
    begin
      for y := py - 1 to py + 1 do
        if (x > 0) and (x <= MapX) and (y > 0) and (y <= MapY) then
          if NOT((x = px) and (y = py)) then
          begin
            if not TilesData[M.Tile[x, y]].move then
              Result := false
            else if M.Item[x, y].Id > 0 then
            begin
              if SameItems(M.Item[x, y], Item) then
              begin
                inc(M.Item[x, y].Amount, Item.Amount);
                Result := TRUE;
                break;
              end
              else
                Result := false;
            end
            else
            begin
              M.Item[x, y] := Item;
              Result := TRUE;
              break;
            end;
          end;
      if Result = TRUE then
        break;
    end;
  end;
end;

{ ������� ��������� ���-�� �������� }
procedure WriteSomeAboutItem(Item: TItem; compare: boolean = false);
var
  s: string;
  cell: Byte;
  t: shortint;
begin
  if Item.Id > 0 then
    with GScreen.Canvas do
    begin
      DrawBorder(15, 31, 70, 4, crLIGHTGRAY);
      // ������ �������� ��������
      s := '';
      case ItemsData[Item.Id].Vid of
        { ������ - ���� ��� ����� (����, ����, ����� �� ����, ��������, ����� }
        1, 3, 4, 11, 12:
          begin
            t := ItemsData[Item.Id].Defense;
            s := s + '������: ' + IntToStr(t) + ' ';
            if compare then
            begin
              s := s + '(';
              cell := Vid2Eq(ItemsData[Item.Id].Vid);
              if (pc.eq[cell].Id <> 0) then
                dec(t, ItemsData[pc.eq[cell].Id].Defense);
              if t > 0 then
                s := s + '+';
              s := s + IntToStr(t) + ') ';
            end;
          end;
        { ����� - �������� ������ ���� ��� - ������ (�������� ��� � ������ }
        6, 13:
          begin
            t := ItemsData[Item.Id].Attack;
            s := s + '�����: ' + IntToStr(t) + ' ';
            if compare then
            begin
              s := s + '(';
              cell := Vid2Eq(ItemsData[Item.Id].Vid);
              if (pc.eq[cell].Id <> 0) then
                dec(t, ItemsData[pc.eq[cell].Id].Attack);
              if t > 0 then
                s := s + '+';
              s := s + IntToStr(t) + ') ';
            end;
          end;
      end;
      // ����� ��������
      s := s + '�����: ' + FloatToStr(Item.Mass);
      // ������� ��������� �������������� ��������
      Font.Color := cCYAN;
      // ����� ��� ������, ������ ��� ����� ��� ���������� � ��� � ��
      TextOut(17 * CharX, 32 * CharY, s);
      // ������� ������ ��������
      Font.Color := cLIGHTGRAY;
      TextOut(49 * CharX, 31 * CharY, '| |');
      Font.Color := RealColor(ItemColor(Item));
      TextOut(50 * CharX, 31 * CharY, ItemTypeData[ItemsData[Item.Id].Vid].Symbol);
      // ��� ������, ���� ��� ������
      Font.Color := cGREEN;
      if (ItemsData[Item.Id].Vid = 6) then
        TextOut((83 - Length(CLOSEWPNNAME[ItemsData[Item.Id].Kind])) * CharX, 32 * CharY, '"' + CLOSEWPNNAME[ItemsData[Item.Id].Kind] + '"');
      if (ItemsData[Item.Id].Vid = 7) or (ItemsData[Item.Id].Vid = 13) then
        TextOut((83 - Length(FARWPNNAME[ItemsData[Item.Id].Kind])) * CharX, 32 * CharY, '"' + FARWPNNAME[ItemsData[Item.Id].Kind] + '"');
      // ��� �����, ���� ��� ����� ��� �����
      if (ItemsData[Item.Id].Vid = 4) or (ItemsData[Item.Id].Vid = 12) then
        TextOut((83 - Length(ARMORTYPENAME[ItemsData[Item.Id].Kind])) * CharX, 32 * CharY, '"' + ARMORTYPENAME[ItemsData[Item.Id].Kind] + '"');
    end;
end;

{ ����������� ��������� ������� }
procedure ExamineItem(Item: TItem);
begin
  if ItemsData[Item.Id].Descr <> '' then
    AddMsg(ItemsData[Item.Id].Descr, 0)
  else
    AddMsg('�� ����������� �������������� ' + ItemName(Item, 1, TRUE) + ', �� �� ������ ������ ����������.', 0);
end;

{ ��������� ������ �������� ��� ������ }
procedure ItemOnOff(Item: TItem; PutOn: boolean);
var
  n: shortint;
begin
  if PutOn then
    n := 1
  else
    n := -1;
  pc.Defense := pc.Defense + n * ItemsData[Item.Id].Defense;
end;

{ ������� ������ �������� �������� SKL = 0 ���? SKL = 1 ����? ����? }
function ItemName(Item: TItem; skl: Byte; all: boolean): string;
var
  s: string;
begin
  case skl of
    0:
      if (Item.Amount = 1) or (not all) then
        s := ItemsData[Item.Id].Name1
      else
        s := ItemsData[Item.Id].Name2;
    1:
      if (Item.Amount = 1) or (not all) then
        s := ItemsData[Item.Id].Name3
      else
        s := ItemsData[Item.Id].Name2;
  end;
  // �������
  if Item.Id = idBOTTLE then
  begin
    // �������� ��� ������������������� �������:
    s := s + ' ' + AllLiquid[Item.LiquidId].Name;
    // �������� ��� �� ������������������� �������:
    // s := s + ' � ' + LiquidState[NowLiquidState[Item.liquidid]] + ' ' + LiquidColor[NowLiquidColor[Item.liquidid]] + ' ���������';
  end;
  if Item.Owner > 0 then
  begin
    // ���� ���������� - ��
    if Item.Owner = 1 then
    begin
    end
    else
    begin
      if (Item.Amount = 1) or (not all) then
        s := s + ' ' + MonstersData[Item.Owner].name5
      else
        s := s + ' ' + MonstersData[Item.Owner].name6;
    end;
  end;
  if (Item.Amount > 1) and (all) then
    s := s + ' (' + IntToStr(Item.Amount) + ' ��)';
  Result := s;
end;

{ ������������ ������� � ��������� }
procedure UseItem(SelectedItem: Byte);
begin
  // ������� ������� (������ ������ ����������� ������������ � ���� � ����� "����� ������!")
  if pc.Inv[SelectedItem].Id = idCOIN then
  begin
    if pc.Inv[SelectedItem].Amount = 1 then
      AddMsg('��� ��� ������������� - � ���� ����� ���� ������� �������...', 0)
    else
      AddMsg('�� ����������{/a} ' + ItemName(pc.Inv[SelectedItem], 0, TRUE) + '.', 0);
    ChangeGameState(gsPLAY);
  end
  else
    // ������������ ������� �� ����������
    case ItemsData[pc.Inv[SelectedItem].Id].Vid of
      // ������
      1 .. 13:
        begin
          MenuSelected := Vid2Eq(ItemsData[pc.Inv[SelectedItem].Id].Vid);
          case pc.EquipItem(pc.Inv[SelectedItem], TRUE) of
            0:
              begin
                ItemOnOff(pc.Inv[SelectedItem], TRUE);
                if (pc.Inv[SelectedItem].Amount > 1) and (ItemsData[pc.Inv[SelectedItem].Id].Vid <> 13) then
                  dec(pc.Inv[SelectedItem].Amount)
                else
                  pc.Inv[SelectedItem].Id := 0;
                pc.RefreshInventory;
              end;
            1:
              begin
                ItemOnOff(pc.Inv[SelectedItem], TRUE);
                GameState := gsPLAY;
              end;
          end;
          ChangeGameState(gsEQUIPMENT);
        end;
      // ������
      14:
        begin
          if pc.status[stHUNGRY] >= 0 then
          begin
            pc.status[stHUNGRY] := pc.status[stHUNGRY] - Round(ItemsData[pc.Inv[SelectedItem].Id].Defense * pc.Inv[SelectedItem].Mass * 1.3 *
              (1 + (pc.Ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
            if pc.status[stHUNGRY] < -500 then
            begin
              AddMsg('#�� �� ����{/��} ������ ' + ItemName(pc.Inv[SelectedItem], 1, false) +
                ' ������, ��� ����� �������{��/���}... �������� �������{��/���}...#', 0);
              pc.status[stHUNGRY] := -500;
            end
            else
              AddMsg('#�� ����{/a} ' + ItemName(pc.Inv[SelectedItem], 1, false) + '.#', 0);
            pc.DeleteItemInv(SelectedItem, 1, 1);
            pc.turn := 1;
          end
          else
            AddMsg('���� �� ������� ������ ����!', 0);
          ChangeGameState(gsPLAY);
        end;
      // ������
      19:
        begin
          AddMsg('�� �����{/a} ' + ItemName(pc.Inv[SelectedItem], 1, false) + '.', 0);
          DrinkLiquid(pc.Inv[SelectedItem].LiquidId, pc);
          pc.DeleteItemInv(SelectedItem, 1, 1);
          pc.turn := 1;
          ChangeGameState(gsPLAY);
        end;
    end;
end;

{ �������� ��� �������� - ��������� �� ���? }
function SameItems(I1, I2: TItem): boolean;
begin
  Result := false;
  if (I1.Id = I2.Id) and (I1.Owner = I2.Owner) then
  begin
    // ���� ��� ������� �� �������� ��� �� �����������
    if I1.Id = idBOTTLE then
    begin
      if (I1.LiquidId = I2.LiquidId) then
        Result := TRUE;
    end
    else
      Result := TRUE;
  end;
end;

{ ������� ���� �������� }
function ItemColor(I: TItem): Byte;
begin
  Result := 3;
  Result := ItemsData[I.Id].Color;
  // ���� �������
  if (I.Id = idBOTTLE) and (I.LiquidId > 0) then
    Result := NowLiquidColor[I.LiquidId];
end;

end.
