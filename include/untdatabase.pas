{%BuildWorkingDir /home/ferox/Documentos/Programação/Graxaim Gestão de Banca}
unit untDatabase;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, ComCtrls, DBGrids, DBCtrls, Menus,
  ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries,
  TADbSource, TACustomSeries, TAMultiSeries, DateUtils, FileUtil, untMain, untSplash;

type
  TBancoDados = class(TformPrincipal)

  private
  public
    procedure DefinirVariaveis;
    procedure VerificarVersaoBancoDeDados;
    procedure AtualizarBancoDeDados;
    procedure CriarBancoDeDados;
    procedure LocalizarBancoDeDados;
    procedure ExecutarSQLDeArquivo(const VarArquivo: string);
    function FimDoTexto(const Ending, FullString: string): boolean;
    procedure qrBancaCalcFields(DataSet: TDataSet);
    procedure BackupAtualizacaoBD;
    procedure CarregarDadosSalvos;
  end;

implementation

var
  CriarBD, AtualizarBD, LocalizarBD, Backup: string;
  versaoBDEsperada: integer;

procedure TBancoDados.DefinirVariaveis;
begin
  writeln('Definindo variáveis');
  versaoBDEsperada := 9;

  {$IFDEF MSWINDOWS}
  if FileExists(GetEnvironmentVariable('PROGRAMFILES') +
    '\Graxaim Gestão de Banca\criarbd.sql') then
    CriarBD := ExpandFileName(GetEnvironmentVariable('PROGRAMFILES') +
      '\Graxaim Gestão de Banca\criarbd.sql')
  else if FileExists(GetEnvironmentVariable('PROGRAMFILES(X86)') +
    '\Graxaim Gestão de Banca\criarbd.sql') then
    CriarBD := ExpandFileName(GetEnvironmentVariable('PROGRAMFILES(X86)') +
      '\Graxaim Gestão de Banca\criarbd.sql');

  if FileExists(GetEnvironmentVariable('PROGRAMFILES') +
    '\Graxaim Gestão de Banca\atualizarbd.sql') then
    AtualizarBD := ExpandFileName(GetEnvironmentVariable('PROGRAMFILES') +
      '\Graxaim Gestão de Banca\atualizarbd.sql')
  else if FileExists(GetEnvironmentVariable('PROGRAMFILES(X86)') +
    '\Graxaim Gestão de Banca\atualizarbd.sql') then
    AtualizarBD := ExpandFileName(GetEnvironmentVariable('PROGRAMFILES(X86)') +
      '\Graxaim Gestão de Banca\atualizarbd.sql');

  LocalizarBD := ExpandFileName(GetEnvironmentVariable('APPDATA') +
    '\GraxaimBanca\database.db');

  Backup := ExpandFileName(GetEnvironmentVariable('TEMP') + 'backupgraxaimbanca.sql');
  {$ENDIF}

  {$IFDEF LINUX}
  LocalizarBD := ExpandFileName('~/.config/GraxaimBanca/database.db');
  CriarBD := ExpandFileName(IncludeTrailingPathDelimiter(GetCurrentDir) + 'datafiles/criarbd.sql');
  AtualizarBD := ExpandFileName(IncludeTrailingPathDelimiter(GetCurrentDir) + 'datafiles/atualizarbd.sql');
  Backup := ExpandFileName('/tmp/backupgraxaimbanca.sql');

  if not FileExists(CriarBD) then
    if not FileExists(AtualizarBD)
     then
       begin
          CriarBD := ExpandFileName('/usr/share/GraxaimBanca/criarbd.sql');
          AtualizarBD := ExpandFileName('/usr/share/GraxaimBanca/atualizarbd.sql');
       end
     else
     begin
     MessageDlg('Erro ao criar/atualizar banco de dados',
     'Arquivos de criação e atualiação do banco de dados ' +
     'não existem ou não estão no diretório correto. Caso tenha instalado o ' +
     'programa através de um arquivo de instalação DEB ou RPM, tente ' +
     'reinstalar o programa. ' +
     'Caso esteja compilando o código-fonte usando apenas o comando "make", certifique-se que' +
     'os arquivos "criarbd.sql" e "atualizarbd.sql" estejam na subpasta "datafiles" ' +
     'dentro da mesma pasta do binário "GraxaimBanca"',mtError,[mbOk],0);
     writeln('Caminho fracassado para CriarBD: ',CriarBD);
     writeln('Caminho fracassado para AtualizarBD: ',AtualizarBD);
     Halt;
     end;
  {$ENDIF}

  if not DirectoryExists(ExtractFilePath(LocalizarBD)) then
    if not ForceDirectories(ExtractFilePath(LocalizarBD)) then
      raise Exception.Create('Não foi possível criar o diretório do banco de dados: '
        + ExtractFilePath(LocalizarBD));

end;

procedure TBancoDados.AtualizarBancoDeDados;
var
  SQL: TStringList;
begin
  writeln('Banco de dados está desatualizado! Atualizando...');
  try
    SQL := TStringList.Create;
    if FileExists(AtualizarBD) then
    ExecutarSQLDeArquivo(AtualizarBD)
    else
    begin
      MessageDlg('Erro',
        'Não foi possível atualizar o banco de dados, o arquivo de atualização não existe. Favor executar o arquivo de instalação do programa para reparar.', mtError, [mbOK], 0);
      halt;
    end;
    writeln('Banco de dados atualizado com sucesso!');
  except
    on E: Exception do
    begin
      MessageDlg('Erro', 'Não foi possível atualizar o banco de dados, ' +
        'Programa será encerrado. Execute o programa pelo terminal para ver log.',
        mtError, [mbOK], 0);
      writeln('Erro ao atualizar banco de dados: ' + E.message);
      halt;
    end;
  end;
end;

procedure TBancoDados.CriarBancoDeDados;
var
  SQL: TStringList;
begin
  writeln('Banco de dados não existe, executando script ', CriarBD);
  try
    SQL := TStringList.Create;
    if FileExists(CriarBD) then
    begin
      if not DirectoryExists(ExtractFileDir(LocalizarBD)) then
          if not CreateDir(ExtractFileDir(LocalizarBD)) then
          begin
            MessageDlg('Erro ao criar diretório',
              'Não foi possível criar o diretório ' +
              'de configuração do programa. O programa será encerrado.',
              mtError, [mbOK], 0);
            Halt;
          end;
      ExecutarSQLDeArquivo(CriarBD)
    end
    else
    begin
      MessageDlg('Erro',
        'Arquivo de criação do banco de dados não existe, ' +
        'favor reinstalar o programa.', mtError, [mbOK], 0);
      halt;
    end;
  except
    on E: Exception do
    begin
      writeln('Erro ao criar banco de dados: ' + E.message);
      MessageDlg('Erro',
        'Não foi possível criar o banco de dados. Tente reinstalar o programa. ' +
        'Se o problema persistir favor informar no Github com a seguinte mensagem: ' +
        E.Message, mtError, [mbOK], 0);
      Halt;
    end;
  end;
  writeln('Banco de dados atualizado com sucesso!');
end;


procedure TBancoDados.VerificarVersaoBancoDeDados;
var
  qrVersaoBD: TSQLQuery;
begin
  qrVersaoBD := TSQLQuery.Create(nil);
  writeln('Verificando se o banco de dados está atualizado...');
  try
    qrVersaoBD.Database := formPrincipal.conectBancoDados;
    qrVersaoBD.SQL.Text := 'SELECT Versao FROM ControleVersao';
    qrVersaoBD.Open;

    if not qrVersaoBD.IsEmpty then
    begin
      if qrVersaoBD.FieldByName('Versao').AsInteger < versaoBDEsperada then
      begin
        writeln('Banco de dados está desatualizado, fazendo atualização...');
        AtualizarBancoDeDados;
      end;
    end
    else
    begin
      writeln('A tabela ControleVersao está vazia, fazendo a atualização...');
      AtualizarBancoDeDados;
    end;
  except
    on E: Exception do
    begin
      writeln('A tabela ControleVersao não existe no banco de dados, fazendo a atualização...');
      if Pos('no such table', LowerCase(E.Message)) > 0 then
        AtualizarBancoDeDados;
    end;
  end;
end;

procedure TBancoDados.LocalizarBancoDeDados;
begin
  with formPrincipal do
  begin
    try
      DefinirVariaveis;
      writeln('Verificando se a variável não está vazia');
      if LocalizarBD = '' then
      begin
        writeln('Erro: a variável está vazia.');
        formPrincipal.Close;
      end
      else
      begin
        if FileExists(LocalizarBD) then
        begin
          try
            writeln('Caminho do banco de dados:', LocalizarBD);
            writeln('Atribuindo o banco de dados à conexão');
            formPrincipal.conectBancoDados.DatabaseName := LocalizarBD;
            writeln('Definido caminho do banco de dados: ' +
              formPrincipal.conectBancoDados.DatabaseName);
          except
            on E: Exception do
            begin
              MessageDlg('Erro', 'Erro ao atribuir banco de dados: ' +
                E.Message, mtError, [mbOK], 0);
              Halt;
            end;
          end;
        end
        else
        begin
          formPrincipal.conectBancoDados.DatabaseName := (LocalizarBD);

          writeln('Banco de dados não existe, caminho para criação: ' +
            formPrincipal.conectBancoDados.DatabaseName);

          if not FileExists(formPrincipal.conectBancoDados.DatabaseName) then
            CriarBancoDeDados;
        end;
      end;

      VerificarVersaoBancoDeDados;

      if not formPrincipal.conectBancoDados.Connected then
      begin
        writeln('Conectando com o banco de dados...');
        formPrincipal.conectBancoDados.Connected := True;
      end;
    except
      on E: Exception do
      begin
        MessageDlg('Erro', 'Ocorreu um erro ao localizar o banco de dados: ' +
          E.Message, mtError, [mbOK], 0);
        Halt;
      end;
    end;
  end;
end;

procedure TBancoDados.ExecutarSQLDeArquivo(const VarArquivo: string);
var
  Arquivo: TStringList;
  ScriptSQL: TStringBuilder;
  I: integer;
  LinhaSQL: string;
  DentroDeTrigger: boolean;
begin
  writeln('Criando StringList');
  Arquivo := TStringList.Create;
  writeln('Criando StringBuilder');
  ScriptSQL := TStringBuilder.Create;
  try
    writeln('Tentando localizar o arquivo ', VarArquivo);
    Arquivo.LoadFromFile(VarArquivo);
    DentroDeTrigger := False;

    writeln('Iniciando a transação');
    ;

    for I := 0 to Arquivo.Count - 1 do
    begin
      LinhaSQL := Trim(Arquivo[I]);

      writeln(I, 'a linha: ', LinhaSQL);

      if (LinhaSQL <> '') and (not LinhaSQL.StartsWith('--')) then
      begin
        ScriptSQL.Append(LinhaSQL);
        ScriptSQL.Append(' ');

        if LinhaSQL.StartsWith('CREATE TRIGGER', True) then
          DentroDeTrigger := True;

        if (not DentroDeTrigger and FimDoTexto(';', LinhaSQL)) or
          (DentroDeTrigger and FimDoTexto('END;', LinhaSQL)) then
        begin
          try
            if not formPrincipal.conectBancoDados.Connected then
              formPrincipal.conectBancoDados.Connected := True;

            formPrincipal.conectBancoDados.ExecuteDirect(ScriptSQL.ToString);

            if DentroDeTrigger and FimDoTexto('END;', LinhaSQL) then
              writeln('Gatilho criado.')
            else if LinhaSQL.StartsWith('CREATE TABLE IF NOT EXISTS', True) then
              writeln('Tabela criada caso não exista.')
            else if LinhaSQL.StartsWith('INSERT INTO', True) then
              writeln('Dados padrão inseridos na tabela.');
          except
            on E: Exception do
            begin
              if transactionBancoDados.Active then
                transactionBancoDados.Rollback;
              MessageDlg('Erro', 'Erro ao executar comando SQL: ' +
                E.Message + ' Comando SQL: ' + LinhaSQL, mtError, [mbOK], 0);
              Halt;
            end;
          end;

          ScriptSQL.Clear;
          if DentroDeTrigger and FimDoTexto('END;', LinhaSQL) then
            DentroDeTrigger := False;
        end;
      end;
    end;

    if formPrincipal.transactionBancoDados.Active then
      formPrincipal.transactionBancoDados.Commit;
  except
    on E: Exception do
    begin
      writeln('Erro ao executar script SQL: ' + E.Message);
      transactionBancoDados.Rollback;
    end;
  end;

  Arquivo.Free;
  ScriptSQL.Free;
end;


function TBancoDados.FimDoTexto(const Ending, FullString: string): boolean;
var
  LenEnding, LenFullString: integer;
begin
  LenEnding := Length(Ending);
  LenFullString := Length(FullString);

  if LenEnding > LenFullString then
    Result := False
  else
    Result := SameText(Ending, Copy(FullString, LenFullString - LenEnding +
      1, LenEnding));
end;

procedure TBancoDados.qrBancaCalcFields(DataSet: TDataSet);
begin
  with formPrincipal do
  begin
    if not qrBanca.Active then qrBanca.Open;
    DataSet.FieldByName('R$Stake').AsString :=
      'R$ ' + FormatFloat('0.00', DataSet.FieldByName('Stake').AsFloat);
    DataSet.FieldByName('ValorInicialCalculado').AsString :=
      'R$ ' + FormatFLoat('0.00', DataSet.FieldByName('Valor_inicial').AsFloat);
    DataSet.FieldByName('LucroR$Calculado').AsString :=
      'R$ ' + FormatFLoat('0.00', DataSet.FieldByName('Lucro_R$').AsFloat);
    DataSet.FieldByName('Lucro%Calculado').AsString :=
      FormatFloat('0.00%', DataSet.FieldByName('Lucro_%').AsFloat);
    DataSet.FieldByName('ValorFinalCalculado').AsString :=
      'R$ ' + FormatFLoat('0.00', DataSet.FieldByName('Valor_Final').AsFloat);
  end;
end;

procedure TBancoDados.BackupAtualizacaoBD;
var
  i: integer;
  Arquivo: TFileStream;
begin
  {Arquivo := nil;
  try
    Arquivo := TFileStream.Create(Backup, fmCreate);

    @formPrincipal.ExportTable('Banca');
    @formPrincipal.ExportTable('Países');
    @formPrincipal.ExportTable('Times');
    @formPrincipal.ExportTable('Competicoes');
    @formPrincipal.ExportTable('Métodos');
    @formPrincipal.ExportTable('Linhas');
    @formPrincipal.ExportTable('Jogo');
    @formPrincipal.ExportTable('Mercados');

    writeln('Dados salvos com sucesso em ', Backup);

  finally
    Arquivo.Free;
  end;}
end;

procedure TBancoDados.CarregarDadosSalvos;
var
  Arquivo: TFileStream;
  Texto: TStringList;
  Linha: string;
  Query: TSQLQuery;
begin
  Texto := TStringList.Create;
  with formPrincipal do
  try
    Arquivo := TFileStream.Create(Backup, fmOpenRead);
      Texto.LoadFromStream(Arquivo, TEncoding.UTF8);

      with TSQLQuery.Create(nil) do
      try
        Database := conectBancoDados;
        for Linha in Texto do
        begin
          if Trim(Linha) <> '' then
          begin
            SQL.Text := Linha;
            ExecSQL;
            writeln('Inserida linha: ', Linha);
          end;
        end;

        transactionBancoDados.CommitRetaining;
        writeln('Dados importados com sucesso!');
        Free;
      except
        on E: Exception do
        begin
          MessageDlg('Erro',
            'Erro ao importar os dados. Tente novamente. Se o problema persistir ' +
            'favor informar no GitHub com a seguinte mensagem: ' + sLineBreak + E.Message,
            mtError, [mbOK], 0);
          transactionBancoDados.RollbackRetaining;
          Free;
        end;
      end;
  finally
    Texto.Free;
    Arquivo.Free;
  end;
end;


end.
