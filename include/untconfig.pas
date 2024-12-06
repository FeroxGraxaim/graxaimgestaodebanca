unit untConfig;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
  TACustomSeries, TAMultiSeries, DateUtils, fgl;

type

  { TformConfig }

  TformConfig = class(TForm)
    chbUpdate: TDBCheckBox;
    procedure chbUpdateClick(Sender: TObject);
  private

  public

  end;

var
  formConfig: TformConfig;

implementation

uses untMain;

  {$R *.lfm}

  { TformConfig }

procedure TformConfig.chbUpdateClick(Sender: TObject);
begin
  with formPrincipal do
    with transactionBancoDados do
      with qrConfig do
        with FieldByName('PreRelease') do
          with chbUpdate do
          try
            writeln('Habilitando/desabilitando pre-release');
            Edit;
            AsBoolean := Checked;
            Post;
            ApplyUpdates;
            CommitRetaining;
          except
            on E: Exception do
            begin
              Cancel;
              RollbackRetaining;
              writeln('Erro ao aplicar: ' + E.Message);
            end;
          end;
end;

end.
