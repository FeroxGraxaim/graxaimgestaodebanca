(*
___________________________________________________________________

TdxDBGridController is a non visual component with no dependencies
providing added fonctionalities for the TDBGrid object

Features :

   - Searching expression in the grid
   - Searching expression in column
   - Column filter editor
   - Datetime editor, memo editor and lookup editor
   - Saving the current filter view (JSON)
   - Multi column sorting
   - Column chooser editor
   - Column grouping visual separator on one level
   - No data indicator
   - Footer and aggregation on columns
   - Perform 50000 records under a second

Repository :

https://gitlab.com/lazaruscomponent/dbgridController

Documentation

https://wiki.freepascal.org/TdxDBGridController

Licenses :

MPL 2.0, LGPL
____________________________________________________________________
*)

Unit dxDBGridController;

{$mode objfpc}{$H+}

Interface


Uses
   BufDataset,
   Buttons,
   Calendar,
   CheckLst,
   Classes,
   contnrs,
   Controls,
   Crt,
   DateTimePicker,
   DateUtils,
   DB,
   DBCtrls,
   DBGrids,
   Dialogs,
   EditBtn,
   ExtCtrls,
   Forms,
   Graphics,
   Grids,
   JsonTools,
   lazutf8,
   LCLIntf,
   lclproc,
   LCLType,
   ListFilterEdit,
   LMessages,
   LResources,
   Math,
   md5,
   memds,
   Menus,
   Messages,
   SQLDB,
   StdCtrls,
   SysUtils,
   Types,
   TypInfo,
   Variants;

Resourcestring

   msg_search         = 'Search...';
   msg_first          = 'First';
   msg_prior          = 'Prior';
   msg_next           = 'Next';
   msg_last           = 'Last';
   msg_add            = 'Add';
   msg_delete         = 'Delete';
   msg_edit           = 'Edit';
   msg_save           = 'Save';
   msg_cancel         = 'Cancel';
   msg_refresh        = 'Refresh';
   msg_btncancel      = 'Cancel';
   msg_btnok          = 'OK';
   msg_of             = 'of';
   msg_nodata         = 'No Data Found!';
   msg_columnchooser  = 'Column Chooser...';
   msg_clearselection = 'Clear Selection';
   msg_selectall      = 'Select All';
   msg_sortingasc     = 'Sort by ascending order';
   msg_sortingdesc    = 'Sort by descending order';


Const

   sVersion              = 'v 1.0.2  2023-01-22';

   clSortIndex           = TColor(clGrayText);
   clSearch              = TColor($006453FD);
   clSearchText          = TColor(clBlack);
   clColumnSearch        = TColor(clGradientActiveCaption);
   clColumnSearchText    = TColor(clBlack);
   clGroupLine           = TColor(clGrayText);
   clPopupFormColor      = TColor(clGray);
   clFixedColor          = TColor(clWhite);

   gBorderSpace: Integer = 3;
   gTitleNumberOfLine: Integer = 1;
   gGlyphWidth: Integer  = 16;

Type

   { TAccessDBGrid }
   TdxAccessDBGrid = Class(TDBGrid);

   { Search Editor }
   TdxColumnSearchEditor = Class(TEdit);
   TdxSearchEditor = Class(TListFilterEdit);

   TdxControllerOption  = (
      coMemoEditor,                          // Enable grid inplace editor for Memo field
      coDatetimeEditor,                      // Enable grid inplace editor for Datetime field
      coLookupEditor,                        // Enable grid inplace editor for Lookup field
      coDefaultDrawingFooter,
      coShowColumnFilter,
      coShowFooter,
      coShowGroupLine,
      coShowRowLineWhenGrouped,
      coFirstRowAfterSort,
      coLastRowAfterSort,
      coFirstRowAfterFilter,
      coLastRowAfterFilter
      );
   TdxControllerOptions = Set Of TdxControllerOption;

   TdxSortOption = (
      soDesc,                          // Descending
      soNone,                          // Not sorted
      soASC                            // Ascending
      );

   TdxHitRegion = (
      hrNone,
      hrFilterRegion,
      hrSortRegion,
      hrCancelRegion,
      hrFilterOperatorRegion
      );

   TdxPopupType = (ptEditor, ptColumnFilter, ptColumnChooser);

   TdxAggregationType = (
      agNone,
      agSum,
      agMin,
      agMax,
      agAvg,
      agCount,
      agDistinct,
      agCustom
      );

   TdxAggInfo = Record

      MinFloat:    float;
      MinInt:      Longint;
      MinStr:      String;
      MinDatetime: TDateTime;

      MaxFloat:    float;
      MaxInt:      Longint;
      MaxStr:      String;
      MaxDatetime: TDateTime;

      SumFloat: float;
      SumInt:   Longint;
      SumStr:   String;

      AvgFloat: float;
      AvgInt:   Longint;
      AvgStr:   String;

      Count:    Longint;
      CountStr: String;

      Distinct:    Longint;
      DistinctStr: String;

      CustomInt:   Longint;
      CustomFloat: Float;
      CustomStr:   String;
   End;

   TdxColumnAggregation      = Class;
   TdxColumnProperty         = Class;
   TdxCustomDBGridController = Class;
   TdxDBGridController       = Class;
   TdxColumnPropertyList     = Class;

   TdxAggregation          = Procedure(Sender: TdxDBGridController) Of Object;
   TdxBeforeSortColumn     = Procedure(Sender: TObject; Column: TColumn; Var AllowSorting: Boolean) Of Object;
   TdxSortColumn           = Procedure(Sender: TObject; Column: TColumn; IndexFieldNames, AscFieldNames, DescFieldNames, IndexName, SQLOrderBy: String) Of
      Object;
   TdxPrepareLookupDataset = Procedure(Sender: TObject; Var Dataset: TDataset; LookupField: TField) Of Object;
   TdxLocalize             = Procedure(Sender: TObject; Component: TComponent; ID_Ressource: String; Var Translation: String) Of Object;

   { TdxFormLookup }

   TdxFormLookup = Class(TForm)
   private
      // Form controls, the owner if the form,
      // destroyed by the form when free
      FTopPanel:         TPanel;
      FClientPanel:      TPanel;
      FBottomPanel:      TPanel;
      FbtnOk:            TBitBtn;
      FbtnCancel:        TBitBtn;
      FbtnClearFilter:   TSpeedButton;
      FbtnSelectAll:     TSpeedButton;
      FbtnSortingAsc:    TSpeedButton;
      FbtnSortingDesc:   TSpeedButton;
      FSearchEditor:     TdxSearchEditor;
      FDBGrid:           TDBGrid;
      FCalendar:         TCalendar;
      FMemo:             TDBMemo;
      // Current column information
      FRect:             TRect;
      //Top left point where to place the form when showing
      FPoint:            TPoint;
      // Grid column field
      FField:            TField;
      // Grid dataset
      FDataset:          TDataset;
      // Grid lookup field data set and datasource
      FLookupDataset:    TDataset;
      FLookupDatasource: TDatasource;
      // Reserence to the column property object, holded by the grid Controller
      FColumnProperty:   TdxColumnProperty;
      // Containt all distinct values for a column
      FDisplayTextList:  TStringList;

      FColumnChooserList: TCheckListBox;

      Function BuildFilter: String;
      Procedure ClearFilterOnClick(Sender: TObject);
      Procedure SelectAllOnClick(Sender: TObject);
      Procedure SortingAsc(Sender: TObject);
      Procedure SortingDesc(Sender: TObject);
      Procedure FilterBoxOnChange(Sender: TObject);
      Procedure FilterBoxOnKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
      Procedure OnKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
      Procedure FilterRecord(DataSet: TDataSet; Var Accept: Boolean);
      Procedure GridOnDblClick(Sender: TObject);
      Procedure MouseEnter(Sender: TObject);
      Procedure MouseLeave(Sender: TObject);
      Procedure Show(Sender: TObject);
      Procedure Paint(Sender: TObject);

   public
      Destructor Destroy; override;
   End;

   { TdxCustomDBGridController }
   TdxCustomDBGridController = Class(TComponent)
   private

      FIndexCount:            Integer;
      FNeedRecalculateAggregation: Boolean;
      FUseDatasetSorting:     Boolean;
      FRecordCount:           Integer;
      FNavigatorDefaultWidth: Integer;
      FColumnChooserShortCut: TShortCut;
      FSearchBoxShortCut:     TShortCut;
      FColumnFilterShortCut:  TShortCut;
      FControllerVersion:     String;

      FColumnSelectAllLimit: Integer;
      FGroupValue:           TStringList;

      FConfiguration:     String;
      FLookupSearchText:  String;
      FSearchBoxWidth:    Integer;
      FSearchTypingDelay: Integer;
      FDelayedFiltering:  TTimer;
      FDelayedGridDraw:   TTimer;
      FDelayedRecalculateAggregation: TTimer;

      FOnBeforeSortColumn:     TdxBeforeSortColumn;
      FOnPrepareLookupDataset: TdxPrepareLookupDataset;
      FOnSortColumn:           TdxSortColumn;
      FOnAfterSortColumn:      TdxSortColumn;
      FOnAfterFilterGrid:      TNotifyEvent;
      FOnLocalize:             TdxLocalize;
      FOnAggregation:          TdxAggregation;
      FOnAfterAggregation:     TdxAggregation;

      // Need this to hold inherited event
      FDBGridEvents:      TDBGrid;
      // Rectangle of current selected cell
      FCurrentCellRect:   TRect;
      FControllerOptions: TdxControllerOptions;
      FIsGridValid:       Boolean;
      FHitRegion:         TdxHitRegion;
      FLastHitRegion:     TRect;
      FGridShiftState:    TShiftState;

      FGridGlyphCancelFilter:     TPortableNetworkGraphic;
      FGridGlyphSortUp:           TPortableNetworkGraphic;
      FGridGlyphSortDown:         TPortableNetworkGraphic;
      FGridGlyphFind:             TPortableNetworkGraphic;
      FGridGlyphColumnFilter:     TPortableNetworkGraphic;
      FGridGlyphColumnHaveFilter: TPortableNetworkGraphic;
      FGridGlyphColumnChooser:    TPortableNetworkGraphic;
      FGridGlyphSelectAll:        TPortableNetworkGraphic;
      FGridGlyphSortingAsc:       TPortableNetworkGraphic;
      FGridGlyphSortingDesc:      TPortableNetworkGraphic;

      FSortIndexColor:        Tcolor;
      FSearchColor:           Tcolor;
      FSearchTextColor:       Tcolor;
      FColumnSearchTextColor: Tcolor;
      FColumnSearchColor:     Tcolor;
      FGroupLineColor:        Tcolor;
      FGroupLineWidth:        Tcolor;

      // Grid
      FGrid:           TDBGrid;
      FOldParent:      TWinControl;
      FOldConstraints: TSizeConstraints;
      FOldAnchors:     TAnchors;
      // All subcomponent to the grid
      FDatasource:     TDatasource;
      FImageList:      TImageList;

      FGridPanel:   TPanel;
      FTopPanel:    TPanel;
      FFooterPanel: TPanel;
      FBottomPanel: TPanel;

      FColumnChooser: TSpeedButton;
      FSearchEditor:  TdxSearchEditor;

      FPageCount:          TLabel;
      FFilterInfo:         TLabel;
      FNavigator:          TDBNavigator;
      FPageSelector:       TDBNavigator;
      FColumnPropertyList: TdxColumnPropertyList;

      // Properties related to display apparence
      FTopPanelHeight:    Integer;
      FBottomPanelHeight: Integer;

      Procedure CalculateAggregationAfterFiltering;
      Function CheckListBoxCount(CheckListBox: TCheckListBox): Integer;
      Procedure ClearSQLOrderBy(FieldName: String);
      Procedure CreateAllColumnProperty;
      Procedure CreateGridSubComponent;
      Function CreatePopupForm(Column: TColumn; PopupType: TdxPopupType): TdxFormLookup;
      Procedure DestroyGridSubComponent;
      Function FixedColsWidth: Integer;
      Procedure PrepareAggregation;
      Procedure DrawAggregation;
      Procedure DrawColumnFooter(Sender: TdxColumnProperty);

      Function GetCurrentColumnIndex: Integer;
      Procedure AddGlobalFilterExpression(Var SearchExpression: String; SQLOpertor: String);
      Function GetColumnByFieldName(FieldName: String): TColumn;
      Function GetColumnByFilterBox(Control: TdxColumnSearchEditor): TColumn; overload;
      Function GetTitleHeight: Integer;

      Function GetDisplayText(Field: TField): String;
      Function GetSearchTypingDelay: Integer;
      Function GetLocalisation(Component: TComponent; ID_Ressource: String): String;
      Function GridShowNoData: Boolean;
      Function IsGridValid: Boolean;
      Function IsPropertyPresent(anInstance: TObject; aPropName: String): Boolean;
      Procedure RecalculateAggregation;
      Procedure RestoreDatasetPosition(OldPosition: Integer);

      Procedure SetColumnSelectAllLimit(AValue: Integer);
      Procedure SetControllerOptions(AValue: TdxControllerOptions);

      Function GetGlyphColumnFilter: TPortableNetworkGraphic;
      Function GetGlyphColumnHaveFilter: TPortableNetworkGraphic;
      Function GetGlyphSelectAll: TPortableNetworkGraphic;
      Function GetGlyphCancelFilter: TPortableNetworkGraphic;
      Function GetGlyphSortUp: TPortableNetworkGraphic;
      Function GetGlyphSortDown: TPortableNetworkGraphic;
      Function GetGlyphFind: TPortableNetworkGraphic;
      Function GetGlyphColumnChooser: TPortableNetworkGraphic;
      Function GetGlyphSortingAsc: TPortableNetworkGraphic;
      Function GetGlyphSortingDesc: TPortableNetworkGraphic;

      Procedure SetGlyphColumnChooser(AValue: TPortableNetworkGraphic);
      Procedure SetGlyphColumnFilter(AValue: TPortableNetworkGraphic);
      Procedure SetGlyphColumnHaveFilter(AValue: TPortableNetworkGraphic);
      Procedure SetGlyphSelectAll(AValue: TPortableNetworkGraphic);
      Procedure SetGlyphCancelFilter(AValue: TPortableNetworkGraphic);
      Procedure SetGlyphSortingAsc(AValue: TPortableNetworkGraphic);
      Procedure SetGlyphSortingDesc(AValue: TPortableNetworkGraphic);
      Procedure SetGlyphSortUp(AValue: TPortableNetworkGraphic);
      Procedure SetGlyphSortDown(AValue: TPortableNetworkGraphic);
      Procedure SetGlyphFind(AValue: TPortableNetworkGraphic);

      Procedure SetColumnSearchColor(AValue: TColor);
      Procedure SetColumnSearchTextColor(AValue: TColor);
      Procedure SetGroupLineColor(AValue: TColor);
      Procedure SetSearchTextColor(AValue: TColor);
      Procedure SetSortIndexColor(AValue: TColor);

      Procedure SetGroupLineWidth(AValue: Integer);
      Procedure SetSearchBoxWidth(AValue: Integer);
      Procedure SetSearchTypingDelay(AValue: Integer);

      Procedure ShowMemoCellText(AGrid: TDbGrid; Const ARect: TRect; AColumn: TColumn; FilterText: String; AState: TGridDrawState);
      Procedure HighlightGroup(AGrid: TDbGrid; Const ARect: TRect; AColumn: TColumn; AState: TGridDrawState);
      Procedure HighlightSearchText(AGrid: TDbGrid; Const ARect: TRect; AColumn: TColumn; FilterText: String; AState: TGridDrawState;
         SearchGlobal: Boolean = True);

      Procedure SetGrid(Const AValue: TDBGrid);
      Procedure SetGridButtonStyle(Const AFieldType: TFieldType; AButtonStyle: TColumnButtonStyle);
      Procedure SetGridDatsetFilter;
      Procedure SetBottomPanelHeight(Const AValue: Integer);
      Procedure SetSearchColor(AValue: TColor);
      Procedure SetTopPanelHeight(Const AValue: Integer);
      Procedure SetObjectEvents;
      Procedure RestoreGridEvents;
      Procedure ShowFilterBox(x, y: Integer);
      Procedure GetHitRegion(x, y: Integer; Var Region: TdxHitRegion);

   protected

      Procedure Loaded; override;
      Procedure Updated; override;
      Procedure Notification(aComponent: TComponent; aOperation: TOperation); override;
      Procedure SetRecordCount;
      Procedure TriggerSorting(AColumn: TColumn; ForceOrder: Boolean; SortOption: TdxSortOption);
      Procedure SortColumn(AColumn: TColumn);

      // All Subcomponent events
      Procedure ColumnFilterEditorClick(Column: TColumn); // Column Filter Editor
      Procedure DataChange(Sender: TObject; Field: TField); // Datasource,  use to diplay the record position
      Procedure UpdateData(Sender: TObject); // Datasource,  use to trigger filtering and aggregation calculation
      Procedure FilterRecord(DataSet: TDataSet; Var Accept: Boolean); // override the filter record procedure of the dataset
      Procedure FilterEditChange(Sender: TObject);
      Procedure FilterMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      Procedure TriggerTimer(Sender: TObject); // Timer trigger event for the delayed typing
      Procedure GridDrawTimer(Sender: TObject); // Timer trigger event for drawing grid when no data fund
      Procedure RecalculateAggregationTimer(Sender: TObject); // Timer trigger event for aggregation recalculation
      Procedure Navigator1Click(Sender: TObject; Button: TDBNavButtonType);

      // All grid events override by the Controller,
      // need to capture existing events if they are assigned, for inherited purpose
      Procedure EditButtonClick(Sender: TObject);
      Procedure ColumnChooserClick(Sender: TObject);
      Procedure GetCellHint(Sender: TObject; Column: TColumn; Var AText: String);
      Procedure DrawColumnTitle(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
      Procedure DrawColumnCell(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
      Procedure KeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
      Procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      Procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      Procedure TitleClick(Column: TColumn);

      // Auto created object are set in readonly mode
      // but we have access in read/write mode to there properties
      Property Navigator: TDBNavigator read FNavigator;
      Property PageSelector: TDBNavigator read FPageSelector;
      Property PageCount: TLabel read FPageCount;
      Property FooterPanel: TPanel read FFooterPanel;
      Property TopPanel: TPanel read FTopPanel;
      Property GridPanel: TPanel read FGridPanel;
      Property SearchEditor: TdxSearchEditor read FSearchEditor;
      Property BottomPanel: TPanel read FBottomPanel;
      Property ColumnChooser: TSpeedButton read FColumnChooser;

      // Grid property and settings
      Property DBGrid: TDBGrid read FGrid write SetGrid;
      Property ColumnPropertyList: TdxColumnPropertyList read FColumnPropertyList;
      Property TopPanelHeight: Integer read FTopPanelHeight write SetTopPanelHeight default 30;
      Property ColumnSelectAllLimit: Integer read FColumnSelectAllLimit write SetColumnSelectAllLimit default 200;
      Property BottomPanelHeight: Integer read FBottomPanelHeight write SetBottomPanelHeight default 30;
      Property ControllerOptions: TdxControllerOptions read FControllerOptions write SetControllerOptions default
         [coMemoEditor, coDatetimeEditor, coDefaultDrawingFooter, coLookupEditor, coShowColumnFilter];
      Property SearchTypingDelay: Integer read GetSearchTypingDelay write SetSearchTypingDelay default 550;

      Property SortIndexColor: TColor read FSortIndexColor write SetSortIndexColor default clSortIndex;
      Property SearchColor: TColor read FSearchColor write SetSearchColor default clSearch;
      Property SearchTextColor: TColor read FSearchTextColor write SetSearchTextColor default clSearchText;
      Property ColumnSearchColor: TColor read FColumnSearchColor write SetColumnSearchColor default clColumnSearch;
      Property ColumnSearchTextColor: TColor read FColumnSearchTextColor write SetColumnSearchTextColor default clColumnSearchText;
      Property GroupLineColor: TColor read FGroupLineColor write SetGroupLineColor default clGroupLine;
      Property GroupLineWidth: Integer read FGroupLineWidth write SetGroupLineWidth default 1;

      // Define shortcut
      Property SearchBoxShortCut: TShortCut read FSearchBoxShortCut write FSearchBoxShortCut default 16454; // Ctrl+F
      Property ColumnChooserShortCut: TShortCut read FColumnChooserShortCut write FColumnChooserShortCut default 16456; // Ctrl+H
      Property ColumnFilterShortCut: TShortCut read FColumnFilterShortCut write FColumnFilterShortCut default 16458; // Ctrl+J

      // Search box width
      Property SearchBoxWidth: Integer read FSearchBoxWidth write SetSearchBoxWidth default 150;

      //Controller events
      Property OnAggregation: TdxAggregation read FOnAggregation write FOnAggregation;
      Property OnAfterAggregation: TdxAggregation read FOnAfterAggregation write FOnAfterAggregation;
      Property OnPrepareLookupDataset: TdxPrepareLookupDataset read FOnPrepareLookupDataset write FOnPrepareLookupDataset;
      Property OnBeforeSortColumn: TdxBeforeSortColumn read FOnBeforeSortColumn write FOnBeforeSortColumn;
      // On Sort Event, normaly set the IndexFieldNames for the dataset or call a SQL query by changing the where clause...
      Property OnSortColumn: TdxSortColumn read FOnSortColumn write FOnSortColumn;
      // On After Sort Event
      Property OnAfterSortColumn: TdxSortColumn read FOnAfterSortColumn write FOnAfterSortColumn;
      // On After Filter Grid
      Property OnAfterFilterGrid: TNotifyEvent read FOnAfterFilterGrid write FOnAfterFilterGrid;
      // On Lacalize Event, used for translation
      Property OnLocalize: TdxLocalize read FOnLocalize write FOnLocalize;

      //Glyph Cancel Filter
      Property GlyphCancelFilter: TPortableNetworkGraphic read GetGlyphCancelFilter write SetGlyphCancelFilter;
      //Glyph Sort Up
      Property GlyphSortUp: TPortableNetworkGraphic read GetGlyphSortUp write SetGlyphSortUp;
      //Glyph Sort Down
      Property GlyphSortDown: TPortableNetworkGraphic read GetGlyphSortDown write SetGlyphSortDown;
      //Glyph Find
      Property GlyphFind: TPortableNetworkGraphic read GetGlyphFind write SetGlyphFind;
      //Glyph Column Filter
      Property GlyphColumnFilter: TPortableNetworkGraphic read GetGlyphColumnFilter write SetGlyphColumnFilter;
      //Glyph Column Filter is active
      Property GlyphColumnHaveFilter: TPortableNetworkGraphic read GetGlyphColumnHaveFilter write SetGlyphColumnHaveFilter;
      //Glyph Column Chooser
      Property GlyphColumnChooser: TPortableNetworkGraphic read GetGlyphColumnChooser write SetGlyphColumnChooser;
      //Glyph Select All
      Property GlyphSelectAll: TPortableNetworkGraphic read GetGlyphSelectAll write SetGlyphSelectAll;
      //Glyph Sorting Asc
      Property GlyphSortingAsc: TPortableNetworkGraphic read GetGlyphSortingAsc write SetGlyphSortingAsc;
      //Glyph Sorting Desc
      Property GlyphSortingDesc: TPortableNetworkGraphic read GetGlyphSortingDesc write SetGlyphSortingDesc;
      // When set to true try to comply with specific class for sorting action
      // if set to false only OnSortColumn event handler will be trigger
      Property UseDatasetSorting: Boolean read FUseDatasetSorting write FUseDatasetSorting default True;

      Property Version: String read FControllerVersion;

   public
      // Read configuration from a JSON file and initialize the dxDBGridController object
      Procedure LoadConfiguration;
      // Save the configuration JSON Object into a file
      Procedure SaveConfiguration;
      // Get configuration from the dxDBGridController object and create a JSON object
      Function GetConfiguration: String;
      // Refresh filter and aggregation
      Procedure Refresh;
      // Clear Column Sorting
      Procedure ClearSort;
      // Clear All Filters
      Procedure ClearAllFilters;
      // Get grid column by FieldName
      Function ColumnByFieldName(Const AFieldName: String): TColumn;
      // All the magic for filtering the dataset happen here
      Function AcceptFilteredRecord(AllRecords: Boolean = False): Boolean;
      // Sort a column
      Procedure SortColumnByFieldName(FieldName: String; SortOption: TdxSortOption);
      // Reset localization
      Procedure ResetLocalization;

      Constructor Create(AOwner: TComponent); override;
      Destructor Destroy; override;
   End;

      { TdxDBGridController }
   TdxDBGridController = Class(TdxCustomDBGridController)
   public
      // Can access these properties
      // they are created in runtime
      Property DBGrid;
      Property Navigator;
      Property PageSelector;
      Property PageCount;
      Property TopPanel;
      Property GridPanel;
      Property SearchEditor;
      Property FooterPanel;
      Property BottomPanel;
      Property ColumnPropertyList;

   published

      Property TopPanelHeight;
      Property BottomPanelHeight;
      Property ColumnSelectAllLimit;

      Property SortIndexColor;
      Property SearchColor;
      Property SearchTextColor;
      Property ColumnSearchColor;
      Property ColumnSearchTextColor;
      Property GroupLineColor;
      Property GroupLineWidth;

      Property SearchBoxShortCut;
      Property ColumnChooserShortCut;
      Property ColumnFilterShortCut;

      Property ControllerOptions;
      Property SearchTypingDelay;
      Property SearchBoxWidth;

      Property GlyphCancelFilter;
      Property GlyphSortUp;
      Property GlyphSortDown;
      Property GlyphFind;
      Property GlyphColumnFilter;
      Property GlyphColumnHaveFilter;
      Property GlyphColumnChooser;
      Property GlyphSelectAll;
      Property GlyphSortingAsc;
      Property GlyphSortingDesc;
      Property UseDatasetSorting;
      Property Version;

      // Published Controller Events
      Property OnPrepareLookupDataset;
      Property OnBeforeSortColumn;
      Property OnSortColumn;
      Property OnAfterSortColumn;
      Property OnAfterFilterGrid;
      Property OnLocalize;
      Property OnAggregation;
      Property OnAfterAggregation;

   End;

   { TdxAggregation1 }

   { TdxColumnAggregation }

   TdxColumnAggregation = Class(TObject)
   private
      FType:        TdxAggregationType;
      FAggregation: TdxAggInfo;
   public
      Function AsIngeger: Longint;
      Function AsString: String;
      Function AsFloat: Float;
      Function AsDateTime: TDatetime;
   End;


   { TdxColumnPropertyList }

   TdxColumnPropertyList = Class(TStringList)
   private
      FOwner:            TdxCustomDBGridController;
      // Filter status
      FHaveColumnSearch: Boolean;
      FHaveColumnFilter: Boolean;
      FHaveGlobalSearch: Boolean;

      SortedColumnCount: Integer;
      SQLOrderBy:        String;
      IndexFieldNames:   String;
      AscFieldNames:     String;
      DescFieldNames:    String;
      IndexName:         String;

      Function ConcatIfNotEmpty(s1, s2: String): String;
      Function GetColumnProperty(AColumn: TColumn; Rect: TRect): TdxColumnProperty;
      //Function ColumnPropertyByName(FieldName: String): TdxColumnProperty;
      Function FindSortedColumn(SortIndex: Integer): TdxColumnProperty;
      Procedure ClearColumnSorting;
      Procedure ClearAllFilters;
      Procedure AddSortedColumn(AColumnProperty: TdxColumnProperty; IsFirst: Boolean);
      Procedure RebuildFilterSearchText;
      Procedure RebuildSQLOrderBy;
      Procedure ResetAggregation;
      Procedure SetFilterStatus;
   public
      Function Aggregation(AType: TdxAggregationType; FieldName: String): TdxColumnAggregation;
      Function ColumnPropertyByName(FieldName: String): TdxColumnProperty;
      Constructor Create(AOwner: TdxCustomDBGridController);
      Destructor Destroy; override;
   End;

   { TdxColumnProperty }

   TdxColumnProperty = Class(TObject) // Collection of some properties for a column
   private
      FOwner:             TdxColumnPropertyList;
      FCheckListBox:      TCheckListBox;
      FColumnAggregation: TdxColumnAggregation;
      FNeedAggregation:   Boolean;
      FFooterDisplayText: String;
      FFooterAlignment:   TAlignment;
   protected
      Column:            TColumn;
      TitleRect:         TRect;
      Field:             TField;
      FieldName:         String;
      IndexSortOrder:    Integer;       // Used to determine the order to apply the sorting when multiple columns are selected
      SortOrder:         TdxSortOption; // Desc, Asc, None
      FilterValueList:   TStringList;   // All selected values
      DistinctValueList: TStringList;   // Distinct value list for Aggregation CountDistinct
      SQLOrderBy:        String;        // Sort by  SQL Expression
      TitleCaption:      String;
      ColumnSearchText:  String;
      FilterSearchText:  String;        // All selected values organized in one string with braces [],[] ... for search accruacy
      // Aggregation
      Aggregation:       TdxAggInfo;
      Procedure ResetAggregation;
   public
      SearchEditor: TdxColumnSearchEditor; // Editor that will populate ColumnSearhText
      Constructor Create(AOwner: TdxColumnPropertyList; AColumn: TColumn; Rect: TRect);
      Destructor Destroy; override;
   published
      Property FooterAlignment: TAlignment read FFooterAlignment write FFooterAlignment;
      Property FooterDisplayText: String read FFooterDisplayText write FFooterDisplayText;
      Property Owner: TdxColumnPropertyList read FOwner;
   End;


Procedure Register;

Implementation

Procedure Register;
Begin
   RegisterComponents('Data Controls', [TdxDBGridController]);
End;

{ TdxAggregation1 }

Function TdxColumnAggregation.AsIngeger: Longint;
Begin
   Case FType Of
      agMin: Result      := FAggregation.MinInt;
      agMax: Result      := FAggregation.MaxInt;
      agSum: Result      := FAggregation.SumInt;
      agAvg: Result      := FAggregation.AvgInt;
      agCount: Result    := FAggregation.Count;
      agDistinct: Result := FAggregation.Distinct;
      agCustom: Result   := FAggregation.CustomInt;
   End;
End;

Function TdxColumnAggregation.AsString: String;
Begin
   Case FType Of
      agMin: Result      := FAggregation.MinStr;
      agMax: Result      := FAggregation.MaxStr;
      agSum: Result      := FAggregation.SumStr;
      agAvg: Result      := FAggregation.AvgStr;
      agCount: Result    := FAggregation.CountStr;
      agDistinct: Result := FAggregation.DistinctStr;
      agCustom: Result   := FAggregation.CustomStr;
   End;
End;

Function TdxColumnAggregation.AsFloat: Float;
Begin
   Case FType Of
      agMin: Result      := FAggregation.MinFloat;
      agMax: Result      := FAggregation.MaxFloat;
      agSum: Result      := FAggregation.SumFloat;
      agAvg: Result      := FAggregation.AvgFloat;
      agCount: Result    := FAggregation.Count;
      agDistinct: Result := FAggregation.Distinct;
      agCustom: Result   := FAggregation.CustomFloat;
   End;
End;

Function TdxColumnAggregation.AsDateTime: TDatetime;
Begin
   Case FType Of
      agMin: Result      := FAggregation.MinDatetime;
      agMax: Result      := FAggregation.MaxDatetime;
      agSum: Result      := Now();
      agAvg: Result      := Now();
      agCount: Result    := Now();
      agDistinct: Result := Now();
      agCustom: Result   := Now();
   End;
End;

{ TdxFormLookup }

Function TdxFormLookup.BuildFilter: String;
Var
   i:       Integer;
   sFilter: String = '';
Begin
   If Assigned(FLookupDataset) Then
      For i := 0 To FLookupDataset.Fields.Count - 1 Do
         If FLookupDataset.Fields[i].DataType IN [ftString, ftFixedChar, ftMemo, ftFmtMemo, ftWideString, ftGuid, ftFixedWideChar, ftWideMemo] Then
            If sFilter <> '' Then
               sFilter := sFilter + ' OR ' + FLookupDataset.Fields[i].FieldName + ' LIKE ''%' + FSearchEditor.Text + '%'''
            Else
               sFilter := FLookupDataset.Fields[i].FieldName + ' LIKE ''%' + FSearchEditor.Text + '%''';
   Result := sFilter;
End;

Procedure TdxFormLookup.ClearFilterOnClick(Sender: TObject);
Begin
   If Assigned(FColumnProperty) Then
      FColumnProperty.FCheckListBox.CheckAll(cbUnchecked);
End;

Procedure TdxFormLookup.SelectAllOnClick(Sender: TObject);
Begin
   If Assigned(FColumnProperty) Then
      FColumnProperty.FCheckListBox.CheckAll(cbChecked);
End;

Procedure TdxFormLookup.SortingAsc(Sender: TObject);
Begin
   If Assigned(Self.FColumnProperty.Column) Then
      Self.FColumnProperty.FOwner.FOwner.TriggerSorting(Self.FColumnProperty.Column, True, soAsc);
   Close;
End;

Procedure TdxFormLookup.SortingDesc(Sender: TObject);
Begin
   If Assigned(Self.FColumnProperty.Column) Then
      Self.FColumnProperty.FOwner.FOwner.TriggerSorting(Self.FColumnProperty.Column, True, soDesc);
   Close;
End;

Procedure TdxFormLookup.FilterBoxOnChange(Sender: TObject);
Begin
   //for the lookup dataset apply the filter
   If Assigned(FLookupDataset) Then
   Begin
      FLookupDataset.DisableControls;
      FLookupDataset.Filtered      := False;
      FLookupDataset.FilterOptions := [foCaseInsensitive];
      // Not supported for all datset
      // go with OnFilterRecord event for the lookup dataset
      // FLookupDataset.Filter        := BuildFilter;
      FLookupDataset.Filtered      := True;
      FLookupDataset.EnableControls;
   End;
End;

Procedure TdxFormLookup.MouseEnter(Sender: TObject);
Begin
   // FMouseNeverEntered := False;
End;

Procedure TdxFormLookup.Show(Sender: TObject);
Var
   pCaretPosition: Tpoint;
Begin
   pCaretPosition.x := 40;
   pCaretPosition.y := 5;
   If Assigned(self.FSearchEditor) Then
      self.FSearchEditor.CaretPos := pCaretPosition;
   If Assigned(self.FCalendar) Then
      self.FCalendar.SetFocus;
End;

Procedure TdxFormLookup.Paint(Sender: TObject);
Begin
   Canvas.Pen.Color := clPopupFormColor;
   Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);
End;


Procedure TdxFormLookup.FilterBoxOnKeyDown(Sender: TObject; Var Key: Word;
   Shift: TShiftState);
Begin
   Inherited;
   Begin
      If Key IN [VK_RIGHT, VK_DOWN] Then
      Begin
         self.FDBGrid.SetFocus;
         If Assigned(self.FLookupDataset) Then
            If NOT self.FLookupDataset.EOF Then
               self.FLookupDataset.Next;
      End
      Else
      If Key IN [VK_UP, VK_LEFT] Then
      Begin
         self.FDBGrid.SetFocus;
         If Assigned(self.FLookupDataset) Then
            If NOT self.FLookupDataset.BOF Then
               self.FLookupDataset.Prior;
      End;
   End;
End;

Procedure TdxFormLookup.OnKeyDown(Sender: TObject; Var Key: Word;
   Shift: TShiftState);
Begin
   If (Key = VK_ESCAPE) AND (Shift = []) Then
      FbtnCancel.Click
   Else
   If (Key = VK_RETURN) AND (Shift = []) AND (Sender IS TDBGrid) Then
      FbtnOk.Click
   Else
   If (Key = VK_RETURN) AND (Shift = [ssCtrl]) AND (Sender IS TDBMemo) Then
   Begin
      (Sender AS TDBMemo).EditingDone;
      FbtnOk.Click;
   End
   Else
   If (Key = VK_RETURN) AND (Shift = [ssAlt]) AND (Sender IS TDBMemo) Then
   Begin
      (Sender AS TDBMemo).EditingDone;
      FbtnOk.Click;
   End
   Else If (Key = VK_S) AND (Shift = [ssCtrl]) AND (Sender IS TDBMemo) Then
   Begin
      (Sender AS TDBMemo).EditingDone;
      FbtnOk.Click;
   End;
End;

Procedure TdxFormLookup.FilterRecord(DataSet: TDataSet; Var Accept: Boolean);
Var
   bFound: Boolean = False;
   i:      Integer;
Begin
   For i := 0 To DataSet.FieldCount - 1 Do
      If DataSet.Fields[i].Visible Then
         If Pos(UPPERCASE(Self.FSearchEditor.Text), UPPERCASE(DataSet.Fields[i].DisplayText)) > 0 Then
         Begin
            bFound := True;
            break;
         End;
   Accept := bFound;
End;

Procedure TdxFormLookup.GridOnDblClick(Sender: TObject);
Begin
   Self.FbtnOk.Click;
End;

Destructor TdxFormLookup.Destroy;
Begin
   // All owned component by fmPopup will be destroy also
   // this one is not owned by the form (not a component)
   FreeAndNil(FDisplayTextList);
   Inherited Destroy;
End;

Procedure TdxFormLookup.MouseLeave(Sender: TObject);
Begin
   // if FMouseNeverEntered then exit;
   // Self.ModalResult:=mrCancel;
   // Self.Close;
End;

{ TdxColumnPropertyList }

Function TdxColumnPropertyList.GetColumnProperty(AColumn: TColumn; Rect: TRect): TdxColumnProperty;
Var
   ColIndex:        Integer = -1;
   AColumnProperty: TdxColumnProperty = nil;
Begin
   If NOT Self.Find(AColumn.FieldName, ColIndex) Then
      AColumnProperty := TdxColumnProperty.Create(Self, AColumn, Rect)
   Else
      AColumnProperty := Self.Objects[ColIndex] AS TdxColumnProperty;

   // Set the new position of the title rectangle
   AColumnProperty.Field        := AColumn.Field;
   AColumnProperty.TitleCaption := AColumn.Title.Caption;
   AColumnProperty.TitleRect    := Rect;

   Result := AColumnProperty;
End;

Function TdxColumnPropertyList.ColumnPropertyByName(FieldName: String): TdxColumnProperty;
Var
   ColIndex:        Integer = -1;
   AColumnProperty: TdxColumnProperty = nil;
Begin
   If Self.Find(FieldName, ColIndex) Then
      AColumnProperty := Self.Objects[ColIndex] AS TdxColumnProperty;
   Result := AColumnProperty;
End;

Function TdxColumnPropertyList.FindSortedColumn(SortIndex: Integer): TdxColumnProperty;
Var
   i: Integer = 0;
   AColumnProperty: TdxColumnProperty = nil;
Begin
   For i := 0 To Self.Count - 1 Do
      If Assigned(Self.Objects[i]) Then
         If TdxColumnProperty(Objects[i]).IndexSortOrder = SortIndex Then
         Begin
            AColumnProperty := TdxColumnProperty(Objects[i]);
            break;
         End;
   Result := AColumnProperty;
End;

Procedure TdxColumnPropertyList.ClearColumnSorting;
Var
   i: Integer = 0;
Begin
   // Reset SortOrder
   SortedColumnCount := 0;
   SQLOrderBy        := '';
   For i := 0 To Self.Count - 1 Do
      If Assigned(Self.Objects[i]) Then
      Begin
         TdxColumnProperty(Objects[i]).IndexSortOrder := -1;
         TdxColumnProperty(Objects[i]).SortOrder      := soNone;
         TdxColumnProperty(Objects[i]).SQLOrderBy     := '';
      End;
End;

Procedure TdxColumnPropertyList.ClearAllFilters;
Var
   AColumnProperty: TdxColumnProperty;
   i: Integer;

Begin
   // For each column reset the search text
   For i := 0 To Self.FOwner.FColumnPropertyList.Count - 1 Do
   Begin
      AColumnProperty := Self.FOwner.FColumnPropertyList.Objects[i] AS TdxColumnProperty;
      // Reset to empty string
      AColumnProperty.FCheckListBox.Clear;
      AColumnProperty.FilterValueList.Clear;
      AColumnProperty.DistinctValueList.Clear;
      AColumnProperty.FilterSearchText  := '';
      AColumnProperty.SearchEditor.Text := '';
      AColumnProperty.ColumnSearchText  := '';
   End;
End;

Procedure TdxColumnPropertyList.AddSortedColumn(AColumnProperty: TdxColumnProperty; IsFirst: Boolean);
Var
   i: Integer = 0;
Begin
   If IsFirst OR (SortedColumnCount = 0) Then
   Begin
      // Reset SortOrder
      SortedColumnCount := 1;
      For i := 0 To Self.Count - 1 Do
         If Assigned(Self.Objects[i]) Then
            If Self.Objects[i] <> AColumnProperty Then
            Begin
               TdxColumnProperty(Objects[i]).IndexSortOrder := -1;
               TdxColumnProperty(Objects[i]).SortOrder      := soNone;
               TdxColumnProperty(Objects[i]).SQLOrderBy     := '';
            End;
      AColumnProperty.IndexSortOrder := 0;
      SQLOrderBy := AColumnProperty.SQLOrderBy;
   End
   Else
   If AColumnProperty.IndexSortOrder = -1 Then
   Begin
      SortedColumnCount := SortedColumnCount + 1;
      AColumnProperty.IndexSortOrder := SortedColumnCount - 1;
   End;
   // the column was already sorted... need to rebuild the new global statement
   // if the column was never sorted ... add it with new position index
   RebuildSQLOrderBy;
End;

Procedure TdxColumnPropertyList.RebuildFilterSearchText;
Var
   AColumnProperty: TdxColumnProperty;
   i, j:   Integer;
   sValue: String;
Const
   sSeparator: String = ',';
Begin
   // For each column reset the search text base on the FilterValueList
   For i := 0 To Self.FOwner.FColumnPropertyList.Count - 1 Do
   Begin
      AColumnProperty := Self.FOwner.FColumnPropertyList.Objects[i] AS TdxColumnProperty;
      // Reset to empty and rebuild it
      AColumnProperty.FilterSearchText := '';
      For j := 0 To AColumnProperty.FilterValueList.Count - 1 Do
      Begin
         sValue := AColumnProperty.FilterValueList.Strings[j];
         If AColumnProperty.FilterSearchText = '' Then
            AColumnProperty.FilterSearchText := '[' + sValue + ']'
         Else
            AColumnProperty.FilterSearchText := AColumnProperty.FilterSearchText + sSeparator + '[' + sValue + ']';
      End;
   End;
End;

Function TdxColumnPropertyList.ConcatIfNotEmpty(s1, s2: String): String;
Begin
   If (S1 = '') OR (S2 = '') Then
      Result := ''
   Else
      Result := S1 + S2;
End;

Procedure TdxColumnPropertyList.RebuildSQLOrderBy;
Var
   i: Integer = 0;
   IndexSortOrder: Integer;
   AColumnProperty: TdxColumnProperty;
Begin
   IndexSortOrder  := 0;
   SQLOrderBy      := '';
   IndexFieldNames := '';
   AscFieldNames   := '';
   DescFieldNames  := '';
   IndexName       := '';

   SortedColumnCount := 0;
   // Reset the  SortedColumnCount
   For i := 0 To Self.Count - 1 Do
      If Assigned(Self.Objects[i]) Then
      Begin
         AColumnProperty := Self.Objects[i] AS TdxColumnProperty;
         If AColumnProperty.IndexSortOrder > -1 Then
            Inc(SortedColumnCount);
      End;
   Repeat
      For i := 0 To Self.Count - 1 Do
         If Assigned(Self.Objects[i]) Then
         Begin
            AColumnProperty := Self.Objects[i] AS TdxColumnProperty;
            If IndexSortOrder = AColumnProperty.IndexSortOrder Then
            Begin
               Self.IndexFieldNames := ConcatIfNotEmpty(Self.IndexFieldNames, '; ') + AColumnProperty.FieldName;
               Case AColumnProperty.SortOrder Of
                  soASC:
                  Begin
                     Self.SQLOrderBy    := ConcatIfNotEmpty(Self.SQLOrderBy, ', ') + AColumnProperty.FieldName + ' ASC';
                     Self.IndexName     := ConcatIfNotEmpty(Self.IndexName, '_') + AColumnProperty.FieldName + '_ASC';
                     Self.AscFieldNames := ConcatIfNotEmpty(Self.AscFieldNames, '; ') + AColumnProperty.FieldName;
                  End;
                  soDESC:
                  Begin
                     Self.SQLOrderBy     := ConcatIfNotEmpty(Self.SQLOrderBy, ', ') + AColumnProperty.FieldName + ' DESC';
                     Self.IndexName      := ConcatIfNotEmpty(Self.IndexName, '_') + AColumnProperty.FieldName + '_DESC';
                     Self.DescFieldNames := ConcatIfNotEmpty(Self.DescFieldNames, '; ') + AColumnProperty.FieldName;
                  End;
               End;
               //End;
               Inc(IndexSortOrder);
            End;
         End;
   Until IndexSortOrder >= (SortedColumnCount);
End;

Procedure TdxColumnPropertyList.ResetAggregation;
Var
   i: Integer = 0;

Begin
   For i := 0 To Count - 1 Do
      (Objects[i] AS TdxColumnProperty).ResetAggregation;
End;

Procedure TdxColumnPropertyList.SetFilterStatus;
Var
   i: Integer = 0;
Begin
   RebuildFilterSearchText;
   // FHaveGlobalSearch
   FHaveGlobalSearch := Self.FOwner.FSearchEditor.Text <> '';
   // FHaveColumnSearch
   FHaveColumnSearch := False;
   For i := 0 To Count - 1 Do
   Begin
      FHaveColumnSearch := ((Objects[i] AS TdxColumnProperty).SearchEditor.Text <> '');
      If FHaveColumnSearch Then
         break;
   End;
   // FHaveColumnFilter
   FHaveColumnFilter := False;
   For i := 0 To Count - 1 Do
   Begin
      FHaveColumnFilter := ((Objects[i] AS TdxColumnProperty).FilterSearchText <> '');   // or FilterValueList.Count > 0
      If FHaveColumnFilter Then
         break;
   End;
End;

Function TdxColumnPropertyList.Aggregation(AType: TdxAggregationType; FieldName: String): TdxColumnAggregation;
Var
   AColumnProperty: TdxColumnProperty;
Begin
   AColumnProperty := ColumnPropertyByName(FieldName);

   If Assigned(AColumnProperty) Then
   Begin
      AColumnProperty.FNeedAggregation := True;
      AColumnProperty.FColumnAggregation.FType := AType;
      AColumnProperty.FColumnAggregation.FAggregation := AColumnProperty.Aggregation;
      Result := AColumnProperty.FColumnAggregation;
   End
   Else
      Result := nil;
End;


Constructor TdxColumnPropertyList.Create(AOwner: TdxCustomDBGridController);
Begin
   Inherited Create;
   FOwner := AOwner;

   SortedColumnCount := 0;
   SQLOrderBy        := '';

   FHaveColumnSearch := False;
   FHaveGlobalSearch := False;
   FHaveColumnFilter := False;

   Self.Sorted     := True;
   Self.Duplicates := dupIgnore;
End;

Destructor TdxColumnPropertyList.Destroy;
Var
   i: Integer = 0;
Begin
   // Destroy all associated object
   For i := 0 To Self.Count - 1 Do
      If Assigned(Self.Objects[i]) Then
      Begin
         Self.Objects[i].Free;
         Self.Objects[i] := nil;
      End;

   Inherited Destroy;
End;

{ TColumnProperty }

Procedure TdxColumnProperty.ResetAggregation;
Begin

   // Flag to tell if an aggregation is ask on this column
   // for a performance issue, calculate aggregation only when set to true
   FNeedAggregation := False;

   If Assigned(DistinctValueList) Then
      DistinctValueList.Clear;

   If Assigned(Column) Then
      FFooterAlignment := Column.Alignment
   Else
      FFooterAlignment := taLeftJustify;

   FFooterDisplayText := '';

   Aggregation.MinFloat    := 0.0;
   Aggregation.MinInt      := 0;
   Aggregation.MinStr      := '';
   Aggregation.MinDatetime := Now();

   Aggregation.MaxFloat    := 0.0;
   Aggregation.MaxInt      := 0;
   Aggregation.MaxStr      := '';
   Aggregation.MaxDatetime := Now();

   Aggregation.SumFloat := 0.0;
   Aggregation.SumInt   := 0;
   Aggregation.SumStr   := '';

   Aggregation.AvgFloat := 0.0;
   Aggregation.AvgInt   := 0;
   Aggregation.AvgStr   := '';

   Aggregation.Count    := 0;
   Aggregation.CountStr := '';

   Aggregation.Distinct    := 0;
   Aggregation.DistinctStr := '';

   Aggregation.CustomFloat := 0.0;
   Aggregation.CustomInt   := 0;
   Aggregation.CustomStr   := '';
End;

Constructor TdxColumnProperty.Create(AOwner: TdxColumnPropertyList; AColumn: TColumn; Rect: TRect);
Var
   ASearchEditor: TdxColumnSearchEditor;

Begin
   Inherited Create;
   // Set the owner.. this is a TStringList
   FOwner        := AOwner;
   FColumnAggregation := TdxColumnAggregation.Create;
   FCheckListbox := TChecklistBox.Create(nil);

   // Create the filter box object we need for this column
   ASearchEditor          := TdxColumnSearchEditor.Create(nil);
   ASearchEditor.Parent   := AOwner.FOwner.FGrid;
   ASearchEditor.Color    := AOwner.FOwner.FGrid.FixedColor;
   ASearchEditor.DoubleBuffered := True;
   ASearchEditor.AutoSize := False;
   ASearchEditor.Visible  := False;
   ASearchEditor.TabStop  := False;
   ASearchEditor.BorderStyle := bsNone;
   ASearchEditor.Text     := '';
   ASearchEditor.Font.Style := ASearchEditor.Font.Style + [fsBold];
   ASearchEditor.TextHint := '';
   ASearchEditor.CharCase := ecNormal;

   // set all the other members
   Column       := AColumn;
   ColumnSearchText := '';
   FilterSearchText := '';
   IndexSortOrder := -1;
   Field        := AColumn.Field;
   FieldName    := AColumn.FieldName;
   TitleCaption := AColumn.Title.Caption;
   TitleRect    := Rect;
   SearchEditor := ASearchEditor;
   SortOrder    := soNone;
   SQLOrderBy   := '';

   // Must reset aggregation on creation
   ResetAggregation;

   FilterValueList          := TStringList.Create;
   DistinctValueList        := TStringList.Create;
   DistinctValueList.Sorted := True;
   DistinctValueList.Duplicates := dupIgnore;

   // Finally Add this column property to the list
   FOwner.AddObject(AColumn.FieldName, Self);

End;

Destructor TdxColumnProperty.Destroy;
Begin
   If Assigned(FCheckListbox) Then
      FreeAndNil(FCheckListbox); // No object only string
   If Assigned(SearchEditor) Then
      FreeAndNil(SearchEditor);
   If Assigned(FilterValueList) Then
      FreeAndNil(FilterValueList);
   If Assigned(DistinctValueList) Then
      FreeAndNil(DistinctValueList);
   If Assigned(FColumnAggregation) Then
      FreeAndNil(FColumnAggregation);
   // Owned by the Grid...
   Column := nil;

   Inherited Destroy;
End;

Function TdxCustomDBGridController.CheckListBoxCount(CheckListBox: TCheckListBox): Integer;
Var
   checkedCount: Integer = 0;
   i: Integer;
Begin
   For i := 0 To CheckListBox.Count - 1 Do
      If CheckListBox.Checked[i] Then
         Inc(checkedCount);
   Result := checkedCount;
End;

Procedure TdxCustomDBGridController.RestoreGridEvents;
Begin
   // Reset the internal datasource events to nil
   FDatasource.OnDataChange := nil;
   FDatasource.OnUpdateData := nil;
   // Reset the Dataset OnFilterRecord to nil on the dataset linked to the grid
   FGrid.Datasource.Dataset.OnFilterRecord := nil;

   //Restore initial grid event's
   FGrid.OnEditButtonClick := FDBGridEvents.OnEditButtonClick;
   FGrid.OnGetCellHint     := FDBGridEvents.OnGetCellHint;
   FGrid.OnDrawColumnTitle := FDBGridEvents.OnDrawColumnTitle;
   FGrid.OnDrawColumnCell  := FDBGridEvents.OnDrawColumnCell;
   FGrid.OnMouseMove       := FDBGridEvents.OnMouseMove;
   FGrid.OnMouseDown       := FDBGridEvents.OnMouseDown;
   FGrid.OnKeyDown         := FDBGridEvents.OnKeyDown;
   FGrid.OnTitleClick      := FDBGridEvents.OnTitleClick;

End;

Procedure TdxCustomDBGridController.SetGrid(Const AValue: TDBGrid);
Begin
   If FGrid = AValue Then
      Exit;
   // Need to restore the parent
   If (AValue = nil) AND Assigned(FGrid) Then
      If Assigned(FGridPanel) Then
      Begin
         RestoreGridEvents;
         // Swap parent to old grid parent if not destroying
         If NOT (csDestroying IN FOldParent.ComponentState) Then
         Begin
            FGrid.Parent      := FOldParent;
            FGrid.Constraints := FOldConstraints;
            FGrid.Anchors     := FOldAnchors;
         End;
         FIsGridValid := False;
      End;
   // Set the new value
   FGrid := AValue;
   If Assigned(FGrid) Then
      CreateGridSubComponent
   Else
      DestroyGridSubComponent;
End;

Procedure TdxCustomDBGridController.CreateAllColumnProperty;
Var
   i:        Integer = 0;
   ColIndex: Integer = 0;
   AColumnProperty: tdxColumnProperty;
   ARect:    TRect;
Begin
   ARect.TopLeft     := Point(0, 0);
   ARect.BottomRight := Point(0, 0);
   For i := 0 To FGrid.Columns.Count - 1 Do
      If NOT Self.FColumnPropertyList.Find(FGrid.Columns[i].FieldName, ColIndex) Then
         If Assigned(FGrid.Columns[i].Field) Then
         Begin
            AColumnProperty           := TdxColumnProperty.Create(FColumnPropertyList, FGrid.Columns[i], ARect);
            AColumnProperty.FieldName := FGrid.Columns[i].FieldName;
            AColumnProperty.Field     := FGrid.Columns[i].Field;
            AColumnProperty.TitleCaption := FGrid.datasource.Dataset.Fields[i].DisplayLabel;
         End;
End;

Procedure TdxCustomDBGridController.CreateGridSubComponent;
Var
   dw, TopSpacing, BottomSpacing, LeftSpacing, RightSpacing: Integer;
Begin
   TopSpacing    := 3;
   BottomSpacing := 3;
   LeftSpacing   := 15;
   RightSpacing  := 15;
   // Create subcomponent only if we are on runtime ... not in design
   // and only if a grid is assign
   If IsGridValid Then
      If NOT (csDesigning IN ComponentState) Then
      Begin

         If NOT Assigned(FGroupValue) Then
            FGroupValue         := TStringList.Create;
         // Create list for each column filter box
         If NOT Assigned(FColumnPropertyList) Then
            FColumnPropertyList := TdxColumnPropertyList.Create(self);
         // Grid object to catch inherited events
         If NOT Assigned(FDBGridEvents) Then
            FDBGridEvents       := TDBGrid.Create(nil);
         // Datasource to catch the dataset scrolling event
         If NOT Assigned(FDatasource) Then
            FDatasource         := TDatasource.Create(Owner);
         // Image List
         If NOT Assigned(FImageList) Then
         Begin
            FImageList := TImageList.Create(Self);
            // Load ressource image on the Image list
            FImagelist.AddLazarusResource('first');
            FImagelist.AddLazarusResource('prior');
            FImagelist.AddLazarusResource('next');
            FImagelist.AddLazarusResource('end');
            FImagelist.AddLazarusResource('add');
            FImagelist.AddLazarusResource('trash');
            FImagelist.AddLazarusResource('edit');
            FImagelist.AddLazarusResource('save');
            FImagelist.AddLazarusResource('cancel');
            FImagelist.AddLazarusResource('refresh');
         End;
         // Set the grid dataset on the datasource used by the DBGridController
         If Assigned(FGrid.DataSource) Then
            FDatasource.DataSet := FGrid.DataSource.DataSet;
         // Create a timer use to delay the grid filtering - keyboard delay
         If NOT Assigned(FDelayedFiltering) Then
            FDelayedFiltering   := TTimer.Create(nil);
         If NOT Assigned(FDelayedGridDraw) Then
            FDelayedGridDraw    := TTimer.Create(nil);
         If NOT Assigned(FDelayedRecalculateAggregation) Then
            FDelayedRecalculateAggregation := TTimer.Create(nil);

         // Create all panels and other control needed for the
         // filter section and footer section
         // GridPanel is the owner of all the other controls
         If NOT Assigned(FGridPanel) Then
         Begin
            // If not exist create the container and swap parent
            FGridPanel        := TPanel.Create(Owner);
            // swap parent ... revert swap when assingning FGrid to nil
            FGridPanel.Parent := FGrid.Parent;
            FOldParent        := FGrid.Parent;
            FOldConstraints   := FGrid.Constraints;
            FOldAnchors       := FGrid.Anchors;
            FGrid.Parent      := FGridPanel;
         End;

         FGridPanel.Top         := FGrid.Top;
         FGridPanel.Left        := FGrid.Left;
         FGridPanel.Width       := FGrid.Width;
         FGridPanel.Height      := FGrid.Height;
         FGridPanel.Align       := FGrid.Align;
         FGridPanel.Constraints := FGrid.Constraints;
         FGridPanel.Anchors     := FGrid.Anchors;
         FGridPanel.BorderStyle := bsNone;
         FGridPanel.bevelOuter  := bvNone;
         FGridPanel.DoubleBuffered := True;
         FGridPanel.Color       := FGrid.Color;

         FGrid.Align          := alClient;
         FGrid.DoubleBuffered := True;

         If NOT Assigned(FTopPanel) Then
            FTopPanel         := TPanel.Create(FGridPanel);
         FTopPanel.Parent     := FGridPanel;
         FTopPanel.Align      := alTop;
         FTopPanel.bevelOuter := bvNone;
         FTopPanel.Height     := FTopPanelHeight;
         FTopPanel.Caption    := '';
         FTopPanel.Width      := 500;
         FTopPanel.Color      := FGrid.Color;

         If NOT Assigned(FColumnChooser) Then
         Begin
            FColumnChooser := TSpeedButton.Create(FGridPanel);
            FColumnChooser.Glyph.Assign(FGridGlyphColumnChooser);
         End;

         FColumnChooser.Left     := 0;
         FColumnChooser.Width    := 25;
         FColumnChooser.Parent   := FTopPanel;
         FColumnChooser.BorderSpacing.Around := TopSpacing;
         FColumnChooser.align    := alLeft;
         FColumnChooser.Flat     := True;
         FColumnChooser.ShowHint := True;
         FColumnChooser.Hint     := GetLocalisation(FSearchEditor, msg_columnchooser);

         If NOT Assigned(FSearchEditor) Then
         Begin
            FSearchEditor := TdxSearchEditor.Create(FGridPanel);
            FSearchEditor.Glyph.Assign(FGridGlyphCancelFilter);
         End;
         FSearchEditor.Left   := 0;
         FSearchEditor.Parent := FTopPanel;
         FSearchEditor.BorderSpacing.Top := TopSpacing;
         FSearchEditor.BorderSpacing.Bottom := BottomSpacing;
         FSearchEditor.BorderSpacing.Right := RightSpacing;

         FSearchEditor.Filter   := '';
         FSearchEditor.Text     := '';
         FSearchEditor.Width    := FSearchBoxWidth;
         FSearchEditor.CharCase := ecNormal;
         FSearchEditor.TextHint := GetLocalisation(FSearchEditor, msg_search);
         FSearchEditor.Flat     := True;
         FSearchEditor.Align    := alRight;

         If NOT Assigned(FNavigator) Then
            FNavigator          := TDBNavigator.Create(FGridPanel);
         FNavigator.Images      := FImageList;
         FNavigator.Parent      := FTopPanel;
         FNavigator.Left        := 125;
         FNavigator.BorderSpacing.Top := TopSpacing;
         FNavigator.BorderSpacing.Bottom := BottomSpacing;
         FNavigator.BorderSpacing.Right := RightSpacing;
         FNavigator.DataSource  := FGrid.DataSource;
         FNavigator.VisibleButtons := [nbInsert, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh];
         FNavigatorDefaultWidth := FNavigator.GetDefaultWidth;
         FNavigator.Width       := Trunc(FNavigatorDefaultWidth * FNavigator.VisibleButtonCount / 10);
         FNavigator.Align       := alRight;
         FNavigator.Flat        := True;
         FNavigator.Hints.Clear;
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_first));
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_prior));
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_next));
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_last));
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_add));
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_delete));
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_edit));
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_save));
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_cancel));
         FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_refresh));
         FNavigator.Left    := 0;
         FSearchEditor.Left := 10000;

         If NOT Assigned(FBottomPanel) Then
            FBottomPanel         := TPanel.Create(FGridPanel);
         FBottomPanel.Parent     := FGridPanel;
         FBottomPanel.Align      := alBottom;
         FBottomPanel.bevelOuter := bvNone;
         FBottomPanel.Height     := FBottomPanelHeight;
         FBottomPanel.Caption    := '';
         FBottomPanel.Color      := FGrid.Color;

         If NOT Assigned(FFooterPanel) Then
            FFooterPanel         := TPanel.Create(FGridPanel);
         FFooterPanel.Parent     := FGridPanel;
         FFooterPanel.Align      := alBottom;
         FFooterPanel.bevelOuter := bvNone;
         FFooterPanel.Height     := FBottomPanelHeight;
         FFooterPanel.Caption    := '';
         FFooterPanel.Color      := FGrid.Color;
         FFooterPanel.Visible    := (coShowFooter IN FControllerOptions);
         FFooterPanel.Top        := 0;
         FFooterPanel.Height     := FGrid.DefaultRowHeight;

         If NOT Assigned(FPageSelector) Then
            FPageSelector         := TDBNavigator.Create(FGridPanel);
         FPageSelector.Images     := FImageList;
         FPageSelector.Left       := 125;
         FPageSelector.Parent     := FBottomPanel;
         FPageSelector.BorderSpacing.Top := TopSpacing;
         FPageSelector.BorderSpacing.Bottom := BottomSpacing;
         FPageSelector.BorderSpacing.Right := RightSpacing;
         FPageSelector.DataSource := FGrid.DataSource;
         FPageSelector.VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast];
         FPageSelector.Width      := Trunc(FPageSelector.GetDefaultWidth * FPageSelector.VisibleButtonCount / 10);
         FPageSelector.Align      := alRight;
         FPageSelector.Flat       := True;
         FPageSelector.Hints.Clear;
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_first));
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_prior));
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_next));
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_last));
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_add));
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_delete));
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_edit));
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_save));
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_cancel));
         FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_refresh));

         If NOT Assigned(FPageCount) Then
            FPageCount         := TLabel.Create(FGridPanel);
         FPageCount.Left       := 125;
         FPageCount.Parent     := FBottomPanel;
         FPageCount.BorderSpacing.Top := TopSpacing;
         FPageCount.BorderSpacing.Bottom := BottomSpacing;
         FPageCount.BorderSpacing.Right := RightSpacing;
         FPageCount.Align      := alRight;
         FPageCount.Alignment  := taCenter;
         FPageCount.Layout     := tlCenter;
         FPageCount.Font.Color := clInfoText;
         FPageCount.Font.Style := FPageCount.Font.Style + [fsBold];
         FPageCount.Left       := 0;
         FPageSelector.Left    := 10000;

         If NOT Assigned(FFilterInfo) Then
            FFilterInfo         := TLabel.Create(FGridPanel);
         FFilterInfo.Left       := 0;
         FFilterInfo.Parent     := FBottomPanel;
         FFilterInfo.BorderSpacing.Top := TopSpacing;
         FFilterInfo.BorderSpacing.Bottom := BottomSpacing;
         FFilterInfo.BorderSpacing.Left := LeftSpacing;
         FFilterInfo.Align      := alLeft;
         FFilterInfo.Alignment  := taLeftJustify;
         FFilterInfo.Layout     := tlCenter;
         FFilterInfo.Caption    := '';
         FFilterInfo.Font.Color := clInfoText;
         FFilterInfo.Font.Style := FPageCount.Font.Style + [fsBold];
         // Disable HotTracking ... TO DO Eventually taking care of this
         FGrid.Options          := FGrid.Options - [dgHeaderHotTracking];

         SetObjectEvents;
         SetRecordCount;

         CreateAllColumnProperty;
         // Trigger the search and aggreation with the delayed timer...
         FDelayedFiltering.Enabled := True;
      End;
         // To force positionning correctly
   If Assigned(FBottomPanel) Then
      FBottomPanel.Top := 10000;
         // Set Grid button style
   SetGridButtonStyle(ftDateTime, cbsEllipsis);
   SetGridButtonStyle(ftDataset, cbsEllipsis);
   SetGridButtonStyle(ftMemo, cbsEllipsis);
End;

Procedure TdxCustomDBGridController.DestroyGridSubComponent;
Var
   i: Integer;
Begin
   If NOT (csDesigning IN ComponentState) Then
   Begin

      // CASE 1 - Detroy when DBGridController is destroying or DBGrid property is set to nil
      If Assigned(FDBGridEvents) Then
         FreeAndNil(FDBGridEvents);
      If Assigned(FColumnPropertyList) Then
         FreeAndNil(FColumnPropertyList);
      If Assigned(FDelayedFiltering) Then
         FreeAndNil(FDelayedFiltering);
      If Assigned(FDelayedGridDraw) Then
         FreeAndNil(FDelayedGridDraw);
      If Assigned(FDelayedRecalculateAggregation) Then
         FreeAndNil(FDelayedRecalculateAggregation);
      If Assigned(FGroupValue) Then
         FreeAndNil(FGroupValue);

      // CASE 2 - Destroy only if the DBGridController is destroying
      If (csDestroying IN ComponentState) Then
      Begin
         FreeAndNil(FGridGlyphCancelFilter);
         FreeAndNil(FGridGlyphSortUp);
         FreeAndNil(FGridGlyphSortDown);
         FreeAndNil(FGridGlyphFind);
         FreeAndNil(FGridGlyphColumnFilter);
         FreeAndNil(FGridGlyphColumnHaveFilter);
         FreeAndNil(FGridGlyphColumnChooser);
         FreeAndNil(FGridGlyphSelectAll);
         FreeAndNil(FGridGlyphSortingAsc);
         FreeAndNil(FGridGlyphSortingDesc);
      End;
      // CASE 3 - Parent of DBGridController is not destroying but DBGrid property was set to nil
      // FDatasource and FGridPanel ... it is te actual form that will take care of that
      If Assigned(FOldParent) Then
         If NOT (csDestroying IN FOldParent.ComponentState) Then
         Begin
            FreeAndNil(FDatasource);
            // Free the GridPanel
            // All component associated with GridPanel will be destroyed  (GridPanel is the owner)
            FreeAndNil(FGridPanel);
            // Set the pointer reference to nil
            FTopPanel      := nil;
            FColumnChooser := nil;
            FSearchEditor  := nil;
            FFooterPanel   := nil;
            FBottomPanel   := nil;
            FNavigator     := nil;
            FPageCount     := nil;
            FFilterInfo    := nil;
            FPageSelector  := nil;
            FImageList     := nil;
         End;
   End;
End;

Procedure TdxCustomDBGridController.Loaded;
Begin
   Inherited Loaded;
   // Create all subcomponent properties
   CreateGridSubComponent;
End;

Procedure TdxCustomDBGridController.Updated;
Begin
   Inherited Updated;
End;


Procedure TdxCustomDBGridController.SetRecordCount;
Begin
   If FIsGridValid Then
      If Self.FPageCount <> nil Then
         FPageCount.Caption := '';
End;

Function TdxCustomDBGridController.IsGridValid: Boolean;
Begin
   FIsGridValid := False;
   If Assigned(FGrid) Then
      If Assigned(FGrid.Datasource) Then
         If Assigned(FGrid.Datasource.Dataset) Then
            // Grid.. all columns are created properly
            FIsGridValid := (FGrid.Datasource.Dataset.FieldCount > 0);

   Result := FIsGridValid;
End;

Procedure TdxCustomDBGridController.TriggerTimer(Sender: TObject);
Begin
   FDelayedFiltering.Enabled := False;
   SetGridDatsetFilter;
End;

Procedure TdxCustomDBGridController.GridDrawTimer(Sender: TObject);
Begin
   FDelayedGridDraw.Enabled := False;
   GridShowNoData;
End;

Procedure TdxCustomDBGridController.RecalculateAggregationTimer(Sender: TObject);
Begin
   FDelayedRecalculateAggregation.Enabled := False;
   RecalculateAggregation;
End;

Procedure TdxCustomDBGridController.Navigator1Click(Sender: TObject; Button: TDBNavButtonType);
Begin
   If Button IN [nbDelete, nbRefresh] Then
      RecalculateAggregation;
End;


Function TdxCustomDBGridController.GetCurrentColumnIndex: Integer;
Begin
   Result := -1;
   If FIsGridValid Then
      If dgIndicator IN FGrid.Options Then
         Result := FGrid.SelectedIndex + 1
      Else
         Result := FGrid.SelectedIndex;
End;

Procedure TdxCustomDBGridController.SetGridButtonStyle(Const AFieldType: TFieldType; AButtonStyle: TColumnButtonStyle);
Var
   i:      Integer;
   AField: TField;
   ButtonActive: Boolean;
Begin
   // Activate or not the inplace editor for memo datetime and lookup
   Case AFieldType Of
      ftMemo: ButtonActive     := (coMemoEditor IN FControllerOptions) AND (AFieldType = ftMemo);
      ftDateTime: ButtonActive := (coDatetimeEditor IN FControllerOptions) AND (AFieldType = ftDateTime);
      ftDataSet: ButtonActive  := (coLookupEditor IN FControllerOptions) AND (AFieldType = ftDataSet);
   End;

   If FIsGridValid Then
      For i := 0 To FGrid.Columns.Count - 1 Do
      Begin
         AField := FGrid.DataSource.DataSet.FieldByName(FGrid.Columns[i].FieldName);
         If AField <> nil Then
            Case AFieldType Of
               ftMemo: If AField.DataType IN [ftMemo, ftFmtMemo, ftWideMemo] Then
                     If ButtonActive Then
                        FGrid.Columns[i].ButtonStyle := AButtonStyle
                     Else
                        FGrid.Columns[i].ButtonStyle := cbsAuto;
               ftDateTime: If AField.DataType IN [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                     If ButtonActive Then
                        FGrid.Columns[i].ButtonStyle := AButtonStyle
                     Else
                        FGrid.Columns[i].ButtonStyle := cbsAuto;
               ftDataSet: If Assigned(AField.LookupDataSet) Then
                     If ButtonActive Then
                        FGrid.Columns[i].ButtonStyle := AButtonStyle
                     Else
                        FGrid.Columns[i].ButtonStyle := cbsAuto;
            End;
      End;
End;


Constructor TdxCustomDBGridController.Create(AOwner: TComponent);
Begin
   Inherited Create(AOwner);


   FControllerVersion := sVersion;
   FUseDatasetSorting := True;
   FIndexCount        := 0;
   FNeedRecalculateAggregation := False;


   // Create Bitmap
   FGridGlyphCancelFilter  := TPortableNetworkGraphic.Create;
   FGridGlyphSortUp        := TPortableNetworkGraphic.Create;
   FGridGlyphSortDown      := TPortableNetworkGraphic.Create;
   FGridGlyphFind          := TPortableNetworkGraphic.Create;
   FGridGlyphColumnFilter  := TPortableNetworkGraphic.Create;
   FGridGlyphColumnHaveFilter := TPortableNetworkGraphic.Create;
   FGridGlyphColumnChooser := TPortableNetworkGraphic.Create;
   FGridGlyphSelectAll     := TPortableNetworkGraphic.Create;
   FGridGlyphSortingAsc    := TPortableNetworkGraphic.Create;
   FGridGlyphSortingDesc   := TPortableNetworkGraphic.Create;

   FGridGlyphCancelFilter.OnChange  := nil;
   FGridGlyphSortUp.OnChange        := nil;
   FGridGlyphSortDown.OnChange      := nil;
   FGridGlyphFind.OnChange          := nil;
   FGridGlyphColumnFilter.OnChange  := nil;
   FGridGlyphColumnHaveFilter.OnChange := nil;
   FGridGlyphColumnChooser.OnChange := nil;
   FGridGlyphSelectAll.OnChange     := nil;
   FGridGlyphSortingAsc.OnChange    := nil;
   FGridGlyphSortingDesc.OnChange   := nil;
   // Laod default image...
   Try
      FGridGlyphCancelFilter.LoadFromLazarusResource('clear_filter');
      FGridGlyphSortUp.LoadFromLazarusResource('up');
      FGridGlyphSortDown.LoadFromLazarusResource('down');
      FGridGlyphFind.LoadFromLazarusResource('search');
      FGridGlyphColumnFilter.LoadFromLazarusResource('filter');
      FGridGlyphColumnHaveFilter.LoadFromLazarusResource('have_filter');
      FGridGlyphColumnChooser.LoadFromLazarusResource('menu');
      FGridGlyphSelectAll.LoadFromLazarusResource('select_all');
      FGridGlyphSortingAsc.LoadFromLazarusResource('sorting_asc');
      FGridGlyphSortingDesc.LoadFromLazarusResource('sorting_desc');
   Except
   End;
   // Initialise default value for properties
   FControllerOptions := [coMemoEditor, coDatetimeEditor, coDefaultDrawingFooter, coLookupEditor, coShowColumnFilter];

   FSearchTypingDelay    := 550;
   FTopPanelHeight       := 30;
   FBottomPanelHeight    := 30;
   FColumnSelectAllLimit := 200;

   FSortIndexColor        := clSortIndex;
   FSearchColor           := clSearch;
   FSearchTextColor       := clSearchText;
   FColumnSearchColor     := clColumnSearch;
   FColumnSearchTextColor := clColumnSearchText;
   FGroupLineColor        := clGroupLine;
   FGroupLineWidth        := 1;

   FIsGridValid           := False;
   FSearchBoxWidth        := 150;
   // Define shortcut
   FSearchBoxShortCut     := TextToShortCut('Ctrl+F');
   FColumnChooserShortCut := TextToShortCut('Ctrl+H');
   FColumnFilterShortCut  := TextToShortCut('Ctrl+J');
End;

Destructor TdxCustomDBGridController.Destroy;
Begin
   // Property change will take care of destroying all subcomponent
   Self.DBGrid := nil;
   Inherited Destroy;
End;

Procedure TdxCustomDBGridController.SetTopPanelHeight(Const AValue: Integer);
Begin
   If FTopPanelHeight = AValue Then
      Exit;
   FTopPanelHeight := AValue;

   If Assigned(FTopPanel) Then
      FTopPanel.Height := FTopPanelHeight;
End;

Procedure TdxCustomDBGridController.SetBottomPanelHeight(Const AValue: Integer);
Begin
   If FBottomPanelHeight = AValue Then
      Exit;
   FBottomPanelHeight := AValue;

   If Assigned(FBottomPanel) Then
      FBottomPanel.Height := FBottomPanelHeight;
End;

Procedure TdxCustomDBGridController.SetSearchColor(AValue: TColor);
Begin
   If FSearchColor = AValue Then
      exit;
   FSearchColor := AValue;
End;


Function TdxCustomDBGridController.CreatePopupForm(Column: TColumn; PopupType: TdxPopupType): TdxFormLookup;
Var
   fmResult: TdxFormLookup = nil;
   AColumnProperty: TdxColumnProperty;
   i: Integer;
Begin
   // Create a popup form adapted to TFieldType
   fmResult := TdxFormLookup.CreateNew(Self);
   fmResult.KeyPreview := True;

   Try
      // Init variables
      If PopupType = ptEditor Then
         fmResult.FRect := FCurrentCellRect
      Else If PopupType = ptColumnFilter Then
         fmResult.FRect := FLastHitRegion
      Else If PopupType = ptColumnChooser Then
      Begin
         fmResult.FRect.Top    := 0;
         fmResult.FRect.Left   := 0;
         fmResult.FRect.Height := 10;
         fmResult.FRect.Width  := 10;
      End;

      fmResult.FRect.Left   := fmResult.FRect.Left + FGrid.Left;
      fmResult.FRect.Top    := fmResult.FRect.Top + FGrid.Top - 1;
      fmResult.FRect.Height := fmResult.FRect.Height + FGrid.Top;
      fmResult.FRect.Width  := fmResult.FRect.Width + FGrid.Left;
      fmResult.color        := Self.FGrid.Color;
      fmResult.Font         := Self.FGrid.Font;

      //Get the top left point where to place the form
      fmResult.FPoint := Self.FGridPanel.ClientToScreen(fmResult.FRect.TopLeft);

      // External object pointer
      // Do not destroy when freeing the form
      fmResult.FField          := Column.Field;
      fmResult.FColumnProperty := Self.FColumnPropertyList.ColumnPropertyByName(fmResult.FField.FieldName);
      fmResult.FDataSet        := fmResult.FField.Dataset;
      fmResult.FLookupDataset  := fmResult.FField.LookupDataSet;

      // Set the form property
      fmResult.FormStyle   := fsStayOnTop;
      fmResult.BorderStyle := bsNone;
      fmResult.Width       := Max(fmResult.FRect.Width, 200);
      fmResult.Color       := FGrid.Color;

      // According to the editor type place at the right position
      If PopupType = ptEditor Then
      Begin
         fmResult.Left   := fmResult.FPoint.x;
         fmResult.Top    := fmResult.FPoint.y + fmResult.FRect.Height;
         fmResult.Width  := Max(fmResult.FRect.Width, 250);
         fmResult.Height := 350;
      End
      Else If PopupType = ptColumnFilter Then
      Begin
         fmResult.Left   := fmResult.FPoint.x;
         fmResult.Top    := fmResult.FPoint.y + fmResult.FRect.Height;
         fmResult.Height := 355;
         fmResult.Width  := 250;
      End
      Else If PopupType = ptColumnChooser Then
      Begin
         fmResult.Left   := fmResult.FPoint.x;
         fmResult.Top    := fmResult.FPoint.y;
         fmResult.Height := 350;
      End;

      fmResult.FTopPanel        := TPanel.Create(fmResult);
      fmResult.FTopPanel.Parent := fmResult;
      fmResult.FTopPanel.Align  := alTop;
      fmResult.FTopPanel.ParentColor := True;
      fmResult.FtopPanel.Height := 30;
      fmResult.FtopPanel.BevelOuter := bvNone;
      fmResult.FtopPanel.BorderSpacing.Around := 1;

      fmResult.FClientPanel        := TPanel.Create(fmResult);
      fmResult.FClientPanel.Parent := fmResult;
      fmResult.FClientPanel.Align  := alClient;
      fmResult.FClientPanel.ParentColor := True;
      fmResult.FClientPanel.BevelOuter := bvNone;
      fmResult.FClientPanel.BorderSpacing.Around := 1;

      fmResult.FBottomPanel        := TPanel.Create(fmResult);
      fmResult.FBottomPanel.Parent := fmResult;
      fmResult.FBottomPanel.Align  := alBottom;
      fmResult.FBottomPanel.Height := 30;
      fmResult.FBottomPanel.ParentColor := True;
      fmResult.FBottomPanel.BevelOuter := bvNone;
      fmResult.FBottomPanel.BorderSpacing.Around := 1;

      fmResult.FbtnOk         := TBitBtn.Create(fmResult);
      fmResult.FbtnOk.Parent  := fmResult.FBottomPanel;
      fmResult.FbtnOk.ModalResult := mrOk;
      fmResult.FbtnOk.Align   := alright;
      fmResult.FbtnOk.BorderSpacing.Around := 3;
      fmResult.FbtnOk.GlyphShowMode := gsmNever;
      fmResult.FbtnOk.Kind    := bkOK;
      fmResult.FbtnOk.Caption := GetLocalisation(fmResult.FbtnOk, msg_btnok);

      fmResult.FbtnCancel         := TBitBtn.Create(fmResult);
      fmResult.FbtnCancel.Parent  := fmResult.FBottomPanel;
      fmResult.FbtnCancel.ModalResult := mrCancel;
      fmResult.FbtnCancel.Align   := alright;
      fmResult.FbtnCancel.BorderSpacing.Around := 3;
      fmResult.FbtnCancel.GlyphShowMode := gsmNever;
      fmResult.FbtnCancel.Kind    := bkCancel;
      fmResult.FbtnCancel.Caption := GetLocalisation(fmResult.FbtnCancel, msg_btncancel);

      fmResult.FDisplayTextList        := TStringList.Create;
      fmResult.FDisplayTextList.Sorted := True;
      fmResult.FDisplayTextList.Duplicates := dupIgnore;

      fmResult.FColumnProperty.FCheckListBox.Parent      := fmResult.FClientPanel;
      fmResult.FColumnProperty.FCheckListBox.Align       := alClient;
      fmResult.FColumnProperty.FCheckListBox.BorderStyle := bsnone;
      fmResult.FColumnProperty.FCheckListBox.ParentColor := True;
      fmResult.FColumnProperty.FCheckListBox.BorderSpacing.Around := 3;
      fmResult.FColumnProperty.FCheckListBox.Visible     := PopupType = ptColumnFilter;

      If (PopupType = ptColumnChooser) Then
      Begin
         fmResult.FtopPanel.Visible         := False;
         fmResult.FColumnChooserList        := TCheckListBox.Create(fmResult);
         fmResult.FColumnChooserList.Parent := fmResult.FClientPanel;
         fmResult.FColumnChooserList.Align  := alClient;
         fmResult.FColumnChooserList.BorderStyle := bsnone;
         fmResult.FColumnChooserList.ParentColor := True;
         fmResult.FColumnChooserList.BorderSpacing.Around := 3;

         fmResult.FSearchEditor          := TdxSearchEditor.Create(fmResult);
         fmResult.FSearchEditor.Glyph.Assign(Self.FGridGlyphCancelFilter);
         fmResult.FSearchEditor.Left     := 0;
         fmResult.FSearchEditor.Parent   := fmResult.FClientPanel;
         fmResult.FSearchEditor.BorderSpacing.Around := 4;
         fmResult.FSearchEditor.Filter   := '';
         fmResult.FSearchEditor.Text     := Self.FLookupSearchText;
         fmResult.FSearchEditor.Align    := alTop;
         fmResult.FSearchEditor.CharCase := ecNormal;
         fmResult.FSearchEditor.TextHint := GetLocalisation(FSearchEditor, msg_search);
         fmResult.FSearchEditor.Flat     := True;
         fmResult.FSearchEditor.AutoSelect := False;

         // populate the list with the actual column
         For i := 0 To FGrid.Columns.Count - 1 Do
         Begin
            AColumnProperty := Self.FColumnPropertyList.ColumnPropertyByName(FGrid.Columns[i].FieldName);
            fmResult.FColumnChooserList.AddItem(FGrid.Columns[i].Title.Caption, nil);
            If FGrid.Columns[i].Visible Then
               fmResult.FColumnChooserList.Checked[i] := True;
         End;

         fmResult.FSearchEditor.FilteredListbox := fmResult.FColumnChooserList;

      End
      Else If (PopupType = ptColumnFilter) Then
      Begin
         fmResult.FTopPanel.Height := (23 * 4) + (2 * gBorderSpace);

         fmResult.FbtnSortingAsc          := TSpeedButton.Create(FGridPanel);
         fmResult.FbtnSortingAsc.Glyph.Assign(FGridGlyphSortingAsc);
         fmResult.FbtnSortingAsc.Left     := 0;
         fmResult.FbtnSortingAsc.Width    := 25;
         fmResult.FbtnSortingAsc.Parent   := fmResult.FTopPanel;
         fmResult.FbtnSortingAsc.BorderSpacing.Around := gBorderSpace;
         fmResult.FbtnSortingAsc.align    := alTop;
         fmResult.FbtnSortingAsc.Layout   := blGlyphLeft;
         fmResult.FbtnSortingAsc.margin   := 0;
         fmResult.FbtnSortingAsc.Flat     := True;
         fmResult.FbtnSortingAsc.ShowHint := True;
         fmResult.FbtnSortingAsc.Caption  := GetLocalisation(FSearchEditor, msg_sortingasc);
         fmResult.FbtnSortingAsc.Hint     := GetLocalisation(FSearchEditor, msg_sortingasc);
         fmResult.FbtnSortingAsc.OnClick  := @fmResult.SortingAsc;
         fmResult.FbtnSortingAsc.top      := -1;

         fmResult.FbtnSortingDesc          := TSpeedButton.Create(FGridPanel);
         fmResult.FbtnSortingDesc.Glyph.Assign(FGridGlyphSortingDesc);
         fmResult.FbtnSortingDesc.Left     := 0;
         fmResult.FbtnSortingDesc.Width    := 25;
         fmResult.FbtnSortingDesc.Parent   := fmResult.FTopPanel;
         fmResult.FbtnSortingDesc.BorderSpacing.Around := gBorderSpace;
         fmResult.FbtnSortingDesc.align    := alTop;
         fmResult.FbtnSortingDesc.Layout   := blGlyphLeft;
         fmResult.FbtnSortingDesc.margin   := 0;
         fmResult.FbtnSortingDesc.Flat     := True;
         fmResult.FbtnSortingDesc.ShowHint := True;
         fmResult.FbtnSortingDesc.Caption  := GetLocalisation(FSearchEditor, msg_sortingdesc);
         fmResult.FbtnSortingDesc.Hint     := GetLocalisation(FSearchEditor, msg_sortingdesc);
         fmResult.FbtnSortingDesc.OnClick  := @fmResult.SortingDesc;
         fmResult.FbtnSortingDesc.top      := 30;

         fmResult.FTopPanel.Visible        := True;
         fmResult.FBtnClearFilter          := TSpeedButton.Create(FGridPanel);
         fmResult.FBtnClearFilter.Glyph.Assign(FGridGlyphCancelFilter);
         fmResult.FBtnClearFilter.Left     := 0;
         fmResult.FBtnClearFilter.Width    := 25;
         fmResult.FBtnClearFilter.Parent   := fmResult.FTopPanel;
         fmResult.FBtnClearFilter.BorderSpacing.Around := gBorderSpace;
         fmResult.FBtnClearFilter.align    := alTop;
         fmResult.FBtnClearFilter.Layout   := blGlyphLeft;
         fmResult.FBtnClearFilter.margin   := 0;
         fmResult.FBtnClearFilter.Flat     := True;
         fmResult.FBtnClearFilter.ShowHint := True;
         fmResult.FBtnClearFilter.Caption  := GetLocalisation(FSearchEditor, msg_clearselection);
         fmResult.FBtnClearFilter.Hint     := GetLocalisation(FSearchEditor, msg_clearselection);
         fmResult.FBtnClearFilter.OnClick  := @fmResult.ClearFilterOnClick;
         fmResult.FBtnClearFilter.top      := 900;

         fmResult.FbtnSelectAll          := TSpeedButton.Create(FGridPanel);
         fmResult.FbtnSelectAll.Glyph.Assign(FGridGlyphSelectAll);
         fmResult.FbtnSelectAll.Left     := 0;
         fmResult.FbtnSelectAll.Width    := 25;
         fmResult.FbtnSelectAll.Parent   := fmResult.FTopPanel;
         fmResult.FbtnSelectAll.BorderSpacing.Around := gBorderSpace;
         fmResult.FbtnSelectAll.align    := alTop;
         fmResult.FbtnSelectAll.Layout   := blGlyphLeft;
         fmResult.FbtnSelectAll.margin   := 0;
         fmResult.FbtnSelectAll.Flat     := True;
         fmResult.FbtnSelectAll.ShowHint := True;
         fmResult.FbtnSelectAll.Caption  := GetLocalisation(FSearchEditor, msg_selectall);
         fmResult.FbtnSelectAll.Hint     := GetLocalisation(FSearchEditor, msg_selectall);
         fmResult.FbtnSelectAll.OnClick  := @fmResult.SelectAllOnClick;
         fmResult.FbtnSelectAll.top      := 900;

         fmResult.FSearchEditor          := TdxSearchEditor.Create(fmResult);
         fmResult.FSearchEditor.Glyph.Assign(Self.FGridGlyphCancelFilter);
         fmResult.FSearchEditor.Left     := 0;
         fmResult.FSearchEditor.Parent   := fmResult.FClientPanel;
         fmResult.FSearchEditor.BorderSpacing.Around := 4;
         fmResult.FSearchEditor.Filter   := '';
         fmResult.FSearchEditor.Text     := Self.FLookupSearchText;
         fmResult.FSearchEditor.Align    := alTop;
         fmResult.FSearchEditor.CharCase := ecNormal;
         fmResult.FSearchEditor.TextHint := GetLocalisation(FSearchEditor, msg_search);
         fmResult.FSearchEditor.Flat     := True;
         fmResult.FSearchEditor.AutoSelect := False;
         fmResult.FbtnSelectAll.top      := 1000;

      End
      Else
      If (PopupType = ptEditor) AND Assigned(fmResult.FField) Then
         If (fmResult.FField.DataType IN [ftDate, ftTime, ftDateTime]) Then
         Begin
            fmResult.FTopPanel.Visible := False;
            fmResult.FCalendar := TCalendar.Create(fmResult);
            fmResult.FCalendar.DateTime := FGrid.SelectedColumn.Field.AsDateTime;
            fmResult.FCalendar.Parent := fmResult.FClientPanel;
            fmResult.FCalendar.Align := alClient;
            fmResult.FCalendar.TabStop := True;
            fmResult.FCalendar.AutoSize := True;
            fmResult.FCalendar.Color := FGrid.Color;
            fmResult.FCalendar.BorderSpacing.Around := 3;
            fmResult.Width  := fmResult.FCalendar.Width + 12;
            fmResult.Height := fmResult.FCalendar.Height + 6;

            If fmResult.FField.IsNull Then
               fmResult.FCalendar.DateTime := Now;

         End
         Else
         // MEMO
         If fmResult.FField.DataType IN [ftMemo, ftFmtMemo, ftWideMemo] Then
         Begin
            fmResult.FTopPanel.Visible := False;
            fmResult.FMemo           := TDBMemo.Create(fmResult);
            fmResult.FMemo.DataField := FGrid.SelectedColumn.Field.FieldName;
            fmResult.FMemo.BorderSpacing.Around := 3;
            fmResult.FMemo.Align     := alClient;
            fmResult.FMemo.BorderStyle := bsnone;
            fmResult.FMemo.BorderWidth := 1;
            fmResult.FMemo.DataSource := FGrid.DataSource;
            fmResult.FMemo.Parent    := fmResult.FClientPanel;
            fmResult.FMemo.Color     := FGrid.Color;
            fmResult.FMemo.OnKeyDown := @fmResult.OnKeyDown;
         End
         Else
         Begin
            // Lookup
            fmResult.Height := 350;
            fmResult.Width  := 350;

            // Call On Prepare Lookup Search event to provide the dataset
            // that will be used to show the selection list
            // the dataset for search will be pass in the ADataset object pointer
            If Assigned(FOnPrepareLookupDataset) Then
               FOnPrepareLookupDataset(Self, fmResult.FLookupDataset, fmResult.FField);
            // Open the lookup Dataset
            fmResult.FLookupDataset.Active := True;

            If Assigned(fmResult.FLookupDataset) Then
            Begin

               fmResult.FSearchEditor           := TdxSearchEditor.Create(fmResult);
               fmResult.FSearchEditor.Glyph.Assign(Self.FGridGlyphCancelFilter);
               fmResult.FSearchEditor.Left      := 0;
               fmResult.FSearchEditor.Parent    := fmResult.FTopPanel;
               fmResult.FSearchEditor.BorderSpacing.Around := 3;
               fmResult.FSearchEditor.Filter    := '';
               fmResult.FSearchEditor.Text      := Self.FLookupSearchText;
               fmResult.FSearchEditor.Align     := alTop;
               fmResult.FSearchEditor.CharCase  := ecNormal;
               fmResult.FSearchEditor.TextHint  := GetLocalisation(FSearchEditor, msg_search);
               fmResult.FSearchEditor.Flat      := True;
               fmResult.FSearchEditor.AutoSelect := False;
               fmResult.FSearchEditor.OnChange  := @fmResult.FilterBoxOnChange;
               fmResult.FSearchEditor.OnKeyDown := @fmResult.FilterBoxOnKeyDown;

               // Assign the filtering procedure
               fmResult.FLookupDataset.Filtered       := False;
               fmResult.FLookupDataset.OnFilterRecord := @fmResult.FilterRecord;

               // Try to locate the record refer to the key and show it on the lookup list
               fmResult.FLookupDataset.Locate(fmResult.FField.LookupKeyFields, fmResult.FField.DataSet.FieldByName(fmResult.FField.KeyFields).Value,
                  [loCaseInsensitive, loPartialKey]);

               // Create a data source for the lookup grid
               fmResult.FLookupDatasource := TDatasource.Create(fmResult);
               fmResult.FLookupDatasource.DataSet := fmResult.FLookupDataset;
               // Create the grid
               fmResult.FDBGrid           := TDBGrid.Create(fmResult);
               fmResult.FDBGrid.Parent    := fmResult.FClientPanel;
               fmResult.FDBGrid.Align     := alClient;
               fmResult.FDBGrid.AutoAdvance := aaNone;
               fmResult.FDBGrid.TabAdvance := aaNone;
               fmResult.FDBGrid.TabStop   := True;
               fmResult.FDBGrid.DefaultRowHeight := 16;
               fmResult.FDBGrid.BorderWidth := 0;
               fmResult.FDBGrid.ParentColor := True;
               fmResult.FDBGrid.BorderSpacing.Around := 3;
               fmResult.FDBGrid.Height    := fmResult.Height - fmResult.FSearchEditor.Height - fmResult.FbtnOk.Height - 6;
               fmResult.FDBGrid.DataSource := fmResult.FLookupDatasource;
               fmResult.FDBGrid.ScrollBars := ssVertical;
               fmResult.FDBGrid.Options   := fmResult.FDBGrid.Options - [dgColLines, dgRowLines, dgTitles, dgIndicator] +
                  [dgAlwaysShowSelection, dgDisableInsert, dgRowSelect, dgDisableDelete, dgAutoSizeColumns, dgRowHighLight];
               fmResult.FDBGrid.AdjustSize;
               fmResult.FDBGrid.AutoAdjustColumns;
               fmResult.FDBGrid.Visible   := (PopupType = ptEditor);
               fmResult.FDBGrid.OnKeyDown := @fmResult.OnKeyDown;
               fmResult.FDBGrid.OnDblClick := @fmResult.GridOnDblClick;
            End;
         End;

      // Attach event
      fmResult.OnPaint      := @fmResult.Paint;
      fmResult.OnShow       := @fmResult.Show;
      fmResult.OnMouseEnter := @fmResult.MouseEnter;
      fmResult.OnMouseLeave := @fmResult.MouseLeave;

   Finally
      Result := fmResult;
   End;
End;


Procedure TdxCustomDBGridController.EditButtonClick(Sender: TObject);
Var
   fmPopup: TdxFormLookup = nil;

Begin
   // Call the inherited event for the EditbuttonClick
   If Assigned(FDBGridEvents.OnEditButtonClick) Then
      FDBGridEvents.OnEditButtonClick(Sender);

   If NOT FIsGridValid Then
      exit;
   Try

      // Create the editor form...
      fmPopup := CreatePopupForm(FGrid.SelectedColumn, ptEditor);

      fmPopup.ShowModal;

      If fmPopup.ModalResult = mrOk Then
      Begin
         If Assigned(fmPopup.FCalendar) Then
         Begin

            If fmPopup.FField.AsDateTime <> fmPopup.FCalendar.DateTime Then
            Begin

               fmPopup.FCalendar.EditingDone;
               If NOT (fmPopup.FField.DataSet.State IN [dsEdit, dsInsert]) Then
                  fmPopup.FField.DataSet.Edit;
               Try
                  fmPopup.FField.DataSet.DisableControls;
                  fmPopup.FField.AsDateTime := fmPopup.FCalendar.DateTime;
               Finally

                  fmPopup.FField.DataSet.EnableControls;
               End;
            End;
         End
         Else
         If Assigned(fmPopup.FLookupDatasource) Then
            If fmPopup.FField.DataSet.FieldByName(fmPopup.FField.KeyFields).Value <> fmPopup.FLookupDataset.FieldByName(
               fmPopup.FField.LookupKeyFields).Value Then
            Begin
               If NOT (fmPopup.FField.DataSet.State IN [dsEdit, dsInsert]) Then
                  fmPopup.FField.DataSet.Edit;
               // Very important ... disable dataset before setting the new value
               Try
                  fmPopup.FLookupDataset.DisableControls;
                  fmPopup.FField.DataSet.DisableControls; // Same as the FGrid.Datasource.Dataset
                  fmPopup.FField.DataSet.FieldByName(fmPopup.FField.KeyFields).Value :=
                     fmPopup.FLookupDataset.FieldByName(fmPopup.FField.LookupKeyFields).Value;
                  fmPopup.FField.Value := fmPopup.FLookupDataset.FieldByName(fmPopup.FField.LookupResultField).Value;
               Finally
                  fmPopup.FField.DataSet.EnableControls;
                  fmPopup.FLookupDataset.EnableControls;
               End;

            End;
      End
      Else
      If fmPopup.ModalResult = mrCancel Then
         // Cancel the assignation if cancel button was pressed
         If fmPopup.FField.DataSet.State IN [dsEdit, dsInsert] Then
         Begin
            fmPopup.FField.DataSet.DisableControls;
            fmPopup.FField.Value := fmPopup.FField.OldValue;
            fmPopup.FField.DataSet.EnableControls;
         End;

      If Assigned(fmPopup.FLookupDataset) Then
      Begin
         fmPopup.FLookupDataset.OnFilterRecord := nil;
         fmPopup.FLookupDataset.Filtered       := False;
      End;

   Finally
      // All owned component by fmPopup will be destroy also
      FreeAndNil(fmPopup);
   End;
End;

Procedure TdxCustomDBGridController.ColumnChooserClick(Sender: TObject);
Var
   fmPopup: TdxFormLookup = nil;
   i:       Integer = 0;
Begin
   If NOT FIsGridValid Then
      exit;
   Try
      // Create the editor form...
      fmPopup := CreatePopupForm(FGrid.SelectedColumn, ptColumnChooser);
      fmPopup.ShowModal;

      If fmPopup.ModalResult = mrOk Then
         For i := 0 To fmPopup.FColumnChooserList.Count - 1 Do
            FGrid.Columns[i].Visible := fmPopup.FColumnChooserList.Checked[i];
   Finally
      // All owned component by fmPopup will be destroy also
      FreeAndNil(fmPopup);
   End;
End;

Procedure TdxCustomDBGridController.GetCellHint(Sender: TObject; Column: TColumn; Var AText: String);
Begin
   // Call the inherited event for the DrawColumnTitle
   If Assigned(FDBGridEvents.OnGetCellHint) Then
      FDBGridEvents.OnGetCellHint(Sender, Column, AText);

   If NOT FIsGridValid Then
      exit;
   // Set the hint text only if the inherited event return an empty string
   If AText = '' Then
      If Assigned(Column) Then
         If Column.FieldName <> '' Then
            If Assigned(Column.Field) Then
               Atext := GetDisplayText(Column.Field);
End;


Procedure TdxCustomDBGridController.ColumnFilterEditorClick(Column: TColumn);
Var
   fmPopup:     TdxFormLookup = nil;
   OldPosition: Integer;
   i, j:        Integer;
   IndexOfItem: Integer = 0;
Begin
   If NOT FIsGridValid Then
      exit;

   Try
      fmPopup := CreatePopupForm(Column, ptColumnFilter);

      // Populate the selection list
      // Transfert the distinct values into the CheckListBox ..
      // CheckListBox did not have Duplicates := dupIgnore so we use a TStringlist
      If CheckListBoxCount(fmPopup.FColumnProperty.FCheckListBox) = 0 Then
      Begin
         fmPopup.FColumnProperty.FCheckListBox.Clear;
         Try
            fmPopup.FDataset.DisableControls;
            OldPosition   := fmPopup.FDataset.RecNo;
            Screen.Cursor := crHourGlass;
            fmPopup.FDataset.First;
            While NOT fmPopup.FDataset.EOF Do
            Begin
               If FGrid.Canvas.TextWidth(fmPopup.FField.DisplayText) > fmPopup.Width Then
                  fmPopup.Width := FGrid.Canvas.TextWidth(fmPopup.FField.DisplayText);
               fmPopup.FDisplayTextList.Add(fmPopup.FField.DisplayText);
               fmPopup.FDataset.Next;
            End;
         Finally
            // Prepare de selection list with the actual data
            Screen.Cursor := crDefault;
            If OldPosition > 0 Then
               If OldPosition <= fmPopup.FDataset.RecordCount Then
                  If NOT fmPopup.FDataset.IsEmpty Then
                     fmPopup.FDataset.RecNo := OldPosition;
            fmPopup.FDataset.EnableControls;
         End;
         fmPopup.FColumnProperty.FCheckListBox.Items.Text := fmPopup.FDisplayTextList.Text;
         fmPopup.FColumnProperty.FCheckListBox.Top        := -1;
      End;
      // Check items with the one contain in the  FilterValueList
      For i := 0 To fmPopup.FColumnProperty.FilterValueList.Count - 1 Do
      Begin
         IndexOfItem := fmPopup.FColumnProperty.FCheckListBox.Items.IndexOf(fmPopup.FColumnProperty.FilterValueList.Strings[i]);
         If IndexOfItem > -1 Then
            fmPopup.FColumnProperty.FCheckListBox.Checked[IndexOfItem] := True;
      End;
      // Disable the select all button if higher than the limit
      fmPopup.FbtnSelectAll.Enabled := (fmPopup.FColumnProperty.FCheckListBox.Count <= FColumnSelectAllLimit);
      fmPopup.FSearchEditor.FilteredListbox := fmPopup.FColumnProperty.FCheckListBox;
      // Do some form width adjustment
      fmPopup.Width := Min(400, fmPopup.Width);
      // Show the selection list
      fmPopup.ShowModal;

      // Apply the Filter with the new values if the ok button was pressed
      If fmPopup.ModalResult = mrOk Then
      Begin
         // Clear the old filter and repopulate with new selected values
         fmPopup.FColumnProperty.FilterValueList.Clear;
         If fmPopup.FColumnProperty.FCheckListBox.Count > 0 Then
            For i := 0 To fmPopup.FColumnProperty.FCheckListBox.Items.Count - 1 Do
               If fmPopup.FColumnProperty.FCheckListBox.Checked[i] Then
                  fmPopup.FColumnProperty.FilterValueList.Add(fmPopup.FColumnProperty.FCheckListBox.Items[i]);

         // Trigger the search with the delayed timer...
         FDelayedFiltering.Enabled := True;
      End;
   Finally
      FreeAndNil(fmPopup);
   End;

End;

Procedure TdxCustomDBGridController.UpdateData(Sender: TObject);
Begin
   If NOT FIsGridValid Then
      exit;
   // Trigger the search and aggreation with the delayed timer...
   // Check if we had some insertion or deletion
   If FNeedRecalculateAggregation Then
      FDelayedRecalculateAggregation.Enabled := True;
End;

Procedure TdxCustomDBGridController.DataChange(Sender: TObject; Field: TField);
Var
   s: TDataSetState;
Begin
   If NOT FIsGridValid Then
      exit;
   // Do not refresh if it is a field notification Field = Nil -> Record notification
   If Field = nil Then
      SetRecordCount;
End;

Procedure TdxCustomDBGridController.Notification(aComponent: TComponent; aOperation: TOperation);
Var
   dw: Integer;
Begin
   Inherited;
   If aComponent IS TDBGrid Then
      If aOperation = opRemove Then
         If aComponent = FGrid Then
         Begin
            FGrid.parent := FOldParent;
            FGrid.Constraints := FOldConstraints;
            FGrid.Anchors := FOldAnchors;
            FIsGridValid := False;
            // Destroy subcomponent ...
            DestroyGridSubComponent;
            FGrid := nil;
         End;
   If Assigned(FGrid) Then
   Begin
      If FNavigator <> nil Then
         FNavigator.Width   := Trunc(FNavigatorDefaultWidth * FNavigator.VisibleButtonCount / 10);
      If PageSelector <> nil Then
         PageSelector.Width := Trunc(FNavigatorDefaultWidth * PageSelector.VisibleButtonCount / 10);
   End;

End;


Procedure TdxCustomDBGridController.ShowMemoCellText(AGrid: TDbGrid; Const ARect: TRect; AColumn: TColumn; FilterText: String; AState: TGridDrawState);
Var
   DisplayText: String;
   TextStyle:   TTextStyle;
Begin
   If Assigned(Acolumn.Field) Then
      If Acolumn.Field.DataType IN [ftMemo, ftFmtMemo, ftWideMemo] Then
      Begin
         DisplayText         := Acolumn.Field.AsString;
         AGrid.Canvas.FillRect(ARect);
         TextStyle           := AGrid.Canvas.TextStyle;
         TextStyle.SingleLine := False;
         TextStyle.Layout    := tlTop;
         TextStyle.Wordbreak := True;
         TextStyle.Opaque    := False;
         AGrid.Canvas.TextStyle := TextStyle;
         AGrid.Canvas.TextRect(ARect, ARect.Left + 3, ARect.Top + 3, DisplayText);
      End;
End;


Procedure TdxCustomDBGridController.HighlightSearchText(AGrid: TDbGrid; Const ARect: TRect; AColumn: TColumn; FilterText: String; AState: TGridDrawState;
   SearchGlobal: Boolean);

Var
   HlRect:   TRect;
   Position: Integer;
   HlText, DisplayText: String;
   offset:   Integer;
Begin
   If Assigned(Acolumn.Field) Then
      If Acolumn.Field.DataType IN [ftInteger, ftDate, ftTime, ftDateTime, ftTimeStamp, ftString, ftFixedChar, ftMemo,
         ftFmtMemo, ftWideString, ftCurrency, ftFloat, ftGuid, ftFixedWideChar, ftWideMemo] Then
      Begin
         DisplayText := GetDisplayText(Acolumn.Field);
         Position    := Pos(AnsiLowerCase(FilterText), AnsiLowerCase(DisplayText));
         If Position > 0 Then
         Begin
            // set highlight area
            Case AColumn.Alignment Of
               taLeftJustify: HlRect.Left :=
                     ARect.Left + AGrid.Canvas.TextWidth(Copy(DisplayText, 1, Position - 1)) + 2;
               taRightJustify:
               Begin
                  Offset      := AGrid.Canvas.TextWidth(Copy(DisplayText, 1, 1)) - 1;
                  HlRect.Left := (ARect.Right - AGrid.Canvas.TextWidth(DisplayText) - offset) + AGrid.Canvas.TextWidth(
                     Copy(DisplayText, 1, Position - 1));
               End;
               taCenter:
               Begin
                  Offset := ((ARect.Right - ARect.Left) DIV 2) - (AGrid.Canvas.TextWidth(DisplayText) DIV 2) + 2;

                  HlRect.Left := (ARect.Right - AGrid.Canvas.TextWidth(DisplayText) - offset) +
                     AGrid.Canvas.TextWidth(Copy(DisplayText, 1, Position - 1));
               End;
            End;

            HlRect.Top    := ARect.Top + 2;
            HlRect.Right  := HlRect.Left + AGrid.Canvas.TextWidth(Copy(DisplayText, Position, Length(FilterText))) + 1;
            HlRect.Bottom := ARect.Bottom - 2;

            //check for  limit of the cell
            If HlRect.Right > ARect.Right Then
               HlRect.Right := ARect.Right;

            If SearchGlobal Then
            Begin
               AGrid.Canvas.Brush.Color := FSearchColor;
               AGrid.Canvas.Font.Color  := FSearchTextColor;
            End
            Else
            Begin
               AGrid.Canvas.Brush.Color := FColumnSearchColor;
               AGrid.Canvas.Font.Color  := FColumnSearchTextColor;
            End;

            AGrid.Canvas.FillRect(HlRect);
            HlText := Copy(DisplayText, Position, Length(FilterText));
            AGrid.Canvas.TextRect(HlRect, HlRect.Left + 1, HlRect.Top + 1, HlText);

         End;
      End;
End;

Procedure TdxCustomDBGridController.HighlightGroup(AGrid: TDbGrid; Const ARect: TRect; AColumn: TColumn; AState: TGridDrawState);
Var
   RowIndex:        Integer;
   CurrentRow:      Integer;
   PriorRow:        Integer;
   AColumnProperty: TdxColumnProperty = nil;

   Function ParseGroupValue(RawGroupValue: String): String;
   Begin
      Result := Copy(RawGroupValue, Pos('#', RawGroupValue) + 1, Length(RawGroupValue));
   End;

Begin
   AColumnProperty := FColumnPropertyList.FindSortedColumn(0);
   If (FRecordCount > 0) AND (AGrid.DataSource.DataSet.State IN [dsBrowse]) Then
      If Assigned(AColumnProperty) Then
         Try
            If NOT (coShowRowLineWhenGrouped IN FControllerOptions) Then
               AGrid.Options := AGrid.Options - [dgRowLines]
            Else
               AGrid.Options := AGrid.Options + [dgRowLines];

            RowIndex := FGroupValue.IndexOf(IntToStr(AGrid.DataSource.DataSet.RecNo) + '#' + AColumnProperty.Field.AsString);
            If (RowIndex > 0) AND (RowIndex < FGroupValue.Count - 1) Then
            Begin
               //If (ParseGroupValue(FGroupValue.Strings[RowIndex - 1]) = ParseGroupValue(FGroupValue.Strings[RowIndex])) AND (AGrid.FixedCols > 1) Then
               //   If AColumnProperty.Field = Acolumn.Field Then
               //      AGrid.Canvas.FillRect(ARect);

               If (ParseGroupValue(FGroupValue.Strings[RowIndex]) <> ParseGroupValue(FGroupValue.Strings[RowIndex + 1])) Then
               Begin

                  AGrid.Canvas.Pen.Width := FGroupLineWidth;
                  AGrid.Canvas.Pen.Color := FGroupLineColor;
                  AGrid.Canvas.Pen.Width := FGroupLineWidth;
                  AGrid.Canvas.Line(0, ARect.Bottom - 1, Arect.Right, Arect.Bottom - 1);
               End;
            End
            Else If (RowIndex = 0) Then
            // First row
            Else
            If (RowIndex = FGroupValue.Count - 1) Then // Last row
            Begin
               AGrid.Canvas.Pen.Width := 1;
               AGrid.Canvas.Pen.Color := AGrid.BorderColor;
               AGrid.Canvas.Line(0, ARect.Bottom - 1, Arect.Right, Arect.Bottom - 1);
            End;
         Except
            // Process the exception
         End;
End;

Procedure TdxCustomDBGridController.SetGlyphColumnFilter(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphColumnFilter = AValue Then
      exit;
   If FGridGlyphColumnFilter = nil Then
      FGridGlyphColumnFilter       := TPortableNetworkGraphic.Create;
   FGridGlyphColumnFilter.OnChange := nil;
   FGridGlyphColumnFilter.Assign(AValue);
End;

Procedure TdxCustomDBGridController.SetGlyphColumnHaveFilter(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphColumnHaveFilter = AValue Then
      exit;
   If FGridGlyphColumnHaveFilter = nil Then
      FGridGlyphColumnHaveFilter       := TPortableNetworkGraphic.Create;
   FGridGlyphColumnHaveFilter.OnChange := nil;
   FGridGlyphColumnHaveFilter.Assign(AValue);
End;

Procedure TdxCustomDBGridController.SetGlyphSelectAll(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphSelectAll = AValue Then
      exit;
   If FGridGlyphSelectAll = nil Then
      FGridGlyphSelectAll       := TPortableNetworkGraphic.Create;
   FGridGlyphSelectAll.OnChange := nil;
   FGridGlyphSelectAll.Assign(AValue);

End;


Procedure TdxCustomDBGridController.SetGroupLineColor(AValue: TColor);
Begin
   If FGroupLineColor = AValue Then
      Exit;
   FGroupLineColor := AValue;
End;

Procedure TdxCustomDBGridController.SetGroupLineWidth(AValue: Integer);
Begin
   If FGroupLineWidth = AValue Then
      Exit;

   If AValue < 0 Then
      AValue := 1;
   If AValue > 10 Then
      AValue := 10;

   FGroupLineWidth := AValue;
End;

Procedure TdxCustomDBGridController.SetGlyphCancelFilter(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphCancelFilter = AValue Then
      exit;
   If FGridGlyphCancelFilter = nil Then
      FGridGlyphCancelFilter       := TPortableNetworkGraphic.Create;
   FGridGlyphCancelFilter.OnChange := nil;
   FGridGlyphCancelFilter.Assign(AValue);
End;

Procedure TdxCustomDBGridController.SetGlyphSortingAsc(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphSortingAsc = AValue Then
      exit;
   If FGridGlyphSortingAsc = nil Then
      FGridGlyphSortingAsc       := TPortableNetworkGraphic.Create;
   FGridGlyphSortingAsc.OnChange := nil;
   FGridGlyphSortingAsc.Assign(AValue);
End;

Procedure TdxCustomDBGridController.SetGlyphSortingDesc(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphSortingDesc = AValue Then
      exit;
   If FGridGlyphSortingDesc = nil Then
      FGridGlyphSortingDesc       := TPortableNetworkGraphic.Create;
   FGridGlyphSortingDesc.OnChange := nil;
   FGridGlyphSortingDesc.Assign(AValue);
End;

Procedure TdxCustomDBGridController.SetGlyphSortUp(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphSortUp = AValue Then
      exit;
   If FGridGlyphSortUp = nil Then
      FGridGlyphSortUp       := TPortableNetworkGraphic.Create;
   FGridGlyphSortUp.OnChange := nil;
   FGridGlyphSortUp.Assign(AValue);
End;

Procedure TdxCustomDBGridController.SetGlyphSortDown(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphSortDown = AValue Then
      exit;
   If FGridGlyphSortDown = nil Then
      FGridGlyphSortDown       := TPortableNetworkGraphic.Create;// TBitmap.Create;  TBitmap.Create;
   FGridGlyphSortDown.OnChange := nil;
   FGridGlyphSortDown.Assign(AValue);
End;

Procedure TdxCustomDBGridController.SetGlyphFind(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphFind = AValue Then
      exit;
   If FGridGlyphFind = nil Then
      FGridGlyphFind       := TPortableNetworkGraphic.Create;// TBitmap.Create;  TBitmap.Create;
   FGridGlyphFind.OnChange := nil;
   FGridGlyphFind.Assign(AValue);
End;

Procedure TdxCustomDBGridController.SetObjectEvents;
Begin
   // Save old even pointer
   FDBGridEvents.OnEditButtonClick := FGrid.OnEditButtonClick;
   FDBGridEvents.OnGetCellHint := FGrid.OnGetCellHint;
   FDBGridEvents.OnDrawColumnTitle := FGrid.OnDrawColumnTitle;
   FDBGridEvents.OnDrawColumnCell := FGrid.OnDrawColumnCell;
   FDBGridEvents.OnMouseMove := FGrid.OnMouseMove;
   FDBGridEvents.OnMouseDown := FGrid.OnMouseDown;
   FDBGridEvents.OnKeyDown := FGrid.OnKeyDown;
   FDBGridEvents.OnTitleClick := FGrid.OnTitleClick;
   // Navigator
   FNavigator.OnClick      := @Navigator1Click;
   // Assign new event  on the assigned grid
   FGrid.OnEditButtonClick := @EditButtonClick;
   FGrid.OnGetCellHint     := @GetCellHint;
   FGrid.OnDrawColumnTitle := @DrawColumnTitle;
   FGrid.OnDrawColumnCell  := @DrawColumnCell;
   FGrid.OnMouseMove       := @MouseMove;
   FGrid.OnMouseDown       := @MouseDown;
   FGrid.OnKeyDown         := @KeyDown;
   FGrid.OnTitleClick      := @TitleClick;
   // Filtebox
   FSearchEditor.onchange  := @FilterEditChange; // onchange  OnEditingDone
   FColumnChooser.OnClick  := @ColumnChooserClick;

   FDelayedFiltering.OnTimer  := @TriggerTimer;
   FDelayedFiltering.Enabled  := False;
   FDelayedFiltering.Interval := FSearchTypingDelay;

   FDelayedGridDraw.OnTimer  := @GridDrawTimer;
   FDelayedGridDraw.Enabled  := False;
   FDelayedGridDraw.Interval := 500;

   FDelayedRecalculateAggregation.OnTimer  := @RecalculateAggregationTimer;
   FDelayedRecalculateAggregation.Enabled  := False;
   FDelayedRecalculateAggregation.Interval := 500;

   // Datasource
   FDatasource.OnDataChange           := @DataChange;
   FDatasource.OnUpdateData           := @UpdateData;
   FDatasource.DataSet.OnFilterRecord := @FilterRecord;
End;

Procedure TdxCustomDBGridController.AddGlobalFilterExpression(Var SearchExpression: String; SQLOpertor: String);
Begin

End;


Procedure TdxCustomDBGridController.KeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState);
Const
   letter = ['0' .. '9', 'a' .. 'z', 'A' .. 'Z'];
Var
   AKeyFilter, AKeySearchBox, AKeyChooser: Word;
   AShiftFilter, AShiftSearchBox, AShiftChooser: TShiftState;
   AColumnProperty: TdxColumnProperty;
Begin
   // Call the inherited event for the KeyDown
   If Assigned(FDBGridEvents.OnKeyDown) Then
      FDBGridEvents.OnKeyDown(Sender, Key, Shift);

   If NOT FIsGridValid Then
      exit;

   // Get the string representation for all shortcut
   ShortCutToKey(Self.FSearchBoxShortCut, AKeySearchBox, AShiftSearchBox);
   ShortCutToKey(Self.FColumnChooserShortCut, AKeyChooser, AShiftChooser);
   ShortCutToKey(Self.FColumnFilterShortCut, AKeyFilter, AShiftFilter);

      // Focus the search box
   If (Key = AKeySearchBox) AND (Shift = AShiftSearchBox) Then
   Begin
      //showMessage( intToStr(Self.FSearchBoxShortCut)) ;
      Self.FSearchEditor.SetFocus;
      Self.FSearchEditor.CaretPos := Point(Self.FSearchEditor.Width - 25, 2);
   End
   Else
   // Popup the column chooser
   If (Key = AKeyChooser) AND (Shift = AShiftChooser) Then
      ColumnChooserClick(Sender)
   Else
   // Popup the column filter
   If (Key = AKeyFilter) AND (Shift = AShiftFilter) Then
   Begin
      AColumnProperty     := self.FColumnPropertyList.ColumnPropertyByName(FGrid.SelectedColumn.FieldName);
      self.FLastHitRegion := AColumnProperty.TitleRect;
      FHitRegion          := hrFilterRegion;
      ColumnFilterEditorClick(FGrid.SelectedColumn);
   End
   Else
   If (Shift = []) AND (FGrid.Options = FGrid.Options + [dgEditing]) Then
      If NOT FGrid.SelectedField.ReadOnly Then
         If FGrid.SelectedField <> nil Then
            // Check if we need to clear the field
            If Key = VK_DELETE Then
            Begin
               If NOT (FGrid.DataSource.DataSet.state IN [dsEdit, dsInsert]) Then
                  FGrid.DataSource.DataSet.edit;
               If NOT FGrid.SelectedField.ReadOnly Then
                  FGrid.SelectedField.Clear;
            End
            Else
            // We have VK_RETURN pressed call the ButtonEdit event
            // and Field is Datetime, Memo of Lookup
            If ((FGrid.SelectedColumn.ButtonStyle = cbsEllipsis) AND ((Char(Key) IN letter) OR (Key = VK_RETURN))) Then
            Begin
               If (Char(Key) IN letter) Then
                  FLookupSearchText := Char(Key)
               Else
                  FLookupSearchText := '';
               Key := 0;
               Self.EditButtonClick(Sender);
            End;
End;


Procedure TdxCustomDBGridController.PrepareAggregation;
Begin
   FRecordCount := 0;
   // Trigger event to set the FNeedAggregation flag to true
   // only for interested columns called in this event
   If Assigned(FOnAggregation) Then
      FOnAggregation(Self AS TdxDBGridController);
End;


Procedure TdxCustomDBGridController.DrawAggregation;
Var
   i: Integer = 0;
Begin
   // To force FooterPanel positionning correctly
   If FBottomPanel.top < 2 Then
      FBottomPanel.top := 10000;

   // Trigger event to get the final aggregation result
   If Assigned(FOnAggregation) Then
      FOnAggregation(Self AS TdxDBGridController);

   If (coDefaultDrawingFooter IN FControllerOptions) AND (coShowFooter IN FControllerOptions) Then
      For i := 0 To Self.FColumnPropertyList.Count - 1 Do
         DrawColumnFooter((FColumnPropertyList.Objects[i] AS TdxColumnProperty));

   // Trigger event to get the final aggregation result for custom draw
   If Assigned(FOnAfterAggregation) Then
      FOnAfterAggregation(Self AS TdxDBGridController);

End;

Procedure TdxCustomDBGridController.RecalculateAggregation;
Var
   OldPosition:     Integer;
   AColumnProperty: TdxColumnProperty = nil;
Begin
   // Save current record position

   FGrid.DataSource.DataSet.DisableControls;
   OldPosition := FGrid.DataSource.DataSet.RecNo;

   // Find first sorted column
   AColumnProperty := FColumnPropertyList.FindSortedColumn(0);
   // Turn the flag off
   FNeedRecalculateAggregation := False;
   // Set Aggregation
   FColumnPropertyList.ResetAggregation;
   PrepareAggregation;
   // Reset group value
   FGroupValue.Clear;
   FGrid.DataSource.DataSet.First;
   While NOT FGrid.DataSource.DataSet.EOF Do
   Begin
      If Assigned(AColumnProperty) Then
         FGroupValue.Add(IntToStr(FGrid.DataSource.DataSet.RecNo) + '#' + AColumnProperty.Field.AsString);
      CalculateAggregationAfterFiltering;
      FGrid.DataSource.DataSet.Next;
   End;
   // Restore record position
   RestoreDatasetPosition(OldPosition);
   FGrid.DataSource.DataSet.EnableControls;
   // Draw the aggregation result
   DrawAggregation;
   //FGrid.Invalidate;
End;

Procedure TdxCustomDBGridController.RestoreDatasetPosition(OldPosition: Integer);
Begin
   // Restore record position
   If NOT FGrid.DataSource.DataSet.IsEmpty Then
   Begin
      FGrid.DataSource.DataSet.First;
      While NOT FGrid.DataSource.DataSet.EOF Do
      Begin
         If FGrid.DataSource.DataSet.RecNo >= OldPosition Then
            break;
         FGrid.DataSource.DataSet.Next;
      End;
   End;
End;

Procedure TdxCustomDBGridController.SetGridDatsetFilter;
Var
   OldPosition:    Integer;
   OldGridOptions: TDBGridOptions;
Begin
   If FIsGridValid Then
   Begin

      // Save current record position
      OldPosition := FGrid.DataSource.DataSet.RecNo;
      FGrid.DataSource.DataSet.DisableControls;

      // Set filter status
      FColumnPropertyList.SetFilterStatus;
      // Adjust grid options to not interfer with the focus control
      OldGridOptions := Fgrid.Options;
      Fgrid.Options  := Fgrid.Options - [dgAlwaysShowEditor];

      Try
         Screen.Cursor := crHourglass;
         // Force to filter all records
         FGrid.DataSource.DataSet.Filtered := False;
         Delay(30);
         FGrid.DataSource.DataSet.Filtered := True;
         RestoreDatasetPosition(OldPosition);
         FGrid.DataSource.dataset.EnableControls;

         RecalculateAggregation;

         // Position the dataset according the selected option
         If (coFirstRowAfterFilter IN FControllerOptions) Then //GotoFirstRecord
            FGrid.DataSource.DataSet.First
         Else If coLastRowAfterFilter IN FControllerOptions Then //GotoLastRecord
            FGrid.DataSource.DataSet.Last;

         // Call the on after filter grid...
         If Assigned(FOnAfterFilterGrid) Then
            FOnAfterFilterGrid(Self);

      Finally
         Fgrid.Options := OldGridOptions;
         Screen.Cursor := crDefault;
      End;

   End;
End;


Procedure TdxCustomDBGridController.FilterEditChange(Sender: TObject);
Var
   i: Integer;
Begin
   // Apply filter on the dataset
   // Activate a timer, the search will be triggered with the delay
   // fixed with the property SearchTypingDelay ( Default 550 ms)
   FDelayedFiltering.Enabled := True;
End;

Procedure TdxCustomDBGridController.FilterMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
Begin
   If NOT FIsGridValid Then
      exit;
   FDelayedGridDraw.Enabled := GridShowNoData;
End;

Procedure TdxCustomDBGridController.DrawColumnCell(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
Var
   AColumnProperty: TdxColumnProperty;
Begin
   If (gdSelected IN State) OR (gdFocused IN State) Then
      FCurrentCellRect := Rect;
   // Call the inherited event for the DrawColumnCell
   If Assigned(FDBGridEvents.OnDrawColumnCell) Then
      FDBGridEvents.OnDrawColumnCell(Sender, Rect, DataCol, Column, State);

   If NOT FIsGridValid Then
      exit;

   If (FGrid.DataSource.DataSet.RecordCount > 0) Then
   Begin
      ShowMemoCellText(Sender AS TDBGrid, Rect, Column, FSearchEditor.Text, State);

      AColumnProperty := Self.FColumnPropertyList.ColumnPropertyByName(Column.FieldName);
      If Assigned(AColumnProperty) Then
         If AColumnProperty.SearchEditor.Text <> '' Then
            HighlightSearchText(Sender AS TDBGrid, Rect, Column, AColumnProperty.SearchEditor.Text, State, False);

      // If we have a global search
      If FSearchEditor.Text <> '' Then
         HighlightSearchText(Sender AS TDBGrid, Rect, Column, FSearchEditor.Text, State, True);

      If coShowGroupLine IN FControllerOptions Then
         HighlightGroup(Sender AS TDBGrid, Rect, Column, State);
   End
   Else
      FDelayedGridDraw.Enabled := GridShowNoData;
End;

Procedure TdxCustomDBGridController.DrawColumnFooter(Sender: TdxColumnProperty);
Var
   ATextStyle: TTextStyle;
   ACol:       Integer = -1;
   APoint:     TPoint;
   ARect:      TRect;
Begin
   If NOT FIsGridValid Then
      exit;

   If (coDefaultDrawingFooter IN FControllerOptions) AND (coShowFooter IN FControllerOptions) Then
   Begin
      APoint     := Point(Sender.TitleRect.Left, Sender.TitleRect.Top);
      // Get the column index on the mouse position
      ACol       := FGrid.MouseToCell(APoint).x - 1;
      // Set the default style
      ATextStyle := FFooterPanel.Canvas.TextStyle;
      ATextStyle.Alignment := Sender.FooterAlignment;
      ATextStyle.Layout := tlTop;
      ATextStyle.Wordbreak := True;
      ATextStyle.SingleLine := False;
      /// Get de default Font for TitleFont
      FFooterPanel.Canvas.Font := FGrid.TitleFont;
      // Repaint only if it is a visible column in the current range
      If Sender.Column.Index = ACol Then
      Begin
         ARect        := Sender.TitleRect;
         ARect.Height := FFooterPanel.Height;
         // Clear all space at the end if last column have an aggregation
         If FGrid.LastColumn = Sender.Column Then
            ARect.Width := 1000;
         FFooterPanel.Canvas.TextStyle := ATextStyle;
         FFooterPanel.Canvas.fillrect(ARect);
         ARect.Width := Sender.TitleRect.Width - FFooterPanel.BorderSpacing.Around * 2;
         // Draw the text
         FFooterPanel.Canvas.TextRect(ARect, ARect.Left + FGRid.BorderSpacing.Around - FFooterPanel.BorderSpacing.Around, gBorderSpace,
            Sender.FooterDisplayText, ATextStyle);
      End;
   End;
End;

Procedure TdxCustomDBGridController.MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
Begin
   // Call the inherited event for the MouseMove
   If Assigned(FDBGridEvents.OnMouseMove) Then
      FDBGridEvents.OnMouseMove(Sender, Shift, X, Y);

   If NOT FIsGridValid Then
      exit;

   ShowFilterBox(x, y);

   FDelayedGridDraw.Enabled := GridShowNoData;
End;


Function TdxCustomDBGridController.GridShowNoData: Boolean;
Var
   ARect:  TRect;
   AText:  String;
   ww, hh: Integer;
Begin
   Try
      Result := FIsGridValid AND (FRecordCount = 0);
      If Result Then
      Begin
         AText         := Self.GetLocalisation(Self, msg_nodata);
         FGrid.Canvas.Font.Size := 12;
         FGrid.Canvas.Font.Color := clGrayText;
         FGrid.Canvas.Font.Quality := fqCleartype;
         FGrid.Canvas.GetTextSize(AText, ww, hh);
         // Calculate the rectangle
         ARect.TopLeft := Point(MAX(0, (FGrid.ClientWidth - ww) DIV 2), MAX(0, (FGrid.Clientheight - hh) DIV 2));
         ARect.BottomRight := Point(ARect.Left + ww, ARect.top + hh);
         // Clear canvas and draw the text
         FGrid.Canvas.Brush.Color := FGrid.Color;
         FGrid.Canvas.Line(1, GetTitleHeight + FGrid.DefaultRowHeight, FGrid.ClientWidth - 1, GetTitleHeight + FGrid.DefaultRowHeight);
         FGrid.Canvas.TextOut(ARect.Left, ARect.Top, AText);
      End
   Except
   End;
End;


Procedure TdxCustomDBGridController.MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
   Region: TdxHitRegion;
Begin
   // Call the inherited event for the MouseDown
   If Assigned(FDBGridEvents.OnMouseDown) Then
      FDBGridEvents.OnMouseDown(Sender, Button, Shift, X, Y);

   If NOT FIsGridValid Then
      exit;

   FGridShiftState := Shift;
   GetHitRegion(x, y, Region);
   FHitRegion      := Region;
End;

Procedure TdxCustomDBGridController.FilterRecord(DataSet: TDataSet; Var Accept: Boolean);
Begin
   Accept := AcceptFilteredRecord;
End;

Procedure TdxCustomDBGridController.ClearSQLOrderBy(FieldName: String);
Var
   i: Integer;
Begin
   For i := 0 To FColumnPropertyList.Count - 1 Do
      If Assigned(FColumnPropertyList.Objects[i]) Then
         // Reset all other column
         If TdxColumnProperty(FColumnPropertyList.Objects[i]).FieldName <> FieldName Then
         Begin
            TdxColumnProperty(FColumnPropertyList.Objects[i]).SortOrder  := soNone;
            TdxColumnProperty(FColumnPropertyList.Objects[i]).SQLOrderBy := '';
         End;
End;

Procedure TdxCustomDBGridController.TitleClick(Column: TColumn);
Var
   ColIndex: Integer = 0;
Begin

   // Call the inherited event for the TitleClick
   If Assigned(FDBGridEvents.OnTitleClick) Then
      FDBGridEvents.OnTitleClick(Column);

   If NOT FIsGridValid Then
      exit;

   // Open filter list box
   If FColumnPropertyList.Find(Column.FieldName, ColIndex) AND (FHitRegion = hrFilterRegion) Then
      ColumnFilterEditorClick(Column)
   Else If FColumnPropertyList.Find(Column.FieldName, ColIndex) AND (FHitRegion = hrFilterOperatorRegion) Then
   Else
      TriggerSorting(Column, False, soNone);
End;


Procedure TdxCustomDBGridController.DrawColumnTitle(Sender: TObject; Const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
Var
   AFilterEditor: TdxColumnSearchEditor;
   AColumnProperty: TdxColumnProperty;
   ControlRect: TRect;
   TitleTextRect: TRect;
   ts: TTextStyle;

Begin
   // Call the inherited event for the DrawColumnTitle
   If Assigned(FDBGridEvents.OnDrawColumnTitle) Then
      FDBGridEvents.OnDrawColumnTitle(Sender, Rect, DataCol, Column, State);

   If NOT FIsGridValid Then
      exit;

   Try
      // Get Column property for filtering and sorting...
      // this function will create the column property if not present
      AColumnProperty        := FColumnPropertyList.GetColumnProperty(Column, Rect);
      AFilterEditor          := AColumnProperty.SearchEditor;
      AFilterEditor.OnChange := @FilterEditChange;
      AFilterEditor.OnMouseMove := @FilterMouseMove;
      AColumnProperty.TitleRect := Rect;

      // Set title row height
      TdxAccessDBGrid(FGrid).RowHeights[0] := GetTitleHeight;

      If (coShowColumnFilter IN FControllerOptions) Then
      Begin
         // Clear the region and repaint
         FGrid.Canvas.fillrect(Rect);

         // Determine zone and the dimension of the search box
         //ControlRect        := Rect;
         ControlRect.Left  := Rect.Left + gGlyphWidth + gBorderSpace;
         ControlRect.Right := Rect.Right - gBorderSpace;
         ControlRect.Top   := Rect.Top + (FGrid.DefaultRowHeight * gTitleNumberOfLine);

         ControlRect.bottom       := Rect.bottom - gBorderSpace;
         // Apply the new dimension on the search box (TEdit)
         AFilterEditor.BoundsRect := ControlRect;
         AFilterEditor.Font.Color := FColumnSearchTextColor;

         // Draw Column Title
         ts           := FGrid.Canvas.TextStyle;
         ts.Layout    := tlTop;
         ts.EndEllipsis := True;
         ts.Wordbreak := (gTitleNumberOfLine > 1);
         ts.SingleLine := (gTitleNumberOfLine = 1);
         FGrid.Canvas.TextStyle := ts;
         TitleTextRect := Rect;
         TitleTextRect.Right := TitleTextRect.Right - (gGlyphWidth * 2);
         FGrid.Canvas.TextRect(TitleTextRect, TitleTextRect.left + gBorderSpace, gBorderSpace, Column.Title.Caption);

         // Show filter value if lost fucus on filter box , Draw the search text if not focused on the search box
         FGrid.Canvas.Font.Style := AFilterEditor.Font.Style + [fsBold];
         FGrid.Canvas.Font.Color := FColumnSearchTextColor;
         FGrid.Canvas.TextOut(ControlRect.Left, ControlRect.Top, AFilterEditor.Text);

         // Draw image Search and Filter operator... the magnifier...
         FGrid.Canvas.Draw(ControlRect.Left - gGlyphWidth, ControlRect.Top, FGridGlyphFind);

         // Show the ColumnFilter button with the appropriate image
         If AColumnProperty.FilterValueList.Count = 0 Then
            FGrid.Canvas.Draw(Rect.right - gGlyphWidth - gBorderSpace, Rect.Top + gBorderSpace, FGridGlyphColumnFilter)
         Else
            FGrid.Canvas.Draw(Rect.right - gGlyphWidth - gBorderSpace, Rect.Top + gborderSpace, FGridGlyphColumnHaveFilter);

      End
      Else
         AFilterEditor.Visible := False;

      // Allways draw sort Arrow up or Down
      Case AColumnProperty.SortOrder Of
         soASC: FGrid.Canvas.Draw(Rect.Right - 35, gBorderSpace, FGridGlyphSortUp);
         soDESC: FGrid.Canvas.Draw(Rect.Right - 35, gBorderSpace, FGridGlyphSortDown);
      End;
      // Draw the IndexSortOrder for sorted column
      If FColumnPropertyList.SortedColumnCount > 1 Then
         If AColumnProperty.IndexSortOrder >= 0 Then
         Begin
            FGrid.Canvas.Font.Style := FGrid.Canvas.Font.Style - [fsBold];
            FGrid.Canvas.Font.Size  := 7;
            FGrid.Canvas.Font.Color := FSortIndexColor;
            If (coShowColumnFilter IN FControllerOptions) Then
               FGrid.Canvas.TextOut(Rect.Right - 30, gBorderSpace * 3, IntToStr(AColumnProperty.IndexSortOrder + 1))
            Else
               FGrid.Canvas.TextOut(Rect.Right - gGlyphWidth - gBorderSpace, gBorderSpace, IntToStr(AColumnProperty.IndexSortOrder + 1));
         End;
      // Draw the column footer if enabled
      DrawColumnFooter(AColumnProperty);
   Finally
      FDelayedGridDraw.Enabled := GridShowNoData;
   End;
End;

Function TdxCustomDBGridController.FixedColsWidth: Integer;
Var
   i: Integer = 0;
   w: Integer = 0;
Begin
   For i := 1 To FGrid.FixedCols - 1 Do
      w   := w + FGrid.Columns[i].Width;
   Result := w;
End;

Procedure TdxCustomDBGridController.ShowFilterBox(x, y: Integer);
Var
   ASearchEditor: TdxColumnSearchEditor = nil;
   i, ss, ee:     Integer;
   ARect:         TRect;
   APoint:        TPoint;
   ACol:          Integer;
   AColumn:       TColumn;
   bInColumn:     Boolean = False;
   bInTitleRow:   Boolean = False;
Begin

   // Get the column index on the mouse position
   APoint := Point(x, y);
   ACol   := FGrid.MouseToCell(APoint).x - 1;

   For i := 0 To FColumnPropertyList.Count - 1 Do
   Begin
      ASearchEditor := TdxColumnProperty(FColumnPropertyList.Objects[i]).SearchEditor;
      ARect         := TdxColumnProperty(FColumnPropertyList.Objects[i]).TitleRect;
      AColumn       := TdxColumnProperty(FColumnPropertyList.Objects[i]).Column;

      // Check if we have a match with the current column index and title area
      bInColumn   := (APoint.x + 5 > ARect.Left) AND (APoint.x - 5 < Arect.Right) AND (ACol = AColumn.Index) AND
         (ARect.Left > 5) AND (coShowColumnFilter IN FControllerOptions) AND (ASearchEditor.Left >= FixedColsWidth);
      bInTitleRow := (APoint.y > ARect.top) AND (APoint.y < Arect.Bottom) AND (coShowColumnFilter IN FControllerOptions);

      FGrid.Options := FGrid.Options - [dgHeaderHotTracking];

      // Show Searchbox only if column is visible
      If NOT ASearchEditor.Visible AND bInColumn AND bInTitleRow Then
      Begin
         ASearchEditor.Visible := True;
         ASearchEditor.SetFocus;
      End
      Else If ASearchEditor.Visible AND bInTitleRow AND NOT bInColumn Then
         ASearchEditor.Visible := False;
   End;
End;

Procedure TdxCustomDBGridController.GetHitRegion(x, y: Integer; Var Region: TdxHitRegion);
Var
   i:       Integer;
   ARect:   TRect;
   ARegion: TRect;
   APoint:  TPoint;
Begin
   Region := hrNone;

   APoint.x := x;
   APoint.y := y;
   For i := 0 To FColumnPropertyList.Count - 1 Do
   Begin

      AREct   := TdxColumnProperty(FColumnPropertyList.Objects[i]).TitleRect;
      ARegion := ARect;

      //----------------------------------------
      // Listbox selection for value selection
      ARegion.Left   := Max(20, ARect.Right - 20);
      ARegion.Top    := ARect.Top;
      ARegion.Bottom := ARegion.Top + DBGrid.DefaultRowHeight;
      If PtInRect(ARegion, APoint) Then
      Begin
         FLastHitRegion := AREct;
         Region         := hrFilterRegion;
      End;

      //----------------------------------------
      // Sorting Region
      ARegion.Left   := ARect.Left;
      ARegion.Right  := MAX(0, ARect.Right - 20);
      ARegion.Top    := ARect.Top;
      ARegion.Bottom := ARegion.Top + DBGrid.DefaultRowHeight;
      If PtInRect(ARegion, APoint) Then
      Begin
         FLastHitRegion := AREct;
         Region         := hrSortRegion;
      End;

      //----------------------------------------
      // Filter operator Region,
      ARegion.Left   := ARect.Left;
      ARegion.Top    := ARect.Top + DBGrid.DefaultRowHeight;
      ARegion.Height := DBGrid.DefaultRowHeight;
      ARegion.Right  := ARegion.Left + 20;
      If PtInRect(ARegion, APoint) Then
      Begin
         FLastHitRegion := AREct;
         Region         := hrFilterOperatorRegion;
      End;
   End;
End;


Procedure TdxCustomDBGridController.TriggerSorting(AColumn: TColumn; ForceOrder: Boolean; SortOption: TdxSortOption);
Var
   AField:          TField;
   AColumnProperty: TdxColumnProperty;
   AllowSorting:    Boolean = True;
   ColIndex:        Integer = 0;
Begin
   //Before sorting check if we are allow to sort
   If Assigned(FOnBeforeSortColumn) Then
      FOnBeforeSortColumn(Self, AColumn, AllowSorting);
   // Sortint  operation
   If AllowSorting AND FColumnPropertyList.Find(AColumn.FieldName, ColIndex) AND ((FHitRegion = hrSortRegion) OR ForceOrder) Then
   Begin
      AField := FGrid.DataSource.DataSet.FieldByName(AColumn.FieldName);
      If AField <> nil Then
         If AField.DataType IN [ftString, ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate,
            ftTime, ftDateTime, ftBytes, ftAutoInc, ftFixedChar, ftWideString, ftLargeint, ftGuid, ftTimeStamp, ftFMTBcd, ftFixedWideChar] Then
         Begin
            // Get the colum property
            AColumnProperty := TdxColumnProperty(FColumnPropertyList.Objects[ColIndex]);
            // Override current value if we force the order by
            If ForceOrder Then
            Begin
               FGridShiftState := [ssCtrl, ssLeft];
               Case SortOption Of
                  soNone: AColumnProperty.SortOrder := soNone;
                  soAsc: AColumnProperty.SortOrder := soDesc;
                  soDesc: AColumnProperty.SortOrder := soAsc;
               End;
            End;
            Case AColumnProperty.SortOrder Of
               soNone: AColumnProperty.SortOrder := soAsc;
               soAsc: AColumnProperty.SortOrder  := soDesc;
               soDesc: AColumnProperty.SortOrder := soAsc;
            End;
            FColumnPropertyList.AddSortedColumn(AColumnProperty, (FGridShiftState <> [ssCtrl, ssLeft]));
            SortColumn(AColumn);
         End;
   End;
End;

Procedure TdxCustomDBGridController.SortColumn(AColumn: TColumn);
Var
   nIndex:     Integer;
   BufDataset: TBufDataset;
   SQLQuery:   TSQLQuery;
Begin
   If NOT FIsGridValid Then
      exit;

   If FUseDatasetSorting Then
      If (FGrid.DataSource.DataSet.ClassNameIs('TMSQuery') OR FGrid.DataSource.DataSet.ClassNameIs('TMSTable')) Then
      Begin
         // Default behavior using the IndexFieldNames property
         If IsPropertyPresent(FGrid.DataSource.DataSet, 'IndexFieldNames') Then
            SetStrProp(FGrid.DataSource.DataSet, 'IndexFieldNames', FColumnPropertyList.SQLOrderBy);
      End
      Else
         // If using the TZQuery, TZTable components, apply SortedFields in SortedFields property
      If (FGrid.DataSource.DataSet.ClassNameIs('TZQuery') OR FGrid.DataSource.DataSet.ClassNameIs('TZTable')) Then
      Begin
         // Default behavior using the SortedFields property
         If IsPropertyPresent(FGrid.DataSource.DataSet, 'SortedFields') Then
            SetStrProp(FGrid.DataSource.DataSet, 'SortedFields', FColumnPropertyList.SQLOrderBy);
      End
      Else
      If (FGrid.DataSource.DataSet.ClassNameIs('TSQLQuery') AND IsPropertyPresent(FGrid.DataSource.DataSet, 'IndexDefs') AND
         IsPropertyPresent(FGrid.DataSource.DataSet, 'IndexName')) Then
      Begin
         SQLQuery := FGrid.DataSource.DataSet AS TSQLQuery;
         SQLQuery.IndexDefs.Updated := False; {This line is critical as IndexDefs.Update will do nothing on the next sort if it's already true}
         SQLQuery.IndexDefs.Update;
         If SQLQuery.IndexDefs.Count < SQLQuery.MaxIndexesCount - 1 Then
         Begin
            If FColumnPropertyList.IndexName <> '' Then
            Begin
               nIndex := SQLQuery.IndexDefs.IndexOf(FColumnPropertyList.IndexName);
               If nIndex = -1 Then
                  SQLQuery.AddIndex(FColumnPropertyList.IndexName, FColumnPropertyList.IndexFieldNames, [], FColumnPropertyList.DescFieldNames);
               SQLQuery.IndexName := FColumnPropertyList.IndexName;
            End;
         End
         Else
            ShowMessage('You reach your maximum indexes limit. You need to close the dataset and execute the ClearIndexes procedure or increase the limit of the MaxIndexesCount property.');
      End
      Else
      If (FGrid.DataSource.DataSet.ClassNameIs('TBufDataset') AND IsPropertyPresent(FGrid.DataSource.DataSet, 'IndexDefs') AND
         IsPropertyPresent(FGrid.DataSource.DataSet, 'IndexName')) Then
      Begin
         BufDataset := FGrid.DataSource.DataSet AS TBufDataset;
         BufDataset.IndexDefs.Updated := False; {This line is critical as IndexDefs.Update will do nothing on the next sort if it's already true}
         BufDataset.IndexDefs.Update;
         If BufDataset.IndexDefs.Count < BufDataset.MaxIndexesCount - 1 Then
         Begin
            If FColumnPropertyList.IndexName <> '' Then
            Begin
               nIndex := BufDataset.IndexDefs.IndexOf(FColumnPropertyList.IndexName);
               If nIndex = -1 Then
                  BufDataset.AddIndex(FColumnPropertyList.IndexName, FColumnPropertyList.IndexFieldNames, [], FColumnPropertyList.DescFieldNames);
               BufDataset.IndexName := FColumnPropertyList.IndexName;
            End;
         End
         Else
            ShowMessage('You reach your maximum indexes limit. You need to close the dataset and execute the ClearIndexes procedure or increase the limit of the MaxIndexesCount property.');
      End
      Else
      // Default behavior using the IndexFieldNames property
      If IsPropertyPresent(FGrid.DataSource.DataSet, 'IndexFieldNames') Then
         If Assigned(AColumn) Then
         Begin
            // Assuming IndexFieldNames do not support Asc and Desc modifier... set sorting icon asc by default
            FColumnPropertyList.ColumnPropertyByName(AColumn.FieldName).SortOrder := soAsc;
            SetStrProp(FGrid.DataSource.DataSet, 'IndexFieldNames', FColumnPropertyList.IndexFieldNames);
         End;

   // Call on sort event if assigned ... more flexibility to do SQL order if needed
   If Assigned(FOnSortColumn) Then
      If FColumnPropertyList.IndexName <> '' Then
         Self.FOnSortColumn(Self, AColumn, FColumnPropertyList.IndexFieldNames, FColumnPropertyList.AscFieldNames,
            FColumnPropertyList.DescFieldNames, FColumnPropertyList.IndexName, FColumnPropertyList.SQLOrderBy);

   RecalculateAggregation;

   // Position the dataset according the selected option
   If coFirstRowAfterSort IN FControllerOptions Then     //GotoFirstRecord
      FGrid.DataSource.DataSet.First
   Else If coLastRowAfterSort IN FControllerOptions Then //GotoLastRecord
      FGrid.DataSource.DataSet.Last;

   // Execute the event after sorting if assigned
   If Assigned(FOnAfterSortColumn) Then
      FOnAfterSortColumn(Self, AColumn, FColumnPropertyList.IndexFieldNames, FColumnPropertyList.AscFieldNames,
         FColumnPropertyList.DescFieldNames, FColumnPropertyList.IndexName, FColumnPropertyList.SQLOrderBy);

End;


Procedure TdxCustomDBGridController.CalculateAggregationAfterFiltering;
Var
   i:       Integer;
   AColumnProperty: TdxColumnProperty = nil;
   sStringToHash: String = '';
   RowHash: String;
Begin

   // Increment the global number of record found
   Inc(FRecordCount);
   // Do the aggregation for each column
   For i := 0 To FColumnPropertyList.Count - 1 Do
   Begin

      AColumnProperty := FColumnPropertyList.Objects[i] AS TdxColumnProperty;
      sStringToHash   := sStringToHash + AColumnProperty.Field.AsString;
      // Check if we need to calculate aggregation for this column
      // FNeedAggregation flag for  performance issue, it is set with PrepareAggregation procedure
      If AColumnProperty.FNeedAggregation Then
      Begin
         // Set the count
         Inc(AColumnProperty.Aggregation.Count);
         AColumnProperty.Aggregation.CountStr    := IntToStr(AColumnProperty.Aggregation.Count);
         // Set the Distinct Count
         AColumnProperty.DistinctValueList.Add(AColumnProperty.Field.AsString);
         AColumnProperty.Aggregation.Distinct    := AColumnProperty.DistinctValueList.Count;
         AColumnProperty.Aggregation.DistinctStr := IntToStr(AColumnProperty.DistinctValueList.Count);

         // if we are a the first record set the starting value for all aggregation
         If FRecordCount = 1 Then
         Begin
            AColumnProperty.Aggregation.MinStr := AColumnProperty.Field.AsWideString;
            AColumnProperty.Aggregation.MaxStr := AColumnProperty.Field.AsWideString;
            If AColumnProperty.Field.DataType IN [ftSmallInt, ftInteger, ftWord, ftLargeint] Then
            Begin
               AColumnProperty.Aggregation.MaxInt := AColumnProperty.Field.AsLargeInt;
               AColumnProperty.Aggregation.MinInt := AColumnProperty.Field.AsLargeInt;
               AColumnProperty.Aggregation.SumInt := 0;
               AColumnProperty.Aggregation.AvgInt := 0;
            End;
            If AColumnProperty.Field.DataType IN [ftFloat, ftCurrency, ftBCD] Then
            Begin
               AColumnProperty.Aggregation.MaxFloat := AColumnProperty.Field.AsFloat;
               AColumnProperty.Aggregation.MinFloat := AColumnProperty.Field.AsFloat;
               AColumnProperty.Aggregation.SumFloat := 0.0;
               AColumnProperty.Aggregation.AvgFloat := 0.0;
            End;
            If AColumnProperty.Field.DataType IN [ftDate, ftTime, ftDateTime] Then
            Begin
               AColumnProperty.Aggregation.MinDatetime := AColumnProperty.Field.AsDateTime;
               AColumnProperty.Aggregation.MaxDatetime := AColumnProperty.Field.AsDateTime;
            End;
         End;
         // Do the evaluation
         If AColumnProperty.Field.DataType IN [ftString, ftWideString, ftGuid] Then
         Begin
            If UTF8CompareText(AColumnProperty.Aggregation.MaxStr, AColumnProperty.Field.AsWideString) < 0 Then
               AColumnProperty.Aggregation.MaxStr := AColumnProperty.Field.AsWideString;
            If UTF8CompareText(AColumnProperty.Aggregation.MinStr, AColumnProperty.Field.AsWideString) > 0 Then
               AColumnProperty.Aggregation.MinStr := AColumnProperty.Field.AsWideString;
         End
         Else
         If AColumnProperty.Field.DataType IN [ftBoolean] Then
         Begin
            If AColumnProperty.Field.AsBoolean Then
               AColumnProperty.Aggregation.MaxInt := AColumnProperty.Aggregation.MaxInt + 1
            Else
               AColumnProperty.Aggregation.MinInt := AColumnProperty.Aggregation.MinInt + 1;
            AColumnProperty.Aggregation.SumInt := AColumnProperty.Aggregation.MinInt + AColumnProperty.Aggregation.MaxInt;
            AColumnProperty.Aggregation.MinStr := IntToStr(AColumnProperty.Aggregation.MinInt);
            AColumnProperty.Aggregation.MaxStr := IntToStr(AColumnProperty.Aggregation.MaxInt);
         End
         Else
         If AColumnProperty.Field.DataType IN [ftSmallInt, ftInteger, ftWord, ftLargeint] Then
         Begin
            AColumnProperty.Aggregation.MaxInt := Max(AColumnProperty.Aggregation.MaxInt, AColumnProperty.Field.AsLargeInt);
            AColumnProperty.Aggregation.MaxStr := IntToStr(AColumnProperty.Aggregation.MaxInt);
            AColumnProperty.Aggregation.MinInt := Min(AColumnProperty.Aggregation.MinInt, AColumnProperty.Field.AsLargeInt);
            AColumnProperty.Aggregation.MinStr := IntToStr(AColumnProperty.Aggregation.MinInt);
            AColumnProperty.Aggregation.SumInt := AColumnProperty.Aggregation.SumInt + AColumnProperty.Field.AsLargeInt;
            AColumnProperty.Aggregation.SumStr := IntToStr(AColumnProperty.Aggregation.SumInt);
            If ABS(AColumnProperty.Aggregation.Count) > 0 Then
            Begin
               AColumnProperty.Aggregation.AvgInt := Trunc(AColumnProperty.Aggregation.SumInt / AColumnProperty.Aggregation.Count);
               AColumnProperty.Aggregation.AvgStr := IntToStr(AColumnProperty.Aggregation.AvgInt);
            End;
         End
         Else
         If AColumnProperty.Field.DataType IN [ftFloat, ftCurrency, ftBCD] Then
         Begin
            AColumnProperty.Aggregation.MaxFloat := Max(AColumnProperty.Aggregation.MaxFloat, AColumnProperty.Field.AsFloat);
            AColumnProperty.Aggregation.MaxStr   := FloatToStr(AColumnProperty.Aggregation.MaxFloat);
            AColumnProperty.Aggregation.MinFloat := Min(AColumnProperty.Aggregation.MinFloat, AColumnProperty.Field.AsFloat);
            AColumnProperty.Aggregation.MinStr   := FloatToStr(AColumnProperty.Aggregation.MinFloat);
            AColumnProperty.Aggregation.SumFloat := AColumnProperty.Aggregation.SumFloat + AColumnProperty.Field.AsFloat;
            AColumnProperty.Aggregation.SumStr   := FloatToStr(AColumnProperty.Aggregation.SumFloat);
            If ABS(AColumnProperty.Aggregation.Count) > 0 Then
            Begin
               AColumnProperty.Aggregation.AvgFloat := AColumnProperty.Aggregation.SumFloat / AColumnProperty.Aggregation.Count;
               AColumnProperty.Aggregation.AvgStr   := FloatToStr(AColumnProperty.Aggregation.AvgFloat);
            End;
         End
         Else
         If AColumnProperty.Field.DataType IN [ftDate, ftTime, ftDateTime] Then
         Begin
            If AColumnProperty.Aggregation.MaxDatetime < AColumnProperty.Field.AsDateTime Then
            Begin
               AColumnProperty.Aggregation.MaxDatetime := AColumnProperty.Field.AsDateTime;
               AColumnProperty.Aggregation.MaxStr      := AColumnProperty.Field.AsString;
            End;
            If AColumnProperty.Aggregation.MinDatetime > AColumnProperty.Field.AsDateTime Then
            Begin
               AColumnProperty.Aggregation.MinDatetime := AColumnProperty.Field.AsDateTime;
               AColumnProperty.Aggregation.MinStr      := AColumnProperty.Field.AsString;
            End;
         End;
      End;
   End;
   RowHash := MD5Print(MD5String(sStringToHash));
End;

Function TdxCustomDBGridController.AcceptFilteredRecord(AllRecords: Boolean): Boolean;
Var
   i:          Integer;
   MatchCount: Integer = 0;
   p1, p2, p3: Integer;

   bColumnFound: Boolean = False;
   bGlobalFound: Boolean = False;

   sSearhText: String = '';
   sDisplayText: String = '';

   ADataset:   TDataset = nil;
   AColumnProperty: TdxColumnProperty = nil;

Begin

   If NOT FIsGridValid Then
      exit;

   ADataset     := Self.FDatasource.DataSet;
   // Loop on each ColumProperty if we have a filter
   MatchCount   := 0;
   // Presume that all columns match the search expression
   bColumnFound := True;
   If FColumnPropertyList.FHaveColumnSearch OR FColumnPropertyList.FHaveColumnFilter Then
   Begin
         // We need to find all column with the match if it is filtered
      For i := 0 To FColumnPropertyList.Count - 1 Do
      Begin
         // Get the column information about the filter
         AColumnProperty := FColumnPropertyList.Objects[i] AS TdxColumnProperty;
         sSearhText      := UpperCase(AColumnProperty.SearchEditor.Text);

         sDisplayText := GetDisplayText(AColumnProperty.Field);

         // Is the column filtered
         If (sSearhText <> '') OR (AColumnProperty.FilterSearchText <> '') Then
         Begin
            p1 := pos(sSearhText, Uppercase(sDisplayText));
            p2 := pos('[' + sDisplayText + ']', AColumnProperty.FilterSearchText);
            p3 := pos(sSearhText, Uppercase(AColumnProperty.FilterSearchText));
            If (p1 > 0) AND (p2 > 0) AND (p3 > 0) Then
               MatchCount := MatchCount + 1
            Else If (p1 > 0) AND (AColumnProperty.FilterSearchText = '') Then
               MatchCount := MatchCount + 1
            Else If (p2 > 0) AND (sSearhText = '') Then
               MatchCount := MatchCount + 1;
         End
         Else
            // The column is not filtered... so we accept this column
            MatchCount := MatchCount + 1;
      End;
            // All column are matched if the count equal the number of column
      bColumnFound := (MatchCount = FColumnPropertyList.Count);
   End;

   // Global search
   MatchCount   := 0;
   // Presume that all columns match the search expression
   bGlobalFound := True;
   If FColumnPropertyList.FHaveGlobalSearch Then
   Begin
      sSearhText := FSearchEditor.Text;
      sSearhText := Uppercase(sSearhText);
      // We need to find at least one column with the match
      For i := 0 To ADataset.FieldCount - 1 Do
         If ADataset.Fields[i].Visible Then
         Begin
            sDisplayText := GetDisplayText(ADataset.Fields[i]);
            If pos(sSearhText, Uppercase(sDisplayText)) > 0 Then
            Begin
               MatchCount := MatchCount + 1;
               break;
            End;
         End;
      bGlobalFound := (MatchCount > 0);
   End;
   // Check if we need to recalculate the aggragation for each column on filtering
   If bGlobalFound AND bColumnFound Then
      FNeedRecalculateAggregation := True;

   // Final result yeah!
   Result := bGlobalFound AND bColumnFound;
End;

// Save the configuration JSON Object into a file
Procedure TdxCustomDBGridController.SaveConfiguration;
Var
   JSON:        TJsonNode;
   sFileName:   String = '';
   sFolderName: String = '';
Begin
   If NOT FIsGridValid Then
      exit;
   Try
      // Before saving read all configuration
      GetConfiguration;
      // Create the destination folder
      CreateDir(GetAppConfigDir(False));
      sFolderName := GetAppConfigDir(False) + '\';
      sFileName   := sFolderName + self.Name + '.json';
      // Save to file
      JSON        := TJsonNode.Create;
      JSON.Parse(FConfiguration);
      JSON.SaveToFile(sFileName);
   Finally
      JSON.Free;
   End;
End;


Function TdxCustomDBGridController.ColumnByFieldName(Const AFieldName: String): TColumn;
Var
   i: Integer;
Begin
   Result := nil;
   If NOT FIsGridValid Then
      exit;
   For i := 0 To FGrid.Columns.Count - 1 Do
      If (FGrid.Columns[i].Field <> nil) AND (CompareText(FGrid.Columns[i].FieldName, AFieldName) = 0) Then
      Begin
         Result := FGrid.Columns[i];
         exit;
      End;
End;

// Get configuration from the dxDBGridController object and create a JSON object
Function TdxCustomDBGridController.GetConfiguration: String;
Var
   JSON:     TJsonNode;
   P:        TJsonNode;
   V:        TJsonNode;
   ColIndex: Integer = -1;
   i:        Integer = 0;
   AColumnProperty: TdxColumnProperty = nil;
Begin
   Result := '';
   If NOT FIsGridValid Then
      exit;
   Try
      JSON := TJsonNode.Create;
      // Save global settings
      P    := JSON.Force('GlobalSettings').Add;
      P.Add('ApplicationName', Application.Title);
      P.Add('Date', DateTimeToStr(Now));
      P.Add('SearchExpression', SearchEditor.Text);
      // Save column configuration
      For ColIndex := 0 To Self.FColumnPropertyList.Count - 1 Do
      Begin
         AColumnProperty := Self.FColumnPropertyList.Objects[ColIndex] AS TdxColumnProperty;

         P := JSON.Force('ColumnProperty').Add;
         P.Add('FieldName', AColumnProperty.FieldName);
         P.Add('Index', AColumnProperty.Column.Index);
         P.Add('SortOrder', Integer(AColumnProperty.SortOrder));
         P.Add('IndexSortOrder', Integer(AColumnProperty.IndexSortOrder));
         P.Add('SQLOrderBy', AColumnProperty.SQLOrderBy);
         P.Add('TitleCaption', AColumnProperty.Column.Title.Caption);
         P.Add('SearchValue', AColumnProperty.SearchEditor.Text);
         If AColumnProperty.FilterValueList.Count > 0 Then
            For i := 0 To AColumnProperty.FilterValueList.Count - 1 Do
            Begin
               V := P.Force('FilterValue').Add;
               V.Add('C' + IntToStr(i), AColumnProperty.FilterValueList.Strings[i]);
            End;
         P.Add('Visible', AColumnProperty.Column.Visible);
         P.Add('Left', AColumnProperty.SearchEditor.Left);
         P.Add('Width', AColumnProperty.Column.Width);
      End;
      FConfiguration := JSON.AsJson;
      Result         := FConfiguration;
   Finally
      JSON.Free;
   End;
End;

Procedure TdxCustomDBGridController.Refresh;
Begin
   // No need to delayed  ie :FDelayedFiltering.Enabled := True;
   SetGridDatsetFilter;
End;

Procedure TdxCustomDBGridController.ClearSort;
Begin
   If NOT FIsGridValid Then
      exit;
   FColumnPropertyList.ClearColumnSorting;
   // Clear IndexFieldNames property if exist
   If IsPropertyPresent(FGrid.DataSource.DataSet, 'IndexFieldNames') Then
      SetStrProp(FGrid.DataSource.DataSet, 'IndexFieldNames', FColumnPropertyList.SQLOrderBy);
   // Clear IndexName property if exist
   If IsPropertyPresent(FGrid.DataSource.DataSet, 'IndexName') Then
      SetStrProp(FGrid.DataSource.DataSet, 'IndexName', '');
End;

Procedure TdxCustomDBGridController.ClearAllFilters;
Begin
   If NOT FIsGridValid Then
      exit;
   FColumnPropertyList.ClearAllFilters;
   FSearchEditor.Text := '';
   RecalculateAggregation;
End;


Procedure TdxCustomDBGridController.SortColumnByFieldName(FieldName: String; SortOption: TdxSortOption);
Var
   AColumnProperty: TdxColumnProperty;
Begin
   If NOT FIsGridValid Then
      exit;
   AColumnProperty := FColumnPropertyList.ColumnPropertyByName(FieldName);
   If AColumnProperty <> nil Then
      If Assigned(AColumnProperty.Column) Then
         AColumnProperty.FOwner.FOwner.TriggerSorting(AColumnProperty.Column, True, SortOption);

End;

Procedure TdxCustomDBGridController.ResetLocalization;
Begin

   If NOT FIsGridValid Then
      exit;

   FColumnChooser.Hint    := GetLocalisation(FSearchEditor, msg_columnchooser);
   FSearchEditor.TextHint := GetLocalisation(FSearchEditor, msg_search);
   FNavigator.Hints.Clear;
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_first));
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_prior));
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_next));
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_last));
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_add));
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_delete));
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_edit));
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_save));
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_cancel));
   FNavigator.Hints.Append(GetLocalisation(FNavigator, msg_refresh));
   FPageSelector.Hints.Clear;
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_first));
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_prior));
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_next));
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_last));
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_add));
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_delete));
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_edit));
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_save));
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_cancel));
   FPageSelector.Hints.Append(GetLocalisation(FNavigator, msg_refresh));

End;

// Read configuration from a JSON file and initialize the dxDBGridController object
Procedure TdxCustomDBGridController.LoadConfiguration;
Var
   JSON:        TJsonNode;
   C:           TJsonNode;
   F:           TJsonNode;
   V:           TJsonNode;
   i:           Integer;
   sFileName:   String = '';
   sFolderName: String = '';
   sFieldName:  String = '';
   sName:       String = '';
   sValue:      String = '';
   AColumnProperty: TdxColumnProperty = nil;
   AColumn:     TColumn = nil;
   ARect:       TRect;

Begin
   If NOT FIsGridValid Then
      exit;
   Try
      Try
         sFolderName := GetAppConfigDir(False) + '\';
         sFileName   := sFolderName + self.Name + '.json';
         JSON        := TJsonNode.Create;
         If FileExists(sFileName) Then
         Begin
            JSON.LoadFromFile(sFileName);

            // Apply global settings
            For C IN JSON.Find('GlobalSettings').AsArray Do
               SearchEditor.Text := c.Find('SearchExpression').AsString;
            // Apply column settings
            For C IN JSON.Find('ColumnProperty').AsArray Do
            Begin
               sFieldName := c.Find('FieldName').AsString;
               AColumn    := Self.GetColumnByFieldName(sFieldName);
               If FIsGridValid AND Assigned(AColumn) Then
               Begin
                  ARect.Left      := -1000;
                  Arect.Right     := -900;
                  Arect.Height    := 15;
                  AColumnProperty := FColumnPropertyList.GetColumnProperty(AColumn, ARect);
                  AColumnProperty.SearchEditor.OnChange := @FilterEditChange;
                  AColumnProperty.Column.Title.Caption := c.Find('TitleCaption').AsString;
                  AColumnProperty.Column.Visible := c.Find('Visible').AsBoolean;
                  AColumnProperty.Column.Width := Trunc(c.Find('Width').AsNumber);
                  AColumnProperty.Column.Index := Min(Trunc(c.Find('Index').AsNumber), FGrid.Columns.Count - 1);
                  AColumnProperty.SortOrder := TdxSortOption(Trunc(c.Find('SortOrder').AsNumber));
                  AColumnProperty.IndexSortOrder := Trunc(c.Find('IndexSortOrder').AsNumber);
                  AColumnProperty.SQLOrderBy := c.Find('SQLOrderBy').AsString;
                  AColumnProperty.SearchEditor.Text := c.Find('SearchValue').AsString;
                  If C.Exists('FilterValue') Then
                  Begin
                     i := 0;
                     For V IN C.find('FilterValue').AsArray Do
                     Begin
                        sName  := 'C' + IntToStr(i);
                        sValue := V.Find(sName).AsString;
                        If sValue <> '' Then
                           AColumnProperty.FilterValueList.Add(sValue);
                        Inc(i);
                     End;
                  End;
               End;
            End;
            FConfiguration := JSON.AsJson;

            // Force the dataset filtering
            SetGridDatsetFilter;

            // Apply the sorting order
            FColumnPropertyList.RebuildSQLOrderBy;
            SortColumn(nil);

         End;
      Except
         // Process the exception
      End;
   Finally
      JSON.Free;
   End;
End;


Function TdxCustomDBGridController.GetColumnByFieldName(FieldName: String): TColumn;
Var
   i: Integer;
Begin
   Result := nil;
   For i  := 0 To FGrid.Columns.Count - 1 Do
      If UPPERCASE(FGrid.Columns.Items[i].FieldName) = UPPERCASE(FieldName) Then
         Result := FGrid.Columns.Items[i];
End;

Function TdxCustomDBGridController.GetColumnByFilterBox(Control: TdxColumnSearchEditor): TColumn;
Var
   i: Integer;
Begin
   Result := nil;
   For i  := 0 To FColumnPropertyList.Count - 1 Do
      If TdxColumnSearchEditor(FColumnPropertyList.Objects[i]) = Control Then
         Result := GetColumnByFieldName(FColumnPropertyList[i]);
End;


Function TdxCustomDBGridController.GetTitleHeight: Integer;
Begin
   If (coShowColumnFilter IN FControllerOptions) Then
      Result := FGrid.DefaultRowHeight * (gTitleNumberOfLine + 1)
   Else
      Result := FGrid.DefaultRowHeight;
End;

Function TdxCustomDBGridController.GetDisplayText(Field: TField): String;
Begin
   // Get the displayed text
   If Field.DataType IN [ftMemo, ftFmtMemo, ftWideMemo] Then
      Result := Field.AsString
   Else
      Result := Field.DisplayText;
End;


Function TdxCustomDBGridController.GetGlyphSortingAsc: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphSortingAsc;
End;

Function TdxCustomDBGridController.GetGlyphSortingDesc: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphSortingDesc;
End;


Function TdxCustomDBGridController.GetGlyphColumnFilter: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphColumnFilter;
End;

Function TdxCustomDBGridController.GetGlyphColumnHaveFilter: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphColumnHaveFilter;
End;

Function TdxCustomDBGridController.GetGlyphSelectAll: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphSelectAll;
End;

Function TdxCustomDBGridController.GetGlyphCancelFilter: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphCancelFilter;
End;

Function TdxCustomDBGridController.GetGlyphSortUp: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphSortUp;
End;

Function TdxCustomDBGridController.GetGlyphSortDown: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphSortDown;
End;

Function TdxCustomDBGridController.GetGlyphFind: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphFind;
End;

Function TdxCustomDBGridController.GetGlyphColumnChooser: TPortableNetworkGraphic;
Begin
   Result := FGridGlyphColumnChooser;
End;

Function TdxCustomDBGridController.GetSearchTypingDelay: Integer;
Begin
   Result := FSearchTypingDelay;
End;

Function TdxCustomDBGridController.GetLocalisation(Component: TComponent; ID_Ressource: String): String;
Var
   ATranslation: String;
Begin
   ATranslation := ID_Ressource;
   If Assigned(FOnLocalize) Then
      FOnLocalize(Self, Component, ID_Ressource, ATranslation);
   Result := ATranslation;
End;

Function TdxCustomDBGridController.IsPropertyPresent(anInstance: TObject; aPropName: String): Boolean;
Begin
   Result := Assigned(GetPropInfo(anInstance, aPropName));
End;

Procedure TdxCustomDBGridController.SetColumnSearchColor(AValue: TColor);
Begin
   If FColumnSearchColor = AValue Then
      Exit;
   FColumnSearchColor := AValue;
End;

Procedure TdxCustomDBGridController.SetColumnSearchTextColor(AValue: TColor);
Begin
   If FColumnSearchTextColor = AValue Then
      Exit;
   FColumnSearchTextColor := AValue;
End;

Procedure TdxCustomDBGridController.SetColumnSelectAllLimit(AValue: Integer);
Begin
   If FColumnSelectAllLimit = AValue Then
      Exit;
   If AValue < 0 Then
      AValue := 200;
   If AValue > 10000 Then
      AValue := 10000;
   FColumnSelectAllLimit := AValue;
End;

Procedure TdxCustomDBGridController.SetControllerOptions(AValue: TdxControllerOptions);
Begin
   If FControllerOptions = AValue Then
      Exit;
   FControllerOptions    := AValue;
   // Both options are exclusive
   If coFirstRowAfterSort IN FControllerOptions Then
      FControllerOptions := FControllerOptions - [coLastRowAfterSort]
   Else If coLastRowAfterSort IN FControllerOptions Then
      FControllerOptions := FControllerOptions - [coFirstRowAfterSort];
   // Both options are exclusive
   If coFirstRowAfterFilter IN FControllerOptions Then
      FControllerOptions := FControllerOptions - [coLastRowAfterFilter]
   Else If coLastRowAfterFilter IN FControllerOptions Then
      FControllerOptions := FControllerOptions - [coFirstRowAfterFilter];

   If Assigned(FFooterPanel) Then
      FFooterPanel.Visible := (coShowFooter IN FControllerOptions);

   If NOT FIsGridValid Then
      exit;
   // Set Grid button style
   SetGridButtonStyle(ftDateTime, cbsEllipsis);
   SetGridButtonStyle(ftDataset, cbsEllipsis);
   SetGridButtonStyle(ftMemo, cbsEllipsis);

   // For to determine the grouped value when doing a recalculation - to draw the group line if needed
   RecalculateAggregation;

   //FGrid.Invalidate;
End;

Procedure TdxCustomDBGridController.SetGlyphColumnChooser(AValue: TPortableNetworkGraphic);
Begin
   If FGridGlyphColumnChooser = AValue Then
      exit;
   If FGridGlyphColumnChooser = nil Then
      FGridGlyphColumnChooser       := TPortableNetworkGraphic.Create;
   FGridGlyphColumnChooser.OnChange := nil;
   FGridGlyphColumnChooser.Assign(AValue);
End;


Procedure TdxCustomDBGridController.SetSearchBoxWidth(AValue: Integer);
Begin
   If FSearchBoxWidth = AValue Then
      Exit;
   FSearchBoxWidth := Min(max(100, AValue), 1000);

   If Assigned(FSearchEditor) Then
      FSearchEditor.Width := FSearchBoxWidth;
End;

Procedure TdxCustomDBGridController.SetSearchTextColor(AValue: TColor);
Begin
   If FSearchTextColor = AValue Then
      Exit;
   FSearchTextColor := AValue;
End;

Procedure TdxCustomDBGridController.SetSearchTypingDelay(AValue: Integer);

Begin
   If AValue = FSearchTypingDelay Then
      exit;
   FSearchTypingDelay := AValue;
End;

Procedure TdxCustomDBGridController.SetSortIndexColor(AValue: TColor);
Begin
   If FSortIndexColor = AValue Then
      Exit;
   FSortIndexColor := AValue;
End;


Initialization
{$I DBGridController.lrs}
{$R DBGridController.res}

End.
