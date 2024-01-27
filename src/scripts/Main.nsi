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
    Var /GLOBAL logFile
    System::Call 'ole32::CoCreateGuid(g .s)'
    pop $logFile
    StrCpy $logFile "$TEMP\$logFile.log"
    LogEx::Init "true" $logFile
    DetailPrint "$logFile"

    ; Locate the FiveM directory
    Var /GLOBAL FiveMDir
    ReadRegStr $FiveMDir HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\CitizenFX_FiveM" "InstallLocation"
    ${If} $FiveMDir == ""
        !insertmacro LogAndPrint "Unable to locate the FiveM directory."
        MessageBox MB_ICONSTOP|MB_OK "Unable to locate the FiveM directory. Please ensure that FiveM is installed."
        Abort
    ${Else}
        !insertmacro LogAndPrint "FiveM directory located at: $FiveMDir"
    ${EndIf}

    InitPluginsDir
FunctionEnd

Section
    SetOutPath $PLUGINSDIR
    File ${HASHSTRINGEXE} ; This utility is required to hash the COMPUTERNAME for the ini file later

    Var /GLOBAL CitizenFXIni
    StrCpy $CitizenFXIni "$FiveMDir\FiveM.app\CitizenFX.ini"

    ExecWait '"$PLUGINSDIR\hash_string.exe" "$CitizenFXIni"'

    ; Locate GTA 5
    Var /GLOBAL IVPath
    ReadINIStr $IVPath "$CitizenFXIni" "Game" "IVPath"
    IfFileExists "$IVPath\*.*" +5 0
        MessageBox MB_ICONSTOP|MB_OK "Unable to locate GTA 5. Please ensure that GTA 5 is installed."
        !insertmacro LogAndPrint "Unable to locate GTA5: $IVPath"
        Abort

    !insertmacro LogAndPrint "GTA 5 location: $IVPath"

    ; Set the update channel to beta if needed
    ReadINIStr $0 "$CitizenFXIni" "Game" "UpdateChannel"
    ${If} $0 != "beta"
        MessageBox MB_ICONEXCLAMATION|MB_YESNO "FiveM is required to be in the beta update channel. Set this automatically?" IDYES +2
            Abort
        WriteINIStr "$CitizenFXIni" "Game" "UpdateChannel" "beta"
        !insertmacro LogAndPrint "FiveM's update channel has been set to beta."
    ${EndIf}

    ; Locate the plugins directory
    Var /GLOBAL FiveMPlugins
    StrCpy $FiveMPlugins "$FiveMDir\FiveM.app\plugins"
	IfFileExists "$FiveMPlugins\*" +2 0
        CreateDirectory "$FiveMPlugins"
    !insertmacro LogAndPrint "Target directory: $FiveMPlugins"

    CreateDirectory "$PLUGINSDIR\reshade"

    ; Download ReShade
    nscurl::http GET "https://reshade.me/downloads/ReShade_Setup_${RESHADE_VERSION}_Addon.exe" "$PLUGINSDIR\reshade\reshade.exe" /END
    Pop $R0 ; Status
    ${If} $R0 != "OK"
        !insertmacro LogAndPrint "Failed to download ReShade: $0"
        MessageBox MB_ICONSTOP|MB_OK "Failed to download ReShade: $R0"
        Abort
    ${EndIf}

    !insertmacro LogAndPrint "Getting ReShade files..."
    ExecWait '"$PLUGINSDIR\reshade\reshade.exe" --api ${GRAPHICSAPI} --headless "$PLUGINSDIR\reshade\reshade.exe"'
    Rename "$PLUGINSDIR\reshade\reshade.exe" "$PLUGINSDIR\reshade.exe"
    
    !insertmacro LogAndPrint "Installing ReShade..."
	ExecWait '"$PLUGINSDIR\reshade.exe" --api ${GRAPHICSAPI} "$IVPath\GTA5.exe"'

    ; Get all the file names in $PLUGINSDIR\reshade
    FindFirst $R1 $R2 "$PLUGINSDIR\reshade\*.*"
    loop:
        StrCmp $R2 "" done ; If no more files, we're done
        IfFileExists "$IVPath\$R2" 0 +4
            Rename "$IVPath\$R2" "$FiveMPlugins\$R2"
            !insertmacro LogAndPrint "Moving $R2"
        FindNext $R1 $R2
        GoTo loop
    done:
        FindClose $R1

    IfFileExists "$IVPath\reshade-shaders\*.*" 0 +2
        CopyFiles /SILENT "$IVPath\reshade-shaders\*.*" "$FiveMPlugins\reshade-shaders"

    RMDir /r "$IVPath\reshade-shaders"
SectionEnd