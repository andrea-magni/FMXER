unit FMXER.UI.Types;

// Types shared by several elements.

interface

uses
  System.Types, FMX.Types;

type
  /// <summary>Tap on an image-like element (TImageFrame, TSVGFrame,
  /// TAnimatedImageFrame, TQRCodeFrame): AImage is the inner control, APoint
  /// is in its coordinates. On Windows it is raised on mouse up.</summary>
  TOnTapHandler = reference to procedure(AImage: TFMXObject; APoint: TPointF);

implementation

end.
