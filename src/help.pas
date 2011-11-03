unit help;

interface

uses
  Utils, Cons, Msg;

procedure ShowHelp;                 // �������� ������ ������
procedure ShowHistory;              // �������� ������� ���������

implementation

uses
  Main, SysUtils, conf;

{ �������� ������ ������ }
procedure ShowHelp;
begin
  StartDecorating('<-������->', FALSE);
  with Screen.Canvas do
  begin
    Font.Color := cBLUEGREEN;
    TextOut(3*CharX,3*CharY, '��� ������ - ������������ ������ �����, ��������� ������� ���������� � ����������� �������:');
    Font.Color := cLIGHTGRAY;
    TextOut(3*CharX,5*CharY,  'ESC    - ����� �� ����');
    TextOut(3*CharX,6*CharY,  'C      - ������� �����');
    TextOut(3*CharX,7*CharY,  'L      - ��������');
    TextOut(3*CharX,8*CharY,  'T      - �������������');
    TextOut(3*CharX,9*CharY,  'Q      - ������ �������');
    TextOut(3*CharX,10*CharY, 'E      - ����������');
    TextOut(3*CharX,11*CharY, 'I      - ���������');
    TextOut(3*CharX,12*CharY, 'A      - ���������');
    TextOut(3*CharX,13*CharY, 'ENTER  - ����������\��������� �� ��������');
    TextOut(3*CharX,14*CharY, 'G      - ������� ���� (Shift + G - ������� ������������ ����������)');
    TextOut(3*CharX,15*CharY, 'S      - ��������');
    TextOut(3*CharX,16*CharY, 'O      - �������');
    TextOut(3*CharX,17*CharY, 'X      - ������ � �����������');
    TextOut(3*CharX,18*CharY, 'M      - ������� ���������');
    TextOut(3*CharX,19*CharY, 'TAB    - �������� ������� ���');
    TextOut(3*CharX,20*CharY, 'F      - ����');
    TextOut(3*CharX,21*CharY, 'D      - ����');

    Font.Color := cPURPLE;
    TextOut(3*CharX,24*CharY, 'F1     - ������ (��� ���������)');
    TextOut(3*CharX,25*CharY, 'F2     - ��������� ���� � �����          {���� �� ��������}');
    TextOut(3*CharX,26*CharY, 'F5     - ������� ��������');

    Font.Color := cGRAY;
    TextOut(3*CharX,28*CharY, '������� �� ������������� � �������� � �����.');
    TextOut(3*CharX,29*CharY, '��������� �� ��������� ��� �� ����� ����� ALT + �������.');
    Font.Color := cLIGHTGRAY;
    TextOut(3*CharX,38*CharY, '���� ���������� ����� �������� aka BreakMeThunder');
    Font.Color := cGRAY;
    TextOut(3*CharX,39*CharY, 'breakmt@mail.ru');
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
