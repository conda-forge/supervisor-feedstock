@echo on
bash -eux build.sh
if errorlevel 1 exit /b 1
