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

check_and_create_executable() {
        make all > /dev/null

	if ! find . -name "factorielle" -print -quit | grep -q .; then
		GRADE=$((GRADE + 2))
	else
		GRADE=0
	fi
}

check_factorial() {
	good_answer=(1 2 6 24 120 720 5040 40320 362880 3628800)

	for ((i=1; i<10; i++)) do
		t_res=$(./factorielle "$i")

		if [ "$t_res" -ne "${good_answer[$((i - 1))]}" ]; then
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
	recover_informations
	number_caracter "main.c" "header.h"
	check_and_create_executable
	check_factorial
	echo "${GRADE}"
}
main "${@}"


