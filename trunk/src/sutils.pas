// String Utils
unit sutils;

interface

function StrRight(S: String; I: Integer): String; // ����� ������ ������
function StrLeft(S: String; I: Integer): String;  // ����� ������ �����
function GetStrKey(S, Key: String): String;       // ���� �� ������
function GetStrValue(S, Key: String): String;     // ����. ����� �� ������

implementation

{ ����� ������ ������ }
function StrRight(S: String; I: Integer): String;
var
  L: Integer;
begin
  L := Length(S);
  Result := Copy(S, L - I + 1, L);
end;

{ ����� ������ ����� }
function StrLeft(S: String; I: Integer): String;
begin
  Result := Copy(S, 1, I);
end;

{ ���� �� ������ � ������������ }
function GetStrKey(S, Key: String): String;
begin
  Result := StrLeft(S, Pos(Key, S) - 1);
end;

{ �������� �� ������ � ������������ }
function GetStrValue(S, Key: String): String;
var
  L: Integer;
begin
  L := Length(S);
  Result := StrRight(S, L - Pos(Key, S));
end;

end.
