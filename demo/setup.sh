#!/bin/bash

ls -d 0* | sort | while read dir; do
  echo "### Entering ${dir} ..."
  cd ${dir}
  echo "[${dir}/setup.sh]"
  ./setup.sh
  echo "### Leaving ${dir} ..."
  cd ..
done

echo ""
echo ""
echo "dashboard: https://$(oc get route/rhods-dashboard -o jsonpath='{.spec.host}' -n redhat-ods-applications)"
echo "username/password: user1/openshift"
echo ""
echo "demo app: https://$(oc get route/ic-app -o jsonpath='{.spec.host}' -n ic-shared-app)"
echo ""
echo "code-server: https://$(oc get route/ic-chatbot-code-server -o jsonpath='{.spec.host}' -n ic-shared-app)/?folder=/home/coder/parasol-insurance/chatbot"
echo "password: openshift"
echo ""

