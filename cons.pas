unit cons;

interface

const
  { ����� ��������� ���� }
  Version                  = '������ 0.08';

  { ���������  ���� }
  FontName                 = 'FixedSys';
  WindowX                  = 100;
  WindowY                  = 40;

  { ��������� ����� }
  CharX                    = 8;
  CharY                    = 16;
  MapX                     = 80;
  MapY                     = 35;

  { ��������� ��� ��������� ���������� }
  MinRooms = 7;
  MaxRooms = 15;
  MinHeight = 3;
  MaxHeight = 10;
  MinWidth  = 6;
  MaxWidth  = 10;
  MaxDoors = 3;

  TipsAmount = 5;

  tipRooms = 1;            // ���������� ������� (��� ������ #2)
  tipDestr = 2;            // ����������� (��� ������ #1)
  tipRuins = 3;            // �����
  tipRulab = 4;            // ����������� ��������
  tipDRoom = 5;            // ����������� �������

  { ��������� }
  MsgAmount                = 5;
  MsgLength                = WindowX;

  { ��������� �������� ������ }
  cRANDOM                  = 1;
  cBLACK                   = 0;
  cBLUE                    = 9830400;
  cGREEN                   = 38400;
  cRED                     = 150;
  cCYAN                    = 14150430;
  cPURPLE                  = 5374116;
  cBROWN                   = 16512;
  cWHITE                   = 16777215;
  cGRAY                    = 8421504;
  cYELLOW                  = 65535;
  cLIGHTGRAY               = 14474460;
  cLIGHTRED                = 255;
  cLIGHTGREEN              = 65280;
  cLIGHTBLUE               = 16711680;

  { ���������� ���� }
  gsPLAY                   = 1;
  gsCLOSE                  = 2;
  gsLOOK                   = 3;
  gsTALK                   = 4;
  gsQUESTLIST              = 5;
  gsEQUIPMENT              = 6;
  gsINVENTORY              = 7;
  gsHELP                   = 8;
  gsATACK                  = 9;
  gsUSEMENU                = 10;

  { ������� �����}
  stHUNGRY                 = 1; 

  { ��� }
  genMIDLE                 = 0;
  genMALE                  = 1;
  genFEMALE                = 2;

  { ������ }
  QuestsAmount             = 1;

  { ����� }
  MaxHandle                = 25;      // ������������ ���������� ���������
  EqAmount                 = 12;      // ����������� ����� � ����������

  { ������� �������� � ������ ������������� �������� }
  HOWMANYVARIANTS          = 5;       //1-������������,2-����������� ��������������,3-�������,4-������,5-��������
implementation

end.
