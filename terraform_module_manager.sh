#!/bin/bash

declare UPDATE_NAME=''
declare UPDATE_VERSION=''
declare run_update='false'
declare run_report='false'

usage () {
	cat <<USAGE

  -r|--report  Run a report of module versions in use
  -u|--update  Update the module to the specified version
  -v|--version Version number to update module to
  -m|--module  Name of the module to update

USAGE
}

run_module_report() {
  for file in `find * -type f -name main.tf |egrep module |egrep -v .terraform`; do
    MODULE_PATH=${module}
    for module in `sed -n '/^module/,/}/p' ${file}|egrep ^module |awk -F '"' '{print $2}'`; do
	    MODULE_NAME=${module}
	    MODULE_VERSION=`sed -n "/^module \"${module}\"/,/}/p" ${file}|egrep version|awk -F '"' '{print $2}'

      echo ${MODULE_PATH}":" ${MODULE_NAME} "=>" ${MODULE_VERSION}
    done  
  done
}

update_module_version(){
  for file in `find * -type f -name main.tf |egrep module |egrep -v .terraform`; do
    MODULE_PATH=${module}
    for module in `sed -n '/^module/,/}/p' ${file}|egrep ^module |awk -F '"' '{print $2}'`; do
	    MODULE_NAME=${module}
      if [[ ${UPDATE_MODULE} == ${MODULE_NAME} ]]; then
        sed -i -e "/^module\ \"${MODULE_NAME}\"/,/}/s/version.*/version\ \= \"${UPDATE_VERSION}\"/" ${MODULE_PATH}
      fi
      MODULE_VERSION=`sed -n "/^module \"${module}\"/,/}/p" ${file}|egrep version|awk -F '"' '{print $2}'
      echo ${MODULE_PATH}":" ${MODULE_NAME} "=>" ${MODULE_VERSION}
    done  
  done
}

if [[ $# -eq 0 ]]; then
  echo ""
   echo "No options provided. You must specify an option:"
   usage
   exit 0
else
  while [[ $# -gt 0 ]]; do
    case $1 in
      -r|--report)
        run_report='true'
      ;;
      -u|--update)
        run_update='true'
      ;;
      -v|--version)
        UPDATE_VERSION=${2}
        shift
      ;;
      -m|--module)
        UPDATE_NAME=${2}
        shift
      ;;
      *)
        echo "Invalid option passed"
        usage
        exit 1
    esac
    shift
  done
fi

if [[ ${run_udpate} == 'true' ]] && [[ ${run_report} == 'true' ]]; then
  echo "Report and Update are mutally exclusive options. Please choose only one at a time."
  usage
  exit 1
fi

if [[ ${run_report} == 'true' ]]; then
  echo "Running report"
  run_module_report
fi

if [[ ${run_update} == 'true' ]]; then
  if [[ ${UPDATE_VERSION} == ''  || ${UPDATE_NAME} == '' ]]; then
    echo "You must supply both a module name and a version to use the update option"
  else
    update_module_version
  fi
fi
