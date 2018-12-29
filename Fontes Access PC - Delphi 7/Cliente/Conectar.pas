unit Conectar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls, zLibEx, StreamManager, Registry, SndKey32,
  ExtCtrls, MMSystem;



type
  TUpload = class(TThread)
  private
  public
    Socket: TCustomWinSocket;
    procedure Execute; override;
  end;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Button1: TButton;
    CS1: TClientSocket;
    StatusBar1: TStatusBar;
    CS2: TClientSocket;
    Label4: TLabel;
    Edit4: TEdit;
    CS3: TClientSocket;
    CheckBox1: TCheckBox;
    Timer1: TTimer;
    Timer2: TTimer;
    CS4: TClientSocket;
    CS5: TClientSocket;
    procedure Button1Click(Sender: TObject);
    procedure CS1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure CS1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure CS1Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure CS2Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure CS2Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure CS1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure CS2Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure CS3Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure CS3Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure CS3Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Timer1Timer(Sender: TObject);
    procedure CS1Connecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure Timer2Timer(Sender: TObject);
    procedure CS4Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure CS4Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure CS4Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure CS5Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure CS5Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocket1Connect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure CS6Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure CS6Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure CS5Read(Sender: TObject; Socket: TCustomWinSocket);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  iSendCount: integer;
  MyFirstBmp, MySecondBmp, MyCompareBmp, PackStream: TMemoryStream;
  RecebendoDados: Boolean;

  ArquivoDownload, ArquivoUpload: TMemoryStream;
  SalvarUpload: string;
  IDSockPrincipal: string;



implementation

uses Chat;

{$R *.dfm}

// Função para converter Stream para String
function StreamToString(Stream: TStream): string;
var
  ms: TMemoryStream;
begin
  Result := '';
  ms := TMemoryStream.Create;
  try
    ms.LoadFromStream(Stream);
    SetString(Result, PChar(ms.memory), ms.Size);
  finally
    ms.Free;
  end;
end;

// Função para listar pastas
function ListFolders(Directory: string): string;
var
  FileName, Filelist, Dirlist: string;
  Searchrec: TWin32FindData;
  FindHandle: THandle;
  ReturnStr: string;
begin
  ReturnStr := '';
  try
    FindHandle := FindFirstFile(pchar(Directory + '*.*'), searchrec);
    if FindHandle <> INVALID_HANDLE_VALUE then
      repeat
        FileName := searchrec.cFileName;
        if ((searchrec.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
        begin
          dirlist := dirlist + (filename + #13);
        end
        else
        begin
          filelist := filelist + (filename + #13);

        end;
      until FindNextFile(FindHandle, searchrec) = false;
  finally
    Windows.FindClose(FindHandle);
  end;
  ReturnStr := (dirlist);
  Result := ReturnStr;
end;

// Função para Listar Arquivos
function GetFiles(FileName, Ext: string): string;
var
  SearchFile: TSearchRec;
  FindResult: Integer;
  Arc: TStrings;
begin
  Arc := TStringList.Create;
  FindResult := FindFirst(FileName + Ext, faArchive, SearchFile);
  try
    while FindResult = 0 do
    begin
      Application.ProcessMessages;
      Arc.Add(SearchFile.Name);
      FindResult := FindNext(SearchFile);
    end;
  finally
    FindClose(SearchFile)
  end;
  Result := Arc.Text;
end;

// Pega o nome do Processador
function Processador: string;
var
  regi: TRegistry; s: string;
begin
  regi := tRegistry.Create;
  with Regi do
  begin
    rootKey := HKEY_LOCAL_MACHINE;
    OpenKey('HARDWARE\DESCRIPTION\System\CentralProcessor\0', false);
    s := ReadString('ProcessorNameString');
    CloseKey;
    result := Trim(s);
  end;
end;

// Pega o Sistema Operacional
function GetSOComputer: string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', False) then
    begin
      Result := Reg.ReadString('ProductName');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

// Comprime dados
function CompressStream(SrcStream: TMemoryStream): boolean;
var
  InputStream, OutputStream: TMemoryStream;
  inbuffer, outbuffer: Pointer;
  count, outcount: longint;
begin
  result := false;
  if not assigned(SrcStream) then exit;

  InputStream := TMemoryStream.Create;
  OutputStream := TMemoryStream.Create;

  try
    InputStream.LoadFromStream(SrcStream);
    count := inputstream.Size;
    getmem(inbuffer, count);
    Inputstream.ReadBuffer(inbuffer^, count);
    zcompress(inbuffer, count, outbuffer, outcount, zcMax);
    outputstream.Write(outbuffer^, outcount);
    SrcStream.Clear;
    SrcStream.LoadFromStream(OutputStream);
    result := true;
  finally
    InputStream.Free;
    OutputStream.Free;
    FreeMem(inbuffer, count);
    FreeMem(outbuffer, outcount);
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  Button1.Enabled := false;
  Edit1.Enabled := false;
  Edit2.Enabled := false;
  Edit3.Enabled := false;
  Edit4.Enabled := false;
  StatusBar1.Panels.Items[1].Text := 'Conectando...';
  CS1.Port := strToInt(Edit2.Text);
  CS1.Host := Edit1.Text;
  CS1.Active := true;
  if CheckBox1.Checked then
    Timer1.Enabled := true
  else
    Timer1.Enabled := false;
end;

procedure TForm1.CS1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  StatusBar1.Panels.Items[1].Text := 'Desconectado';
  Button1.Enabled := true;
  Edit1.Enabled := true;
  Edit2.Enabled := true;
  Edit3.Enabled := true;
  Edit4.Enabled := true;
  Timer2.Enabled := false;
  CS2.Active := false;
  CS3.Active := false;
  CS4.Active := false;
  CS5.Active := false;
  Form2.Close;
end;

procedure TForm1.CS1Error(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  StatusBar1.Panels.Items[1].Text := 'Erro ao conectar';
  ErrorCode := 0;
  Button1.Enabled := true;
  Edit1.Enabled := true;
  Edit2.Enabled := true;
  Edit3.Enabled := true;
  Edit4.Enabled := true;
  Timer2.Enabled := false;
  CS2.Active := false;
  CS3.Active := false;
  CS4.Active := false;
  CS5.Active := false;
  Form2.Close;
end;

procedure TForm1.CS1Connect(Sender: TObject; Socket: TCustomWinSocket);
begin
  CS2.Host := CS1.Host;
  CS2.Port := CS1.Port;

  CS3.Host := CS1.Host;
  CS3.Port := CS1.Port;

  CS4.Host := CS1.Host;
  CS4.Port := CS1.Port;

  CS5.Host := CS1.Host;
  CS5.Port := CS1.Port;


  MyFirstBmp := TMemoryStream.Create;
  MySecondBmp := TMemoryStream.Create;
  MyCompareBmp := TMemoryStream.Create;
  PackStream := TMemoryStream.Create;
  iSendCount := 0;
  StatusBar1.Panels.Items[1].Text := 'Conectado';
  Timer2.Enabled := true;

  Button1.Enabled := false;
  Edit1.Enabled := false;
  Edit2.Enabled := false;
  Edit3.Enabled := false;
  Edit4.Enabled := false;

  Sleep(1000);
  Socket.SendText('<|PRINCIPAL|>');
end;

procedure TForm1.CS2Error(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure TForm1.CS2Read(Sender: TObject; Socket: TCustomWinSocket);
var
  StrCommand, StrPackSize: string;
begin
  StrCommand := socket.ReceiveText;



  if StrCommand = '<|gets|>' then
  begin

    PackStream := TMemoryStream.Create;
    CompareStream(MyFirstBmp, MySecondBmp, MyCompareBmp);

    MyCompareBmp.Position := 0;
    PackStream.LoadFromStream(MyCompareBmp);
    CompressStream(PackStream);
    PackStream.Position := 0;
    StrPackSize := inttostr(PackStream.size);
    Socket.Sendtext('<|TAMANHO|>' + StrPackSize + '<<|');

    iSendCount := iSendCount + 1;

  end;
  if StrCommand = '<|okok|>' then
  begin
    PackStream.Position := 0;
    socket.SendText(StreamToString(PackStream));
  end;
end;

procedure TForm1.CS1Read(Sender: TObject; Socket: TCustomWinSocket);
var
  StrCommand, dados2: string;
  posX, posY: Integer;
  Pastas: TStrings;
begin
  StrCommand := socket.ReceiveText;

  if Pos('<|SocketMain|>', strCommand) > 0 then begin
    dados2 := StrCommand;
    Delete(dados2, 1, Pos('<|SocketMain|>', dados2) + 13);

    dados2 := Copy(dados2, 1, Pos('<<|', dados2) - 1);
    IDSockPrincipal := dados2;
  end;


  if Pos('<|OK|>', StrCommand) > 0 then begin
    Socket.SendText('<|Info|>' + Edit4.Text + '<|>' + GetSoComputer + '<|>' + Processador + '<|>' + Edit3.Text + '<<|')
  end;

  if Pos('<|PING|>', strCommand) > 0 then begin
    Socket.SendText('<|PONG|>');
    RecebendoDados := true;
  end;

  if Pos('<|Close|>', strCommand) > 0 then begin
    CS1.Active := false;
    CS2.Active := false;
    CS3.Active := false;
    CS4.Active := false;
    CS5.Active := false;
  end;

  if Pos('<|NOSenha|>', strCommand) > 0 then begin
    CS1.Active := false;
    CS2.Active := false;
    CS3.Active := false;
    CS4.Active := false;
    CS5.Active := false;

    Application.MessageBox('Senha incorreta!', 'Erro', 16);
  end;

  if Pos('<|REQUESTKEYBOARD|>', strCommand) > 0 then begin
    dados2 := strCommand;
    Delete(dados2, 1, Pos('<|REQUESTKEYBOARD|>', dados2) + 18);
    IDSockPrincipal := Copy(dados2, 1, Pos('<<|', dados2) - 1);

    CS3.Close;
    CS3.Active := true;
  end;

  if StrCommand = '<|first|>' then
  begin
    CS2.Active := false;
    CS2.Active := true;
  end;

  if Pos('<|OpenChat|>', strCommand) > 0 then begin
    Form2.Show;
  end;

  if Pos('<|Chat|>', strCommand) > 0 then begin
    dados2 := strCommand;
    Delete(dados2, 1, Pos('<|Chat|>', dados2) + 7);

    dados2 := Copy(dados2, 1, Pos('<<|', dados2) - 1);
    Form2.Memo2.Lines.Add(dados2);
    Form2.Memo2.Lines.Add(' ');
    FlashWindow(Application.Handle, true);
    sndPlaySound(PChar(ExtractFilePath(ParamStr(0)) + '\Alerta.wav'), SND_ASYNC);
  end;

  if Pos('<|CloseChat|>', strCommand) > 0 then begin
    Form2.Close;
  end;

  if Pos('<|MousePos|>', StrCommand) > 0 then begin
    Dados2 := StrCommand;

    Delete(dados2, 1, Pos('<|MousePos|>', dados2) + 11);
    posX := strToInt(Copy(dados2, 1, Pos('<|>', dados2) - 1));

    Delete(dados2, 1, Pos('<|>', dados2) + 2);
    posY := strToInt(Copy(dados2, 1, Pos('<<|', dados2) - 1));

    SetCursorPos(posX, posY);
  end;

  if Pos('<|MouseLD|>', strCommand) > 0 then begin
    Dados2 := StrCommand;

    Delete(dados2, 1, Pos('<|MouseLD|>', dados2) + 10);
    posX := strToInt(Copy(dados2, 1, Pos('<|>', dados2) - 1));

    Delete(dados2, 1, Pos('<|>', dados2) + 2);
    posY := strToInt(Copy(dados2, 1, Pos('<<|', dados2) - 1));

    SetCursorPos(posX, posY);

    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);

  end;

  if Pos('<|MouseDC|>', strCommand) > 0 then begin
    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    Sleep(10);
    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    Sleep(10);
    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    Sleep(10);
    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  end;

  if Pos('<|MouseLU|>', strCommand) > 0 then begin
    Dados2 := StrCommand;

    Delete(dados2, 1, Pos('<|MouseLU|>', dados2) + 10);
    posX := strToInt(Copy(dados2, 1, Pos('<|>', dados2) - 1));

    Delete(dados2, 1, Pos('<|>', dados2) + 2);
    posY := strToInt(Copy(dados2, 1, Pos('<<|', dados2) - 1));

    SetCursorPos(posX, posY);
    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  end;

  if Pos('<|MouseRD|>', strCommand) > 0 then begin
    Dados2 := StrCommand;

    Delete(dados2, 1, Pos('<|MouseRD|>', dados2) + 10);
    posX := strToInt(Copy(dados2, 1, Pos('<|>', dados2) - 1));

    Delete(dados2, 1, Pos('<|>', dados2) + 2);
    posY := strToInt(Copy(dados2, 1, Pos('<<|', dados2) - 1));

    SetCursorPos(posX, posY);
    mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
  end;

  if Pos('<|MouseRU|>', strCommand) > 0 then begin
    Dados2 := StrCommand;

    Delete(dados2, 1, Pos('<|MouseRU|>', dados2) + 10);
    posX := strToInt(Copy(dados2, 1, Pos('<|>', dados2) - 1));

    Delete(dados2, 1, Pos('<|>', dados2) + 2);
    posY := strToInt(Copy(dados2, 1, Pos('<<|', dados2) - 1));

    SetCursorPos(posX, posY);
    mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
  end;


  // Gerenciador de Arquivos
  if Pos('<|Folder|>', strCommand) > 0 then begin
    dados2 := strCommand;

    Delete(dados2, 1, Pos('<|Folder|>', dados2) + 9);
    dados2 := Copy(dados2, 1, Pos('<<|', dados2) - 1);
    try
      Pastas := TStringList.Create;
      Pastas.Text := ListFolders(dados2);
      if Pastas.Strings[0] = '.' then
        Pastas.Delete(0);

      Socket.SendText('<|Folder|>' + Pastas.Text + '<<|');
      Pastas.Free;
    except
      exit;
    end;
  end;

  if Pos('<|Files|>', strCommand) > 0 then begin
    dados2 := strCommand;

    Delete(dados2, 1, Pos('<|Files|>', dados2) + 8);
    dados2 := Copy(dados2, 1, Pos('<<|', dados2) - 1);

    Socket.SendText('<|Files|>' + GetFiles(dados2, '*.*') + '<<|');
  end;

  if Pos('<|DownloadFile|>', strCommand) > 0 then begin
    dados2 := strCommand;

    Delete(dados2, 1, Pos('<|DownloadFile|>', dados2) + 15);
    dados2 := Copy(dados2, 1, Pos('<<|', dados2) - 1);

    ArquivoDownload := TMemoryStream.Create;
    ArquivoDownload.LoadFromFile(dados2);
    CS4.Close;
    CS4.Active := true;
  end;

  if Pos('<|UploadFile|>', strCommand) > 0 then begin
    dados2 := strCommand;

    Delete(dados2, 1, Pos('<|UploadFile|>', dados2) + 13);
    dados2 := Copy(dados2, 1, Pos('<<|', dados2) - 1);

    SalvarUpload := dados2;
    CS5.Close;
    CS5.Active := true;
  end;
  //



end;

procedure TForm1.CS2Connect(Sender: TObject; Socket: TCustomWinSocket);
var
  StrPackSize: string;
begin
  Socket.SendText('<|Desktop|>');
  Sleep(2000);
  MyFirstBmp := TMemoryStream.Create;
  MySecondBmp := TMemoryStream.Create;
  MyCompareBmp := TMemoryStream.Create;
  PackStream := TMemoryStream.Create;
  iSendCount := 0;

  MyFirstBmp.Clear;
  GetScreenToBmp(False, MyFirstBmp);
  MyFirstBmp.Position := 0;
  PackStream.LoadFromStream(MyFirstBmp);
  CompressStream(PackStream);
  PackStream.Position := 0;
  StrPackSize := inttostr(PackStream.size);
  CS2.Socket.Sendtext('<|TAMANHO|>' + StrPackSize + '<<|');
  iSendCount := iSendCount + 1;

end;

procedure TForm1.CS3Error(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure TForm1.CS3Read(Sender: TObject; Socket: TCustomWinSocket);
var
  dados: string;
begin
  dados := Socket.ReceiveText;

  SendKeys(PChar(dados), false);

end;

procedure TForm1.CS3Connect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Sleep(2000);
  Socket.SendText('<|KEYBOARD|>' + IDSockPrincipal + '<<|');
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if not CS1.Active then
    CS1.Active := true;
end;

procedure TForm1.CS1Connecting(Sender: TObject; Socket: TCustomWinSocket);
begin
  Button1.Enabled := false;
  Edit1.Enabled := false;
  Edit2.Enabled := false;
  Edit3.Enabled := false;
  Edit4.Enabled := false;
  StatusBar1.Panels.Items[1].Text := 'Conectando...';
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if RecebendoDados then
    RecebendoDados := false
  else begin
    CS1.Active := false;
    CS2.Active := false;
    CS3.Active := false;
  end;
end;

procedure TForm1.CS4Error(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure TForm1.CS4Connect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Sleep(2000);
  Socket.SendText('<|DOWNLOAD|>' + IDSockPrincipal + '<<|');
end;

procedure TForm1.CS4Read(Sender: TObject; Socket: TCustomWinSocket);
var
  StrCommand: string;
begin
  StrCommand := socket.ReceiveText;

  if Pos('<|OK|>', strCommand) > 0 then
  begin
    ArquivoDownload.Position := 0;
    Socket.Sendtext(inttostr(ArquivoDownload.size) + #0);
    Socket.SendStream(ArquivoDownload);
  end;

end;

procedure TForm1.CS5Error(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure TForm1.CS5Connect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Sleep(2000);
  Socket.SendText('<|UPLOAD|>');

end;

procedure TForm1.ClientSocket1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Sleep(2000);
  Socket.SendText('<|UPLOAD|>');
end;

procedure TForm1.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure TForm1.CS6Connect(Sender: TObject; Socket: TCustomWinSocket);
var
  UU: TUpload;
begin
  Sleep(2000);
  UU := TUpload.Create(true);
  UU.Socket := Socket;
  Socket.SendText('<|UPLOAD|>' + IDSockPrincipal + '<<|');
  UU.Resume;
end;

procedure TForm1.CS6Error(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure TForm1.CS5Read(Sender: TObject; Socket: TCustomWinSocket);
begin

end;

{ TUpload }
// Thread de Upload de Arquivos

procedure TUpload.Execute;
var
  s: string;
  stSize: integer;
  recebendo: Boolean;
  Stream: TMemoryStream;
begin
  inherited;
  Stream := TMemoryStream.Create;
  recebendo := false;
  while not Terminated and Socket.Connected do begin
    if Socket.ReceiveLength > 0 then begin
      s := Socket.ReceiveText;
      if not Recebendo then
      begin
        if pos(#0, s) > 0 then begin
          stSize := strtoint(copy(s, Pos('<|Size|>', s) + 8, pos(#0, s) - 1));
          Stream := TMemoryStream.Create;
        end else
          exit;
        recebendo := True;
        delete(s, 1, pos(#0, s));
      end;
      try
        Stream.Write(s[1], length(s));
        if Stream.Size = stSize then
        begin
          Stream.Position := 0;
          Recebendo := False;
          Stream.SaveToFile(SalvarUpload);
          Stream.Free;
          Form1.CS1.Socket.SendText('<|Enviado|>');
          Socket.Close;
        end;
      except
        exit;
      end;
    end;
    Sleep(10);
  end;
end;

end.

