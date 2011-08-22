(******************************************,
**           ~W~A~N~D~E~R~                **
** Авторские права оригинального кода     **
**   принадлежат Дивненко Павлу aka       **
**       BreakMeThunder :)                **
**           Compiler: Borland Delphi 7.0 **
'******************************************)
program wander;

uses
  Forms,
  main in 'main.pas' {MainForm},
  cons in 'cons.pas',
  msg in 'msg.pas',
  utils in 'utils.pas',
  player in 'player.pas',
  map in 'map.pas',
  tile in 'tile.pas',
  intro in 'intro.pas',
  special in 'special.pas',
  monsters in 'monsters.pas',
  flags in 'flags.pas',
  items in 'items.pas',
  help in 'help.pas',
  ability in 'ability.pas';

{$R *.res}

begin
  Randomize;
  Application.Initialize;
  Application.Title := 'WANDER';
  Application.CreateForm(TMainForm, MainForm);
  MainForm.Caption := 'WANDER '+Version;
  Application.Run;
end.
