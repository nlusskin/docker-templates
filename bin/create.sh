#!/bin/bash

RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
CYAN='\033[96m'
NC='\033[0m' # Reset

# change into the proper working directory
SCRIPT_DIR="$(cd -P -- "$(dirname -- "${0}")" && pwd -P)"
cd $SCRIPT_DIR && cd ../

# determine the service to be started and validate it against
# the Dockerfiles available
service_list=$(
  find services -mindepth 1 -maxdepth 1 -type d | 
  awk 'BEGIN { FS="/" } { print $2 }'
)
service="${1}"

# help message if '--help' is passed
if [ "${service}" = "--help" ]; then
  echo "Enter the name of the service you want to create\n" \
       "\rAvailable services:\n" \
       "\r$(for s in ${service_list}; do echo ' - '${s}; done)"
  exit 0
fi

# if service isn't provided as an argument, query it interactively
if [ -z ${service} ]; then
  read -p "Which service do you want to start?: " service
  if [ -z ${service} ]; then
    echo "${RED}Service must be specified${NC}"
    exit 1
  fi
fi

# check if the user-provided service is one of the available services
if [ $(echo ${service_list} | grep "${service}" | wc -l) -lt 1 ]; then
  echo -e "${RED}Service specified does not exist${NC}"
  exit 1
fi

# begin service setup
echo -e "Starting service ${YELLOW}${service}${NC}"

# find the relevant docker image, building it if necessary
docker_image_exists=$(sudo docker image list | egrep "${service}-auto" | wc -l)

if [ ${docker_image_exists} -lt 1 ]; then
  echo "Image does not exist. Building using the Dockerfile"
  sudo docker build -t ${service}-auto -f "Dockerfile.${service}" .
fi

# run the container using a unique name associated to the project
# if project name isn't provided as an argument, query it interactively
project_name="${2}"
if [ -z ${project_name} ]; then
  read -p "What is the name of your project: " project_name
  if [ -z ${project_name} ]; then
    echo -e "${RED}You must provide a project name${NC}"
    exit 1
  fi
fi


salt=$(openssl rand -hex 4)
echo "$project_name-$salt"

# find an open port in the specified range to bind
lower_port=6000
upper_port=7000
open_port=0

for port in $(seq $lower_port $upper_port); do
  if [ -n $(sudo lsof -i ':'$port) ]; then
    open_port=${port}
    break 
  fi
done

# spin up the container instance and print out the information
# TODO: use the SRV_PORT variable from .env to map to the internal docker port
sudo docker run -d -p 0.0.0.0:${port}:80 --name "${project-name}-${salt}" 