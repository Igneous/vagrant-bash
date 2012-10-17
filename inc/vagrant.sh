#!/usr/bin/env bash

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

__Vagrant.ListRunningVMs() {

  StateFile="$(__Vagrant.FindStatefile)"

  while read line;do
    if [[ "$line" =~ ^.\"active\",\".*$ ]];then
      line_remainder=${line#*,}
      vm_name="${line_remainder%%]*}"
      vm_uuid="${line_remainder#*]}"
      vm_uuid="${vm_uuid//[[:space:]]}"

      # Check to make sure it's *actually* up in virtualbox
      vboxmanage showvminfo ${vm_uuid//\"} | egrep "State:.*running" >/dev/null 2>&1
      if [[ $? == 0 ]];then
        RunningVMs+=(${vm_name})
      else
        DeadVMs+=(${vm_name})
      fi
    fi
  done <<< "$( cat ${StateFile} | __JSON.Tokenize | __JSON.Parse )"

  echo "${RunningVMs[*]}"

  return 0

}
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
