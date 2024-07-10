unit untNA;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBExtCtrls,
ActnList, StdCtrls, DBCtrls, EditBtn, Math;

type

{ TformNovaAposta }

TformNovaAposta = class(TForm)
  btnOk:      TButton;
  btnCancelar: TButton;
  cbCompeticao: TComboBox;
  cbMandante: TComboBox;
  cbSituacao: TComboBox;
  cbVisitante: TComboBox;
  cbEstrategia: TComboBox;
  cbUnidade:  TComboBox;
  deAposta:   TDateEdit;
  dsNACompeticao: TDataSource;
  dsNAEstrategia: TDataSource;
  dsNAUnidade: TDataSource;
  dsNAMandante: TDataSource;
  dsNASituacao: TDataSource;
  dsNAVisitante: TDataSource;
  dsNovaAposta: TDataSource;
  edtOdd:     TEdit;
  edtValor:   TEdit;
  Label1:     TLabel;
  Label2:     TLabel;
  Label3:     TLabel;
  Label4:     TLabel;
  Label5:     TLabel;
  Label6:     TLabel;
  Label7:     TLabel;
  Label8:     TLabel;
  Label9:     TLabel;
  qrNACompeticaoCompetio: TStringField;
  qrNAEstrategia: TSQLQuery;
  qrNASituacao: TSQLQuery;
  qrNASituacaoStatus: TStringField;
  qrNAUnidade: TSQLQuery;
  qrNAMandante: TSQLQuery;
  qrNAVisitante: TSQLQuery;
  qrNovaAposta: TSQLQuery;
  qrNACompeticao: TSQLQuery;
  transactionNovaAposta: TSQLTransaction;
  procedure btnCancelarClick(Sender: TObject);
  procedure btnOkClick(Sender: TObject);
  procedure cbCompeticaoChange(Sender: TObject);
  procedure cbCompeticaoKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
  procedure cbEstrategiaChange(Sender: TObject);
  procedure cbMandanteChange(Sender: TObject);
  procedure cbSituacaoChange(Sender: TObject);
  procedure cbUnidadeChange(Sender: TObject);
  procedure cbVisitanteChange(Sender: TObject);
  procedure deApostaChange(Sender: TObject);
  procedure edtOddChange(Sender: TObject);
  procedure edtOddKeyPress(Sender: TObject; var Key: char);
  procedure edtValorChange(Sender: TObject);
  procedure edtValorKeyPress(Sender: TObject; var Key: char);
  procedure edtValorMouseEnter(Sender: TObject);
  procedure edtValorMouseLeave(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure FormShow(Sender: TObject);
private

  procedure PreencherComboBox;
  procedure CalcularValorAposta;
  procedure HabilitarBotaoOk;
public

end;

var
formNovaAposta: TformNovaAposta;

implementation

uses
untMain;

{$R *.lfm}

{ TformNovaAposta }

procedure TformNovaAposta.FormCreate(Sender: TObject);
begin
  btnOk.Enabled := False;
  qrNovaAposta.Open;
  qrNACompeticao.Open;
  qrNAMandante.Open;
  qrNAVisitante.Open;
  qrNAEstrategia.Open;
  qrNAUnidade.Open;
  qrNASituacao.Open;
  qrNovaAposta.First;
  PreencherComboBox;
  CalcularValorAposta;

  // Listar competições no ComboBox "Competição":
  while not qrNACompeticao.EOF do
    begin
    cbCompeticao.items.AddObject(
      qrNACompeticao.FieldByName('Competição').AsString,
      TObject(qrNACompeticao.FieldByName('Competição').AsString));
    qrNACompeticao.Next;
    end;

  //Listar times no ComboBox "Mandante":
  while not qrNAMandante.EOF do
    begin
    cbMandante.Items.AddObject(
      qrNAMandante.FieldByName('Time').AsString,
      TObject(qrNAMandante.FieldByName('Time').AsString));
    qrNAMandante.Next;
    end;

  //Listar times no ComboBox "Visitante":
  while not qrNAVisitante.EOF do
    begin
    cbVisitante.Items.AddObject(
      qrNAVisitante.FieldByName('Time').AsString,
      TObject(qrNAVisitante.FieldByName('Time').AsString));
    qrNAVisitante.Next;
    end;

  //Listar estratégias no ComboBox "Estratégia":
  while not qrNAEstrategia.EOF do
    begin
    cbEstrategia.Items.AddObject(
      qrNAEstrategia.FieldByName('Estratégia').AsString,
      TObject(qrNAEstrategia.FieldByName('Estratégia').AsString));
    qrNAEstrategia.Next;
    end;
  //Listar unidades no ComboBox "Unidade":
  while not qrNAUnidade.EOF do
    begin
    cbUnidade.Items.AddObject(
      qrNAUnidade.FieldByName('Unidade').AsString,
      TObject(qrNAUnidade.FieldByName('Unidade').AsString));
    qrNAUnidade.Next;
    end;
  //Exibir valor padrão do edtValor:
  CalcularValorAposta;
  //Listar Situações no ComboBox "Situação":
  while not qrNASituacao.EOF do
    begin
    cbSituacao.Items.AddObject(
      qrNASituacao.FieldByName('Status').AsString,
      TObject(qrNASituacao.FieldByName('Status').AsString));
    qrNASituacao.Next;
    end;
  //Valores padrão dos Campos
  {deAposta.Date := Now;}
  cbUnidade.ItemIndex  := cbUnidade.Items.IndexOf('1 Un');
  cbSituacao.ItemIndex := cbSituacao.Items.IndexOf('Pré-Live');
  {cbUnidade.Text := ('1 Un');
  cbSituacao.Text := ('Pré-Live');)}

  if (deAposta.Text <> '') and (cbMandante.Text <> '') and
    (cbVisitante.Text <> '') and (cbEstrategia.Text <> '') and
    (edtOdd.Text <> '') and (edtValor.Text <> '') and (cbSituacao.Text <> '') and
    (cbCompeticao.Text <> '') then
    btnOk.Enabled := True
  else
    btnOk.Enabled := False;
end;

procedure TformNovaAposta.FormShow(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.PreencherComboBox;
begin
  deAposta.Date := Now;
  cbUnidade.ItemIndex := cbUnidade.Items.IndexOf('1 Un');
  cbSituacao.ItemIndex := cbSituacao.Items.IndexOf('Pré-Live');

  if (deAposta.Text <> '') and (cbMandante.Text <> '') and
    (cbVisitante.Text <> '') and (cbEstrategia.Text <> '') and
    (edtOdd.Text <> '') and (edtValor.Text <> '') and (cbSituacao.Text <> '') and
    (cbCompeticao.Text <> '') then
    btnOk.Enabled := True
  else
    btnOk.Enabled := False;
end;


//Calcular valor da aposta
procedure TformNovaAposta.CalcularValorAposta;
var
  CalcUnidade, ValorAposta: double;
  qrDefinirStake: TSQLQuery;
begin

  //Coletando valor da stake do banco de dados
    try
    qrDefinirStake := TSQLQuery.Create(nil);
    qrDefinirStake.DataBase := formPrincipal.conectBancoDados;
    qrDefinirStake.SQL.Text :=
      'SELECT Stake FROM Banca WHERE Mês = :mesSelecionado AND Ano = :anoSelecionado';
    qrDefinirStake.ParamByName('mesSelecionado').AsInteger := mesSelecionado;
    qrDefinirStake.ParamByName('anoSelecionado').AsInteger := anoSelecionado;
    qrDefinirStake.Open;
    stakeAposta := qrDefinirStake.FieldByName('Stake').AsFloat;
    finally
    qrDefinirStake.Free;
    end;

  //Calculando valor da aposta
  if cbUnidade.Text <> 'Outro Valor' then
    begin
    case cbUnidade.Text of
      '0,25 Un': CalcUnidade := 0.25;
      '0,5 Un': CalcUnidade  := 0.5;
      '0,75 Un': CalcUnidade := 0.75;
      '1 Un': CalcUnidade    := 1.0;
      '1,25 Un': CalcUnidade := 1.25;
      '1,5 Un': CalcUnidade  := 1.5;
      '1,75 Un': CalcUnidade := 1.75;
      '2 Un': CalcUnidade    := 2.0;
      else
        CalcUnidade := 1.0;
      end;
    ValorAposta   := stakeAposta * CalcUnidade;
    edtValor.Text := FloatToStr(ValorAposta);

    end;
end;

procedure TformNovaAposta.HabilitarBotaoOk;
begin
  if (deAposta.Text <> '') and (cbMandante.Text <> '') and
    (cbVisitante.Text <> '') and (cbEstrategia.Text <> '') and
    (edtOdd.Text <> '') and (edtValor.Text <> '') and (cbSituacao.Text <> '') and
    (cbCompeticao.Text <> '') then
    btnOk.Enabled := True
  else
    btnOk.Enabled := False;
end;

procedure TformNovaAposta.cbCompeticaoKeyUp(Sender: TObject;
var Key: word; Shift: TShiftState);
var
  PesquisarTexto: string;
begin
  PesquisarTexto := TDbComboBox(Sender).Text;
  qrNACompeticao.Close;
  qrNACompeticao.SQL.Text :=
    'Select * from Competições where Competição like :PesquisarTexto';
  qrNACompeticao.ParamByName('PesquisarTexto').AsString := '%' + PesquisarTexto + '%';
  qrNACompeticao.Open;
end;

procedure TformNovaAposta.cbEstrategiaChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.cbMandanteChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.cbSituacaoChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TformNovaAposta.btnOkClick(Sender: TObject);
begin
    try
       qrNovaAposta.Close;
    qrNovaAposta.SQL.Clear;
    qrNovaAposta.SQL.Text :=
      'INSERT INTO Apostas (Data, Competição_AP, Mandante, Visitante, ' +
      'Estratégia_Escolhida, Odd, Unidade, Valor_Aposta, Status) ' +
      'VALUES (:Data, :Competição, :Mandante, :Visitante, :Estratégia, ' +
      ':Odd, :Unidade, :ValorApostado, :Situação)';

    qrNovaAposta.ParamByName('Data').AsString := FormatDateTime('YYYY-MM-DD', deAposta.Date);
    qrNovaAposta.ParamByName('Competição').AsString := cbCompeticao.Text;
    qrNovaAposta.ParamByName('Mandante').AsString := cbMandante.Text;
    qrNovaAposta.ParamByName('Visitante').AsString := cbVisitante.Text;
    qrNovaAposta.ParamByName('Estratégia').AsString := cbEstrategia.Text;
    qrNovaAposta.ParamByName('Odd').AsFloat := StrToFloat(edtOdd.Text);
    qrNovaAposta.ParamByName('ValorApostado').AsFloat := StrToFloat(edtValor.Text);
    qrNovaAposta.ParamByName('Unidade').AsString := cbUnidade.Text;
    qrNovaAposta.ParamByName('Situação').AsString := cbSituacao.Text;

    try
      qrNovaAposta.ExecSQL;
      formPrincipal.transactionBancoDados.Commit;
      formPrincipal.ReiniciarTodosOsQueries;
      MessageDlg('Aposta inserida com sucesso!', mtInformation, [mbOK], 0);
      Close;
    except
      on E: Exception do
      begin
        MessageDlg('Erro ao inserir nova aposta, se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        formPrincipal.transactionBancoDados.Rollback;
      end;
    end;
    except
    on E: Exception do
      begin
      MessageDlg('Erro',
        'Erro ao salvar dados, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: '
        + E.Message, mtError, [mbOK], 0);
      end;
    end;
end;


procedure TformNovaAposta.cbCompeticaoChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.cbUnidadeChange(Sender: TObject);
begin
  //Bloquear ou liberar o edtValor
  if cbUnidade.Text = 'Outro Valor' then
    begin
    edtValor.ReadOnly := False;
    edtValor.Color    := clWindow;
    edtValor.Cursor   := crIBeam;
    end
  else
    begin
    edtValor.ReadOnly := True;
    edtValor.Color    := clInactiveBorder;
    edtValor.Cursor   := crNo;
    end;
  //Chamar o procedimento para calcular o valor da aposta
  CalcularValorAposta;
end;



procedure TformNovaAposta.cbVisitanteChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.deApostaChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtOddChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtOddKeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then
    Key := ',';
end;

procedure TformNovaAposta.edtValorChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtValorKeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then
    Key := ',';
end;

procedure TformNovaAposta.edtValorMouseEnter(Sender: TObject);
begin
  if edtValor.ReadOnly then
    edtValor.Cursor := crNo;
end;

procedure TformNovaAposta.edtValorMouseLeave(Sender: TObject);
begin
  //  if edtValor.ReadOnly then
  //  edtValor.Cursor := crDefault;
end;



end.
