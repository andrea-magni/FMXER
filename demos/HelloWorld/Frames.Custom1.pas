unit Frames.Custom1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation;

type
  TCustom1Frame = class(TFrame)
    CustomButton: TButton;
    Circle1: TCircle;
    procedure CustomButtonClick(Sender: TObject);
  private
    FOnButtonClick: TProc;
  public
    property OnButtonClick: TProc read FOnButtonClick write FOnButtonClick;
  end;

implementation

{$R *.fmx}

procedure TCustom1Frame.CustomButtonClick(Sender: TObject);
begin
  if Assigned(FOnButtonClick) then
    FOnButtonClick();
end;

end.
