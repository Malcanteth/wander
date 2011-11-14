unit help;

interface

uses
  Utils, Cons, Msg;

procedure ShowHelp;                 // �������� ������ ������
procedure ShowHistory;              // �������� ������� ���������
procedure DrawGameMenu;             // ������� ����

const
  GMChooseAmount = 2;
  gmNEWGAME      = 1;
  gmEXIT         = 2;

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
    TextOut(3*CharX,5*CharY,  'ESC   - ����� �� ����                             S     - ��������');
    TextOut(3*CharX,6*CharY,  'C     - ������� �����                             O     - �������');
    TextOut(3*CharX,7*CharY,  'L     - ��������                                  X     - ������ � �����������');
    TextOut(3*CharX,8*CharY,  'T     - �������������                             M     - ������� ���������');
    TextOut(3*CharX,9*CharY,  'Q     - ������ �������                            TAB   - �������� ������� ���');
    TextOut(3*CharX,10*CharY, 'E     - ����������                                F     - ����');
    TextOut(3*CharX,11*CharY, 'I     - ���������                                 D     - ����');
    TextOut(3*CharX,12*CharY, 'A     - ���������');
    TextOut(3*CharX,13*CharY, 'ENTER - ����������\��������� �� ��������');
    TextOut(3*CharX,14*CharY, 'G     - ������� ���� (Shift + G - ������������ ����������)');

    Font.Color := cPURPLE;
    TextOut(3*CharX,20*CharY, 'F1    - ������ (��� ���������)');
    TextOut(3*CharX,21*CharY, 'F2    - ��������� ���� � ����� {���� �� ��������}');
    TextOut(3*CharX,22*CharY, 'F5    - ������� ��������');
    TextOut(3*CharX,23*CharY, 'F6    - ��������\�������� ������� ����');

    Font.Color := cGRAY;
    TextOut(3*CharX,30*CharY, '������� �� ������������� � �������� � �����.');
    TextOut(3*CharX,31*CharY, '��������� �� ��������� ��� �� ����� ����� ALT + �������.');
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

{ ������� ���� }
procedure DrawGameMenu;
const
  TableX = 39;
  TableW = 20;
  MenuNames : array[1..GMChooseAmount] of string =
  ('����� ����', '�����');
var
  i : byte;
begin
  DrawBorder(TableX, Round(WindowY/2)-Round((GMChooseAmount+2)/2)-1, TableW,(GMChooseAmount+2)+1,crBLUEGREEN);
  with Screen.Canvas do
  begin
    for i:=1 to GMChooseAmount do
    begin
      Font.Color := cBROWN;
      TextOut((TableX+2)*CharX, (Round(WindowY/2)-Round((GMChooseAmount+2)/2)-1+(1+i))*CharY, '[ ]');
      Font.Color := cCYAN;
      TextOut((TableX+6)*CharX, (Round(WindowY/2)-Round((GMChooseAmount+2)/2)-1+(1+i))*CharY, MenuNames[i]);
    end;
    Font.Color := cYELLOW;
    TextOut((TableX+3)*CharX, (Round(WindowY/2)-Round((GMChooseAmount+2)/2)-1+(1+MenuSelected))*CharY, '*');
  end;
end;

end.
