object MainData: TMainData
  OnCreate = DataModuleCreate
  Height = 960
  Width = 1280
  PixelsPerInch = 192
  object ActionList1: TActionList
    Left = 112
    Top = 80
    object ShowShareSheetAction1: TShowShareSheetAction
      Category = 'Media Library'
    end
  end
  object RadiusFactorDeferTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = RadiusFactorDeferTimerTimer
    Left = 120
    Top = 216
  end
end
