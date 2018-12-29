unit Principal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Menus, ComCtrls, ScktComp, zLibEx, StreamManager,
  AppEvnts, MMSystem;





type TSock_Thread = class(TThread)
  private
    Socket: TCustomWinSocket;
  public
    constructor Create(aSocket: TCustomWinSocket);
    procedure Execute; override;
  end;

type TSock_Thread2 = class(TThread)
  private
    Socket: TCustomWinSocket;
  public
    constructor Create(aSocket: TCustomWinSocket);
    procedure Execute; override;
  end;



type TSock_Thread4 = class(TThread)
  private
    Socket: TCustomWinSocket;
  public
    ID: string;
    constructor Create(aSocket: TCustomWinSocket);
    procedure Execute; override;
  end;


type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Bevel1: TBevel;
    Button3: TButton;
    LV1: TListView;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    Fecharconexo1: TMenuItem;
    N1: TMenuItem;
    FecharConexo2: TMenuItem;
    SS1: TServerSocket;
    Timer1: TTimer;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    GerenciadordeArquivos1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    Chato1: TMenuItem;
    procedure Fecharconexo1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SS1ClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure SS1Listen(Sender: TObject; Socket: TCustomWinSocket);
    procedure SS1Accept(Sender: TObject; Socket: TCustomWinSocket);
    procedure SS1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Timer1Timer(Sender: TObject);
    procedure FecharConexo2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure GerenciadordeArquivos1Click(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure Chato1Click(Sender: TObject);
  private
    { Private declarations }
  public
    L: TListItem;

    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Desktop_Remoto, File_Manager, Chat;


constructor TSock_Thread.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(true);
  Socket := aSocket;
  FreeOnTerminate := true;
end;

constructor TSock_Thread2.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(true);
  Socket := aSocket;
  FreeOnTerminate := true;
end;



constructor TSock_Thread4.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(true);
  Socket := aSocket;
  FreeOnTerminate := true;
end;



{$R *.dfm}


// Thread principal, onde será definido onde a conexão será de informações, Desktop Remoto, Teclado Remoto, Baixar e Enviar arquivos.

procedure TSock_Thread.Execute;
var
  s, s2: string;
  L: TListItem;
  TamanhoFile: Integer;
  TSTPrincipal: TSock_Thread2;
  TSTDownload: TSock_Thread4;
  Desktop: TForm2;
  FileManager: TForm3;
begin
  inherited;

  while not Terminated and Socket.Connected do begin
    if Socket.ReceiveLength > 0 then begin
      s := Socket.ReceiveText;

      // Cria Thread para transmissão de informações principais
      if Pos('<|PRINCIPAL|>', s) > 0 then begin
        TSTPrincipal := TSock_Thread2.Create(Socket);
        TSTPrincipal.Resume;
        Socket.SendText('<|OK|>');
        Destroy;
      end;

      // Cria Thead para Desktop Remoto
      if Pos('<|Desktop|>', s) > 0 then begin
        Form1.LV1.Selected.SubItems.Objects[1] := TObject(Socket);
        (Form1.LV1.Selected.SubItems.Objects[2] as TForm2).Remoto := TRemoto.Create(true);
        (Form1.LV1.Selected.SubItems.Objects[2] as TForm2).Remoto.Socket := Socket;
        (Form1.LV1.Selected.SubItems.Objects[2] as TForm2).Remoto.Resume;
        Destroy;
      end;

      // Cria Thread para Teclado Remoto
      if Pos('<|KEYBOARD|>', s) > 0 then begin
        s2 := s;
        Delete(s2, 1, Pos('<|KEYBOARD|>', s2) + 11);

        s2 := Copy(s2, 1, Pos('<<|', s2) - 1);
        L := Form1.LV1.FindCaption(0, s2, false, true, false);
        if L <> nil then
          (L.SubItems.Objects[2] as TForm2).Socket2 := Socket;
        Destroy;
      end;

      // Cria Thread para Download de Arquivos
      if Pos('<|DOWNLOAD|>', s) > 0 then begin
        s2 := s;
        Delete(s2, 1, Pos('<|DOWNLOAD|>', s2) + 11);

        s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

        TSTDownload := TSock_Thread4.Create(Socket);
        TSTDownload.ID := s2;
        TSTDownload.Resume;
        Sleep(1000);
        Socket.SendText('<|OK|>');
        Destroy;
      end;

      // Cria Thread para Upload de Arquivos
      if Pos('<|UPLOAD|>', s) > 0 then begin
        s2 := s;
        Delete(s2, 1, Pos('<|UPLOAD|>', s2) + 9);

        s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

        L := Form1.LV1.FindCaption(0, s2, false, true, false);
        if L <> nil then begin
          (L.SubItems.Objects[4] as TForm3).ProgressBar2.Max := (L.SubItems.Objects[4] as TForm3).ArquivoEnviar.Size;

          Socket.SendText('<|Size|>' + intToStr((L.SubItems.Objects[4] as TForm3).ArquivoEnviar.Size) + #0);
          Socket.SendStream((L.SubItems.Objects[4] as TForm3).ArquivoEnviar);
          (L.SubItems.Objects[4] as TForm3).Timer1.Enabled := true;
        end;

        Destroy;
      end;

    end;
    Sleep(10); // Este sleep evita do processador ficar 100% devido ao While
  end;
end;


// Thread principal, onde será transmitido as informações básicas

procedure TSock_Thread2.Execute;
var
  s, s2, iden, SO, Proc, Senha: string;
  L, L2: TListItem;
  ping1, ping2, i: Integer;
  Lista: TStrings;
begin
  inherited;

  Socket.SendText('<|SocketMain|>' + intToStr(Socket.Handle) + '<<|');
  while not Terminated and Socket.Connected do begin
    if Socket.ReceiveLength > 0 then begin
      s := Socket.ReceiveText;



      if Pos('<|Info|>', s) > 0 then begin
        s2 := s;

        Delete(s2, 1, Pos('<|Info|>', s2) + 7);
        Iden := Copy(s2, 1, Pos('<|>', s2) - 1);

        Delete(s2, 1, Pos('<|>', s2) + 2);
        SO := Copy(s2, 1, Pos('<|>', s2) - 1);

        Delete(s2, 1, Pos('<|>', s2) + 2);
        Proc := Copy(s2, 1, Pos('<|>', s2) - 1);

        Delete(s2, 1, Pos('<|>', s2) + 2);
        Senha := Copy(s2, 1, Pos('<<|', s2) - 1);

        if Senha = Form1.Edit2.Text then begin
          L := Form1.LV1.Items.Add;
          L.Caption := intToStr(Socket.Handle);
          L.SubItems.Add(Iden);
          L.SubItems.Add(SO);
          L.SubItems.Add(Proc);
          L.SubItems.Add(Socket.RemoteAddress);
          L.SubItems.Add('...');
          L.SubItems.Add(' ');
          L.SubItems.Add(' ');
          L.SubItems.Objects[0] := TObject(Socket);
        end else
          Socket.SendText('<|NOSenha|>');
      end;


      // Calcula o PING
      if Pos('<|PONG|>', s) > 0 then begin
        L := Form1.LV1.FindCaption(0, intToStr(Socket.Handle), false, true, false);
        ping1 := Integer(L.SubItems.Objects[5]);
        ping2 := GetTickCount - Ping1;
        L.SubItems[4] := intToStr(ping2);
      end;


      // Chat
      if Pos('<|Chat|>', s) > 0 then begin
        s2 := s;
        Delete(s2, 1, Pos('<|Chat|>', s2) + 7);

        s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

        (L.SubItems.Objects[6] as TForm4).Memo2.Lines.Add(s2);
        (L.SubItems.Objects[6] as TForm4).Memo2.Lines.Add(' ');
        FlashWindow((L.SubItems.Objects[6] as TForm4).Handle, true);
        sndPlaySound(PChar(ExtractFilePath(ParamStr(0)) + '\Alerta.wav'), SND_ASYNC);
      end;

      if Pos('<|CloseChat|>', s) > 0 then begin
        if L.SubItems.Objects[6] <> nil then begin
          (L.SubItems.Objects[6] as TForm4).Memo2.Lines.Add('-- Usuário fechou o Chat --');
          (L.SubItems.Objects[6] as TForm4).Memo2.Lines.Add(' ');
          (L.SubItems.Objects[6] as TForm4).Memo1.Enabled := false;
        end;
      end;
      //

      // Gerenciador de Arquivos
      //---
      // Lista as Pastas
      if Pos('<|Folder|>', s) > 0 then begin
        s2 := s;
        Delete(s2, 1, Pos('<|Folder|>', s2) + 9);
        s2 := Copy(s2, 1, Pos('<<|', s2) - 1);
        Lista := TStringList.Create;
        Lista.Text := s2;
        L2 := Form1.LV1.FindCaption(0, intToStr(Socket.Handle), false, true, false);
        (L2.SubItems.Objects[4] as TForm3).ListView1.Clear;
        for i := 0 to Lista.Count - 1 do begin
          L := (L2.SubItems.Objects[4] as TForm3).ListView1.Items.Add;
          L.ImageIndex := 0;
          Sleep(10);
          L.Caption := Lista.Strings[i];
          L.SubItems.Add('Pasta');
        end;

        Lista.Free;
        Socket.SendText('<|Files|>' + (L2.SubItems.Objects[4] as TForm3).Edit1.Text + '<<|');
      end;

      // Lista os Arquivos
      if Pos('<|Files|>', s) > 0 then begin
        s2 := s;
        Delete(s2, 1, Pos('<|Files|>', s2) + 8);
        s2 := Copy(s2, 1, Pos('<<|', s2) - 1);
        Lista := TStringList.Create;
        Lista.Text := s2;


        for i := 0 to Lista.Count - 1 do begin
          L2 := Form1.LV1.FindCaption(0, intToStr(Socket.Handle), false, true, false);
          L := (L2.SubItems.Objects[4] as TForm3).ListView1.Items.Add;
          L.ImageIndex := 1;

          Sleep(10);
          L.Caption := Lista.Strings[i];
          L.SubItems.Add('Arquivo');
        end;

        Lista.Free;
      end;

      // Atualiza o Progresso de Upload
      if Pos('<|ProgressUP|>', s) > 0 then begin
        s2 := s;

        Delete(s, 1, Pos('<|ProgressUP|>', s) + 13);
        s2 := Copy(s2, 1, Pos('<<|', s2) - 1);

        (L2.SubItems.Objects[4] as TForm3).ProgressBar2.Position := strToInt(s2);
      end;

      // Informa que o arquivo foi enviado
      if Pos('<|Enviado|>', s) > 0 then begin
        (L2.SubItems.Objects[4] as TForm3).Progressbar2.Position := 0;

        Socket.SendText('<|Folder|>' + (L2.SubItems.Objects[4] as TForm3).Edit1.Text + '<<|');
        Application.MessageBox('Arquivo enviado com sucesso!', 'Aviso', 64);
      end;
      //---
      //


    end;
    Sleep(10);
  end;
end;



//Download de arquivo

procedure TSock_Thread4.Execute;
var
  S: string;
  stSize: Integer;
  Stream: TMemoryStream;
  Receiving: Boolean;
  L: TListItem;
begin
  inherited;
  while not Terminated and Socket.Connected do
  begin
    if Socket.ReceiveLength > 0 then
    begin
      L := Form1.LV1.FindCaption(0, ID, false, true, false);

      s := Socket.ReceiveText;
      if not Receiving then
      begin
        if pos(#0, s) > 0 then begin
          stSize := strtoint(copy(s, 1, pos(#0, s) - 1));
          (L.SubItems.Objects[4] as TForm3).ProgressBar1.Max := stSize;
        end else
          exit;
        Stream := TMemoryStream.Create;
        Receiving := True;
        delete(s, 1, pos(#0, s));
      end;
      try
        Stream.Write(s[1], length(s));
        (L.SubItems.Objects[4] as TForm3).ProgressBar1.Position := Stream.Size;
        if Stream.Size = stSize then
        begin
          Stream.Position := 0;
          Receiving := False;
          Stream.SaveToFile((L.SubItems.Objects[4] as TForm3).LocalSalvar);
          Stream.Free;
          (L.SubItems.Objects[4] as TForm3).ProgressBar1.Position := 0;
          Application.MessageBox('Arquivo baixado com sucesso!', 'Aviso', 64);
          Terminate;
        end;
      except
        Stream.Free;
      end;
    end;
    Sleep(10); // evita a CPU ficar em 100%
  end;
end;
//



procedure TForm1.Fecharconexo1Click(Sender: TObject);
var
  Desktop: TForm2;
  Socket: TCustomWinSocket;
begin
  if LV1.ItemIndex < 0 then
    exit;

  if LV1.Selected.SubItems.Objects[2] = nil then begin
    Desktop := TForm2.Create(self);
    LV1.Selected.SubItems.Objects[2] := TObject(Desktop);
    Desktop.Caption := 'Access PC - Desktop Remoto de "' + LV1.Selected.SubItems[0] + '"';
    Desktop.Show;
    Socket := TCustomWinSocket(LV1.Selected.SubItems.Objects[0]);
    Desktop.Socket := Socket;
    Socket.SendText('<|first|>');
  end else if (LV1.Selected.SubItems.Objects[2] as TForm2).Visible = false then begin
    Socket := TCustomWinSocket(LV1.Selected.SubItems.Objects[0]);
    (LV1.Selected.SubItems.Objects[2] as TForm2).Socket := Socket;
    (LV1.Selected.SubItems.Objects[2] as TForm2).Show;
    (LV1.Selected.SubItems.Objects[2] as TForm2).Socket.SendText('<|first|>');
  end

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Button1.Caption = 'Ativar' then begin
    LV1.Enabled := true;
    Button1.Caption := 'Desativar';
    SS1.Port := strToInt(Edit1.Text);
    SS1.Active := true;
    Edit1.Enabled := false;
  end else begin
    LV1.Enabled := false;
    Button1.Caption := 'Ativar';
    StatusBar1.Panels.Items[1].Text := 'Desativado';
    SS1.Active := false;
    LV1.Clear;
    Edit1.Enabled := true;
  end;
end;

procedure TForm1.SS1ClientError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
  L := LV1.FindCaption(0, intToStr(Socket.Handle), false, true, false);
  if L <> nil then begin
    if L.SubItems.Objects[2] <> nil then begin
      if Socket = (L.SubItems.Objects[2] as TForm2).Socket then begin
        (L.SubItems.Objects[2] as TForm2).Close;
      end;

      if Socket = (L.SubItems.Objects[4] as TForm3).Socket then begin
        (L.SubItems.Objects[4] as TForm3).Close;
      end;

      if Socket = (L.SubItems.Objects[6] as TForm4).Socket then begin
        (L.SubItems.Objects[6] as TForm4).Close;
      end;
    end;
    L.Delete;
  end;
end;

procedure TForm1.SS1Listen(Sender: TObject; Socket: TCustomWinSocket);
begin
  StatusBar1.Panels.Items[1].Text := 'Aguardando conexões na porta: ' + intToStr(SS1.Port);
end;



procedure TForm1.SS1Accept(Sender: TObject; Socket: TCustomWinSocket);
var
  TST: TSock_Thread;
begin
  TST := TSock_Thread.Create(Socket);
  TST.Resume;
end;

procedure TForm1.SS1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  L := LV1.FindCaption(0, intToStr(Socket.Handle), false, true, false);
  if L <> nil then begin
    if L.SubItems.Objects[2] <> nil then begin
      if Socket = (L.SubItems.Objects[2] as TForm2).Socket then begin
        (L.SubItems.Objects[2] as TForm2).Close;
      end;

      if Socket = (L.SubItems.Objects[4] as TForm3).Socket then begin
        (L.SubItems.Objects[4] as TForm3).Close;
      end;

      if Socket = (L.SubItems.Objects[6] as TForm4).Socket then begin
        (L.SubItems.Objects[6] as TForm4).Close;
      end;
    end;
    L.Delete;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i: Integer;
  Socket: TcustomWinSocket;
begin
  try
    for i := 0 to LV1.Items.Count - 1 do begin
      Socket := TCustomWinSocket(Form1.LV1.Items.Item[i].SubItems.Objects[0]);
      Form1.LV1.Items.Item[i].SubItems.Objects[5] := TObject(GetTickCount);
      Socket.SendText('<|PING|>');
    end;
  except
    Form1.LV1.Items.Delete(i);
  end;
end;

procedure TForm1.FecharConexo2Click(Sender: TObject);
var
  Socket: TCustomWinSocket;
begin
  Socket := TCustomWinSocket(LV1.Selected.SubItems.Objects[0]);
  Socket.SendText('<|Close|>');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Application.MessageBox('GitHub: https://www.github.com/Maickonn', 'About', 64);
end;

procedure TForm1.GerenciadordeArquivos1Click(Sender: TObject);
var
  Compartilhador: TForm3;
  Sock: TCustomWinSocket;
begin
  if LV1.ItemIndex < 0 then
    exit;

  if LV1.Selected.SubItems.Objects[4] = nil then begin

    Compartilhador := TForm3.Create(self);
    Compartilhador.Caption := 'Access PC - Compartilhador de Arquivos de "' + LV1.Selected.SubItems[0] + '"';
    Compartilhador.Show;
    LV1.Selected.SubItems.Objects[4] := TObject(Compartilhador);

    Sock := TCustomWinSocket(LV1.Selected.SubItems.Objects[0]);
    Compartilhador.Socket := Sock;
    Compartilhador.Socket.SendText('<|Folder|>C:\<<|');
    Compartilhador.Edit1.Text := 'C:\';
  end;
end;

procedure TForm1.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  exit;
end;

procedure TForm1.Chato1Click(Sender: TObject);
var
  Nome: string;
  OK: Boolean;
  Chat: TForm4;
begin
  if LV1.ItemIndex < 0 then
    exit;

  ok := inputQuery('Chat com "' + LV1.Selected.SubItems[0] + '"', 'Digite seu nome:', Nome);

  if ok then begin
    if LV1.Selected.SubItems.Objects[6] = nil then begin
      Chat := TForm4.Create(Self);
      Chat.Nome := Nome;
      Chat.Caption := 'Chat com "' + LV1.Selected.SubItems[0] + '"';
      Chat.Show;
      Chat.Socket := TCustomWinSocket(LV1.Selected.SubItems.Objects[0]);
      Chat.Socket.SendText('<|OpenChat|>');
      LV1.Selected.SubItems.Objects[6] := TObject(Chat);
    end;
  end;

end;

end.

