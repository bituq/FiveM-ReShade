!include "MUI2.nsh"
!include "Config.nsh"

!define MUI_WELCOMEPAGE_TITLE "FiveM Reshade Installation"
!define MUI_WELCOMEPAGE_TEXT "This will install Reshade ${RESHADE_VERSION} to FiveM."
!insertmacro MUI_PAGE_WELCOME

!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_TEXT "Reshade has now been installed to FiveM.$\n$\nThe changes will be in effect next time you launch the application."

!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"