// String Utils
unit sutils;

interface

type
  TExplodeResult = array of string;               // Тип для разбивания строки на фрагменты

function StrLeft(S: String; I: Integer): String;  // Копия строки слева
function StrRight(S: String; I: Integer): String; // Копия строки справа
function GetStrKey(Key, S: String): String;       // Ключ из строки
function GetStrValue(Key, S: String): String;     // Знач. ключа из строки
function Explode(const cSeparator, vString: String): TExplodeResult; // Разбить строку на массив строк

implementation

{ Копия строки слева }
function StrLeft(S: String; I: Integer): String;
begin
  Result := Copy(S, 1, I);
end;

{ Копия строки справа }
function StrRight(S: String; I: Integer): String;
begin
  Result := Copy(S, Length(S) - I + 1, Length(S));
end;

{ Ключ из строки с разделителем }
function GetStrKey(Key, S: String): String;
begin
  Result := Copy(S, 1, Pos(Key, S) - 1);
end;

{ Значение из строки с разделителем }
function GetStrValue(Key, S: String): String;
begin
  Result :=Copy(S, Pos(Key, S) + 1, Length(S));
end;

{ Разбить строку на массив строк }
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

