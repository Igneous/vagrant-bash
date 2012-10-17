#!/usr/bin/env bash

__Array.ContainsElement() {

  local element

  for element in "${@:2}";do
    [[ "$element" == "$1" ]] && return 0
  done

  return 1

}

__pwdln() {

   # Doing PE from the beginning of the string is needed
   # so we get a string of 0 len to break the until loop.

   pwdmod="${PWD}/"
   itr=0
   until [[ -z "$pwdmod" ]];do
      itr=$(($itr+1))
      pwdmod="${pwdmod#*/}"
   done
   echo -n $(($itr-1))

}
