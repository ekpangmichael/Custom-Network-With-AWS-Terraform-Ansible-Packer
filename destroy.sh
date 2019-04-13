#!/bin/bash

# ---------------------------------------------------------------------------------------------------------------------
# DESTROY THE INFRASTRUCTURE
# This script destroys the infrastucture
# ---------------------------------------------------------------------------------------------------------------------

# terminate when the script encounters an error
set -o pipefail

blue=`tput setaf 4`
green=`tput setaf 2`
reset=`tput sgr0`

source .env

#function to display messages as the script executes
echo_message() {
  echo  -e "\n ${1}=================================== ${2} ============================================ ${reset} \n "
}


# function to provision the infrastructure
destory_infrastructure(){
  echo_message "${blue}" "Destroying infrastructure"
  cd terraform 
  terraform destroy --auto-approve

  echo_message "${green}" "destroyed successfully"
}


# function to start the script and run all other functions
main(){
  destory_infrastructure
}

main
  