unit untMultipla;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
Iphttpbroker, DateUtils, Math, Grids, TAChartAxisUtils, untMain;

type

{ TEventosMultiplas }

TEventosMultiplas = class(TformPrincipal)

public
  contMult: integer;
  cloneMultipla, cloneInfoMult: TPanel;

  procedure SalvaContadorNovaMultipla;
  procedure CarregaContadorNovaMultipla;
  procedure CriaMultipla(Contador: integer);
  procedure tsMultiplaShow(Sender: TObject);
  procedure btnNovaMultClick(Sender: TObject);
  procedure btnExcMultClick(Sender: TObject);
end;

implementation

{ TEventosMultiplas }

procedure TEventosMultiplas.tsMultiplaShow(Sender: TObject);
begin
  with formPrincipal do
    begin
    if not conectBancoDados.Connected then conectBancoDados.Connected := True;

    CarregaContadorNovaMultipla;
    CriaMultipla(contMult);
    end;

end;

procedure TEventosMultiplas.SalvaContadorNovaMultipla;
begin

end;

procedure TEventosMultiplas.CarregaContadorNovaMultipla;
var
  qrContMult: TSQLQuery;
begin
  with formPrincipal do
    begin
      try
      qrContMult := TSQLQuery.Create(nil);
      qrContMult.DataBase := conectBancoDados;
      qrContMult.SQL.Text := 'SELECT COUNT(*) AS TotalLinhas FROM "Aposta Múltipla"';
      qrContMult.Open;
      contMult := qrContMult.FieldByName('TotalLinhas').AsInteger;
      except
      on E: Exception do
        begin
        writeln('Erro ao carregar dados do Query: ' + E.Message);
        qrContMult.Cancel;
        end;
      end;
    qrContMult.Free;
    end;
end;

procedure TEventosMultiplas.CriaMultipla(Contador: integer);
var
  i, j:  integer;
  componente: TComponent;
  novoComponente: TComponent;
  query: TSQLQuery;
begin
  with formPrincipal do
    begin
      try
      query := TSQLQuery.Create(nil);
      query.Database := conectBancoDados;
      query.SQL.Text := 'SELECT * FROM "Aposta Múltipla"';
      query.InsertSQL.Text :=
        'INSERT INTO "Aposta Múltipla" ("Selec.", Data, Cod_Jogo, Status, Valor, Retorno) VALUES ("Selec.", Data, Cod_Jogo, Status, Valor, Retorno)';
      query.Open;
      query.Append;
      query.Insert;
      query.ApplyUpdates;
      transactionBancoDados.Commit;

      for i := 1 to Contador do
        begin
        Inc(contMult); // Incrementa o contador global

        // Cria o painel clone
        cloneMultipla      := TPanel.Create(Self);
        cloneMultipla.Parent := scrlTodasMultiplas;
        cloneMultipla.Left := pnMultipla.Left;
        cloneMultipla.Top  := scrlTodasMultiplas.Top + contMult * (pnMultipla.Height + 10);
        cloneMultipla.Width := pnMultipla.Width;
        cloneMultipla.Height := pnMultipla.Height;
        cloneMultipla.Name := 'pnMultipla' + IntToStr(contMult);
        cloneMultipla.Caption := '';

        // Clona os componentes do painel original
        for j := 0 to pnMultipla.ControlCount - 1 do
          begin
          componente := pnMultipla.Controls[j];
          if componente <> nil then
            begin
            novoComponente      :=
              TComponentClass(componente.ClassType).Create(cloneMultipla);
            novoComponente.Name := componente.Name + IntToStr(contMult);
            TControl(novoComponente).Left := TControl(componente).Left;
            TControl(novoComponente).Top := TControl(componente).Top;
            TControl(novoComponente).Width := TControl(componente).Width;
            TControl(novoComponente).Height := TControl(componente).Height;
            novoComponente.Name := componente.Name + IntToStr(contMult);
            cloneMultipla.InsertControl(TControl(novoComponente));

            if componente is TButton then
              begin
              TButton(novoComponente).Caption := TButton(componente).Caption;
              TButton(novoComponente).OnClick := TButton(componente).OnClick;
              end
            else if componente is TLabel then
                begin
                TLabel(novoComponente).Font.Name := TLabel(componente).Font.Name;
                TLabel(novoComponente).Font.Size := TLabel(componente).Font.Size;

                case componente.Name of
                  'lbData':
                    begin
                    if query.Active then query.Close;
                    query.SQL.Text :=
                      'SELECT Data FROM "Aposta Múltipla" WHERE ROWID = :rowid';
                    query.ParamByName('rowid').AsInteger := contMult;
                    query.Open;
                    TLabel(novoComponente).Caption :=
                      FormatDateTime('yyyy-mm-dd', query.FieldByName('Data').AsDateTime);
                    query.Close;
                    end;
                  'lbRetorno':
                    begin
                    if query.Active then query.Close;
                    query.SQL.Text :=
                      'SELECT Retorno FROM "Aposta Múltipla" WHERE ROWID = :rowid';
                    query.ParamByName('rowid').AsInteger := contMult;
                    query.Open;
                    TLabel(novoComponente).Caption :=
                      'R$ ' + FloatToStr(query.FieldByName('Retorno').AsFloat);
                    query.Close;
                    end;
                  'lbSituacao':
                    begin
                    if query.Active then query.Close;
                    query.SQL.Text :=
                      'SELECT Status FROM "Aposta Múltipla" WHERE ROWID = :rowid';
                    query.ParamByName('rowid').AsInteger := contMult;
                    query.Open;
                    TLabel(novoComponente).Caption :=
                      query.FieldByName('Status').AsString;
                    query.Close;
                    case TLabel(novoComponente).Caption of
                      'Green': TLabel(novoComponente).Font.Color := clGreen;
                      'Red': TLabel(novoComponente).Font.Color   := clRed;
                      'Anulada': TLabel(novoComponente).Font.Color := clYellow;
                      'Cashout': TLabel(novoComponente).Font.Color := clSkyBlue;
                      'Pré-live': TLabel(novoComponente).Font.Color := clDefault;
                      'Meio Green': TLabel(novoComponente).Font.Color := $0000FFB4;
                      'Meio Red': TLabel(novoComponente).Font.Color := $000084FF;
                      end;
                    end;
                  end;
                end
              else if componente is TCheckBox then
                  begin
                  TCheckBox(novoComponente).Caption := '';
                  TCheckBox(novoComponente).Checked := TCheckBox(componente).Checked;
                  TCheckBox(novoComponente).OnClick := TCheckBox(componente).OnClick;
                  end;
            end;
          end;
        end;
      except
      on E: Exception do
        begin
        writeln('Erro: ' + E.Message);
        end;
      end;
    end;
end;

procedure TEventosMultiplas.btnNovaMultClick(Sender: TObject);
begin
  CriaMultipla(1);
end;

procedure TEventosMultiplas.btnExcMultClick(Sender: TObject);
var
  query: TSQLQuery;
begin
  if MessageDlg('Confirmação', 'Tem certeza que quer excluir a(s) aposta(s) selecionada(s)?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
    with formPrincipal do
      begin
      query := TSQLQuery.Create(nil)
      query.Database := conectBancoDados;
      query.SQL.Text := 'DELETE FROM Jogos ' +
                        'WHERE Cod_Mult IN ( ' +
                        'SELECT Cod_Mult ' +
                        'FROM "Apostas Múltiplas" ' +
                        'WHERE "Selec." = 1 ';
      query.ExecSQL;
      query.ApplyUpdates;
      transactionBancoDados.Commit;
      query.SQL.Text := 'DELETE FROM "Apostas Múltiplas" ' +
      'WHERE "Selec." = 1 AND Cod_Mult IN (SELECT Cod_Mult FROM Jogos);';
      query.ApplyUpdates;
      transactionBancoDados.Commit;
      query.Free;
      cloneMultipla.Free;
      cloneInfoMult.Free;
      CarregaContadorNovaMultipla;
      CriaMultipla(contMult);
      end;
    end;
end;

end.
