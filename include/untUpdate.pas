unit untUpdate;

{$mode ObjFPC}
{$H+}

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
function UltimaPreRelease: string;
function AceitaPreRelease: boolean;

var
  currentVersion: string;

implementation

uses
  fpjson, HTTPDefs, fphttpclient,
  jsonparser, LCLIntf, opensslsockets, untMain;

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
const
  LinkNormal =
    'https://api.github.com/repos/FeroxGraxaim/graxaimgestaodebanca/releases/latest';
var
  response: TStringStream;
  apiUrl, latestVersion: string;
  json:     TJSONObject;
  userResponse: integer;
  httpClient: TFPHTTPClient;
  AtualTestes: boolean;
label
  Procurar, Fim;
begin
  writeln('Verificando atualizações...');
  currentVersion := '0.6.1.28';
  Result := '';
  if AceitaPreRelease then apiUrl := UltimaPreRelease
  else
    apiUrl := LinkNormal;
  response := TStringStream.Create('');
  httpClient := TFPHTTPClient.Create(nil);

  AtualTestes := AceitaPreRelease;

  writeln('Tentando se conectar com o repositório...');
  try
    try

      Procurar:

        httpClient.AddHeader('User-Agent', 'GraxaimBanca/beta');
      httpClient.Get(apiUrl, response);
    //writeln('Resposta recebida: ' + response.DataString);

      if response.DataString = '' then
      begin
        writeln('Resposta nula recebida da API.');
        goto Fim;
      end;
      if Pos('API rate limit exceeded', response.DataString) > 0 then
        writeln('Limite de requisições da API excedido. Tente novamente mais tarde.'
          + 'Resposta: ' + response.DataString)
      else
      begin
        json := TJSONObject(GetJSON(response.DataString));
        latestVersion := json.Get('tag_name', '');
        if AtualTestes then begin
          if latestVersion <> '' then
          begin
            if CompareText(currentVersion, latestVersion) < 0 then begin
              userResponse :=
                MessageDlg('Nova versão de testes disponível: ' +
                latestVersion + sLineBreak + 'Deseja atualizar agora?',
                mtConfirmation, [mbYes, mbNo], 0);
              if userResponse = mrYes then
              begin
                OpenURL(apiUrl);
                writeln('Fechando aplicação...');
                halt;
              end;
            end
            else begin
              apiURL      := LinkNormal;
              AtualTestes := False;
              goto Procurar;
            end;
          end;
        end
        else begin
          if latestVersion <> '' then
          begin
            if CompareText(currentVersion, latestVersion) < 0 then begin
              userResponse :=
                MessageDlg('Nova versão estável disponível: ' +
                latestVersion + sLineBreak + 'Deseja atualizar agora?',
                mtConfirmation, [mbYes, mbNo], 0);
              if userResponse = mrYes then
              begin
                OpenURL(apiUrl);
                writeln('Fechando aplicação...');
                halt;
              end;
            end;
          end
          else
            writeln('Versão não encontrada no JSON.');
        end;
      end;
      Fim:
    finally
      json.Free;
      response.Free;
      httpClient.Free;
    end;
  except
    on E: Exception do
    begin
      writeln('Erro ao fazer a solicitação HTTP: ' + E.Message);
      response.Free;
      httpClient.Free;
      writeln('Erro: ' + E.Message);
      MessageDlg('Não foi possível verificar se há atualizações, verifique a ' +
        'conexão e tente novamente.', mtError, [mbOK], 0);
    end;
  end;
end;

function UltimaPreRelease: string;
var
  HttpClient: TFPHTTPClient;
  JsonResponse: TJSONData;
  Releases: TJSONArray;
  i: integer;
  PreRelease: TJSONObject;
  URL: string;
  VersaoEstavel, VersaoTestes: string;
begin
  Result     := '';
  HttpClient := TFPHTTPClient.Create(nil);
  httpClient.AddHeader('User-Agent', 'GraxaimBanca/1.0');
  try
    JsonResponse := GetJSON(HttpClient.Get(
      'https://api.github.com/repos/FeroxGraxaim/graxaimgestaodebanca/releases'));
    if JsonResponse.JSONType = jtArray then
    begin
      Releases := TJSONArray(JsonResponse);
      for i :=  Releases.Count - 1 downto 0 do
      begin
        PreRelease := TJSONObject(Releases.Items[i]);
        if PreRelease.Booleans['prerelease'] then
          VersaoTestes := PreRelease.Strings['tag_name']
        else VersaoEstavel := PreRelease.Strings['tag_name'];
          if CompareText(VersaoTestes, VersaoEstavel) > 0 then
            URL  := PreRelease.Strings['url'];
      end;
      writeln('Link: ',URL);
      Result := URL;
    end;
  except
    on E: Exception do
      writeln('Erro ao verificar pré-release: ' + E.Message);
  end;
  HttpClient.Free;
  JsonResponse.Free;
end;


function AceitaPreRelease: boolean;
begin
  with formPrincipal do
    with qrConfig do
    begin
      if not Active then Open;
      Result := FieldByName('PreRelease').AsBoolean;
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
