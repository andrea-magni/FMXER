program DataSetProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Data.Main in 'Data.Main.pas' {DataModule1: TDataModule},
  Frames.MyDataSetList in 'Frames.MyDataSetList.pas' {MyDatasetListFrame: TFrame},
  Frames.MyDataSetDetail in 'Frames.MyDataSetDetail.pas' {MyDataSetDetailFrame: TFrame};

{$R *.res}

begin
  {$IFDEF MSWINDOWS} ReportMemoryLeaksOnShutdown := True; {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
