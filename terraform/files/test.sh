#!/bin/bash
 cd selene-ah-frontend
  sudo rm app.json
  sudo touch app.json
  sudo chmod 777 app.json
  echo "{
  "addons": [

  ],
  "buildpacks": [

  ],
  "env": {
    "SERVER_API": "http://test.com/api/v1"
  },
  "formation": {
  },
  "name": "selene-ah-frontend",
  "scripts": {
  },
  "stack": "heroku-18"
}" >> app.json