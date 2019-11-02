unit FMXER.ImageFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.MultiResBitmap;

type
  TImageFrame = class(TFrame)
    ContentImage: TImage;
  private
  public
    property Image: TImage read ContentImage;
  end;

implementation

{$R *.fmx}

end.
