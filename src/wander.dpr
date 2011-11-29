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
  sysutils,
  main in 'main.pas' {MainForm},
  cons in 'cons.pas',
  msg in 'msg.pas',
  utils in 'utils.pas',
  player in 'player.pas',
  map in 'map.pas',
  tile in 'tile.pas',
  monsters in 'monsters.pas',
  flags in 'flags.pas',
  items in 'items.pas',
  help in 'help.pas',
  ability in 'ability.pas',
  mapeditor in 'mapeditor.pas' {MainEdForm},
  conf in 'conf.pas',
  sutils in 'sutils.pas',
  wlog in 'wlog.pas',
  vars in 'vars.pas',
  script in 'script.pas',
  mbox in 'mbox.pas',
  liquid in 'liquid.pas',
  pngimage in 'PNGImage\PNGImage.pas',
  zlibpas in 'PNGImage\ZLibPas.pas',
  pnglang in 'PNGImage\PNGLang.pas',
  pngextra in 'PNGImage\PNGExtra.pas',
  herogen in 'herogen.pas';

{$R *.res}
{.$DEFINE DEBUG}

var Count: byte;

begin
  Randomize;
  {$IFDEF DEBUG} Debug := True; {$ELSE} Debug := false; {$ENDIF}
  Application.Initialize;
  Application.Title := 'WANDER';
  for Count := 1 to ParamCount do
  begin
    if ParamStr(Count) = '-dev' then Debug := true;
  end;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TMainEdForm, MainEdForm);
  Application.Run;
end.
