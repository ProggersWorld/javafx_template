@echo off
set APP_NAME=JavaFX_Template
set MAIN_CLASS=org.proggersworld.javafx_template.App 
set ICON=src\main\resources\icons\app.ico
set INSTALLER_TYPE=exe
set OS_NAME=windows
set OUT_DIR=releases
set VENDOR=Proggersworld
set LICENSE=LICENSE.txt

rem Read the version from the pom.xml file.
rem The line below doesn't work with Windows. Not with cmd nor with PowerShell.
rem for /f %%v in ('mvn help:evaluate -Dexpression=project.version -q -DforceStdout') do set VERSION=%%v

rem As long there is no way to let it work, we take the hardcoded way.
set VERSION=0.0.1

if not exist %OUT_DIR% (
  mkdir %OUT_DIR%
)

echo ===========================================
echo Building installer for %OS_NAME% (%INSTALLER_TYPE%), version %VERSION%...
echo ===========================================

rem Maven Build starten
call mvn -q -DskipTests clean package

rem Search for the FatJar.
set MAIN_JAR=%APP_NAME%-%VERSION%-shaded.jar

if not exist target\%MAIN_JAR% (
  echo ERROR: Shaded JAR target\%MAIN_JAR% not found!
  exit /b 1
)

rem Build the runtime, if not exists.
if not exist target\runtime (
  echo No cached runtime found, building new runtime...
  "%JAVA_HOME%\bin\jlink.exe" ^
    --module-path "%JAVA_HOME%\jmods" ^
    --add-modules java.base,java.sql,javafx.controls ^
    --strip-debug --no-header-files --no-man-pages ^
    --output target\runtime
) else (
  echo Reusing cached runtime from target\runtime
)

rem Build the installer.
"%JAVA_HOME%\bin\jpackage.exe" ^
  --name %APP_NAME% ^
  --app-version %VERSION% ^
  --input target ^
  --main-jar %MAIN_JAR% ^
  --main-class %MAIN_CLASS% ^
  --type %INSTALLER_TYPE% ^
  --runtime-image target\runtime ^
  --icon %ICON% ^
  --dest %OUT_DIR% ^
  --vendor "%VENDOR%" ^
  --license-file %LICENSE% ^
  --win-shortcut ^
  --win-menu ^
  --win-menu-group "%APP_NAME%" ^
  --win-dir-chooser

rem Rename the installer file.
for %%f in (%OUT_DIR%\%APP_NAME%*) do (
    ren "%%f" "%APP_NAME%-%VERSION%-install.%INSTALLER_TYPE%"
)

echo Installer created: %OUT_DIR%\%APP_NAME%-%VERSION%-install.%INSTALLER_TYPE%
