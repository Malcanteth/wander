// String Utils
unit sutils;

interface

type
  TExplodeResult = array of string;               // ��� ��� ���������� ������ �� ���������

function StrLeft(S: String; I: Integer): String;  // ����� ������ �����
function StrRight(S: String; I: Integer): String; // ����� ������ ������
function GetStrKey(Key, S: String): String;       // ���� �� ������
function GetStrValue(Key, S: String): String;     // ����. ����� �� ������
function Explode(const cSeparator, vString: String): TExplodeResult; // ������� ������ �� ������ �����

implementation

{ ����� ������ ����� }
function StrLeft(S: String; I: Integer): String;
begin
  Result := Copy(S, 1, I);
end;

{ ����� ������ ������ }
function StrRight(S: String; I: Integer): String;
begin
  Result := Copy(S, Length(S) - I + 1, Length(S));
end;

{ ���� �� ������ � ������������ }
function GetStrKey(Key, S: String): String;
begin
  Result := Copy(S, 1, Pos(Key, S) - 1);
end;

{ �������� �� ������ � ������������ }
function GetStrValue(Key, S: String): String;
begin
  Result :=Copy(S, Pos(Key, S) + 1, Length(S));
end;

{ ������� ������ �� ������ ����� }
function Explode(const cSeparator, vString: String): TExplodeResult;
var
  I: Integer;
  S: String;
begin
  S := vString;
  SetLength(Result, 0);
  I := 0;
  while Pos(cSeparator, S) > 0 do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[I] := Copy(S, 1, Pos(cSeparator, S) - 1);
    Inc(I);
    S := Copy(S, Pos(cSeparator, S) + Length(cSeparator), Length(S));
  end;
  SetLength(Result, Length(Result) + 1);
  Result[I] := Copy(S, 1, Length(S));
end;
end.

