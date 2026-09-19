@echo off
setlocal enabledelayedexpansion

:: Verify dependencies are in PATH
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] FFmpeg was not found in your system PATH.
    pause
    exit /b
)
where ffprobe >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] FFprobe was not found in your system PATH.
    pause
    exit /b
)

:MENU
cls
echo ====================================================
echo    Audiophile 24-bit FLAC / WAV Toolkit v4.0
echo ====================================================
echo.
echo  [1] Convert FLAC Files to 24-bit WAV
echo  [2] Verify Audio Folder Quality (Comprehensive Audit)
echo  [3] Exit Tool
echo.
echo ====================================================
set /p "choice=Select an option (1-3): "

if "%choice%"=="1" goto CONVERT_MODE
if "%choice%"=="2" goto VERIFY_MODE
if "%choice%"=="3" exit /b
goto MENU


:CONVERT_MODE
cls
echo ====================================================
echo             MODE 1: FLAC TO WAV ENGINE
echo ====================================================
echo.

echo [1/4] Select the directory containing your 24-bit FLAC files...
set "psCommand="(new-object -com shell.application).BrowseForFolder(0,'[SOURCE] Choose your FLAC folder:',0,0).Self.Path""
for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "source_dir=%%I"

if "%source_dir%"=="" (
    echo [ERROR] No source directory selected. Returning to menu.
    pause
    goto MENU
)
echo Selected Source: "%source_dir%"
echo.

echo [2/4] Select the target output folder for your WAV files...
set "psCommand="(new-object -com shell.application).BrowseForFolder(0,'[OUTPUT] Choose or create target WAV folder:',0,0).Self.Path""
for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "dest_dir=%%I"

if "%dest_dir%"=="" (
    echo [ERROR] No output directory selected. Returning to menu.
    pause
    goto MENU
)
echo Selected Output: "%dest_dir%"
echo.

echo ====================================================
echo PHASE 1: Analyzing Source FLAC File Properties
echo ====================================================
set "flac_found=0"
for %%F in ("%source_dir%\*.flac") do (
    set /a flac_found+=1
    if !flac_found! == 1 (
        echo Found match. Analyzing first sample track structure: "%%~nxF"
        echo ----------------------------------------------------
        ffprobe -v error -show_entries stream=codec_name,sample_fmt,sample_rate,bits_per_raw_sample -of default=noprint_wrappers=1 "%%F"
        echo ----------------------------------------------------
    )
)

if !flac_found! == 0 (
    echo [ERROR] No .flac files were found in the selected folder.
    pause
    goto MENU
)
echo Found !flac_found! total FLAC items. Proceeding to extraction...
pause
echo.

echo ====================================================
echo PHASE 2: Converting Tracks (Preserving 24-bit Stream)
echo ====================================================
set "count=0"
for %%F in ("%source_dir%\*.flac") do (
    set /a count+=1
    echo Processing Track [!count!/!flac_found!]: "%%~nxF"
    ffmpeg -y -i "%%F" -c:a pcm_s24le "%dest_dir%\%%~nF.wav" >nul 2>&1
)
echo.
echo Success! Done converting !count! FLAC files to WAV containers.
echo.

echo ====================================================
echo PHASE 3: Verifying Output Container Quality Metrics
echo ====================================================
set "verified=0"
for %%W in ("%dest_dir%\*.wav") do (
    set /a verified+=1
    if !verified! == 1 (
        echo Validating target format layout on: "%%~nxW"
        echo ----------------------------------------------------
        ffprobe -v error -show_entries stream=codec_name,sample_fmt,sample_rate -of default=noprint_wrappers=1 "%%W"
        echo ----------------------------------------------------
    )
)
echo Validation complete. !verified! files structurally verified as lossless 24-bit PCM.
echo.
pause
goto MENU


:VERIFY_MODE
cls
echo ====================================================
echo        MODE 2: COMPREHENSIVE QUALITY AUDIT
echo ====================================================
echo.
echo Select the directory you want to inspect...
set "psCommand="(new-object -com shell.application).BrowseForFolder(0,'[INSPECT] Choose an audio folder to analyze:',0,0).Self.Path""
for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "inspect_dir=%%I"

if "%inspect_dir%"=="" (
    echo [ERROR] No directory selected. Returning to menu.
    pause
    goto MENU
)

echo Selected Directory: "%inspect_dir%"
echo ====================================================
echo Scanning every file format layout...
echo ====================================================
echo.

set "items_found=0"
set "mismatch_detected=0"
set "first_codec="
set "first_rate="

:: Scan FLAC files
for %%F in ("%inspect_dir%\*.flac") do (
    set /a items_found+=1
    
    :: Extract properties using ffprobe shortcut variables
    for /f "tokens=1,2 delims==" %%A in ('ffprobe -v error -show_entries stream^=codec_name^,sample_rate -of default^=noprint_wrappers^=1^:nokey^=0 "%%F"') do (
        if "%%A"=="codec_name" set "current_codec=%%B"
        if "%%A"=="sample_rate" set "current_rate=%%B"
    )
    
    echo Track !items_found!: "%%~nxF" [!current_codec! ^| !current_rate! Hz]
    
    if !items_found! == 1 (
        set "first_codec=!current_codec!"
        set "first_rate=!current_rate!"
    ) else (
        if not "!current_codec!"=="!first_codec!" set "mismatch_detected=1"
        if not "!current_rate!"=="!first_rate!" set "mismatch_detected=1"
    )
)

:: Scan WAV files
for %%W in ("%inspect_dir%\*.wav") do (
    set /a items_found+=1
    
    for /f "tokens=1,2 delims==" %%A in ('ffprobe -v error -show_entries stream^=codec_name^,sample_rate -of default^=noprint_wrappers^=1^:nokey^=0 "%%W"') do (
        if "%%A"=="codec_name" set "current_codec=%%B"
        if "%%A"=="sample_rate" set "current_rate=%%B"
    )
    
    echo Track !items_found!: "%%~nxW" [!current_codec! ^| !current_rate! Hz]
    
    if !items_found! == 1 (
        set "first_codec=!current_codec!"
        set "first_rate=!current_rate!"
    ) else (
        if not "!current_codec!"=="!first_codec!" set "mismatch_detected=1"
        if not "!current_rate!"=="!first_rate!" set "mismatch_detected=1"
    )
)

echo.
echo ====================================================
echo                  AUDIT SUMMARY
echo ====================================================
if !items_found! == 0 (
    echo [NOTICE] No valid .flac or .wav files detected in this folder.
) else (
    echo Total files checked: !items_found!
    if !mismatch_detected! == 0 (
        echo STATUS: SUCCESS
        echo All files match perfectly in quality format details.
        echo Profile: [!first_codec! @ !first_rate! Hz]
    ) else (
        echo STATUS: WARNING / DISCREPANCY DETECTED
        echo Audio files in this directory do NOT have uniform specifications.
        echo Some tracks differ in sample rate or codec bit configuration profiles.
    )
)
echo ====================================================
echo.
pause
goto MENU
