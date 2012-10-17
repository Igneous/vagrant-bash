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

  local -a RunningVMs=()
  local -a RunningUUIDs=()
  local -a DeadVMs=()
  local StateFile="$(__Vagrant.FindStatefile)"

  # Gather the UUIDs of all presently running VMs.
  while read proc;do
    proc=${proc#*--startvm[[:space:]]}
    proc=${proc%%[[:space:]]*}
    RunningUUIDs+=(${proc})
  done <<< "$(ps h -C VBoxHeadless -o args)"

  while read line;do
    if [[ "$line" =~ ^.\"active\",\".*$ ]];then
      local line_remainder=${line#*,}
      local vm_name="${line_remainder%%]*}"
      local vm_uuid="${line_remainder#*]}"
      local vm_uuid="${vm_uuid//[[:space:]]}"
      local vm_uuid="${vm_uuid//\"}"

      if __Array.ContainsElement "${vm_uuid}" "${RunningUUIDs[@]}";then
        RunningVMs+=(${vm_name})
      else
        DeadVMs+=(${vm_name})
      fi
    fi
  done <<< "$( __JSON.Tokenize < ${StateFile} | __JSON.Parse )"

  echo "${RunningVMs[*]}"

  return 0

}
__Vagrant.FindStatefile() {

   if [[ -f "${PWD}/.vagrant" ]];then

      echo "${PWD}/.vagrant"
      return 0

   else

      local TestDirectory="${PWD}"

      until [[ -f "${TestDirectory}/.vagrant" ]];do
        export TestDirectory="$(dirname ${TestDirectory})"
      done

      echo "${TestDirectory}/.vagrant"
      return 0

   fi

   return 1

}
