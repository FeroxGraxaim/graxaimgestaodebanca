unit untCampeonatos;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries, DateUtils,
Grids, untMain;

type
TEventosCampeonatos = class(TformPrincipal)

public
  procedure tsCampeonatosShow(Sender: TObject);
end;

implementation

procedure TEventosCampeonatos.tsCampeonatosShow(Sender: TObject);
begin
  with formPrincipal do
    begin
    if not qrCampeonatos.Active then
      qrCampeonatos.Open;
    writeln ('Encontrados ',qrCampeonatos.RecordCount,' campeonatos');
    end;
end;

end.
