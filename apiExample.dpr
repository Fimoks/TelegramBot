program apiExample;
uses
  Vcl.Forms,
  uFrmMain in 'telegram-bot-delphi-main\sample\uFrmMain.pas' {Form1},
  uClassMessageDTO in 'telegram-bot-delphi-main\src\uClassMessageDTO.pas',
  uConsts in 'telegram-bot-delphi-main\src\uConsts.pas',
  uTelegramAPI.Interfaces in 'telegram-bot-delphi-main\src\uTelegramAPI.Interfaces.pas',
  uTelegramAPI in 'telegram-bot-delphi-main\src\uTelegramAPI.pas';

{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
