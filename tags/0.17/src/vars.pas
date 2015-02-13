unit Vars;

interface

uses Classes;

type
  TVars = class
    FID: TStringList;
    FValue: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ClearGameVars;
    function Count: Integer;
    procedure EmptyVar(const AVar: String);
    function IsVar(const AVar: String): Boolean;
    function GetStr(const AVar: String): String;
    procedure SetStr(const AVar, AValue: String);
    function GetInt(const AVar: String): Integer;
    procedure SetInt(const AVar: String; const AValue: Integer);
    function GetBool(const AVar: String): Boolean;
    procedure SetBool(const AVar: String; const AValue: Boolean);
    procedure SaveToFile(const AFileName: String);
    procedure LoadFromFile(const AFileName: String);
    procedure Inc(const VarName: String; Count: Integer = 1);
    procedure Dec(const VarName: String; Count: Integer = 1);
    procedure Let(Var1, Var2: String);
  end;

var
  V: TVars;

implementation

uses SysUtils;

{ TVars }

procedure TVars.Clear;
begin
  FID.Clear;
  FValue.Clear;
end;

constructor TVars.Create;
begin
  FID := TStringList.Create;
  FValue := TStringList.Create;
  Self.Clear;
end;

destructor TVars.Destroy;
begin
  FID.Free;
  FValue.Free;
end;

function TVars.GetStr(const AVar: String): String;
var
  I: Integer;
begin
  I := FID.IndexOf(AVar);
  if I < 0 then Result := '' else Result := FValue[I];
end;

procedure TVars.SetStr(const AVar, AValue: String);
var
  I: Integer;
begin
  I := FID.IndexOf(AVar);
  if I < 0 then
  begin
    FID.Append(AVar);
    FValue.Append(AValue);
  end else FValue[I] := AValue;
end;

function TVars.GetInt(const AVar: String): Integer;
var
  S: string;
begin
  S := Trim(GetStr(AVar));
  if S = '' then Result := 0 else Result := StrToInt(S);
end;

procedure TVars.SetInt(const AVar: String; const AValue: Integer);
begin
  SetStr(AVar, IntToStr(AValue));
end;

function TVars.GetBool(const AVar: String): Boolean;
begin
  Result := Trim(GetStr(AVar)) = 'TRUE';
end;

procedure TVars.SetBool(const AVar: String; const AValue: Boolean);
begin
  if AValue then SetStr(AVar, 'TRUE') else SetStr(AVar, 'FALSE');
end;

procedure TVars.SaveToFile(const AFileName: String);
var
  I: Integer;
  S: TStringList;
begin
  S := TStringList.Create;
  for I := 0 to FID.Count - 1 do
    S.Append(FID[I] + ',' + FValue[I]);
  S.SaveToFile(AFileName);
  S.Free;
end;

function TVars.Count: Integer;
begin
  Result := FID.Count;
end;

function TVars.IsVar(const AVar: String): Boolean;
begin
  Result := FID.IndexOf(AVar) > -1;
end;

procedure TVars.ClearGameVars;
var
  I: Integer;  
  S: string;
begin
  for I := FID.Count - 1 downto 0 do
  begin
    S := Copy(Trim(FID[I]), 1, 5);
    if (S = 'Game.') then Continue;
    //FValue[I] := '';   
    FID.Delete(I);
    FValue.Delete(I);
  end;
end;

procedure TVars.Dec(const VarName: String; Count: Integer);
var
  I: Integer;
begin
  if (Count < 1) then Exit;
  I := GetInt(VarName);
  System.Dec(I, Count);
  SetInt(VarName, I);
end;

procedure TVars.Inc(const VarName: String; Count: Integer);
var
  I: Integer;
begin
  if (Count < 1) then Exit;
  I := GetInt(VarName);
  System.Inc(I, Count);
  SetInt(VarName, I);
end;

procedure TVars.Let(Var1, Var2: String);
var
  I: Integer;
  S: string;
begin
  I := FID.IndexOf(Var2);
  if I < 0 then S := '' else S := FValue[I];
  I := FID.IndexOf(Var1);
  if I < 0 then
  begin
    FID.Append(Var1);
    FValue.Append(S);
  end else FValue[I] := S;
end;

procedure TVars.LoadFromFile(const AFileName: String);
var
  A: TStringList;
  I, J: Integer;
  S: string;
begin
  A := TStringList.Create;
  try
    Self.Clear;
    A.LoadFromFile(AFileName);
    for I := 0 to A.Count - 1 do
    begin
      S := Trim(A[I]);
      J := Pos(',', S);
      Self.FID.Append(Trim(Copy(S, 1, J - 1)));
      Self.FValue.Append(Trim(Copy(S, J + 1, Length(S))));
    end;
  finally
    A.Free;
  end;
end;

procedure TVars.EmptyVar(const AVar: String);
var
  I: Integer;
begin
  I := FID.IndexOf(AVar);
  if (I < 0) then Exit;
  FValue[I] := '';
end;

initialization
  V := TVars.Create;

finalization
  V.Free;

end.

