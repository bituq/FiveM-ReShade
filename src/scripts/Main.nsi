SetCompressor /SOLID lzma
Unicode true

!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "ModernUI.nsh"
!include "x64.nsh"

InstType "full"
Name "${NAME}"
Caption "$(^Name) Installation"
OutFile "../../output/setup.exe"
BrandingText "${MANUFACTURER}"

Function .onInit
    Var /GLOBAL logFile
    System::Call 'ole32::CoCreateGuid(g .s)'
    pop $logFile
    StrCpy $logFile "$TEMP\$logFile.log"
    LogEx::Init "true" $logFile

    IfFileExists "${APPDIR}\CitizenFX.ini" +3 0
        MessageBox MB_ICONEXCLAMATION|MB_OK "FiveM directory not found. Please ensure that it is installed."
        Abort

    InitPluginsDir
FunctionEnd

Section
    SetOutPath $PLUGINSDIR
    File "..\..\hash_string\target\release\hash_string.exe"

    DetailPrint "$PLUGINSDIR"

    ExecWait '"$PLUGINSDIR\hash_string.exe" "${APPDIR}\CitizenFX.ini"'

    ReadINIStr $0 "${APPDIR}\CitizenFX.ini" "Game" "IVPath"
    StrCpy $0 "$0"
    DetailPrint "IVPath is: $0"

    WriteINIStr "${APPDIR}\CitizenFX.ini" "Game" "UpdateChannel" "beta"

	IfFileExists "${TARGETDIR}\*" +2
        CreateDirectory "${TARGETDIR}"
    LogEx::Write "Target directory: ${TARGETDIR}"

    nscurl::http GET "https://reshade.me/downloads/ReShade_Setup_${RESHADE_VERSION}_Addon.exe" "${TARGETDIR}\reshade.exe" /END
    Pop $R0
    ${If} $R0 != "OK"
        MessageBox MB_ICONSTOP "Download failed: $R0"
        Abort
    ${EndIf}

	ExecWait '"${TARGETDIR}\reshade.exe" --api ${RENDERAPI} "$0\GTA5.exe"'
    DetailPrint "$0\${RENDERAPI}.dll ${TARGETDIR}"

    Rename "$0\${RENDERAPI}.dll" "${TARGETDIR}\${RENDERAPI}.dll"
    Rename "$0\ReShade.ini" "${TARGETDIR}\ReShade.ini"
    Rename "$0\ReShade.log" "${TARGETDIR}\ReShade.log"
    Rename "$0\ReShadePreset.ini" "${TARGETDIR}\ReShadePreset.ini"
    CopyFiles /SILENT "$0\reshade-shaders" "${TARGETDIR}\reshade-shaders"
    RMDir /r "$0\reshade-shaders"
	Delete "${TARGETDIR}\reshade.exe"
SectionEnd