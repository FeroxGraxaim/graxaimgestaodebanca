unit untUpdate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  Forms, Controls, Graphics, Dialogs, ComCtrls, DBGrids, DBCtrls,
  ActnList, Buttons, ExtCtrls,
  TAGraph, TARadialSeries, Types, TASeries,
  TADbSource, TACustomSeries, TAMultiSeries, DateUtils;
  function CompareVersion(version1, version2: string): Integer;
  function VerificarAtualizacoes (currentVersion: string): string;
  function JaAtualizado: Boolean;
var
  currentVersion: String;
implementation
uses
  untMain, fpjson, HTTPDefs, fphttpclient, httpsend, synautil, jsonparser, LCLIntf, IdSSLOpenSSLHeaders, ssl_openssl3;

function CompareVersion(version1, version2: string): Integer;
var
  ver1, ver2: TStringDynArray;
  i: Integer;
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
  userResponse: Integer;
begin
  writeln('Verificando atualizações...');
  currentVersion := '0.0.2.0';
  Result := '';
  apiUrl := 'https://api.github.com/repos/FeroxGraxaim/graxaimgestaodebanca/releases/latest';
  response := TStringStream.Create('');

  try
    writeln('Tentando se conectar com o repositório...');
    if HttpGetBinary(apiUrl, response) then
    begin
      writeln('Resposta recebida: ' + response.DataString);

      if Pos('API rate limit exceeded', response.DataString) > 0 then
      begin
        writeln('Limite de requisições da API excedido. Tente novamente mais tarde.');
        Exit;
      end;

      json := TJSONObject(GetJSON(response.DataString));
      try
        latestVersion := json.Get('tag_name', '');
        if latestVersion <> '' then
        begin
          if CompareText(currentVersion, latestVersion) < 0 then
          begin
            userResponse := MessageDlg('Nova versão disponível: ' + latestVersion + sLineBreak +
                                       'Deseja instalar agora?', mtConfirmation, [mbYes, mbNo], 0);
            if userResponse = mrYes then
            begin
              OpenURL('https://github.com/FeroxGraxaim/graxaimgestaodebanca/releases/latest');
            end;
          end
          else
          begin
            writeln('Programa já está atualizado.');
          end;
        end
        else
        begin
          writeln('Versão não encontrada no JSON.');
        end;
      finally
        json.Free;
      end;
    end
    else
    begin
      ShowMessage('Falha ao obter informações de atualização. Resposta: ' + response.DataString);
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Erro: ' + E.Message + sLineBreak + 'Resposta: ' + response.DataString);
    end;
  end;
  response.Free;
  Exit;
end;

function JaAtualizado: Boolean;
begin
  writeln('Verificando se o arquivo de marcação existe...');
  {$IFDEF MSWINDOWS}
   Result := FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) +
    'GraxaimBanca\NaoExcluir');
  {$ENDIF}

  {$IFDEF LINUX}
   Result := FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
    '.GraxaimBanca/NaoExcluir');
  {$ENDIF}
end;

end.
