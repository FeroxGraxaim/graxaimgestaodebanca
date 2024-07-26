Unit MainFormDemo;

{$mode objfpc}{$H+}

Interface

Uses
   BufDataset,
   Classes,
   ComCtrls,
   Controls,
   crt,
   DB,
   DBCtrls,
   DBGrids,
   Dialogs,
   dxDBGridController,
   ExtCtrls,
   Forms,
   Graphics,
   Grids,
   RTTIGrids,
   StdCtrls,
   SysUtils;

Var
   sDistinct:         String;
   sCount:            String;
   sMin:              String;
   sMax:              String;
   sAvg:              String;
   sSum:              String;
   sProjectWithTaxes: String;
   sProjectWithoutTaxes: String;

Type

   { TfmMainDemo }

   TfmMainDemo = Class(TForm)
      btnHideGroupLine:        TButton;
      btnSortColumn:           TButton;
      btnLinkController:       TButton;
      btnChangeSearchBox:      TButton;
      btnGroupOnClient:        TButton;
      btnUnlinkController:     TButton;
      btnDestroyController:    TButton;
      btnUnitTesting:          TButton;
      btnClearAllFilters:      TButton;
      btnShowHideFooter:       TButton;
      btnDeleteProject:        TButton;
      btnClearSort:            TButton;
      btnSaveGridView:         TButton;
      btnActivateGridHint:     TButton;
      btnLoadGridView:         TButton;
      btnCreateProject:        TButton;
      lbControllerProperties:  TLabel;
      lbGridProperties1:       TLabel;
      qLUClientBuf:            TBufDataset;
      cbLocalization:          TComboBox;
      grdProject:              TDBGrid;
      dxDBGridController:      TdxDBGridController;
      gbSortingInformation:    TGroupBox;
      gbCustomAggregation:     TGroupBox;
      gbDatasetInformation:    TGroupBox;
      lblSQLOrderby:           TLabel;
      lblIndexFieldNames:      TLabel;
      lblIndexName:            TLabel;
      lbMaxAmount:             TLabel;
      lbIndexFieldNames:       TLabel;
      lbIndexName:             TLabel;
      lbMinAmount:             TLabel;
      lbAvgAmount:             TLabel;
      lbSQLOrderby:            TLabel;
      pnlRight:                TPanel;
      pnlClientPanel:          TPanel;
      pnlButtonPanel:          TPanel;
      pnlFooterPanel:          TPanel;
      pbProgressBar:           TProgressBar;
      qLUClientBufCode:        TStringField;
      qLUClientBufLookupValue: TStringField;
      qLUClientBufName:        TStringField;
      qLUClientBufPK_Client:   TLongintField;
      qProjectBuf:             TBufDataset;
      dsProject:               TDataSource;
      qProjectBufAmount:       TCurrencyField;
      qProjectBufEndDate:      TDateTimeField;
      qProjectBufFK_Client:    TLongintField;
      qProjectBufLUClient:     TStringField;
      qProjectBufNote:         TMemoField;
      qProjectBufPK_Project:   TAutoIncField;
      qProjectBufProjectManager: TStringField;
      qProjectBufProjectNumber: TStringField;
      qProjectBufStartDate:    TDateTimeField;
      qProjectBufWithTaxes:    TBooleanField;
      Splitter1:               TSplitter;
      Splitter2:               TSplitter;
      stMaxAmount:             TStaticText;
      stMinAmount:             TStaticText;
      stAvgAmount:             TStaticText;
      TIPropertyGrid:          TTIPropertyGrid;
      TIPropertyDataset:       TTIPropertyGrid;
      Procedure btnActivateGridHintClick(Sender: TObject);
      Procedure btnChangeSearchBoxClick(Sender: TObject);
      Procedure btnClearAllFiltersClick(Sender: TObject);
      Procedure btnClearSortClick(Sender: TObject);
      Procedure btnCreateProjectClick(Sender: TObject);
      Procedure btnDeleteProjectClick(Sender: TObject);
      Procedure btnDestroyControllerClick(Sender: TObject);
      Procedure btnGroupOnClientClick(Sender: TObject);
      Procedure btnHideGroupLineClick(Sender: TObject);
      Procedure btnLinkControllerClick(Sender: TObject);
      Procedure btnSaveGridViewClick(Sender: TObject);
      Procedure btnShowHideFooterClick(Sender: TObject);
      Procedure btnSortColumnClick(Sender: TObject);
      Procedure btnUnitTestingClick(Sender: TObject);
      Procedure btnUnlinkControllerClick(Sender: TObject);
      Procedure btnLoadGridViewClick(Sender: TObject);
      Procedure cbLocalizationChange(Sender: TObject);
      Procedure dxDBGridControllerAfterAggregation(Sender: TdxDBGridController);
      Procedure dxDBGridControllerAfterSortColumn(Sender: TObject; Column: TColumn; IndexFieldNames, AscFieldNames, DescFieldNames, IndexName,
         SQLOrderBy: String);
      Procedure dxDBGridControllerAggregation(Sender: TdxDBGridController);
      Procedure dxDBGridControllerLocalize(Sender: TObject; Component: TComponent; ID_Ressource: String; Var Translation: String);
      Procedure dxDBGridControllerSortColumn(Sender: TObject; Column: TColumn; IndexFieldNames, AscFieldNames, DescFieldNames, IndexName, SQLOrderBy: String);
      Procedure FormCreate(Sender: TObject);
      Procedure grdProjectDrawColumnCell(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
      Procedure grdProjectDrawColumnTitle(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
      Procedure grdProjectEditButtonClick(Sender: TObject);
      Procedure grdProjectGetCellHint(Sender: TObject; Column: TColumn; Var AText: String);
      Procedure grdProjectKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
      Procedure grdProjectMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      Procedure grdProjectMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      Procedure grdProjectTitleClick(Column: TColumn);
   private
      Procedure CreateClient;
      Procedure CreateController;
      Procedure CreateProject(Batch: Integer = 100);
      Procedure DeleteProject(Batch: Integer = 100);
      Procedure InitDataset;

   public
      nCounter: Integer;
   End;

Var
   fmMainDemo: TfmMainDemo;

Implementation

{$R *.lfm}

{ TfmMainDemo }


Procedure TfmMainDemo.InitDataset;
Begin
   qLUClientBuf.MaxIndexesCount := 20; // Not necessary...
   qLUClientBuf.CreateDataset;
   qLUClientBuf.FieldByName('PK_Client').Visible := False;
   qLUClientBuf.FieldByName('PK_Client').DisplayLabel := 'PK_Client';
   qLUClientBuf.FieldByName('LookupValue').Visible := False;
   qLUClientBuf.FieldByName('LookupValue').DisplayLabel := 'Client';
   qLUClientBuf.FieldByName('Code').Alignment := taCenter;
   qLUClientBuf.FieldByName('Code').DisplayLabel := 'Code';
   qLUClientBuf.FieldByName('Name').DisplayLabel := 'Name';
   qLUClientBuf.Active          := True;

   qProjectBuf.MaxIndexesCount := 20;
   qProjectBuf.CreateDataset;
   qProjectBuf.FieldByName('PK_Project').Visible := False;
   // qProjectBuf.FieldByName('FK_Client').Visible := False;
   qProjectBuf.FieldByName('PK_Project').DisplayLabel := 'PK_Project';
   qProjectBuf.FieldByName('ProjectNumber').Alignment := taCenter;
   qProjectBuf.FieldByName('ProjectNumber').DisplayLabel := 'Project Number';
   qProjectBuf.FieldByName('StartDate').DisplayLabel := 'Start Date';
   qProjectBuf.FieldByName('StartDate').Alignment := taCenter;
   qProjectBuf.FieldByName('EndDate').DisplayLabel := 'End Date';
   qProjectBuf.FieldByName('EndDate').Alignment := taCenter;
   qProjectBuf.FieldByName('ProjectManager').DisplayLabel := 'Project Manager';
   qProjectBuf.FieldByName('LUClient').DisplayLabel := 'Client';
   qProjectBuf.Active          := True;

End;


Procedure TfmMainDemo.CreateClient;
Var
   i:     Integer;
   sCode: String;
Begin
   Try
      Screen.Cursor := crHourGlass;
      qLUClientBuf.DisableControls;
      For i         := 0 To 1000 Do
      Begin
         qLUClientBuf.insert;
         sCode := '0000000' + IntToStr(i);
         sCode := 'C' + copy(sCode, Length(sCode) - 5, Length(sCode));
         qLUClientBuf.FieldByName('PK_Client').AsInteger := i;
         qLUClientBuf.FieldByName('Code').AsString := sCode;
         qLUClientBuf.FieldByName('Name').AsString := 'Client name ' + IntToStr(i);
         qLUClientBuf.FieldByName('LookupValue').AsString := qLUClientBuf.FieldByName('Code').AsString + ' - ' +
            qLUClientBuf.FieldByName('Name').AsString;
         qLUClientBuf.Post;
      End;
   Finally
      qLUClientBuf.EnableControls;
      Screen.Cursor := crDefault;
   End;
End;


Procedure TfmMainDemo.CreateProject(Batch: Integer);
Var
   sProjectNumber:  String;
   sProjectManager: Array [0..10] Of String;
   sNote:           Array [0..11] Of String;
   sBranchOffice:   String;
Begin
   sProjectManager[0]  := 'Agilera, Lucy';
   sProjectManager[1]  := 'Corto, Peter';
   sProjectManager[2]  := 'Tamy, Lea';
   sProjectManager[3]  := 'Cardinal, Luis';
   sProjectManager[4]  := 'Parmilo, Guy';
   sProjectManager[5]  := 'Santa, Annita';
   sProjectManager[6]  := 'Riopel, Marc';
   sProjectManager[7]  := 'Venn, Clara';
   sProjectManager[8]  := 'Tulum, Richard';
   sProjectManager[9]  := 'Denis, Peter';
   sProjectManager[9]  := 'Jarry, Martine';
   sProjectManager[10] := 'Jarry, Simon';

   sNote[0]  := 'At vero eos et accusamus et iusto odio';
   sNote[1]  := 'Dignissimos ducimus qui blanditiis praesentium voluptatum';
   sNote[2]  := 'Deleniti atque corrupti quos dolores et quas molestias';
   sNote[3]  := 'Eexcepturi sint occaecati cupiditate non provident';
   sNote[4]  := 'Similique sunt in culpa qui officia deserunt mollitia animi';
   sNote[5]  := 'Id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio';
   sNote[6]  := 'Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit';
   sNote[7]  := 'Quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est';
   sNote[8]  := 'Omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut ';
   sNote[9]  := 'Rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae';
   sNote[10] := 'Itaque earum rerum hic tenetur a sapiente delectus';
   sNote[11] := 'Ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat';

   sBranchOffice := IntToStr(1000 + random(200));

   Try
      Screen.Cursor := crHourGlass;

      qProjectBuf.DisableControls;
      While Batch > 0 Do
      Begin
         qProjectBuf.Insert;
         sProjectNumber := '000000' + IntToStr(Batch);
         sProjectNumber := sBranchOffice + copy(sProjectNumber, Length(sProjectNumber) - 5, Length(sProjectNumber));
         qProjectBuf.FieldByName('ProjectNumber').AsString := sProjectNumber;
         qProjectBuf.FieldByName('ProjectManager').AsString := sProjectManager[random(11)];
         qProjectBuf.FieldByName('FK_Client').AsInteger := random(1000);
         If (Batch MOD (random(5) + 1)) = 0 Then
            qProjectBuf.FieldByName('WithTaxes').AsBoolean := False
         Else
            qProjectBuf.FieldByName('WithTaxes').AsBoolean := True;

         // Do not use a calculated field or a lookup field with the TBufDatset,
         // it is triggering and error if we apply an index on those kind of field.
         // The Controller is checking if the LookupDataset property is assigned on this field to accomplish the task.
         // Make sure you specified the KeyFields, LookupKeyFields and the LookupResultField properties.
         // When using a database, we can populate the lookupvalue with a join an set the providerflag to [] for this filed.
         If qLUClientBuf.Locate('PK_Client', qProjectBuf.FieldByName('FK_Client').AsInteger, []) Then
            qProjectBuf.FieldByName('LUClient').AsString := qLUClientBuf.FieldByName('LookupValue').AsString;

         qProjectBuf.FieldByName('StartDate').AsDateTime  := Date() - random(600) - 150;
         If (Batch MOD 25) = 0 Then
            qProjectBuf.FieldByName('EndDate').AsDateTime := qProjectBuf.FieldByName('StartDate').AsDateTime + 100;
         qProjectBuf.FieldByName('Note').AsString := sNote[random(12)] + Char(13) + Char(10) + sNote[random(12)];
         qProjectBuf.FieldByName('Amount').AsCurrency := 5000 + (random(600) * 100);
         qProjectBuf.Post;
         Dec(Batch);
      End;
   Finally

      qProjectBuf.EnableControls;
      Screen.Cursor := crDefault;
   End;
End;

Procedure TfmMainDemo.DeleteProject(Batch: Integer);
Begin
   Try
      Screen.Cursor := crHourGlass;
      qProjectBuf.DisableControls;
      While (Batch > 0) Do
      Begin
         If NOT qProjectBuf.IsEmpty Then
            qProjectBuf.Delete;
         Dec(Batch);
      End;
   Finally
      qProjectBuf.EnableControls;
      Screen.Cursor := crDefault;
   End;
End;

Procedure TfmMainDemo.FormCreate(Sender: TObject);
Begin

   // Use to limit the output event on inherited event handle -- unit testing
   nCounter := 0;

   InitDataset;
   CreateClient;
   // Create 2000 projects
   CreateProject(2000);

   // Set grid columns we want to Display
   With grdProject Do
   Begin
      Columns.Add;
      Columns.Add;
      Columns.Add;
      Columns.Add;
      Columns.Add;
      Columns.Add;
      Columns.Add;
      Columns.Add;

      Columns.Items[0].Width     := 120;
      Columns.Items[0].FieldName := 'ProjectNumber';
      Columns.Items[1].Width     := 180;
      Columns.Items[1].FieldName := 'ProjectManager';
      Columns.Items[2].Width     := 150;
      Columns.Items[2].FieldName := 'Amount';
      Columns.Items[3].Width     := 150;
      Columns.Items[3].FieldName := 'StartDate';
      Columns.Items[4].Width     := 150;
      Columns.Items[4].FieldName := 'EndDate';
      Columns.Items[5].Width     := 250;
      Columns.Items[5].FieldName := 'LUClient';
      Columns.Items[6].Width     := 150;
      Columns.Items[6].FieldName := 'WithTaxes';
      Columns.Items[7].Width     := 500;
      Columns.Items[7].FieldName := 'Note';

   End;

   // Important we assign the grid to the controler once the grid is ready and loaded
   If Assigned(dxDBGridController) Then
   Begin
      dxDBGridController.DBGrid := grdProject;
      // Use the FooterPanel property to set the footer height
      dxDBGridController.FooterPanel.Height := Trunc(grdProject.DefaultRowHeight * 2.8);
      dxDBGridController.FooterPanel.Color := grdProject.FixedColor;
      dxDBGridController.FooterPanel.BorderSpacing.Around := 3;
      dxDBGridController.FooterPanel.BorderStyle := bsSingle;
      // we can't do a refrech on BufDataset...
      dxDBGridController.Navigator.VisibleButtons := dxDBGridController.Navigator.VisibleButtons - [nbRefresh];
   End;
      // Localization
   cbLocalizationChange(self);

End;

Procedure TfmMainDemo.grdProjectDrawColumnCell(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
Begin
   If (nCounter MOD 500) = 0 Then
      writeln('---> Inherited OnDrawColumnCell');
   Inc(nCounter);
End;

Procedure TfmMainDemo.grdProjectDrawColumnTitle(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
Begin
   If (nCounter MOD 20) = 0 Then
      writeln('---> Inherited OnDrawColumnTitle');
   Inc(nCounter);
End;

Procedure TfmMainDemo.grdProjectEditButtonClick(Sender: TObject);
Begin
   writeln('---> Inherited OnEditButtonClick');
   Inc(nCounter);
End;

Procedure TfmMainDemo.grdProjectGetCellHint(Sender: TObject; Column: TColumn; Var AText: String);
Begin
   writeln('---> Inherited OnGetCellHint');
   Inc(nCounter);
End;

Procedure TfmMainDemo.grdProjectKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Begin
   writeln('---> Inherited OnKeyDown');
   Inc(nCounter);
End;

Procedure TfmMainDemo.grdProjectMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
   writeln('---> Inherited OnMouseDown');
   Inc(nCounter);
End;

Procedure TfmMainDemo.grdProjectMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
Begin
   If (nCounter MOD 10) = 0 Then
      writeln('---> Inherited OnMouseMove');
   Inc(nCounter);
End;

Procedure TfmMainDemo.grdProjectTitleClick(Column: TColumn);
Begin
   writeln('---> Inherited OnTitleClick');
   Inc(nCounter);
End;

Procedure TfmMainDemo.dxDBGridControllerAggregation(Sender: TdxDBGridController);
Begin

   Sender.ColumnPropertyList.ColumnPropertyByName('ProjectNumber').FooterAlignment   := taLeftJustify;
   Sender.ColumnPropertyList.ColumnPropertyByName('ProjectNumber').FooterDisplayText :=
      sCount + ': ' + Sender.ColumnPropertyList.Aggregation(agCount, 'ProjectNumber').AsString;

   Sender.ColumnPropertyList.ColumnPropertyByName('WithTaxes').FooterAlignment   := taRightJustify;
   Sender.ColumnPropertyList.ColumnPropertyByName('WithTaxes').FooterDisplayText :=
      sProjectWithTaxes + Sender.ColumnPropertyList.Aggregation(agMax, 'WithTaxes').AsString + Char(13) + Char(10) +
      sProjectWithoutTaxes + Sender.ColumnPropertyList.Aggregation(agMin, 'WithTaxes').AsString;

   Sender.ColumnPropertyList.ColumnPropertyByName('LUClient').FooterAlignment   := taLeftJustify;
   Sender.ColumnPropertyList.ColumnPropertyByName('LUClient').FooterDisplayText :=
      sDistinct + ': ' + Sender.ColumnPropertyList.Aggregation(agDistinct, 'LUClient').AsString;

   Sender.ColumnPropertyList.ColumnPropertyByName('ProjectManager').FooterAlignment   := taRightJustify;
   Sender.ColumnPropertyList.ColumnPropertyByName('ProjectManager').FooterDisplayText :=
      sDistinct + ': ' + Sender.ColumnPropertyList.Aggregation(agDistinct, 'ProjectManager').AsString;

   // Use the FooterPanel property to set the height
   // dxDBGridController.FooterPanel.Height := Self.DBGrid1.DefaultRowHeight * 2;
   Sender.ColumnPropertyList.ColumnPropertyByName('StartDate').FooterAlignment   := taCenter;
   Sender.ColumnPropertyList.ColumnPropertyByName('StartDate').FooterDisplayText :=
      sMin + ': ' + Sender.ColumnPropertyList.Aggregation(agMin, 'StartDate').AsString + Char(13) + Char(10) + sMax + ': ' +
      Sender.ColumnPropertyList.Aggregation(agMax, 'StartDate').AsString + Char(13) + Char(10) + sDistinct + ': ' +
      Sender.ColumnPropertyList.Aggregation(agDistinct, 'StartDate').AsString;

   // Use the FooterPanel property to set the height
   // dxDBGridController.FooterPanel.Height := Self.DBGrid1.DefaultRowHeight * 2;
   Sender.ColumnPropertyList.ColumnPropertyByName('Amount').FooterAlignment   := taRightJustify;
   Sender.ColumnPropertyList.ColumnPropertyByName('Amount').FooterDisplayText :=
      sAvg + ': ' + FloatToStrF(Sender.ColumnPropertyList.Aggregation(agAvg, 'Amount').AsFloat, ffcurrency, 10, 2) + Char(13) +
      Char(10) + sSum + ': ' + FloatToStrF(Sender.ColumnPropertyList.Aggregation(agSum, 'Amount').AsFloat, ffcurrency, 10, 2);

End;

Procedure TfmMainDemo.dxDBGridControllerLocalize(Sender: TObject; Component: TComponent; ID_Ressource: String; Var Translation: String);
Begin

   If cbLocalization.ItemIndex = 1 Then  // French
   Begin
      If ID_Ressource = msg_search Then
         Translation := 'Recherche...'
      Else If ID_Ressource = msg_first Then
         Translation := 'Aller au début'
      Else If ID_Ressource = msg_prior Then
         Translation := 'Précédent'
      Else If ID_Ressource = msg_next Then
         Translation := 'Suivant'
      Else If ID_Ressource = msg_last Then
         Translation := 'Aller à la fin'
      Else If ID_Ressource = msg_add Then
         Translation := 'Ajouter'
      Else If ID_Ressource = msg_delete Then
         Translation := 'Détruire'
      Else If ID_Ressource = msg_edit Then
         Translation := 'Éditer'
      Else If ID_Ressource = msg_save Then
         Translation := 'Enregistrer'
      Else If ID_Ressource = msg_cancel Then
         Translation := 'Annuler'
      Else If ID_Ressource = msg_refresh Then
         Translation := 'Actualiser'
      Else If ID_Ressource = msg_btncancel Then
         Translation := 'Annuler'
      Else If ID_Ressource = msg_of Then
         Translation := 'de'
      Else If ID_Ressource = msg_nodata Then
         Translation := 'Aucune donnée trouvée!'
      Else If ID_Ressource = msg_columnchooser Then
         Translation := 'Sélectionner les colonnes...'
      Else If ID_Ressource = msg_clearselection Then
         Translation := 'Annuler sélection'
      Else If ID_Ressource = msg_selectall Then
         Translation := 'Tout sélectionner'
      Else If ID_Ressource = msg_sortingasc Then
         Translation := 'Trier en mode croissant'
      Else If ID_Ressource = msg_sortingdesc Then
         Translation := 'Trier en mode décroissant';
   End
   Else
   If cbLocalization.ItemIndex = 0 Then  // English
      // Do notting .. english is the default value for the controller ressources
   ;

End;


Procedure TfmMainDemo.dxDBGridControllerSortColumn(Sender: TObject; Column: TColumn;
   IndexFieldNames, AscFieldNames, DescFieldNames, IndexName, SQLOrderBy: String);
Begin

   (*

   If your dataset is inherited from TBufDataset (Lazarus) or TMSQuery, TMSTable (Devart)
   you don't need to use this event handler, the controller will automatically detect the class and
   set the IndexDef or IndexFieldNames accordingly to the dataset you're using.
   You can use the SQLOrderBy value to requery your dataset on the db server side if needed.

   *)

End;


Procedure TfmMainDemo.btnSaveGridViewClick(Sender: TObject);
Begin
   btnLinkController.OnClick(self);
   dxDBGridController.SaveConfiguration;
End;

Procedure TfmMainDemo.btnShowHideFooterClick(Sender: TObject);
Begin
   btnLinkController.OnClick(self);
   If coShowFooter IN dxDBGridController.ControllerOptions Then
      dxDBGridController.ControllerOptions := dxDBGridController.ControllerOptions - [coShowFooter]
   Else
      dxDBGridController.ControllerOptions := dxDBGridController.ControllerOptions + [coShowFooter];
End;

Procedure TfmMainDemo.btnSortColumnClick(Sender: TObject);
Begin
   btnLinkController.OnClick(self);
   // Clear sort if necessary -> dxDBGridController.ClearSort;
   // If we are not clearing ... add columns to the current sorting sequence... it will change the sort order if already sorted
   dxDBGridController.SortColumnByFieldName('ProjectManager', soDESC);
   dxDBGridController.SortColumnByFieldName('Amount', soASC);
End;

Procedure TfmMainDemo.btnUnitTestingClick(Sender: TObject);
Var
   i, w: Integer;
Begin
   pbProgressBar.Visible := True;
   writeln('Start unit test .....');
   writeln('');

   application.ProcessMessages;
   writeln(self.btnUnlinkController.Caption);
   self.btnUnlinkController.OnClick(self);

   application.ProcessMessages;
   writeln(self.btnlinkController.Caption);
   self.btnLinkController.OnClick(self);

   application.ProcessMessages;
   writeln(self.btnDestroyController.Caption);
   self.btnDestroyController.OnClick(self);

   application.ProcessMessages;

   writeln(self.btnlinkController.Caption);
   self.btnLinkController.OnClick(self);

   application.ProcessMessages;
   writeln(self.btnCreateProject.Caption);
   self.btnCreateProject.OnClick(self);

   application.ProcessMessages;
   writeln(self.btnDeleteProject.Caption);
   self.btnDeleteProject.OnClick(self);

   application.ProcessMessages;
   writeln(self.btnlinkController.Caption);
   self.btnLinkController.OnClick(self);

   application.ProcessMessages;
   self.btnCreateProject.OnClick(self);
   writeln(self.btnDeleteProject.Caption);

   application.ProcessMessages;
   writeln(self.btnDeleteProject.Caption);
   self.btnDeleteProject.OnClick(self);

   application.ProcessMessages;
   writeln(self.btnlinkController.Caption);
   self.btnLinkController.OnClick(self);

   application.ProcessMessages;
   writeln('Search in column ProjectManager the expression : Mar');
   dxDBGridController.ColumnPropertyList.ColumnPropertyByName('ProjectManager').SearchEditor.Text := 'Mar';

   application.ProcessMessages;
   writeln('Restore Footer Panel Height');
   dxDBGridController.FooterPanel.Height      := Trunc(grdProject.DefaultRowHeight * 2.8);
   dxDBGridController.FooterPanel.Color       := grdProject.FixedColor;
   dxDBGridController.FooterPanel.BorderSpacing.Around := 3;
   dxDBGridController.FooterPanel.BorderStyle := bsSingle;

   application.ProcessMessages;
   writeln(self.btnShowHideFooter.Caption);
   self.btnShowHideFooter.OnClick(self);

   application.ProcessMessages;
   writeln(self.btnClearAllFilters.Caption);
   self.btnClearAllFilters.OnClick(self);
   delay(600);

   application.ProcessMessages;
   writeln('Empty qProjectBuf Dataset');
   //qProjectBuf.Filtered:=false;
   qProjectBuf.First;
   qProjectBuf.DisableControls;
   While NOT qProjectBuf.EOF Do
      qProjectBuf.Delete;
   qProjectBuf.EnableControls;

   application.ProcessMessages;
   i := random(4000);
   writeln(Format('Create %d Project', [i]));
   CreateProject(i);

   application.ProcessMessages;
   writeln('Search in grid the expression : lor');
   dxDBGridController.SearchEditor.Text := Copy(IntToHex(Random(Int64($7fffffffffffffff)), 4), 1, 2);//'lor';

   application.ProcessMessages;
   writeln('Variation on the Note column width');
   w     := dxDBGridController.ColumnByFieldName('Note').Width;
   For i := 0 To 10 Do
   Begin
      delay(10);
      application.ProcessMessages;
      dxDBGridController.ColumnByFieldName('Note').Width := w + i * 10;
   End;

   w     := dxDBGridController.ColumnByFieldName('Note').Width;
   For i := 10 Downto 0 Do
   Begin
      delay(10);
      application.ProcessMessages;
      dxDBGridController.ColumnByFieldName('Note').Width := w - i * 10;
   End;

   writeln('Move Amount column to the end');
   dxDBGridController.ColumnByFieldName('Amount').Index := dxDBGridController.DBGrid.Columns.Count - 1;
   dxDBGridController.ColumnByFieldName('Note').Width   := 200;

   writeln('');
   writeln('End unit test .....');
   pbProgressBar.Visible   := False;
   TIPropertyGrid.TIObject := dxDBGridController;

End;

Procedure TfmMainDemo.btnUnlinkControllerClick(Sender: TObject);
Begin
   If Assigned(dxDBGridController) Then
      dxDBGridController.DBGrid := nil;
End;

Procedure TfmMainDemo.btnCreateProjectClick(Sender: TObject);
Begin
   btnLinkController.OnClick(self);
   CreateProject(200);
   dxDBGridController.Refresh;
End;

Procedure TfmMainDemo.btnClearSortClick(Sender: TObject);
Begin
   btnLinkController.OnClick(self);
   dxDBGridController.ClearSort;
End;

Procedure TfmMainDemo.btnClearAllFiltersClick(Sender: TObject);
Begin
   btnLinkController.OnClick(self);
   dxDBGridController.ClearAllFilters;
End;

Procedure TfmMainDemo.btnActivateGridHintClick(Sender: TObject);
Begin
   grdProject.ShowHint := True;
   grdProject.Options  := grdProject.Options + [dgCellEllipsis, dgCellHints];
End;

Procedure TfmMainDemo.btnChangeSearchBoxClick(Sender: TObject);
Begin
   btnLinkController.OnClick(self);
   If dxDBGridController.SearchEditor.Parent = dxDBGridController.BottomPanel Then
   Begin
      dxDBGridController.SearchEditor.Parent := dxDBGridController.TopPanel;
      dxDBGridController.SearchEditor.Align  := alRight;
      dxDBGridController.SearchEditor.Left   := dxDBGridController.TopPanel.Width + 10;
      dxDBGridController.SearchEditor.Width  := 150;
   End
   Else
   Begin
      dxDBGridController.SearchEditor.Parent := dxDBGridController.BottomPanel;
      dxDBGridController.SearchEditor.Align  := alLeft;
      dxDBGridController.SearchEditor.Left   := -1;
      dxDBGridController.SearchEditor.Width  := 500;
   End;
End;


Procedure TfmMainDemo.btnDeleteProjectClick(Sender: TObject);
Begin
   btnLinkController.OnClick(self);
   DeleteProject(100);
   dxDBGridController.Refresh;
End;

Procedure TfmMainDemo.btnDestroyControllerClick(Sender: TObject);
Begin
   If Assigned(dxDBGridController) Then
      FreeAndNil(dxDBGridController);
End;

Procedure TfmMainDemo.btnGroupOnClientClick(Sender: TObject);
Begin

   btnLinkController.OnClick(self);

   // Clear prior sort if necessary
   // and show group line
   If grdProject.FixedCols = 3 Then
   Begin
      // Clear sorting and set fixed columns to 1
      dxDBGridController.ClearSort;
      grdProject.BorderColor := clDefault;
      grdProject.FixedCols   := 1;
      qProjectBuf.First;
   End
   Else
   Begin
      dxDBGridController.ControllerOptions := dxDBGridController.ControllerOptions + [coShowGroupLine];
      dxDBGridController.GroupLineWidth    := 1;
      dxDBGridController.GroupLineColor    := $00C5BEE7;

      // Set position in the grid for to present the client first and manager second
      dxDBGridController.ColumnByFieldName('LUClient').Index       := 0;
      dxDBGridController.ColumnByFieldName('ProjectManager').Index := 1;

      // do the sorting
      dxDBGridController.ClearSort;
      dxDBGridController.SortColumnByFieldName('LUClient', soASC);
      dxDBGridController.SortColumnByFieldName('ProjectManager', soASC);

      grdProject.BorderColor := $00C5BEE7;
      grdProject.FixedCols   := 3;
      qProjectBuf.First;
   End;
End;

Procedure TfmMainDemo.btnHideGroupLineClick(Sender: TObject);
Begin
   dxDBGridController.ControllerOptions := dxDBGridController.ControllerOptions - [coShowGroupLine];
End;

Procedure TfmMainDemo.CreateController;
Begin
   dxDBGridController      := TdxDBGridController.Create(self);
   dxDBGridController.Name := 'dxDBGridController';
   dxDBGridController.OnAfterAggregation := @self.dxDBGridControllerAfterAggregation;
   dxDBGridController.OnAfterSortColumn := @self.dxDBGridControllerAfterSortColumn;
   dxDBGridController.OnAggregation := @self.dxDBGridControllerAggregation;
   dxDBGridController.OnLocalize := @self.dxDBGridControllerLocalize;
   dxDBGridController.OnSortColumn := @self.dxDBGridControllerSortColumn;
   TIPropertyGrid.TIObject := dxDBGridController;
End;

Procedure TfmMainDemo.btnLinkControllerClick(Sender: TObject);
Begin
   If Assigned(dxDBGridController) Then
      dxDBGridController.DBGrid := grdProject
   Else
   Begin
      CreateController;
      // link the Grid
      dxDBGridController.DBGrid := grdProject;
   End;
End;

Procedure TfmMainDemo.btnLoadGridViewClick(Sender: TObject);
Begin
   dxDBGridController.LoadConfiguration;
End;

Procedure TfmMainDemo.cbLocalizationChange(Sender: TObject);
Begin
   // Always reset localisation before translating your resources
   dxDBGridController.ResetLocalization;

   // Translate your ressources here ...
   // 1 = French
   If cbLocalization.ItemIndex = 1 Then
   Begin
      qProjectBuf.FieldByName('ProjectNumber').DisplayLabel  := 'Numéro de Projet';
      qProjectBuf.FieldByName('ProjectManager').DisplayLabel := 'Chargé de projet';
      qProjectBuf.FieldByName('StartDate').DisplayLabel      := 'Date de début';
      qProjectBuf.FieldByName('EndDate').DisplayLabel        := 'Date de fin';
      qProjectBuf.FieldByName('Amount').DisplayLabel         := 'Montant';
      qProjectBuf.FieldByName('WithTaxes').DisplayLabel      := 'Avec taxes';

      // We can use also directrly the column object from the DBGrid
      dxDBGridController.ColumnByFieldName('ProjectNumber').Title.Caption  := 'Numéro de Projet';
      dxDBGridController.ColumnByFieldName('ProjectManager').Title.Caption := 'Chargé de projet';
      dxDBGridController.ColumnByFieldName('StartDate').Title.Caption      := 'Date de début';
      dxDBGridController.ColumnByFieldName('EndDate').Title.Caption        := 'Date de fin';
      dxDBGridController.ColumnByFieldName('Amount').Title.Caption         := 'Montant';

      gbSortingInformation.Caption := 'Information sur le tri';
      gbCustomAggregation.Caption  := 'Aggrégation présentée sur mesure';
      lbMaxAmount.Caption          := 'Montant maximum';
      lbMinAmount.Caption          := 'Montant minimum';
      lbAvgAmount.Caption          := 'Montant moyen';

      sDistinct := 'Distinct';
      sCount    := 'Nombre';
      sMin      := 'Minimum';
      sMax      := 'Maximum';
      sAvg      := 'Moyen';
      sSum      := 'Total';
      sProjectWithTaxes := 'Avec taxes ';
      sProjectWithoutTaxes := 'Sans taxes ';

   End
   Else
      // English
   Begin
      qProjectBuf.FieldByName('ProjectNumber').DisplayLabel  := 'Project Number';
      qProjectBuf.FieldByName('ProjectManager').DisplayLabel := 'Project Manager';
      qProjectBuf.FieldByName('StartDate').DisplayLabel      := 'Start Date';
      qProjectBuf.FieldByName('EndDate').DisplayLabel        := 'End Date';
      qProjectBuf.FieldByName('Amount').DisplayLabel         := 'Amount';
      qProjectBuf.FieldByName('WithTaxes').DisplayLabel      := 'With Taxes';

      // We can use also directrly the column object from the DBGrid
      dxDBGridController.ColumnByFieldName('ProjectNumber').Title.Caption  := 'Project Number';
      dxDBGridController.ColumnByFieldName('ProjectManager').Title.Caption := 'Project Manager';
      dxDBGridController.ColumnByFieldName('StartDate').Title.Caption      := 'Start Date';
      dxDBGridController.ColumnByFieldName('EndDate').Title.Caption        := 'End Date';
      dxDBGridController.ColumnByFieldName('Amount').Title.Caption         := 'Amount';

      gbSortingInformation.Caption := 'Last sorting information';
      gbCustomAggregation.Caption  := 'Custom display aggregation';

      lbMaxAmount.Caption := 'Max Amount';
      lbMinAmount.Caption := 'Min Amount';
      lbAvgAmount.Caption := 'Avg Amount';

      sDistinct := 'Distinct';
      sCount    := 'Count';
      sMin      := 'Min';
      sMax      := 'Max';
      sAvg      := 'Avg';
      sSum      := 'Sum';

      sProjectWithTaxes    := 'With taxes ';
      sProjectWithoutTaxes := 'Without taxes ';

   End;
   dxDBGridController.Refresh;
End;

Procedure TfmMainDemo.dxDBGridControllerAfterAggregation(Sender: TdxDBGridController);
Begin
   Self.stAvgAmount.Caption := FloatToStrF(Sender.ColumnPropertyList.Aggregation(agAvg, 'Amount').AsFloat, ffcurrency, 10, 2);
   Self.stMinAmount.Caption := FloatToStrF(Sender.ColumnPropertyList.Aggregation(agMin, 'Amount').AsFloat, ffcurrency, 10, 2);
   Self.stMaxAmount.Caption := FloatToStrF(Sender.ColumnPropertyList.Aggregation(agMax, 'Amount').AsFloat, ffcurrency, 10, 2);
End;

Procedure TfmMainDemo.dxDBGridControllerAfterSortColumn(Sender: TObject; Column: TColumn; IndexFieldNames, AscFieldNames, DescFieldNames, IndexName,
   SQLOrderBy: String);
Begin
   lbIndexFieldNames.Caption := IndexFieldNames;
   lbIndexName.Caption       := IndexName;
   lbSQLOrderby.Caption      := SQLOrderBy;
End;


End.
