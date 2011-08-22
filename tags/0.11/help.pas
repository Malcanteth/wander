unit help;

interface

uses
  Utils, Cons;

procedure ShowHelp;                 // �������� ������ ������

implementation

uses
  Main;

{ �������� ������ ������ }
procedure ShowHelp;
begin
  StartDecorating('<-������->', FALSE);
  with Screen.Canvas do
  begin
    Font.Color := cCYAN;
    TextOut(3*CharX,3*CharY, '��� ������ - ������������ ������ �����, ��������� ������� ���������� � ����������� �������:');
    Font.Color := cLIGHTGRAY;
    TextOut(3*CharX,5*CharY,  'ESC    - ����� �� ����');
    TextOut(3*CharX,6*CharY,  'C      - ������� �����');
    TextOut(3*CharX,7*CharY,  'L      - ��������');
    TextOut(3*CharX,8*CharY,  'T      - �������������');
    TextOut(3*CharX,9*CharY,  'Q      - ������ �������');
    TextOut(3*CharX,10*CharY, 'E      - ����������');
    TextOut(3*CharX,11*CharY, 'I      - ���������');
    TextOut(3*CharX,12*CharY, 'A      - ��������� (������� ����� ��� ����� ������������ �������)');
    TextOut(3*CharX,13*CharY, 'ENTER  - ���������� ��� ��������� �� ��������');
    TextOut(3*CharX,14*CharY, 'G      - ������� ����');
    TextOut(3*CharX,15*CharY, 'S      - �����������');
    TextOut(3*CharX,16*CharY, 'O      - �������');
    TextOut(3*CharX,17*CharY, 'X      - �����������');

    TextOut(3*CharX,20*CharY, 'F1     - ������ (��� ���������)');
    TextOut(3*CharX,21*CharY, 'F2     - ��������� ���� � �����          {���� �� ��������}');
    TextOut(3*CharX,22*CharY, 'F5     - ������� ��������');

    Font.Color := cGRAY;
    TextOut(3*CharX,25*CharY, '������� �� ������������� � �������� � �����.');

    Font.Color := cLIGHTGRAY;
    TextOut(3*CharX,38*CharY, '���� ���������� ����� �������� aka BreakMeThunder');
    Font.Color := cGRAY;
    TextOut(3*CharX,39*CharY, 'breakmt@mail.ru');
  end;

end;

end.
