unit cons;

interface

const
  { ����� ��������� ���� }
  Version                  = '0.12';
  MapEditorVersion         = '0.6';

  { ���������  ���� }
  FontName                 = 'FixedSys';
  WindowX                  = 100;
  WindowY                  = 42;

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
  MaxDoors  = 3;

  MaxLadders = 4;          // ������������ ���-�� ������� ���� �� �������
  MaxDepth  = 10;          // ������������ ������� ����������

  TipsAmount = 5;

  tipRooms = 1;            // ���������� ������� (��� ������ #2)
  tipDestr = 2;            // ����������� (��� ������ #1)
  tipRuins = 3;            // �����
  tipRulab = 4;            // ����������� ��������
  tipDRoom = 5;            // ����������� �������

  { ��������� }
  MsgAmount                = 7;
  MsgLength                = WindowX;
  MaxHistory               = 38;

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
  cORANGE                  = 212675;

  { ���������� ���� }
  gsPLAY                   = 1;
  gsCLOSE                  = 2;
  gsLOOK                   = 3;
  gsCHOOSEMONSTER          = 4;
  gsQUESTLIST              = 5;
  gsEQUIPMENT              = 6;
  gsINVENTORY              = 7;
  gsHELP                   = 8;
  gsUSEMENU                = 9;
  gsHERONAME               = 10;
  gsHEROGENDER             = 11;
  gsOPEN                   = 12;
  gsABILITYS               = 13;
  gsHISTORY                = 14;

  { ������� �����}
  stHUNGRY                 = 1;
  stDRUNK                  = 2;

  { ��� }
  genMIDLE                 = 0;
  genMALE                  = 1;
  genFEMALE                = 2;

  { ������ }
  QuestsAmount             = 3;       // 1-���������,2-����,3-�������

  { ����� }
  MaxHandle                = 27;      // ������������ ���������� ���������
  EqAmount                 = 12;      // ����������� ����� � ����������

  { ������� �������� � ������ ������������� �������� }
  HOWMANYVARIANTS          = 5;       //1-������������,2-����������� ��������������,3-�������,4-������,5-��������
  
implementation

end.
