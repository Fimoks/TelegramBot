unit uFrmMain;
interface
uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, System.IOUtils,
  uTelegramAPI, uTelegramAPI.Interfaces, uConsts, uClassMessageDTO,  Winapi.Windows, Winapi.Messages, System.DateUtils,
  Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Image1: TImage;
    Image2: TImage;
    procedure FormCreate(Sender: TObject);
    function FileNotUpdated(const FileName: string): Boolean;
    procedure Timer1Timer(Sender: TObject);
    procedure Image2Click(Sender: TObject);
  private
    { Private declarations }
    FTelegram: iTelegramAPI;
    FAsyncHttp: TThread;
  public
    { Public declarations }
  end;
var
  Form1: TForm1;
  EdtTokenBot: string;
  EdtUserId: string;



implementation
{$R *.dfm}




function FileTimeToDateTime(FileTime: TFileTime): TDateTime;
var
  LocalFileTime: TFileTime;
  SystemTime: TSystemTime;

begin
  if not FileTimeToLocalFileTime(FileTime, LocalFileTime) then
    RaiseLastOSError;

  if not FileTimeToSystemTime(LocalFileTime, SystemTime) then
    RaiseLastOSError;
  Result := SystemTimeToDateTime(SystemTime);
end;



function TForm1.FileNotUpdated(const FileName: string): Boolean;
var
  FileInfo: TWin32FileAttributeData;
  LastWriteTime: TDateTime;

begin
  Result := False;
  if GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @FileInfo) then
  begin
    LastWriteTime := FileTimeToDateTime(FileInfo.ftLastWriteTime);
    Result := (Now - LastWriteTime) > (5 / 1440); // 5 секунд = 5 / 86400 дней
  end;
end;



function OutputValues(const FileName: string): Integer;
var
  LogFile: TextFile;
  Line: string;
  Number: Integer;
  MessageNumber: Integer;

begin
  AssignFile(LogFile, FileName);
  Reset(LogFile);

  try
    MessageNumber := 0;
    ReadLn(LogFile, Line);
    Inc(MessageNumber);

    for Line in Line.Split([';']) do
      begin
        Number := StrToIntDef(Trim(Line), 0);
        if Number < 50 then
        begin
          Result := MessageNumber;
          Exit; // выходим из функции после нахождения первого числа меньше 50
        end;
        if MessageNumber = 12 then // закрываем цикл после проверки первых 12 чисел
          Break;
        Inc(MessageNumber);
      end;
  Result := 0; // если в файле нет чисел меньше 50, возвращаем 0
  finally
    CloseFile(LogFile);
  end;

end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  EdtTokenBot := '6119846027:AAGIa8DzPCzAq0EIp7aySpbZqM4iYHZX3LI';
  EdtUserId := '-887946958';
  FTelegram := TTelegramAPI.New();
  FTelegram
    .SetUserID(EdtUserId)
    .SetBotToken(EdtTokenBot);

end;



procedure TForm1.Image2Click(Sender: TObject);
begin
   Timer1.Enabled := True;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  begin

    if FileNotUpdated('C:\Users\danys\OneDrive\Рабочий стол\Рабочий диплом\Данные\logs.txt') then
      begin
        ListBox1.Clear;
        ListBox1.Items.Add('ВНИМАНИЕ: Файл logs.txt не обновлялся более 5 секунд');
        FTelegram.SendMsg('Файл logs.txt не обновлялся более 5 секунд');
      end

    else

      begin
        ListBox1.Clear;
        ListBox1.Items.Add('Файл Logs.txt обновлялся менее 5 минут назад');
      end;

      var
        MessageNumber: Integer;

      begin
        MessageNumber := OutputValues('C:\Users\danys\OneDrive\Рабочий стол\Рабочий диплом\Данные\logs.txt');
        if MessageNumber = 0 then
          begin
            ListBox2.Clear;
            ListBox2.Items.Add('В файле нет чисел меньше 50');
          end

        else
          begin
          ListBox2.Clear;
          ListBox2.Items.Add('ВНИМАНИЕ: Антенна с номером ' + IntToStr(MessageNumber) + 'показывает значения меньше 50');
          FTelegram.SendMsg('Антена с номером '+ IntToStr(MessageNumber) + ' показывает значения меньше 50');
          end;

      end;

      Timer1.Enabled := True;
      end;
end;

end.
