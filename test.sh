#!/bin/bash

if [ "$1" == "--image" ] || [ "$1" == "-i" ] ; then
    echo "Positional parameter 1 contains something"
    image="hello"
fi

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
echo "Deplpyment script 1.0.0.

Usage:
  bash test.sh  <option>

Options:
  -h --help     Show help commands.
  -i --image    Build imagw with packer then deploy
  "
fi



hello(){
  echo "hello world"
}

sayhi(){
  echo "hi"
}


main(){
  $image
  sayhi
}

main