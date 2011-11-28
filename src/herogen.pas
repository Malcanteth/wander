unit herogen;

interface

function ChooseMode: boolean;       // ������� ����� ����
function HeroRandom: boolean;       // ������� ����������
function HeroGender: boolean;       // ���� ������ ����
function HeroName: boolean;         // ���� ����� �����
function HeroAtributes: boolean;    // ����������� �����������
function HeroCloseWeapon: boolean;  // ������ �������� ���
function HeroFarWeapon: boolean;    // ������ �������� ���
function HeroCreateResult: boolean; // �����������

implementation
uses main, utils, graphics, cons, conf, player, ability, mapeditor, mbox,
     msg, sysutils, script, vars, map;

{ ������� ����� ���� }
function ChooseMode: boolean;
const s1 = '� ����� ������ ���� �� ������ ������?';
var j: byte;
begin
  Result := false;
  repeat
    MainForm.Cls;
    GameMenu := true;
    StartDecorating('<-����� ������ ����->', TRUE);
    MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, s1);
    with TMenu.Create(40,15) do
    begin
      Add('�����������');
      Add('����������');
      j := Run();
      Free;
    end;
    if j = 0 then exit;
    GameMenu := false;
    PlayMode := j;
    // ���� ����� ����������� �� ����� ��������� �����
    if PlayMode = AdventureMode then
      if not MainEdForm.LoadSpecialMaps then
      begin
        MsgBox('������ �������� ����!');
        Halt;
      end;
      //��������� �����?
      if HeroRandom then break;
  until false;
  Result := true;
end;

{ ������� ���������� }
function HeroRandom: boolean;
const s1 = '������� �������� ��� ��� ���������� ���� ������?';
var j: byte;
begin
  Result := false;
  repeat
    pc.ClearPlayer;
    MainForm.Cls;
    GameMenu := true;
    StartDecorating('<-�������� ������ ���������->', TRUE);
    MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, s1);
    with TMenu.Create(40,15) do
    begin
      Add('������ ���');
      Add('��������� �����');
      j := Run();
      Free;
    end;
    if j = 0 then exit; //������� � ���������� ����
    GameMenu := false;
    if j = 1 then
      if HeroGender then break else continue
    else
    // �� ��������
    begin
      // ���
      pc.gender := Rand(1, 2);
      // ���
      case pc.gender of
        genMALE   : pc.name := GenerateName(FALSE);
        genFEMALE : pc.name := GenerateName(TRUE);
      end;
      // ��������
      pc.atr[1] := Rand(1, 3);
      pc.atr[2] := Rand(1, 3);
      // �������� ���� ������ ������ �� ������
      pc.Prepare;
      pc.PrepareSkills;
      if (pc.HowManyBestWPNCL > 1) and not ((pc.HowManyBestWPNCL < 3) and (pc.OneOfTheBestWPNCL(CLOSE_TWO))) then
      begin
        pc.CreateClWList;
        c_choose := Wlist[Random(wlistsize)+1];
      end;
      if (pc.HowManyBestWPNFR > 1) and not ((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW))) then
      begin
        pc.CreateFrWList;
        f_choose := Wlist[Random(wlistsize)+1];
      end;
      if HeroCreateResult then break;
    end;
  until false;
  Result := true;
end;

{ ���� ������ ���� }
function HeroGender: boolean;
const s1 = '������ ���� ����� ���� ��������?';
var j: byte;
begin
  Result := false;
  repeat
    MainForm.Cls;
    GameMenu := true;
    StartDecorating('<-�������� ������ ���������->', TRUE);
    MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, s1);
    with TMenu.Create(40,15) do
    begin
      Add('��������');
      Add('��������');
      Add('��� �������');
      j := Run();
      Free;
    end;
    if j = 0 then exit;
    GameMenu := false;
    if j < 3 then pc.gender := j else pc.gender := Rand(1, 2);
    if HeroName then break;
  until false;
  Result := true;
end;

{ ���� ����� ����� }
function HeroName: boolean;
const s2 = '^^^^^^^^^^^^^';
var
  n : string[13];
  s1: string;
  b: boolean;
begin
  Result := false;
  repeat
    MainForm.Cls;
    StartDecorating('<-�������� ������ ���������->', TRUE);
    s1 := GetMsg('����� ��� ����{�/���}{:',pc.gender);
    MainForm.DrawString(((WindowX-length(s1)) div 2) , 15, cWHITE, s1);
    MainForm.DrawString(((WindowX-length(s2)) div 2) , 18, cBROWN, s2);
    s1 := Input(((WindowX-13) div 2), 17, '', b, 13);
    if not(b) then exit;
    if s1 = '' then
      case pc.gender of
        genMALE   : pc.name := GenerateName(FALSE);
        genFEMALE : pc.name := GenerateName(TRUE);
      end
    else
      pc.name := s1;
    if HeroAtributes then break;
  until false;
  Result := true;
end;

{ ����������� ����������� }
function HeroAtributes: boolean;
var s1, s2 : string;
    i,j: byte;
    b: boolean;
begin
  Result := false;
  s1 := Format('������ �������, � ������� %s ������ ����� ��������{/a}:', [pc.name]); //'������ �������, � ������� '+pc.name+' ������ ����� ��������{/a}:';
  s2 := Format('� ������ ������ �������, �������� %s ���� ������{/a} ��������:', [pc.name]); //'� ������ ������ �������, �������� '+pc.name+' ���� ������{/a} ��������:';
  i := 1;
  repeat
    while i <=2 do
    begin
      MainForm.Cls;
      StartDecorating('<-�������� ������ ���������->', TRUE);
      case i of
        1 : MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, GetMsg(S1,pc.gender));
        2 : MainForm.DrawString(((WindowX-length(s2)) div 2) , 13, cWHITE, GetMsg(S2,pc.gender));
      end;
      GameMenu := True;
      with TMenu.Create(40,15) do
      begin
        Add('����');
        Add('��������');
        Add('���������');
        j := Run();
        if j = 0 then dec(i);
        Free;
      end;
      GameMenu := False;
      if i = 0 then exit;
      if j <> 0 then begin pc.atr[i] := j; inc(i); end;
    end;
    // �������� ���� ������ ������ �� ������
    pc.Prepare;
    pc.PrepareSkills;
    j := 1;
    repeat
      b := true;
      case j of
        0: begin b := false; dec(i); break; end;
        1: if (pc.HowManyBestWPNCL > 1) and not ((pc.HowManyBestWPNCL < 3) and (pc.OneOfTheBestWPNCL(CLOSE_TWO))) then
           begin
             b:=HeroCloseWeapon;
             if not(b) then begin dec(j); continue; end;
             inc(j);
           end else inc(j);
        2: if (pc.HowManyBestWPNFR > 1) and not ((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW))) then
           begin
             b := HeroFarWeapon;
            if not(b) then begin dec(j); continue; end;
            inc(j);
          end else inc(j);
        3: if HeroCreateResult then break else inc(j);
      end;
    until j=4;
  until b;
  Result := true;
end;

{ ���� ������ ���� ������ �������� ��� }
function HeroCloseWeapon: boolean;
var
  s1  : string;
  j   : byte;
  c   : LongInt;
  b   : boolean;
begin
  Result := false;
  pc.CreateClWList;
  MainForm.Cls;
  StartDecorating('<-�������� ������ ���������->', TRUE);
  s1 := Format('������ ������ �������� ���, � ������� %s ����������{��/���} ������ �����:', [PC.Name]);
  GameMenu := true;
  MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, GetMsg(s1,pc.gender));
  with TMenu.Create(40,15) do
  begin
    for j:=1 to CLOSEFIGHTAMOUNT-1 do
      if wlist[j] > 0 then
        if pc.closefight[wlist[j]] > 0 then
        begin
          if pc.OneOfTheBestWPNCL(wlist[j]) then c := cWHITE else c := cGRAY;
          case wlist[j] of
            2: Add('���',c);
            3: Add('������',c);
            4: Add('�����',c);
            5: Add('�����',c);
            6: Add('���������� ���',c);
          end;
        end;
    j := Run();
    Free;
  end;
  GameMenu := false;
  if j = 0 then exit;
  Result := true;
  c_choose := Wlist[j];
end;

{ ���� ������ ���� }
function HeroFarWeapon: boolean;
var
  S1     : string;
  j      : byte;
  c      : LongInt;
begin
  Result := false;
  pc.CreateFrWList;
  MainForm.Cls;
  S1 := Format('����� ������ �������� ��� %s ��������{/a} �� ����� ����������?', [PC.Name]);
  StartDecorating('<-�������� ������ ���������->', TRUE);
  GameMenu := true;
  MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, GetMsg(s1,pc.gender));
  with TMenu.Create(40,15) do
  begin
    for j:=1 to FARFIGHTAMOUNT do
      if wlist[j] > 0 then
        if pc.farfight[wlist[j]] > 0 then
        begin
          if pc.OneOfTheBestWPNFR(wlist[j]) then c := cWHITE else c := cGRAY;
          case wlist[j] of
            2 : Add('���',c);
            3 : Add('�����',c);
            4 : Add('������� ������',c);
            5 : Add('�������',c);
          end;
       end;
    j := Run();
    Free;
  end;
  GameMenu := false;
  if j = 0 then exit;
  Result := true;
  f_choose := Wlist[j];
end;

{ ����������� }
function HeroCreateResult: boolean;
const
  s1 = 'ENTER - ���������, ESC - ������� ������';
var
  R, H, S : string;
  Key : Word;
begin
  Result := false;
  GameMenu := true;
  MainForm.Cls;
  StartDecorating('<-�������� ������ ���������->', TRUE);
  Script.Run('CreatePC.pas');
  S := Format(V.GetStr('CreatePCStr'), [pc.CLName(1), PC.Name]);
  MainForm.DrawString(((WindowX-length(s)) div 2) , 13, cWHITE, GetMsg(S,pc.gender));
  MainForm.DrawString(((WindowX-length(s1)) div 2) , 15, cYELLOW, s1);
  MainForm.Redraw;
  repeat
    Key := getKey;
  until Key in [13, 27];
  GameMenu := false;  
  if Key = 27 then exit;
  Result := true;
  pc.FavWPNSkill;
end;

end.
