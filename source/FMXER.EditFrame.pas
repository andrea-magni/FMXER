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
    function GetTextPrompt: string;
    procedure SetTextPrompt(const Value: string);
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    function GetText: string;
    procedure SetText(const Value: string);
    function GetPassword: Boolean;
    procedure SetPassword(const Value: Boolean);
    function GetExtraText: string;
    procedure SetExtraText(const Value: string);
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    [Show]
    procedure ShowHandler;

    property FocusOnShow: Boolean read FFocusOnShow write FFocusOnShow;
    property Password: Boolean read GetPassword write SetPassword;
    property TextPrompt: string read GetTextPrompt write SetTextPrompt;
    property Caption: string read GetCaption write SetCaption;
    property Text: string read GetText write SetText;
    property ExtraText: string read GetExtraText write SetExtraText;
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

procedure TEditFrame.SetCaption(const Value: string);
begin
  CaptionLabel.Text := Value;
end;

procedure TEditFrame.SetExtraText(const Value: string);
begin
  ExtraLabel.Text := Value;
end;

procedure TEditFrame.SetPassword(const Value: Boolean);
begin
  EditControl.Password := Value;
end;

procedure TEditFrame.SetText(const Value: string);
begin
  EditControl.Text := Value;
end;

procedure TEditFrame.SetTextPrompt(const Value: string);
begin
  EditControl.TextPrompt := Value;
end;

procedure TEditFrame.ShowHandler;
begin
  SI.DefaultShow;

  if FocusOnShow and EditControl.CanFocus then
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
