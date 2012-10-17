#!/bin/bash

# Thanks @fszczerba for this symlink-resolving magic.
SOURCE="${BASH_SOURCE[0]}"
DIR="$( dirname "$SOURCE" )"
while [ -h "$SOURCE" ];do
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
  DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

source ${SCRIPT_DIR}/generic.sh
source ${SCRIPT_DIR}/json.sh

__Vagrant.FindStatefile() {

   if [[ -f "${PWD}/.vagrant" ]];then

      echo "${PWD}/.vagrant"
      return 0

   else

      TestDirectory="${PWD}"

      until [[ -f "${TestDirectory}/.vagrant" ]];do
        export TestDirectory="$(dirname ${TestDirectory})"
      done

      echo "${TestDirectory}/.vagrant"
      return 0

   fi

   return 1

}
