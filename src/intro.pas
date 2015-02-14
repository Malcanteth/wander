unit intro;

interface

procedure IntroWindow;                                   // ��������
procedure StartHeroName;
procedure HeroRandomWindow;                              // ������� ����������
procedure HeroNameWindow;                                // ���� ����� �����
procedure HeroGenderWindow;                              // ���� ������ ����
procedure HeroAtributesWindow;                           // ����������� �����������
procedure HeroCloseWeaponWindow;                         // ������ �������� ���
procedure HeroFarWeaponWindow;                           // ������ �������� ���
procedure HeroCreateResultWindow;                        // �����������
procedure ChooseModeWindow;                              // ������� ����� ����
procedure DrawGameMenu;                                  // ������� ����

const
  GMChooseAmount = 2;
  gmNEWGAME      = 1;
  gmEXIT         = 2;

implementation

uses
  Player, Conf, Main, Cons, Utils, Msg, SysUtils, Ability;
  
{ �������� }
procedure IntroWindow;
const
  up = 5;
  s0 = '#       #   #   #          #### #     ';
  s1 = ' #  #  #   ##   ##  # ###  #    ###   ';
  s2 = ' ## # ##  #  #  # # # #  # #### #  #  ';
  s3 = '  # # #   ####  #  ## #  # #    ###   ';
  s4 = '   ###   #    # #   # #  # #### #  #  ';
  s5 = '        #           # ###           # ';
begin
  with GScreen.Canvas do
  begin
    // WANDER
    Font.Color := cLIGHTGRAY;
    TextOut(((WindowX-length(s0)) div 2) * CharX, up*CharY, s0);
    Font.Color := cLIGHTBLUE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, (up+1)*CharY, s1);
    Font.Color := cBLUE;
    TextOut(((WindowX-length(s2)) div 2) * CharX, (up+2)*CharY, s2);
    Font.Color := cBLUE;
    TextOut(((WindowX-length(s3)) div 2) * CharX, (up+3)*CharY, s3);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s4)) div 2) * CharX, (up+4)*CharY, s4);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s5)) div 2) * CharX, (up+5)*CharY, s5);
    // ������
    Font.Color := cBLUEGREEN;
    TextOut((((WindowX-length(s5)) div 2) + Length(s5)) * CharX, (up+5)*CharY, GameVersion);
  end;
end;

{ ���� ����� ����� }
procedure StartHeroName;
begin
  GameState := gsHERONAME;
  Input(((WindowX-13) div 2), 17, '');
end;

{ ���� ����� ����� }
procedure HeroNameWindow;
const s2 = '^^^^^^^^^^^^^';
var
  n : string[13];
  s1: string;
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  s1 := GetMsg('����� ��� ����{�/���}:',pc.gender);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s2)) div 2) * CharX, 18*CharY, s2);
    if (Inputing = FALSE) then
    begin
      if InputString = '' then
      begin
        case pc.gender of
          genMALE   : pc.name := GenerateName(FALSE);
          genFEMALE : pc.name := GenerateName(TRUE);
        end;
      end else
        pc.name := InputString;
      GameState := gsHEROATR;
      MainForm.OnPaint(NIL);
    end;
  end;
end;

{ ������� ���������� }
procedure HeroRandomWindow;
const
  s1 = '������� �������� ��� ��� ���������� ���� ������?';
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, '������ ���');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, '��������� �����');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ���� ������ ���� }
procedure HeroGenderWindow;
const
  s1 = '������ ���� ����� ���� ��������?';
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, '��������');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, '��������');
    Font.Color := cBROWN;
    TextOut(40*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 17*CharY, '��� �������');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ����������� ����������� }
procedure HeroAtributesWindow;
var
  s1, s2 : string;
begin
  s1 := Format('������ �������, � ������� %s ������ ����� ��������{/a}:', [pc.name]); //'������ �������, � ������� '+pc.name+' ������ ����� ��������{/a}:';
  s2 := Format('� ������ ������ �������, �������� %s ���� ������{/a} ��������:', [pc.name]); //'� ������ ������ �������, �������� '+pc.name+' ���� ������{/a} ��������:';
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    case MenuSelected2 of
      1 :
      TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(S1,pc.gender));
      2 :
      TextOut(((WindowX-length(s2)) div 2) * CharX, 13*CharY, GetMsg(S2,pc.gender));
    end;
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, '����');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, '��������');
    Font.Color := cBROWN;
    TextOut(40*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 17*CharY, '���������');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ���� ������ ���� ������ �������� ��� }
procedure HeroCloseWeaponWindow;
var
  s1  : string;
  i   : byte;
begin
  pc.CreateClWList;
  s1 := Format('������ ������ �������� ���, � ������� %s ����������{��/���} ������ �����:', [PC.Name]);
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(s1,pc.gender));
    for i:=1 to CLOSEFIGHTAMOUNT-1 do
      if wlist[i] > 0 then
        if pc.closefight[wlist[i]] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(40*CharX, (14+i)*CharY, '[ ]');
          if pc.OneOfTheBestWPNCL(wlist[i]) then
            Font.Color := cWHITE else
              Font.Color := cGRAY;
          case wlist[i] of
            2 : TextOut(44*CharX, (14+i)*CharY, '���');
            3 : TextOut(44*CharX, (14+i)*CharY, '������');
            4 : TextOut(44*CharX, (14+i)*CharY, '�����');
            5 : TextOut(44*CharX, (14+i)*CharY, '�����');
            6 : TextOut(44*CharX, (14+i)*CharY, '���������� ���');
          end;
        end;
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ���� ������ ���� }
procedure HeroFarWeaponWindow;
var
  S1     : string;
  I      : byte;
begin
  pc.CreateFrWList;
  S1 := Format('����� ������ �������� ��� %s ��������{/a} �� ����� ����������?', [PC.Name]);
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(s1,pc.gender));
    for i:=1 to FARFIGHTAMOUNT do
      if wlist[i] > 0 then
        if pc.farfight[wlist[i]] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(40*CharX, (14+i)*CharY, '[ ]');
          if pc.OneOfTheBestWPNFR(wlist[i]) then
            Font.Color := cWHITE else
              Font.Color := cGRAY;
          case wlist[i] of
            2 : TextOut(44*CharX, (14+i)*CharY, '���');
            3 : TextOut(44*CharX, (14+i)*CharY, '�����');
            4 : TextOut(44*CharX, (14+i)*CharY, '������� ������');
            5 : TextOut(44*CharX, (14+i)*CharY, '�������');
          end;
      end;
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ����������� }
procedure HeroCreateResultWindow;
const
  s1 = 'ENTER - ���������, ESC - ������� ������';
var
  R, H, S : string;
begin
  StartDecorating('<-�������� ������ ���������->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    s := GetMsg('����, � ���� ���� �� '+pc.CLName(1)+' �� ����� '+PC.Name+'. ������{��/��}?', 0);
    TextOut(((WindowX-length(s)) div 2) * CharX, 13*CharY, s);
    Font.Color := cYELLOW;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
  end;
end;

{ ������� ����� ���� }
procedure ChooseModeWindow;
const
  s1 = '� ����� ������ ���� �� ������ ������?';
begin
  StartDecorating('<-����� ������ ����->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, '�����������');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, '����������');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ ������� ���� }
procedure DrawGameMenu;
const
  TableX = 39;
  TableW = 20;
  MenuNames : array[1..GMChooseAmount] of string = ('����� ����', '�����');
var
  i : byte;
begin
  DrawBorder(TableX, Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2, TableW,(GMChooseAmount+2)+1,crBLUEGREEN);
  with GScreen.Canvas do
  begin
    for i:=1 to GMChooseAmount do
    begin
      Font.Color := cBROWN;
      TextOut((TableX+2)*CharX, (Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2+(1+i))*CharY, '[ ]');
      Font.Color := cCYAN;
      TextOut((TableX+6)*CharX, (Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2+(1+i))*CharY, MenuNames[i]);
    end;
    Font.Color := cYELLOW;
    TextOut((TableX+3)*CharX, (Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2+(1+MenuSelected))*CharY, '*');
  end;
end;

end.
