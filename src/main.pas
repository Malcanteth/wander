unit main;

interface

uses
  Windows, Classes, Graphics, Forms, SysUtils, ExtCtrls, Controls, StdCtrls,
  Dialogs, Math,
  Menus;

type
  TMainForm = class(TForm)
    GameTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ProcessMsg;
    procedure EndGame;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure InitGame;
    procedure GameTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AnimFly(x1, y1, x2, y2: integer; symbol: string; color: byte);
  private
    procedure CMDialogKey(Var msg: TCMDialogKey); message CM_DIALOGKEY;
    function GetCharFromVirtualKey(Key: Word): string;
  public
  end;

var
  MainForm: TMainForm;
  GScreen, GrayGScreen: TBitMap; // �������� ��� �������-������������
  WaitMore, // --�����--
  WaitEnter, // ���� ������� Enter
  GameMenu, // ������� ����
  AskForQuit, // ������������� ������
  Inputing: Boolean; // ����� �����
  GameState, // ��������� ����
  MenuSelected2, // ��������� ������� � ����
  VidFilter, // �������� ������ ���� ���������� � ��������� (0-���)
  wtd, // ��� ������� ��� ������ �������
  LastGameState, // ��������� ��������� ����
  WasEqOrInv, // ���� ������� ���������� ��� ���������
  PlayMode: byte; // ��������� ����� ����
  Answer: string[1]; // ��������� �����
  MenuSelected, a: integer;
  DC: HDC; // �������� ����������

implementation

{$R *.dfm}

uses
  Cons, Utils, msg, Player, Map, Tile, Help, Items, Ability, MapEditor, Liquid,
  Conf, SUtils, MBox, Vars, Monsters, Intro;

{ ������������� }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // �������� ������� �����
  DC := GetDC(MainForm.Handle);
  // ������ ������� ����
  Menu := nil;
  // ������ ����
  ClientWidth := WindowX * CharX;
  ClientHeight := WindowY * CharY;
  with GScreen do
  begin
    Width := ClientWidth;
    Height := ClientHeight;
  end;
  with GrayGScreen do
  begin
    Width := ClientWidth;
    Height := ClientHeight;
  end;
  GameTimer.Enabled := Timer = 1;
  ChangeGameState(gsINTRO);
end;

{ ��������� }
procedure TMainForm.FormPaint(Sender: TObject);
begin
  // ��������� �������� ������ ������
  GScreen.Canvas.Brush.color := 0;
  GScreen.Canvas.FillRect(Rect(0, 0, MainForm.ClientRect.Right, MainForm.ClientRect.Bottom));
  // �������
  case GameState of
    gsPLAY, gsCLOSE, gsLOOK, gsCHOOSEMONSTER, gsOPEN, gsAIM:
      begin
        // ������� �����
        M.DrawScene;
        // ������� ���������
        ShowMsgs;
        // ������� ���������� � �����
        pc.WriteInfo;
      end;
    gsINTRO:
      IntroWindow; // ��������
    gsQUESTLIST:
      pc.QuestList;
    gsEQUIPMENT:
      pc.Equipment;
    gsINVENTORY:
      pc.Inventory;
    gsHELP:
      ShowHelp;
    gsUSEMENU:
      begin
        if LastGameState = gsEQUIPMENT then
          pc.Equipment
        else
          pc.Inventory;
        pc.UseMenu;
      end;
    gsCHOOSEMODE:
      ChooseModeWindow;
    gsHERONAME:
      HeroNameWindow;
    gsHEROATR:
      HeroAtributesWindow;
    gsHERORANDOM:
      HeroRandomWindow;
    gsHEROGENDER:
      HeroGenderWindow;
    gsHEROCRRESULT:
      HeroCreateResultWindow;
    gsHEROCLWPN:
      HeroCloseWeaponWindow;
    gsHEROFRWPN:
      HeroFarWeaponWindow;
    gsABILITYS:
      ShowAbilitys;
    gsHISTORY:
      ShowHistory;
    gsSKILLSMENU:
      SkillsAndAbilitys;
    gsWPNSKILLS:
      WpnSkills;
    gsABOUTHERO:
      pc.HeroInfoWindow;
  end;
  // ����
  if Inputing then
  begin
    GameTimer.Interval := 250;
    if (Timer = 0) then
      GameTimer.Enabled := TRUE; // ��������� ������, ����� ����� ������
    ShowInput; // ���������� ���� ��� ����� ����� ���������
  end;
  // ������� ����
  if GameMenu then
  begin
    // ������� ������ �������� �����
    if GameState <> gsINTRO then
    begin
      BlackWhite(GScreen);
      GrayGScreen := GScreen;
    end;
    // ������� ����
    DrawGameMenu;
  end;
  // ���������� ������������� �����
  SetStretchBltMode(GScreen.Canvas.Handle, STRETCH_DELETESCANS);
  StretchBlt(DC, 0, 0, MainForm.ClientRect.Right, MainForm.ClientRect.Bottom, GScreen.Canvas.Handle, 0, 0, GScreen.Width, GScreen.Height, SRCCopy);
end;

{ ������� �� ������� }
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: integer;
  n: string;
  Item: TItem;
begin
  // ���� ������ �� Shift, Alt ��� Ctrl � ������ �� ��������� �����
  if Key <> 16 then
  begin
    // ��������
    if Key = 116 then
      TakeScreenShot
    else
      // ������ ��� Enter ��� �����������
      if WaitMore then
      begin
        if (Key = 32) or (Key = 13) then
          WaitMore := False;
      end
      else
        // Enter ��� �����������
        if WaitEnter then
        begin
          if Key = 13 then
          begin
            WaitEnter := False; // ���� ����� ��������. ������� �������
            if (Timer = 0) then
              GameTimer.Enabled := False; // ������ �� �����, ��������� ������
          end
          else
            // ����
            if Inputing then
            begin
              if (Key = VK_BACK) and (InputPos > 0) then
              begin
                Delete(InputString, InputPos, 1);
                dec(InputPos);
              end
              else if (Key = VK_DELETE) and (InputPos < Length(InputString)) then
              begin
                Delete(InputString, InputPos + 1, 1);
              end
              else if Key = VK_HOME then
                InputPos := 0
              else if Key = VK_END then
                InputPos := Length(InputString)
              else if (Key = VK_LEFT) and (InputPos > 0) then
                dec(InputPos)
              else if (Key = VK_RIGHT) and (InputPos < Length(InputString)) then
                inc(InputPos)
              else if Length(InputString) < 13 then
              begin
                n := GetCharFromVirtualKey(Key);
                if n <> '' then
                begin
                  if ord(n[1]) > 31 then
                  begin
                    Insert(n, InputString, InputPos + 1);
                    inc(InputPos);
                  end;
                end;
              end;
              OnPaint(Sender);
            end;
        end
        else
          // ������
          if Answer = ' ' then
          begin
            if Key = 32 then
              Answer := ''
            else
              Answer := UpCase(Chr(Key));
          end
          else
            // ������� ����
            if GameMenu then
            begin
              case Key of
                // Esc
                27:
                  if GameState <> gsINTRO then
                    GameMenu := False;
                // �����
                38, 104, 56:
                  begin
                    if MenuSelected = 1 then
                      MenuSelected := GMChooseAmount
                    else
                      dec(MenuSelected);
                  end;
                // ����
                40, 98, 50:
                  begin
                    if MenuSelected = GMChooseAmount then
                      MenuSelected := 1
                    else
                      inc(MenuSelected);
                  end;
                // ������
                112:
                  begin
                    GameMenu := False;
                    ChangeGameState(gsHELP);
                  end;
                // Ok...
                13:
                  begin
                    GameMenu := False;
                    case MenuSelected of
                      gmNEWGAME:
                        begin
                          if Mode = 0 then
                            ChangeGameState(gsCHOOSEMODE)
                          else
                          begin
                            PlayMode := Mode;
                            // ���� ����� ����������� �� ����� ��������� �����
                            if PlayMode = AdventureMode then
                              if not MainEdForm.LoadSpecialMaps then
                              begin
                                MsgBox('������ �������� ����!');
                                Halt;
                              end;
                            ChangeGameState(gsHERORANDOM);
                          end;
                        end;
                      gmHELP:
                        begin
                          ChangeGameState(gsHELP);
                        end;
                      gmEXIT:
                        begin
                          GameMenu := False;
                          if GameState = gsINTRO then
                            AskForQuit := False;
                          MainForm.Close;
                        end;
                    end;
                  end;
              end;
              OnPaint(Sender);
            end
            else
            // ��� ���������
            begin
              ClearMsg;
              pc.turn := 0;
              case GameState of
                // ����� ������ ����
                gsCHOOSEMODE:
                  begin
                    ChooseModeWindow;
                    case Key of
                      // �����/����
                      38, 104, 56, 40, 98, 50:
                        begin
                          if MenuSelected = 1 then
                            MenuSelected := 2
                          else
                            MenuSelected := 1;
                          OnPaint(Sender);
                        end;
                      // Ok...
                      13:
                        begin
                          PlayMode := MenuSelected;
                          // ���� ����� ����������� �� ����� ��������� �����
                          if PlayMode = AdventureMode then
                            if not MainEdForm.LoadSpecialMaps then
                            begin
                              MsgBox('������ �������� ����!');
                              Halt;
                            end;
                          ChangeGameState(gsHERORANDOM);
                          MenuSelected := 1;
                          OnPaint(Sender);
                        end;
                    end;
                  end;
                // ��������� �����?
                gsHERORANDOM:
                  begin
                    pc.ClearPlayer;
                    case Key of
                      // �����/����
                      38, 104, 56, 40, 98, 50:
                        begin
                          if MenuSelected = 1 then
                            MenuSelected := 2
                          else
                            MenuSelected := 1;
                          OnPaint(Sender);
                        end;
                      // Ok...
                      13:
                        begin
                          if MenuSelected = 1 then
                            ChangeGameState(gsHEROGENDER)
                          else
                          // �� ��������
                          begin
                            // ���
                            pc.gender := Rand(1, 2);
                            // ���
                            case pc.gender of
                              genMALE:
                                pc.name := GenerateName(False);
                              genFEMALE:
                                pc.name := GenerateName(TRUE);
                            end;
                            // ��������
                            pc.atr[1] := Rand(1, 3);
                            pc.atr[2] := Rand(1, 3);
                            // �������� ���� ������ ������ �� ������
                            pc.Prepare;
                            pc.PrepareSkills;
                            if (pc.HowManyBestWPNCL > 1) and not((pc.HowManyBestWPNCL < 3) and (pc.OneOfTheBestWPNCL(CLOSE_TWO))) then
                            begin
                              pc.CreateClWList;
                              c_choose := Wlist[Random(wlistsize) + 1];
                            end;
                            if (pc.HowManyBestWPNFR > 1) and not((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW))) then
                            begin
                              pc.CreateFrWList;
                              f_choose := Wlist[Random(wlistsize) + 1];
                            end;
                            ChangeGameState(gsHEROCRRESULT);
                          end;
                          OnPaint(Sender);
                        end;
                    end;
                  end;
                // ����� ����
                gsHEROGENDER:
                  begin
                    case Key of
                      // �����
                      38, 104, 56:
                        begin
                          if MenuSelected = 1 then
                            MenuSelected := 3
                          else
                            dec(MenuSelected);
                          OnPaint(Sender);
                        end;
                      // ����
                      40, 98, 50:
                        begin
                          if MenuSelected = 3 then
                            MenuSelected := 1
                          else
                            inc(MenuSelected);
                          OnPaint(Sender);
                        end;
                      // Ok...
                      13:
                        begin
                          if MenuSelected < 3 then
                            pc.gender := MenuSelected
                          else
                            pc.gender := Rand(1, 2);
                          MenuSelected := 1;
                          MenuSelected2 := 1;
                          StartHeroName;
                          OnPaint(Sender);
                        end;
                    end;
                  end;
                // ����� ������ ��. ���
                gsHEROCLWPN:
                  begin
                    case Key of
                      // �����
                      38, 104, 56:
                        begin
                          if MenuSelected > 1 then
                            dec(MenuSelected)
                          else
                            MenuSelected := wlistsize;
                          OnPaint(Sender);
                        end;
                      // ����
                      40, 98, 50:
                        begin
                          if MenuSelected < wlistsize then
                            inc(MenuSelected)
                          else
                            MenuSelected := 1;
                          OnPaint(Sender);
                        end;
                      // Ok...
                      13:
                        begin
                          c_choose := Wlist[MenuSelected];
                          MenuSelected := 1;
                          MenuSelected2 := 1;
                          if (pc.HowManyBestWPNFR > 1) and not((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW))) then
                            ChangeGameState(gsHEROFRWPN)
                          else
                            ChangeGameState(gsHEROCRRESULT);
                          OnPaint(Sender);
                        end;
                    end;
                  end;
                // ����� ������ �������� ���
                gsHEROFRWPN:
                  begin
                    case Key of
                      // �����
                      38, 104, 56:
                        begin
                          if MenuSelected > 1 then
                            dec(MenuSelected)
                          else
                            for i := 4 downto 1 do
                              if Wlist[i] > 0 then
                              begin
                                MenuSelected := i;
                                break;
                              end;
                          OnPaint(Sender);
                        end;
                      // ����
                      40, 98, 50:
                        begin
                          if MenuSelected < 4 then
                          begin
                            if Wlist[MenuSelected + 1] > 0 then
                              inc(MenuSelected)
                            else
                              MenuSelected := 1;
                          end
                          else
                            MenuSelected := 1;
                          OnPaint(Sender);
                        end;
                      // Ok...
                      13:
                        begin
                          f_choose := Wlist[MenuSelected];
                          MenuSelected := 1;
                          MenuSelected2 := 1;
                          ChangeGameState(gsHEROCRRESULT);
                          OnPaint(Sender);
                        end;
                    end;
                  end;
                // ����� ���������
                gsHEROATR:
                  begin
                    case Key of
                      // �����
                      38, 104, 56:
                        begin
                          if MenuSelected = 1 then
                            MenuSelected := 3
                          else
                            dec(MenuSelected);
                          OnPaint(Sender);
                        end;
                      // ����
                      40, 98, 50:
                        begin
                          if MenuSelected = 3 then
                            MenuSelected := 1
                          else
                            inc(MenuSelected);
                          OnPaint(Sender);
                        end;
                      // Ok...
                      13:
                        begin
                          pc.atr[MenuSelected2] := MenuSelected;
                          if MenuSelected2 = 1 then
                          begin
                            MenuSelected := 1;
                            inc(MenuSelected2);
                          end
                          else
                          begin
                            MenuSelected := 1;
                            // �������� ���� ������ ������ �� ������
                            pc.Prepare;
                            pc.PrepareSkills;
                            if (pc.HowManyBestWPNCL > 1) and not((pc.HowManyBestWPNCL < 3) and (pc.OneOfTheBestWPNCL(CLOSE_TWO))) then
                              ChangeGameState(gsHEROCLWPN)
                            else if (pc.HowManyBestWPNFR > 1) and not((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW))) then
                              ChangeGameState(gsHEROFRWPN)
                            else
                              ChangeGameState(gsHEROCRRESULT);
                          end;
                          OnPaint(Sender);
                        end;
                    end;
                  end;
                // �����������
                gsHEROCRRESULT:
                  begin
                    case Key of
                      13, 32:
                        begin
                          pc.FavWPNSkill;
                          M.MonL[pc.idinlist] := pc;
                          InitGame;
                        end;
                      27:
                        begin
                          MenuSelected := 1;
                          ChangeGameState(gsHERORANDOM);
                        end;
                    end;
                  end;
                // �� ����� ����
                gsPLAY:
                  begin
                    { ������������ �� ��������� alt+��� ������� }
                    if ssAlt in Shift then
                    begin
                      If ((GetKeyState(VK_LEFT) AND 128) = 128) and ((GetKeyState(VK_DOWN) AND 128) = 128) then
                        pc.Move(-1, 1)
                      else If ((GetKeyState(VK_RIGHT) AND 128) = 128) and ((GetKeyState(VK_DOWN) AND 128) = 128) then
                        pc.Move(1, 1)
                      else If ((GetKeyState(VK_LEFT) AND 128) = 128) and ((GetKeyState(VK_UP) AND 128) = 128) then
                        pc.Move(-1, -1)
                      else If ((GetKeyState(VK_RIGHT) AND 128) = 128) and ((GetKeyState(VK_UP) AND 128) = 128) then
                        pc.Move(1, -1);
                    end
                    else
                      case Key of
                        { ������������ }
                        35, 97, 49:
                          if ssShift in Shift then
                            pc.Run(-1, 1)
                          else
                            pc.Move(-1, 1);
                        40, 98, 50:
                          if ssShift in Shift then
                            pc.Run(0, 1)
                          else
                            pc.Move(0, 1);
                        34, 99, 51:
                          if ssShift in Shift then
                            pc.Run(1, 1)
                          else
                            pc.Move(1, 1);
                        37, 100, 52:
                          if ssShift in Shift then
                            pc.Run(-1, 0)
                          else
                            pc.Move(-1, 0);
                        12, 101, 53, 32:
                          pc.Move(0, 0);
                        39, 102, 54:
                          if ssShift in Shift then
                            pc.Run(1, 0)
                          else
                            pc.Move(1, 0);
                        36, 103, 55:
                          if ssShift in Shift then
                            pc.Run(-1, -1)
                          else
                            pc.Move(-1, -1);
                        38, 104, 56:
                          if ssShift in Shift then
                            pc.Run(0, -1)
                          else
                            pc.Move(0, -1);
                        33, 105, 57:
                          if ssShift in Shift then
                            pc.Run(1, -1)
                          else
                            pc.Move(1, -1);
                        13:
                          pc.UseStairs;
                        { �������� }
                        // ���� 'Esc'
                        27:
                          begin
                            MenuSelected := 1;
                            GameMenu := TRUE;
                          end;
                        // ������� ����� 'c'
                        67:
                          pc.SearchForDoors;
                        // �������� 'l'
                        76:
                          begin
                            ChangeGameState(gsLOOK);
                            lx := pc.x;
                            ly := pc.y;
                            pc.AnalysePlace(lx, ly, 2);
                          end;
                        // �������� 't'
                        84:
                          pc.SearchForAlive(2);
                        // ������ ������� 'q'
                        81:
                          begin
                            ChangeGameState(gsQUESTLIST);
                          end;
                        // ������ 'f'
                        70:
                          begin
                            if pc.HaveItemVid(14) then
                            begin
                              MenuSelected := 1;
                              VidFilter := 14;
                              ChangeGameState(gsINVENTORY);
                            end
                            else
                              AddMsg('� ���� ��� ������ ���������!', 0);
                          end;
                        // ������ 'd'
                        68:
                          begin
                            if pc.HaveItemVid(19) then
                            begin
                              MenuSelected := 1;
                              VidFilter := 19;
                              ChangeGameState(gsINVENTORY);
                            end
                            else
                              AddMsg('� ��������� ��� ������, ��� ����� ������!', 0);
                          end;
                        // ���������� 'e'
                        69:
                          begin
                            MenuSelected := 1;
                            WasEqOrInv := 2;
                            ChangeGameState(gsEQUIPMENT);
                          end;
                        // ��������� 'i'
                        73:
                          begin
                            if pc.ItemsAmount > 0 then
                            begin
                              MenuSelected := 1;
                              VidFilter := 0;
                              WasEqOrInv := 1;
                              ChangeGameState(gsINVENTORY);
                            end
                            else
                              AddMsg('���� ��������� ����!', 0);
                          end;
                        // ������ 'F1'
                        112:
                          begin
                            ChangeGameState(gsHELP);
                          end;
                        // � ����� 'F9'
                        120:
                          begin
                            ChangeGameState(gsABOUTHERO);
                          end;
                        // ��������� 'a'
                        65:
                          pc.SearchForAlive(1);
                        // ������� 'g'
                        71:
                          begin
                            i := 1;
                            if M.Item[pc.x, pc.y].amount > 1 then
                            begin
                              // ���� ������, �� ����� ��� ��� ��������
                              if not(ssShift in Shift) then
                                i := M.Item[pc.x, pc.y].amount
                              else
                              begin
                                AddMsg(ItemName(M.Item[pc.x, pc.y], 0, TRUE) + '. ������� ������ �����?', 0);
                                n := Input(LastMsgL + 1, MapY + (LastMsgY - 1), IntToStr(M.Item[pc.x, pc.y].amount));
                                if TryStrToInt(n, i) then
                                begin
                                  if (i > M.Item[pc.x, pc.y].amount) then
                                  begin
                                    AddMsg('������� ������� ������� ��������.', 0);
                                    i := 0;
                                  end;
                                end
                                else
                                begin
                                  AddMsg('����� ������ �����.', 0);
                                  i := 0;
                                end;
                              end;
                            end;
                            if i > 0 then
                            begin
                              case pc.PickUp(M.Item[pc.x, pc.y], False, i) of
                                0:
                                  begin
                                    Item := M.Item[pc.x, pc.y];
                                    Item.amount := i;
                                    AddMsg('�� ���������� ' + ItemName(Item, 0, TRUE) + '.', 0);
                                    if M.Item[pc.x, pc.y].amount > i then
                                      dec(M.Item[pc.x, pc.y].amount, i)
                                    else
                                      M.Item[pc.x, pc.y].id := 0;
                                  end;
                                1:
                                  AddMsg('����� ������ �� �����!', 0);
                                2:
                                  AddMsg('���� ��������� ��������� �����! ��� ����� ����� ���������?! ���� �� �������� � ���, ����� �������� ��� ������� ��������� ����...',
                                    0);
                                3:
                                  AddMsg('�� �� ������ ����� ������... ������� ������!', 0);
                              end;
                            end;
                          end;
                        // ������� 'o'
                        79:
                          begin
                            AddMsg('��� �� ������ �������?', 0);
                            ChangeGameState(gsOPEN);
                          end;
                        // ����� � ���� ������ � ����������� 'x'
                        88:
                          begin
                            MenuSelected := 1;
                            ChangeGameState(gsSKILLSMENU);
                          end;
                        // ������� ��������� 'm'
                        77:
                          ChangeGameState(gsHISTORY);
                        // �������� 'y'
                        89:
                          begin
                            AddMsg('��� �� ������ ��������?', 0);
                            Input(LastMsgL + 1, MapY + (LastMsgY - 1), '');
                          end;
                        // �������� 's'
                        83:
                          pc.PrepareShooting(pc.eq[7], pc.eq[13], 1);
                        // �������� ������� 'tab'
                        VK_TAB:
                          begin
                            case pc.tactic of
                              0:
                                AddMsg('������� ������� - $�����������$.', 0);
                              1:
                                AddMsg('������� ������� - *����������� ���������*.', 0);
                              2:
                                AddMsg('������� ������� - #������#.', 0);
                            end;
                            case Ask('������� �������: (#A#) - ����������� ���������, (#S#) - �����������, (#D#) - ����������.') of
                              'A':
                                begin
                                  ClearMsg;
                                  pc.tactic := 1;
                                  AddMsg('������� ����������� ���������.', 0);
                                  AddMsg('������������� ������:', 0);
                                  AddMsg('#+50% � ��������� ��������� � �����#, *-50% � ��������� � ������������� �����*.', 0);
                                end;
                              'S':
                                begin
                                  ClearMsg;
                                  pc.tactic := 0;
                                  AddMsg('������� ����������� �������.', 0);
                                  AddMsg('������� ������ � ������� �� ����� ���.', 0);
                                end;
                              'D':
                                begin
                                  ClearMsg;
                                  pc.tactic := 2;
                                  AddMsg('������� �������� �������.', 0);
                                  AddMsg('������������� ������:', 0);
                                  AddMsg('*-50% � ��������� ��������� � �����*, #+50% � ��������� � ������������� �����#.', 0);
                                end;
                            ELSE
                              AddMsg('�� �����{/a} �� ������ �������.', 0);
                            end;
                          end;
                      end;
                  end;
                // ������� �����
                gsCLOSE:
                  begin
                    case Key of
                      35, 97, 49:
                        pc.CloseDoor(-1, 1);
                      40, 98, 50:
                        pc.CloseDoor(0, 1);
                      34, 99, 51:
                        pc.CloseDoor(1, 1);
                      37, 100, 52:
                        pc.CloseDoor(-1, 0);
                      39, 102, 54:
                        pc.CloseDoor(1, 0);
                      36, 103, 55:
                        pc.CloseDoor(-1, -1);
                      38, 104, 56:
                        pc.CloseDoor(0, -1);
                      33, 105, 57:
                        pc.CloseDoor(1, -1);
                    else
                      AddDrawMsg('������� ������������ �����������!', 0);
                    end;
                    pc.turn := 1;
                    ChangeGameState(gsPLAY);
                  end;
                // �������
                gsOPEN:
                  begin
                    case Key of
                      35, 97, 49:
                        pc.Open(-1, 1);
                      40, 98, 50:
                        pc.Open(0, 1);
                      34, 99, 51:
                        pc.Open(1, 1);
                      37, 100, 52:
                        pc.Open(-1, 0);
                      39, 102, 54:
                        pc.Open(1, 0);
                      36, 103, 55:
                        pc.Open(-1, -1);
                      38, 104, 56:
                        pc.Open(0, -1);
                      33, 105, 57:
                        pc.Open(1, -1);
                    else
                      AddDrawMsg('������� ������������ �����������!', 0);
                    end;
                    pc.turn := 1;
                    ChangeGameState(gsPLAY);
                  end;
                // ���������!
                gsCHOOSEMONSTER:
                  begin
                    case Key of
                      35, 97, 49:
                        case wtd of
                          1:
                            pc.Fight(M.MonL[M.MonP[pc.x - 1, pc.y + 1]], 0);
                          2:
                            pc.Talk(M.MonL[M.MonP[pc.x - 1, pc.y + 1]]);
                          3:
                            if LastGameState = gsEQUIPMENT then
                              pc.GiveItem(MenuSelected, 2, M.MonL[M.MonP[pc.x - 1, pc.y + 1]])
                            else
                              pc.GiveItem(MenuSelected, 1, M.MonL[M.MonP[pc.x - 1, pc.y + 1]]);
                        end;
                      40, 98, 50:
                        case wtd of
                          1:
                            pc.Fight(M.MonL[M.MonP[pc.x, pc.y + 1]], 0);
                          2:
                            pc.Talk(M.MonL[M.MonP[pc.x, pc.y + 1]]);
                          3:
                            if LastGameState = gsEQUIPMENT then
                              pc.GiveItem(MenuSelected, 2, M.MonL[M.MonP[pc.x, pc.y + 1]])
                            else
                              pc.GiveItem(MenuSelected, 1, M.MonL[M.MonP[pc.x, pc.y + 1]]);
                        end;
                      34, 99, 51:
                        case wtd of
                          1:
                            pc.Fight(M.MonL[M.MonP[pc.x + 1, pc.y + 1]], 0);
                          2:
                            pc.Talk(M.MonL[M.MonP[pc.x + 1, pc.y + 1]]);
                          3:
                            if LastGameState = gsEQUIPMENT then
                              pc.GiveItem(MenuSelected, 2, M.MonL[M.MonP[pc.x + 1, pc.y + 1]])
                            else
                              pc.GiveItem(MenuSelected, 1, M.MonL[M.MonP[pc.x + 1, pc.y + 1]]);
                        end;
                      37, 100, 52:
                        case wtd of
                          1:
                            pc.Fight(M.MonL[M.MonP[pc.x - 1, pc.y]], 0);
                          2:
                            pc.Talk(M.MonL[M.MonP[pc.x - 1, pc.y]]);
                          3:
                            if LastGameState = gsEQUIPMENT then
                              pc.GiveItem(MenuSelected, 2, M.MonL[M.MonP[pc.x - 1, pc.y]])
                            else
                              pc.GiveItem(MenuSelected, 1, M.MonL[M.MonP[pc.x - 1, pc.y]]);
                        end;
                      39, 102, 54:
                        case wtd of
                          1:
                            pc.Fight(M.MonL[M.MonP[pc.x + 1, pc.y]], 0);
                          2:
                            pc.Talk(M.MonL[M.MonP[pc.x + 1, pc.y]]);
                          3:
                            if LastGameState = gsEQUIPMENT then
                              pc.GiveItem(MenuSelected, 2, M.MonL[M.MonP[pc.x + 1, pc.y]])
                            else
                              pc.GiveItem(MenuSelected, 1, M.MonL[M.MonP[pc.x + 1, pc.y]]);
                        end;
                      36, 103, 55:
                        case wtd of
                          1:
                            pc.Fight(M.MonL[M.MonP[pc.x - 1, pc.y - 1]], 0);
                          2:
                            pc.Talk(M.MonL[M.MonP[pc.x - 1, pc.y - 1]]);
                          3:
                            if LastGameState = gsEQUIPMENT then
                              pc.GiveItem(MenuSelected, 2, M.MonL[M.MonP[pc.x - 1, pc.y - 1]])
                            else
                              pc.GiveItem(MenuSelected, 1, M.MonL[M.MonP[pc.x - 1, pc.y - 1]]);
                        end;
                      38, 104, 56:
                        case wtd of
                          1:
                            pc.Fight(M.MonL[M.MonP[pc.x, pc.y - 1]], 0);
                          2:
                            pc.Talk(M.MonL[M.MonP[pc.x, pc.y - 1]]);
                          3:
                            if LastGameState = gsEQUIPMENT then
                              pc.GiveItem(MenuSelected, 2, M.MonL[M.MonP[pc.x, pc.y - 1]])
                            else
                              pc.GiveItem(MenuSelected, 1, M.MonL[M.MonP[pc.x, pc.y - 1]]);
                        end;
                      33, 105, 57:
                        case wtd of
                          1:
                            pc.Fight(M.MonL[M.MonP[pc.x + 1, pc.y - 1]], 0);
                          2:
                            pc.Talk(M.MonL[M.MonP[pc.x + 1, pc.y - 1]]);
                          3:
                            if LastGameState = gsEQUIPMENT then
                              pc.GiveItem(MenuSelected, 2, M.MonL[M.MonP[pc.x + 1, pc.y - 1]])
                            else
                              pc.GiveItem(MenuSelected, 1, M.MonL[M.MonP[pc.x + 1, pc.y - 1]]);
                        end;
                    else
                      AddDrawMsg('������� ������������ �����������!', 0);
                    end;
                    pc.turn := 1;
                    ChangeGameState(gsPLAY);
                  end;
                // ���������� �������� �������
                gsLOOK:
                  begin
                    case Key of
                      35, 97, 49:
                        pc.MoveLook(-1, 1);
                      40, 98, 50:
                        pc.MoveLook(0, 1);
                      34, 99, 51:
                        pc.MoveLook(1, 1);
                      37, 100, 52:
                        pc.MoveLook(-1, 0);
                      12, 101, 53:
                        pc.MoveLook(0, 0);
                      39, 102, 54:
                        pc.MoveLook(1, 0);
                      36, 103, 55:
                        pc.MoveLook(-1, -1);
                      38, 104, 56:
                        pc.MoveLook(0, -1);
                      33, 105, 57:
                        pc.MoveLook(1, -1);
                      13:
                        AnimFly(pc.x, pc.y, lx, ly, '`', crBrown);
                    else
                      ChangeGameState(gsPLAY);
                      M.DrawScene;
                    end;
                  end;
                // ���������� �������� �������
                gsAIM:
                  begin
                    case Key of
                      35, 97, 49:
                        pc.MoveAim(-1, 1);
                      40, 98, 50:
                        pc.MoveAim(0, 1);
                      34, 99, 51:
                        pc.MoveAim(1, 1);
                      37, 100, 52:
                        pc.MoveAim(-1, 0);
                      12, 101, 53:
                        pc.MoveAim(0, 0);
                      39, 102, 54:
                        pc.MoveAim(1, 0);
                      36, 103, 55:
                        pc.MoveAim(-1, -1);
                      38, 104, 56:
                        pc.MoveAim(0, -1);
                      33, 105, 57:
                        pc.MoveAim(1, -1);
                      13, 83:
                        if (lx = pc.x) and (ly = pc.y) then
                          AddMsg('����� ����� ESC, ���� �� ��� ������ �������!', 0)
                        else
                        begin
                          // ������� ��������� �������
                          if Bow.id = 0 then
                            pc.DeleteItemInv(13, 1, 2)
                          else
                          begin
                            case WasEqOrInv of
                              1:
                                pc.DeleteItemInv(MenuSelected, 1, 1);
                              2:
                                pc.DeleteItemInv(MenuSelected, 1, 2);
                            end;
                          end;
                          ChangeGameState(gsPLAY);
                          pc.StartShooting(ShootingMode);
                          pc.turn := 1;
                        end;
                    ELSE
                      ChangeGameState(gsPLAY);
                      M.DrawScene;
                    end;
                  end;
                // ������
                gsHELP:
                  begin
                    if (Key = 27) or (Key = 32) then
                      ChangeGameState(LastGameState);
                  end;
                // ������ �������, ����������
                gsQUESTLIST, gsEQUIPMENT, gsINVENTORY, gsABILITYS, gsHISTORY, gsSKILLSMENU, gsUSEMENU, gsWPNSKILLS, gsABOUTHERO:
                  begin
                    // ����� � ���� ��� � ������ �����
                    if GameState = gsUSEMENU then
                    begin
                      if Key = 27 then
                        ChangeGameState(LastGameState);
                    end
                    else if (Key = 27) or (Key = 32) then
                      ChangeGameState(gsPLAY);

                    // ��� � �������
                    if GameState = gsWPNSKILLS then
                    begin
                      case Key of
                        // ���������� �������� '\'
                        220:
                          begin
                            ShowProc := not ShowProc;
                            OnPaint(Sender);
                          end;
                      end;

                    end
                    ELSE

                      // ���������� � ����������
                      if GameState = gsEQUIPMENT then
                      begin
                        case Key of
                          // i
                          73:
                            if pc.ItemsAmount > 0 then
                            begin
                              MenuSelected := 1;
                              VidFilter := 0;
                              pc.Inventory;
                              ChangeGameState(gsINVENTORY);
                            end;
                          // �����
                          38, 104, 56:
                            if MenuSelected = 1 then
                              MenuSelected := EqAmount
                            else
                              dec(MenuSelected);
                          // ����
                          40, 98, 50:
                            if MenuSelected = EqAmount then
                              MenuSelected := 1
                            else
                              inc(MenuSelected);
                          // ����� / ����� � ���������
                          13:
                            begin
                              // �����
                              if pc.eq[MenuSelected].id > 0 then
                              begin
                                MenuSelected2 := 1;
                                pc.UseMenu;
                                ChangeGameState(gsUSEMENU);
                              end
                              else if pc.HaveItemVid(Eq2Vid(MenuSelected)) then
                              begin
                                VidFilter := Eq2Vid(MenuSelected);
                                MenuSelected := 1;
                                ChangeGameState(gsINVENTORY);
                              end;
                            end;
                        end;
                      end
                      ELSE

                        // ���������� � ���������
                        if GameState = gsINVENTORY then
                        begin
                          case Key of
                            // i
                            73:
                              begin
                                MenuSelected := 1;
                                pc.Equipment;
                                ChangeGameState(gsEQUIPMENT);
                              end;
                            // �����
                            38, 104, 56:
                              if VidFilter = 0 then
                              begin
                                if MenuSelected = 1 then
                                  MenuSelected := ReturnInvAmount
                                else
                                  dec(MenuSelected);
                              end
                              else if MenuSelected = 1 then
                                MenuSelected := ReturnInvListAmount
                              else
                                dec(MenuSelected);
                            // ����
                            40, 98, 50:
                              if VidFilter = 0 then
                              begin
                                if MenuSelected = ReturnInvAmount then
                                  MenuSelected := 1
                                else
                                  inc(MenuSelected);
                              end
                              else if MenuSelected = ReturnInvListAmount then
                                MenuSelected := 1
                              else
                                inc(MenuSelected);
                            // ������� ������ �������� � ���������
                            13:
                              begin
                                if VidFilter = 0 then
                                begin
                                  MenuSelected2 := 1;
                                  pc.UseMenu;
                                  ChangeGameState(gsUSEMENU);
                                end
                                else
                                  UseItem(InvList[MenuSelected]);
                              end;
                          end;
                        end
                        ELSE

                          // ���������� � ������ ������������
                          if GameState = gsABILITYS then
                          begin
                            case Key of
                              // �����
                              38, 104, 56:
                                begin
                                  if MenuSelected = 1 then
                                  begin
                                    for a := 1 to AbilitysAmount - 1 do
                                      if FullAbilitys[a + 1] = 0 then
                                        break;
                                    MenuSelected := a;
                                  end
                                  else
                                    dec(MenuSelected);
                                end;
                              // ����
                              40, 98, 50:
                                begin
                                  for a := 1 to AbilitysAmount - 1 do
                                    if FullAbilitys[a + 1] = 0 then
                                      break;
                                  if MenuSelected = a then
                                    MenuSelected := 1
                                  else
                                    inc(MenuSelected);
                                end;
                            end;
                          end
                          ELSE

                            // ������ �������� ��� ���������
                            if GameState = gsUSEMENU then
                            begin
                              case Key of
                                // �����
                                38, 104, 56:
                                  begin
                                    if MenuSelected2 = 1 then
                                      MenuSelected2 := HOWMANYVARIANTS
                                    else
                                      dec(MenuSelected2);
                                    OnPaint(Sender);
                                  end;
                                // ����
                                40, 98, 50:
                                  begin
                                    if MenuSelected2 = HOWMANYVARIANTS then
                                      MenuSelected2 := 1
                                    else
                                      inc(MenuSelected2);
                                    OnPaint(Sender);
                                  end;
                                // ������� ��������� �������� � ���������
                                13:
                                  begin
                                    case MenuSelected2 of
                                      1: // ������������
                                        begin
                                        // � ����������
                                        if LastGameState = gsEQUIPMENT then
                                        begin
                                        case pc.PickUp(pc.eq[MenuSelected], TRUE, pc.eq[MenuSelected].amount) of
                                        0:
                                        begin
                                        ItemOnOff(pc.eq[MenuSelected], False);
                                        AddMsg('�� �������{/a} ' + ItemName(pc.eq[MenuSelected], 1, TRUE) + ' ������� � ���������.', 0);
                                        pc.eq[MenuSelected].id := 0;
                                        ChangeGameState(gsEQUIPMENT);
                                        end;
                                        1:
                                        begin
                                        AddMsg('*�� �������{/a} ������� ������� � ���� ��������� :)*', 0);
                                        ChangeGameState(gsPLAY);
                                        end;
                                        2:
                                        begin
                                        AddMsg('���� ��������� ��������� �����! ��� ��� ���� �������� ����� ��� � �����.', 0);
                                        ChangeGameState(gsPLAY);
                                        end;
                                        3:
                                        begin
                                        AddMsg('*����� ���� �� ������ - ���� ���� � ���� ����������, �� ������ �������� ��, ��� �� ��� ������ � ���������.*',
                                        0);
                                        ChangeGameState(gsPLAY);
                                        end;
                                        end;
                                        end
                                        else
                                        UseItem(MenuSelected);
                                        end;
                                      2: // �����������
                                        begin
                                        if LastGameState = gsEQUIPMENT then
                                        ExamineItem(pc.eq[MenuSelected])
                                        else
                                        ExamineItem(pc.Inv[MenuSelected]);
                                        ChangeGameState(gsPLAY);
                                        pc.turn := 1;
                                        end;
                                      3: // �������
                                        begin
                                        if LastGameState = gsEQUIPMENT then
                                        pc.PrepareShooting(pc.eq[MenuSelected], pc.eq[MenuSelected], 2)
                                        else
                                        pc.PrepareShooting(pc.Inv[MenuSelected], pc.Inv[MenuSelected], 2);
                                        end;
                                      4: // ������
                                        begin
                                        GameState := gsPLAY;
                                        pc.SearchForAlive(3);
                                        end;
                                      5: // ��������
                                        begin
                                        ChangeGameState(gsPLAY);
                                        if LastGameState = gsEQUIPMENT then
                                        begin
                                        i := 1;
                                        if pc.eq[MenuSelected].amount > 1 then
                                        begin
                                        AddMsg(ItemName(pc.eq[MenuSelected], 0, TRUE) + '. ������� ������ ��������?', 0);
                                        n := Input(LastMsgL + 1, MapY + (LastMsgY - 1), IntToStr(pc.eq[MenuSelected].amount));
                                        if TryStrToInt(n, i) then
                                        begin
                                        if (i > pc.eq[MenuSelected].amount) then
                                        begin
                                        AddMsg('������� ������� ������� ��������.', 0);
                                        i := 0;
                                        end;
                                        end
                                        else
                                        begin
                                        AddMsg('����� ������ �����.', 0);
                                        i := 0;
                                        end;
                                        end;
                                        if i > 0 then
                                        begin
                                        if PutItem(pc.x, pc.y, pc.eq[MenuSelected], i) then
                                        begin
                                        Item := pc.eq[MenuSelected];
                                        Item.amount := i;
                                        AddMsg('�� ����������� ' + ItemName(Item, 0, TRUE) + '.', 0);
                                        pc.DeleteItemInv(MenuSelected, i, 2);
                                        pc.turn := 1;
                                        end
                                        else
                                        AddMsg('����� ��� ����� ��� ����, ��� �� �������� ���-����!', 0);
                                        end;
                                        end
                                        else
                                        begin
                                        i := 1;
                                        if pc.Inv[MenuSelected].amount > 1 then
                                        begin
                                        AddMsg(ItemName(pc.Inv[MenuSelected], 0, TRUE) + '. ������� ������ ��������?', 0);
                                        n := Input(LastMsgL + 1, MapY + (LastMsgY - 1), IntToStr(pc.Inv[MenuSelected].amount));
                                        if TryStrToInt(n, i) then
                                        begin
                                        if (i > pc.Inv[MenuSelected].amount) then
                                        begin
                                        AddMsg('������� ������� ������� ��������.', 0);
                                        i := 0;
                                        end;
                                        end
                                        else
                                        begin
                                        AddMsg('����� ������ �����.', 0);
                                        i := 0;
                                        end;
                                        end;
                                        if i > 0 then
                                        begin
                                        if PutItem(pc.x, pc.y, pc.Inv[MenuSelected], i) then
                                        begin
                                        Item := pc.Inv[MenuSelected];
                                        Item.amount := i;
                                        AddMsg('�� ����������� ' + ItemName(Item, 0, TRUE) + '.', 0);
                                        pc.DeleteItemInv(MenuSelected, i, 1);
                                        pc.turn := 1;
                                        end
                                        else
                                        AddMsg('����� ��� ����� ��� ����, ��� �� �������� ���-����!', 0);
                                        end;
                                        end;
                                        end;
                                    end;
                                  end;
                              end;
                            end
                            ELSE

                              // ���� ������� � ������������
                              if GameState = gsSKILLSMENU then
                              begin
                                case Key of
                                  // �����
                                  38, 104, 56:
                                    begin
                                      if MenuSelected = 1 then
                                        MenuSelected := 4
                                      else
                                        dec(MenuSelected);
                                      OnPaint(Sender);
                                    end;
                                  // ����
                                  40, 98, 50:
                                    begin
                                      if MenuSelected = 4 then
                                        MenuSelected := 1
                                      else
                                        inc(MenuSelected);
                                      OnPaint(Sender);
                                    end;
                                  // Ok...
                                  13:
                                    begin
                                      case MenuSelected of
                                        3: // ��������� �����������
                                        ChangeGameState(gsWPNSKILLS);
                                        4: // ��������� �����������
                                        ChangeGameState(gsABILITYS);
                                      end;
                                      MenuSelected := 1;
                                      OnPaint(Sender);
                                    end;
                                end;
                              end; { ELSE }

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
  CanClose := False;
  if (pc.Hp <= 0) or (AskForQuit = False) then
  begin
    EndGame;
    CanClose := TRUE;
  end
  else if (GameState = gsPLAY) or (GameState = gsLOOK) or (GameState = gsCLOSE) or (GameState = gsCHOOSEMONSTER) then
  begin
    MenuSelected := 1;
    if (Ask('�������� ���, �������� ������? #(Y/n)#')) = 'Y' then
    begin
      CanClose := TRUE;
      EndGame;
    end
    else
      AddMsg('�� �����{/a} ������ ��� ����-����.', 0);
  end
  else
  begin
    if (GameState <> gsHEROGENDER) and (GameState <> gsHERONAME) then
    begin
      ChangeGameState(gsPLAY);
      OnPaint(Sender);
    end;
  end;
end;

{ ���������� - �������� ���� }
procedure TMainForm.FormResize(Sender: TObject);
begin
  if GameState > 0 then
    OnPaint(Sender);
end;

{ ��� �����, ��� �� TAB ���������� }
procedure TMainForm.CMDialogKey(var msg: TCMDialogKey);
begin
  if msg.Charcode <> VK_TAB then
    inherited;
end;

{ ��������� ������ }
procedure TMainForm.InitGame;
begin
  // ��������� ���� -> ����
  ChangeGameState(gsPLAY);
  AskForQuit := TRUE;
  // ����� � ��������� ��������
  GenerateColorAndStateOfLiquids;
  // ������ �������
  AddMsg('����� ������ � ����� ����.', 0);
  // ����� ������ �����������
  case PlayMode of
    AdventureMode: // ��������� �������
      begin
        pc.level := 1;
        M.MakeSpMap(pc.level);
        pc.PlaceHere(6, 18);
        AddMsg('����� ���������� ������ ����������, ��, �������, ������{/a} � ��������� �������. ����� �����, ��� ����� �������� �������� ����. �� ������ ����������� � ����...',
          0);
      end;
    DungeonMode: // ���� � ����������
      begin
        pc.level := 7;
        M.MakeSpMap(pc.level);
        pc.PlaceHere(42, 16);
        AddMsg('������ ���������� ������� - �� ������ ����� ������ � ������, �������, �������� ��������, ������ � ���� ��������� �������� � ����������. �� ��������� ����� - �������, � ��� ������� ���� ����...',
          0);
      end;
  end;
  pc.FOV;
  AddMsg(' ', 0);
  AddMsg('����� (#F1#), ���� ����� ������.', 0);
  OnPaint(NIL);
end;

{ �������� �������� ������� }
procedure TMainForm.AnimFly(x1, y1, x2, y2: integer; symbol: string; color: byte);
var
  dx, dy, i, sx, sy, check, e, oldx, oldy: integer;
begin
  dx := abs(x1 - x2);
  dy := abs(y1 - y2);
  sx := Sign(x2 - x1);
  sy := Sign(y2 - y1);
  FlyX := x1;
  FlyY := y1;
  FlyS := symbol;
  FlyC := color;
  check := 0;
  if dy > dx then
  begin
    dx := dx + dy;
    dy := dx - dy;
    dx := dx - dy;
    check := 1;
  end;
  e := 2 * dy - dx;
  for i := 0 to dx - 1 do
  begin
    oldx := FlyX;
    oldy := FlyY;
    if e >= 0 then
    begin
      if check = 1 then
        FlyX := FlyX + sx
      else
        FlyY := FlyY + sy;
      e := e - 2 * dx;
    end;
    if check = 1 then
      FlyY := FlyY + sy
    else
      FlyX := FlyX + sx;
    e := e + 2 * dy;
    // � ������ ��������� � ��� �����������
    if not TilesData[M.Tile[FlyX, FlyY]].void then
    begin
      // ���� ��������� ����� ��������� ����� �������
      break;
    end
    else
      // ����� ������
      if M.MonP[FlyX, FlyY] > 0 then
      begin
        autoaim := M.MonP[FlyY, FlyY];
        pc.Fire(M.MonL[M.MonP[FlyX, FlyY]]);
        break;
      end
      else
      begin
        OnPaint(NIL);
        sleep(FlySpeed);
      end;
  end;
  FlyX := 0;
  FlyY := 0;
end;

{ Word 2 Char }
function TMainForm.GetCharFromVirtualKey(Key: Word): string;
var
  keyboardState: TKeyboardState;
  asciiResult: integer;
begin
  GetKeyboardState(keyboardState);
  SetLength(Result, 2);
  asciiResult := ToAscii(Key, MapVirtualKey(Key, 0), keyboardState, @Result[1], 0);
  case asciiResult of
    0:
      Result := '';
    1:
      SetLength(Result, 1);
    2:
      ;
  else
    Result := '';
  end;
end;

procedure TMainForm.GameTimerTimer(Sender: TObject);
begin
  MainForm.Paint;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ReleaseDC(MainForm.Handle, DC);
  DeleteDC(DC);
end;

initialization

// ������� �������� (�����)
GScreen := TBitMap.Create;
GrayGScreen := TBitMap.Create;
// ���� ������ ������ = 0, ��������������
if FontSize = 0 then
begin
  case Screen.Height of
    1080:
      FontSize := 16;
    1050:
      FontSize := 15;
    1024:
      FontSize := 14;
    960:
      FontSize := 13;
    900, 864:
      FontSize := 12;
    800:
      FontSize := 11;
    768:
      FontSize := 10;
    720:
      FontSize := 9;
    600:
      FontSize := 8; { ������ }
  else
    // �� ���������� ����������
    FontSize := 10;
  end;
end;
// �������� �������
if (FontSize < 8) then
  FontSize := 8;
if (FontSize > 20) then
  FontSize := 20;
// �������� ������
with GScreen.Canvas do
begin
  Font.name := FontMsg;
  Font.Size := FontSize;
  case FontStyle of
    1:
      Font.Style := [fsBold];
    2:
      Font.Style := [fsItalic];
    3:
      Font.Style := [fsBold, fsItalic];
  else
    Font.Style := [];
  end;
  CharX := TextWidth('W');
  CharY := TextHeight('W');
end;

finalization

// ����������� �������� (�����)
GScreen.Free;

end.
