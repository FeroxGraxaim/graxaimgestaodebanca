unit untMetodoLinha;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons;

type

  { TformMetodoLinha }

  TformMetodoLinha = class(TForm)
    BitBtn1: TBitBtn;
    cbMet:    TComboBox;
    edtLinha: TLabeledEdit;
    lbLin:   TLabel;
    procedure FormShow(Sender: TObject);
    function Linha: string;
    function Metodo: string;
  private

  public

  end;

var
  formMetodoLinha: TformMetodoLinha;

implementation

uses
  untMain;

{$R *.lfm}

{ TformMetodoLinha }

procedure TformMetodoLinha.FormShow(Sender: TObject);
begin
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      cbMet.Items.Clear;
      DataBase := conectBancoDados;
      SQL.Text := 'SELECT Nome FROM Métodos';
      Open;
      First;
      while not EOF do
      begin
        cbMet.Items.Add(FieldByName('Nome').AsString);
        Next;
      end;
      cbMet.ItemIndex := 0;
    finally
      Free;
    end;
end;

function TformMetodoLinha.Linha: string;
begin
  Result := edtLinha.Text;
end;

function TformMetodoLinha.Metodo: string;
begin
  Result := cbMet.Text;
end;

end.
