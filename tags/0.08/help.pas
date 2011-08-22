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
  StartDecorating('<-������->');
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
    TextOut(3*CharX,11*CharY, 'A      - ��������� (������� ����� ��� ����� ������������ �������)');
    TextOut(3*CharX,12*CharY, 'ENTER  - ���������� ��� ��������� �� ��������');
    TextOut(3*CharX,13*CharY, 'G      - ������� ����');
    TextOut(3*CharX,14*CharY, '?      - ������ (��� ���������)');
    Font.Color := cGRAY;
    TextOut(3*CharX,16*CharY, '������� �� ������������� � �������� � �����.');
    Font.Color := cGREEN;
    TextOut(3*CharX,35*CharY, Version);
  end;
end;

end.
