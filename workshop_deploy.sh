#!/bin/bash
cd ./demo
./demo_app_reset.sh
./setup.sh

for NS in $(oc get project | grep showroom | awk '{print $1}'); do
  echo "Update showroom to Japanese in ${NS}"
  oc scale --replicas=0 deployment/showroom -n $NS
  oc set env deployment/showroom GIT_REPO_URL="https://github.com/team-ohc-jp-place/parasol-insurance" -n $NS
  oc set env deployment/showroom GIT_REPO_REF="translation-jp" -n $NS
  oc scale --replicas=1 deployment/showroom  -n $NS
done