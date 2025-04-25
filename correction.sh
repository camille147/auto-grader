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

main() {
	check_student_project
	create_grades_csv
	check_and_play_student_program
}

main "${@}"

