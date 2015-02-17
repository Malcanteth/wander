unit intro;

interface

procedure IntroWindow;                                   // Заставка
procedure StartHeroName;
procedure HeroRandomWindow;                              // Сделать рандомного
procedure HeroNameWindow;                                // Окно ввода имени
procedure HeroGenderWindow;                              // Окно выбора пола
procedure HeroAtributesWindow;                           // Расстановка приоритетов
procedure HeroCloseWeaponWindow;                         // Оружие ближнего боя
procedure HeroFarWeaponWindow;                           // Оружие дальнего боя
procedure HeroCreateResultWindow;                        // Подтвердить
procedure ChooseModeWindow;                              // Выбрать режим игры
procedure DrawGameMenu;                                  // Игровое меню

const
  GMChooseAmount = 2;
  gmNEWGAME      = 1;
  gmEXIT         = 2;

implementation

uses
  Player, Conf, Main, Cons, Utils, Msg, SysUtils, Ability;
  
{ Заставка }
procedure IntroWindow;
const
  Top = 5;
  L: array [1..6] of string = (
  ('#       #   #   #          #### #     '),
  (' #  #  #   ##   ##  # ###  #    ###   '),
  (' ## # ##  #  #  # # # #  # #### #  #  '),
  ('  # # #   ####  #  ## #  # #    ###   '),
  ('   ###   #    # #   # #  # #### #  #  '),
  ('        #           # ###           # ')
  );
var
  X, Y, Len: Byte;
  Left: Word;
begin
  with GScreen.Canvas do
  begin
    DrawBG; // Фон

    // Лого WANDER
    Font.Color := cLIGHTGRAY;
    Len := Length(L[1]);
    Left := ((WindowX div 2) - (Len div 2)) * CharX;
    for Y := 1 to High(L) do
      for X := 1 to Len do
      begin
        if (L[Y][X] = ' ') then Continue;
        case Y of
             1: Font.Color := cLIGHTGRAY;
             2: Font.Color := cLIGHTBLUE;
          3..4: Font.Color := cBLUE;
          else Font.Color := cBROWN;
        end;
        TextOut(Left + ((X - 2) * CharX), (Top + Y) * CharY, L[Y][X]);
      end;

    // Версия
    Font.Color := Darker(RealColor(crRANDOM), 80); 
    TextOut(Len * CharY, (Top + High(L) + 1) * CharY, GameVersion);
  end;
end;

{ Окно ввода имени }
procedure StartHeroName;
begin
  GameState := gsHERONAME;
  Input(((WindowX-13) div 2), 17, '');
end;

{ Окно ввода имени }
procedure HeroNameWindow;
const s2 = '^^^^^^^^^^^^^';
var
  n : string[13];
  s1: string;
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  s1 := GetMsg('Введи имя геро{я/ини}:',pc.gender);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);
    Font.Color := cBROWN;
    TextOut(((WindowX-length(s2)) div 2) * CharX, 18*CharY, s2);
    if (Inputing = FALSE) then
    begin
      if InputString = '' then
      begin
        case pc.gender of
          genMALE   : pc.name := GenerateName(FALSE);
          genFEMALE : pc.name := GenerateName(TRUE);
        end;
      end else
        pc.name := InputString;
      GameState := gsHEROATR;
      MainForm.OnPaint(NIL);
    end;
  end;
end;

{ Сделать рандомного }
procedure HeroRandomWindow;
const
  s1 = 'Создашь персонаж сам или доверишься воле случая?';
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, 'Создам сам');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, 'Рандомный герой');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ Окно выбора пола }
procedure HeroGenderWindow;
const
  s1 = 'Какого пола будет твой персонаж?';
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, 'Мужского');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, 'Женского');
    Font.Color := cBROWN;
    TextOut(40*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 17*CharY, 'Без разницы');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ Расстановка приоритетов }
procedure HeroAtributesWindow;
var
  s1, s2 : string;
begin
  s1 := Format('Выбери атрибут, в котором %s больше всего преуспел{/a}:', [pc.name]); //'Выбери атрибут, в котором '+pc.name+' больше всего преуспел{/a}:';
  s2 := Format('А теперь выбери атрибут, которому %s тоже уделял{/a} внимание:', [pc.name]); //'А теперь выбери атрибут, которому '+pc.name+' тоже уделял{/a} внимание:';
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    case MenuSelected2 of
      1 :
      TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(S1,pc.gender));
      2 :
      TextOut(((WindowX-length(s2)) div 2) * CharX, 13*CharY, GetMsg(S2,pc.gender));
    end;
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, 'Сила');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, 'Ловкость');
    Font.Color := cBROWN;
    TextOut(40*CharX, 17*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 17*CharY, 'Интеллект');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ Окно выбора типа оружия ближнего боя }
procedure HeroCloseWeaponWindow;
var
  s1  : string;
  i   : byte;
begin
  pc.CreateClWList;
  s1 := Format('Выбери оружие ближнего боя, с которым %s тренировал{ся/ась} больше всего:', [PC.Name]);
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(s1,pc.gender));
    for i:=1 to CLOSEFIGHTAMOUNT-1 do
      if wlist[i] > 0 then
        if pc.closefight[wlist[i]] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(40*CharX, (14+i)*CharY, '[ ]');
          if pc.OneOfTheBestWPNCL(wlist[i]) then
            Font.Color := cWHITE else
              Font.Color := cGRAY;
          case wlist[i] of
            2 : TextOut(44*CharX, (14+i)*CharY, 'Меч');
            3 : TextOut(44*CharX, (14+i)*CharY, 'Дубина');
            4 : TextOut(44*CharX, (14+i)*CharY, 'Посох');
            5 : TextOut(44*CharX, (14+i)*CharY, 'Топор');
            6 : TextOut(44*CharX, (14+i)*CharY, 'Рукопашный бой');
          end;
        end;
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ Окно выбора пола }
procedure HeroFarWeaponWindow;
var
  S1     : string;
  I      : byte;
begin
  pc.CreateFrWList;
  S1 := Format('Какое оружие дальнего боя %s осваивал{/a} во время тренировок?', [PC.Name]);
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, GetMsg(s1,pc.gender));
    for i:=1 to FARFIGHTAMOUNT do
      if wlist[i] > 0 then
        if pc.farfight[wlist[i]] > 0 then
        begin
          Font.Color := cBROWN;
          TextOut(40*CharX, (14+i)*CharY, '[ ]');
          if pc.OneOfTheBestWPNFR(wlist[i]) then
            Font.Color := cWHITE else
              Font.Color := cGRAY;
          case wlist[i] of
            2 : TextOut(44*CharX, (14+i)*CharY, 'Лук');
            3 : TextOut(44*CharX, (14+i)*CharY, 'Праща');
            4 : TextOut(44*CharX, (14+i)*CharY, 'Духовая трубка');
            5 : TextOut(44*CharX, (14+i)*CharY, 'Арбалет');
          end;
      end;
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ Подтвердить }
procedure HeroCreateResultWindow;
const
  s1 = 'ENTER - продожить, ESC - создать заново';
var
  R, H, S : string;
begin
  StartDecorating('<-СОЗДАНИЕ НОВОГО ПЕРСОНАЖА->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    s := GetMsg('Итак, в этом мире ты '+pc.CLName(1)+' по имени '+PC.Name+'. Соглас{ен/на}?', 0);
    TextOut(((WindowX-length(s)) div 2) * CharX, 13*CharY, s);
    Font.Color := cYELLOW;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 15*CharY, s1);  
  end;
end;

{ Выбрать режим игры }
procedure ChooseModeWindow;
const
  s1 = 'В каком режиме игры ты хочешь играть?';
begin
  StartDecorating('<-ВЫБОР РЕЖИМА ИГРЫ->', TRUE);
  with GScreen.Canvas do
  begin
    Font.Color := cWHITE;
    TextOut(((WindowX-length(s1)) div 2) * CharX, 13*CharY, s1);
    Font.Color := cBROWN;
    TextOut(40*CharX, 15*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 15*CharY, 'Приключение');
    Font.Color := cBROWN;
    TextOut(40*CharX, 16*CharY, '[ ]');
    Font.Color := cCYAN;
    TextOut(44*CharX, 16*CharY, 'Подземелье');
    Font.Color := cYELLOW;
    TextOut(41*CharX, (14+MenuSelected)*CharY, '>');
  end;
end;

{ Игровое меню }
procedure DrawGameMenu;
const
  TableX = 39;
  TableW = 20;
  MenuNames : array[1..GMChooseAmount] of string = ('Новая игра', 'Выход');
var
  i : byte;
begin
  DrawBorder(TableX, Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2, TableW,(GMChooseAmount+2)+1,crBLUEGREEN);
  with GScreen.Canvas do
  begin
    for i:=1 to GMChooseAmount do
    begin
      Font.Color := cBROWN;
      TextOut((TableX+2)*CharX, (Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2+(1+i))*CharY, '[ ]');
      Font.Color := cCYAN;
      TextOut((TableX+6)*CharX, (Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2+(1+i))*CharY, MenuNames[i]);
    end;
    Font.Color := cYELLOW;
    TextOut((TableX+3)*CharX, (Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2+(1+MenuSelected))*CharY, '*');
  end;
end;

end.
