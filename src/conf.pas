// ������������ Wander
unit conf;

interface

var
  // �������� �������
  FontMap: String = 'FixedSys'; 
  FontMsg: String = 'Courier New';
  FontSize: Byte = 0;
  // ������ �������
  CharX: Byte = 8;
  CharY: Byte = 16;
  // �������� �������� ������
  FlySpeed: Byte = 70;
  // �������� ������� ������� ��� �����
  UnderHitSpeed: Byte = 10;
  // ����
  Path: String;
  // ����� ����
  Mode: Byte = 0;
  // ������� �������� �� @
  ShowPCBar: Byte = 1;
  // ������. ������� �� ������ ������
  ShowBars: Byte = 1;
  // �����
  MoreKey: Byte = 0;
  // ��� ����� �� ���������
  YourName: String = '';

implementation

uses IniFiles, Cons;

var
  Ini: TINIFile;

initialization
  // ����
  GetDir(0, Path);
  Path := Path + '\';
  // ������ ��������� �� Wander.ini
  Ini:= TINIFile.Create(Path + 'wander.ini');
  try
    FontMap   := Ini.ReadString('FONT', 'NameMap', 'Courier New');
    FontMsg   := Ini.ReadString('FONT', 'NameMsg', 'Courier New');
    FontSize  := Ini.ReadInteger('FONT', 'Size', 0);
    Mode      := Ini.ReadInteger('GAME', 'Mode', AdventureMode);
    FlySpeed  := Ini.ReadInteger('GAME', 'FlySpeed', 70);
    UnderHitSpeed  := Ini.ReadInteger('GAME', 'UnderHitSpeed', 10);
    ShowPCBar := Ini.ReadInteger('GAME', 'ShowPCBar', 1);
    ShowBars  := Ini.ReadInteger('GAME', 'ShowBars', 1);
    MoreKey   := Ini.ReadInteger('GAME', 'MoreKey', 0);
    YourName  := Ini.ReadString('HERO', 'YourName', '');
  finally
    Ini.Free;
  end;

finalization

end.
