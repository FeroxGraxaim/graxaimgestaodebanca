unit untSobre;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons;

type

  { TformSobre }

  TformSobre = class(TForm)
    btnApoie: TBitBtn;
    btnGithub: TBitBtn;
    graxaimFoto: TImage;
    Label1: TLabel;
    lbFerox: TLabel;
    procedure btnApoieClick(Sender: TObject);
    procedure btnGithubClick(Sender: TObject);
  private

  public

  end;

var
  formSobre: TformSobre;

implementation
uses
  untMain, fpjson, HTTPDefs, fphttpclient, jsonparser, LCLIntf;

{$R *.lfm}

{ TformSobre }

procedure TformSobre.btnGithubClick(Sender: TObject);
begin
  openurl('https://github.com/FeroxGraxaim');
end;

procedure TformSobre.btnApoieClick(Sender: TObject);
begin
  openurl('https://link.mercadopago.com.br/graxaimgestaodebanca');
end;

end.

