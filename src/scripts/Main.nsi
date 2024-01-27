SetCompressor /SOLID lzma
Unicode true

!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "ModernUI.nsh"
!include "x64.nsh"
!include "Log.nsh"

InstType "full"
Name "${NAME}"
Caption "$(^Name) Installation"
OutFile "../../output/setup.exe"
BrandingText "${MANUFACTURER}"

Function .onInit
    ; Initialize the log file
    System::Call 'ole32::CoCreateGuid(g .s)'
    pop $0
    LogEx::Init "true" "$TEMP\$0.log"
    DetailPrint "$TEMP\$0.log"

    ; Locate the FiveM directory
    ReadRegStr $0 HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\CitizenFX_FiveM" "InstallLocation"
    ${If} $0 == ""
        !insertmacro LogAndPrint "Unable to locate the FiveM directory."
        MessageBox MB_ICONSTOP|MB_OK "Unable to locate the FiveM directory. Please ensure that FiveM is installed." /SD IDOK
        Quit
    ${Else}
        !insertmacro LogAndPrint "FiveM directory located at: $0"
    ${EndIf}

    InitPluginsDir
FunctionEnd

Section
    SetOutPath $PLUGINSDIR
    File ${HASHSTRINGEXE}

    ; Locate GTA 5
    ReadINIStr $0 "$0\FiveM.app\CitizenFX.ini" "Game" "IVPath"
    IfFileExists "$0\*.*" +3
        !insertmacro LogAndPrint "GTA 5 location: $0"
    MessageBox MB_ICONSTOP|MB_OK "Unable to locate GTA 5. Please ensure that GTA 5 is installed." /SD IDOK
    Quit

    ; Set the update channel to beta if needed
    ReadINIStr $1 "$0\FiveM.app\CitizenFX.ini" "Game" "UpdateChannel"
    ${If} $1 != "beta"
        MessageBox MB_ICONEXCLAMATION|MB_YESNO "FiveM is required to be in the beta update channel. Set this automatically?" /SD IDYES
        WriteINIStr "$0\FiveM.app\CitizenFX.ini" "Game" "UpdateChannel" "beta"
        !insertmacro LogAndPrint "FiveM's update channel has been set to beta."
    ${EndIf}

    ; Ensure the plugins directory exists
    StrCpy $1 "$0\FiveM.app\plugins"
    IfFileExists "$1\*" +2
        CreateDirectory "$1"
    !insertmacro LogAndPrint "Target directory: $1"

    CreateDirectory "$PLUGINSDIR\reshade"

    ; Download ReShade
    nscurl::http GET "https://reshade.me/downloads/ReShade_Setup_${RESHADE_VERSION}_Addon.exe" "$PLUGINSDIR\reshade\reshade.exe" /END
    Pop $R0
    ${If} $R0 != "OK"
        !insertmacro LogAndPrint "Failed to download ReShade: $R0"
        MessageBox MB_ICONSTOP|MB_OK "Failed to download ReShade: $R0" /SD IDOK
        Quit
    ${EndIf}

    !insertmacro LogAndPrint "Installing ReShade..."
    ExecWait '"$PLUGINSDIR\reshade\reshade.exe" --api ${GRAPHICSAPI} "$PLUGINSDIR\reshade\reshade.exe"'
    Delete "$PLUGINSDIR\reshade\${GRAPHICSAPI}.dll"
    nsisunz::UnzipToLog /file "ReShade64.dll" "$PLUGINSDIR\reshade\reshade.exe" "$PLUGINSDIR\reshade"
    Rename "$PLUGINSDIR\reshade\ReShade64.dll" "$PLUGINSDIR\reshade\${GRAPHICSAPI}.dll"
    Delete "$PLUGINSDIR\reshade\reshade.exe"

    ; Copy all the files from reshade directory to plugins directory
    FindFirst $R1 $R2 "$PLUGINSDIR\reshade\*.*"
    loop:
        StrCmp $R2 "" done
        CopyFiles "$PLUGINSDIR\reshade\$R2" "$1\$R2"
        !insertmacro LogAndPrint "Moving $R2"
        FindNext $R1 $R2
        GoTo loop
    done:
        FindClose $R1

    ; Copy reshade-shaders folder if it exists
    IfFileExists "$PLUGINSDIR\reshade\reshade-shaders\*.*" +2
        CopyFiles /SILENT "$PLUGINSDIR\reshade\reshade-shaders\*.*" "$1\reshade-shaders"
SectionEnd
