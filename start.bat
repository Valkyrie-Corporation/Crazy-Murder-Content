echo OFF

goto(){
# Linux code here
echo "The Script work only on Windows environment"
exit 0
}

goto $@
exit

:(){
call gmod-content-installer.bat
exit