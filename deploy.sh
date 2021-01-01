#!/bin/bash

printf "Sven Co-op custom resource bouncer\n\n"



# Config

PLATFORM=""
case "$(uname -s)" in
	Darwin)
		PLATFORM=MacOS
	;;
	Linux)
		PLATFORM=Linux
	;;
	CYGWIN*|MINGW32*|MSYS*|MINGW*)
		PLATFORM=Windows
	;;
	*)
		printf "[Error] Platform \"$(uname -s)\" not supported.\n"
		exit 1
	;;
esac

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

GAME_DIR_PATHNAME=$(realpath "${DIR}/../..")
if [ -n "${1}" ] && [ ! -z "${1}" ]; then
	if [ ! -d "${1}" ]; then
		printf "[Error] Game directory specified not found.\n"
		exit 1
	fi

	GAME_DIR_PATHNAME=$(realpath "${1}")
fi

GAME_BASE_DIR_PATHNAME=$(realpath "${GAME_DIR_PATHNAME}/svencoop")
GAME_BASE_DIR_NAME=$(basename "${GAME_BASE_DIR_PATHNAME}")

GAME_ADDON_DIR_PATHNAME=$(realpath "${GAME_BASE_DIR_PATHNAME}_addon")
GAME_ADDON_DIR_NAME=$(basename "${GAME_ADDON_DIR_PATHNAME}")

GAME_DOWNLOADS_DIR_PATHNAME=$(realpath "${GAME_BASE_DIR_PATHNAME}_downloads")
GAME_DOWNLOADS_DIR_NAME=$(basename "${GAME_DOWNLOADS_DIR_PATHNAME}")

REPLACEMENT_RESOURCES_DIR_PATHNAME=$(realpath "${DIR}/resources")

REPLACEMENT_PLAYER_MODEL_NAME="helmet"
REPLACEMENT_PLAYER_MODEL_DIR_PATHNAME=$(realpath "${GAME_BASE_DIR_PATHNAME}/models/player/${REPLACEMENT_PLAYER_MODEL_NAME}")

FILTER_PLAYER_MODELS_FILE_PATHNAME=$(realpath "${DIR}/filter-player-models.txt")
FILTER_SOUNDS_FILE_PATHNAME=$(realpath "${DIR}/filter-sounds.txt")



# Information

printf "Platform:                       ${PLATFORM}\n"
printf "\n"

printf "Directory path names:\n"
printf " - Tool                         ${DIR}\n"
printf " - Game                         ${GAME_DIR_PATHNAME}\n"
printf " - Base content                 ${GAME_BASE_DIR_PATHNAME}\n"
printf " - Add-on content               ${GAME_ADDON_DIR_PATHNAME}\n"
printf " - Downloaded content           ${GAME_DOWNLOADS_DIR_PATHNAME}\n"
printf "\n"

printf "Player model sub:               ${REPLACEMENT_PLAYER_MODEL_NAME}\n"
printf "Player model filter:            ${FILTER_PLAYER_MODELS_FILE_PATHNAME}\n"
printf "Sounds filter:                  ${FILTER_SOUNDS_FILE_PATHNAME}\n"
printf "\n"



# Pre-flight checks

if [ ! -d "${GAME_DIR_PATHNAME}" ]; then
	printf "[Error] Game directory not found.\n"
	exit 1
fi

if [ ! -d "${GAME_BASE_DIR_PATHNAME}" ]; then
	printf "[Error] Game base directory not found.\n"
	exit 1
fi

if [ ! -f "${GAME_BASE_DIR_PATHNAME}/liblist.gam" ]; then
	printf "[Error] Game base content directory invalid.\n"
	exit 1
fi

if [ ! -f "${GAME_ADDON_DIR_PATHNAME}/../${GAME_BASE_DIR_NAME}/liblist.gam" ]; then
	printf "[Error] Game add-on content directory invalid.\n"
	exit 1
fi

if [ ! -d "${GAME_DOWNLOADS_DIR_PATHNAME}" ]; then
	printf "[Info] Game downloaded content directory not found. It will be created.\n"
	mkdir -p "${GAME_DOWNLOADS_DIR_PATHNAME}"

	if [ ! -d "${GAME_DOWNLOADS_DIR_PATHNAME}" ]; then
		printf "[Error] Game downloaded content directory could not be created.\n"
		exit 1
	fi
fi

if [ ! -f "${GAME_DOWNLOADS_DIR_PATHNAME}/../${GAME_BASE_DIR_NAME}/liblist.gam" ]; then
	printf "[Error] Game downloaded content directory invalid.\n"
	exit 1
fi

if [ ! -d "${REPLACEMENT_PLAYER_MODEL_DIR_PATHNAME}" ]; then
	printf "[Error] Replacement player model directory \"${REPLACEMENT_PLAYER_MODEL_NAME}\" not found.\n"
	exit 1
fi

if [ ! -f "${REPLACEMENT_PLAYER_MODEL_DIR_PATHNAME}/${REPLACEMENT_PLAYER_MODEL_NAME}.mdl" ]; then
	printf "[Error] Replacement player model file \"${REPLACEMENT_PLAYER_MODEL_NAME}\" not found.\n"
	exit 1
fi

if [ ! -f "${REPLACEMENT_PLAYER_MODEL_DIR_PATHNAME}/${REPLACEMENT_PLAYER_MODEL_NAME}.bmp" ]; then
	printf "[Warning] Replacement player model file \"${REPLACEMENT_PLAYER_MODEL_NAME}\" thumbnail not found.\n"
fi



# Prepare resource directories

printf "\nPreparing resource directories...\n\n"

if [ ! -d "${GAME_ADDON_DIR_PATHNAME}/models/player" ]; then
	mkdir -p "${GAME_ADDON_DIR_PATHNAME}/models/player"
fi

if [ ! -d "${GAME_ADDON_DIR_PATHNAME}/sound" ]; then
	mkdir -p "${GAME_ADDON_DIR_PATHNAME}/sound"
fi

if [ ! -d "${GAME_DOWNLOADS_DIR_PATHNAME}/models/player" ]; then
	mkdir -p "${GAME_DOWNLOADS_DIR_PATHNAME}/models/player"
fi

if [ ! -d "${GAME_DOWNLOADS_DIR_PATHNAME}/sound" ]; then
	mkdir -p "${GAME_DOWNLOADS_DIR_PATHNAME}/sound"
fi



# Filter player models

printf "\nFiltering player models...\n\n"

if [ -f "${FILTER_PLAYER_MODELS_FILE_PATHNAME}" ]; then
	if [ -s "${FILTER_PLAYER_MODELS_FILE_PATHNAME}" ]; then
		while read FILTER_PLAYER_MODEL_NAME; do
			FILTER_PLAYER_MODEL_NAME=$(sed 's/\r$//' <<< $FILTER_PLAYER_MODEL_NAME)
			if [ ! -n "${FILTER_PLAYER_MODEL_NAME}" ] || [ -z "${FILTER_PLAYER_MODEL_NAME}" ]; then
				continue
			fi

			printf "${FILTER_PLAYER_MODEL_NAME}:\n"

			FILTER_PLAYER_MODEL_ADDON_DIR_PATHNAME=$(realpath "${GAME_ADDON_DIR_PATHNAME}/models/player/${FILTER_PLAYER_MODEL_NAME}")
			FILTER_PLAYER_MODEL_DOWNLOADS_DIR_PATHNAME=$(realpath "${GAME_DOWNLOADS_DIR_PATHNAME}/models/player/${FILTER_PLAYER_MODEL_NAME}")

			if [ -d "${FILTER_PLAYER_MODEL_DOWNLOADS_DIR_PATHNAME}" ]; then
				printf " - Deleting directory from downloads.\n"
				rm -rf "${FILTER_PLAYER_MODEL_DOWNLOADS_DIR_PATHNAME}"
			fi

			if [ "${PLATFORM}" == "Windows" ]; then
				if [ ! -d "${FILTER_PLAYER_MODEL_ADDON_DIR_PATHNAME}" ]; then
					mkdir -p "${FILTER_PLAYER_MODEL_ADDON_DIR_PATHNAME}"
				fi

				find "${REPLACEMENT_PLAYER_MODEL_DIR_PATHNAME}" -type f | sort | while read REPLACEMENT_PLAYER_MODEL_FILE_PATHNAME; do
					cp "${REPLACEMENT_PLAYER_MODEL_FILE_PATHNAME}" "${FILTER_PLAYER_MODEL_ADDON_DIR_PATHNAME}/"
				done
			else
				ln -s "${REPLACEMENT_PLAYER_MODEL_FILE_PATHNAME}" "${FILTER_PLAYER_MODEL_ADDON_DIR_PATHNAME}"
			fi

			printf " - Filter installed.\n"
		done < "${FILTER_PLAYER_MODELS_FILE_PATHNAME}"
	else
		printf "[Warning] Player models filter file is empty.\n"
	fi
else
	printf "[Warning] Player models filter file not found.\n"
fi



# Filter sounds

printf "\nFiltering sounds...\n\n"

if [ -f "${FILTER_SOUNDS_FILE_PATHNAME}" ]; then
	if [ -s "${FILTER_SOUNDS_FILE_PATHNAME}" ]; then
		while read FILTER_SOUND_NAME; do
			FILTER_SOUND_NAME=$(sed 's/\r$//' <<< $FILTER_SOUND_NAME)
			if [ ! -n "${FILTER_SOUND_NAME}" ] || [ -z "${FILTER_SOUND_NAME}" ]; then
				continue
			fi

			printf "${FILTER_SOUND_NAME}:\n"

			FILTER_SOUND_DOWNLOADS_PATHNAME=$(realpath "${GAME_DOWNLOADS_DIR_PATHNAME}/sound/${FILTER_SOUND_NAME}")
			declare -a FILTER_SOUND_REPLACEMENT_FILE_PATHNAMES

			if [ -d "${FILTER_SOUND_DOWNLOADS_PATHNAME}" ]; then
				while read FILTER_SOUND_DOWNLOADS_SUBITEM_PATHNAME; do
					FILTER_SOUND_REPLACEMENT_FILE_PATHNAMES+=( "${FILTER_SOUND_DOWNLOADS_SUBITEM_PATHNAME}" )
					#printf " - Detected file to filter: ${FILTER_SOUND_DOWNLOADS_SUBITEM_PATHNAME}\n"
				done < <(find "${FILTER_SOUND_DOWNLOADS_PATHNAME}" -type f | sort)
			elif [ -f "${FILTER_SOUND_DOWNLOADS_PATHNAME}" ]; then
				FILTER_SOUND_REPLACEMENT_FILE_PATHNAMES+=( "${FILTER_SOUND_DOWNLOADS_PATHNAME}" )
				#printf " - Detected file to filter: ${FILTER_SOUND_DOWNLOADS_PATHNAME}\n"
			else
				if [ "${FILTER_SOUND_NAME: -1}" != "/" ]; then
					FILTER_SOUND_REPLACEMENT_FILE_PATHNAMES+=( "${FILTER_SOUND_DOWNLOADS_PATHNAME}" )
				fi
				#printf " - No downloaded directory or file detected to filter.\n"
			fi

			if [ "${FILTER_SOUND_NAME: -1}" == "/" ]; then
				if [ ! -d "${FILTER_SOUND_DOWNLOADS_PATHNAME}" ]; then
					mkdir -p "${FILTER_SOUND_DOWNLOADS_PATHNAME}"
				fi
			else
				if [ ! -f "${FILTER_SOUND_DOWNLOADS_PATHNAME}" ]; then
					mkdir -p $(dirname "${FILTER_SOUND_DOWNLOADS_PATHNAME}")
				fi
			fi

			for FILTER_SOUND_REPLACEMENT_PATHNAME in "${FILTER_SOUND_REPLACEMENT_FILE_PATHNAMES[@]}"; do
				if [ -f "${FILTER_SOUND_REPLACEMENT_PATHNAME}" ]; then
					if [ -s "${FILTER_SOUND_REPLACEMENT_PATHNAME}" ]; then
						rm -f "${FILTER_SOUND_REPLACEMENT_PATHNAME}"
						touch "${FILTER_SOUND_REPLACEMENT_PATHNAME}"

						printf " - Filter installed: ${FILTER_SOUND_REPLACEMENT_PATHNAME}\n"
					else
						printf " - Filter already installed: ${FILTER_SOUND_REPLACEMENT_PATHNAME}\n"
					fi
				else
					touch "${FILTER_SOUND_REPLACEMENT_PATHNAME}"
					printf " - Filter pre-emptively installed: ${FILTER_SOUND_REPLACEMENT_PATHNAME}\n"
				fi
			done
		done < "${FILTER_SOUNDS_FILE_PATHNAME}"
	else
		printf "[Warning] Sounds filter file is empty.\n"
	fi
else
	printf "[Warning] Sounds filter file not found.\n"
fi



# Finished

exit 0
