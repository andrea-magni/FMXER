unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls
, SubjectStand, FormStand
, FMXER.ColumnForm;

type
  TMainForm = class(TForm)
    FormStand1: TFormStand;
    Stands: TStyleBook;
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
  protected
    function GetColumnDefinition: TProc<TColumnForm>;
    procedure NavigatorStackPopkHandler(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;

  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts, FMXER.UI.Misc, FMXER.Navigator
, FMXER.ContainerFrame, FMXER.ContainerForm
, FMXER.BackgroundFrame, FMXER.BackgroundForm
, FMXER.HorzDividerFrame, FMXER.VertScrollFrame
, FMXER.TextFrame, FMXER.LogoFrame, FMXER.CardFrame;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key in [vkHardwareBack, vkEscape] then
    Navigator.CloseAllRoutesExcept('home');
end;

function TMainForm.GetColumnDefinition: TProc<TColumnForm>;
begin
  Result := procedure (AColumn: TColumnForm)
     begin
       AColumn.AddFrame<TContainerFrame>(100,
       procedure (AContainer: TContainerFrame)
       begin
         AContainer.SetContentAs<TButton>(
           procedure (AButton: TButton)
           begin
             AButton.Text := 'Close me';
             AButton.OnClick := NavigatorStackPopkHandler;
             AButton.Align := TAlignLayout.Center;
           end);
       end);

       AColumn.AddFrame<TLogoFrame>(100);
       AColumn.AddFrame<TLogoFrame>(200);

       AColumn.AddFrame<THorzDividerFrame>(1); // ----------------------

       AColumn.AddFrame<TLogoFrame>(
         TElementDef<TLogoFrame>.Create(nil, [
           Param('Height', 100)
         ]));
       AColumn.AddFrame<TLogoFrame>(
         TElementDef<TLogoFrame>.Create(nil, [
           Param('Height', 200)
         ]));

       AColumn.AddFrame<TCardFrame>(
        TElementDef<TCardFrame>.Create(
         procedure (Card: TCardFrame)
         begin
           Card.Title := 'Delphi Live 13/5';
           Card.SetContentAsFrame<TLogoFrame>(
             procedure (ALogo: TLogoFrame)
             begin
               ALogo.Height := 150;
             end
           );
         end
        , []
        )
      );

     end
end;

procedure TMainForm.NavigatorStackPopkHandler(Sender: TObject);
begin
  Navigator.StackPop;
end;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  Navigator(FormStand1) // initialization

  .DefineRoute<TBackgroundForm>('home'
   , procedure (ABackground: TBackgroundForm)
     begin
       ABackground.Fill.Color := $FF1565c0;

       ABackground.SetContentAsForm<TColumnForm>(
         procedure(AColumn: TColumnForm)
         begin
           AColumn.AddFrame<TTextFrame>(100
             , procedure (AText: TTextFrame)
               begin
                 AText.Content := 'Column route';
                 AText.OnClickProc := procedure
                                      begin
                                        Navigator.RouteTo('column')
                                      end;
               end);

           AColumn.AddFrame<THorzDividerFrame>(1); // ----------------------

           AColumn.AddFrame<TTextFrame>(100
             , procedure (AText: TTextFrame)
               begin
                 AText.Content := 'Column with vert scroll route';
                 AText.OnClickProc := procedure
                                      begin
                                        Navigator.RouteTo('vertScrollColumn')
                                      end;
               end);
         end);
     end)

  .DefineRoute<TBackgroundForm>('column'
   , procedure(ABackground: TBackgroundForm)
     begin
       ABackground.Fill.Color := TAppColors.MATERIAL_AMBER_800;
       ABackground.SetContentAsForm<TColumnForm>(
         GetColumnDefinition()
       );
     end)

  .DefineRoute<TBackgroundForm>('vertScrollColumn'
   , procedure(ABackground: TBackgroundForm)
     begin
       ABackground.Fill.Color := TAppColors.MATERIAL_INDIGO_800;
       ABackground.SetContentAsFrame<TVertScrollFrame>(
         procedure (AScroll: TVertScrollFrame)
         begin
           AScroll.SetContentAsForm<TColumnForm>(
             GetColumnDefinition()
           );
         end);
     end);

  Navigator.RouteTo('home'); // initial route
end;

end.
