object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'transfORM Demo'
  ClientHeight = 629
  ClientWidth = 727
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    727
    629)
  PixelsPerInch = 96
  TextHeight = 13
  object dbgrdData: TDBGrid
    Left = 2
    Top = 393
    Width = 771
    Height = 234
    Anchors = [akLeft, akTop, akRight]
    DataSource = dtsrcData
    TabOrder = 5
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object dbgrdInfo: TDBGrid
    Left = 2
    Top = 42
    Width = 339
    Height = 115
    DataSource = dtsrcInfo
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 2
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
  object mmoCode: TMemo
    Left = 343
    Top = 60
    Width = 382
    Height = 327
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'mmoCode')
    TabOrder = 3
  end
  object btnTest: TBitBtn
    Left = 650
    Top = 33
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 1
    OnClick = btnTestClick
  end
  object dbgrdFields: TDBGrid
    Left = 2
    Top = 163
    Width = 339
    Height = 228
    DataSource = dtsrcFields
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 4
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
  object btnGenerate: TBitBtn
    Left = 552
    Top = 33
    Width = 89
    Height = 25
    Caption = 'Generate code'
    TabOrder = 0
    OnClick = btnGenerateClick
  end
  object conSQLite: TFDConnection
    Params.Strings = (
      'ConnectionDef=SQLite_Demo')
    ConnectedStoredUsage = []
    Connected = True
    LoginPrompt = False
    Left = 40
    Top = 42
  end
  object fdqryData: TFDQuery
    Connection = conSQLite
    SQL.Strings = (
      'select * from &TableName')
    Left = 354
    Top = 314
    MacroData = <
      item
        Value = Null
        Name = 'TABLENAME'
        DataType = mdIdentifier
      end>
  end
  object metaqryInfo: TFDMetaInfoQuery
    Active = True
    AfterScroll = metaqryInfoAfterScroll
    Connection = conSQLite
    Left = 290
    Top = 40
  end
  object dtsrcData: TDataSource
    DataSet = fdqryData
    Left = 366
    Top = 344
  end
  object dtsrcInfo: TDataSource
    DataSet = metaqryInfo
    Left = 294
    Top = 78
  end
  object metaqryFields: TFDMetaInfoQuery
    Active = True
    Filtered = True
    Connection = conSQLite
    MetaInfoKind = mkTableFields
    ObjectName = 'categories'
    Left = 128
    Top = 276
  end
  object dtsrcFields: TDataSource
    DataSet = metaqryFields
    Left = 136
    Top = 304
  end
end
