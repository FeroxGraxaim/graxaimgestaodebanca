unit untConfig;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBCtrls;

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
    Edit;
    Checked := AsBoolean;
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

