unit flags;

interface

const
  { ��� ������ }
  NOF                = 0;

  { ������ ��� �������� (����� 64) }
  // �����������
  M_OPEN             = 1 shl 0;     // ����� ��������� �����
  M_FREEZE           = 1 shl 1;     // �� ���������
  M_NEUTRAL          = 1 shl 2;     // ������ ��������� � �����
  M_NAME             = 1 shl 3;     // ���� ���
  M_STAY             = 1 shl 4;     // ����� �� ����� ���� ������ �����
  M_ALWAYSANSWERED   = 1 shl 5;     // ������ �������� �� �����
  M_DRUNK            = 1 shl 6;     // ������
  M_HAVEITEMS        = 1 shl 7;     // ����� ������� ����
  M_TACTIC           = 1 shl 8;     // ����� ��������� �������
  M_CLASS            = 1 shl 9;     // ���������� ����� ��� �������


  { ������ ��� ��������� }
  I_TWOHANDED        = 1 shl 0;     // ��������� ������

  { ������ ��� �������� }
  L_NOSATURATION    =  1 shl 0;     // ������� �� ��������
  L_WSATURATION     =  1 shl 1;     // ������� �������� �������
  L_RANDOMPOWER     =  1 shl 2;     // ��������� �������� ������� �������
  L_LITTLEHEAL      =  1 shl 3;     // ����-���� ����� ��� ������������
  L_WMASS           =  1 shl 4;     // ������� ����� �������

implementation

end.
