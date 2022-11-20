object MainData: TMainData
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
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
    Interval = 50
    OnTimer = RadiusFactorDeferTimerTimer
    Left = 112
    Top = 200
  end
  object CameraComponent1: TCameraComponent
    OnSampleBufferReady = CameraComponent1SampleBufferReady
    Left = 112
    Top = 312
  end
end
