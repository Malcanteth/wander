  // ���������� ������� ������
  // ������ � ����
  case Rand(1, 3) of
    1: AddMsg('����� ������ � ����� ����.', 0);
    2: AddMsg('��������� � ��������� ����.', 0);
    3: AddMsg('��������� � �������� ����.', 0);
  end;
  case GetInt('PlayMode') of 
    AdventureMode: AddMsg('����� ���������� ������ ����������, ��, �������, ������{/a} � ��������� �������. ����� �����, ��� ����� �������� �������� ����. �� ������ ����������� � ����...', 0);// ��������� ������� - AdventureMode
    DungeonMode: AddMsg('������ ���������� ������� - �� ������ ����� ������ � ������, �������, �������� ��������, ������ � ���� ��������� �������� � ����������. �� ��������� ����� - �������, � ��� ������� ���� ����...', 0);// ���� � ���������� - DungeonMode
  end;

