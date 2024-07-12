unit untPainel;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
TACustomSeries, TAMultiSeries, DateUtils, untMain;

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
  procedure PreencherComboBox;
  procedure PreencherBancaInicial;
  procedure AtualizarGraficoLucro;
  procedure AtualizaMesEAno;
end;

implementation

var
MesDoCB, AnoDoCB: integer;

procedure TEventosPainel.tsPainelShow(Sender: TObject);
begin
  with formPrincipal do
    begin

    //Preenchendo os itens dos ComboBoxes do painel
    PreencherComboBox;

    //Atualizar o mês e ano
    AtualizaMesEAno;

    //Preenchendo o TEdit da Banca Inicial
    PreencherBancaInicial;

    //Chamando procedimento de calcular a stake
    PerfilDoInvestidor;

    //Definindo a stake
    //if not qrBanca.Active then qrBanca.Open;
    DefinirStake;

    //Reiniciando todos os queries
    ReiniciarTodosOsQueries;

    //Chamando procedimento de mudar a cor do lucro
    MudarCorLucro;

    //Atualizando os gráficos
    AtualizarGraficoLucro;
    end;
end;



procedure TEventosPainel.btnSalvarBancaInicialClick(Sender: TObject);
var
  mes, ano:  integer;
  novoValor: double;
  query:     TSQLQuery;
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
    //cbPerfil.Items.Add(qrPerfis.FieldByName('Perfil').AsString);
    //qrPerfis.Next;
    //cbPerfil.Text := (qrSelecionarPerfil.FieldByName('Perfil Selecionado').AsString);

    // Verifica se o mês e o ano são válidos
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
          // ou qualquer valor inicial apropriado
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
        transactionBancoDAdos.Commit;
        ReiniciarTodosOsQueries;
        DefinirStake;
        ReiniciarTodosOsQueries;
        ShowMessage('Valor de banca salvo com sucesso!');
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
        transactionBancoDados.Commit;
        except
        on E: Exception do
          begin
          writeln('Erro ao atualizar perfil: ' + E.Message);
          transactionBancoDados.Rollback;
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
  if Key = '.' then
    Key := ',';
end;

procedure TEventosPainel.PreencherComboBox;
var
  itemCBPerfil: string;
  i, anoAtual:  integer;
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
    cbPerfil.Text    := perfilInvestidor;
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

        while not qrMes.EOF do
        begin
          (chrtLucroMes.Series[0] as TLineSeries).AddXY(
            qrMes.RecNo,
            qrMes.FieldByName('SomaLucro').AsFloat,
            qrMes.FieldByName('Dia').AsFloat);
          qrMes.Next;
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


        while not qrAno.EOF do
        begin
          (chrtLucroAno.Series[0] as TLineSeries).AddXY(
            qrAno.RecNo,
            qrAno.FieldByName('Lucro_R$').AsFloat,
            qrAno.FieldByName('Mês').AsFloat);
          qrAno.Next;
        end;
      except
        on E: Exception do
        begin
          writeln('Falha ao atualizar o gráfico de lucro do ano: ' + E.Message);
        end;
      end;
      chrtLucroMes.Invalidate;
      chrtLucroAno.Invalidate;
    finally
      qrMes.Close;
      qrAno.Close;
    end;
  end;
end;

procedure TEventosPainel.AtualizaMesEAno;
var
  query: TSQLQuery;
label
  AoMudar, AtualizaNoBD, Fim;
begin
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
        {query.SQL.Text := 'SELECT Mês AS mes, Ano AS ano FROM "Selecionar Mês e Ano"';
        query.ExecSQL;
        if not query.Active then query.Open;
        writeln('Mês e ano do banco de dados definidos para ',
        query.FieldByName('mes').AsInteger, '/', query.FieldByName('ano').AsInteger);}
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

    Fim:
      ReiniciarTodosOsQueries;
    AtualizarGraficoLucro;
    end;
end;

procedure TEventosPainel.cbMesChange(Sender: TObject);
begin
  AtualizaMesEAno;
  AtualizarGraficoLucro;
end;

procedure TEventosPainel.cbAnoChange(Sender: TObject);
begin
  AtualizaMesEAno;
  AtualizarGraficoLucro;
end;

end.
