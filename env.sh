#!/usr/bin/env bash
set -e

home="$( cd "$( dirname "$0" )" && pwd )"
conf="${home}/config.yaml"
key="$2"
keys=$(egrep "^[a-z]" ${conf} | cut -d':' -f1 | tr '\n' ' ')
opts="start stop restart build rebuild kill rm rmi"
#-------------------------------------------------------------------------------
build() {
  echo "Build docker images:"
  for image in $images; do
    docker build --rm -t dockerfile/${image} ${home}/${image}/.
  done

  docker images
}
#-------------------------------------------------------------------------------
rebuild() {
  echo "Rebuild docker images:"
  for image in $images; do
    docker build --no-cache --rm -t dockerfile/${image} ${home}/${image}/.
  done
}
#-------------------------------------------------------------------------------
stop() {
  echo "Stopping docker containers:"
  for container in $containers; do
    docker stop "$container" || true
  done
}
#-------------------------------------------------------------------------------
start() {
  service_name=$(shyaml get-value $key.service.name < $conf)
  service_image=$(shyaml get-value $key.service.image < $conf)

  service_ports=$(shyaml get-value $key.service.port < $conf | cut -d' ' -f2)
  #service_port=$(shyaml get-value $key.service.port < $conf)
  #service_port_cmd=$(if [[ ! -z "$service_port" ]]; then echo "-p ${service_port}:${service_port}"; fi)

  for service_port in $service_ports; do

    if [[ ! -z "$links_cmd" ]]; then
      service_port_cmd=$(echo "-p ${service_port}:${service_port}")
    else
      service_port_cmd=$(echo $service_port_cmd" -p ${service_port}:${service_port}")
    fi

  done

  links_num=$(shyaml get-value $key.links < $conf | grep -c "name") || true

  if [[ "$links_num" -ne 0 ]]; then
    n=0
    while [[ "$n" -lt "$links_num" ]]; do
      link_name=$(shyaml get-value $key.links.$n < $conf | grep name | cut -d' ' -f2)
      link_image=$(shyaml get-value $key.links.$n < $conf | grep image | cut -d' ' -f2)
      link_alias=$(shyaml get-value $key.links.$n < $conf | grep alias | cut -d' ' -f2)

      echo "Starting ${link_name}:"
      docker run -d --name "$link_name" "$link_image"
      if [[ ! -z "$links_cmd" ]]; then
        links_cmd=$(echo "--link ${link_name}:${link_alias}")
      else
        links_cmd=$(echo $links_cmd" --link ${link_name}:${link_alias}")
      fi

      n=$(( n+1 ))
    done
  fi

  echo "Starting ${service_name}:"
  echo "docker run -d --name $service_name $service_port_cmd $links_cmd $service_image"
  docker run -d \
             --name "$service_name" \
             $service_port_cmd \
             $links_cmd \
             "$service_image"

  docker ps -a

  C_ID=$(docker ps -a | grep $service_name | cut -d' ' -f1)

  echo "docker exec -i -t $C_ID bash"
}
#-------------------------------------------------------------------------------
kill() {
  echo "Killing docker containers:"
  for container in $containers; do
    docker kill "$container" || true
  done
}
#-------------------------------------------------------------------------------
rm() {
  echo "Removing stopped containers:"
  for container in $containers; do
    docker rm "$container" || true
  done
}
#-------------------------------------------------------------------------------
rmi() {
  echo "Removing all untagged images:"
  docker images | grep "^<none>" | awk '{print "docker rmi "$3}' | sh
}
#-------------------------------------------------------------------------------
usage() {
  echo "USAGE: $0" option key

  echo -e "\nOptions:"
  for opt in $opts; do
    echo "    ${opt}"
  done

  echo -e "\nKeys from config.yaml:"
  for key in $keys; do
    echo "    ${key}"
  done
  echo ""
  exit 1
}
#-------------------------------------------------------------------------------
if [[ ! $# -eq 2 ]]; then
  usage
elif [[ $(echo $keys | grep -cwm1 $key) -eq 0 ]]; then
  usage
fi
#-------------------------------------------------------------------------------
images=$(shyaml get-value $key.images < $conf | cut -d' ' -f2)
containers=$(shyaml get-value $key < $conf | grep name | cut -d':' -f2)
#-------------------------------------------------------------------------------
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    kill
    rm
    start
    ;;
  build)
    build
    ;;
  rebuild)
    rebuild
    ;;
  kill)
    kill
    rm
    ;;
  rm)
    rm
    ;;
  rmi)
    rmi
    ;;
  *)
    usage
    ;;
esac
#===============================================================================
