; example2.nsi
;
; This script is based on example1.nsi, but it remember the directory, 
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects,

;--------------------------------

!define APP "OpenUNC"
!define COM "HIRAOKA HYPERS TOOLS, Inc."
!define VER "0.1"
!define APV "0_1"

; The name of the installer
Name "${APP} ${VER}"

; The file to write
OutFile "Setup_${APP}_${APV}.exe"

; The default installation directory
InstallDir "$PROGRAMFILES\${APP}"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\${COM}\${APP}" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

!include 'LogicLib.nsh'
!include 'nsProcess.nsh'

;--------------------------------

; Pages

Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section ""

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File "bin\DEBUG\OpenUNC.exe"
  
  WriteRegStr HKCR "unc" "" "URL:UNC Path Protocol"
  WriteRegStr HKCR "unc" "URL Protocol" "URL:UNC Path Protocol"

  WriteRegStr HKCR "unc\shell\open\command" "" '"$INSTDIR\OpenUNC.exe" %1 %*'
  
  StrCpy $0 "$LOCALAPPDATA\Google\Chrome\User Data\Local State"
  ${If} ${FileExists} $0
Retry:
    ${nsProcess::FindProcess} "chrome.exe" $1
    ${If} $1 == "0"
      MessageBox MB_ICONEXCLAMATION|MB_YESNOCANCEL "ChromeÇèIóπÇµÇƒÇ≠ÇæÇ≥Ç¢ÅB" IDYES Retry IDNO Ignore
      Abort "íÜé~ÇµÇ‹ÇµÇΩÅB"
Ignore:
    ${EndIf}
  
    nsJSON::Set               /file $0
    nsJSON::Set `protocol_handler` `excluded_schemes` `unc` /value `false`
    nsJSON::Serialize /format /file $0
  ${EndIf}

  ; Write the installation path into the registry
  WriteRegStr HKLM "Software\${COM}\${APP}" "Install_Dir" "$INSTDIR"
  WriteRegStr HKLM "Software\${COM}\${APP}" "Ver" "${VER}"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "DisplayName" "${APP} ${VER}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove files and uninstaller
  Delete "$INSTDIR\OpenUNC.exe"
  Delete "$INSTDIR\uninstall.exe"
  
  DeleteRegKey HKCR "unc\shell\open\command"
  DeleteRegKey HKCR "unc\shell\open"
  DeleteRegKey HKCR "unc\shell"
  DeleteRegKey HKCR "unc"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}"
  DeleteRegKey HKLM "Software\${COM}\${APP}"

  ; Remove directories used
  RMDir "$SMPROGRAMS\${APP}"
  RMDir "$INSTDIR"

SectionEnd
