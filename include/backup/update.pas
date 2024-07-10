unit untUpdate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  function CompareVersion(version1, version2: string): Integer;
  function VerificarAtualizacoes (currentVersion: string): string;
  function JaAtualizado: Boolean;
var
  currentVersion: String;
implementation

function CompareVersion(version1, version2: string): Integer;
var
  ver1, ver2: TStringDynArray;
  i: Integer;
begin
  // Dividir as versões em partes
  ver1 := version1.Split(['.']);
  ver2 := version2.Split(['.']);

  // Comparar cada parte da versão
  for i := Low(ver1) to High(ver1) do
  begin
    if i > High(ver2) then
      Exit(1); // ver1 tem mais partes que ver2

    if StrToInt(ver1[i]) < StrToInt(ver2[i]) then
      Exit(-1)
    else if StrToInt(ver1[i]) > StrToInt(ver2[i]) then
      Exit(1);
  end;

  // Se todas as partes comparadas forem iguais até aqui
  if Length(ver1) < Length(ver2) then
    Result := -1 // ver2 tem mais partes que ver1
  else
    Result := 0; // Versões são iguais até onde foram comparadas
end;

function TformPrincipal.VerificarAtualizacoes(currentVersion: string): string;
var
  response: TStringStream;
  apiUrl, latestVersion: string;
  json: TJSONObject;
  userResponse: Integer;
begin
  currentVersion := ('0.0.0.4');
  Result := '';
  apiUrl := 'https://api.github.com/repos/FeroxGraxaim/graxaimgestaodebanca/releases/latest';
  response := TStringStream.Create('');
  try
    if HttpGetBinary(apiUrl, response) then
    begin
      writeln('Requisição bem-sucedida. Resposta recebida: ' + response.DataString);
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
          end;
        end
        else
        begin
          ShowMessage('Versão não encontrada no JSON.');
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
end;

function TformPrincipal.JaAtualizado: Boolean;
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
