unit script;

interface
uses classes;

procedure Run(Script: string); // Запускаем скрипт на выполнение

type
  TPSPc = class
  private
    procedure getHP(var value: Integer);
    procedure setHP(value: Integer);
    procedure getRHP(var value: Integer);
    procedure setRHP(value: Integer);
    procedure getX(var value: word);
    procedure getY(var value: word);
    function getName(): string;
    procedure getQuest(var Value: byte; Index:byte);
    procedure setQuest(Value, Index:byte);
    function getGold(): word;
    function addItem(id: byte; amount: integer): boolean;
    function addPotion(id: byte; amount: integer): boolean;
    function removeGold(amount: word): boolean;
  end;

  TPSMap = class
  private
    procedure putItem(x,y,id: byte; amount: integer);
    procedure putPotion(x,y,id: byte; amount: integer);
    procedure getTile(var Value: byte; IndexX,IndexY: byte);
    procedure setTile(Value, IndexX, IndexY: byte);
  end;


implementation

uses uPSCompiler, uPSRuntime, uPSC_std, uPSR_std, SysUtils, wlog, sutils, vars,
  utils, mbox, msg, player, monsters, items, liquid, map;

const ScriptPath = '\Data\Scripts\'; // Путь к папке со скриптами

var
  Path: string;
  L, F, H, D, Z: TStringList;

{ класс TPSPc }
function TPSPc.getName(): string; begin Result := pc.name; end;
function TPSPc.getGold(): word; begin Result := pc.getGold(); end;
function TPSPc.removeGold(amount: word): boolean; begin Result := pc.removeGold(amount); end;
procedure TPSPc.getQuest(var Value: byte; Index:byte); begin Value := pc.quest[Index]; end;
procedure TPSPc.setQuest(Value, Index:byte); begin pc.quest[Index] := Value; end;
procedure TPSPc.getHP(var value: Integer); begin Value := pc.hp; end;
procedure TPSPc.getRHP(var value: Integer); begin Value := pc.Rhp; end;
procedure TPSPc.getX(var value: Word); begin Value := pc.X; end;
procedure TPSPc.getY(var value: Word); begin Value := pc.Y; end;
procedure TPSPc.setHP(value: Integer); begin pc.HP:= value; end;
procedure TPSPc.setRHP(value: Integer); begin pc.RHP:= value; end;
function TPSPc.addItem(id: byte; amount: integer): boolean; begin Result := pc.PickUp(CreateItem(id, amount, 0), FALSE,amount)=0; end;
function TPSPc.addPotion(id: byte; amount: integer): boolean; begin Result := pc.PickUp(CreatePotion(id, amount), FALSE,amount)=0; end;
{ класс TPSMap }
procedure TPSMap.putItem(x,y,id: byte; amount: integer); begin items.PutItem(x,y,CreateItem(id, amount, 0),amount); end;
procedure TPSMap.putPotion(x,y,id: byte; amount: integer); begin items.PutItem(x,y,CreatePotion(id, amount),amount); end;
procedure TPSMap.getTile(var Value: byte; IndexX,IndexY: byte); begin Value := M.Tile[IndexX,IndexY]; end;
procedure TPSMap.setTile(Value, IndexX, IndexY: byte); begin M.Tile[IndexX,IndexY] :=Value ; end;

{ Вернуть переменную как строку }
function WanderGetStr(VR: String): String;
begin
  Result := V.GetStr(VR);
end;

{ Установить переменную как строку }
procedure WanderSetStr(VR, D: String);
begin
  V.SetStr(VR, D);
end;

{ Вернуть переменную как целое число }
function WanderGetInt(VR: String): Integer;
begin
  Result := V.GetInt(VR);
end;

{ Установить переменную как целое число }
procedure WanderSetInt(VR: String; A: Integer);
begin
  V.SetInt(VR, A);
end;

{ Инкременировать целочисленное значение переменной }
procedure WanderIncInt(VR: String; A: Integer);
begin
  V.Inc(VR, A);
end;

{ Декременировать целочисленное значение переменной }
procedure WanderDecInt(VR: String; A: Integer);
begin
  V.Dec(VR, A);
end;

{ Вернуть переменную как булевую }
function WanderGetBool(VR: String): Boolean;
begin
  Result := V.GetBool(VR);
end;

{ Установить переменную как булевую }
procedure WanderSetBool(VR: String; B: Boolean);
begin
  V.SetBool(VR, B);
end;

{ Присвоить значение одной переменной другой }
procedure WanderLetVar(V1, V2: String);
begin
  V.Let(V1, V2);
end;

{ Имя монстра в нужной форме }
function WanderMonstersName(id, form: byte): string;
begin
  case form of
    2: Result := MonstersData[id].name2;
    3: Result := MonstersData[id].name3;
    4: Result := MonstersData[id].name4;
    5: Result := MonstersData[id].name5;
    6: Result := MonstersData[id].name6;
    else Result := MonstersData[id].name1;
  end;
end;

{ Заголовки }
function ExtendCompiler(Sender: TPSPascalCompiler; const Name: string): Boolean;
begin
  Result := False;
  if Name = 'SYSTEM' then
  try
    Sender.AddDelphiFunction('function Rand(A, B: Integer): Integer');
    Sender.AddDelphiFunction('procedure MsgBox(S: String)');
    Sender.AddDelphiFunction('procedure Log(LogMsg: String)');
    Sender.AddDelphiFunction('procedure AddMsg(s: string; id : integer)');
    Sender.AddDelphiFunction('function Ask(s: string): char');
    Sender.AddDelphiFunction('procedure More');
    Sender.AddDelphiFunction('function GetMsg(AString: String; gender : byte): string');
    Sender.AddDelphiFunction('procedure Run(Script: String)');

    Sender.AddDelphiFunction('function  GetStr(VR: String): String');
    Sender.AddDelphiFunction('procedure SetStr(VR, D: String)');
    Sender.AddDelphiFunction('function  GetInt(VR: String): Integer');
    Sender.AddDelphiFunction('procedure SetInt(VR: String; I: Integer)');
    Sender.AddDelphiFunction('procedure IncInt(VR: String; A: Integer)');
    Sender.AddDelphiFunction('procedure DecInt(VR: String; A: Integer)');
    Sender.AddDelphiFunction('function  GetBool(VR: String): Boolean');
    Sender.AddDelphiFunction('procedure SetBool(VR: String; B: Boolean)');
    Sender.AddDelphiFunction('procedure LetVar(V1, V2: String)');
    Sender.AddDelphiFunction('function MonstersName(id, form: byte): string');

    SIRegisterTObject(Sender);
    with Sender.AddClassN(Sender.FindClass('TOBJECT'), 'TPSPC') do
    begin
      RegisterMethod('function getGold(): word');
      RegisterMethod('function removeGold(amount: word): boolean');
      RegisterMethod('function addItem(id: byte; amount: integer): boolean');
      RegisterMethod('function addPotion(id: byte; amount: integer): boolean');
      RegisterProperty('HP', 'Integer', iptRW);
      RegisterProperty('RHP', 'Integer', iptRW);
      RegisterProperty('X', 'Word', iptR);
      RegisterProperty('Y', 'Word', iptR);
      RegisterProperty('NAME', 'String', iptR);
      RegisterProperty('QUEST', 'Byte Byte', iptRW);
    end;

    with Sender.AddClassN(Sender.FindClass('TOBJECT'), 'TPSMAP') do
    begin
      RegisterMethod('procedure putItem(x,y,id: byte; amount: integer): boolean');
      RegisterMethod('procedure putPotion(x,y,id: byte; amount: integer): boolean');
      RegisterProperty('TILE', 'Byte Byte Byte', iptRW);
      SetDefaultPropery('TILE');
    end;
    Result := True;
  except end;
end;

procedure ExtendRuntime(Exec: TPSExec; ClassImporter: TPSRuntimeClassImporter);
begin
  // Указатели на функции из других модулей
  Exec.RegisterDelphiFunction(@Rand,'RAND',cdRegister);
  Exec.RegisterDelphiFunction(@Log,'LOG',cdRegister);
  Exec.RegisterDelphiFunction(@MsgBox,'MSGBOX',cdRegister);
  Exec.RegisterDelphiFunction(@AddDrawMsg,'ADDMSG',cdRegister);
  Exec.RegisterDelphiFunction(@Ask,'ASK',cdRegister);
  Exec.RegisterDelphiFunction(@More,'MORE',cdRegister);
  Exec.RegisterDelphiFunction(@GetMsg,'GETMSG',cdRegister);
  Exec.RegisterDelphiFunction(@Run,'RUN',cdRegister);
  // Указатели на функции из этого модуля
  Exec.RegisterDelphiFunction(@WanderGetStr,'GETSTR',cdRegister);
  Exec.RegisterDelphiFunction(@WanderSetStr,'SETSTR',cdRegister);
  Exec.RegisterDelphiFunction(@WanderGetInt,'GETINT',cdRegister);
  Exec.RegisterDelphiFunction(@WanderSetInt,'SETINT',cdRegister);
  Exec.RegisterDelphiFunction(@WanderIncInt,'INCINT',cdRegister);
  Exec.RegisterDelphiFunction(@WanderDecInt,'DECINT',cdRegister);
  Exec.RegisterDelphiFunction(@WanderGetBool,'GETBOOL',cdRegister);
  Exec.RegisterDelphiFunction(@WanderSetBool,'SETBOOL',cdRegister);
  Exec.RegisterDelphiFunction(@WanderLetVar,'LETVAR',cdRegister);
  Exec.RegisterDelphiFunction(@WanderMonstersName,'MONSTERSNAME',cdRegister);
  // Указатели на классы
  RIRegisterTObject(ClassImporter);
  with ClassImporter.Add(TPSPc) do
  begin
    RegisterMethod(@TPSPc.getGold, 'GETGOLD');
    RegisterMethod(@TPSPc.removeGold, 'REMOVEGOLD');
    RegisterMethod(@TPSPc.addItem, 'ADDITEM');
    RegisterMethod(@TPSPc.addPotion, 'ADDPOTION');
    RegisterPropertyHelper(@TPSPc.getHP, @TPSPc.setHP, 'HP');
    RegisterPropertyHelper(@TPSPc.getRHP, @TPSPc.setRHP, 'RHP');
    RegisterPropertyHelper(@TPSPc.getQuest, @TPSPc.setQuest, 'QUEST');
    RegisterPropertyHelper(@TPSPc.getX, nil, 'X');
    RegisterPropertyHelper(@TPSPc.getY, nil, 'Y');
    RegisterPropertyHelper(@TPSPc.getName, nil, 'NAME');
  end;
  with ClassImporter.Add(TPSMap) do
  begin
    RegisterMethod(@TPSMap.putItem, 'PUTITEM');
    RegisterMethod(@TPSMap.putItem, 'PUTPOTION');
    RegisterPropertyHelper(@TPSMap.getTile, @TPSMap.setTile, 'TILE');        
  end;
end;

function CompileScript(Script: AnsiString; out Bytecode, Messages: AnsiString): Boolean;
var
  Compiler: TPSPascalCompiler;
  I: Integer;
begin
  Bytecode := '';
  Messages := 'Compiler Messages:';

  Compiler := TPSPascalCompiler.Create;
  Compiler.OnUses := ExtendCompiler;

  try
    Result := Compiler.Compile(Script) and Compiler.GetOutput(Bytecode);
    for I := 0 to Compiler.MsgCount - 1 do
      if Length(Messages) = 0 then
        Messages := Compiler.Msg[I].MessageToString
       else
         Messages := Messages + #13#10 + Compiler.Msg[I].MessageToString;
  finally
    Compiler.Free;
  end;
end;

function RunCompiledScript(Bytecode: AnsiString; out RuntimeErrors: AnsiString): Boolean;
var
  Runtime: TPSExec;
  ClassImporter: TPSRuntimeClassImporter;
begin
  Runtime := TPSExec.Create;
  ClassImporter := TPSRuntimeClassImporter.CreateAndRegister(Runtime, false);
  try
    ExtendRuntime(Runtime, ClassImporter);
    Result := Runtime.LoadData(Bytecode)
          and Runtime.RunScript
          and (Runtime.ExceptionCode = erNoError);
    if not Result then
      RuntimeErrors :=  PSErrorToString(Runtime.LastEx, '');
  finally
    ClassImporter.Free;
    Runtime.Free;
  end;
end;

{ Процедура Run, загрузка, компиляция и выполнение скрипта }
procedure Run(Script: string);
var
  S, Data: AnsiString;
  Compiled, Run: Boolean;
  I: Integer;
begin
  S := Script;
  if (StrRight(S, 4) = '.pas') then
  begin
    // Берем скрипт из кеша...
    I := F.IndexOf(Script);
    if I > -1 then Script := D[I] else
    begin
      // Если нет в кеше...
      F.Append(Script);
      S := Path + Script;
      if Not FileExists(S) then
      begin
        MsgBox('Файл скрипта "' + ExtractFileName(S) + '" не найден!');
        Exit;
      end;
      L.LoadFromFile(S);
      Script := L.Text;
      D.Append(Script);
    end;
  end;
  // Компилируем скрипт
  Script := H.Text + Script + Z.Text;
  Compiled := CompileScript(Script, Data, S);
  // Выполняем скрипт
  if Compiled then
  begin
    Run := RunCompiledScript(Data,s);
    if s<>'' then MsgBox(s);
  end else MsgBox(s);
end;

var i: word;
initialization
  // Путь
  GetDir(0, Path);
  Path := Path + ScriptPath;
  // Списки
  L := TStringList.Create;
  F := TStringList.Create;
  D := TStringList.Create;
  H := TStringList.Create;
  Z := TStringList.Create;
  // Заголовочный скрипт
  Z.LoadFromFile(Path + 'Const.pas');
  for i:= 0 to Z.Count-1 do H.Add(Z[i]);
  Z.Clear; Z.LoadFromFile(Path + 'Monsters.pas');
  for i:= 0 to Z.Count-1 do H.Add(Z[i]);
  Z.Clear; Z.LoadFromFile(Path + 'Items.pas');
  for i:= 0 to Z.Count-1 do H.Add(Z[i]);
  Z.Clear; Z.LoadFromFile(Path + 'Tiles.pas');
  for i:= 0 to Z.Count-1 do H.Add(Z[i]);
  Z.Clear; Z.LoadFromFile(Path + 'Init.pas');
  for i:= 0 to Z.Count-1 do H.Add(Z[i]);
  Z.Clear; Z.LoadFromFile(Path + 'Final.pas');

finalization
  // Осв. ресурсы
  F.Free;
  H.Free;
  L.Free;
  D.Free;
  Z.Free;
end.
