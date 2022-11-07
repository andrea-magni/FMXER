unit FMXER.EditFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, SubjectStand;

type
  TEditFrame = class(TFrame)
    EditControl: TEdit;
    CaptionLabel: TLabel;
    ExtraLabel: TLabel;
    procedure EditControlChangeTracking(Sender: TObject);
    procedure EditControlChange(Sender: TObject);
  private
    FOnChangeProc: TProc<Boolean>;
    FFocusOnShow: Boolean;
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    [Show]
    procedure ShowHandler;

    function GetTextPrompt: string;
    function GetCaption: string;
    function GetText: string;
    function GetPassword: Boolean;
    function GetExtraText: string;
    function GetFocusOnShow: Boolean;

    function SetCaption(const ACaption: string): TEditFrame;
    function SetTextPrompt(const ATextPrompt: string): TEditFrame;
    function SetText(const AText: string): TEditFrame;
    function SetExtraText(const AExtraText: string): TEditFrame;
    function SetPassword(const AIsPassword: Boolean): TEditFrame;
    function SetFocusOnShow(const AFocusOnShow: Boolean): TEditFrame;

    property OnChangeProc: TProc<Boolean> read FOnChangeProc write FOnChangeProc;
  end;

implementation

{$R *.fmx}

{ TEditFrame }

procedure TEditFrame.EditControlChange(Sender: TObject);
begin
  if Assigned(FOnChangeProc) then
    FOnChangeProc(False);
end;

procedure TEditFrame.EditControlChangeTracking(Sender: TObject);
begin
  if Assigned(FOnChangeProc) then
    FOnChangeProc(True);
end;

function TEditFrame.GetCaption: string;
begin
  Result := CaptionLabel.Text;
end;

function TEditFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TEditFrame.GetFocusOnShow: Boolean;
begin
  Result := FFocusOnShow;
end;

function TEditFrame.GetPassword: Boolean;
begin
  Result := EditControl.Password;
end;

function TEditFrame.GetText: string;
begin
  Result := EditControl.Text;
end;

function TEditFrame.GetTextPrompt: string;
begin
  Result := EditControl.TextPrompt;
end;

function TEditFrame.SetCaption(const ACaption: string): TEditFrame;
begin
  Result := Self;
  CaptionLabel.Text := ACaption;
end;

function TEditFrame.SetExtraText(const AExtraText: string): TEditFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
end;

function TEditFrame.SetFocusOnShow(const AFocusOnShow: Boolean): TEditFrame;
begin
  Result := Self;
  FFocusOnShow := AFocusOnShow;
end;

function TEditFrame.SetPassword(const AIsPassword: Boolean): TEditFrame;
begin
  Result := Self;
  EditControl.Password := AIsPassword;
end;

function TEditFrame.SetText(const AText: string): TEditFrame;
begin
  Result := Self;
  EditControl.Text := AText;
end;

function TEditFrame.SetTextPrompt(const ATextPrompt: string): TEditFrame;
begin
  Result := Self;
  EditControl.TextPrompt := ATextPrompt;
end;

procedure TEditFrame.ShowHandler;
begin
  SI.DefaultShow;

  if GetFocusOnShow and EditControl.CanFocus then
  begin
    TDelayedAction.Execute(10
    , procedure
      begin
        EditControl.SetFocus;
      end
    );

  end;
end;

end.
