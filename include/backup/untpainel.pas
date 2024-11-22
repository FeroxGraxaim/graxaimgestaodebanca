unit untPainel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
  TACustomSeries, TAMultiSeries, DateUtils, untMain, contnrs, fgl, Math;

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
    procedure FazerAporte(Sender: TObject);
    procedure AlterarBancaInicial(Sender: TObject);
    procedure RetirarDinheiro(Sender: TObject);
    procedure AtualizaDadosBanca(DataSet: TDataSet);
    procedure VerificaBancaAntiga;
    procedure AtualizaBanca;
    procedure ParametrosBanca(DataSet: TDataSet);
  end;

  TDateDoubleMap = specialize TFPGMap<TDateTime, double>;

implementation

uses untApostas;

var
  MesDoCB, AnoDoCB: integer;

procedure TEventosPainel.tsPainelShow(Sender: TObject);
begin
  writeln('Exibido painel principal');
  with formPrincipal do
  begin
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
  end;
  AtualizarGraficoLucro;
end;



procedure TEventosPainel.btnSalvarBancaInicialClick(Sender: TObject);
var
  mes, ano: integer;
  novoValor: double;
  query: TSQLQuery;
  entrada: string;
label
  Valor, Fim;
begin
  with formPrincipal do
  begin
    writeln('Clicado no botão para salvar dados da banca!');
    query := TSQLQuery.Create(nil);
    query.DataBase := conectBancoDados;
    writeln('Lendo o edit para salvar na variável...');
    if qrBanca.FieldByName('Valor_Inicial').AsFloat <> 0 then
      novoValor := valorInicial
    else
      novoValor := 0.00;

    writeln('Verificando se o mês e ano são válidos...');
    if TryStrToInt(cbMes.Text, mes) and TryStrToInt(cbAno.Text, ano) then
    begin
      try
        if not conectBancoDados.Connected then
          conectBancoDados.Connected := True;

        if qrBanca.RecordCount = 0 then
        begin
          writeln(
            'Não tem valor na tabela Banca com mês e ano selecionados, ' +
            'inserindo novos dados');
          query.Close;
          query.SQL.Text :=
            'INSERT INTO "Banca" ("Mês", "Ano", "Valor_Inicial") ' +
            'SELECT :mes, :ano, :valorInicial ' +
            'WHERE NOT EXISTS (SELECT 1 FROM "Banca" WHERE "Mês" = :mes AND ' +
            '"Ano" = :ano);';
          query.ParamByName('mes').AsInteger := mes;
          query.ParamByName('ano').AsInteger := ano;
          query.ParamByName('valorInicial').AsFloat := novoValor;
          query.ExecSQL;
        end
        else
        if qrBanca.FieldByName('Valor_Inicial').AsFloat <> 0 then
          if MessageDlg('AVISO:' + sLineBreak + sLineBreak +
            'A banca inicial já está preenchida, caso tenha ' +
            'adicionado mais dinheiro à banca, favor usar o botão ' +
            '"Fazer Aporte". Se alterar a banca inicial, o cálculo dos ' +
            'gráficos será incorreto. Só é recomendado alterar a banca ' +
            'inicial caso haja um erro no valor.' + sLineBreak +
            'Deseja alterar o valor mesmo assim?', mtWarning, [mbYes, mbNo], 0) =
            mrYes then goto Valor
          else
            goto Fim;

        Valor:

          if InputQuery('Inserir Valor', 'Insira o valor da tua banca na casa ' +
          'de apostas que tu operas:', Entrada) then
            if TryStrToFloat(Entrada, novoValor) then
              with query do
              begin
                writeln('Já existe valor no mês e ano selecionados, atualizando');
                SQL.Text :=
                  'UPDATE "Banca" SET "Valor_Inicial" = :novoValor ' +
                  'WHERE "Mês" = :mesSelecionado AND "Ano" = :anoSelecionado';
                ParamByName('novoValor').AsFloat := novoValor;
                ParamByName('mesSelecionado').AsInteger := mes;
                ParamByName('anoSelecionado').AsInteger := ano;
                ExecSQL;
              end
            else
            begin
              MessageDlg('Erro', 'O valor inserido não é numérico!',
              mtError, [mbOK], 0);
              goto Valor;
            end;
        transactionBancoDados.CommitRetaining;
        valorInicial := novoValor;
        mesSelecionado := StrToInt(cbMes.Text);
        anoSelecionado := StrToInt(cbAno.Text);
        qrBanca.Close;
        qrBanca.Open;

        Fim: ;
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
      MessageDlg('Erro', 'Informe um mês e um ano válidos!', mtError, [mbOK], 0);
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
    CalculaDadosAposta;
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
    //DefinirStake;
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
      if IsEmpty then
        cbAno.Items.Add(IntToStr(YearOf(Now)))
      else
        while not EOF do
        begin
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
    writeln('Mês selecionado: ', cbMes.Text);
    mesSelecionado := StrToInt(cbMes.Text);
    writeln('Ano Selecionado: ', cbAno.Text);
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
        'select Valor_Inicial , Aporte ' +
        'from Banca where Mês = :MesSelecionado and Ano = :AnoSelecionado';
      query.ParamByName('MesSelecionado').AsInteger := mesSelecionado;
      query.ParamByName('AnoSelecionado').AsInteger := anoSelecionado;
      query.Open;

      if not query.IsEmpty then
      begin
        valorInicial := query.FieldByName('Valor_Inicial').AsFloat;
        Aporte := query.FieldByName('Aporte').AsFloat;
      end
      else
        valorInicial := 0;
      //edtBancaInicial.Text := FloatToStr(valorInicial);
    finally
      query.Free;
    end;
  end;
end;

procedure TEventosPainel.AtualizarGraficoLucro;
var
  i, j, Contador, anoGreen, anoRed, mesGreen, mesRed, diaGreen, diaRed,
  anoNeutro, mesNeutro, diaNeutro, MaxInt, MinInt, Mes: integer;
  ContFloat, LAP, LAR, LAPA, LARA, SomaLucro, ValInicio, Aporte,
  TotInvest, LucroPcent, BancaFinal, LMP, LMR: double;
  LucroStr: string;
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

      writeln('Registros encontrados para o mês: ' + IntToStr(qrMes.RecordCount));

      case cbGraficos.Text of

        'Lucro R$':
          with qrMes do
          begin
            writeln('alterando gráfico do mês para porcentagem');
            chrtLucroMes.AxisList[1].Marks.Format := '%0:.2m';
            First;
            if RecordCount <> 0 then
              with (chrtLucroMes.Series[0] as TLineSeries) do
                for i := 1 to 31 do
                begin
                  ContFloat := i;
                  if i <= FieldByName('Dia').AsInteger then
                    LMR := FieldByName('SomaLucro').AsFloat
                  else
                  if not EOF then
                  begin
                    Next;
                    LMR := FieldByName('SomaLucro').AsFloat;
                  end;
                  AddXY(i, LMR, ContFloat);
                end;
          end;

        'Lucro %':
        begin
          chrtLucroMes.AxisList[1].Marks.Format := '%0:.2n%%';
          if qrMes.RecordCount <> 0 then
            with (chrtLucroMes.Series[0] as TLineSeries) do
              with qrMes do
              begin
                First;
                LMP := FieldByName('PorCentoLucro').AsFloat;
                for i := 1 to 31 do
                begin
                  ContFloat := i;
                  if i <= FieldByName('Dia').AsInteger then
                    LMP := FieldByName('PorCentoLucro').AsFloat
                  else
                  if not EOF then
                  begin
                    Next;
                    LMP := LMP + FieldByName('PorCentoLucro').AsFloat;
                  end;
                  AddXY(i, LMP, ContFloat);
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
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      begin
        case cbGraficos.Text of
          'Lucro %':
          begin
            SQL.Text :=
              'SELECT                                                         ' +
              'IFNULL(SUM(Apostas.Lucro) / (Valor_Inicial + Aporte), 0) * 100 ' +
              'AS LucroTotal                                                  ' +
              'FROM Banca                                                     ' +
              'LEFT JOIN Apostas                                              ' +
              'ON strftime(''%Y'', Apostas.Data) = Banca.Ano                  ' +
              'AND strftime(''%m'', Apostas.Data) = Banca.Mês                 ' +
              'WHERE Banca.Mês = :contagem                                    ' +
              'AND Banca.Ano = (SELECT Ano FROM "Selecionar Mês e Ano");      ';

            chrtLucroAno.AxisList[0].Marks.Format := '%0:.2n%%';
            Mes := 0;
            LAP := 0;
            for Contador := 1 to 12 do
            begin
              ParamByName('contagem').AsInteger := Contador;
              Open;
              ContFloat := Contador;
              with (chrtLucroAno.Series[0] as TLineSeries) do
              begin
                if not IsEmpty then
                  LAP := LAP + Fields[0].AsFloat
                else
                  LAP := LAP + 0;
                AddXY(Contador, LAP, ContFloat);
              end;
              Close;
            end;
          end;
          'Lucro R$':
          begin

            SQL.Text :=
              'SELECT                                                         ' +
              'IFNULL(SUM(Apostas.Lucro), 0)                                  ' +
              'AS LucroTotal                                                  ' +
              'FROM Banca                                                     ' +
              'LEFT JOIN Apostas                                              ' +
              'ON strftime(''%Y'', Apostas.Data) = Banca.Ano                  ' +
              'AND strftime(''%m'', Apostas.Data) = Banca.Mês                 ' +
              'WHERE Banca.Mês = :contagem                                    ' +
              'AND Banca.Ano = (SELECT Ano FROM "Selecionar Mês e Ano");      ';

            chrtLucroAno.AxisList[0].Marks.Format := '%0:.2m';

            LAR := 0;
            for Contador := 1 to 12 do
              with (chrtLucroAno.Series[0] as TLineSeries) do
              begin
                ParamByName('contagem').AsInteger := Contador;
                Open;
                ContFloat := Contador;
                if not IsEmpty or not Fields[0].IsNull then
                try
                  LAR := LAR + Fields[0].AsFloat;
                except
                  LAR := LAR + 0;
                end;
                AddXY(Contador, LAR, ContFloat);
                Close;
              end;
          end;
        end;
      end;
      Free;
    except
      on E: Exception do
      begin
        Free;
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
      SQL.Text := 'SELECT Ano FROM Banca GROUP BY Ano ORDER BY Ano';
      Open;
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
      case cbGraficos.Text of

        'Lucro %':

        begin
          Close;
          SQL.Text :=
            'SELECT                                                         ' +
            'Banca.Ano,                                                     ' +
            'IFNULL(Banca.Valor_Inicial, 0) AS ValorInicial,                ' +
            '(SELECT SUM(IFNULL(Aporte, 0))                                 ' +
            'FROM Banca WHERE Ano = Banca.Ano) AS Aporte,                   ' +
            '(SELECT SUM(IFNULL(Apostas.Lucro, 0)) FROM Apostas             ' +
            'WHERE Banca.Ano =                                              ' +
            'strftime(''%Y'', Apostas.Data)) AS Lucro                       ' +
            'FROM Banca                                                     ' +
            'GROUP BY Banca.Ano;                                            ';
          Open;
          First;
          SomaLucro := FieldByName('Lucro').AsFloat;
          ValInicio := FieldByName('ValorInicial').AsFloat;
          Aporte := FieldByName('Aporte').AsFloat;
          TotInvest := ValInicio + Aporte;
          BancaFinal := ValInicio + SomaLucro;

          chrtLucroTodosAnos.AxisList[0].Marks.Format := '%0:.2n%%';
          First;
          LAPA := (BancaFinal - TotInvest) / TotInvest * 100;
          if RecordCount <> 0 then
            with chrtLucroTodosAnos.AxisList[1].Range do
              with (chrtLucroTodosAnos.Series[0] as TLineSeries) do
                for Contador := MinInt to MaxInt do
                begin
                  ContFloat := Contador;
                  First;
                  for i := 0 to FieldCount - 1 do
                    if Contador < FieldByName('Ano').AsInteger then
                      AddXY(Contador, 0, ContFloat)
                    else
                    begin
                      Next;
                      AddXY(Contador, LAPA, ContFloat);
                      if not EOF then
                      begin
                        SomaLucro := SomaLucro + FieldByName('Lucro').AsFloat;
                        Aporte := Aporte + FieldByName('Aporte').AsFloat;
                        TotInvest := ValInicio + Aporte;
                        BancaFinal := ValInicio + SomaLucro;
                        LAPA :=
                          LAPA + ((BancaFinal - TotInvest) / TotInvest * 100);
                      end;
                    end;
                end;
        end;
        'Lucro R$':

        begin
          chrtLucroTodosAnos.AxisList[0].Marks.Format := '%0:.2m';
          Close;
          SQL.Text :=
            'SELECT                                                          ' +
            'Banca.Ano,                                                      ' +
            '(SELECT SUM(IFNULL(Apostas.Lucro, 0)) FROM Apostas WHERE        ' +
            'Banca.Ano = strftime(''%Y'', Apostas.Data)) AS Lucro            ' +
            'FROM Banca                                                      ' +
            'GROUP BY Banca.Ano;                                             ';
          Open;
          First;
          LARA := FieldByName('Lucro').AsFloat;
          with chrtLucroTodosAnos.AxisList[1].Range do
            with (chrtLucroTodosAnos.Series[0] as TLineSeries) do
              if RecordCount <> 0 then
                for Contador := MinInt to MaxInt do
                begin
                  ContFloat := Contador;
                  if Contador < FieldByName('Ano').AsInteger then
                    AddXY(Contador, 0, ContFloat)
                  else
                  begin
                    AddXY(Contador, LARA, ContFloat);
                    Next;
                    if not EOF then
                    begin
                      LARA := LARA + FieldByName('Lucro').AsFloat;
                    end;
                    Next;
                  end;
                end;
        end;
      end;
      Free;
    except
      on E: Exception do
      begin
        writeln('Falha ao atualizar o gráfico de lucro de todos os anos: ' +
          E.Message + ' SQL: ' + SQL.Text);
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
        if RecordCount <> 0 then
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
          'SELECT Mês,                                                        ' +
          'CASE WHEN IFNULL((SELECT SUM(Lucro)                                ' +
          'FROM Apostas                                                       ' +
          'WHERE strftime(''%m'', Apostas.Data) = Banca.Mês                   ' +
          'AND strftime(''%Y'', Apostas.Data) = Banca.Ano                     ' +
          'AND Apostas.Lucro IS NOT NULL), 0) > 0 THEN 1 ELSE 0 END AS Green, ' +
          'CASE WHEN IFNULL((SELECT SUM(Lucro)                                ' +
          'FROM Apostas                                                       ' +
          'WHERE strftime(''%m'', Apostas.Data) = Banca.Mês                   ' +
          'AND strftime(''%Y'', Apostas.Data) = Banca.Ano                     ' +
          'AND Apostas.Lucro IS NOT NULL), 0) < 0 THEN 1 ELSE 0 END AS Red,   ' +
          'CASE WHEN (SELECT SUM(Lucro)                                       ' +
          'FROM Apostas                                                       ' +
          'WHERE strftime(''%m'', Apostas.Data) = Banca.Mês                   ' +
          'AND strftime(''%Y'', Apostas.Data) = Banca.Ano                     ' +
          'AND (Apostas.Status <> ''Pré-live'' AND Apostas.Lucro = 0)) = 0    ' +
          'THEN 1 ELSE 0 END AS Neutro                                        ' +
          'FROM Banca                                                         ' +
          'WHERE Ano = :Ano                                                   ' +
          'ORDER BY Mês                                                       ';
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
            mesGreen := mesGreen + FieldByName('Green').AsInteger;
            mesRed := mesRed + FieldByName('Red').AsInteger;
            mesNeutro := mesNeutro + FieldByName('Neutro').AsInteger;
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
          'Ano, SUM(Valor_Inicial) + SUM(Apostas.Lucro) AS SomaValorFinal,    ' +
          'SUM(Valor_Inicial)   ' +
          'AS SomaValorInicial                                           ' +
          'FROM Banca                                                    ' +
          'LEFT JOIN Apostas ON strftime(''%Y'', Apostas.Data) = Ano     ' +
          'GROUP BY Ano)                                                 ' +
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

procedure TEventosPainel.FazerAporte(Sender: TObject);
var
  Banca, Aporte, Convert: double;
  Entrada: string;
label
  InserirValor;
begin
  with formPrincipal do
    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      try
        DataBase := conectBancoDados;
        Screen.Cursor := crAppStart;
        writeln('Fazendo aporte');
        SQL.Text := 'SELECT Aporte FROM Banca WHERE Mês = :mesSelec ' +
          'AND Ano = :anoSelec';
        ParamByName('mesSelec').AsInteger := mesSelecionado;
        ParamByName('anoSelec').AsInteger := anoSelecionado;
        Open;
        Aporte := FieldByName('Aporte').AsFloat;
        Close;
        Screen.Cursor := crDefault;
        Entrada := '';
        InserirValor:
          if InputQuery('Inserir Valor', 'Insira o valor do aporte realizado na sua ' +
          'banca:', Entrada) then
          begin
            case FormatSettings.DecimalSeparator of
            '.': if Pos(',', Entrada) > 0 then
                Entrada := StringReplace(Entrada, ',', '.', [rfReplaceAll]);

            ',': if Pos('.', Entrada) > 0 then
                Entrada := StringReplace(Entrada, '.', ',', [rfReplaceAll]);
          end;
            if TryStrToFloat(Entrada, Convert) then
            begin
              Screen.Cursor := crAppStart;
              Aporte := Aporte + Convert;
              SQL.Text := 'UPDATE Banca SET Aporte = :aporte WHERE Mês = :mes ' +
                'AND Ano = :ano';
              ParamByName('aporte').AsFloat := Aporte;
              ParamByName('mes').AsInteger := mesSelecionado;
              ParamByName('ano').AsInteger := anoSelecionado;
              ExecSQL;
              CommitRetaining;
              qrBanca.Refresh;
            end
            else
            begin
              Screen.Cursor := crDefault;
              MessageDlg('Erro', 'Insira um valor numérico!',
              mtError, [mbOK], 0);
              goto InserirValor;
            end;
          end;
      finally
        Screen.Cursor := crDefault;
        Free;
      end;
end;

procedure TEventosPainel.AlterarBancaInicial(Sender: TObject);
begin

end;

procedure TEventosPainel.RetirarDinheiro(Sender: TObject);
var
  Retirada, Aporte: double;
  Entrada: string;
label
  Valor;
begin
  with formPrincipal do
    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      try
        DataBase := conectBancoDados;
        SQL.Text := 'SELECT Aporte FROM Banca WHERE Mês = :mes AND Ano = :ano';
        ParamByName('mes').AsInteger := mesSelecionado;
        ParamByName('ano').AsInteger := anoSelecionado;
        Open;
        Aporte := Fields[0].AsFloat;
        Close;
        Valor:
          if InputQuery('Inserir Valor','Digite o valor que foi retirado da ' +
          'sua banca:', Entrada) then
          begin
            case FormatSettings.DecimalSeparator of
              '.': if Pos(',', Entrada) > 0 then
                  Entrada := StringReplace(Entrada, ',', '.', [rfReplaceAll]);

              ',': if Pos('.', Entrada) > 0 then
                  Entrada := StringReplace(Entrada, '.', ',', [rfReplaceAll]);
            end;
            if TryStrToFloat(Entrada, Retirada) then
            begin
              Screen.Cursor := crAppStart;
              SQL.Text := 'UPDATE Banca SET Aporte = :retirada WHERE Mês = :mes AND ' +
                'Ano = :ano';
              ParamByName('retirada').AsFloat := Aporte - Retirada;
              ParamByName('mes').AsInteger := mesSelecionado;
              ParamByName('ano').AsInteger := anoSelecionado;
              ExecSQL;
              CommitRetaining;
            end
            else
            begin
              MessageDlg('Erro', 'Insira um valor numérico!', mtError, [mbOK], 0);
              goto Valor;
            end;
          end;
        Free;
      except
        on E: Exception do
        begin
          Cancel;
          RollbackRetaining;
          Free;
          writeln('Erro: ' + E.Message);
        end;
      end;
end;

procedure TEventosPainel.AtualizaDadosBanca(DataSet: TDataSet);
begin
  AtualizaBanca;
end;

procedure TEventosPainel.VerificaBancaAntiga;
var
  AnteBancaExiste: boolean;
  AnteBanca, AnteLucro, BancaAtual: double;
begin
  AnteBancaExiste := False;
  with formPrincipal do
    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      try
        DataBase := conectBancoDados;
        SQL.Text := 'SELECT Mês, Ano, Valor_Inicial, ' +
          '(SELECT SUM(A.Lucro) ' + ' FROM Apostas A ' +
          ' WHERE strftime(''%m'', A.Data) = B.Mês ' +
          '   AND strftime(''%Y'', A.Data) = B.Ano) AS Lucro ' +
          'FROM Banca B ' + 'WHERE Mês = :mes AND ANO = :ano';
        ParamByName('mes').AsInteger := (mesSelecionado - 1);
        ParamByName('ano').AsInteger := anoSelecionado;
        Open;
        AnteBanca := FieldByName('Valor_Inicial').AsFloat;
        AnteLucro := FieldByName('Lucro').AsFloat;
        BancaAtual := qrBanca.FieldByName('Valor_Inicial').AsFloat;
        if not IsEmpty then
          if AnteBanca <> BancaAtual then
          begin
            writeln('Banca anterior existe!');
            AnteBancaExiste := True;
            Close;
            SQL.Text := 'UPDATE Banca SET Valor_Inicial = :valInicio WHERE ' +
              'Mês = :mes AND Ano = :ano';
            ParamByName('mes').AsInteger := mesSelecionado;
            ParamByName('ano').AsInteger := anoSelecionado;
            ParamByName('valInicio').AsFloat := AnteBanca + AnteLucro;
            ExecSQL;
            CommitRetaining;
          end;
      finally
        Free;
      end;
end;

procedure TEventosPainel.AtualizaBanca;
var
  BancaInicial, Aporte, BancaFinal, BancaTotal: double;
begin
  with formPrincipal do
    with qrBanca do
    begin
      BancaInicial := FieldByName('Valor_Inicial').AsFloat;
      Aporte := FieldByName('Aporte').AsFloat;
      BancaTotal := BancaInicial + Aporte;
      BancaFinal := FieldByName('Valor_Final').AsFloat;
      writeln('Alterando os dados a serem exibidos da banca');
      lbValorBanca.Caption :=
        'R$ ' + StringReplace(FloatToStrF(RoundTo(BancaInicial, -2), ffFixed, 15, 2),
        '.', ',', [rfReplaceAll]);
      lbValAporte.Caption :=
        'R$ ' + StringReplace(FloatToStrF(RoundTo(Aporte, -2), ffFixed, 15, 2),
        '.', ',', [rfReplaceAll]);
      lbValBancaTotal.Caption :=
        'R$ ' + StringReplace(FloatToStrF(RoundTo(BancaTotal, -2), ffFixed, 15, 2),
        '.', ',', [rfReplaceAll]);
      lbStake.Caption :=
        'R$ ' + StringReplace(FloatToStrF(RoundTo(stakeAposta, -2), ffFixed, 15, 2),
        '.', ',', [rfReplaceAll]);
      MudarCorLucro;
    end;
end;

procedure TEventosPainel.ParametrosBanca(DataSet: TDataSet);
begin
  with formPrincipal do
    with qrBanca do
    begin
      ParamByName('mesSelec').AsInteger := mesSelecionado;
      ParamByName('anoSelec').AsInteger := anoSelecionado;
    end;
end;

procedure TEventosPainel.cbMesChange(Sender: TObject);
begin
  with formPrincipal do
  begin
    mesSelecionado := StrToInt(cbMes.Text);
    qrBanca.Close;
    qrBanca.Open;
    AtualizaMesEAno;
    AtualizarGraficoLucro;
  end;
end;

procedure TEventosPainel.cbAnoChange(Sender: TObject);
begin
  with formPrincipal do
  begin
    anoSelecionado := StrToInt(cbAno.Text);
    qrBanca.Close;
    qrBanca.Open;
    AtualizaMesEAno;
    AtualizarGraficoLucro;
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
