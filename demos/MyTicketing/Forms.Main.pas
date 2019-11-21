unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SubjectStand,
  FormStand, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TMainForm = class(TForm)
    FormStand1: TFormStand;
    Stands: TStyleBook;
  private
  public
    constructor Create(AOwner: TComponent); override;

  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts, FMXER.UI.Misc, FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.ColumnForm
, FMXER.LogoFrame, FMXER.ContainerFrame, FMXER.EditFrame, FMXER.ButtonFrame,
  Data.Remote, FMX.ActnList;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  Navigator(FormStand1) // initialization
  .DefineRoute<TColumnForm>( // route definition
     'login'
   , procedure (AForm: TColumnForm)
     begin
       AForm.AddFrame<TLogoFrame>(100);

       AForm.AddFrame<TEditFrame>(80
         , procedure (AFrame: TEditFrame)
           begin
             AFrame.Caption := 'Username:';
             AFrame.OnChangeProc :=
               procedure (ATracking: Boolean)
               begin
                 RemoteData.LoginUserName := AFrame.Text;
               end;
           end
       );
       AForm.AddFrame<TEditFrame>(80
         , procedure (AFrame: TEditFrame)
           begin
             AFrame.Caption := 'Password:';
             AFrame.Password := True;
             AFrame.OnChangeProc :=
               procedure (ATracking: Boolean)
               begin
                 RemoteData.LoginPassword := AFrame.Text;
               end;
           end
       );

       AForm.AddFrame<TButtonFrame>(80
         , procedure (AFrame: TButtonFrame)
           begin
             AFrame.Text := 'Login';
             AFrame.ButtonControl.Width := 200;
             AFrame.IsDefault := True;

             AFrame.OnUpdateProc :=
               procedure(AAction: TAction)
               begin
                 AAction.Enabled := not (RemoteData.LoginUserName.Trim.IsEmpty)
                   and (not RemoteData.LoginPassword.IsEmpty);
               end;

             AFrame.OnClickProc :=
               procedure (AFrame: TButtonFrame)
               begin
                 RemoteData.AttemptLogin(
                   procedure
                   begin
                     Navigator.StackPop;
                     Navigator.RouteTo('home');
                   end
                 , procedure
                   begin
                     ShowMessage('Login failed');
                   end
                 );
               end;
           end
       );
     end
  )
  .DefineRoute<TScaffoldForm>( // route definition
     'home'
   , procedure (AForm: TScaffoldForm)
     begin
       AForm.Title := 'Hello, World!';

       AForm.SetContentAsFrame<TLogoFrame>;

       AForm.AddActionButton('A',
         procedure
         begin
           AForm.ShowSnackBar('This is a transient message', 3000);
         end);

       AForm.AddActionButton('X',
         procedure
         begin
           Navigator.CloseRoute('home');
         end);
     end
  );

  Navigator.RouteTo('login'); // initial route
end;

end.
