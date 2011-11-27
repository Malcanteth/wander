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
  StartDecorating('<-������->', FALSE);
  with Screen.Canvas do
  begin
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
  end;
end;

{ �������� ������� ��������� }
procedure ShowHistory;
var
  x,y,c,t : byte;
begin
  StartDecorating('<-������� ��������� ���������->', FALSE);
  with Screen.Canvas do
  begin
    Brush.Color := 0;
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
                0 : Font.Color := MyRGB(160,160,160);  //�����
                1 : Font.Color := MyRGB(255,255,0);    //������
                2 : Font.Color := MyRGB(200,0,0);      //�������
                3 : Font.Color := MyRGB(0,200,0);      //�������
              end;
              Textout((t-1)*CharX, (2*CharY)+((y-1)*CharY), History[y].msg[x]);
              inc(t);
            end;
        end;
        if History[y].amount > 1 then
        begin
          Font.Color := MyRGB(200,255,255);
          Textout((Length(History[y].msg)+1)*CharX, (2*CharY)+((y-1)*CharY), IntToStr(History[y].amount)+' ����.');
        end;
      end;
  end;
end;

end.
