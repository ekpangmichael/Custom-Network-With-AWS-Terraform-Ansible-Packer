#!/bin/bash

# ---------------------------------------------------------------------------------------------------------------------
# BUILD AMI'S AND INFRASTRUCTURE
# This script builds the images with Packer and Provision the infrasture with terraform
# ---------------------------------------------------------------------------------------------------------------------
 

# to ensure the script terminate when it encounters an error
set -o pipefail

blue=`tput setaf 4`
green=`tput setaf 2`
reset=`tput sgr0`

terraform_directory="terraform"

#get extra arguements from the command
if [ "$1" == "--image" ] || [ "$1" == "-i" ] ; then
    build_amis="build_amis"
    terraform_directory="../terraform"
    
fi

# Help commands
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
echo "${green}Deployment script 1.0.0

Usage:
  bash deploy.sh  <option>
  bash deploy.sh  <without option> Provision the infrastructure without building the images

Options:
  -h --help     Show help commands.
  -i --image    Build image with packer then run deploy
  ${reset}
  "
exit 0
fi



source .env

#function to display messages as the script executes
echo_message() {
  echo  -e " \n ${1}=================================== ${2} ============================================ ${reset} \n "
}

#function to run migrations and seed data
build_amis(){
echo_message "${blue}" "Building the Images"

 cd frontend
   packer build packer.json
 cd ../backend
   packer build packer.json
 cd ../database
    packer build packer.json

 echo_message "${green}" "Images build complete"
}

provision_infrastructure(){
  echo_message "${blue}" "Setting up infrastructure"
  cd $terraform_directory
  
  terraform init 
  terraform apply --auto-approve

  echo_message "${green}" "Deployment complete"
}


main(){
  $build_amis
  provision_infrastructure
}

main
  