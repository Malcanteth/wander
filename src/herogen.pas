unit herogen;

interface

function ChooseMode: boolean;       // Выбрать режим игры
function HeroRandom: boolean;       // Сделать рандомного
function HeroGender: boolean;       // Окно выбора пола
function HeroName: boolean;         // Окно ввода имени
function HeroAtributes: boolean;    // Расстановка приоритетов
function HeroCloseWeapon: boolean;  // Оружие ближнего боя
function HeroFarWeapon: boolean;    // Оружие дальнего боя
function HeroCreateResult: boolean; // Подтвердить

implementation
uses main, utils, graphics, cons, conf, player, ability, mapeditor, mbox,
     msg, sysutils, script, vars, map;

{ Выбрать режим игры }
function ChooseMode: boolean;
const s1 = 'В каком режиме игры ты хочешь играть?';
var j: byte;
begin
  Result := false;
  repeat
    MainForm.Cls;
    GameMenu := true;
    StartDecorating('<-ВЫБОР РЕЖИМА ИГРЫ->', TRUE);
    MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, s1);
    with TMenu.Create(40,15) do
    begin
      Add('Приключение');
      Add('Подземелье');
      j := Run();
      Free;
    end;
    if j = 0 then exit;
    GameMenu := false;
    PlayMode := j;
    // Если режим приключений то нужно загрузить карты
    if PlayMode = AdventureMode then
      if not MainEdForm.LoadSpecialMaps then
      begin
        MsgBox('Ошибка загрузки карт!');
        Halt;
      end;
      //случайный герой?
      if HeroRandom then break;
  until false;
  Result := true;
end;

{ Сделать рандомного }
function HeroRandom: boolean;
const s1 = 'Создашь персонаж сам или доверишься воле случая?';
var j: byte;
begin
  Result := false;
  repeat
    pc.ClearPlayer;
    MainForm.Cls;
    GameMenu := true;
    StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
    MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, s1);
    with TMenu.Create(40,15) do
    begin
      Add('Создам сам');
      Add('Рандомный герой');
      j := Run();
      Free;
    end;
    if j = 0 then exit; //возврат в предыдущее меню
    GameMenu := false;
    if j = 1 then
      if HeroGender then break else continue
    else
    // Всё рандомно
    begin
      // пол
      pc.gender := Rand(1, 2);
      // имя
      case pc.gender of
        genMALE   : pc.name := GenerateName(FALSE);
        genFEMALE : pc.name := GenerateName(TRUE);
      end;
      // атрибуты
      pc.atr[1] := Rand(1, 3);
      pc.atr[2] := Rand(1, 3);
      // Добавить очки умений исходя из класса
      pc.Prepare;
      pc.PrepareSkills;
      if (pc.HowManyBestWPNCL > 1) and not ((pc.HowManyBestWPNCL < 3) and (pc.OneOfTheBestWPNCL(CLOSE_TWO))) then
      begin
        pc.CreateClWList;
        c_choose := Wlist[Random(wlistsize)+1];
      end;
      if (pc.HowManyBestWPNFR > 1) and not ((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW))) then
      begin
        pc.CreateFrWList;
        f_choose := Wlist[Random(wlistsize)+1];
      end;
      if HeroCreateResult then break;
    end;
  until false;
  Result := true;
end;

{ Окно выбора пола }
function HeroGender: boolean;
const s1 = 'Какого пола будет твой персонаж?';
var j: byte;
begin
  Result := false;
  repeat
    MainForm.Cls;
    GameMenu := true;
    StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
    MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, s1);
    with TMenu.Create(40,15) do
    begin
      Add('Мужского');
      Add('Женского');
      Add('Без разницы');
      j := Run();
      Free;
    end;
    if j = 0 then exit;
    GameMenu := false;
    if j < 3 then pc.gender := j else pc.gender := Rand(1, 2);
    if HeroName then break;
  until false;
  Result := true;
end;

{ Окно ввода имени }
function HeroName: boolean;
const s2 = '^^^^^^^^^^^^^';
var
  n : string[13];
  s1: string;
  b: boolean;
begin
  Result := false;
  repeat
    MainForm.Cls;
    StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
    s1 := GetMsg('Введи имя геро{я/ини}{:',pc.gender);
    MainForm.DrawString(((WindowX-length(s1)) div 2) , 15, cWHITE, s1);
    MainForm.DrawString(((WindowX-length(s2)) div 2) , 18, cBROWN, s2);
    s1 := Input(((WindowX-13) div 2), 17, '', b, 13);
    if not(b) then exit;
    if s1 = '' then
      case pc.gender of
        genMALE   : pc.name := GenerateName(FALSE);
        genFEMALE : pc.name := GenerateName(TRUE);
      end
    else
      pc.name := s1;
    if HeroAtributes then break;
  until false;
  Result := true;
end;

{ Расстановка приоритетов }
function HeroAtributes: boolean;
var s1, s2 : string;
    i,j: byte;
    b: boolean;
begin
  Result := false;
  s1 := Format('Выбери атрибут, в котором %s больше всего преуспел{/a}:', [pc.name]); //'Выбери атрибут, в котором '+pc.name+' больше всего преуспел{/a}:';
  s2 := Format('А теперь выбери атрибут, которому %s тоже уделял{/a} внимание:', [pc.name]); //'А теперь выбери атрибут, которому '+pc.name+' тоже уделял{/a} внимание:';
  i := 1;
  repeat
    while i <=2 do
    begin
      MainForm.Cls;
      StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
      case i of
        1 : MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, GetMsg(S1,pc.gender));
        2 : MainForm.DrawString(((WindowX-length(s2)) div 2) , 13, cWHITE, GetMsg(S2,pc.gender));
      end;
      GameMenu := True;
      with TMenu.Create(40,15) do
      begin
        Add('Сила');
        Add('Ловкость');
        Add('Интеллект');
        j := Run();
        if j = 0 then dec(i);
        Free;
      end;
      GameMenu := False;
      if i = 0 then exit;
      if j <> 0 then begin pc.atr[i] := j; inc(i); end;
    end;
    // Добавить очки умений исходя из класса
    pc.Prepare;
    pc.PrepareSkills;
    j := 1;
    repeat
      b := true;
      case j of
        0: begin b := false; dec(i); break; end;
        1: if (pc.HowManyBestWPNCL > 1) and not ((pc.HowManyBestWPNCL < 3) and (pc.OneOfTheBestWPNCL(CLOSE_TWO))) then
           begin
             b:=HeroCloseWeapon;
             if not(b) then begin dec(j); continue; end;
             inc(j);
           end else inc(j);
        2: if (pc.HowManyBestWPNFR > 1) and not ((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW))) then
           begin
             b := HeroFarWeapon;
            if not(b) then begin dec(j); continue; end;
            inc(j);
          end else inc(j);
        3: if HeroCreateResult then break else inc(j);
      end;
    until j=4;
  until b;
  Result := true;
end;

{ Окно выбора типа оружия ближнего боя }
function HeroCloseWeapon: boolean;
var
  s1  : string;
  j   : byte;
  c   : LongInt;
  b   : boolean;
begin
  Result := false;
  pc.CreateClWList;
  MainForm.Cls;
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  s1 := Format('Выбери оружие ближнего боя, с которым %s тренировал{ся/ась} больше всего:', [PC.Name]);
  GameMenu := true;
  MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, GetMsg(s1,pc.gender));
  with TMenu.Create(40,15) do
  begin
    for j:=1 to CLOSEFIGHTAMOUNT-1 do
      if wlist[j] > 0 then
        if pc.closefight[wlist[j]] > 0 then
        begin
          if pc.OneOfTheBestWPNCL(wlist[j]) then c := cWHITE else c := cGRAY;
          case wlist[j] of
            2: Add('Меч',c);
            3: Add('Дубина',c);
            4: Add('Посох',c);
            5: Add('Топор',c);
            6: Add('Рукопашный бой',c);
          end;
        end;
    j := Run();
    Free;
  end;
  GameMenu := false;
  if j = 0 then exit;
  Result := true;
  c_choose := Wlist[j];
end;

{ Окно выбора пола }
function HeroFarWeapon: boolean;
var
  S1     : string;
  j      : byte;
  c      : LongInt;
begin
  Result := false;
  pc.CreateFrWList;
  MainForm.Cls;
  S1 := Format('Какое оружие дальнего боя %s осваивал{/a} во время тренировок?', [PC.Name]);
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  GameMenu := true;
  MainForm.DrawString(((WindowX-length(s1)) div 2) , 13, cWHITE, GetMsg(s1,pc.gender));
  with TMenu.Create(40,15) do
  begin
    for j:=1 to FARFIGHTAMOUNT do
      if wlist[j] > 0 then
        if pc.farfight[wlist[j]] > 0 then
        begin
          if pc.OneOfTheBestWPNFR(wlist[j]) then c := cWHITE else c := cGRAY;
          case wlist[j] of
            2 : Add('Лук',c);
            3 : Add('Праща',c);
            4 : Add('Духовая трубка',c);
            5 : Add('Арбалет',c);
          end;
       end;
    j := Run();
    Free;
  end;
  GameMenu := false;
  if j = 0 then exit;
  Result := true;
  f_choose := Wlist[j];
end;

{ Подтвердить }
function HeroCreateResult: boolean;
const
  s1 = 'ENTER - продожить, ESC - создать заново';
var
  R, H, S : string;
  Key : Word;
begin
  Result := false;
  GameMenu := true;
  MainForm.Cls;
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  Script.Run('CreatePC.pas');
  S := Format(V.GetStr('CreatePCStr'), [pc.CLName(1), PC.Name]);
  MainForm.DrawString(((WindowX-length(s)) div 2) , 13, cWHITE, GetMsg(S,pc.gender));
  MainForm.DrawString(((WindowX-length(s1)) div 2) , 15, cYELLOW, s1);
  MainForm.Redraw;
  repeat
    Key := getKey;
  until Key in [13, 27];
  GameMenu := false;  
  if Key = 27 then exit;
  Result := true;
  pc.FavWPNSkill;
end;

end.
