unit main;

interface

uses
  Windows, Classes, Graphics, Forms, SysUtils, ExtCtrls, Controls, StdCtrls, Dialogs, Math;

type
  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ProcessMsg;
    procedure EndGame;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure InitGame;
  private
    procedure CMDialogKey( Var msg: TCMDialogKey );
    message CM_DIALOGKEY;
    procedure AnimFly(x1,y1,x2,y2:integer;symbol:string; color:byte);
    function GetCharFromVirtualKey(Key: Word): string;
  public
  end;

var
  MainForm             : TMainForm;
  Screen               : TBitMap;              // �������� ��� �������-������������
  WaitMore             : boolean;              // --�����--
  WaitEnter            : boolean;              // ���� ������� Enter
  Inputing             : boolean;              // ����� �����
  GameState            : byte;                 // ��������� ����
  Answer               : string[1];            // ��������� �����
  AskForQuit           : boolean;              // ������������� ������
  MenuSelected,
  MenuSelected2        : byte;                 // ��������� ������� � ����
  VidFilter            : byte;                 // �������� ������ ���� ���������� � ��������� (0-���)
  WasEq                : boolean;              // ����� ������� ���� �������� � ��������� ��� ��������� ��� ����������
  a                    : integer;
  wtd                  : byte;                 // ��� ������� ��� ������ �������
  PlayMode             : byte;                 // 0-�����������,1-����������

implementation

{$R *.dfm}

uses
  Cons, Utils, Msg, Player, Map, Tile, Help, Items, Ability, MapEditor;

{ ������������� }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  PlayMode := AdventureMode;
  // ������ ����
  ClientWidth := WindowX * CharX;
  ClientHeight := WindowY * CharY;
  // ���� ����� ����������� �� ����� ��������� �����
  if PlayMode = AdventureMode then
    if not MainEdForm.LoadSpecialMaps then
    begin
      ShowMessage('������ �������� ����� maps.dp!');
      Halt;
    end;
  // ������� ��������
  Screen := TBitMap.Create;
  Screen.Width := ClientWidth;
  Screen.Height := ClientHeight;
  Screen.Canvas.Font.Name := FontMsg;
  GameState := gsINTRO;
  pc.id := 1;
  pc.idinlist := 1;
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
    gsPLAY, gsCLOSE, gsLOOK, gsCHOOSEMONSTER, gsOPEN, gsAIM:
    begin
      // ������� �����
      M.DrawScene;
      // ������� ���������
      ShowMsgs;
      // ������� ���������� � �����
      pc.WriteInfo;
    end;
    gsQUESTLIST    : pc.QuestList;
    gsEQUIPMENT    : pc.Equipment;
    gsINVENTORY    : pc.Inventory;
    gsHELP         : ShowHelp;
    gsUSEMENU      : begin if WasEq then pc.Equipment else pc.Inventory; pc.UseMenu; end;
    gsHERONAME     : pc.HeroName;
    gsHEROATR      : pc.HeroAtributes;
    gsHERORANDOM   : pc.HeroRandom;
    gsHEROGENDER   : pc.HeroGender;
    gsHEROCRRESULT : pc.HeroCreateResult;
    gsHEROCLWPN    : pc.HeroCloseWeapon;
    gsHEROFRWPN    : pc.HeroFarWeapon;
    gsABILITYS     : ShowAbilitys;
    gsHISTORY      : ShowHistory;
    gsINTRO        : Intro;
    gsSKILLSMENU   : SkillsAndAbilitys;
    gsWPNSKILLS    : WpnSkills;
  end;
  // ����
  if Inputing then ShowInput;
  // ����������
  Canvas.StretchDraw(ClientRect, Screen);
end;

{ ������� �� ������� }
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : integer;
  n : string;
  Item : TItem;
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
        if Key = 13 then WaitENTER := False else
        // ����
        if Inputing then
        begin
          if Key = VK_BACK then
            Delete(InputString,Length(InputString),1) else
              InputString := InputString + GetCharFromVirtualKey(Key);
          OnPaint(Sender);
        end;
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
          // ��������
          gsINTRO:
          begin
            case Key of
              13, 32 : GameState := gsHERORANDOM;
              67     : if PlayMode = 0 then PlayMode := 1 else PlayMode := 0;
            end;
          end;
          // ��������� �����?
          gsHERORANDOM:
          begin
            case Key of
              // �����/����
              38,104,56,40,98,50 :
              begin
                if MenuSelected = 1 then MenuSelected := 2 else MenuSelected := 1;
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                if MenuSelected = 1 then
                  GameState := gsHEROGENDER else
                    // �� ��������
                    begin
                      // ���
                      pc.gender := Random(2)+1;
                      // ���
                      case pc.gender of
                        genMALE   : pc.name := GenerateName(FALSE);
                        genFEMALE : pc.name := GenerateName(TRUE);
                      end;
                      // ��������
                      pc.atr[1] := Random(3)+1;
                      pc.atr[2] := Random(3)+1;
                      // �������� ���� ������ ������ �� ������
                      pc.Prepare;
                      pc.PrepareSkills;
                      if (HowManyBestWPNCL > 1) and not ((HowManyBestWPNCL < 3) and (OneOfTheBestWPNCL(CLOSE_TWO))) then
                      begin
                        pc.CreateClWList;
                        c_choose := Wlist[Random(wlistsize)+1];
                      end;
                      if (HowManyBestWPNFR > 1) and not ((HowManyBestWPNFR < 3) and (OneOfTheBestWPNFR(FAR_THROW))) then
                      begin
                        pc.CreateFrWList;
                        f_choose := Wlist[Random(wlistsize)+1];
                      end;
                      GameState := gsHEROCRRESULT;
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
              38,104,56 :
              begin
                if MenuSelected = 1 then MenuSelected := 3 else dec(MenuSelected);
                OnPaint(SENDER);
              end;
              // ����
              40,98,50 :
              begin
                if MenuSelected = 3 then MenuSelected := 1 else inc(MenuSelected);
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                if MenuSelected < 3 then pc.gender := MenuSelected else pc.gender := Random(2)+1;
                MenuSelected := 1;
                MenuSelected2 := 1;
                pc.startheroname;
                OnPaint(Sender);
              end;
            end;
          end;
          // ����� ������ ��. ���
          gsHEROCLWPN:
          begin
            case Key of
              // �����
              38,104,56 :
              begin
                if MenuSelected > 1 then dec(MenuSelected) else MenuSelected := wlistsize;
                OnPaint(SENDER);
              end;
              // ����
              40,98,50 :
              begin
                if MenuSelected < wlistsize then inc(MenuSelected) else MenuSelected := 1;
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                c_choose := Wlist[MenuSelected];
                MenuSelected := 1;
                MenuSelected2 := 1;
                if (HowManyBestWPNFR > 1) and not ((HowManyBestWPNFR < 3) and (OneOfTheBestWPNFR(FAR_THROW)))  then
                  GameState := gsHEROFRWPN else
                    GameState := gsHEROCRRESULT;
                OnPaint(Sender);
              end;
            end;
          end;
          // ����� ������ �������� ���
          gsHEROFRWPN:
          begin
            case Key of
              // �����
              38,104,56 :
              begin
                if MenuSelected > 1 then dec(MenuSelected) else
                  for i:= 4 downto 1 do
                    if WList[i] > 0 then
                      begin
                        MenuSelected := i;
                        break;
                      end;
                OnPaint(SENDER);
              end;
              // ����
              40,98,50 :
              begin
                if MenuSelected < 4 then
                begin
                  if WList[MenuSelected+1] > 0 then
                    inc(MenuSelected) else
                      MenuSelected := 1;
                end else
                  MenuSelected := 1;
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                f_choose := Wlist[MenuSelected];
                MenuSelected := 1;
                MenuSelected2 := 1;
                GameState := gsHEROCRRESULT;
                OnPaint(Sender);
              end;
            end;
          end;
          // ����� ���������
          gsHEROATR:
          begin
            case Key of
              // �����
              38,104,56 :
              begin
                if MenuSelected = 1 then MenuSelected := 3 else dec(MenuSelected);
                OnPaint(SENDER);
              end;
              // ����
              40,98,50 :
              begin
                if MenuSelected = 3 then MenuSelected := 1 else inc(MenuSelected);
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                pc.atr[MenuSelected2] := MenuSelected;
                if MenuSelected2 = 1 then
                begin
                  MenuSelected := 1;
                  inc(MenuSelected2);
                end else
                  begin
                    MenuSelected := 1;
                    // �������� ���� ������ ������ �� ������
                    pc.Prepare;
                    pc.PrepareSkills;
                    if (HowManyBestWPNCL > 1) and not ((HowManyBestWPNCL < 3) and (OneOfTheBestWPNCL(CLOSE_TWO))) then
                      GameState := gsHEROCLWPN else
                        if (HowManyBestWPNFR > 1) and not ((HowManyBestWPNFR < 3) and (OneOfTheBestWPNFR(FAR_THROW))) then
                          GameState := gsHEROFRWPN else
                            GameState := gsHEROCRRESULT;
                  end;
                OnPaint(Sender);
              end;
            end;
          end;
          // �����������
          gsHEROCRRESULT:
          begin
            case Key of
              13, 32 :
              begin
                pc.FavWPNSkill;
                M.MonL[pc.idinlist] := pc;
                InitGame;
              end;
              27     :
              begin
                MenuSelected := 1;
                GameState := gsHERORANDOM;
              end;
            end;
          end;
          // �� ����� ����
          gsPLAY:
          begin
            { ������������ �� ��������� alt+��� �������}
            if ssAlt in Shift then
            begin
              If ((GetKeyState(VK_LEFT) AND 128)=128) and ((GetKeyState(VK_DOWN) AND 128)=128) then
                pc.Move(-1,1) else
              If ((GetKeyState(VK_RIGHT) AND 128)=128) and ((GetKeyState(VK_DOWN) AND 128)=128) then
                pc.Move(1,1) else
              If ((GetKeyState(VK_LEFT) AND 128)=128) and ((GetKeyState(VK_UP) AND 128)=128) then
                pc.Move(-1,-1) else
              If ((GetKeyState(VK_RIGHT) AND 128)=128) and ((GetKeyState(VK_UP) AND 128)=128) then
                pc.Move(1,-1);
            end else
            case Key of
              { ������������ }
              35,97,49     : if ssShift in Shift then pc.Run(-1,1) else pc.Move(-1,1);
              40,98,50     : if ssShift in Shift then pc.Run(0,1) else pc.Move(0,1);
              34,99,51     : if ssShift in Shift then pc.Run(1,1) else pc.Move(1,1);
              37,100,52    : if ssShift in Shift then pc.Run(-1,0) else pc.Move(-1,0);
              12,101,53,32 : pc.Move(0,0);
              39,102,54    : if ssShift in Shift then pc.Run(1,0) else pc.Move(1,0);
              36,103,55    : if ssShift in Shift then pc.Run(-1,-1) else pc.Move(-1,-1);
              38,104,56    : if ssShift in Shift then pc.Run(0,-1) else pc.Move(0,-1);
              33,105,57    : if ssShift in Shift then pc.Run(1,-1) else pc.Move(1,-1);
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
                pc.AnalysePlace(lx,ly,2);
              end;
              // �������� 't'
              84        : pc.SearchForAlive(2);
              // ������ ������� 'q'
              81        :
              begin
                GameState := gsQUESTLIST;
              end;
              // ������ 'f'
              70        :
              begin
                if pc.HaveItemVid(14) then
                begin
                  MenuSelected := 1;
                  VidFilter := 14;
                  GameState := gsINVENTORY;
                end else
                  AddMsg('� ���� ��� ������ ���������!');
              end;
              // ������ 'd'
              68        :
              begin
                if pc.HaveItemVid(19) then
                begin
                  MenuSelected := 1;
                  VidFilter := 19;
                  GameState := gsINVENTORY;
                end else
                  AddMsg('� ��������� ��� ������ ��� ����� ������!');
              end;
              // ���������� 'e'
              69        :
              begin
                  MenuSelected := 1;
                  GameState := gsEQUIPMENT;
              end;
              // ��������� 'i'
              73        :
              begin
                if pc.ItemsAmount > 0 then
                begin
                  MenuSelected := 1;
                  VidFilter := 0;
                  GameState := gsINVENTORY;
                end else
                  AddMsg('���� ��������� ����!');
              end;
              // ������ '?'
              112       :
              begin
                GameState := gsHELP;
              end;
              // ��������� 'a'
              65        : pc.SearchForAlive(1);
              // ������� 'g'
              71        :
              begin
                i := 1;
                if M.Item[pc.x,pc.y].amount > 1 then
                begin
                  AddMsg(ItemName(M.Item[pc.x,pc.y], 0, TRUE)+'. ������� ������ �����?');
                  n := Input(LastMsgL+1, MapY+(LastMsgY-1), IntToStr(M.Item[pc.x,pc.y].amount));
                  if TryStrToInt(n,i) then
                  begin
                    if (i > M.Item[pc.x,pc.y].amount) then
                    begin
                      AddMsg('������� ������� ������� ��������.');
                      i := 0;
                    end;
                  end else
                    begin
                      AddMsg('����� ������ �����.');
                      i := 0;
                    end;
                end;
                if i > 0 then
                begin
                  case pc.PickUp(M.Item[pc.x,pc.y], FALSE,i) of
                    0 :
                    begin
                      Item := M.Item[pc.x,pc.y];
                      Item.amount := i;
                      AddMsg('�� ���������� '+ItemName(Item,0,TRUE)+'.');
                      if M.Item[pc.x,pc.y].amount > i then
                        dec(M.Item[pc.x,pc.y].amount,i) else
                          M.Item[pc.x,pc.y].id := 0;
                    end;
                    1 : AddMsg('����� ������ �� �����!');
                    2 : AddMsg('���� ��������� �������� �����! ��� ����� ����� ���������?! ���� �� �������� � ���, ����� �������� ��� ������� ��������� ����...');
                    3 : AddMsg('�� �� ������ ����� ������... ������� ������!');
                  end;
                end;
              end;
              // ������� 'o'
              79        :
              begin
                AddMsg('��� �� ������ �������?');
                GameState := gsOPEN;
              end;
              // ����� � ���� ������ � ����������� 'x'
              88        :
              begin
                MenuSelected := 1;
                GameState := gsSKILLSMENU;
              end;
              // ������� ��������� 'm'
              77        :
                GameState := gsHISTORY;
              // �������� 'y'
              89        :
              begin
                AddMsg('��� �� ������ ��������?');
                Input(LastMsgL+1, MapY+(LastMsgY-1), '');
              end;
              // �������� 's'
              83       :
              begin
                if (pc.eq[13].id > 0) then
                begin
                  if (pc.eq[7].id = 0) or (ItemsData[pc.eq[7].id].kind = ItemsData[pc.eq[13].id].kind) then
                  begin
                    AddMsg('{�������� �:}');
                    i := pc.SearchForAliveField;
                    if autoaim > 0 then
                      if (M.Saw[M.MonL[autoaim].x, M.MonL[autoaim].y] = 2) and (M.MonL[autoaim].id > 0) then
                        i := autoaim;
                    if i > 0 then
                    begin
                      lx := M.MonL[i].x;
                      ly := M.MonL[i].y;
                      pc.AnalysePlace(lx,ly,1);
                      GameState := gsAIM;
                    end else
                      begin
                        lx := pc.x;
                        ly := pc.y;
                        pc.AnalysePlace(lx,ly,1);
                        GameState := gsAIM;
                      end;
                  end else
                    AddMsg(ItemsData[pc.eq[13].id].name2+' � '+ItemsData[pc.eq[7].id].name1+' - �� ����������!');
                end else
                  AddMsg('���� ��������� � ���������� ����!');
              end;
              // �������� ������� 'tab'
              VK_TAB    :
              begin
                case pc.tactic of
                   0 : AddMsg('������� ������� - {�����������}.');
                   1 : AddMsg('������� ������� - <����������� ���������>.');
                   2 : AddMsg('������� ������� - [������].');
                end;
                case Ask('������� �������: ([A]) - ����������� ���������, ([S]) - �����������, ([D]) - ����������.') of
                  'A' :
                  begin
                    ClearMsg;
                    pc.tactic := 1;
                    AddMsg('������� ����������� ���������.');
                    AddMsg('������������� ������:');
                    AddMsg('[+50% � ��������� ��������� � �����], <-50% � ��������� � ������������� �����>.');
                  end;
                  'S' :
                  begin
                    ClearMsg;
                    pc.tactic := 0;
                    AddMsg('������� ����������� �������.');
                    AddMsg('������� ������ � ������� �� ����� ���.');
                  end;
                  'D' :
                  begin
                    ClearMsg;
                    pc.tactic := 2;
                    AddMsg('������� �������� �������.');
                    AddMsg('������������� ������:');
                    AddMsg('<-50% � ��������� ��������� � �����>, [+50% � ��������� � ������������� �����].');
                  end;
                  ELSE
                    AddMsg('�� �����'+pc.HeSheIt(1)+' �� ������ �������.');
                end;
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
              13        : AnimFly(pc.x,pc.y,lx,ly,'`',crBrown);
              else
                GameState := gsPlay;
              M.DrawScene;
            end;
          end;
          // ���������� �������� �������
          gsAIM:
          begin
            case Key of
              35,97,49  : pc.MoveAim(-1,1);
              40,98,50  : pc.MoveAim(0,1);
              34,99,51  : pc.MoveAim(1,1);
              37,100,52 : pc.MoveAim(-1,0);
              12,101,53 : pc.MoveAim(0,0);
              39,102,54 : pc.MoveAim(1,0);
              36,103,55 : pc.MoveAim(-1,-1);
              38,104,56 : pc.MoveAim(0,-1);
              33,105,57 : pc.MoveAim(1,-1);
              13,83     :
                if (lx = pc.x) and (ly = pc.y) then
                  AddMsg('����� ����� ESC, ���� �� ��� ������ �������!') else
                  begin
                    GameState := gsPLAY;
                    AnimFly(pc.x,pc.y,lx,ly, ItemSymbol(pc.Eq[13].id), ItemsData[pc.Eq[13].id].color);
                    pc.turn := 1;
                  end;
              ELSE
                GameState := gsPlay;
              M.DrawScene;
            end;
          end;
          // ������ �������, ����������, ������
          gsQUESTLIST, gsEQUIPMENT, gsINVENTORY, gsHELP, gsABILITYS, gsHISTORY, gsSKILLSMENU,
          gsUSEMENU, gsWPNSKILLS:
          begin
            if (Key = 27) or (Key = 32) then GameState := gsPLAY;
            // ��� � �������
            if GameState = gsWPNSKILLS then
            begin
              case Key of
                // ���������� �������� '\'
                220 :
                begin
                  ShowProc := not ShowProc;
                  OnPaint(SENDER);
                end;
              end;

            end ELSE

            // ���������� � ����������
            if GameState = gsEQUIPMENT then
            begin
              case Key of
                //i
                73 :
                if pc.ItemsAmount > 0 then
                begin
                  MenuSelected := 1;
                  VidFilter := 0;
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
                    if pc.HaveItemVid(Eq2Vid(MenuSelected)) then
                    begin
                      VidFilter := Eq2Vid(MenuSelected);
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
                  if VidFilter = 0 then
                  begin
                    if MenuSelected = 1 then MenuSelected := ReturnInvAmount else dec(MenuSelected);
                  end else
                    if MenuSelected = 1 then MenuSelected := ReturnInvListAmount else dec(MenuSelected);
                // ����
                40,98,50 :
                  if VidFilter = 0 then
                  begin
                    if MenuSelected = ReturnInvAmount then MenuSelected := 1 else inc(MenuSelected);
                  end else
                    if MenuSelected = ReturnInvListAmount then MenuSelected := 1 else inc(MenuSelected);
                // ������� ������ �������� � ���������
                13 :
                begin
                  if VidFilter = 0 then
                  begin
                    WasEq := FALSE;
                    MenuSelected2 := 1;
                    pc.UseMenu;
                    GameState := gsUSEMENU;
                  end else
                    begin
                      UseItem(InvList[MenuSelected]);
                      GameState := gsPLAY;
                    end;
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
          end ELSE

          // ������ �������� ��� ���������
          if GameState = gsUSEMENU then
          begin
            case Key of
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
                      case pc.PickUp(pc.eq[MenuSelected], TRUE,pc.eq[MenuSelected].amount) of
                        0 :
                        begin
                          ItemOnOff(pc.eq[MenuSelected], FALSE);
                          AddMsg('�� �������'+pc.HeSheIt(1)+' '+ItemName(pc.eq[MenuSelected], 1, TRUE)+' ������� � ���������.');
                          pc.eq[MenuSelected].id := 0;
                        end;
                        1 : AddMsg('<�� �������'+pc.HeSheIt(1)+' ������� ������� � ���� ��������� :)>');
                        2 : AddMsg('���� ��������� ��������� �����! ��� ��� ���� �������� ����� ��� � �����.');
                        3 : AddMsg('<����� ���� �� ������ - ���� ���� � ���� ����������, �� ������ ��������, �� ��� �� ��� ������ � ���������.>');
                      end;
                    end else
                      UseItem(MenuSelected);
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
                      i := 1;
                      if pc.Eq[MenuSelected].amount > 1 then
                      begin
                        AddMsg(ItemName(pc.Eq[MenuSelected], 0, TRUE)+'. ������� ������ ��������?');
                        n := Input(LastMsgL+1, MapY+(LastMsgY-1), IntToStr(pc.Eq[MenuSelected].amount));
                        if TryStrToInt(n,i) then
                        begin
                          if (i > pc.Eq[MenuSelected].amount) then
                          begin
                            AddMsg('������� ������� ������� ��������.');
                            i := 0;
                          end;
                        end else
                          begin
                            AddMsg('����� ������ �����.');
                            i := 0;
                          end;
                      end;
                      if i > 0 then
                      begin
                        if PutItem(pc.x,pc.y, pc.Eq[MenuSelected], i) then
                        begin
                          Item := pc.Eq[MenuSelected];
                          Item.amount := i;
                          AddMsg('�� ����������� '+ItemName(Item,0,TRUE)+'.');
                          pc.DeleteInvItem(pc.Eq[MenuSelected], i);
                          pc.turn := 1;
                        end else
                          AddMsg('����� ��� ����� ��� ����, ��� �� �������� ���-����!');
                      end;
                    end else
                      begin
                        i := 1;
                        if pc.Inv[MenuSelected].amount > 1 then
                        begin
                          AddMsg(ItemName(pc.Inv[MenuSelected], 0, TRUE)+'. ������� ������ ��������?');
                          n := Input(LastMsgL+1, MapY+(LastMsgY-1), IntToStr(pc.Inv[MenuSelected].amount));
                          if TryStrToInt(n,i) then
                          begin
                            if (i > pc.Inv[MenuSelected].amount) then
                            begin
                              AddMsg('������� ������� ������� ��������.');
                              i := 0;
                            end;
                          end else
                            begin
                              AddMsg('����� ������ �����.');
                              i := 0;
                            end;
                        end;
                        if i > 0 then
                        begin
                          if PutItem(pc.x,pc.y, pc.Inv[MenuSelected], i) then
                          begin
                            Item := pc.Inv[MenuSelected];
                            Item.amount := i;
                            AddMsg('�� ����������� '+ItemName(Item,0,TRUE)+'.');
                            pc.DeleteInvItem(pc.Inv[MenuSelected], i);
                            pc.turn := 1;
                          end else
                            AddMsg('����� ��� ����� ��� ����, ��� �� �������� ���-����!');
                        end;
                      end;
                  end;
                end;
              end;
            end;
          end ELSE

          // ���� ������� � ������������
          if GameState = gsSKILLSMENU then
          begin
            case Key of
              // �����
              38,104,56 :
              begin
                if MenuSelected = 1 then MenuSelected := 4 else dec(MenuSelected);
                OnPaint(SENDER);
              end;
              // ����
              40,98,50 :
              begin
                if MenuSelected = 4 then MenuSelected := 1 else inc(MenuSelected);
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                case MenuSelected of
                  3 : // ��������� �����������
                  GameState := gsWPNSKILLS;
                  4 : // ��������� �����������
                  GameState := gsABILITYS;
                end;
                MenuSelected := 1;
                OnPaint(Sender);
              end;
            end;
          end; {ELSE}
          
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
        AddMsg('�� �����'+pc.HeSheIt(1)+' ������ ��� ����-����.');
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

{ ��� ����� ��� �� TAB ���������� }
procedure TMainForm.CMDialogKey(var msg: TCMDialogKey);
begin
  if msg.Charcode <> VK_TAB then inherited;
end;

{ ��������� ������ }
procedure TMainForm.InitGame;
begin
  GameState := gsPLAY;
  AskForQuit := TRUE;
  // ����� �����������
  if PlayMode = AdventureMode then
  begin
    pc.level := 1;   // �������
    M.MakeSpMap(pc.level);
    pc.PlaceHere(6,18);
    Addmsg('{����� ������ � ����� ����.}');
    Addmsg('����� ���������� ������ ����������, ��, �������, ������'+pc.HeSheIt(1)+' � ��������� �������.');
    Addmsg('����� �����, ��� ����� �������� �������� ����. �� ������ ����������� � ����.');
  end else
    if PlayMode = DungeonMode then
    begin
      pc.level := 7; // ���� � ����������
      M.MakeSpMap(pc.level);
      pc.PlaceHere(42,16);
      Addmsg('������ ���������� ������� - �� ������ ����� ������ � ������, �������, �������� ��������,');
      Addmsg('������ � ���� ��������� �������� � ����������. �� ����������� � � ���������� - �������, � ���');
      Addmsg('������� ���� ����...');
    end;
  pc.FOV;
  Addmsg(' ');
  Addmsg('����� ([F1]), ���� ����� ������.');
  OnPaint(NIL);
end;

{ �������� �������� ������� }
procedure TMainForm.AnimFly(x1,y1,x2,y2:integer; symbol:string; color:byte);
var
  dx,dy,i,sx,sy,check,e,oldx,oldy:integer;
begin
  dx:=abs(x1-x2);
  dy:=abs(y1-y2);
  sx:=Sign(x2-x1);
  sy:=Sign(y2-y1);
  FlyX:=x1;
  FlyY:=y1;
  FlyS:=symbol;
  FlyC:=color;
  check:=0;
  if dy>dx then begin
      dx:=dx+dy;
      dy:=dx-dy;
      dx:=dx-dy;
      check:=1;
  end;
  e:= 2*dy - dx;
  for i:=0 to dx-1 do
  begin
    oldx := FlyX;
    oldy := FlyY;
    if e>=0 then
    begin
      if check=1 then FlyX:=FlyX+sx else FlyY:=FlyY+sy;
      e:=e-2*dx;
    end;
    if check=1 then FlyY:=FlyY+sy else FlyX:=FlyX+sx;
    e:=e+2*dy;
    OnPaint(NIL);
    sleep(150);
    // � ������ ��������� � ��� �����������
    if not TilesData[M.Tile[FlyX,FlyY]].void then
    begin
      // ���� ��������� ����� ��������� ����� �������
      break;
    end else
      // ����� ������
      if M.MonP[FlyX,FlyY] > 0 then
      begin
        autoaim := M.MonP[FlyY,FlyY];
        pc.Fire(M.MonL[M.MonP[FlyX,FlyY]]);
          break;
      end;
  end;
  pc.DecArrows;
  FlyX := 0;
  FlyY := 0;
end;

{ Word 2 Char }
function TMainForm.GetCharFromVirtualKey(Key: Word): string;
var
  keyboardState: TKeyboardState;
  asciiResult: Integer;
begin
  GetKeyboardState(keyboardState) ;
  SetLength(Result, 2) ;
  asciiResult := ToAscii(key, MapVirtualKey(key, 0), keyboardState, @Result[1], 0) ;
  case asciiResult of
    0: Result := '';
    1: SetLength(Result, 1) ;
    2:;
  else
    Result := '';
end;

end;

end.