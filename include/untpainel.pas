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
  with formPrincipal do
  begin
    if qrBanca.Active then qrBanca.Close;
    qrBanca.ParamByName('mesSelec').AsInteger := MonthOf(Now);
    qrBanca.ParamByName('anoSelec').AsInteger := YearOf(Now);
    qrBanca.Open;
  end;
  formPrincipal.MudarCorLucro;
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
    try
      query.Close;
      query.SQL.Text :=
        'select Valor_Inicial from Banca where Mês = :MesSelecionado and Ano = :AnoSelecionado';
      query.ParamByName('MesSelecionado').AsInteger := mesSelecionado;
      query.ParamByName('AnoSelecionado').AsInteger := anoSelecionado;
      query.Open;
    finally
      query.Free;
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
    cbAno.Items.Add(IntToStr(qrBanca.FieldByName('Ano').AsInteger));

    //Adicionar itens no ComboBox Mês
    cbMes.Clear;
    for i := 1 to 12 do
    begin
      cbMes.Items.Add(IntToStr(i));
      writeln('Adicionado mês "', i, '"no ComboBox "Mês"');
    end;
    cbMes.ItemIndex := MonthOf(Now) - 1;
    writeln('Definido mês padrão como ' + cbMes.Text);

    //Adicionar itens no ComboBox Ano
    if cbAno.Items.IndexOf(IntToStr(anoAtual)) = -1 then
      cbAno.Items.Add(IntToStr(anoAtual));
    cbAno.ItemIndex := cbAno.Items.IndexOf(IntToStr(anoAtual));
    writeln('definido ano padrão como ' + cbAno.Text);

    //Definir as variáveis mesSelecionado e anoSelecionado de acordo com o texto do ComboBox
    mesSelecionado := StrToInt(cbMes.Text);
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
  i, j, Contador, mesGreen, mesRed, diaGreen, diaRed: integer;
  ContFloat: double;
begin
  with formPrincipal do
  begin
    try
      (chrtLucroMes.Series[0] as TLineSeries).Clear;
      (chrtLucroAno.Series[0] as TLineSeries).Clear;

      // Gráfico de lucro do mês
      try
        if not qrMes.Active then qrMes.Open;
        if qrMes.RecordCount = 0 then Exit;

        writeln('Registros encontrados para o mês: ' + IntToStr(qrMes.RecordCount));
        if cbGraficos.Text = 'Lucro R$' then
        begin
          chrtLucroMes.AxisList[1].Marks.Format := '%0:.2m';
          (chrtLucroMes.Series[0] as TLineSeries).Clear;

          if not qrMes.Active then qrMes.Open;

          for i := 1 to 31 do
          begin
           { (chrtLucroMes.Series[0] as TLineSeries).AddXY(
              i,
              qrMes.FieldByName('SomaLucro').AsFloat);
            qrMes.Next; }
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

        end
        else if cbGraficos.Text = 'Lucro %' then
        begin
          chrtLucroMes.AxisList[1].Marks.Format := '%0:.2n%%';
          (chrtLucroMes.Series[0] as TLineSeries).Clear;
          for i := 1 to 31 do
          begin
            {(chrtLucroMes.Series[0] as TLineSeries).AddXY(
              i,
              qrMes.FieldByName('PorCentoLucro').AsFloat);
            qrMes.Next;}
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
      except
        on E: Exception do
        begin
          writeln('Falha ao atualizar o gráfico do mês: ' + E.Message);
        end;
      end;

      // Gráfico de lucro do ano
      try
        if not qrAno.Active then qrAno.Open;
        if qrAno.RecordCount = 0 then Exit;

        writeln('Registros encontrados para o ano: ' + IntToStr(qrAno.RecordCount));

        begin
          if cbGraficos.Text = 'Lucro %' then
          begin
            chrtLucroAno.AxisList[0].Marks.Format := '%0:.2n%%';

            qrAno.First;
            for Contador := 1 to 12 do
            begin
              ContFloat := Contador;
              if Contador < qrAno.FieldByName('Mês').AsInteger then
                (chrtLucroAno.Series[0] as TLineSeries).AddXY(Contador,
                  qrAno.FieldByName('LucroTotalPorCento').AsFloat, ContFloat)
              else if Contador > qrAno.FieldByName('Mês').AsInteger then
              begin
                qrAno.Last;
                (chrtLucroAno.Series[0] as TLineSeries).AddXY(Contador,
                  qrAno.FieldByName('LucroTotalPorCento').AsFloat, ContFloat);
                qrAno.First;
              end
              else
              begin
                (chrtLucroAno.Series[0] as TLineSeries).AddXY(
                  Contador,
                  qrAno.FieldByName('LucroTotalPorCento').AsFloat,
                  ContFloat);
                qrAno.Next;
              end;
            end;
          end
          else if cbGraficos.Text = 'Lucro R$' then
          begin
            chrtLucroAno.AxisList[0].Marks.Format := '%0:.2m';
            for Contador := 1 to 12 do
            begin
              ContFloat := Contador;
              if Contador < qrAno.FieldByName('Mês').AsInteger then
                (chrtLucroAno.Series[0] as TLineSeries).AddXY(Contador,
                  qrAno.FieldByName('LucroAnualReais').AsFloat, ContFloat)
              else if Contador > qrAno.FieldByName('Mês').AsInteger then
              begin
                qrAno.Last;
                (chrtLucroAno.Series[0] as TLineSeries).AddXY(Contador,
                  qrAno.FieldByName('LucroAnualReais').AsFloat, ContFloat);
                qrAno.First;
              end
              else
              begin
                (chrtLucroAno.Series[0] as TLineSeries).AddXY(
                  Contador,
                  qrAno.FieldByName('LucroAnualReais').AsFloat,
                  ContFloat);
                qrAno.Next;
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

      //Atualizar gráficos pizza
      try
        (chrtAcertMes.Series[0] as TPieSeries).Clear;
        (chrtAcertAno.Series[0] as TPieSeries).Clear;
        if not qrMes.Active then qrMes.Open;
        if qrMes.RecordCount = 0 then Exit;

        writeln('Registros encontrados para colocar no gráfico de greens e reds: ' +
          IntToStr(qrMes.RecordCount));
        diaGreen := 0;
        diaRed := 0;
        for i := 0 to qrMes.RecordCount - 1 do
        begin
          qrMes.RecNo := i + 1;
          diaGreen := diaGreen + qrMes.FieldByName('Green').AsInteger;
          diaRed := diaRed + qrMes.FieldByName('Red').AsInteger;
        end;

        (chrtAcertMes.Series[0] as TPieSeries).AddPie(diaGreen,
          'Dias de Lucro ', clGreen);
        (chrtAcertMes.Series[0] as TPieSeries).AddPie(diaRed,
          'Dias de Perejuízo ', clRed);

        (chrtAcertAno.Series[0] as TPieSeries).Clear;
        mesGreen := 0;
        mesRed := 0;
        for j := 0 to qrBanca.RecordCount - 1 do
        begin
          qrBanca.RecNo := j + 1;

          if (qrBanca.FieldByName('Lucro').AsFloat) < 0 then
            mesRed := mesRed + 1
          else if (qrBanca.FieldByName('Lucro').AsFloat) > 0 then
            mesGreen := mesGreen + 1;
        end;

        (chrtAcertAno.Series[0] as TPieSeries).AddPie(mesGreen, 'Meses de Lucro',
          clGreen);

        (chrtAcertAno.Series[0] as TPieSeries).AddPie(mesRed,
          'Meses de Prejuízo', clRed);
      except
        on E: Exception do
        begin
          writeln('Falha ao atualizar o gráfico do mês: ' + E.Message);
        end;
      end;
      chrtAcertMes.Invalidate;

    finally
      qrMesesGreenRed.Close;
      qrMes.Close;
      qrAno.Close;
    end;

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
