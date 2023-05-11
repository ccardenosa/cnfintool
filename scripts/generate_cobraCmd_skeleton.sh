#!/bin/bash

: ${APP:="cnfintool"}
: ${AUTHOR:="Carlos Cardeñosa Pérez ccardenosa@redhat.com"}
: ${LICENSE:="apache"}

#[[ ! -d ${APP} ]] && mkdir -p ${APP}

#pushd ${APP}
go mod init github.com/spf13/${APP}

ccli=$(go env GOPATH)/bin/cobra-cli
[[ ! -f ${ccli} ]] && go install github.com/spf13/cobra-cli@latest

common_params="--author '${AUTHOR}' --license '${LICENSE}' --viper"
eval "$ccli init ${common_params}"

function capitalize {
  printf '%s' "$1" | head -c 1 | tr [:lower:] [:upper:]
  printf '%s' "$1" | tail -c '+2'
}

function nested_cmd {
  cname="$1$(capitalize ${2})"
  eval "$ccli add ${cname} -p ${2}Cmd ${common_params}"
  find . -type f -name "${cname}".go | xargs -I % sed -i "s/Use:.*\"${cname}\",/Use: \"${1}\",/" %
}


subcmds=("config" "context" "infra" "cluster" "testsuite" "test" "report")
for sc in ${subcmds[@]}; do
  eval "$ccli add $sc ${common_params}"

  case $sc in
    "config")
      nested_cmd create $sc
      nested_cmd show $sc
      ;;
    "context")
      nested_cmd state $sc
      ;;
    "infra")
      nested_cmd create $sc
      nested_cmd show $sc
      ;;
    "cluster")
      nested_cmd create $sc
      nested_cmd show $sc
      nested_cmd get $sc
      ;;
    "test")
      nested_cmd create $sc
      nested_cmd run $sc
      ;;
    "test-suite")
      nested_cmd create $sc
      nested_cmd list $sc
      nested_cmd run $sc
      ;;
    "report")
      nested_cmd generate $sc
      nested_cmd save $sc
      nested_cmd push $sc
      ;;
  esac
done
#popd
