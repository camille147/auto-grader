#!/bin/bash

CSV_FILE="note.csv"
GRADE=0
FIRST_NAME=""
LAST_NAME=""

check_student_project() {

	if [ ! -f "main.c" ] || [ ! -f "Makefile" ] || [ ! -f "header.h" ] || [ ! -f "readme.txt" ]; then
		echo "il manque un fichier au dossier de l'étudiant"
		exit 1
	fi
	echo "dossier ok"
}

create_grades_csv() {
	if [ ! -f "${CSV_FILE}" ]; then
		echo "Nom,Prénom,Note" > "${CSV_FILE}"
		echo "fichier note.csv crée"
	fi
}

check_and_play_student_program() {
	if find . -name "Makefile"; then
		echo "lancement du makefile"
		make all
		./factorielle 5
		echo "executable lancé avec succès."
	else
		echo "Le projet ne dispose pas de fichier Makefile"
	fi
}

check_factorial() {
	if [ "$number" -ge 1 -a "$number" -le 10 ]; then
		echo "C'est une factoriel entre 1 et 10"
	else
		echo "Ce n'est pas une factoriel"
	fi
}

recover_informations() {
	read -r line < readme.txt
	if [[ "${line}" =~ ^([^\ ]+)\ (.*)$ ]]; then
		FIRST_NAME="${BASH_REMATCH[1]}"
		LAST_NAME="${BASH_REMATCH[2]}"
	fi
}

indentations() {
	local indent_step=2

    while [ "$#" -gt 0 ]; do
        local file="$1"
        local current_level=0
        local line_number=0

        echo "🔍 Vérification de l'indentation dans : $file"

        while IFS= read -r line; do
            ((line_number++))


            [[ -z "$line" ]] && continue

            local trimmed_line="${line#"${line%%[![:space:]]*}"}"
            local actual_spaces=$(( ${#line} - ${#trimmed_line} ))
            local expected_spaces=$((current_level * indent_step))

            if [ "$actual_spaces" -ne "$expected_spaces" ]; then
                echo "❌ Ligne $line_number : indentation incorrecte (attendu: $expected_spaces, trouvé: $actual_spaces)"
            
            fi
            [[ "$trimmed_line" == "}"* ]] && ((current_level--))
            ((current_level < 0)) && current_level=0

            
            [[ "$trimmed_line" == *"{"* ]] && ((current_level++))

        done < "$file"

        shift
    done
}

number_caracter() {
	while [ "$#" -gt 0 ]; 
	do
		line_number=1

		while IFS= read -r line
		do
			l=`printf "%s" "$line" | wc -c`
			if [ "${l}" -gt 80 ]; then
				GRADE=$((GRADE - 2))
				echo "Une ligne fait plus de 80 caractères ${l} dans ${1} "
				return 0
			fi
			line_number=$((line_number + 1))
		done < "$1"
		shift
	done
}

main() {
	check_student_project
	create_grades_csv
	check_and_play_student_program
	recover_informations
	number_caracter "main.c" "header.h"
	indentations "main.c" "header.h"
	echo "${GRADE}"
}
main "${@}"
