[Code]
{************************************************************************}
{                                                                        }
{ FMXER setup, based on the Ethea InnoSetup Tools Library                }
{ (InnoSetupScripts, MIT license; original code by the Skia4Delphi       }
{ Project), the same library used by the TFrameStand and MARS setups.   }
{                                                                        }
{************************************************************************}
{                                                                        }
{                          Custom Parameters                             }
{                                                                        }
{ /RADStudioVersions=                                                    }
{   Values allowed: 21.0 to 37.0 separed by comma or all keyword         }
{   Default: (latest version found in computer)                          }
{   Description: The version used is the product version in registry,    }
{     i.e. RAD Studio 12 Athens is "23.0", RAD Studio 13 Florence is     }
{     "37.0". Ex: /RADStudioVersions=37.0,23.0 installs only in RAD      }
{     Studio 13 Florence and 12 Athens; /RADStudioVersions=all installs  }
{     in all the RAD Studio versions found. Run by GetIt, use            }
{     /RADStudioVersions=$(ProductVersion)                               }
{                                                                        }
{ /CreateUninstallRegKey=                                                }
{   Values allowed: no|yes or false|true or 0|1                          }
{   Default: yes                                                         }
{   Description: When true the uninstall shortcut in applications panel  }
{     is created and, before the setup starts, the uninstall of other    }
{     versions is called                                                 }
{                                                                        }
{************************************************************************}
{                                                                        }
{ Install in silent mode:                                                }
{   cmd /C ""FMXER_Setup.exe" /DIR="C:\Dev\FMXER"                        }
{     /SILENT /RADStudioVersions=all"                                    }
{                                                                        }
{ Uninstall in silent mode:                                              }
{   cmd /C ""C:\Dev\FMXER\unins000.exe" /VERYSILENT                      }
{     /RADStudioVersions=all"                                            }
{                                                                        }
{ Requirements (installed before FMXER, the setup does not install       }
{ them): TFrameStand (its setup, GetIt or TMS Smart Setup) and           }
{ IconFontsImageList (GetIt or its packages), whose packages             }
{ FMXERPackage requires. FMXERQRCodePackage is built only when a         }
{ DelphiZXingQRCode package is installed (DelphiZXingQRCode.dcp in the   }
{ Dcp folder of the IDE): otherwise the QR code units compile from the   }
{ source folder, with DelphiZXingQRCode's source in the search path.     }
{                                                                        }
{ Build: setup\build-setup.cmd (from a clean export of the repository)   }
{                                                                        }
{************************************************************************}

#define LibraryName "FMXER"
#define SetupName "FMXER"
#define LibraryVersion "1.5.3"
#define LibraryPublisher "Andrea Magni"
#define LibraryCopyright "Copyright (c) Andrea Magni"
#define LibraryURL "https://github.com/andrea-magni/FMXER"
#define LibrarySamplesFolder "demos"
#define LibraryPackagesFolder "packages"
#define LibrarySourceFolder "source"
#define LibraryDCUFolder "dcu"
#define LibraryDocumentationURL "https://andrea-magni.github.io/FMXER/"
#define LibrarySupportURL "https://github.com/andrea-magni/FMXER/issues/"
#define LibraryUpdatesURL "https://github.com/andrea-magni/FMXER/releases/"
#define LibraryLicenseFileName "..\LICENSE"
#define BannerImagesFileName "WizFMXERImage.bmp"
#define SmallImagesFileName "WizFMXERSmallImage.bmp"
#define SetupFolder "setup"
#define FilesEmbedded

// the demo folders shipped with the setup ("|lightbox|wait|...|"): the uninstaller deletes only
// these, any other folder in demos (a project of the user) is left alone
#define DemoFolders "|"
#define DemoFindHandle 0
#define DemoFindResult 0
#define DemoName ""
#sub ReadDemoName
  #define public DemoName FindGetFileName(DemoFindHandle)
  #if DemoName == "." || DemoName == ".." || !DirExists(AddBackslash(SourcePath) + "..\demos\" + DemoName)
    #define public DemoName ""
  #endif
#endsub
#sub AddDemoFolder
  #expr ReadDemoName
  #if DemoName != ""
    #define public DemoFolders DemoFolders + DemoName + "|"
  #endif
#endsub
#for {DemoFindHandle = DemoFindResult = FindFirst(AddBackslash(SourcePath) + "..\demos\*", faDirectory); DemoFindResult; DemoFindResult = FindNext(DemoFindHandle)} AddDemoFolder
#if DemoFindHandle
  #expr FindClose(DemoFindHandle)
#endif
#if DemoFolders == "|"
  #error No demo folder found in ..\demos
#endif
//you can choose your preferred Style contained in folder: InnoSetupScripts\Style
#define VclStyle "RubyGraphite.vsf"

[Setup]
WizardSizePercent=120
AllowCancelDuringInstall=yes
AppCopyright={#LibraryCopyright}
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
AppId={{2171E688-9C3B-410F-AEF2-EF54084DA535}
AppName={#LibraryName}
AppPublisher={#LibraryPublisher}
AppPublisherURL={#LibraryURL}
AppSupportURL={#LibrarySupportURL}
AppUpdatesURL={#LibraryUpdatesURL}
AppVersion={#LibraryVersion}
CloseApplications=no
Compression=lzma2/ultra64
CreateUninstallRegKey=NeedsUninstallRegKey
DefaultDirName={code:GetDefaultDirName}
DefaultGroupName={#LibraryName}
DirExistsWarning=no
DisableDirPage=no
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableStartupPrompt=yes
DisableWelcomePage=no
InternalCompressLevel=ultra64
LicenseFile={#LibraryLicenseFileName}
LZMANumBlockThreads=6
LZMAUseSeparateProcess=yes
MissingMessagesWarning=yes
NotRecognizedMessagesWarning=yes
PrivilegesRequired=lowest
SetupLogging=yes
ShowLanguageDialog=no
SolidCompression=yes
UsePreviousAppDir=no
WizardImageFile={#BannerImagesFileName}
WizardSmallImageFile={#SmallImagesFileName}
OutputBaseFilename={#SetupName}_{#LibraryVersion}_Setup
OutputDir=.\Output\
Uninstallable=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl,.\InnoSetupScripts\Languages\BrazilianPortuguese.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl,.\InnoSetupScripts\Languages\Catalan.isl"
Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl,.\InnoSetupScripts\Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl,.\InnoSetupScripts\Languages\German.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl,.\InnoSetupScripts\Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl,.\InnoSetupScripts\Languages\Spanish.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl,.\InnoSetupScripts\Languages\Default.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl,.\InnoSetupScripts\Languages\Default.isl"

#define CommonRADStudioFilesExcludes "*.exe,*.dll,*.bpl,*.bpi,*.dcp,*.so,*.apk,*.drc,*.map,*.dres,*.rsm,*.tds,*.dcu,*.lib,*.jdbg,*.plist,*.cfg,*Resource.rc,*.local,*.identcache,*.projdata,*.tvsconfig,*.skincfg,*.cbk,*.dsk,__history\*,__recovery\*,*.~*,*.stat,modules\*,.github\*,*.a,*.dex,*.o,*.vrc,*.res,*.log,*.deployproj,*.bak,unins0*.dat,*.nupkg"
; Don't change the order of the files. This could affect the performance when extract temp files
[Files]
#ifdef VclStyle
  Source: ".\InnoSetupScripts\Style\*"; DestDir: "{app}\{#SetupFolder}\Style"; Flags: ignoreversion
#endif
; packages: one folder per Delphi version (12, 13), each with FMXER.groupproj
Source: "..\{#LibraryPackagesFolder}\*"; Excludes: "{#CommonRADStudioFilesExcludes}"; DestDir: "{app}\{#LibraryPackagesFolder}"; Flags: recursesubdirs ignoreversion
Source: "..\*"; Excludes: "{#CommonRADStudioFilesExcludes},*.gitattributes,*.gitignore,\.git\*,\.github\*,\.claude\*,\.claude-plugin\*,\{#LibraryDCUFolder}\*,\lib\TFrameStand\*,\lib\IconFontsImageList\*,\lib\DelphiZXingQRCode\TestApp\*,\lib\ZXing.Delphi\UnitTest\*,\lib\ZXing.Delphi\MemLeakTest\*,\lib\ZXing.Delphi\demo\*,\{#SetupFolder}\*,\{#LibraryPackagesFolder}\*,\build\*,\docs\node_modules\*,\docs\.vitepress\cache\*,\docs\.vitepress\dist\*,\docs\public\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion
; the icon font of FMXER (FMXER.IconFontsData): installed for the current user, so that
; icons show in the demos and in the applications run on this machine. Kept on uninstall:
; other applications may use it
Source: "..\media\Material Design Icons Desktop.ttf"; DestDir: "{autofonts}"; FontInstall: "Material Design Icons Desktop"; Flags: onlyifdoesntexist uninsneveruninstall

[Icons]
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#LibrarySamplesFolder}"; Description: "{cm:SetupOpenSamplesFolder}"; Flags: shellexec runasoriginaluser postinstall;
Filename: "{#LibraryDocumentationURL}"; Description: "{cm:SetupViewOnlineDocumentation}"; Flags: shellexec runasoriginaluser postinstall;

[UninstallDelete]
; demos: only the demo folders shipped with the setup (see DemoFolders), not the projects of the user
Type: files; Name: "{app}\demos\*";
#sub EmitDemoUninstallDelete
  #expr ReadDemoName
  #if DemoName != ""
Type: filesandordirs; Name: "{app}\demos\{#DemoName}";
  #endif
#endsub
#for {DemoFindHandle = DemoFindResult = FindFirst(AddBackslash(SourcePath) + "..\demos\*", faDirectory); DemoFindResult; DemoFindResult = FindNext(DemoFindHandle)} EmitDemoUninstallDelete
#if DemoFindHandle
  #expr FindClose(DemoFindHandle)
#endif
Type: filesandordirs; Name: "{app}\dcu\*";
Type: filesandordirs; Name: "{app}\docs\*";
Type: filesandordirs; Name: "{app}\media\*";
Type: filesandordirs; Name: "{app}\packages\*";
Type: filesandordirs; Name: "{app}\Skills\*";
Type: filesandordirs; Name: "{app}\source\*";
Type: filesandordirs; Name: "{app}\tests\*";
Type: filesandordirs; Name: "{app}\{#SetupFolder}\*";
Type: filesandordirs; Name: "{app}\build.cmd";
Type: filesandordirs; Name: "{app}\Build.Logs.txt";
Type: filesandordirs; Name: "{app}\CODE_OF_CONDUCT.md";
Type: filesandordirs; Name: "{app}\LICENSE";
Type: filesandordirs; Name: "{app}\List.md";
Type: filesandordirs; Name: "{app}\README.md";
Type: filesandordirs; Name: "{app}\tmsbuild.yaml";
Type: filesandordirs; Name: "{app}\version.txt";
Type: dirifempty; Name: "{app}\demos";
Type: dirifempty; Name: "{app}\dcu";
Type: dirifempty; Name: "{app}\docs";
Type: dirifempty; Name: "{app}\media";
Type: dirifempty; Name: "{app}\packages";
Type: dirifempty; Name: "{app}\Skills";
Type: dirifempty; Name: "{app}\source";
Type: dirifempty; Name: "{app}\tests";
Type: dirifempty; Name: "{app}\{#SetupFolder}";
Type: dirifempty; Name: "{app}";

// Include
#include ".\InnoSetupScripts\Source\Setup.Main.inc"

[code]
const
  // IDE environment variable with the installation folder: the library paths use $(FMXERDIR)
  LibraryDirVariable = 'FMXERDIR';
  LibraryDirDefine = '$(' + LibraryDirVariable + ')';

/// <summary> Make custom changes before the installation </summary>
function _OnTryPrepareProjectInstallation(var AProjectItem: TRADStudioGroupProjectItem; const AInfo: TRADStudioInfo): Boolean; forward;
/// <summary> Make custom changes before the uninstallation </summary>
function _OnTryPrepareProjectUninstallation(var AProjectItem: TRADStudioGroupProjectItem; const AInfo: TRADStudioInfo): Boolean; forward;

/// <summary> FMXERQRCodePackage requires DelphiZXingQRCode.dcp, a package that DelphiZXingQRCode
/// does not ship (TMS Smart Setup builds one): build it only when the IDE has it, otherwise the
/// QR code units compile from the source folder (added to the library path anyway) </summary>
function _OnBeforeProjectBuild(const AProject: TRADStudioProject; const APlatform: TProjectPlatform; const AInfo: TRADStudioInfo): Boolean;
begin
  Result := True;
  if SameText(ExtractFileName(AProject.FileName), 'FMXERQRCodePackage.dproj') then
  begin
    Result := FileExists(AddBackslash(GetRADStudioCommonDcpDir(AInfo, APlatform)) + 'DelphiZXingQRCode.dcp');
    if not Result then
      Log(Format('_OnBeforeProjectBuild: DelphiZXingQRCode.dcp not found for %s %s, %s skipped', [AInfo.Version.Name, GetProjectPlatformName(APlatform), ExtractFileName(AProject.FileName)]));
  end;
end;

/// <summary> FMXER is a FireMonkey library for every FMX platform. The setup builds the
/// packages for Win32 and Win64 (the runtime packages need them), and Setup.Main.inc
/// sets the library path of those two platforms. Applications for the other platforms (Win64x,
/// WinArm64EC, Android, iOS, macOS, Linux) compile the units from source: the source folder must
/// be in their library path too. The platforms are read from the registry of the IDE, so new
/// ones (WinArm64EC in Delphi 13, the next ones) are covered without changing the setup. </summary>
procedure _UpdateSourcePathsOfOtherPlatforms(const AProject: TRADStudioProject; const AInfo: TRADStudioInfo; const AAdd: Boolean);
var
  LLibraryKey, LPlatformKey, LValue: string;
  LPlatformNames, LPaths: TArrayOfString;
  I, J: Integer;
begin
  if AProject.IsDesignOnly or (GetArrayLength(AProject.SourcePaths) = 0) then
    Exit;
  LLibraryKey := GetRADStudioRegKey(AInfo.Version) + '\Library';
  if not RegGetSubkeyNames(HKEY_CURRENT_USER, LLibraryKey, LPlatformNames) then
    Exit;
  for I := 0 to GetArrayLength(LPlatformNames) - 1 do
  begin
    if SameText(LPlatformNames[I], GetProjectPlatformName(pfWin32))
      or SameText(LPlatformNames[I], GetProjectPlatformName(pfWin64)) then
      Continue;
    LPlatformKey := LLibraryKey + '\' + LPlatformNames[I];
    if not RegQueryStringValue(HKEY_CURRENT_USER, LPlatformKey, 'Search Path', LValue) then
      LValue := '';
    LPaths := SplitString(LValue, ';');
    // drop our paths first (also when adding: no duplicates, and they move to the top)
    for J := 0 to GetArrayLength(AProject.SourcePaths) - 1 do
    begin
      LPaths := RemoveString(LPaths, AProject.SourcePaths[J], False);
      LPaths := RemoveString(LPaths, AProject.SourcePaths[J] + '\', False);
    end;
    if AAdd then
      for J := GetArrayLength(AProject.SourcePaths) - 1 downto 0 do
        LPaths := InsertString(0, LPaths, AProject.SourcePaths[J], False);
    if RegWriteStringValue(HKEY_CURRENT_USER, LPlatformKey, 'Search Path', JoinStrings(LPaths, ';', False)) then
      Log(Format('_UpdateSourcePathsOfOtherPlatforms: %s, %s', [LPlatformNames[I], JoinStrings(AProject.SourcePaths, ';', False)]))
    else
      Log(Format('_UpdateSourcePathsOfOtherPlatforms: could not update the library path of %s', [LPlatformNames[I]]));
  end;
end;

/// <summary> A folder of the library path of the IDE with its $(...) variables expanded:
/// $(Platform), $(Config) and the variables of the IDE (environment.proj) </summary>
function _ExpandLibraryPath(const AInfo: TRADStudioInfo; const APlatform: TProjectPlatform; APath: string): string;
var
  LStart, LEnd: Integer;
  LName, LValue: string;
begin
  Result := '';
  LStart := Pos('$(', APath);
  while LStart > 0 do
  begin
    LEnd := Pos(')', Copy(APath, LStart + 2, MaxInt));
    if LEnd = 0 then
      Break;
    LName := Copy(APath, LStart + 2, LEnd - 1);
    if SameText(LName, 'Platform') then
      LValue := GetProjectPlatformName(APlatform)
    else if SameText(LName, 'Config') then
      LValue := 'Release'
    else if not _TryGetRADStudioEnvVar(AInfo.Version, LName, LValue) then
      LValue := GetEnv(LName);
    Result := Result + Copy(APath, 1, LStart - 1) + LValue;
    Delete(APath, 1, LStart + LEnd + 1);
    LStart := Pos('$(', APath);
  end;
  Result := Result + APath;
end;

/// <summary> True when the compiler finds the package: its .dcp in the Dcp folder of the
/// IDE (GetIt, the TFrameStand setup) or in a folder of the library path (TMS Smart Setup) </summary>
function _IsPackageInstalled(const AInfo: TRADStudioInfo; const APlatform: TProjectPlatform; const APackageName: string): Boolean;
var
  LSearchPath: string;
  LPaths: TArrayOfString;
  I: Integer;
begin
  Result := FileExists(AddBackslash(GetRADStudioCommonDcpDir(AInfo, APlatform)) + APackageName + '.dcp');
  if Result then
    Exit;
  if not RegQueryStringValue(HKEY_CURRENT_USER, GetRADStudioRegKey(AInfo.Version) + '\Library\' + GetProjectPlatformLibraryName(APlatform), 'Search Path', LSearchPath) then
    Exit;
  LPaths := SplitString(LSearchPath, ';');
  for I := 0 to GetArrayLength(LPaths) - 1 do
    if (Trim(LPaths[I]) <> '') and FileExists(AddBackslash(_ExpandLibraryPath(AInfo, APlatform, Trim(LPaths[I]))) + APackageName + '.dcp') then
    begin
      Result := True;
      Exit;
    end;
end;

/// <summary> FMXERPackage requires the packages of TFrameStand and IconFontsImageList, which the
/// setup does not install: without them MSBuild stops with "E2202 Required package not found".
/// Check them before installing anything, and tell what is missing and how to get it </summary>
function PrepareToInstall(var ANeedsRestart: Boolean): string;
var
  LInfos: TRADStudioInfos;
  LPlatforms: array of TProjectPlatform;
  LMissing: string;
  I, J: Integer;
begin
  Result := '';
  LMissing := '';
  LInfos := GetSelectedRADStudioVersions;
  SetArrayLength(LPlatforms, 2);
  LPlatforms[0] := pfWin32;
  LPlatforms[1] := pfWin64;
  for I := 0 to GetArrayLength(LInfos) - 1 do
  begin
    if LInfos[I].Status <> riNormal then
      Continue;
    for J := 0 to GetArrayLength(LPlatforms) - 1 do
    begin
      if not CheckIfRADStudioSupportsPlatform(LInfos[I], LPlatforms[J]) then
        Continue;
      if not _IsPackageInstalled(LInfos[I], LPlatforms[J], 'FrameStandPackage') then
        LMissing := LMissing + #13#10 + Format('  %s, %s: TFrameStand (FrameStandPackage)', [LInfos[I].Version.Name, GetProjectPlatformName(LPlatforms[J])]);
      if not _IsPackageInstalled(LInfos[I], LPlatforms[J], 'IconFontsImageListFMX') then
        LMissing := LMissing + #13#10 + Format('  %s, %s: IconFontsImageList (IconFontsImageListFMX)', [LInfos[I].Version.Name, GetProjectPlatformName(LPlatforms[J])]);
    end;
  end;
  if LMissing <> '' then
  begin
    Result := 'FMXER requires TFrameStand and IconFontsImageList. These packages were not found:' + LMissing + #13#10#13#10 +
      'Install them first and then run this setup again:' + #13#10 +
      '  TFrameStand: its setup (github.com/andrea-magni/TFrameStand/releases), GetIt or TMS Smart Setup' + #13#10 +
      '  IconFontsImageList: GetIt (Tools > GetIt Package Manager, search "IconFontsImageList")' + #13#10#13#10 +
      'Nothing was installed.';
    Log('PrepareToInstall: ' + Result);
  end;
end;

/// <summary> Library paths relative to $(FMXERDIR) instead of absolute </summary>
procedure _UseLibraryDirVariable(var AProjectItem: TRADStudioGroupProjectItem);
var
  I: Integer;
  LAppPath: string;
begin
  LAppPath := ExpandConstant('{app}');
  for I := 0 to GetArrayLength(AProjectItem.Project.SourcePaths) - 1 do
    StringChangeEx(AProjectItem.Project.SourcePaths[I], LAppPath, LibraryDirDefine, True);
  StringChangeEx(AProjectItem.Project.DCUOutputPath, LAppPath, LibraryDirDefine, True);
end;

function _OnTryPrepareProjectInstallation(var AProjectItem: TRADStudioGroupProjectItem; const AInfo: TRADStudioInfo): Boolean;
begin
  Log(Format('_OnTryPrepareProjectInstallation: Preparing package "%s" before install...', [AProjectItem.Project.FileName]));
  _UseLibraryDirVariable(AProjectItem);
  Result := TryAddRADStudioEnvVariable(AInfo.Version, LibraryDirVariable, ExpandConstant('{app}'));
  if Result then
    _UpdateSourcePathsOfOtherPlatforms(AProjectItem.Project, AInfo, True);
end;

function _OnTryPrepareProjectUninstallation(var AProjectItem: TRADStudioGroupProjectItem; const AInfo: TRADStudioInfo): Boolean;
begin
  Log(Format('_OnTryPrepareProjectUninstallation: Preparing package "%s" to uninstall...', [AProjectItem.Project.FileName]));
  _UseLibraryDirVariable(AProjectItem);
  _UpdateSourcePathsOfOtherPlatforms(AProjectItem.Project, AInfo, False);
  Result := TryRemoveRADStudioEnvVariable(AInfo.Version, LibraryDirVariable);
  if not Result then
    Log(Format('_OnTryPrepareProjectUninstallation: Failed to prepare the project "%s"', [AProjectItem.Project.FileName]));
end;

function _IsShippedDemoFolder(const AName: string): Boolean;
begin
  Result := Pos('|' + Lowercase(AName) + '|', Lowercase('{#DemoFolders}')) > 0;
end;

/// <summary> Folders of ADemosDir that are not demos shipped with FMXER: projects of the user </summary>
function _GetUserFolders(const ADemosDir: string): TArrayOfString;
var
  LFindRec: TFindRec;
begin
  SetArrayLength(Result, 0);
  if FindFirst(AddBackslash(ADemosDir) + '*', LFindRec) then
  try
    repeat
      if ((LFindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0)
        and (LFindRec.Name <> '.') and (LFindRec.Name <> '..')
        and not _IsShippedDemoFolder(LFindRec.Name)
      then
        Result := AppendString(Result, LFindRec.Name, False);
    until not FindNext(LFindRec);
  finally
    FindClose(LFindRec);
  end;
end;

<event('CurUninstallStepChanged')>
procedure _CurUninstallStepChangedReportUserFolders(ACurUninstallStep: TUninstallStep);
var
  LFolders: TArrayOfString;
  LMessage: string;
  I: Integer;
begin
  if ACurUninstallStep <> usPostUninstall then
    Exit;
  LFolders := _GetUserFolders(ExpandConstant('{app}\demos'));
  if GetArrayLength(LFolders) = 0 then
    Exit;
  LMessage := '';
  for I := 0 to GetArrayLength(LFolders) - 1 do
    LMessage := LMessage + #13#10 + '  ' + ExpandConstant('{app}\demos\') + LFolders[I];
  Log('Folders not shipped with {#LibraryName} left in demos:' + LMessage);
  if not UninstallSilent then
    MsgBox('These folders are not part of {#LibraryName} and were not deleted:' + LMessage, mbInformation, MB_OK);
end;

<event('InitializeSetup')>
function _InitializeSetup: Boolean;
begin
  FOnBeforeProjectBuild := @_OnBeforeProjectBuild;
  FOnTryPrepareProjectInstallation := @_OnTryPrepareProjectInstallation;
  FOnTryPrepareProjectUninstallation := @_OnTryPrepareProjectUninstallation;
  Result := True;
end;

<event('InitializeUninstall')>
function _InitializeUninstall: Boolean;
begin
  FOnTryPrepareProjectUninstallation := @_OnTryPrepareProjectUninstallation;
  Result := True;
end;
