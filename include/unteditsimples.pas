unit untEditSimples;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBExtCtrls,
  ActnList, StdCtrls, DBCtrls, EditBtn, DBGrids, Menus, ComCtrls, Math,
  SQLScript, untApostas;

type

  { TformEditSimples }

  TformEditSimples = class(TForm)
    btnCancelar: TButton;
    btnNovaLinha: TButton;
    btnOk: TButton;
    cbCompeticao: TComboBox;
    cbMandante: TComboBox;
    cbVisitante: TComboBox;
    dsEditarAposta: TDataSource;
    grbNovaLinha: TGroupBox;
    grdEditarAposta: TDBGrid;
    lbCompeticao: TLabel;
    lbMandante2: TLabel;
    lbVisitante2: TLabel;
    qrEditarAposta: TSQLQuery;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure grdEditarApostaEditingDone(Sender: TObject);
  private

  public

  end;

var
  formEditSimples: TformEditSimples;
  Ok: boolean = False;
  EventosApostas: TEventosApostas;

implementation

uses untMain;

{$R *.lfm}

{ TformEditSimples }

procedure TformEditSimples.FormShow(Sender: TObject);
begin
  with qrEditarAposta do
  begin
    if Active then Close;
    ParamByName('CodAposta').AsInteger := EventosApostas.GlobalCodAposta;
    Open;
  end;
end;

procedure TformEditSimples.grdEditarApostaEditingDone(Sender: TObject);
begin
  with qrEditarAposta do
  begin
    Edit;
    Post;
    ApplyUpdates;
  end;
end;

procedure TformEditSimples.btnOkClick(Sender: TObject);
begin
  Ok := True;
  Close;
end;

procedure TformEditSimples.FormClose(Sender: TObject; var CloseAction: TCloseAction);
label
  Cancelar;
begin

  if not Ok then goto Cancelar;

  with formPrincipal do
  begin
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text :=
        'UPDATE Jogo JOIN Mercados ON Mercados.Cod_Jogo = Jogo.Cod_Jogo ' +
        'JOIN Competicoes ON Competicoes.Cod_Comp = Jogo.Cod_Comp ' +
        'SET Cod_Comp = Competicoes.Cod_Comp, Mandante = :mandante, ' +
        'Visitante = :visitante WHERE Mercados.Cod_Aposta = :CodAposta ' +
        'AND Competicoes.Competicao = :Comp';
      ParamByName('Comp').AsString := cbCompeticao.Text;
      ParamByName('mandante').AsString := cbMandante.Text;
      ParamByName('visitante').AsString := cbVisitante.Text;
      ParamByName('CodAposta').AsInteger := EventosApostas.GlobalCodAposta;
      ExecSQL;
      ApplyUpdates;
      transactionBancoDados.CommitRetaining;
      Free;
    except
      on E: Exception do
      begin
        Cancel;
        transactionBancoDados.RollbackRetaining;
        writeln('Erro no SQL: ' + SQL.Text);
        CloseAction := caNone;
        Free;
        MessageDlg('Erro ao salvar alterações, tente novamente. Se o problema ' +
          'persistir favor informar no GitHub com a seguinte mensagem: ' +
          sLineBreak + sLineBreak + E.Message, mtError, [mbOK], 0);
      end;
    end;
    Exit;

    Cancelar:

      if MessageDlg('Confirmação', 'Tem certeza que deseja cancelar a edição da aposta?',
      mtConfirmation, [mbYes, mbNo], 0) = mrNo then
        CloseAction := caNone
      else
        transactionBancoDados.RollbackRetaining;
  end;
end;

procedure TformEditSimples.btnCancelarClick(Sender: TObject);
begin
  Ok := False;
  Close;
end;

end.
