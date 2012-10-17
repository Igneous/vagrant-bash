#!/usr/bin/env bash

#  JSON.sh < https://github.com/dominictarr/JSON.sh >
#
#  The MIT License
#  
#  Copyright (c) 2011 Dominic Tarr
#  
#  Permission is hereby granted, free of charge,
#  to any person obtaining a copy of this software and
#  associated documentation files (the "Software"), to
#  deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify,
#  merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom
#  the Software is furnished to do so,
#  subject to the following conditions:
#  
#  The above copyright notice and this permission notice
#  shall be included in all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
#  ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

__JSON.Throw () {
  echo "$*" >&2
  exit 1
}

__JSON.Tokenize () {
  local ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
  local CHAR='[^[:cntrl:]"\\]'
  local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
  local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  local KEYWORD='null|false|true'
  local SPACE='[[:space:]]+'
  egrep -ao "$STRING|$NUMBER|$KEYWORD|$SPACE|." --color=never |
    egrep -v "^$SPACE$"  # eat whitespace
}

__JSON.ParseArray () {
  local index=0
  local ary=''
  read -r token
  case "$token" in
    ']') ;;
    *)
      while :
      do
        __JSON.ParseValue "$1" "$index"
        let index=$index+1
        ary="$ary""$value" 
        read -r token
        case "$token" in
          ']') break ;;
          ',') ary="$ary," ;;
          *) __JSON.Throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
      ;;
  esac
  value=`printf '[%s]' "$ary"`
}

__JSON.ParseObject () {
  local key
  local obj=''
  read -r token
  case "$token" in
    '}') ;;
    *)
      while :
      do
        case "$token" in
          '"'*'"') key=$token ;;
          *) __JSON.Throw "EXPECTED string GOT ${token:-EOF}" ;;
        esac
        read -r token
        case "$token" in
          ':') ;;
          *) __JSON.Throw "EXPECTED : GOT ${token:-EOF}" ;;
        esac
        read -r token
        __JSON.ParseValue "$1" "$key"
        obj="$obj$key:$value"        
        read -r token
        case "$token" in
          '}') break ;;
          ',') obj="$obj," ;;
          *) __JSON.Throw "EXPECTED , or } GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
    ;;
  esac
  value=`printf '{%s}' "$obj"`
}

__JSON.ParseValue () {
  local jpath="${1:+$1,}$2"
  case "$token" in
    '{') __JSON.ParseObject "$jpath" ;;
    '[') __JSON.ParseArray  "$jpath" ;;
    # At this point, the only valid single-character tokens are digits.
    ''|[^0-9]) __JSON.Throw "EXPECTED value GOT ${token:-EOF}" ;;
    *) value=$token ;;
  esac
  printf "[%s]\t%s\n" "$jpath" "$value"
}

__JSON.Parse () {
  read -r token
  __JSON.ParseValue
  read -r token
  case "$token" in
    '') ;;
    *) __JSON.Throw "EXPECTED EOF GOT $token" ;;
  esac
}
