unit untPainel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
  TACustomSeries, TAMultiSeries, DateUtils, untMain, contnrs, fgl;

type

  { TEventosPainel }

  TEventosPainel = class(TformPrincipal)

  public
    procedure tsPainelShow(Sender: TObject);
    procedure btnSalvarBancaInicialClick(Sender: TObject);
    procedure cbPerfilChange(Sender: TObject);
    procedure edtBancaInicialKeyPress(Sender: TObject; var Key: char);
    procedure cbMesChange(Sender: TObject);
    procedure cbAnoChange(Sender: TObject);
    procedure cbGraficosChange(Sender: TObject);
    procedure qrMesCalcFields(DataSet: TDataSet);
    procedure qrAnoCalcFields(DataSet: TDataSet);

    procedure PreencherComboBox;
    procedure PreencherBancaInicial;
    procedure AtualizarGraficoLucro;
    procedure AtualizaMesEAno;
    procedure HabilitaMesEAno(Sender: TObject);
  end;

  TDateDoubleMap = specialize TFPGMap<TDateTime, double>;

implementation

var
  MesDoCB, AnoDoCB: integer;

procedure TEventosPainel.tsPainelShow(Sender: TObject);
begin
  writeln('Exibido painel principal');
  with formPrincipal do
  begin
    with qrBanca do
    begin
      if Active then Close;
      ParamByName('mesSelec').AsInteger := StrToInt(cbMes.Text);
      ParamByName('anoSelec').AsInteger := StrToInt(cbAno.Text);
      Open;
      MudarCorLucro;
    end;

    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'SELECT GestaoPcent FROM "Selecionar Perfil"';
      Open;
      if FieldByName('GestaoPcent').AsBoolean then
      begin
        rbGestPcent.Checked := True;
        GestaoUnidade := False;
      end
      else
      begin
        rbGestUn.Checked := True;
        GestaoUnidade := True;
      end;
    finally
      Free;
    end;
    PerfilDoInvestidor;
    DefinirStake;
  end;
  AtualizarGraficoLucro;
end;



procedure TEventosPainel.btnSalvarBancaInicialClick(Sender: TObject);
var
  mes, ano, mesGreen, mesRed: integer;
  novoValor: double;
  query: TSQLQuery;
begin
  with formPrincipal do
  begin
    writeln('Clicado no botão para salvar dados da banca!');
    writeln('Criando query...');
    query := TSQLQuery.Create(nil);
    writeln('Definindo banco de dados do query...');
    query.DataBase := conectBancoDados;
    writeln('Lendo o edit para salvar na variável...');
    if edtBancaInicial.Text <> '' then
      novoValor := StrToFloat(edtBancaInicial.Text)
    else
      novoValor := 0.00;

    writeln('Verificando se o mês e ano são válidos...');
    if TryStrToInt(cbMes.Text, mes) and TryStrToInt(cbAno.Text, ano) then
    begin
      try

        if not conectBancoDados.Connected then
        begin
          writeln('Conectando com o banco de dados...');
          conectBancoDados.Connected := True;
        end;
        if qrBanca.RecordCount = 0 then
        begin
          writeln(
            'Não tem valor na tabela Banca com mês e ano selecionados, inserindo novos dados');
          query.Close;
          query.SQL.Text :=
            'INSERT INTO "Banca" ("Mês", "Ano", "Valor_Inicial", "Stake") ' +
            'SELECT :mes, :ano, :valorInicial, :stake ' +
            'WHERE NOT EXISTS (SELECT 1 FROM "Banca" WHERE "Mês" = :mes AND "Ano" = :ano);';
          writeln('Inserido texto SQL no query: ' + query.SQL.Text);
          writeln('Definindo o parâmetro "mês" do query como ', mes);
          query.ParamByName('mes').AsInteger := mes;
          writeln('Definindo o parâmetro "ano" do query como ', ano);
          query.ParamByName('ano').AsInteger := ano;
          writeln('Definindo parâmetro "valorInicial" do query como ', novoValor);
          query.ParamByName('valorInicial').AsFloat := novoValor;
          writeln('Definindo parâmetro "stake" do query como ', stakeAposta);
          query.ParamByName('stake').AsFloat := stakeAposta;
          writeln('Executando ExecSQL');
          query.ExecSQL;
        end
        else if TryStrToFloat(edtBancaInicial.Text, novoValor) then
        begin
          writeln('Já existe valor no mês e ano selecionados, atualizando');
          query.Close;
          query.SQL.Text :=
            'UPDATE "Banca" SET "Valor_Inicial" = :novoValor, "Stake" = :stake WHERE "Mês" = :mesSelecionado AND "Ano" = :anoSelecionado';
          writeln('Inserido texto SQL no query: ' + query.SQL.Text);
          writeln('Definindo parâmetro "novoValor" do query como ', novoValor);
          query.ParamByName('novoValor').AsFloat := novoValor;
          writeln('Definindo parâmetro "stake" do query como ', stakeAposta);
          query.ParamByName('stake').AsFloat := stakeAposta;
          writeln('Definindo o parâmetro "mesSelecionado" do query como ', mes);
          query.ParamByName('mesSelecionado').AsInteger := mes;
          writeln('Definindo o parâmetro "anoSelecionado" do query como ', ano);
          query.ParamByName('anoSelecionado').AsInteger := ano;
          writeln('Executando ExecSQL');
          query.ExecSQL;
        end;
        writeln('Alterando o valor ', valorInicial, ' para ', novoValor);
        valorInicial := novoValor;
        writeln('Salvando mudanças no banco de dados');
        mesSelecionado := StrToInt(cbMes.Text);
        anoSelecionado := StrToInt(cbAno.Text);
        transactionBancoDados.CommitRetaining;
        DefinirStake;
        qrBanca.Refresh;
        ShowMessage('Valor da banca para ' + IntToStr(mesSelecionado) +
          '/' + IntToStr(anoSelecionado) + ' salvo com sucesso!');
      except
        on E: Exception do
        begin
          MessageDlg('Erro',
            'Erro ao salvar dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          writeln('Ocorreu um erro: ' + E.Message +
            ' Revertendo mudanças no banco de dados');
          transactionBancoDados.Rollback;
        end;
      end;
    end
    else
    begin
      MessageDlg('Erro', 'Informe um mês e um ano válidos!', mtError, [mbOK], 0);
    end;
    with query do
    try
      Close;
      SQL.Text :=
        'select Valor_Inicial from Banca where Mês = :MesSelecionado and Ano = :AnoSelecionado';
      ParamByName('MesSelecionado').AsInteger := mesSelecionado;
      ParamByName('AnoSelecionado').AsInteger := anoSelecionado;
      Open;
    finally
      Free;
    end;
    //perfilInvestidor := cbPerfil.Text;
    //txtStake.DataField := qrBanca.FieldByName('R$Stake').AsString;
    MudarCorLucro;
    AtualizarGraficoLucro;
  end;
end;

procedure TEventosPainel.cbPerfilChange(Sender: TObject);
var
  query: TSQLQuery;
begin
  with formPrincipal do
  begin
    perfilInvestidor := cbPerfil.Text;
    try
      query := TSQLQuery.Create(nil);
      try
        query.DataBase := conectBancoDados;
        query.Close;
        query.SQL.Text :=
          'UPDATE "Selecionar Perfil" SET "Perfil Selecionado" = :perfilSelecionado';
        query.ParamByName('perfilSelecionado').AsString := perfilInvestidor;
        query.ExecSQL;
        transactionBancoDados.CommitRetaining;
      except
        on E: Exception do
        begin
          writeln('Erro ao atualizar perfil: ' + E.Message);
          transactionBancoDados.RollbackRetaining;
        end;
      end;
    finally
      query.Free;
    end;
    DefinirStake;
    PerfilDoInvestidor;
    writeln('Definido perfil como ', perfilInvestidor);
    ReiniciarTodosOsQueries;
    AtualizarGraficoLucro;
  end;
end;

procedure TEventosPainel.edtBancaInicialKeyPress(Sender: TObject; var Key: char);
begin
  if FormatSettings.DecimalSeparator = ',' then
    if Key = '.' then
      Key := ','
    else if FormatSettings.DecimalSeparator = '.' then
      if Key = ',' then
        Key := '.';
end;

procedure TEventosPainel.PreencherComboBox;
var
  itemCBPerfil: string;
  i, anoAtual: integer;
begin
  with formPrincipal do
  begin
    writeln('Habilitando queries que estiverem desabilitados...');
    if not qrBanca.Active then qrBanca.Open;
    if not qrPerfis.Active then qrPerfis.Open;

    //Adicionar itens no ComboBox Perfil
    cbPerfil.Clear;
    while not qrPerfis.EOF do
    begin
      itemCBPerfil := qrPerfis.FieldByName('Perfil').AsString;
      cbPerfil.Items.Add(itemCBPerfil);
      writeln('Adicionado item "', itemCBPerfil, '" no ComboBox "Perfil"');
      qrPerfis.Next;
    end;

    if not qrSelecionarPerfil.Active then qrSelecionarPerfil.Open;
    perfilInvestidor :=
      qrSelecionarPerfil.FieldByName('Perfil Selecionado').AsString;
    cbPerfil.Text := perfilInvestidor;
    writeln('Definido texto do cbPerfil como "', perfilInvestidor, '"');

    //Adicionar itens no ComboBox Ano
    anoAtual := YearOf(Now);
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'SELECT Ano FROM Banca GROUP BY Ano';
      Open;
      First;
      while not EOF do
      begin
        if IsEmpty then
        cbAno.Items.Add(IntToStr(YearOf(Now)))
        else
        cbAno.Items.Add(IntToStr(FieldByName('Ano').AsInteger));
        Next;
      end;
    finally
      Free;
    end;
    writeln('Adicionado(s) ano(s) no ComboBox "Ano"');
    //Adicionar itens no ComboBox Mês
    cbMes.ItemIndex := cbMes.Items.IndexOf(IntToStr(MonthOf(Now)));
    writeln('Definido mês padrão como ' + cbMes.Text);

    //Adicionar itens no ComboBox Ano
    cbAno.ItemIndex := cbAno.Items.IndexOf(IntToStr(anoAtual));
    writeln('definido ano padrão como ' + cbAno.Text);

    //Definir as variáveis mesSelecionado e anoSelecionado de acordo com o texto do ComboBox
    writeln('Mês selecionado: ',cbMes.Text);
    mesSelecionado := StrToInt(cbMes.Text);
    writeln('Ano Selecionado: ',cbAno.Text);
    anoSelecionado := StrToInt(cbAno.Text);
  end;
end;

procedure TEventosPainel.PreencherBancaInicial;
var
  query: TSQLQuery;
  i: integer;
begin
  with formPrincipal do
  begin
    try
      query := TSQLQuery.Create(nil);
      query.DataBase := conectBancoDados;
      query.SQL.Text :=
        'select Valor_Inicial from Banca where Mês = :MesSelecionado and Ano = :AnoSelecionado';
      query.ParamByName('MesSelecionado').AsInteger := mesSelecionado;
      query.ParamByName('AnoSelecionado').AsInteger := anoSelecionado;
      query.Open;

      if not query.IsEmpty then
        valorInicial := query.FieldByName('Valor_Inicial').AsFloat
      else
        valorInicial := 0;
      edtBancaInicial.Text := FloatToStr(valorInicial);
    finally
      query.Free;
    end;
  end;
end;

procedure TEventosPainel.AtualizarGraficoLucro;
var
  i, j, Contador, anoGreen, anoRed, mesGreen, mesRed, diaGreen, diaRed,
  anoNeutro, mesNeutro, diaNeutro, MaxInt, MinInt: integer;
  ContFloat, LAP, LAR, LAPA, LARA: double;
begin
  writeln('Atualizando gráficos do painel principal');
  with formPrincipal do
  begin
    writeln('Limpando gráficos');
    (chrtLucroMes.Series[0] as TLineSeries).Clear;
    (chrtLucroAno.Series[0] as TLineSeries).Clear;
    (chrtLucroTodosAnos.Series[0] as TLineSeries).Clear;

    {*********************************LUCRO DO MÊS*********************************}
    try
      writeln('Abrindo query');
      if not qrMes.Active then qrMes.Open
      else
        qrMes.Refresh;
      //if qrMes.RecordCount = 0 then Exit;

      writeln('Registros encontrados para o mês: ' + IntToStr(qrMes.RecordCount));

      case cbGraficos.Text of

        'Lucro R$':
        begin
          writeln('alterando gráfico do mês para porcentagem');
          chrtLucroMes.AxisList[1].Marks.Format := '%0:.2m';
          writeln('Limpando gráfico');
          (chrtLucroMes.Series[0] as TLineSeries).Clear;
          writeln('Abrindo qrMes');
          if not qrMes.Active then qrMes.Open;
          writeln('Preenchendo gráfico do mês');
          for i := 1 to 31 do
          begin
            ContFloat := i;
            if i < qrMes.FieldByName('Dia').AsInteger then
              (chrtLucroMes.Series[0] as TLineSeries).AddXY(i,
                qrMes.FieldByName('SomaLucro').AsFloat, ContFloat)
            else if i > qrMes.FieldByName('Dia').AsInteger then
            begin
              qrMes.Last;
              (chrtLucroMes.Series[0] as TLineSeries).AddXY(i,
                qrMes.FieldByName('SomaLucro').AsFloat, ContFloat);
              qrMes.First;
            end
            else
            begin
              (chrtLucroMes.Series[0] as TLineSeries).AddXY(
                i,
                qrMes.FieldByName('SomaLucro').AsFloat,
                ContFloat);
              qrMes.Next;
            end;
          end;
        end;

        'Lucro %':
        begin
          chrtLucroMes.AxisList[1].Marks.Format := '%0:.2n%%';
          (chrtLucroMes.Series[0] as TLineSeries).Clear;
          for i := 1 to 31 do
          begin
            ContFloat := i;
            if i < qrMes.FieldByName('Dia').AsInteger then
              (chrtLucroMes.Series[0] as TLineSeries).AddXY(i,
                qrMes.FieldByName('PorCentoLucro').AsFloat, ContFloat)
            else if i > qrMes.FieldByName('Dia').AsInteger then
            begin
              qrMes.Last;
              (chrtLucroMes.Series[0] as TLineSeries).AddXY(i,
                qrMes.FieldByName('PorCentoLucro').AsFloat, ContFloat);
              qrMes.First;
            end
            else
            begin
              (chrtLucroMes.Series[0] as TLineSeries).AddXY(
                i,
                qrMes.FieldByName('PorCentoLucro').AsFloat,
                ContFloat);
              qrMes.Next;
            end;
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        writeln('Falha ao atualizar o gráfico do mês: ' + E.Message);
      end;
    end;

    {******************************************************************************}
    {*********************************LUCRO DO ANO*********************************}
    with qrAno do
    try
      if not Active then Open;
      if RecordCount = 0 then Exit;
      writeln
      ('Registros encontrados para o ano: ' + IntToStr(qrAno.RecordCount));
      begin
        if cbGraficos.Text = 'Lucro %' then
        begin
          chrtLucroAno.AxisList[0].Marks.Format := '%0:.2n%%';
          First;
          LAP := FieldByName('LucroTotalPorCento').AsFloat;
          for Contador := 1 to 12 do
            with (chrtLucroAno.Series[0] as TLineSeries) do
            begin
              ContFloat := Contador;
              if Contador <= FieldByName('Mês').AsInteger then
                AddXY(Contador, 0, ContFloat)
              else
              begin
                Next;
                if not EOF then
                  LAP := LAP + FieldByName('LucroTotalPorCento').AsFloat
                else
                  LAP := LAP;
                AddXY(Contador, LAP, ContFloat);
              end;
            end;
        end
        else if cbGraficos.Text = 'Lucro R$' then
        begin
          chrtLucroAno.AxisList[0].Marks.Format := '%0:.2m';
          First;
          LAR := FieldByName('LucroAnualReais').AsFloat;
          for Contador := 1 to 12 do
            with (chrtLucroAno.Series[0] as TLineSeries) do
            begin
              ContFloat := Contador;
              if Contador <= FieldByName('Mês').AsInteger then
                AddXY(Contador, 0, ContFloat)
              else
              begin
                Next;
                if not EOF then
                  LAR := LAR + FieldByName('LucroAnualReais').AsFloat
                else
                  LAR := LAR;
                AddXY(Contador, LAR, ContFloat);
              end;
            end;
        end;
      end;
    except
      on E: Exception do
      begin
        writeln('Falha ao atualizar o gráfico de lucro do ano: ' + E.Message);
      end;
    end;
    chrtLucroMes.Invalidate;
    chrtLucroAno.Invalidate;

    {******************************************************************************}
    {****************************LUCRO DE TODOS OS ANOS****************************}

    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text :=
        'SELECT Banca.Mês, Banca.Ano,                               ' +
        'SUM(Banca.Valor_Final - Banca.Valor_Inicial) / COUNT(*)    ' +
        'AS lcrAnosReais,                                           ' +
        '(SUM(Banca.Valor_Final - Banca.Valor_Inicial) /            ' +
        'SUM(CASE WHEN Banca.Valor_Inicial IS NULL THEN 0           ' +
        'ELSE Banca.Valor_Inicial END)) * 100 AS lcrAnosPcent       ' +
        'FROM Banca                                                 ' +
        'LEFT JOIN                                                  ' +
        'Apostas ON strftime(''%m'', Apostas.Data) = Banca.Mês      ' +
        'AND strftime(''%Y'', Apostas.Data) = Banca.Ano             ' +
        'WHERE Banca.Ano = (SELECT Ano FROM "Selecionar Mês e Ano") ' +
        'GROUP BY Banca.Ano;                                        ';
      Open;

      if RecordCount = 0 then Exit;

      with chrtLucroTodosAnos.AxisList[1].Range do
      begin
        First;
        Min := FieldByName('Ano').AsInteger;
        Max := FieldByName('Ano').AsInteger + 10;
        Last;
        if Max < RecordCount then Max := RecordCount;
        MinInt := Round(Min);
        MaxInt := Round(Max);
        writeln('Valor mínimo: ', MinInt);
        writeln('Valor Máximo: ', MaxInt);
      end;

      if cbGraficos.Text = 'Lucro %' then
      begin
        chrtLucroTodosAnos.AxisList[0].Marks.Format := '%0:.2n%%';
        First;
        LAPA := FieldByName('lcrAnosPcent').AsFloat;
        with chrtLucroTodosAnos.AxisList[1].Range do
          with (chrtLucroTodosAnos.Series[0] as TLineSeries) do
            for Contador := MinInt to MaxInt do
            begin
              ContFloat := Contador;
              if Contador < FieldByName('Ano').AsInteger then
              begin
                AddXY(Contador, 0, ContFloat);
              end
              else
              begin
                Next;
                if not EOF then
                begin
                  if (LAPA < 0) and (FieldByName('lcrAnosPcent').AsFloat < 0) then
                    LAPA := LAPA - FieldByName('lcrAnosPcent').AsFloat
                  else
                    LAPA := LAPA + FieldByName('lcrAnosPcent').AsFloat;
                  AddXY(Contador, LAPA, ContFloat);
                end
                else
                begin
                  AddXY(Contador, LAPA, ContFloat);
                end;
              end;
            end;
      end
      else if cbGraficos.Text = 'Lucro R$' then

      begin
        chrtLucroTodosAnos.AxisList[0].Marks.Format := '%0:.2m';
        First;
        LARA := FieldByName('lcrAnosReais').AsFloat;
        with chrtLucroTodosAnos.AxisList[1].Range do
          with (chrtLucroTodosAnos.Series[0] as TLineSeries) do
            for Contador := MinInt to MaxInt do
            begin
              ContFloat := Contador;
              if Contador <= FieldByName('Mês').AsInteger then
                AddXY(Contador, 0, ContFloat)
              else
              begin
                Next;
                if not EOF then
                begin
                  if (LARA < 0) and (FieldByName('lcrAnosReais').AsFloat < 0) then
                    LARA := LARA - FieldByName('lcrAnosReais').AsFloat
                  else
                    LARA := LARA + FieldByName('lcrAnosReais').AsFloat;
                  AddXY(Contador, LARA,
                    ContFloat);
                end
                else
                begin
                  AddXY(Contador, LARA, ContFloat);
                end;
              end;
            end;
      end;
      Free;
    except
      on E: Exception do
      begin
        writeln('Falha ao atualizar o gráfico de lucro de todos os anos: ' +
          E.Message);
        Free;
      end;
    end;
    chrtLucroTodosAnos.Invalidate;

    {******************************************************************************}
    {*********************************GRÁFICOS PIZZA*******************************}

    try
      (chrtAcertMes.Series[0] as TPieSeries).Clear;
      (chrtAcertAno.Series[0] as TPieSeries).Clear;
      if qrMes.RecordCount = 0 then Exit;

      writeln('Registros encontrados para colocar no gráfico de greens e reds: ' +
        IntToStr(qrMes.RecordCount));
      diaGreen := 0;
      diaRed := 0;
      diaNeutro := 0;

      //Gráfico pizza do mês
      with qrMes do
        for i := 0 to RecordCount - 1 do
        begin
          RecNo := i + 1;
          diaGreen := diaGreen + FieldByName('Green').AsInteger;
          diaRed := diaRed + FieldByName('Red').AsInteger;
          diaNeutro := diaNeutro + FieldByName('Neutro').AsInteger;
        end;
      with (chrtAcertMes.Series[0] as TPieSeries) do
      begin
        if diaGreen <> 0 then
          AddPie(diaGreen, IntToStr(diaGreen) + ' Dias Bons,', clGreen);

        if diaRed <> 0 then
          AddPie(diaRed, IntToStr(diaRed) + ' Dias Ruins,', clRed);

        if diaNeutro <> 0 then
          AddPie(diaNeutro, IntToStr(diaNeutro) + ' Dias Neutros,', clGray);
      end;

      //Gráfico pizza do ano
      with TSQLQuery.Create(nil) do
      try
        DataBase := conectBancoDados;
        SQL.Text :=
          'SELECT                                                                  ' +
          'ROUND(COALESCE(                                                         ' +
          '(SELECT SUM(Lucro)                                                      ' +
          'FROM Apostas                                                            ' +
          'WHERE strftime(''%m'', Apostas.Data) = Banca.Mês                          ' +
          'AND strftime(''%Y'', Apostas.Data) = Banca.Ano), 0), 2) AS Lucro,         ' +
          'ROUND(                                                                  ' +
          'CASE                                                                    ' +
          'WHEN Valor_Inicial = 0 THEN 0                                           ' +
          'ELSE COALESCE(                                                          ' +
          '(SELECT SUM(Lucro)                                                      ' +
          'FROM Apostas                                                            ' +
          'WHERE strftime(''%m'', Apostas.Data) = Banca.Mês                          ' +
          'AND strftime(''%Y'', Apostas.Data) = Banca.Ano), 0) / Valor_Inicial * 100 ' +
          'END, 2) AS "Lucro_%"                                                   ' +
          'FROM Banca                                                              ' +
          'WHERE Ano = :ano                                                        ';
        ParamByName('Ano').AsInteger := anoSelecionado;
        Open;
        with (chrtAcertAno.Series[0] as TPieSeries) do
        begin
          Clear;
          mesGreen := 0;
          mesRed := 0;
          mesNeutro := 0;
          First;
          for j := 0 to RecordCount - 1 do
          begin
            RecNo := j + 1;

            if (FieldByName('Lucro').AsFloat) < 0 then
              mesRed := mesRed + 1
            else if (FieldByName('Lucro').AsFloat) > 0 then
              mesGreen := mesGreen + 1
            else
              mesNeutro := mesNeutro + 1;
          end;
          if mesGreen <> 0 then
            AddPie(mesGreen, IntToStr(mesGreen) + ' Meses Bons,', clGreen);

          if mesRed <> 0 then
            AddPie(mesRed, IntToStr(mesRed) + ' Meses Ruins,', clRed);

          if mesNeutro <> 0 then
            AddPie(mesNeutro, IntToStr(mesNeutro) + ' Meses Neutros,', clGray);
        end;
        Free;
      except
        On E: Exception do
        begin
          Free;
          raise Exception.Create(E.Message);
        end;
      end;

      //Gráfico de Assertividade Todos os Anos
      writeln('Mudando gráfico de assertividade de todos os anos');
      with TSQLQuery.Create(nil) do
      try
        DataBase := conectBancoDados;
        writeln('Definindo o SQL do Query');
        SQL.Text :=
          'WITH SomaValores AS (                                         ' +
          'SELECT                                                        ' +
          'Ano, SUM(Valor_Final) AS SomaValorFinal, SUM(Valor_Inicial)   ' +
          'AS SomaValorInicial                                           ' +
          'FROM Banca GROUP BY Ano)                                      ' +
          'SELECT                                                        ' +
          'COUNT(CASE WHEN SomaValorFinal > SomaValorInicial THEN 1 END) ' +
          'AS AnoGreen,                                                  ' +
          'COUNT(CASE WHEN SomaValorFinal < SomaValorInicial THEN 1 END) ' +
          'AS AnoRed,                                                    ' +
          'COUNT(CASE WHEN SomaValorFinal = SomaValorInicial THEN 1 END) ' +
          'AS AnoNeutro                                                  ' +
          'FROM SomaValores                                              ';
        Open;
        First;

        writeln('Verificando situação de cada ano');

        anoGreen := FieldByName('AnoGreen').AsInteger;
        anoRed := FieldByName('AnoRed').AsInteger;
        anoNeutro := FieldByName('AnoNeutro').AsInteger;

        writeln('Adicionando dados no gráfico');
        with (chrtAcertTodosAnos.Series[0] as TPieSeries) do
        begin
          Clear;
          if anoGreen <> 0 then
            AddPie(anoGreen, IntToStr(anoGreen) + ' Anos Bons,', clGreen);
          if anoRed <> 0 then
            AddPie(anoRed, IntToStr(anoRed) + ' Anos Ruins,', clRed);
          if anoNeutro <> 0 then
            AddPie(anoNeutro, IntToStr(anoNeutro) + ' Anos Neutros,', clGray);
        end;
        Free;
      except
        on E: Exception do
          raise Exception.Create('Erro no gráfico de assertividade de todos os anos, ' +
            E.Message);
      end;
    except
      on E: Exception do
      begin
        writeln('Falha ao atualizar os gráficos: ' + E.Message);
      end;
    end;
    {******************************************************************************}

    chrtAcertMes.Invalidate;
    chrtAcertAno.Invalidate;
    chrtAcertTodosAnos.Invalidate;
    qrMesesGreenRed.Close;
    qrMes.Close;
    qrAno.Close;
  end;
end;

procedure TEventosPainel.cbGraficosChange(Sender: TObject);
begin
  AtualizarGraficoLucro;
end;

procedure TEventosPainel.AtualizaMesEAno;
var
  query: TSQLQuery;
label
  AoMudar, AtualizaNoBD, Fim;
begin
  writeln('Tentando atualizar mês e ano');
  with formPrincipal do
  begin
    MesDoCB := StrToInt(cbMes.Text);
    AnoDoCB := StrToInt(cbAno.Text);

    writeln('Mês e ano nos ComboBoxes: ', MesDoCB, '/', AnoDoCB);

    mesSelecionado := MonthOf(now);
    anoSelecionado := YearOf(now);
    if (MesDoCB <> mesSelecionado) or (AnoDoCB <> anoSelecionado) then goto AoMudar
    else
      goto AtualizaNoBD;

    AtualizaNoBD:
      try
        query := TSQLQuery.Create(nil);
        writeln('Criado query');
        query.Database := conectBancoDados;
        writeln('Definido banco de dados do query');
        query.SQL.Text :=
          'UPDATE "Selecionar Mês e Ano" SET Mês = :mesSelec, Ano = :anoSelec WHERE rowid = 1;';
        writeln('Inserido texto SQL no query');
        query.ParamByName('mesSelec').AsInteger := mesSelecionado;
        query.ParamByName('anoSelec').AsInteger := anoSelecionado;
        writeln('Dando ExecSQL com as variáveis ', mesSelecionado, '/', anoSelecionado);
        query.ExecSQL;
        transactionBancoDados.CommitRetaining;
        query.Free;
      except
        on E: Exception do
        begin
          writeln('Erro ao salvar mês e ano selecionados: ' + E.Message);
          transactionBancoDados.Rollback;
        end;
      end;
    goto Fim;

    AoMudar:
      writeln('Mês e ano dos ComboBoxes: ', MesDoCB, '/', AnoDoCB);
    mesSelecionado := StrToInt(cbMes.Text);
    anoSelecionado := StrToInt(cbAno.Text);
    writeln('Mudados mês e ano das variáveis para ', mesSelecionado,
      '/', anoSelecionado);
    goto AtualizaNoBD;

    Fim: ;
  end;
end;

procedure TEventosPainel.HabilitaMesEAno(Sender: TObject);
begin
  with formPrincipal do
  begin
    qrMes.Open;
    qrAno.Open;
  end;
end;

procedure TEventosPainel.cbMesChange(Sender: TObject);
begin
  AtualizaMesEAno;
  AtualizarGraficoLucro;
  with formPrincipal do
  begin
    qrBanca.Close;
    qrBanca.ParamByName('mesSelec').AsInteger := StrToInt(cbMes.Text);
    qrBanca.ParamByName('anoSelec').AsInteger := StrToInt(cbAno.Text);
    qrBanca.Open;
    edtBancaInicial.Text := FloatToStr(qrBanca.FieldByName('Valor_Inicial').AsFloat);
    MudarCorLucro;
  end;
end;

procedure TEventosPainel.cbAnoChange(Sender: TObject);
begin
  AtualizaMesEAno;
  AtualizarGraficoLucro;
  with formPrincipal do
  begin
    qrBanca.Close;
    qrBanca.ParamByName('mesSelec').AsInteger := StrToInt(cbMes.Text);
    qrBanca.ParamByName('anoSelec').AsInteger := StrToInt(cbAno.Text);
    qrBanca.Open;
    edtBancaInicial.Text := FloatToStr(qrBanca.FieldByName('Valor_Inicial').AsFloat);
    MudarCorLucro;
  end;
end;

procedure TEventosPainel.qrMesCalcFields(DataSet: TDataSet);
begin

 { if DataSet.FieldByName('PorCentoLucro').DataType in [ftFloat, ftCurrency] then
    DataSet.FieldByName('LucroCalculado').AsString :=
      FormatFloat('#0.##%', DataSet.FieldByName('PorCentoLucro').AsFloat);


  if DataSet.FieldByName('SomaLucro').DataType in [ftFloat, ftCurrency] then
    DataSet.FieldByName('LucroMoedaCalculado').AsString :=
      'R$ ' + FormatFloat('#,##0.00', DataSet.FieldByName('SomaLucro').AsFloat);}
end;

procedure TEventosPainel.qrAnoCalcFields(DataSet: TDataSet);
begin

end;

end.
