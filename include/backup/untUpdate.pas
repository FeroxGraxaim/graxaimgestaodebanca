unit untUpdate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  Forms, Controls, Graphics, Dialogs, ComCtrls, DBGrids, DBCtrls,
  ActnList, Buttons, ExtCtrls,
  TAGraph, TARadialSeries, Types, TASeries,
  TADbSource, TACustomSeries, TAMultiSeries, DateUtils;

function CompareVersion(version1, version2: string): integer;
function VerificarAtualizacoes(currentVersion: string): string;
function JaAtualizado: boolean;

var
  currentVersion: string;

implementation

uses
  fpjson, HTTPDefs, fphttpclient,
  jsonparser, LCLIntf, opensslsockets;

function CompareVersion(version1, version2: string): integer;
var
  ver1, ver2: TStringDynArray;
  i: integer;
begin
  ver1 := version1.Split(['.']);
  ver2 := version2.Split(['.']);

  for i := Low(ver1) to High(ver1) do
  begin
    if i > High(ver2) then
      Exit(1);

    if StrToInt(ver1[i]) < StrToInt(ver2[i]) then
      Exit(-1)
    else if StrToInt(ver1[i]) > StrToInt(ver2[i]) then
      Exit(1);
  end;

  if Length(ver1) < Length(ver2) then
    Result := -1
  else
    Result := 0;
end;

function VerificarAtualizacoes(currentVersion: string): string;
var
  response: TStringStream;
  apiUrl, latestVersion: string;
  json: TJSONObject;
  userResponse: integer;
  httpClient: TFPHTTPClient;
begin
  writeln('Verificando atualizações...');
  currentVersion := '0.1.2.11'; // Atualize conforme necessário
  Result := '';
  apiUrl := 'https://api.github.com/repos/FeroxGraxaim/graxaimgestaodebanca/releases/latest';
  response := TStringStream.Create('');
  httpClient := TFPHTTPClient.Create(nil);

  try
    writeln('Tentando se conectar com o repositório...');
    try
      // Adiciona o cabeçalho User-Agent
      httpClient.AddHeader('User-Agent', 'MyApp/1.0');
      httpClient.Get(apiUrl, response);
      writeln('Resposta recebida: ' + response.DataString);

      if response.DataString = '' then
      begin
        writeln('Resposta nula recebida da API.');
        Exit;
      end;

      if Pos('API rate limit exceeded', response.DataString) > 0 then
        writeln('Limite de requisições da API excedido. Tente novamente mais tarde.')
      else
      begin
        try
          json := TJSONObject(GetJSON(response.DataString));
          try
            latestVersion := json.Get('tag_name', '');
            if latestVersion <> '' then
            begin
              if CompareText(currentVersion, latestVersion) < 0 then
              begin
                userResponse := MessageDlg('Nova versão disponível: ' +
                  latestVersion + sLineBreak +
                  'Deseja atualizar agora?', mtConfirmation, [mbYes, mbNo], 0);
                if userResponse = mrYes then
                begin
                  OpenURL('https://github.com/FeroxGraxaim/graxaimgestaodebanca/releases/latest');
                  writeln('Fechando aplicação...');
                  halt;
                end;
              end
              else
                writeln('Programa já está atualizado.');
            end
            else
              writeln('Versão não encontrada no JSON.');
          except
            on E: Exception do
              writeln('Erro ao processar JSON: ' + E.Message);
          end;
        finally
          json.Free;
        end;
      end;
    except
      on E: Exception do
      begin
        writeln('Erro ao fazer a solicitação HTTP: ' + E.Message);
        MessageDlg('Não foi possível verificar se há atualizações, verifique a conexão e tente novamente.', mtError, [mbOK], 0);
      end;
    end;
  finally
    response.Free;
    httpClient.Free;
  end;
end;

function JaAtualizado: boolean;
begin
  writeln('Verificando se o arquivo de marcação existe...');
  {$IFDEF MSWINDOWS}
  Result := FileExists(GetEnvironmentVariable('APPDATA') + '\GraxaimBanca\NaoExcluir');
  {$ENDIF}

  {$IFDEF LINUX}
   Result := FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
    '.GraxaimBanca/NaoExcluir');
  {$ENDIF}
end;

end.
