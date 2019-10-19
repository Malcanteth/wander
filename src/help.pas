unit help;

interface

uses
  Utils, Cons, Msg;

procedure ShowHelp; // �������� ������ ������
procedure ShowHistory; // �������� ������� ���������

implementation

uses
  Main, SysUtils, conf;

{ �������� ������ ������ }
procedure ShowHelp;
var
  Y: Byte;

  procedure Add(S: string);
  begin
    AddTextLine(3, Y, S);
    Inc(Y);
  end;

begin
  Y := 2;
  StartDecorating('<-������->', FALSE);
  Add('��� ������ - ������������ ������ �����, ��������� ������� ���������� � ����������� �������:');
  Add('$ESC$   - ����� �� ���� � ����                     $S$     - ��������');
  Add('$C$     - ������� �����                            $O$     - �������');
  Add('$L$     - ��������                                 $X$     - ������ � �����������');
  Add('$T$     - �������������                            $M$     - ������� ���������');
  Add('$Q$     - ������ �������                           $TAB$   - �������� ������� ���');
  Add('$E$     - ����������                               $F$     - ����');
  Add('$I$     - ���������                                $D$     - ����');
  Add('$A$     - ���������                                $SPACE$ - �����\����� (*� ����*)');
  Add('$ENTER$ - ����������\��������� �� ��������');
  Add('$G$     - ������� ������� ($Shift + G$ - ����� ������������ ����������)');
  Inc(Y, 4);

  Add('� ������� ������ *�������� ����������* ����� ��������� �� ���� ������������ (����� $5$ - �����).');
  Add('������������� �� ��������� ��� �� ����� ����� *ALT + �������*.');
  Inc(Y, 3);

  Add('����� ����������� ��� �������������� �������:');
  Add('#F1#    - ������ (*��� ���������*)');
  Add('*F2*    - ��������� ���� � ����� {*���� �� ��������*}');
  Add('#F5#    - ������� ��������');
  Add('#F9#    - �������� ������ ���������� � �����');
  Inc(Y, 4);

  Add('������� �� ������������� � �������� � �����.');
  Inc(Y, 6);

  Add('���� ���������� ����� �������� aka BreakMeThunder *breakmt@mail.ru*');
  Add('�������������: ������-���, Apromix *bees@meta.ua*');
end;

{ �������� ������� ��������� }
procedure ShowHistory;
var
  x, Y, c, t: Byte;
begin
  StartDecorating('<-������� ��������� ���������->', FALSE);
  with GScreen.Canvas do
  begin
    Brush.Color := 0;
    for Y := 1 to MaxHistory do
      if History[Y].Msg <> '' then
      begin
        c := 0;
        t := 1;
        for x := 1 to Length(History[Y].Msg) do
        begin
          // ������� ������ � ����� �����
          if History[Y].Msg[x] = '$' then // ������
          begin
            if c = 0 then
              c := 1
            else
              c := 0;
          end
          else if History[Y].Msg[x] = '*' then // �������
          begin
            if c = 0 then
              c := 2
            else
              c := 0;
          end
          else if History[Y].Msg[x] = '#' then // �������
          begin
            if c = 0 then
              c := 3
            else
              c := 0;
          end
          else
          begin
            // ���� ����
            case c of
              0:
                Font.Color := MyRGB(160, 160, 160); // �����
              1:
                Font.Color := MyRGB(255, 255, 0); // ������
              2:
                Font.Color := MyRGB(200, 0, 0); // �������
              3:
                Font.Color := MyRGB(0, 200, 0); // �������
            end;
            Textout((t - 1) * CharX, (2 * CharY) + ((Y - 1) * CharY), History[Y].Msg[x]);
            Inc(t);
          end;
        end;
        if History[Y].amount > 1 then
        begin
          Font.Color := MyRGB(200, 255, 255);
          Textout((Length(History[Y].Msg) + 1) * CharX, (2 * CharY) + ((Y - 1) * CharY), IntToStr(History[Y].amount) + ' ����.');
        end;
      end;
  end;
end;

end.
