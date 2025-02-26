unit untControleMetodos;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
  TACustomSeries, TAMultiSeries, DateUtils, untMain, Math;

type

  { TEventosMetodos }

  TEventosMetodos = class(TformPrincipal)

  public
    procedure CarregaMetodos;
    procedure AtualizaGraficosMetodo;
    procedure AtualizaGraficosLinha;

    procedure lsbMetodosClick(Sender: TObject);
    procedure lsbLinhasClick(Sender: TObject);
    procedure NovoMetodo(Sender: TObject);
    procedure RemoverMetodo(Sender: TObject);
    procedure NovaLinha(Sender: TObject);
    procedure RemoverLinha(Sender: TObject);
    procedure GridMesMetodos(Sender: TObject);
    procedure GridMesLinhas(Sender: TObject);
    procedure GridAnoMetodos(Sender: TObject);
    procedure GridAnoLinhas(Sender: TObject);
    procedure AoExibirMetodos(Sender: TObject);
  end;

  TMetodo = class
    Texto:     string;
    CodMetodo: integer;
  end;

  TLinha = class
    Texto:    string;
    CodLinha: integer;
  end;

var
  InfoMetodo:  TMetodo;
  InfoLinha:   TLinha;
  ListaMetodo: TList;
  ListaLinha:  TList;
  GlobalCodMetodo, GlobalCodLinha: integer;

implementation

{ TEventosMetodos }

procedure TEventosMetodos.CarregaMetodos;
begin
  with formPrincipal do
  begin
    ListaMetodo := TList.Create;
    ListaLinha  := TList.Create;
    writeln('Carregando métodos');
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'SELECT * FROM Métodos';
      //writeln('SQL: ', SQL.Text);
      Open;
      lsbMetodos.Items.Clear;
      while not EOF do
      begin
        InfoMetodo := TMetodo.Create;
        InfoMetodo.Texto := FieldByName('Nome').AsString;
        InfoMetodo.CodMetodo := FieldByName('Cod_Metodo').AsInteger;
        ListaMetodo.Add(InfoMetodo);
        lsbMetodos.Items.Add(InfoMetodo.Texto);
        Next;
      end;
    finally
      Free;
    end;
    lsbMetodos.ItemIndex := 0;
    lsbMetodosClick(nil);
  end;
end;

procedure TEventosMetodos.AtualizaGraficosMetodo;
var
  Green, Red, Anulada, MeioGreen, MeioRed: integer;
begin
  with formPrincipal do
  begin
    Green   := 0;
    Red     := 0;
    Anulada := 0;
    MeioGreen := 0;
    MeioRed := 0;
    (chrtAcertMetodo.Series[0] as TPieSeries).Clear;
    with TSQLQuery.Create(nil) do
    begin
      DataBase := conectBancoDados;
      SQL.Text :=
        'SELECT                                                         ' +
        'SUM(CASE WHEN Status = ''Green'' THEN 1 ELSE 0 END) AS Green,   ' +
        'SUM(CASE WHEN Status = ''Red'' THEN 1 ELSE 0 END) AS Red,       ' +
        'SUM(CASE WHEN Status = ''Anulada'' THEN 1 ELSE 0 END) AS Anulada,' +
        'SUM(CASE WHEN Status = ''Meio Green'' THEN 1 ELSE 0 END) AS MeioGreen, ' +
        'SUM(CASE WHEN Status = ''Meio Red'' THEN 1 ELSE 0 END) AS MeioRed ' +
        'FROM Mercados                                                    ' +
        'WHERE Cod_Metodo = :CodMetodo                                  ';
      ParamByName('CodMetodo').AsInteger := GlobalCodMetodo;
      Open;

      if not FieldByName('Green').IsNull then
        Green := FieldByName('Green').AsInteger;

      if not FieldByName('Red').IsNull then
        Red := FieldByName('Red').AsInteger;

      if not FieldByName('Anulada').IsNull then
        Anulada := FieldByName('Anulada').AsInteger;

      if not FieldByName('MeioGreen').IsNull then
        MeioGreen := FieldByName('MeioGreen').AsInteger;

      if not FieldByName('MeioRed').IsNull then
        MeioRed := FieldByName('MeioRed').AsInteger;
      Free;
    end;

    if Green <> 0 then
      (chrtAcertMetodo.Series[0] as TPieSeries).AddPie(Green,
        'Acertos ', clGreen);

    if Red <> 0 then
      (chrtAcertMetodo.Series[0] as TPieSeries).AddPie(Red,
        'Erros ', clRed);

    if Anulada <> 0 then
      (chrtAcertMetodo.Series[0] as TPieSeries).AddPie(Anulada,
        'Anulados', clGray);

    if MeioGreen <> 0 then
      (chrtAcertMetodo.Series[0] as TPieSeries).AddPie(MeioGreen,
        'Meios Acertos', clYellow);

    if MeioRed <> 0 then
      (chrtAcertMetodo.Series[0] as TPieSeries).AddPie(MeioRed,
        'Meios Erros', $0000AFFF);

    //Gráfico de Lucratividade

    Green   := 0;
    Red     := 0;
    Anulada := 0;
    MeioGreen := 0;
    MeioRed := 0;
    (chrtLucroMetodo.Series[0] as TPieSeries).Clear;
    with TSQLQuery.Create(nil) do
    begin
      DataBase := conectBancoDados;
      SQL.Text :=
        'SELECT SUM(CASE WHEN Apostas.Status = ''Green'' THEN 1 ELSE 0 END) AS Green,   '
        + 'SUM(CASE WHEN Apostas.Status = ''Red'' THEN 1 ELSE 0 END) AS Red,       ' +
        'SUM(CASE WHEN Apostas.Status = ''Anulada'' THEN 1 ELSE 0 END) AS Anulada,' +
        'SUM(CASE WHEN Apostas.Status = ''Meio Green'' THEN 1 ELSE 0 END) AS MeioGreen, '
        +
        'SUM(CASE WHEN Apostas.Status = ''Meio Red'' THEN 1 ELSE 0 END) AS MeioRed ' +
        'FROM Mercados ' + 'JOIN Apostas ON Mercados.Cod_Aposta = Apostas.Cod_Aposta ' +
        'WHERE Cod_metodo = :CodMetodo';
      ParamByName('CodMetodo').AsInteger := GlobalCodMetodo;
      Open;

      if not FieldByName('Green').IsNull then
        Green := FieldByName('Green').AsInteger;

      if not FieldByName('Red').IsNull then
        Red := FieldByName('Red').AsInteger;

      if not FieldByName('Anulada').IsNull then
        Anulada := FieldByName('Anulada').AsInteger;

      if not FieldByName('MeioGreen').IsNull then
        MeioGreen := FieldByName('MeioGreen').AsInteger;

      if not FieldByName('MeioRed').IsNull then
        MeioRed := FieldByName('MeioRed').AsInteger;
      Free;
    end;

    if Green <> 0 then
      (chrtLucroMetodo.Series[0] as TPieSeries).AddPie(Green,
        'Lucros', clGreen);

    if Red <> 0 then
      (chrtLucroMetodo.Series[0] as TPieSeries).AddPie(Red,
        'Prejuízos', clRed);

    if Anulada <> 0 then
      (chrtLucroMetodo.Series[0] as TPieSeries).AddPie(Anulada,
        'Anulados', clGray);

    if MeioGreen <> 0 then
      (chrtLucroMetodo.Series[0] as TPieSeries).AddPie(MeioGreen,
        'Meios Lucros', clYellow);

    if MeioRed <> 0 then
      (chrtLucroMetodo.Series[0] as TPieSeries).AddPie(MeioRed,
        'Meios Prejuízos', $0000AFFF);
  end;
end;

procedure TEventosMetodos.AtualizaGraficosLinha;
var
  Green, Red, Anulada, MeioGreen, MeioRed: integer;
begin
  with formPrincipal do
  begin

    //Gráfico de acertos
    Green   := 0;
    Red     := 0;
    Anulada := 0;
    MeioGreen := 0;
    MeioRed := 0;
    (chrtAcertLinha.Series[0] as TPieSeries).Clear;
    with TSQLQuery.Create(nil) do
    begin
      DataBase := conectBancoDados;
      SQL.Text :=
        'SELECT                                                         ' +
        'SUM(CASE WHEN Status = ''Green'' THEN 1 ELSE 0 END) AS Green,   ' +
        'SUM(CASE WHEN Status = ''Red'' THEN 1 ELSE 0 END) AS Red,       ' +
        'SUM(CASE WHEN Status = ''Anulada'' THEN 1 ELSE 0 END) AS Anulada,' +
        'SUM(CASE WHEN Status = ''Meio Green'' THEN 1 ELSE 0 END) AS MeioGreen, ' +
        'SUM(CASE WHEN Status = ''Meio Red'' THEN 1 ELSE 0 END) AS MeioRed ' +
        'FROM Mercados                                                    ' +
        'WHERE Cod_Linha = :CodLinha                                  ';
      ParamByName('CodLinha').AsInteger := GlobalCodLinha;
      Open;

      if not FieldByName('Green').IsNull then
        Green := FieldByName('Green').AsInteger;

      if not FieldByName('Red').IsNull then
        Red := FieldByName('Red').AsInteger;

      if not FieldByName('Anulada').IsNull then
        Anulada := FieldByName('Anulada').AsInteger;

      if not FieldByName('MeioGreen').IsNull then
        MeioGreen := FieldByName('MeioGreen').AsInteger;

      if not FieldByName('MeioRed').IsNull then
        MeioRed := FieldByName('MeioRed').AsInteger;
      Free;
    end;

    if Green <> 0 then
      (chrtAcertLinha.Series[0] as TPieSeries).AddPie(Green,
        'Acertos', clGreen);

    if Red <> 0 then
      (chrtAcertLinha.Series[0] as TPieSeries).AddPie(Red,
        'Erros', clRed);

    if Anulada <> 0 then
      (chrtAcertLinha.Series[0] as TPieSeries).AddPie(Anulada,
        'Anulados', clGray);

    if MeioGreen <> 0 then
      (chrtAcertLinha.Series[0] as TPieSeries).AddPie(MeioGreen,
        'Meios Acertos', clYellow);

    if MeioRed <> 0 then
      (chrtAcertLinha.Series[0] as TPieSeries).AddPie(MeioRed,
        'Meios Erros', $0000AFFF);

    //Gráfico de Lucratividade

    Green   := 0;
    Red     := 0;
    Anulada := 0;
    MeioGreen := 0;
    MeioRed := 0;
    (chrtLucroLinha.Series[0] as TPieSeries).Clear;
    with TSQLQuery.Create(nil) do
    begin
      DataBase := conectBancoDados;
      SQL.Text :=
        'SELECT ' + 'SUM(CASE WHEN Apostas.Status = ''Green'' THEN 1 ELSE 0 END) AS Green,   '
        + 'SUM(CASE WHEN Apostas.Status = ''Red'' THEN 1 ELSE 0 END) AS Red,       ' +
        'SUM(CASE WHEN Apostas.Status = ''Anulada'' THEN 1 ELSE 0 END) AS Anulada,' +
        'SUM(CASE WHEN Apostas.Status = ''Meio Green'' THEN 1 ELSE 0 END) AS MeioGreen, '
        +
        'SUM(CASE WHEN Apostas.Status = ''Meio Red'' THEN 1 ELSE 0 END) AS MeioRed ' +
        'FROM Mercados ' + 'JOIN Apostas ON Mercados.Cod_Aposta = Apostas.Cod_Aposta ' +
        'WHERE Cod_Linha = :CodLinha';
      ParamByName('CodLinha').AsInteger := GlobalCodLinha;
      Open;

      if not FieldByName('Green').IsNull then
        Green := FieldByName('Green').AsInteger;

      if not FieldByName('Red').IsNull then
        Red := FieldByName('Red').AsInteger;

      if not FieldByName('Anulada').IsNull then
        Anulada := FieldByName('Anulada').AsInteger;

      if not FieldByName('MeioGreen').IsNull then
        MeioGreen := FieldByName('MeioGreen').AsInteger;

      if not FieldByName('MeioRed').IsNull then
        MeioRed := FieldByName('MeioRed').AsInteger;
      Free;
    end;

    if Green <> 0 then
      (chrtLucroLinha.Series[0] as TPieSeries).AddPie(Green,
        'Lucros ', clGreen);

    if Red <> 0 then
      (chrtLucroLinha.Series[0] as TPieSeries).AddPie(Red,
        'Prejuízos', clRed);

    if Anulada <> 0 then
      (chrtLucroLinha.Series[0] as TPieSeries).AddPie(Anulada,
        'Anulados', clGray);

    if MeioGreen <> 0 then
      (chrtLucroLinha.Series[0] as TPieSeries).AddPie(MeioGreen,
        'Meios Lucros', clYellow);

    if MeioRed <> 0 then
      (chrtLucroLinha.Series[0] as TPieSeries).AddPie(MeioRed,
        'Meios Prejuízos', $0000AFFF);

  end;
end;

procedure TEventosMetodos.lsbMetodosClick(Sender: TObject);
var
  CodMetodo, i: integer;
begin
  with formPrincipal do
  begin
    if lsbMetodos.ItemIndex <> -1 then
    begin
      CodMetodo := -1;
      for i := 0 to ListaMetodo.Count - 1 do
      begin
        if TMetodo(ListaMetodo[i]).Texto = lsbMetodos.Items[lsbMetodos.ItemIndex]
        then
        begin
          CodMetodo := TMetodo(ListaMetodo[i]).CodMetodo;
          writeln('Item Selecionado: ', CodMetodo);
          Break;
        end;
      end;
      if CodMetodo <> -1 then GlobalCodMetodo := CodMetodo;
      ListaLinha.Clear;
      with TSQLQuery.Create(nil) do
      begin
        DataBase := conectBancoDados;
        SQL.Text := 'SELECT * FROM Linhas WHERE Cod_Metodo = :CodMetodo ' +
                    'ORDER BY CAST(REPLACE(REPLACE(TRIM(REPLACE(Nome, '' '', ' +
                    ''''')), '','', ''.''), '' '', '''') AS NUMERIC)';
        //writeln('SQL: ', SQL.Text);
        ParamByName('CodMetodo').AsInteger := GlobalCodMetodo;
        Open;
        ListaLinha.Clear;
        lsbLinhas.Clear;
        while not EOF do
        begin
          InfoLinha := TLinha.Create;
          InfoLinha.Texto := FieldByName('Nome').AsString;
          InfoLinha.CodLinha := FieldByName('Cod_Linha').AsInteger;
          ListaLinha.Add(InfoLinha);
          lsbLinhas.Items.Add(InfoLinha.Texto);
          Next;
        end;
        Free;
      end;
    end;
    btnExcluirMetodo.Enabled := True;
    btnNovaLinha.Enabled     := True;
    lsbLinhas.ItemIndex      := 0;

    //Dados Escritos

    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text :=
        'SELECT ' + 'Métodos.Cod_Metodo, ' + 'Métodos.Nome AS Método, ' +
        'COUNT(Mercados.Cod_Metodo) AS TotalApostas, ' +
        'SUM(CASE WHEN Apostas.Lucro > 0 THEN 1 ELSE 0 END) AS LucroGreens, ' +
        'SUM(CASE WHEN Apostas.Lucro < 0 THEN 1 ELSE 0 END) AS LucroReds, ' +
        'SUM(CASE WHEN Mercados.Status = ''Green'' THEN 1 ELSE 0 END) AS Greens, '
        +
        'SUM(CASE WHEN Mercados.Status = ''Meio Green'' THEN 1 ELSE 0 END) AS MeioGreen, '
        + 'SUM(CASE WHEN Mercados.Status = ''Meio Red'' THEN 1 ELSE 0 END) AS MeioRed, '
        + 'SUM(CASE WHEN Mercados.Status = ''Anulada'' THEN 1 ELSE 0 END) AS Nulo, ' +
        'SUM(CASE WHEN Mercados.Status = ''Red'' OR ''Meio Red'' THEN 1 ELSE 0 END) AS Reds, '
        + 'SUM(CASE WHEN Apostas.Lucro > 0 THEN 1 ELSE 0 END) AS ApLucro, ' +
        '(CASE WHEN COUNT(Mercados.Cod_Metodo) = 0 THEN 0 ' + 'ELSE  ' +
        'SUM(CASE WHEN Apostas.Lucro > 0 THEN 1 ELSE 0 END) /  ' +
        'CAST(COUNT(Mercados.Cod_Metodo) AS FLOAT) * 100  ' +
        'END) AS PcentLucro, ' + '(CASE ' +
        'WHEN COUNT(Mercados.Cod_Metodo) = 0 THEN 0 ' + 'ELSE  ' +
        '(SUM(CASE WHEN Mercados.Status = ''Green'' OR ''Meio Green''  ' +
        'THEN 1 ELSE 0 END) / CAST(COUNT(Mercados.Cod_Metodo) AS FLOAT) * 100) ' +
        'END) AS PcentAcertos ' + 'FROM Mercados  ' +
        'LEFT JOIN Apostas ON Mercados.Cod_Aposta = Apostas.Cod_Aposta  ' +
        'LEFT JOIN Métodos ON Mercados.Cod_Metodo = Métodos.Cod_Metodo ' +
        'WHERE Métodos.Cod_Metodo = :codMet ' + 'GROUP BY Métodos.Nome ';
      ParamByName('codMet').AsInteger := GlobalCodMetodo;
      Open;

      if IsEmpty then
      begin
        lbMercadosMet.Caption  :=
          ('Mercados: 0');
        lbAcertosMet.Caption   :=
          ('Acertos: 0');
        lbErrosMet.Caption     :=
          ('Erros: 0');
        lbNuloMet.Caption      :=
          ('Anulados: 0');
        lbMeioAcertMet.Caption :=
          ('Meios Acertos: 0');
        lbMeioErroMet.Caption  :=
          ('Meios Erros: 0');
        lbLucroMet.Caption     :=
          ('Lucro Total: 0%');
      end
      else
      begin
        lbMercadosMet.Caption  :=
          ('Mercados: ' + IntToStr(FieldByName('TotalApostas').AsInteger));
        lbAcertosMet.Caption   :=
          ('Acertos: ' + IntToStr(FieldByName('Greens').AsInteger));
        lbErrosMet.Caption     :=
          ('Erros: ' + IntToStr(FieldByName('Reds').AsInteger));
        lbNuloMet.Caption      :=
          ('Anulados: ' + IntToStr(FieldByName('Nulo').AsInteger));
        lbMeioAcertMet.Caption :=
          ('Meios Acertos: ' + IntToStr(FieldByName('MeioGreen').AsInteger));
        lbMeioErroMet.Caption  :=
          ('Meios Erros: ' + IntToStr(FieldByName('MeioRed').AsInteger));
        lbLucroMet.Caption     :=
          ('Lucro Total: ' + FloatToStr(RoundTo(FieldByName('PcentLucro').AsFloat,
          -1)) + '%');
      end;
      Free;
    except
      on E: Exception do
      begin
        writeln('Erro ao selecionar método: ' + E.Message);
        Cancel;
        Free;
      end;
    end;
  end;
  AtualizaGraficosMetodo;
  lsbLinhasClick(nil);
end;

procedure TEventosMetodos.lsbLinhasClick(Sender: TObject);
var
  CodLinha, i: integer;
begin
  with formPrincipal do
  try
    if lsbLinhas.ItemIndex <> -1 then
    begin
      CodLinha := -1;
      for i := 0 to ListaLinha.Count - 1 do
      begin
        if TLinha(ListaLinha[i]).Texto = lsbLinhas.Items[lsbLinhas.ItemIndex] then
        begin
          CodLinha := TLinha(ListaLinha[i]).CodLinha;
          writeln('Item Selecionado: ', CodLinha);
          Break;
        end;
      end;
      if CodLinha <> -1 then GlobalCodLinha := CodLinha;
      AtualizaGraficosLinha;
    end;
    btnExcluirLinha.Enabled := True;

    //Dados Escritos

    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text :=
        'SELECT ' + 'Linhas.Cod_Linha, Linhas.Nome AS Linha, ' +
        'COUNT(Mercados.Cod_Linha) AS TotalApostas, ' +
        'SUM(CASE WHEN Apostas.Lucro > 0 THEN 1 ELSE 0 END) AS LucroGreens, ' +
        'SUM(CASE WHEN Apostas.Lucro < 0 THEN 1 ELSE 0 END) AS LucroReds, ' +
        'SUM(CASE WHEN Mercados.Status = ''Green'' THEN 1 ELSE 0 END) AS Greens, '
        +
        'SUM(CASE WHEN Mercados.Status = ''Meio Green'' THEN 1 ELSE 0 END) AS MeioGreen, '
        + 'SUM(CASE WHEN Mercados.Status = ''Meio Red'' THEN 1 ELSE 0 END) AS MeioRed, '
        + 'SUM(CASE WHEN Mercados.Status = ''Anulada'' THEN 1 ELSE 0 END) AS Nulo, ' +
        'SUM(CASE WHEN Mercados.Status = ''Red'' OR ''Meio Red'' THEN 1 ELSE 0 END) AS Reds, '
        + 'SUM(CASE WHEN Apostas.Lucro > 0 THEN 1 ELSE 0 END) AS ApLucro, ' +
        '(CASE WHEN COUNT(Mercados.Cod_Linha) = 0 THEN 0 ELSE  ' +
        'SUM(CASE WHEN Apostas.Lucro > 0 THEN 1 ELSE 0 END) /  ' +
        'CAST(COUNT(Mercados.Cod_Linha) AS FLOAT) * 100  ' +
        'END) AS PcentLucro, (CASE ' +
        'WHEN COUNT(Mercados.Cod_Linha) = 0 THEN 0 ' + 'ELSE  ' +
        '(SUM(CASE WHEN Mercados.Status = ''Green'' OR ''Meio Green''  ' +
        'THEN 1 ELSE 0 END) / CAST(COUNT(Mercados.Cod_Linha) AS FLOAT) * 100) ' +
        'END) AS PcentAcertos ' + 'FROM Mercados  ' +
        'LEFT JOIN Apostas ON Mercados.Cod_Aposta = Apostas.Cod_Aposta  ' +
        'LEFT JOIN Linhas ON Mercados.Cod_Linha = Linhas.Cod_Linha ' +
        'WHERE Linhas.Cod_Linha = :codLin ' + 'GROUP BY Linhas.Nome ';
      ParamByName('codLin').AsInteger := GlobalCodLinha;
      Open;
      if IsEmpty then
      begin
        lbMercadosLin.Caption  :=
          ('Mercados: 0');
        lbAcertosLin.Caption   :=
          ('Acertos: 0');
        lbErrosLin.Caption     :=
          ('Erros: 0');
        lbNuloLin.Caption      :=
          ('Anulados: 0');
        lbMeioAcertLin.Caption :=
          ('Meios Acertos: 0');
        lbMeioErroLin.Caption  :=
          ('Meios Erros: 0');
        lbLucroLin.Caption     :=
          ('Lucro Total: 0%');
      end
      else
      begin
        lbMercadosLin.Caption  :=
          ('Mercados: ' + IntToStr(FieldByName('TotalApostas').AsInteger));
        lbAcertosLin.Caption   :=
          ('Acertos: ' + IntToStr(FieldByName('Greens').AsInteger));
        lbErrosLin.Caption     :=
          ('Erros: ' + IntToStr(FieldByName('Reds').AsInteger));
        lbNuloLin.Caption      :=
          ('Anulados: ' + IntToStr(FieldByName('Nulo').AsInteger));
        lbMeioAcertLin.Caption :=
          ('Meios Acertos: ' + IntToStr(FieldByName('MeioGreen').AsInteger));
        lbMeioErroLin.Caption  :=
          ('Meios Erros: ' + IntToStr(FieldByName('MeioRed').AsInteger));
        lbLucroLin.Caption     :=
          'Lucro Total: ' + FloatToStr(RoundTo(FieldByName('PcentLucro').AsFloat,
          -1)) + '%';
      end;
      Free;
    except
      on E: Exception do
      begin
        writeln('Erro: ' + E.Message);
        Cancel;
        Free;
      end;
    end;
  except
    on E: Exception do
      writeln('Erro: ' + E.Message);
  end;
end;

procedure TEventosMetodos.NovoMetodo(Sender: TObject);
var
  ValorEntrada, Comparar: string;
begin
  with formPrincipal do
  begin
    if InputQuery('Novo Método', 'Digite o nome do método:', ValorEntrada) then
    begin
      Screen.Cursor := crAppStart;
      with TSQLQuery.Create(nil) do
      begin
        try
          Database := formPrincipal.conectBancoDados;
          SQL.Text := 'SELECT Nome FROM Métodos WHERE Nome = :Comparar';
          ParamByName('Comparar').AsString := ValorEntrada;
          Open;

          if not IsEmpty then
          begin
            Comparar := FieldByName('Nome').AsString;
            if Comparar = ValorEntrada then
              MessageDlg('Erro',
                'Erro ao salvar método, o método digitado já existe.',
                mtError, [mbOK], 0)
            else
            begin
              Close;
              SQL.Text := 'INSERT INTO Métodos (Nome) VALUES (:Metodo)';
              ParamByName('Metodo').AsString := ValorEntrada;
              ExecSQL;
              transactionBancoDados.CommitRetaining;
              CarregaMetodos;
            end;
          end
          else
          begin
            Close;
            SQL.Text := 'INSERT INTO Métodos (Nome) VALUES (:Metodo)';
            ParamByName('Metodo').AsString := ValorEntrada;
            ExecSQL;
            transactionBancoDados.CommitRetaining;
            CarregaMetodos;
          end;

        except
          on E: Exception do
          begin
            MessageDlg('Erro', 'Erro ao criar novo método, tente novamente. ' +
              'Se o erro persistir favor informar no GitHub com a seguinte mensagem: ' +
              sLineBreak + E.Message, mtError, [mbOK], 0);
            Cancel;
          end;
        end;
        Free;
      end;
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TEventosMetodos.RemoverMetodo(Sender: TObject);
begin
  if MessageDlg('Remover Método', 'Deseja realmente remover o método?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    with formPrincipal do
    begin
      with TSQLQuery.Create(nil) do
      begin
        try
          DataBase := conectBancoDados;
          SQL.Text := 'DELETE FROM Linhas WHERE Cod_Metodo = :CodMetodo;';
          writeln('SQL: ', SQL.Text);
          ParamByName('CodMetodo').AsInteger := GlobalCodMetodo;
          ExecSQL;
          SQL.Text := 'DELETE FROM Métodos WHERE Cod_Metodo = :CodMetodo';
          writeln('SQL: ', SQL.Text);
          ParamByName('CodMetodo').AsInteger := GlobalCodMetodo;
          ExecSQL;
        except
          on E: Exception do
          begin
            MessageDlg('Erro', 'Não foi possível remover o método, tente novamente.' +
              ' Se o problema persistir, favor informar no GitHub com a seguinte mensagem:'
              + sLineBreak + E.Message, mtError, [mbOK], 0);
            Cancel;
          end;
        end;
        transactionBancoDados.CommitRetaining;
        Free;
      end;
      CarregaMetodos;
    end;
  end;
end;

procedure TEventosMetodos.NovaLinha(Sender: TObject);
var
  ValorEntrada, Comparar: string;
begin
  with formPrincipal do
  begin
    if InputQuery('Novs Linha', 'Digite o nome da linha:', ValorEntrada) then
    begin
      Screen.Cursor := crAppStart;
      with TSQLQuery.Create(nil) do
      begin
        try
          Database := conectBancoDados;
          SQL.Text := 'SELECT Nome FROM Linhas WHERE Nome = :Comparar';
          ParamByName('Comparar').AsString := ValorEntrada;
          Open;

          Comparar := FieldByName('Nome').AsString;
          if Comparar = ValorEntrada then
            MessageDlg('Erro',
              'Erro ao salvar linha, a linha digitada já existe.',
              mtError, [mbOK], 0)
          else
          begin
            Close;
            SQL.Text :=
              'INSERT INTO Linhas (Nome, Cod_Metodo) VALUES (:Linha, :CodMetodo)';
            ParamByName('Linha').AsString := ValorEntrada;
            ParamByName('CodMetodo').AsInteger := GlobalCodMetodo;
            ExecSQL;
            transactionBancoDados.CommitRetaining;
            CarregaMetodos;
          end;

        except
          on E: Exception do
          begin
            MessageDlg('Erro', 'Erro ao criar nova linha, tente novamente. ' +
              'Se o erro persistir favor informar no GitHub com a seguinte mensagem: ' +
              sLineBreak + E.Message, mtError, [mbOK], 0);
            Cancel;
          end;
        end;
        Free;
      end;
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TEventosMetodos.RemoverLinha(Sender: TObject);
begin
  if MessageDlg('Remover Linha', 'Deseja realmente remover a linha selecionada?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    with formPrincipal do
    begin
      with TSQLQuery.Create(nil) do
      begin
        try
          DataBase := conectBancoDados;
          SQL.Text := 'DELETE FROM Linhas WHERE Cod_Linha = :CodLinha;';
          writeln('SQL: ', SQL.Text);
          ParamByName('CodLinha').AsInteger := GlobalCodLinha;
          ExecSQL;
        except
          on E: Exception do
          begin
            MessageDlg('Erro', 'Não foi possível remover a linha, tente novamente.' +
              ' Se o problema persistir, favor informar no GitHub com a seguinte mensagem:'
              + sLineBreak + E.Message, mtError, [mbOK], 0);
            Cancel;
          end;
        end;
        transactionBancoDados.CommitRetaining;
        Free;
      end;
      lsbLinhas.Items.Clear;
      CarregaMetodos;
    end;
  end;
end;

procedure TEventosMetodos.GridMesMetodos(Sender: TObject);
begin
  with formPrincipal do
  begin
    with qrMetodosMes do
    begin
      if Active then Close;
      //ParamByName('mesSelec').AsString := Format('%.2d', [mesSelecionado]);
      //ParamByName('anoSelec').AsString := Format('%.4d', [anoSelecionado]);
      Open;
      if IsEmpty then
      begin
        grdMetodosMes.Enabled := False;
        grdLinhasMes.Enabled  := False;
      end
      else
      begin
        grdMetodosMes.Enabled := True;
        grdLinhasMes.Enabled  := True;
      end;
    end;
    with qrLinhasMes do
    begin
      if Active then Close;
      ParamByName('CodMetodo').AsInteger :=
        qrMetodosMes.FieldByName('Cod_Metodo').AsInteger;
      //ParamByName('mesSelec').AsString := Format('%.2d', [mesSelecionado]);
      //ParamByName('anoSelec').AsString := Format('%.4d', [anoSelecionado]);
      Open;
    end;
  end;
end;

procedure TEventosMetodos.GridMesLinhas(Sender: TObject);
begin
  with formPrincipal do
  begin
    with qrLinhasMes do
    begin
      if Active then Close;
      ParamByName('CodMetodo').AsInteger :=
        qrMetodosMes.FieldByName('Cod_Metodo').AsInteger;
      //ParamByName('mesSelec').AsString := Format('%.2d', [mesSelecionado]);
      //ParamByName('anoSelec').AsString := Format('%.4d', [anoSelecionado]);
      Open;
    end;
    with qrMetodosMes do
    begin
      if qrMT.Active then qrMT.Close;
      if qrMC.Active then qrMC.Close;
      if qrMP.Active then qrMP.Close;
      qrMT.ParamByName('codmet').AsInteger := FieldByName('Cod_Metodo').AsInteger;
      qrMC.ParamByName('codmet').AsInteger := FieldByName('Cod_Metodo').AsInteger;
      qrMP.ParamByName('codmet').AsInteger := FieldByName('Cod_Metodo').AsInteger;
      qrMT.Open;
      qrMC.Open;
      qrMP.Open;
    end;
  end;
end;

procedure TEventosMetodos.GridAnoMetodos(Sender: TObject);
begin
  with formPrincipal do
  begin
    with qrMetodosAno do
    begin
      if Active then Close;
      ParamByName('anoSelec').AsString := Format('%.4d', [anoSelecionado]);
      Open;
      if IsEmpty then
      begin
        grdMetodosMes.Enabled := False;
        grdLinhasMes.Enabled  := False;
      end
      else
      begin
        grdMetodosMes.Enabled := True;
        grdLinhasMes.Enabled  := True;
      end;
    end;
    with qrLinhasAno do
    begin
      if Active then Close;
      ParamByName('CodMetodo').AsInteger :=
        qrMetodosMes.FieldByName('Cod_Metodo').AsInteger;
      ParamByName('anoSelec').AsString   := Format('%.4d', [anoSelecionado]);
      Open;
    end;
  end;
end;

procedure TEventosMetodos.GridAnoLinhas(Sender: TObject);
begin
  with formPrincipal do
  begin
    with qrLinhasAno do
    begin
      if Active then Close;
      ParamByName('CodMetodo').AsInteger :=
        qrMetodosMes.FieldByName('Cod_Metodo').AsInteger;
      ParamByName('anoSelec').AsString   := Format('%.4d', [anoSelecionado]);
      Open;
    end;
  end;
end;

procedure TEventosMetodos.AoExibirMetodos(Sender: TObject);
begin
  with formPrincipal do
  begin
    with qrMetodosMes do
      if not Active then Open
      else
        Refresh;
    with qrMetodosAno do
      if not Active then Open
      else
        Refresh;
  end;
  GridMesLinhas(nil);
end;

end.
