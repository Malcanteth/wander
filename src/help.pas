unit help;

interface

uses
  Utils, Cons, Msg;

procedure ShowHelp;                 // �������� ������ ������
procedure ShowHistory;              // �������� ������� ���������

const
  GMChooseAmount = 2;
  gmNEWGAME      = 1;
  gmEXIT         = 2;

implementation

uses
  Main, SysUtils, conf, wlog, mbox, player, herogen;

{ �������� ������ ������ }
procedure ShowHelp;
begin
  Mainform.Cls;
  GameMenu := true;
  StartDecorating('<-������->', FALSE);
  AddTextLine(3, 2, '��� ������ - ������������ ������ ����� ��������� ���������� � ����������� �������:');

  AddTextLine(3, 5,  '$ESC$   - ����� �� ���� � ����                      $S$     - ��������');
  AddTextLine(3, 6,  '$C$     - ������� �����                             $O$     - �������');
  AddTextLine(3, 7,  '$L$     - ��������                                  $X$     - ������ � �����������');
  AddTextLine(3, 8,  '$T$     - �������������                             $M$     - ������� ���������');
  AddTextLine(3, 9,  '$Q$     - ������ �������                            $TAB$   - �������� ������� ���');
  AddTextLine(3, 10, '$E$     - ����������                                $F$     - ����');
  AddTextLine(3, 11, '$I$     - ���������                                 $D$     - ����');
  AddTextLine(3, 12, '$A$     - ���������');
  AddTextLine(3, 13, '$ENTER$ - ����������\��������� �� ��������');
  AddTextLine(3, 14, '$G$     - ������� ���� ($Shift + G$ - ������������ ����������)');

  AddTextLine(3, 20, '#F1#    - ������ (��� ���������)');
  AddTextLine(3, 21, '#F2#    - ��������� ���� � ����� {���� �� ��������}');
  AddTextLine(3, 22, '#F5#    - ������� ��������');

  if Debug then AddTextLine(3, 26, '#~#     - �������\�������� �������');

  AddTextLine(3, 39, '������� �� ������������� � �������� � �����.');
  AddTextLine(3, 30, '��������� �� ��������� ��� �� ����� ����� *ALT + �������*.');

  AddTextLine(3, 39, '���� ���������� ����� �������� aka BreakMeThunder *breakmt@mail.ru*');

  Mainform.Redraw;
  repeat until getKey in [13,27,32];
  GameMenu := false;
end;

{ �������� ������� ��������� }
procedure ShowHistory;
var
  x,y,c,t : byte;
  col: LongInt;
begin
  Mainform.Cls;
  GameMenu := true;
  StartDecorating('<-������� ��������� ���������->', FALSE);
  for y:=1 to MaxHistory do
    if History[y].Msg <> '' then
    begin
      c := 0;
      t := 1;
      for x:=1 to Length(History[y].msg) do
      begin
        //������� ������ � ����� �����
        if History[y].msg[x] = '$' then  // ������
        begin
          if c = 0 then c := 1 else c := 0;
        end else
        if History[y].msg[x] = '*' then  // �������
        begin
          if c= 0 then c := 2 else c := 0;
        end else
        if History[y].msg[x] = '#' then  // �������
        begin
          if c= 0 then c := 3 else c := 0;
        end else
          begin
            //���� ����
            case c of
              0 : col := MyRGB(160,160,160);  //�����
              1 : col := MyRGB(255,255,0);    //������
              2 : col := MyRGB(200,0,0);      //�������
              3 : col := MyRGB(0,200,0);      //�������
            end;
            MainForm.DrawString((t-1), (2)+((y-1)), col, History[y].msg[x]);
            inc(t);
          end;
      end;
      if History[y].amount > 1 then
        MainForm.DrawString((Length(History[y].msg)+1), (2)+((y-1)), MyRGB(200,255,255), IntToStr(History[y].amount)+' ����.');
    end;
  Mainform.Redraw;
  repeat until getKey in [13,27,32];
  GameMenu := false;
end;

end.
