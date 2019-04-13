#!/bin/bash

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN INSTANCE, THEN TRIGGERS A PROVISIONER
# This script runs migrations and seed data to the backend instance
# ---------------------------------------------------------------------------------------------------------------------

# to ensure the script terminate when it encounters an error
set -o pipefail

blue=`tput setaf 4`
green=`tput setaf 2`
reset=`tput sgr0`

#function to display messages as the script executes
echo_message() {
  echo  -e " \n ${1}=================================== ${2} ============================================ ${reset} \n "
}

#function to run migrations and seed data
run_migrations(){
 cd selene-ah-backend
 echo_message "${blue}" "Running migrations and seeding data"
 sudo npm run db:migrate:seed
 echo_message "${green}" "Migrations complete"
}


main(){
  run_migrations
}

main
  


