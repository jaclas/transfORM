object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'transfORM Demo'
  ClientHeight = 629
  ClientWidth = 726
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    726
    629)
  PixelsPerInch = 96
  TextHeight = 13
  object dbgrdInfo: TDBGrid
    AlignWithMargins = True
    Left = 3
    Top = 30
    Width = 720
    Height = 115
    Margins.Top = 30
    Align = alTop
    DataSource = dtsrcTables
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 4
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'TABLE_NAME'
        Width = 316
        Visible = True
      end>
  end
  object btnTest: TBitBtn
    Left = 648
    Top = 3
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Test'
    TabOrder = 2
    OnClick = btnTestClick
  end
  object btnGenerate: TBitBtn
    Left = 553
    Top = 3
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Generate code'
    TabOrder = 1
    OnClick = btnGenerateClick
  end
  object pgcMain: TPageControl
    Left = 0
    Top = 148
    Width = 726
    Height = 481
    ActivePage = tsMeta
    Align = alClient
    TabOrder = 5
    ExplicitLeft = 2
    ExplicitTop = 192
    ExplicitWidth = 697
    ExplicitHeight = 409
    object tsMeta: TTabSheet
      Caption = 'Meta'
      ExplicitWidth = 281
      ExplicitHeight = 165
      DesignSize = (
        718
        453)
      object dbgrdFields: TDBGrid
        Left = 2
        Top = 3
        Width = 713
        Height = 360
        Anchors = [akLeft, akTop, akRight, akBottom]
        DataSource = dtsrcFields
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
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
            Width = 122
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COLUMN_TYPENAME'
            Width = 104
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COLUMN_LENGTH'
            Visible = True
          end>
      end
      object dbgrd2: TDBGrid
        Left = 2
        Top = 367
        Width = 713
        Height = 83
        Anchors = [akLeft, akRight, akBottom]
        DataSource = dtsrcPK
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
    object tsData: TTabSheet
      Caption = 'Data'
      ImageIndex = 1
      ExplicitWidth = 281
      ExplicitHeight = 165
      object dbgrdData: TDBGrid
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 712
        Height = 447
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
    object tsCode: TTabSheet
      Caption = 'Code'
      ImageIndex = 2
      ExplicitWidth = 689
      ExplicitHeight = 381
      object mmoCode: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 712
        Height = 447
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 307
        ExplicitTop = 54
        ExplicitWidth = 382
        ExplicitHeight = 327
      end
    end
  end
  object edtDB: TEdit
    Left = 4
    Top = 5
    Width = 419
    Height = 21
    TabOrder = 3
    Text = 
      'C:\Users\Public\Documents\Embarcadero\Studio\20.0\Samples\data\F' +
      'DDemo.sdb'
  end
  object btnConnect: TBitBtn
    Left = 472
    Top = 3
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Connect'
    TabOrder = 0
    OnClick = btnConnectClick
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
    Left = 92
    Top = 182
  end
  object metaqryFields: TFDMetaInfoQuery
    Filtered = True
    Connection = conSQLite
    MetaInfoKind = mkTableFields
    ObjectName = 'categories'
    Left = 128
    Top = 276
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
    Active = True
    Filtered = True
    Connection = conSQLite
    MetaInfoKind = mkPrimaryKeyFields
    BaseObjectName = 'Categories'
    ObjectName = 'categories'
    Left = 392
    Top = 280
  end
end
