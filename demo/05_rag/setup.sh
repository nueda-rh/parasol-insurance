#!/bin/bash

#USER=user1

#oc apply -k .

#while true; do oc get statefulset/ic-chatbot -n ic-shared-app 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "statefulset/ic-chatbot does not exist yet. waiting..."; sleep 3; continue; else break; fi; done
#oc wait --for=jsonpath='{.status.availableReplicas}'=1 --timeout 10m statefulset/ic-chatbot -n ic-shared-app

#while true; do oc get deployment/maven -n ic-shared-app 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "deployment/maven does not exist yet. waiting..."; sleep 3; continue; else break; fi; done
#oc wait --for=jsonpath='{.status.availableReplicas}'=1 --timeout 10m deployment/maven -n ic-shared-app

#git_url="https://$(oc get route/git -n ${USER} -o jsonpath='{.spec.host}')/parasol-insurance"

#oc exec statefulset/ic-chatbot -c insurance-claim-app -n ic-shared-app -- git clone ${git_url}
#oc exec statefulset/ic-chatbot -c insurance-claim-app -n ic-shared-app -- mkdir -p /home/coder/.m2
#oc cp settings.xml ic-chatbot-0:/home/coder/.m2/settings.xml -c insurance-claim-app -n ic-shared-app
#oc exec statefulset/ic-chatbot -c insurance-claim-app -n ic-shared-app -- bash -c "curl -L -o /home/coder/parasol-insurance/chatbot/001226848.pdf -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36' https://www.moj.go.jp/content/001226848.pdf"

