// String Utils
unit sutils;

interface

function StrRight(S: String; I: Integer): String; // Копия строки справа
function StrLeft(S: String; I: Integer): String;  // Копия строки слева
function GetStrKey(S, Key: String): String;       // Ключ из строки
function GetStrValue(S, Key: String): String;     // Знач. ключа из строки

implementation

{ Копия строки справа }
function StrRight(S: String; I: Integer): String;
var
  L: Integer;
begin
  L := Length(S);
  Result := Copy(S, L - I + 1, L);
end;

{ Копия строки слева }
function StrLeft(S: String; I: Integer): String;
begin
  Result := Copy(S, 1, I);
end;

{ Ключ из строки с разделителем }
function GetStrKey(S, Key: String): String;
begin
  Result := StrLeft(S, Pos(Key, S) - 1);
end;

{ Значение из строки с разделителем }
function GetStrValue(S, Key: String): String;
var
  L: Integer;
begin
  L := Length(S);
  Result := StrRight(S, L - Pos(Key, S));
end;

end.
