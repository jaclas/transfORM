object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'transfORM Demo'
  ClientHeight = 589
  ClientWidth = 726
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    726
    589)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 4
    Top = 13
    Width = 35
    Height = 13
    Caption = 'DBPath'
  end
  object spl1: TSplitter
    Left = 0
    Top = 240
    Width = 726
    Height = 9
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ResizeStyle = rsUpdate
    ExplicitTop = 148
  end
  object dbgrdInfo: TDBGrid
    AlignWithMargins = True
    Left = 3
    Top = 40
    Width = 720
    Height = 197
    Margins.Top = 40
    Align = alTop
    BorderStyle = bsNone
    DataSource = dtsrcTables
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'RECNO'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'TABLE_NAME'
        Width = 265
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'TABLE_TYPE'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'CATALOG_NAME'
        Width = 100
        Visible = True
      end>
  end
  object pgcMain: TPageControl
    Left = 0
    Top = 249
    Width = 726
    Height = 321
    ActivePage = tsTests
    Align = alClient
    TabOrder = 3
    ExplicitTop = 239
    ExplicitHeight = 331
    object tsData: TTabSheet
      Caption = 'Data'
      ImageIndex = 1
      ExplicitHeight = 425
      object dbgrdData: TDBGrid
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 712
        Height = 287
        Align = alClient
        DataSource = dtsrcData
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
    object tsMeta: TTabSheet
      Caption = 'Meta'
      ExplicitHeight = 425
      object dbgrdFields: TDBGrid
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 712
        Height = 198
        Align = alClient
        BorderStyle = bsNone
        DataSource = dtsrcFields
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'COLUMN_NAME'
            Width = 95
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COLUMN_DATATYPE'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COLUMN_TYPENAME'
            Width = 105
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COLUMN_LENGTH'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COLUMN_POSITION'
            Width = 99
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COLUMN_ATTRIBUTES'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CATALOG_NAME'
            Width = 88
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'SCHEMA_NAME'
            Width = 83
            Visible = True
          end>
      end
      object dbgrd2: TDBGrid
        AlignWithMargins = True
        Left = 3
        Top = 207
        Width = 712
        Height = 83
        Align = alBottom
        BorderStyle = bsNone
        DataSource = dtsrcPK
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        ReadOnly = True
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'TABLE_NAME'
            Width = 150
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'INDEX_NAME'
            Width = 150
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COLUMN_NAME'
            Width = 140
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COLUMN_POSITION'
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'SORT_ORDER'
            Width = 120
            Visible = True
          end>
      end
    end
    object tsTests: TTabSheet
      Caption = 'Tests'
      ImageIndex = 3
      ExplicitHeight = 425
      object btnTestA: TBitBtn
        Left = 10
        Top = 10
        Width = 75
        Height = 25
        Caption = 'Test A'
        TabOrder = 0
        OnClick = btnTestAClick
      end
      object btnTestB: TBitBtn
        Left = 98
        Top = 10
        Width = 75
        Height = 25
        Caption = 'Test B'
        TabOrder = 1
        OnClick = btnTestBClick
      end
      object btnTestC: TBitBtn
        Left = 184
        Top = 10
        Width = 75
        Height = 25
        Caption = 'Test C'
        TabOrder = 2
        OnClick = btnTestCClick
      end
      object mmoLog: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 40
        Width = 712
        Height = 250
        Margins.Top = 40
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 3
        ExplicitTop = 41
        ExplicitHeight = 341
      end
    end
    object tsCode: TTabSheet
      Caption = 'Code'
      ImageIndex = 2
      ExplicitLeft = 3
      ExplicitTop = 22
      ExplicitHeight = 303
      object mmoCode: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 40
        Width = 712
        Height = 250
        Margins.Top = 40
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 1
        ExplicitTop = 50
      end
      object btnGenerate: TBitBtn
        Left = 10
        Top = 10
        Width = 89
        Height = 25
        Caption = 'Generate code'
        TabOrder = 0
        OnClick = btnGenerateClick
      end
    end
  end
  object edtDB: TEdit
    Left = 42
    Top = 8
    Width = 561
    Height = 21
    TabOrder = 1
    Text = 
      'C:\Users\Public\Documents\Embarcadero\Studio\20.0\Samples\data\F' +
      'DDemo.sdb'
  end
  object btnConnect: TBitBtn
    Left = 614
    Top = 7
    Width = 95
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Connect'
    TabOrder = 0
    OnClick = btnConnectClick
  end
  object statBar: TStatusBar
    Left = 0
    Top = 570
    Width = 726
    Height = 19
    Panels = <
      item
        Text = 'Memory allocated'
        Width = 100
      end
      item
        Width = 50
      end>
    ExplicitTop = 610
  end
  object conSQLite: TFDConnection
    Params.Strings = (
      'ConnectionDef=SQLite_Demo')
    ConnectedStoredUsage = []
    Connected = True
    LoginPrompt = False
    Left = 98
    Top = 18
  end
  object fdqryData: TFDQuery
    Connection = conSQLite
    SQL.Strings = (
      'select * from &TableName')
    Left = 532
    Top = 270
    MacroData = <
      item
        Value = ''
        Name = 'TABLENAME'
        DataType = mdIdentifier
      end>
  end
  object metaqryTables: TFDMetaInfoQuery
    Active = True
    AfterScroll = metaqryTablesAfterScroll
    Connection = conSQLite
    Left = 98
    Top = 110
  end
  object dtsrcData: TDataSource
    DataSet = fdqryData
    Left = 524
    Top = 322
  end
  object dtsrcTables: TDataSource
    DataSet = metaqryTables
    Left = 44
    Top = 196
  end
  object metaqryFields: TFDMetaInfoQuery
    Filtered = True
    Connection = conSQLite
    MetaInfoKind = mkTableFields
    ObjectName = 'categories'
    Left = 164
    Top = 330
  end
  object dtsrcFields: TDataSource
    DataSet = metaqryFields
    Left = 122
    Top = 330
  end
  object dtsrcPK: TDataSource
    DataSet = metaqryPK
    Left = 394
    Top = 332
  end
  object metaqryPK: TFDMetaInfoQuery
    Filtered = True
    Connection = conSQLite
    MetaInfoKind = mkPrimaryKeyFields
    BaseObjectName = 'Categories'
    ObjectName = 'categories'
    Left = 392
    Top = 280
  end
  object tmr1: TTimer
    OnTimer = tmr1Timer
    Left = 24
    Top = 550
  end
end
