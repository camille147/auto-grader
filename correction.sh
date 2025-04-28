#!/bin/bash

CSV_FILE="note.csv"
GRADE=0
FIRST_NAME=""
LAST_NAME=""

check_student_project() {

        if [ ! -f "main.c" ] || [ ! -f "Makefile" ] || [ ! -f "readme.txt" ]; then
                echo "il manque un fichier au dossier de l'étudiant"
                exit 1
        fi

        if ! find . -maxdepth 1 -name "*.h" | grep -q .; then
                echo "il manque un fichier header au dossier de l'étudiant. Il perd 2 points"
                GRADE=$((GRADE - 2))
        fi

        echo "dossier ok"
}

create_grades_csv() {
	if [ ! -f "${CSV_FILE}" ]; then
		echo "Nom,Prénom,Note" > "${CSV_FILE}"
		echo "fichier note.csv crée"
	fi
}

check_and_create_executable() {
        make all > /dev/null

	if ! find . -name "factorielle" -print -quit | grep -q .; then
		GRADE=0
		exit 1
	else
		GRADE=$((GRADE + 2))
	fi
}

check_syntax_factorielle() {
	while IFS= read -r line; do
		if echo "$line" | grep -qE "^\s*int factorielle\s*\( int number \)\s*\r?$"; then
			GRADE=$((GRADE + 2))
			break
		fi
	done < main.c
}

check_factorial() {
	good_answer=(1 2 6 24 120 720 5040 40320 362880 3628800)

	if ! find . -maxdepth 1 -name "*.h" | grep -q .; then
		echo "le dossier élève ne contient pas de header.h . Le dossier n'est pas configurez pour fonctionner sans."
	fi

	for ((i=1; i<10; i++)) do
		if [ $(./factorielle "$i") -ne "${good_answer[$((i - 1))]}" ]; then
			echo "Les factorisation de 1 à 10 ne sont pas bonnes"
			break
		fi
	done

	if [ $(./factorielle 0) -eq 1 ]; then
		GRADE=$((GRADE + 5))
	fi
}

recover_informations() {
	read -r line < readme.txt
	if [[ "${line}" =~ ^([^\ ]+)\ (.*)$ ]]; then
		FIRST_NAME="${BASH_REMATCH[1]}"
		LAST_NAME="${BASH_REMATCH[2]}"
	fi
}

add_to_csv() {
	echo "${LAST_NAME},${FIRST_NAME},${GRADE}" >> ${CSV_FILE}
}

indentations() {
    local indent_step=2
    local line_number=0

    for file in "$@"; do
        echo "🔍 Vérification de l'indentation dans : $file"
        local current_level=0

        while IFS= read -r line || [ -n "$line" ]; do
            ((line_number++))

            if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
                continue
            fi

            local trimmed_line="${line#"${line%%[![:space:]]*}"}"
            local actual_spaces=$(( ${#line} - ${#trimmed_line} ))

            #si la ligne est une accolade fermante seule
            if [[ "$trimmed_line" == "}"* ]]; then
                ((current_level--))
                ((current_level < 0)) && current_level=0
            fi

            local expected_spaces=$((current_level * indent_step))

            #déclaration de fonction au début
            if [[ "$trimmed_line" =~ ^int\ (factorielle|main)\  ]]; then
                expected_spaces=0
            fi

            if [ "$actual_spaces" -ne "$expected_spaces" ]; then
                echo "$line_number : indentation incorrecte (attendu: $expected_spaces, trouvé: $actual_spaces)"
                GRADE=$((GRADE - 2))
                return
            fi

            #si la ligne est une accolade ouvrante seule
            if [[ "$trimmed_line" == "{"* ]]; then
                ((current_level++))
            fi

        done < "$file"

        current_level=0
        line_number=0
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

check_makefile_clean() {
    local makefile="Makefile"
    local executable="factorielle"

    if [ ! -f "$makefile" ]; then
        echo "pas de Makefile trouvé."
        return 1
    fi

    if ! grep -qE '^clean:' "$makefile"; then
        echo "pas de règle 'clean:' trouvée dans le Makefile."
        return 1
    fi

    make clean > /dev/null 2>&1

    if [ -f "$executable" ]; then
        echo "❌ 'make clean' n'a pas supprimé l'exécutable '$executable'."
        GRADE=$((GRADE - 2))
        return 1
    else
        echo "'make clean' fonctionne correctement et supprime '$executable'."
        return 0
    fi
}


main() {
	check_student_project
	create_grades_csv
	recover_informations
	check_and_create_executable
        check_factorial
	number_caracter "main.c" "header.h"
	check_syntax_factorielle
	indentations "main.c" "header.h"
	check_makefile_clean
	add_to_csv
	echo "${GRADE}"
}
main "${@}"
