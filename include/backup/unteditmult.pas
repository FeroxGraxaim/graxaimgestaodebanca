unit untEditMult;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids;

type

  { TformEditMult }

  TformEditMult = class(TForm)
    btnCancelar: TButton;
    btnNovaLinha: TButton;
    btnNovoJogo: TButton;
    btnRemoverJogo: TButton;
    btnRemoverLinha: TButton;
    btnOk: TButton;
    grbNovaLinha: TGroupBox;
    grbJogos: TGroupBox;
    grdNovaAposta: TDBGrid;
    grdJogos: TDBGrid;
  private

  public

  end;

var
  formEditMult: TformEditMult;

implementation

{$R *.lfm}

end.

