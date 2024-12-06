unit untBoasVindas;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
  TACustomSeries, TAMultiSeries, DateUtils, contnrs, fgl, untMain;

type

  { TformBoasVindas }

  TformBoasVindas = class(TForm)
    btnGitHub:  TBitBtn;
    btnDoacao:  TBitBtn;
    chbExibirNovamente: TDBCheckBox;
    dsExibirJanela: TDataSource;
    Image1:     TImage;
    lbAtencao:  TLabel;
    lbBemVindo: TLabel;
    mmIntro:    TMemo;
    mmAtencao:  TMemo;
    qrExibirJanela: TSQLQuery;
    qrExibirJanelaExibirTelaBoasVindas: TBooleanField;
    procedure chbExibirNovamenteClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CliqueBotao(Sender: TObject);
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
        Checked := AsBoolean;
      end;
end;

procedure TformBoasVindas.CliqueBotao(Sender: TObject);
var
  Botao: TButton;
begin
  case Botao.Name of
    'btnDoacao': OpenURL('https://link.mercadopago.com.br/graxaimgestaodebanca');
    'btnGitHub': OpenURL('https://github.com/FeroxGraxaim/graxaimgestaodebanca');
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
            if not Active then Open;
            Edit;
            AsBoolean := Checked;
            Post;
            CommitRetaining;
          except
            Cancel;
            RollbackRetaining;
          end;
end;

end.
