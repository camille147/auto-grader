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

main() {
	check_student_project
	create_grades_csv
}

main "${@}"

