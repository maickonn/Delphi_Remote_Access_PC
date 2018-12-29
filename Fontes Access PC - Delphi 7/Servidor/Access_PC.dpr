{$R UAC.RES} // Pede permissões do Administrador do Windows.

program Access_PC;

uses
  Forms,
  Principal in 'Principal.pas' {Form1},
  Desktop_Remoto in 'Desktop_Remoto.pas' {Form2},
  File_Manager in 'File_Manager.pas' {Form3},
  Chat in 'Chat.pas' {Form4};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Access PC [ Servidor ]';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.

