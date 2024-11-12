unit untBoasVindas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
  TACustomSeries, TAMultiSeries, DateUtils, contnrs, fgl, untMain;

type

  { TformBoasVindas }

  TformBoasVindas = class(TForm)
    btnGitHub: TBitBtn;
    btnDoacao: TBitBtn;
    chbExibirNovamente: TDBCheckBox;
    dsExibirJanela: TDataSource;
    Image1: TImage;
    lbAtencao: TLabel;
    lbBemVindo: TLabel;
    mmIntro: TMemo;
    mmAtencao: TMemo;
    qrExibirJanela: TSQLQuery;
    qrExibirJanelaExibirTelaBoasVindas: TBooleanField;
    procedure btnDoacaoClick(Sender: TObject);
    procedure btnGitHubClick(Sender: TObject);
    procedure chbExibirNovamenteClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  formBoasVindas: TformBoasVindas;
  LocalArquivo: string;
  Arquivo: TStringList;

implementation

uses
  fpjson, HTTPDefs, fphttpclient, jsonparser, LCLIntf;

  {$R *.lfm}

  { TformBoasVindas }

procedure TformBoasVindas.FormShow(Sender: TObject);
begin
  writeln('Exibindo tela de boas-vindas');
  with qrExibirJanela do
    with chbExibirNovamente do
      with FieldByName('ExibirTelaBoasVindas') do
      begin
        if not Active then Open;
        if AsBoolean = True then
          Checked := True
        else
          Checked := False;
      end;
end;

procedure TformBoasVindas.chbExibirNovamenteClick(Sender: TObject);
begin
  with formPrincipal do
    with qrExibirJanela do
      with FieldByName('ExibirTelaBoasVindas') do
        with transactionBancoDados do
          with chbExibirNovamente do
          try
            Open;
            Edit;
            if AsBoolean = True then
              Checked := True
            else
              Checked := False;
            Post;
            ApplyUpdates;
            CommitRetaining;
          except
            on E: Exception do
            begin
              Cancel;
              RollbackRetaining;
              raise Exception.Create('Não foi possível salvar configurações da ' +
              'tela de boas-vindas, ' + E.Message);
            end;
          end;
end;

procedure TformBoasVindas.btnGitHubClick(Sender: TObject);
begin
  OpenURL('https://github.com/FeroxGraxaim/graxaimgestaodebanca');
end;

procedure TformBoasVindas.btnDoacaoClick(Sender: TObject);
begin
  openurl('https://link.mercadopago.com.br/graxaimgestaodebanca');
end;

end.
