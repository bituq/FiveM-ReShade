!include "MUI2.nsh"
!include "Config.nsh"

!define MUI_WELCOMEPAGE_TITLE "Welcome to the FiveM Reshade Installer"
!define MUI_WELCOMEPAGE_TEXT "This installer will guide you through the process of installing Reshade ${RESHADE_VERSION} for FiveM."

!insertmacro MUI_PAGE_WELCOME

!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_TEXT "The installation of Reshade ${RESHADE_VERSION} for FiveM is now complete.$\n$\nThe enhancements will be applied the next time you start the game."

!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"
