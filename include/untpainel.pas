unit untPainel;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
  TACustomSeries, TAMultiSeries, DateUtils, untMain, fgl, Math;

function InserirNaBanca: boolean;

type

  { TEventosPainel }

  TEventosPainel = class(TformPrincipal)

  public
    procedure tsPainelShow(Sender: TObject);
    procedure btnSalvarBancaInicialClick(Sender: TObject);
    procedure cbPerfilChange(Sender: TObject);
    procedure cbGraficosChange(Sender: TObject);
    procedure qrMesCalcFields(DataSet: TDataSet);
    procedure qrAnoCalcFields(DataSet: TDataSet);

    procedure PreencherComboBox;
    procedure PreencherBancaInicial;
    procedure AtualizarGraficoLucro;
    procedure AtualizaMesEAno;
    procedure HabilitaMesEAno(Sender: TObject);
    procedure FazerAporte(Sender: TObject);
    procedure RetirarDinheiro(Sender: TObject);
    procedure AtualizaDadosBanca(DataSet: TDataSet);
    //procedure VerificaBancaAntiga;
    procedure AtualizaBanca;
    procedure ParametrosBanca(DataSet: TDataSet);
    procedure StakeVariavel(Sender: TObject);
    procedure AoMudarMesEAno(Sender: TObject);
  end;

  TDateDoubleMap = specialize TFPGMap<TDateTime, double>;

var
  Painel: TEventosPainel;

implementation

uses untApostas;

var
  MesDoCB, AnoDoCB: integer;

function InserirNaBanca: boolean;
begin
  Result := False;
  with formPrincipal do
    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      begin
        if not qrBanca.Active then qrBanca.Open;
        if qrBanca.IsEmpty then
        try
          writeln('Banca vazia na data selecionada, preenchendo');
          DataBase := conectBancoDados;
          SQL.Text := 'INSERT INTO Banca (Mês, Ano) VALUES (:mes, :ano)';
          ParamByName('mes').AsInteger := mesSelecionado;
          ParamByName('ano').AsInteger := anoSelecionado;
          ExecSQL;
          CommitRetaining;
          Result := True;
        except
          On E: Exception do
          begin
            writeln('Erro ao inserir dados na banca: ' + E.Message);
            Rollbackretaining;
            Result := False;
          end;
        end
        else
          Result := True;
        qrBanca.Refresh;
        Free;
        tsGraficos.Show;
      end;
end;

procedure TEventosPainel.tsPainelShow(Sender: TObject);
begin
  writeln('Exibido painel principal');
  with formPrincipal do
  begin
    rbGestUn.Checked    := GestaoUnidade;
    rbGestPcent.Checked := not GestaoUnidade;
    chbGestaoVariavel.Checked := GestaoVariavel;
    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      try
        DataBase := conectBancoDados;
        if not qrBanca.Active then qrBanca.Open;
        if qrBanca.IsEmpty then
        begin
          SQL.Text := 'INSERT INTO Banca (Mês, Ano) VALUES (:mes, :ano)';
          ParamByName('mes').AsInteger := mesSelecionado;
          ParamByname('ano').AsInteger := anoSelecionado;
          ExecSQL;
          CommitRetaining;
          qrBanca.Close;
          qrBanca.Open;
        end;
      finally
        Free;
      end;
  end;
  PerfilDoInvestidor;
  AtualizarGraficoLucro;
end;



procedure TEventosPainel.btnSalvarBancaInicialClick(Sender: TObject);
var
  mes, ano:  integer;
  novoValor: double;
  query:     TSQLQuery;
  entrada:   string;
label
  Valor;
begin
  with formPrincipal do
  begin
    novoValor := 0.00;
    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      begin
        try
          DataBase := conectBancoDados;
          SQL.Text := 'SELECT Banca FROM BancaInicial';
          Open;
          if RecordCount = 0 then
          begin
            Close;
            SQL.Text := 'INSERT INTO BancaInicial DEFAULT VALUES';
            ExecSQL;
            goto Valor;
          end
          else if Fields[0].AsFloat = 0 then
          begin

            Valor:

              if InputQuery('Inserir Valor', 'Insira o valor da tua banca na casa ' +
              'de apostas que tu operas:', Entrada) then
              begin
                case FormatSettings.DecimalSeparator of
                  '.': if Pos(',', Entrada) > 0 then
                      Entrada := StringReplace(Entrada, ',', '.', [rfReplaceAll]);

                  ',': if Pos('.', Entrada) > 0 then
                      Entrada := StringReplace(Entrada, '.', ',', [rfReplaceAll]);
                end;
                if TryStrToFloat(Entrada, novoValor) then
                begin
                  Close;
                  SQL.Text := 'UPDATE BancaInicial SET Banca = :banca';
                  ParamByName('banca').AsFloat := novoValor;
                  ExecSQL;
                end
                else
                begin
                  MessageDlg('Erro', 'Insira um valor numérico!', mtError,
                  [mbOK], 0);
                  goto Valor;
                end;
              end;
          end
          else if MessageDlg('Aviso', 'AVISO:' + sLineBreak +
            sLineBreak + 'A banca inicial já foi registrada! Caso tenha inserido mais '
            + 'dinheiro na tua banca da casa de apostas, favor usar o botão '
            + '"Inserir Dinheiro"; caso tenha retirado dinheiro da banca, favor usar ' +
            'o botão "Retirar Dinheiro". Só é recomendável alterar o valor da ' +
            'banca inicial em caso de correção do valor, do contrário o cálculo '
            +
            'dos dados ficará incorreto. ' + sLineBreak +
            'Deseja alterar a banca inicial mesmo assim?', mtWarning,
            [mbYes, mbNo], 0) = mrYes then
            goto Valor
          else
            Exit;

          transactionBancoDados.CommitRetaining;
          valorInicial   := novoValor;
          mesSelecionado := StrToInt(cbMes.Text);
          anoSelecionado := StrToInt(cbAno.Text);
          qrBanca.Close;
          qrBanca.Open;
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
        Free;
      end;
    //perfilInvestidor := cbPerfil.Text;
    //txtStake.DataField := qrBanca.FieldByName('R$Stake').AsString;
    MudarCorLucro;
    PerfilDoInvestidor;
    CalculaDadosAposta;
    AtualizarGraficoLucro;
  end;
end;

procedure TEventosPainel.cbPerfilChange(Sender: TObject);
begin
  writeln('Atualizando perfil');
  with formPrincipal do
  begin
    perfilInvestidor := cbPerfil.Text;
    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      begin
        try
          DataBase := conectBancoDados;
          SQL.Text :=
            'UPDATE "Selecionar Perfil" SET "Perfil Selecionado" = ' +
            ':perfilSelecionado';
          ParamByName('perfilSelecionado').AsString := perfilInvestidor;
          ExecSQL;
          CommitRetaining;
        except
          on E: Exception do
          begin
            RollbackRetaining;
            writeln('Erro ao atualizar perfil: ' + E.Message);
          end;
        end;
        Free;
      end;
    PerfilDoInvestidor;
    writeln('Definido perfil como ', perfilInvestidor);
    ReiniciarTodosOsQueries;
    AtualizarGraficoLucro;
  end;
end;

procedure TEventosPainel.PreencherComboBox;
var
  itemCBPerfil: string;
  i, anoAtual:  integer;
begin
  with formPrincipal do
  begin
    writeln('Preenchendo ComboBoxes');
    try
      if not qrBanca.Active then qrBanca.Open;
    except
      On E: Exception do
        writeln('Erro ao abrir qrBanca: ' + E.Message);
    end;

    //if not qrPerfis.Active then qrPerfis.Open;

    //Adicionar itens no ComboBox Perfil
    with TSQLQuery.Create(nil) do
    begin
      try
        writeln('Selecionando perfil');
        DataBase := conectBancoDados;
        SQL.Text := 'SELECT "Perfil Selecionado" FROM "Selecionar Perfil"';
        Open;
        if not IsEmpty then
          perfilInvestidor := FieldByName('Perfil Selecionado').AsString
        else
          perfilInvestidor := 'Conservador';
      except
        writeln('Erro ao selecionar perfil, definindo padrão como "Conservador"');
        perfilInvestidor := 'Conservador';
      end;
      cbPerfil.Text := perfilInvestidor;
      Free;
    end;

    //Adicionar itens no ComboBox Ano
    anoAtual := YearOf(Now);
    with TSQLQuery.Create(nil) do
    try
      writeln('Preenchendo ComboBox "Ano"');
      DataBase := conectBancoDados;
      SQL.Text := 'SELECT Ano FROM Banca GROUP BY Ano ORDER BY Ano';
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
    //Adicionar itens no ComboBox Mês
    cbMes.ItemIndex := cbMes.Items.IndexOf(IntToStr(MonthOf(Now)));
    writeln('Definido mês padrão como ' + cbMes.Text);

    //Adicionar itens no ComboBox Ano
    cbAno.ItemIndex := cbAno.Items.IndexOf(IntToStr(anoAtual));

    //Definir as variáveis mesSelecionado e anoSelecionado de acordo com o texto do ComboBox
    mesSelecionado := StrToInt(cbMes.Text);
    anoSelecionado := StrToInt(cbAno.Text);
  end;
end;

procedure TEventosPainel.PreencherBancaInicial;
begin
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text :=
        'select Valor_Inicial , Aporte ' +
        'from Banca where Mês = :MesSelecionado and Ano = :AnoSelecionado';
      ParamByName('MesSelecionado').AsInteger := mesSelecionado;
      ParamByName('AnoSelecionado').AsInteger := anoSelecionado;
      Open;

      if not IsEmpty then
      begin
        valorInicial := FieldByName('Valor_Inicial').AsFloat;
        Aporte := FieldByName('Aporte').AsFloat;
      end
      else
        valorInicial := 0;
    finally
      Free;
    end;
end;

procedure TEventosPainel.AtualizarGraficoLucro;
var
  i, j, anoGreen, anoRed, mesGreen, mesRed, diaGreen, diaRed, anoNeutro,
  mesNeutro, diaNeutro, MaxInt, MinInt, Mes: integer;

  ContFloat, LAP, LAR, LAPA, LARA, SomaLucro, ValInicio, Aporte,
  TotInvest, LucroPcent, BancaFinal, LMP, LMR: double;

  LucroStr: string;
begin
  writeln('Atualizando gráficos do painel principal');
  with formPrincipal do
  begin
    (chrtLucroMes.Series[0] as TLineSeries).Clear;
    (chrtLucroAno.Series[0] as TLineSeries).Clear;
    (chrtLucroTodosAnos.Series[0] as TLineSeries).Clear;

{*********************************LUCRO DO MÊS*********************************}
    with qrMes do
    try
      if not Active then Open
      else
        Refresh;

      //writeln('Registros encontrados para o mês: ' + IntToStr(qrMes.RecordCount));
      case cbGraficos.Text of

        'Lucro R$':
        begin
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
          if RecordCount <> 0 then
            with (chrtLucroMes.Series[0] as TLineSeries) do
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
                  LMP := FieldByName('PorCentoLucro').AsFloat;
                end;
                AddXY(i, LMP, ContFloat);
              end;
            end;
        end;
      end;
    except
      on E: Exception do
        writeln('Falha ao atualizar o gráfico do mês: ' + E.Message);
    end;
    chrtLucroMes.Invalidate;

{******************************************************************************}
{*********************************LUCRO DO ANO*********************************}
    with qrLucroAno do
    try
      case cbGraficos.Text of
        'Lucro %':
        begin
          chrtLucroAno.AxisList[0].Marks.Format := '%0:.2n%%';
          Mes := 0;
          LAP := 0;
          for i := 1 to 12 do
          begin
            ParamByName('contagem').AsInteger := i;
            Open;
            ContFloat := i;
            with (chrtLucroAno.Series[0] as TLineSeries) do
            begin
              if not IsEmpty then
              begin
                writeln('Registro ', i, ': ', Fields[1].AsFloat);
                LAP := LAP + Fields[1].AsFloat;
              end
              else
                LAP := LAP + 0;
              AddXY(i, LAP, ContFloat);
            end;
            Close;
          end;
        end;
        'Lucro R$':
        begin

          chrtLucroAno.AxisList[0].Marks.Format := '%0:.2m';

          LAR := 0;
          for i := 1 to 12 do
            with (chrtLucroAno.Series[0] as TLineSeries) do
            begin
              ParamByName('contagem').AsInteger := i;
              Open;
              ContFloat := i;
              if not IsEmpty or not Fields[0].IsNull then
              try
                LAR := LAR + Fields[0].AsFloat;
              except
                LAR := LAR + 0;
              end;
              AddXY(i, LAR, ContFloat);
              Close;
            end;
        end;
      end;
    except
      on E: Exception do
        writeln('Falha ao atualizar o gráfico de lucro do ano: ' + E.Message);
    end;
    chrtLucroAno.Invalidate;

{******************************************************************************}
{****************************LUCRO DE TODOS OS ANOS****************************}

    with qrTodosAnos do
    try
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

        'Lucro %': begin
          chrtLucroTodosAnos.AxisList[0].Marks.Format := '%0:.2n%%';
          if not IsEmpty then begin
            First;
            SomaLucro  := FieldByName('Lucro').AsFloat;
            ValInicio  := FieldByName('ValorInicial').AsFloat;
            Aporte     := FieldByName('Aporte').AsFloat;
            TotInvest  := ValInicio + Aporte;
            BancaFinal := TotInvest + SomaLucro;

            LAPA := SomaLucro / BancaFinal * 100;
            if RecordCount <> 0 then
              with chrtLucroTodosAnos.AxisList[1].Range do
                with (chrtLucroTodosAnos.Series[0] as TLineSeries) do
                  for i := MinInt to MaxInt do
                  begin
                    ContFloat := i;
                    First;
                    while not EOF do
                      if i < FieldByName('Ano').AsInteger then
                        AddXY(i, 0, ContFloat)
                      else
                      begin
                        Next;
                        AddXY(i, LAPA, ContFloat);
                        if not EOF then
                        begin
                          SomaLucro := SomaLucro + FieldByName('Lucro').AsFloat;
                          Aporte := Aporte + FieldByName('Aporte').AsFloat;
                          TotInvest := ValInicio + Aporte;
                          BancaFinal := TotInvest + SomaLucro;
                          LAPA :=
                            LAPA + (SomaLucro / TotInvest * 100);
                        end;
                      end;
                  end;
          end;
          {else begin
            SomaLucro  := 0;
            ValInicio  := 0;
            Aporte     := 0;
            TotInvest  := 0;
            BancaFinal := 0;
          end; }
        end;
        'Lucro R$':
        begin
          chrtLucroTodosAnos.AxisList[0].Marks.Format := '%0:.2m';
          if not IsEmpty then begin
            First;
            LARA := FieldByName('Lucro').AsFloat;
            with chrtLucroTodosAnos.AxisList[1].Range do
              with (chrtLucroTodosAnos.Series[0] as TLineSeries) do
                if RecordCount <> 0 then
                  for i := MinInt to MaxInt do
                  begin
                    ContFloat := i;
                    if i < FieldByName('Ano').AsInteger then
                      AddXY(i, 0, ContFloat)
                    else
                    begin
                      AddXY(i, LARA, ContFloat);
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
      end;
    except
      on E: Exception do
        writeln('Falha ao atualizar o gráfico de lucro de todos os anos: ' +
          E.Message);
    end;
    qrTodosAnos.Close;
    chrtLucroTodosAnos.Invalidate;

{******************************************************************************}
{*********************************GRÁFICOS PIZZA*******************************}
    with qrMes do
    begin
      (chrtAcertMes.Series[0] as TPieSeries).Clear;
      (chrtAcertAno.Series[0] as TPieSeries).Clear;

      diaGreen  := 0;
      diaRed    := 0;
      diaNeutro := 0;

      //Gráfico pizza do mês
      First;
      if RecordCount <> 0 then
        while not EOF do
        begin
          diaGreen  := diaGreen + FieldByName('Green').AsInteger;
          diaRed    := diaRed + FieldByName('Red').AsInteger;
          diaNeutro := diaNeutro + FieldByName('Neutro').AsInteger;
          Next;
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
    end;

      //Gráfico pizza do ano
    (chrtAcertAno.Series[0] as TPieSeries).Clear;
    with TSQLQuery.Create(nil) do
    begin
      try
         mesGreen  := 0;
         mesRed    := 0;
         mesNeutro := 0;
        DataBase := conectBancoDados;
        SQL.Text :=
          'WITH SomaValores AS (                                           ' +
          'SELECT                                                          ' +
          ' B.Mês, B.Ano,                                                  ' +
          '  (SELECT Banca FROM BancaInicial) AS BancaInicio,              ' +
          '  IFNULL(SUM(CASE WHEN strftime(''%m'', A.Data) <= B.Mês THEN   ' +
          'A.Lucro ELSE 0 END), 0) AS LucroAtual,                          ' +
          '  IFNULL(SUM(CASE WHEN strftime(''%m'', A.Data) < B.Mês THEN    ' +
          'A.Lucro ELSE 0 END), 0) AS LucroAntigo                          ' +
          'FROM Banca B                                                    ' +
          'LEFT JOIN Apostas A ON strftime(''%m'', A.Data) <= B.Mês        ' +
          'WHERE B.Ano = :ano                                              ' +
          'GROUP BY B.Mês                                                  ' +
          'HAVING COUNT(A.Data) > 0)                                       ' +
          'SELECT                                                          ' +
          'SUM(CASE WHEN LucroAtual > LucroAntigo THEN 1 ELSE 0 END)       ' +
          'AS Green,                                                       ' +
          'SUM(CASE WHEN LucroAtual < LucroAntigo THEN 1 ELSE 0 END)       ' +
          'AS Red,                                                         ' +
          'SUM(CASE WHEN LucroAtual = LucroAntigo THEN 1 ELSE 0 END)       ' +
          'AS Neutro                                                       ' +
          'FROM SomaValores                                                ';
        ParamByName('ano').AsInteger := anoSelecionado;
        Open;
        if not IsEmpty then
          begin
            mesGreen  := FieldByName('Green').AsInteger;
            mesRed    := FieldByName('Red').AsInteger;
            mesNeutro := FieldByName('Neutro').AsInteger;
          end;
        with (chrtAcertAno.Series[0] as TPieSeries) do
        begin
          if mesGreen <> 0 then
            AddPie(mesGreen, IntToStr(mesGreen) + ' Meses Bons,', clGreen);

          if mesRed <> 0 then
            AddPie(mesRed, IntToStr(mesRed) + ' Meses Ruins,', clRed);

          if mesNeutro <> 0 then
            AddPie(mesNeutro, IntToStr(mesNeutro) + ' Meses Neutros,', clGray);
        end;
      except
        On E: Exception do
          writeln('Erro no gráfico pizza do ano: ' + E.Message);
      end;
      Free;
    end;

      //Gráfico de Assertividade Todos os Anos
    writeln('Mudando gráfico de assertividade de todos os anos');
    with TSQLQuery.Create(nil) do
    begin
      try
        DataBase := conectBancoDados;
        writeln('Definindo o SQL do Query');
        SQL.Text :=
          'WITH SomaValores AS (                                           ' +
          'SELECT                                                          ' +
          ' B.Mês,                                                         ' +
          '  (SELECT Banca FROM BancaInicial) AS BancaInicio,              ' +
          '  IFNULL(SUM(CASE WHEN strftime(''%m'', A.Data) <= B.Mês THEN   ' +
          'A.Lucro ELSE 0 END), 0) AS LucroAtual,                          ' +
          '  IFNULL(SUM(CASE WHEN strftime(''%m'', A.Data) < B.Mês THEN    ' +
          'A.Lucro ELSE 0 END), 0) AS LucroAntigo                          ' +
          'FROM Banca B                                                    ' +
          'LEFT JOIN Apostas A ON strftime(''%m'', A.Data) <= B.Mês        ' +
          'GROUP BY B.Mês                                                  ' +
          'HAVING COUNT(A.Data) > 0)                                       ' +
          'SELECT                                                          ' +
          'SUM(CASE WHEN LucroAtual > LucroAntigo THEN 1 ELSE 0 END)       ' +
          'AS Green,                                                       ' +
          'SUM(CASE WHEN LucroAtual < LucroAntigo THEN 1 ELSE 0 END)       ' +
          'AS Red,                                                         ' +
          'SUM(CASE WHEN LucroAtual = LucroAntigo THEN 1 ELSE 0 END)       ' +
          'AS Neutro                                                       ' +
          'FROM SomaValores                                                ';
        writeln('Abrindo query');
        Open;
        First;
        anoGreen  := 0;
        anoRed    := 0;
        anoNeutro := 0;
        if not IsEmpty then
          while not EOF do
          begin
            mesGreen  := FieldByName('Green').AsInteger;
            mesRed    := FieldByName('Red').AsInteger;
            mesNeutro := FieldByName('Neutro').AsInteger;
            if mesGreen > mesRed then
              anoGreen := anoGreen + 1
            else if mesGreen < mesRed then
              anoRed    := anoRed + 1
            else
              anoNeutro := anoNeutro + 1;
            Next;
          end;
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
      except
        on E: Exception do
          writeln('Erro no gráfico de assertividade de todos ' +
            'os anos: ' + E.Message);
      end;
      Free;
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
begin
  writeln('Tentando atualizar mês e ano');
  with formPrincipal do
  begin
    MesDoCB := StrToInt(cbMes.Text);
    AnoDoCB := StrToInt(cbAno.Text);
    mesSelecionado := MonthOf(now);
    anoSelecionado := YearOf(now);
    if (MesDoCB <> mesSelecionado) or (AnoDoCB <> anoSelecionado) then
    begin
      mesSelecionado := StrToInt(cbMes.Text);
      anoSelecionado := StrToInt(cbAno.Text);
    end;

    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      begin
        try
          Database := conectBancoDados;
          SQL.Text :=
            'UPDATE "Selecionar Mês e Ano" SET Mês = :mesSelec, Ano = :anoSelec ' +
            'WHERE rowid = 1;';
          ParamByName('mesSelec').AsInteger := mesSelecionado;
          ParamByName('anoSelec').AsInteger := anoSelecionado;
          ExecSQL;
          CommitRetaining;
        except
          on E: Exception do
          begin
            writeln('Erro ao salvar mês e ano selecionados: ' + E.Message);
            RollbackRetaining;
          end;
        end;
        Free;
      end;
  end;
end;

procedure TEventosPainel.HabilitaMesEAno(Sender: TObject);
begin
  with formPrincipal do
  begin
    qrMes.Open;
    qrAno.Open;
    qrTodosAnos.Open;
  end;
end;

procedure TEventosPainel.FazerAporte(Sender: TObject);
var
  Banca, Aporte, Convert: double;
  Entrada: string;
label
  InserirValor;
begin
  if InserirNaBanca then
    with formPrincipal do
      with transactionBancoDados do
        with TSQLQuery.Create(nil) do
        try
          DataBase      := conectBancoDados;
          Screen.Cursor := crAppStart;
          writeln('Fazendo aporte');
          if not qrBanca.Active then qrBanca.Open;
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
                Aporte   := Aporte + Convert;
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
                MessageDlg('Erro', 'Insira um valor numérico!', mtError, [mbOK], 0);
                goto InserirValor;
              end;
            end;
        finally
          Screen.Cursor := crDefault;
          Free;
        end
  else
  {$IFDEF MSWINDOWS}
  if MessageDlg('Erro', 'Não foi possível inserir dados na banca, deseja abrir o ' +
    'arquivo de log?', mtError, [mbYes, mbNo], 0) = mrYes then AbrirArquivoLog;
  {$ENDIF}
  {$IFDEF LINUX}
  MessageDlg('Erro','Não foi possível inserir dados da banca, abra o programa ' +
  'pelo terminal com o comando "graxaimbanca" para ver o log.', mtError, [mbOk],
  0);
  {$ENDIF}
  CalculaDadosAposta;
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
          if InputQuery('Inserir Valor', 'Digite o valor que foi retirado da ' +
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
              SQL.Text      :=
                'UPDATE Banca SET Aporte = :retirada WHERE Mês = :mes AND ' +
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
        qrBanca.Refresh;
        Free;
      except
        on E: Exception do
        begin
          Cancel;
          RollbackRetaining;
          Free;
          writeln('Erro: ' + E.Message);
          qrBanca.Refresh;
        end;
      end;
  CalculaDadosAposta;
end;

procedure TEventosPainel.AtualizaDadosBanca(DataSet: TDataSet);
begin
  AtualizaBanca;
end;

procedure TEventosPainel.AtualizaBanca;
var
  BancaInicial, Aporte, BancaFinal, BancaTotal, LucroRS, LucroPcent: double;
label
  DadosBanca;
begin
  with formPrincipal do
  begin
    with TSQLQuery.Create(nil) do
    begin
      try
        DataBase := conectBancoDados;
        SQL.Text := 'SELECT Banca FROM BancaInicial';
        Open;
        if not IsEmpty or not Fields[0].IsNull then
          BancaInicial := Fields[0].AsFloat;
      except
        writeln('Erro, definindo banca inicial como 0');
        BancaInicial := 0;
      end;
      Free;
    end;

    writeln('Definindo variáveis da banca');
    with qrBanca do
    try
      with FieldByName('Aporte') do
        if not IsNull then
          Aporte := AsFloat;
      with FieldByName('BancaTotal') do
        if not IsNull then
          BancaTotal := AsFloat;
      with FieldByName('Valor_Final') do
        if not IsNull then
          BancaFinal := AsFloat;
      with FieldByName('LucroR$') do
        if not IsNull then
          LucroRS := AsFloat;
    except
      writeln('Erro, definindo as variáveis como 0');
      Aporte     := 0;
      BancaTotal := 0;
      BancaFinal := 0;
      LucroRS    := 0;
    end;
    if BancaTotal <> 0 then
      LucroPcent := RoundTo(LucroRS / BancaTotal * 100, -2)
    else
      LucroPcent := 0;

    writeln('Alterando os dados a serem exibidos da banca');
    try
      lbValorBanca.Caption := 'R$ ' + FormatFloat('#,##0.00', BancaInicial);
      lbValAporte.Caption  := 'R$ ' + FormatFloat('#,##0.00', Aporte);
      lbValBancaTotal.Caption := 'R$ ' + FormatFloat('#,##0.00', BancaTotal);
      lbStake.Caption      := 'R$ ' + FormatFloat('#,##0.00', stakeAposta);
      lbBancaFinal.Caption := 'R$ ' + FormatFLoat('#,##0.00', BancaFinal);
      lbLucroDinheiro.Caption := 'R$ ' + FormatFloat('#,##0.00', LucroRS);
      lbLucroPcent.Caption := FormatFloat('#,##0.00', LucroPcent) + '%';
      MudarCorLucro;
      CalculaDadosAposta;
    except
      lbValorBanca.Caption := 'R$ 0,00';
      lbValAporte.Caption  := 'R$ 0,00';
      lbValBancaTotal.Caption := 'R$ 0,00';
      lbStake.Caption      := 'R$ 0,00';
      lbBancaFinal.Caption := 'R$ 0,00';
      lbLucroDinheiro.Caption := 'R$ 0,00';
      lbLucroPcent.Caption := '0,00%';
    end;
  end;
end;

procedure TEventosPainel.ParametrosBanca(DataSet: TDataSet);
begin
  with formPrincipal do
    with qrBanca do
    begin
      if mesSelecionado = 0 or -1 then
        mesSelecionado := MonthOf(Now);
      if anoSelecionado = 0 or -1 then
        anoSelecionado := YearOf(Now);
      ParamByName('mesSelec').AsInteger := mesSelecionado;
      ParamByName('anoSelec').AsInteger := anoSelecionado;
    end;
end;

procedure TEventosPainel.StakeVariavel(Sender: TObject);
begin
  with formPrincipal do
    with transactionBancoDados do
      with qrConfig do
        with FieldByName('GestaoVariavel') do
          with chbGestaoVariavel do
          begin
            writeln('Definindo a stake como variável/fixa');
            Checked := AsBoolean;
            GestaoVariavel := AsBoolean;
            Edit;
            Post;
            ApplyUpdates;
            CommitRetaining;
            PerfilDoInvestidor;
          end;
end;

procedure TEventosPainel.AoMudarMesEAno(Sender: TObject);
begin
  with formPrincipal do
  begin
    mesSelecionado := StrToInt(cbMes.Text);
    anoSelecionado := StrToInt(cbAno.Text);
    AtualizaMesEAno;
    qrBanca.Close;
    qrBanca.Open;
    if not InserirNaBanca then Exit;
    AtualizaBanca;
    try
      AtualizarGraficoLucro;
      CalculaDadosAposta;
      PerfilDoInvestidor;
    except
      Exit;
    end;
  end;
end;

{procedure TEventosPainel.cbMesChange(Sender: TObject);
begin
  with formPrincipal do
  begin
    mesSelecionado := StrToInt(cbMes.Text);
    //qrBanca.Close;
    //qrBanca.Open;
    AtualizaMesEAno;
    AtualizarGraficoLucro;
    CalculaDadosAposta;
    PerfilDoInvestidor;
  end;
end;

procedure TEventosPainel.cbAnoChange(Sender: TObject);
begin
  with formPrincipal do
  begin
    mesSelecionado := StrToInt(cbMes.Text);
    anoSelecionado := StrToInt(cbAno.Text);
    qrBanca.Refresh;
    AtualizaMesEAno;
    AtualizarGraficoLucro;
    CalculaDadosAposta;
    PerfilDoInvestidor;
  end;
end; }

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
