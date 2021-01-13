@ECHO OFF
SETLOCAL EnableDelayedExpansion

ECHO Sven Co-op custom resource bouncer
ECHO.



:config

SET DIR=%~dp0

PUSHD %DIR%
SET GAME_DIR_PATHNAME=%CD%
POPD

IF NOT "%~1" == "" (
	SET GAME_DIR_PATHNAME=%~1

	IF NOT EXIST "!GAME_DIR_PATHNAME!" (
		ECHO [Error] Game directory specified not found.
		GOTO end
	)
)

SET GAME_BASE_DIR_PATHNAME=!GAME_DIR_PATHNAME!\svencoop
FOR /F "delims=" %%i IN ("!GAME_BASE_DIR_PATHNAME!") DO SET GAME_BASE_DIR_NAME=%%~ni
SET GAME_ADDON_DIR_PATHNAME=!GAME_BASE_DIR_PATHNAME!_addon
FOR /F "delims=" %%i IN ("!GAME_ADDON_DIR_PATHNAME!") DO SET GAME_ADDON_DIR_NAME=%%~ni
SET GAME_DOWNLOADS_DIR_PATHNAME=!GAME_BASE_DIR_PATHNAME!_downloads
FOR /F "delims=" %%i IN ("!GAME_DOWNLOADS_DIR_PATHNAME!") DO SET GAME_DOWNLOADS_DIR_NAME=%%~ni

SET REPLACEMENT_RESOURCES_DIR_PATHNAME=%DIR%\resources

SET REPLACEMENT_PLAYER_MODEL_NAME=helmet
SET REPLACEMENT_PLAYER_MODEL_DIR_PATHNAME=!GAME_BASE_DIR_PATHNAME!\models\player\!REPLACEMENT_PLAYER_MODEL_NAME!

SET FILTER_PLAYER_MODELS_FILE_PATHNAME=!DIR!filter-player-models.txt
SET FILTER_SOUNDS_FILE_PATHNAME=!DIR!filter-sounds.txt



:information

ECHO Platform:                       Windows     (Obviously.)
ECHO.

ECHO Directory path names:
ECHO  - Tool                         !DIR!
ECHO  - Game                         !GAME_DIR_PATHNAME!
ECHO  - Base content                 !GAME_BASE_DIR_PATHNAME!
ECHO  - Add-on content               !GAME_ADDON_DIR_PATHNAME!
ECHO  - Downloaded content           !GAME_DOWNLOADS_DIR_PATHNAME!
ECHO.

ECHO Player model sub:               !REPLACEMENT_PLAYER_MODEL_NAME!
ECHO Player model filter:            !FILTER_PLAYER_MODELS_FILE_PATHNAME!
ECHO Sounds filter:                  !FILTER_SOUNDS_FILE_PATHNAME!
ECHO.


:preFlightChecks

IF NOT EXIST "!GAME_DIR_PATHNAME!\" (
	ECHO [Error] Game directory not found.
	GOTO end
)

IF NOT EXIST "!GAME_BASE_DIR_PATHNAME!\" (
	ECHO [Error] Game base directory not found.
	GOTO end
)

IF NOT EXIST "!GAME_BASE_DIR_PATHNAME!\liblist.gam" (
	ECHO [Error] Game base content directory invalid.
	GOTO end
)

IF NOT EXIST "!GAME_ADDON_DIR_PATHNAME!\..\!GAME_BASE_DIR_NAME!\liblist.gam" (
	ECHO [Error] Game add-on content directory invalid.
	GOTO end
)

IF NOT EXIST "!GAME_DOWNLOADS_DIR_PATHNAME!\" (
	ECHO [Info] Game downloaded content directory not found. It will be created.
	MD "!GAME_DOWNLOADS_DIR_PATHNAME!"

	IF NOT EXIST "!GAME_DOWNLOADS_DIR_PATHNAME!\" (
		ECHO [Error] Game downloaded content directory could not be created.
		GOTO end
	)
)

IF NOT EXIST "!GAME_DOWNLOADS_DIR_PATHNAME!\..\!GAME_BASE_DIR_NAME!\liblist.gam" (
	ECHO [Error] Game downloaded content directory invalid.
	GOTO end
)

IF NOT EXIST "!REPLACEMENT_PLAYER_MODEL_DIR_PATHNAME!\" (
	ECHO [Error] Replacement player model directory "!REPLACEMENT_PLAYER_MODEL_NAME!" not found.
	GOTO end
)

IF NOT EXIST "!REPLACEMENT_PLAYER_MODEL_DIR_PATHNAME!\!REPLACEMENT_PLAYER_MODEL_NAME!.mdl" (
	ECHO [Error] Replacement player model file "!REPLACEMENT_PLAYER_MODEL_NAME!" not found.
	GOTO end
)

IF NOT EXIST "!REPLACEMENT_PLAYER_MODEL_DIR_PATHNAME!\!REPLACEMENT_PLAYER_MODEL_NAME!.bmp" (
	ECHO [Warning] Replacement player model file "!REPLACEMENT_PLAYER_MODEL_NAME!" thumbnail not found.
)



:prepareResourceDirectories

ECHO.
ECHO Preparing resource directories...
ECHO.

IF NOT EXIST "!GAME_ADDON_DIR_PATHNAME!\models\player\" (
	MD "!GAME_ADDON_DIR_PATHNAME!\models\player"
)

IF NOT EXIST "!GAME_ADDON_DIR_PATHNAME!\sound\" (
	MD "!GAME_ADDON_DIR_PATHNAME!\sound"
)

IF NOT EXIST "!GAME_DOWNLOADS_DIR_PATHNAME!\models\player\" (
	MD "!GAME_DOWNLOADS_DIR_PATHNAME!\models\player"
)

IF NOT EXIST "!GAME_DOWNLOADS_DIR_PATHNAME!\sound\" (
	MD "!GAME_DOWNLOADS_DIR_PATHNAME!\sound"
)



:filterPlayerModels

ECHO.
ECHO Filtering player models...
ECHO.

SET FILTER_PLAYER_MODELS_FILE_SIZE=-1
IF EXIST "!FILTER_PLAYER_MODELS_FILE_PATHNAME!" (
	FOR /F "delims=" %%i IN ("!FILTER_PLAYER_MODELS_FILE_PATHNAME!") DO (
		SET FILTER_PLAYER_MODELS_FILE_SIZE=%%~zi
		IF NOT DEFINED FILTER_PLAYER_MODELS_FILE_SIZE SET FILTER_PLAYER_MODELS_FILE_SIZE=0
	)

	IF !FILTER_PLAYER_MODELS_FILE_SIZE! GTR 0 (
		ECHO Seems legit. -- Functionality TBD!
		FOR /F "usebackq tokens=*" %%L IN ("!FILTER_PLAYER_MODELS_FILE_PATHNAME!") DO (
			IF "%%L"=="" GOTO filterPlayerModelsForLineEnd

			ECHO %%L


			:filterPlayerModelsForLineEnd
			REM Equivalent of "CONTINUE" ^
		)
	) ELSE (
		ECHO [Warning] Player models filter file is empty.
	)
) ELSE (
	ECHO [Warning] Player models filter not found.
)



:filterSounds

ECHO.
ECHO Filtering sounds...
ECHO.

SET FILTER_SOUNDS_FILE_SIZE=-1
IF EXIST "!FILTER_SOUNDS_FILE_PATHNAME!" (
	FOR /F "delims=" %%i IN ("!FILTER_SOUNDS_FILE_PATHNAME!") DO (
		SET FILTER_SOUNDS_FILE_SIZE=%%~zi
		IF NOT DEFINED FILTER_SOUNDS_FILE_SIZE SET FILTER_SOUNDS_FILE_SIZE=0
	)

	IF !FILTER_SOUNDS_FILE_SIZE! GTR 0 (
		ECHO Seems legit. -- Functionality TBD!
		FOR /F "usebackq tokens=*" %%L IN ("!FILTER_SOUNDS_FILE_PATHNAME!") DO (
			IF "%%L"=="" GOTO filterSoundsForLineEnd

			ECHO %%L


			:filterSoundsForLineEnd
			REM Equivalent of "CONTINUE" ^
		)
	) ELSE (
		ECHO [Warning] Sounds filter file is empty.
	)
) ELSE (
	ECHO [Warning] Sounds filter file not found.
)



:end
