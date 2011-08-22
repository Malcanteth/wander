unit main;

interface

uses
  Classes, Graphics, Forms, SysUtils, ExtCtrls, Controls, StdCtrls;

type
  TMainForm = class(TForm)
    Edit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ProcessMsg;
    procedure EndGame;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
  private
  public
  end;

var
  MainForm             : TMainForm;
  Screen               : TBitMap;              // �������� ��� �������-������������
  WaitMore             : boolean;              // --�����--
  WaitEnter            : boolean;              // ���� ������� Enter
  GameState            : byte;                 // ��������� ����
  Answer               : string[1];            // ��������� �����
  AskForQuit           : boolean;              // ������������� ������
  MenuSelected,
  MenuSelected2        : byte;                 // ��������� ������� � ����
  WasEq                : boolean;              // ����� ������� ���� �������� � ��������� ��� ��������� ��� ����������
  a                    : integer;
  wtd                  : byte;                 // ��� ������� ��� ������ �������

implementation

{$R *.dfm}

uses
  Cons, Utils, Msg, Player, Map, Special, Tile, Help, Items, Ability;

{ ������������� }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // ������ ����
  ClientWidth := WindowX * CharX;
  ClientHeight := WindowY * CharY;
  // ������� ��������
  Screen := TBitMap.Create;
  Screen.Width := ClientWidth;
  Screen.Height := ClientHeight;
  Screen.Canvas.Font.Name := FontName;
  GameState := gsHEROGENDER;
  MenuSelected := 1;
end;

{ ��������� }
procedure TMainForm.FormPaint(Sender: TObject);
begin
  // ��������� �������� ������ ������
  Screen.Canvas.Brush.Color := 0;
  Screen.Canvas.FillRect(Rect(0, 0, MainForm.ClientRect.Right, MainForm.ClientRect.Bottom));
  // �������
  case GameState of
    gsPLAY, gsCLOSE, gsLOOK, gsCHOOSEMONSTER, gsOPEN:
    begin
      // ������� �����
      M.DrawScene;
      // ������� ���������
      ShowMsgs;
      // ������� ���������� � �����
      pc.WriteInfo;
    end;
    gsQUESTLIST  : pc.QuestList;
    gsEQUIPMENT  : pc.Equipment;
    gsINVENTORY  : pc.Inventory;
    gsHELP       : ShowHelp;
    gsUSEMENU    : begin if WasEq then pc.Equipment else pc.Inventory; pc.UseMenu; end;
    gsHERONAME   : pc.HeroName;
    gsHEROGENDER : pc.HeroGender;
    gsABILITYS   : ShowAbilitys;
  end;
  // ����������
  Canvas.StretchDraw(ClientRect, Screen);
end;

{ ������� �� ������� }
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // ���� ������ �� Shift, Alt ��� Ctrl � ������ �� ��������� �����
  if Key <> 16 then
  begin
    // ��������
    if Key = 116 then TakeScreenShot else
      // ������ ��� �����������
      if WaitMore then
      begin
        if Key = 32 then WaitMore := False;
      end else
        // Enter ��� �����������
        if WaitENTER then
        begin
          if Key = 13 then WaitENTER := False;
        end else
          // ������
          if Answer = ' ' then
          begin
            if key = 32 then Answer := '' else Answer := UpCase (Chr(Key));
          end else
        // ��� ���������
        begin
          ClearMsg;
          pc.turn := 0;
          case GameState of
            // ����� ����
            gsHEROGENDER:
            begin
              case Key of
                // �����
                38,104,56 :
                begin
                  if MenuSelected = 1 then MenuSelected := 2 else dec(MenuSelected);
                  OnPaint(SENDER);
                end;
                // ����
                40,98,50 :
                begin
                  if MenuSelected = 2 then MenuSelected := 1 else inc(MenuSelected);
                  OnPaint(SENDER);
                end;
                // Ok...
                13 :
                begin
                  pc.gender := MenuSelected;
                  GameState := gsHERONAME;
                  OnPaint(Sender);
                end;
              end;
            end;
            // �� ����� ����
            gsPLAY:
            begin
              case Key of
                { ������������ }
                35,97,49     : pc.Move(-1,1);
                40,98,50     : pc.Move(0,1);
                34,99,51     : pc.Move(1,1);
                37,100,52    : pc.Move(-1,0);
                12,101,53,32 : pc.Move(0,0);
                39,102,54    : pc.Move(1,0);
                36,103,55    : pc.Move(-1,-1);
                38,104,56    : pc.Move(0,-1);
                33,105,57    : pc.Move(1,-1);
                13           : pc.UseStairs;
                { �������� }
                // ����� 'Esc'
                27        : Close;
                // ������� ����� 'c'
                67        : pc.SearchForDoors;
                // �������� 'l'
                76        :
                begin
                  GameState := gsLOOK;
                  lx := pc.x;
                  ly := pc.y;
                  pc.AnalysePlace(lx,ly,TRUE);
                end;
                // �������� 't'
                84        : pc.SearchForAlive(2);
                // ������ ������� 'q'
                81        :
                begin
                  GameState := gsQUESTLIST;
                end;
                // ���������� 'e'
                69        :
                begin
                  MenuSelected := 1;
                  GameState := gsEQUIPMENT;
                end;
                // ��������� 'i'
                73        :
                if pc.ItemsAmount > 0 then
                begin
                  MenuSelected := 1;
                  GameState := gsINVENTORY;
                end else
                  AddMsg('���� ��������� ����!');
                // ������ '?'
                112       :
                begin
                  GameState := gsHELP;
                end;
                // ��������� 'a'
                65        : pc.SearchForAlive(1);
                // ������� 'g'
                71        :
                case pc.PickUp(M.Item[pc.x,pc.y], FALSE) of
                  0 :
                  begin
                    AddMsg('�� ���������� '+ItemName(M.Item[pc.x,pc.y], 1, TRUE)+'.');
                    M.Item[pc.x,pc.y].id := 0;
                  end;
                  1 : AddMsg('����� ������ �� �����!');
                  2 : AddMsg('���� ��������� �������� �����! ��� ����� ����� ���������?! ���� �� �������� � ���, ����� �������� ��� ������� ��������� ����...');
                  3 : AddMsg('�� �� ������ ����� ������... ������� ������!');
                end;
                // ������� 'o'
                79        :
                begin
                  AddMsg('��� �� ������ �������?');
                  GameState := gsOPEN;
                end;
                // ����������� 's'
                83        :
                begin
                  AddMsg('�� ����������� �������������� �� ��������...');
                  pc.Search(1);
                  pc.turn := 1;
                end;
                // ������� 'x'
                88        :
                begin
                  MenuSelected := 1;
                  GameState := gsABILITYS;
                end;
              end;
            end;
            // ������� �����
            gsCLOSE:
            begin
              case Key of
                35,97,49  : pc.CloseDoor(-1,1);
                40,98,50  : pc.CloseDoor(0,1);
                34,99,51  : pc.CloseDoor(1,1);
                37,100,52 : pc.CloseDoor(-1,0);
                39,102,54 : pc.CloseDoor(1,0);
                36,103,55 : pc.CloseDoor(-1,-1);
                38,104,56 : pc.CloseDoor(0,-1);
                33,105,57 : pc.CloseDoor(1,-1);
                else
                  AddDrawMsg('������� ������������ �����������!');
              end;
              pc.turn := 1;
              GameState := gsPLAY;
            end;
            // �������
            gsOPEN:
            begin
              case Key of
                35,97,49  : pc.Open(-1,1);
                40,98,50  : pc.Open(0,1);
                34,99,51  : pc.Open(1,1);
                37,100,52 : pc.Open(-1,0);
                39,102,54 : pc.Open(1,0);
                36,103,55 : pc.Open(-1,-1);
                38,104,56 : pc.Open(0,-1);
                33,105,57 : pc.Open(1,-1);
                else
                  AddDrawMsg('������� ������������ �����������!');
              end;
              pc.turn := 1;
              GameState := gsPLAY;
            end;
            // ���������!
            gsCHOOSEMONSTER:
            begin
              case Key of
                35,97,49  :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x-1,pc.y+1]], 0);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x-1,pc.y+1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y+1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y+1]], pc.Inv[MenuSelected]);
                end;
                40,98,50  :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x,pc.y+1]], 0);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x,pc.y+1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y+1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y+1]], pc.Inv[MenuSelected]);
                end;
                34,99,51  :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x+1,pc.y+1]], 0);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x+1,pc.y+1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y+1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y+1]], pc.Inv[MenuSelected]);
                end;
                37,100,52 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x-1,pc.y]], 0);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x-1,pc.y]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y]], pc.Inv[MenuSelected]);
                end;
                39,102,54 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x+1,pc.y]], 0);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x+1,pc.y]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y]], pc.Inv[MenuSelected]);
                end;
                36,103,55 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x-1,pc.y-1]], 0);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x-1,pc.y-1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y-1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y-1]], pc.Inv[MenuSelected]);
                end;
                38,104,56 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x,pc.y-1]], 0);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x,pc.y-1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y-1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y-1]], pc.Inv[MenuSelected]);
                end;
                33,105,57 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x+1,pc.y-1]], 0);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x+1,pc.y-1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y-1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y-1]], pc.Inv[MenuSelected]);
                end;
                else
                  AddDrawMsg('������� ������������ �����������!');
              end;
              pc.turn := 1;
              GameState := gsPLAY;
            end;
            // ���������� �������� �������
            gsLOOK:
            begin
              case Key of
                35,97,49  : pc.MoveLook(-1,1);
                40,98,50  : pc.MoveLook(0,1);
                34,99,51  : pc.MoveLook(1,1);
                37,100,52 : pc.MoveLook(-1,0);
                12,101,53 : pc.MoveLook(0,0);
                39,102,54 : pc.MoveLook(1,0);
                36,103,55 : pc.MoveLook(-1,-1);
                38,104,56 : pc.MoveLook(0,-1);
                33,105,57 : pc.MoveLook(1,-1);
                else
                  GameState := gsPlay;
                M.DrawScene;
              end;
            end;
            // ������ �������, ����������, ������
            gsQUESTLIST, gsEQUIPMENT, gsINVENTORY, gsHELP, gsABILITYS:
            begin
              if (Key = 27) or (Key = 32) then GameState := gsPLAY;
              // ���������� � ����������
              if GameState = gsEQUIPMENT then
              begin
                case Key of
                  //i
                  73 :
                  if pc.ItemsAmount > 0 then
                  begin
                    MenuSelected := 1;
                    pc.Inventory;
                    GameState := gsINVENTORY;
                  end;
                  // �����
                  38,104,56 :
                    if MenuSelected = 1 then MenuSelected := EqAmount else dec(MenuSelected);
                  // ����
                  40,98,50 :
                    if MenuSelected = EqAmount then MenuSelected := 1 else inc(MenuSelected);
                  // ����� / ����� � ���������
                  13 :
                  begin
                    // �����
                    if pc.eq[MenuSelected].id > 0 then
                    begin
                      WasEq := TRUE;
                      MenuSelected2 := 1;
                      pc.UseMenu;
                      GameState := gsUSEMENU;
                    end else
                      begin
                        MenuSelected := 1;
                        pc.Inventory;
                        GameState := gsINVENTORY;
                      end;
                  end;
                end;
              end ELSE
              // ���������� � ���������
              if GameState = gsINVENTORY then
              begin
                case Key of
                  //i
                  73 :
                  begin
                    MenuSelected := 1;
                    pc.Equipment;
                    GameState := gsEQUIPMENT;
                  end;
                  // �����
                  38,104,56 :
                    if MenuSelected = 1 then MenuSelected := ReturnInvAmount else dec(MenuSelected);
                  // ����
                  40,98,50 :
                    if MenuSelected = ReturnInvAmount then MenuSelected := 1 else inc(MenuSelected);
                  // ������� ������ �������� � ���������
                  13 :
                  begin
                    WasEq := FALSE;
                    MenuSelected2 := 1;
                    pc.UseMenu;
                    GameState := gsUSEMENU;
                  end;
                end;
              end ELSE
              // ���������� � ������ ������������
              if GameState = gsABILITYS then
              begin
                case Key of
                  // �����
                  38,104,56 :
                  begin
                    if MenuSelected = 1 then
                    begin
                      for a:=1 to AbilitysAmount-1 do
                        if FullAbilitys[a+1] = 0 then
                          break;
                       MenuSelected := a;
                    end
                      else
                        dec(MenuSelected);
                  end;
                  // ����
                  40,98,50 :
                  begin
                    for a:=1 to AbilitysAmount-1 do
                      if FullAbilitys[a+1] = 0 then
                        break;
                    if MenuSelected = a then MenuSelected := 1 else inc(MenuSelected);
                  end;
                end;
              end;
            end;
            // ������ �������� ��� ���������
            gsUSEMENU:
            begin
              case Key of
                // Esc
                27 : if WasEq then GameState := gsEQUIPMENT else GameState := gsINVENTORY;
                // �����
                38,104,56 :
                begin
                  if MenuSelected2 = 1 then MenuSelected2 := HOWMANYVARIANTS else dec(MenuSelected2);
                  OnPaint(SENDER);
                end;
                // ����
                40,98,50 :
                begin
                  if MenuSelected2 = HOWMANYVARIANTS then MenuSelected2 := 1 else inc(MenuSelected2);
                  OnPaint(SENDER);
                end;
                // ������� ��������� �������� � ���������
                13 :
                begin
                  case MenuSelected2 of
                    1: // ������������
                    begin
                      GameState := gsPLAY;
                      //� ����������
                      if WasEq then
                      begin
                        case pc.PickUp(pc.eq[MenuSelected], TRUE) of
                          0 :
                          begin
                            ItemOnOff(pc.eq[MenuSelected], FALSE);
                            AddMsg('�� �������'+HeroHS(1)+' '+ItemName(pc.eq[MenuSelected], 1, TRUE)+' ������� � ���������.');
                            pc.eq[MenuSelected].id := 0;
                          end;
                          1 : AddMsg('<�� �������'+HeroHS(1)+' ������� ������� � ���� ��������� :)>');
                          2 : AddMsg('���� ��������� ��������� �����! ��� ��� ���� �������� ����� ��� � �����.');
                          3 : AddMsg('<����� ���� �� ������ - ���� ���� � ���� ����������, �� ������ ��������, �� ��� �� ��� ������ � ���������.>');
                        end;
                      end else
                        //� ���������
                        begin
                          // ������� ������� (������ ������ ����������� ������������ � ���� � ����� "����� ������!")
                          if pc.Inv[MenuSelected].id = idCOIN then
                            begin
                              if pc.Inv[MenuSelected].amount = 1 then
                                AddMsg('��� ��� ������������� - � ���� ����� ���� ������� �������...') else
                                  AddMsg('�� ����������'+HeroHS(1)+' '+ItemName(pc.Inv[MenuSelected],0, TRUE)+'.');
                              pc.turn := 1;
                            end else
                              // ������������ ������� �� ����������
                              case ItemsData[pc.Inv[MenuSelected].id].vid of
                                // ������
                                1..13:
                                begin
                                  case pc.EquipItem(pc.Inv[MenuSelected]) of
                                    0 :
                                    begin
                                      ItemOnOff(pc.Inv[MenuSelected], TRUE);
                                      if (pc.Inv[MenuSelected].amount > 1) and (ItemsData[pc.Inv[MenuSelected].id].vid <> 13) then
                                        dec(pc.Inv[MenuSelected].amount) else
                                          pc.Inv[MenuSelected].id := 0;
                                      pc.RefreshInventory;
                                      MenuSelected := Cell;
                                      GameState := gsEQUIPMENT;
                                    end;
                                    1 :
                                    begin
                                      ItemOnOff(pc.Inv[MenuSelected], TRUE);
                                      GameState := gsPLAY;
                                    end;
                                  end;
                                end;
                                // ������
                                14:
                                begin
                                  if pc.status[stHUNGRY] >= 0 then
                                  begin
                                    pc.status[stHUNGRY] := pc.status[stHUNGRY] - Round(ItemsData[pc.Inv[MenuSelected].id].defense * pc.Inv[MenuSelected].mass * 1.3 * (1 + (pc.ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
                                    if pc.status[stHUNGRY] < -500 then
                                    begin
                                      AddMsg('[�� �� ����'+HeroHS(3)+' ������ '+ItemName(pc.Inv[MenuSelected], 1, FALSE)+', ������ ��� ����� �������'+HeroHS(2)+'... �������� �������'+HeroHS(2)+'...]');
                                      pc.status[stHUNGRY] := -500;
                                    end else
                                        AddMsg('[�� ����'+HeroHS(1)+' '+ItemName(pc.Inv[MenuSelected], 1, FALSE)+'.]');
                                    pc.DeleteInvItem(pc.Inv[MenuSelected], FALSE);
                                    pc.turn := 1;
                                  end else
                                    AddMsg('���� �� ������� ������ ����!');
                                end;
                                // ������
                                19:
                                begin
                                  AddMsg('�� �����'+HeroHS(1)+' '+ItemName(pc.Inv[MenuSelected], 1, FALSE)+'.');
                                  // �������
                                  if pc.Inv[MenuSelected].id = idPOTIONCURE then
                                  begin
                                    if pc.Hp < pc.RHp then
                                    begin
                                      a := Random(15)+1;
                                      if pc.hp + a > pc.RHp then
                                        a := pc.RHp - pc.Hp;
                                      inc(pc.hp, a);
                                      if pc.Hp >= pc.RHp then
                                      begin
                                        AddMsg('[�� ��������� �������'+HeroHS(2)+'!] ({+'+IntToStr(a)+'})');
                                        pc.Hp := pc.RHp;
                                      end else
                                        AddMsg('[���� ����� ������� �����] ({+'+IntToStr(a)+'})');
                                    end else
                                      AddMsg('������ �� ���������.');
                                  end;
                                  // ���������
                                  if pc.Inv[MenuSelected].id = idPOTIONHEAL then
                                  begin
                                    if pc.Hp < pc.RHp then
                                    begin
                                      AddMsg('[�� ��������� �������'+HeroHS(2)+'!] ({+'+IntToStr(pc.RHp-pc.Hp)+'})');
                                      pc.Hp := pc.RHp;
                                    end else
                                      AddMsg('������ �� ���������.');
                                  end;
                                  // �������
                                  if pc.Inv[MenuSelected].id = idCHEAPBEER then
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
                                          AddMsg('��� ���� - ������ ������, �� ��� ������� �� ������ ���������� ���� ������������!');
                                        end else
                                          AddMsg('�� ����� �� ��� ���� � ������...');
                                      end else
                                        AddMsg('�� �������� ������ ������'+HeroHS(1)+' ������� ����. �� �����. ��������!');
                                      inc(pc.status[stDRUNK], 130);  
                                    end else
                                      AddMsg('�� �������'+HeroHS(2)+' ������ ���, �� �������� ������� ������������ �� ����� ��� � ���������!..');
                                  end;
                                  pc.DeleteInvItem(pc.Inv[MenuSelected], FALSE);
                                  pc.turn := 1;
                                end;
                              end;
                            end;
                    end;
                    2: // �����������
                    begin
                      GameState := gsPLAY;
                      if WasEq then
                        ExamineItem(pc.Eq[MenuSelected]) else
                          ExamineItem(pc.Inv[MenuSelected]);
                      pc.turn := 1;
                    end;
                    3: // �������
                    begin
                    end;
                    4: // ������
                    begin
                      GameState :=gsPLAY;
                      pc.SearchForAlive(3);
                    end;
                    5: // ��������
                    begin
                      GameState := gsPLAY;
                      if WasEq then
                      begin
                        if PutItem(pc.x,pc.y, pc.Eq[MenuSelected]) then
                        begin
                          AddMsg('�� �������'+HeroHS(1)+' '+ItemName(pc.Eq[MenuSelected], 1, TRUE)+'.');
                          pc.DeleteInvItem(pc.Eq[MenuSelected], TRUE);
                          pc.turn := 1;
                        end else
                          AddMsg('����� ��� ����� ��� ����, ��� �� �������� ���-����!');
                      end else
                        begin
                          if PutItem(pc.x,pc.y, pc.Inv[MenuSelected]) then
                          begin
                            AddMsg('�� �������'+HeroHS(1)+' '+ItemName(pc.Inv[MenuSelected], 1, TRUE)+'.');
                            pc.DeleteInvItem(pc.Inv[MenuSelected], TRUE);
                            pc.turn := 1;
                          end else
                            AddMsg('����� ��� ����� ��� ����, ��� �� �������� ���-����!');
                        end;
                    end;
                  end;
                end;
              end;
            end;
          end;
          pc.AfterTurn;
        end;
  end;
end;

{ ��������� �������� }
procedure TMainForm.ProcessMsg;
begin
  Application.ProcessMessages;
end;

{ ��������� ���� }
procedure TMainForm.EndGame;
begin
  // ������� ����������
  DeleteSwap;
end;

{ ����� �� ���� }
procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FALSE;
  if (pc.Hp <= 0) or (AskForQuit = False) then
  begin
    EndGame;
    CanClose := TRUE;
  end else
    if (GameState = gsPLAY) or (GameState = gsLOOK) or (GameState = gsCLOSE) or (GameState = gsCHOOSEMONSTER) then
    begin
      if (Ask('�������� ���, �������� ������? [(Y/n)]')) = 'Y' then
      begin
        CanClose := TRUE;
        EndGame;
      end else
        AddMsg('�� �����'+HeroHS(1)+' ������ ��� ����-����.');
    end else
      begin
        if (GameState <> gsHEROGENDER) and (GameState <> gsHERONAME) then
        begin
          GameState := gsPLAY;
          OnPaint(SENDER);
        end;
      end;
end;

{ ���������� - �������� ���� }
procedure TMainForm.FormResize(Sender: TObject);
begin
  if GameState > 0 then
    OnPaint(Sender);
end;

{ ������� � Edit'e}
procedure TMainForm.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if Edit.Text = '' then
    begin
      case pc.gender of
        genMALE   : pc.name := GenerateName(FALSE);
        genFEMALE : pc.name := GenerateName(TRUE);
      end;
    end else
      pc.name := Edit.Text;
    Edit.Visible := False;
    GameState := gsPLAY;
    // ������������� ����
    AskForQuit := TRUE;
    Eviliar;
    pc.Prepare;
    pc.FOV;
    Addmsg('{����� ������ � ����� ����.}');
    Addmsg('����� ���������� ������ ����������, ��, �������, ������'+HeroHS(1)+' � ��������� �������.');
    Addmsg('����� �����, ��� ����� �������� �������� ����. �� ������ ����������� � ����.');
    Addmsg(' ');
    Addmsg('����� ([F1]), ���� ����� ������.');
    OnPaint(Sender);
    Key := #0;
  end;
end;

end.
