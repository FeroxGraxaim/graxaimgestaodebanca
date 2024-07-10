unit untDatabase;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
DB, Forms, Controls, Graphics, Dialogs, ComCtrls, DBGrids, DBCtrls, Menus,
ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries,
TADbSource, TACustomSeries, TAMultiSeries, DateUtils, FileUtil, untMain;

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
end;

implementation

var
CriarBD, AtualizarBD, LocalizarBD: string;
versaoBDEsperada: integer;

procedure TBancoDados.DefinirVariaveis;
begin
  writeln('Definindo variáveis');
  versaoBDEsperada := 4;

  {$IFDEF MSWINDOWS}
  CriarBD     := ExpandFileName('.\criarbd.sql');
  AtualizarBD := ExpandFileName('.\atualizarbd.sql');
  LocalizarBD := ExpandFileName('%APPDATA%\GraxaimBanca\database.db');
  {$ENDIF}

  {$IFDEF LINUX}
       CriarBD     := ExpandFileName('/usr/share/GraxaimBanca/criarbd.sql');
       AtualizarBD := ExpandFileName('/usr/share/GraxaimBanca/atualizarbd.sql');
       LocalizarBD := ExpandFileName('~/.config/GraxaimBanca/database.db');
  {$ENDIF}
end;

procedure TBancoDados.AtualizarBancoDeDados;
begin
  writeln('Banco de dados está desatualizado! Atualizando...');
    try
    if FileExists(AtualizarBD) then ExecutarSQLDeArquivo(AtualizarBD)
    else
      begin
      MessageDlg('Erro',
        'Não foi possível atualizar o banco de dados, o arquivo de atualização não existe. Favor executar o arquivo de instalação do programa para reparar.', mtError, [mbOK], 0);
      formPrincipal.Close;
      end;
    writeln('Banco de dados atualizado com sucesso!');
    except
    on E: Exception do
      begin
      MessageDlg('Erro', 'Não foi possível atualizar o banco de dados: ' +
        E.Message, mtError, [mbOK], 0);
      Close;
      end;
    end;
end;

procedure TBancoDados.CriarBancoDeDados;
begin
    try
    writeln('Banco de dados não existe, criando...');
      try
      if FileExists(CriarBD) then
        begin
          try
          ExecutarSQLDeArquivo(CriarBD);
          except
          On E: Exception do
            begin
            writeln('Erro ao executar script SQL: ' + E.message);
            end;
          end;
        end
      else
        begin
        writeln('Erro: arquivo de criação do banco de dados não existe. Abortado.');
        Close;
        end;
      except
      on E: Exception do
        begin
        writeln('Erro ao criar banco de dados: ' + E.message);
        MessageDlg('Erro',
          'Não foi possível criar o banco de dados. Tente reinstalar o programa. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        end;
      end;
    finally
    writeln('Banco de dados atualizado com sucesso!');
    end;
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
              writeln('Erro ao atribuir banco de dados: ' + E.Message);
              end;
            end;
          end
        else
          begin
          writeln(
            'Arquivo de banco de dados não existe, atribuindo o caminho do arquivo para criação');
          formPrincipal.conectBancoDados.DatabaseName := (LocalizarBD);
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
        formPrincipal.Close;
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
  with formPrincipal do
    begin
    Arquivo   := TStringList.Create;
    ScriptSQL := TStringBuilder.Create;
      try
      Arquivo.LoadFromFile(VarArquivo);
      DentroDeTrigger := False;

      for I := 0 to Arquivo.Count - 1 do
        begin
        LinhaSQL := Trim(Arquivo[I]);

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
              // if not formPrincipal.conectBancoDados.Connected then
              // formPrincipal.conectBancoDados.Connected := True;

              if not transactionBancoDados.Active then
                transactionBancoDados.StartTransaction;

              formPrincipal.conectBancoDados.ExecuteDirect(ScriptSQL.ToString);

              if DentroDeTrigger and FimDoTexto('END;', LinhaSQL) then
                writeln('Gatilho criado.')
              else if LinhaSQL.StartsWith('CREATE TABLE IF NOT EXISTS', True) then
                  writeln('Tabela criada caso não exista.')
                else if LinhaSQL.StartsWith('INSERT INTO', True) then
                    writeln('Dados padrão inseridos na tabela.');

              transactionBancoDados.Commit;
              except
              on E: Exception do
                begin
                if transactionBancoDados.Active then
                  transactionBancoDados.Rollback;
                writeln('Erro ao executar comando SQL: ' + E.Message +
                  ' Comando: ' + ScriptSQL.ToString);
                end;
              end;

            ScriptSQL.Clear;
            if DentroDeTrigger and FimDoTexto('END;', LinhaSQL) then
              DentroDeTrigger := False;
            end;
          end;
        end;
      finally
      Arquivo.Free;
      ScriptSQL.Free;
      end;
    end;
end;


function TBancoDados.FimDoTexto(const Ending, FullString: string): boolean;
var
  LenEnding, LenFullString: integer;
begin
  LenEnding     := Length(Ending);
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

initialization
end.
