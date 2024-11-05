#!/bin/bash

#USER=user1

#HTPASSWD=$(oc get oauth/cluster -o jsonpath='{.spec.identityProviders[0].htpasswd.fileData.name}')
#HTPASSWD_ADMIN=$(oc get secret/${HTPASSWD} -n openshift-config -o jsonpath='{.data.htpasswd}' | base64 -d | grep admin)
#htpasswd -c -B -b /tmp/htpasswd ${USER} openshift
#echo "${HTPASSWD_ADMIN}" >> /tmp/htpasswd

#oc create secret generic htpass-secret --from-file=htpasswd=/tmp/htpasswd -n openshift-config
#oc get oauth/cluster -o yaml | grep -B50 spec: | grep -v spec: > /tmp/oauth.yaml
#cat <<EOF >> /tmp/oauth.yaml
#spec:
#  identityProviders:
#  - name: htpasswd_provider
#    mappingMethod: claim
#    type: HTPasswd
#    htpasswd:
#      fileData:
#        name: htpass-secret
#EOF
#oc apply -f /tmp/oauth.yaml
#rm -f /tmp/oauth.yaml /tmp/htpasswd

#cd bootstrap/ic-rhoai-configuration/
#oc apply -k .
# oc wait
#cd ../../

#cd bootstrap/ic-shared-minio/
#oc apply -k .
#oc wait --for=jsonpath='{.status.succeeded}'=1 --timeout 10m job/create-buckets -n ic-shared-minio
#cd ../../

#cd bootstrap/ic-shared-database/
#oc apply -k .
#oc wait --for=jsonpath='{.status.succeeded}'=1 --timeout 10m job/db-init-job -n ic-shared-db
#oc wait --for=jsonpath='{.status.succeeded}'=1 --timeout 10m job/populate-images -n ic-shared-db
#cd ../../

#cd bootstrap/ic-shared-app/
#oc apply -k .
#oc wait --for=jsonpath='{.status.availableReplicas}'=1 --timeout 10m deployment/ic-app -n ic-shared-app
#cd ../../

#cd bootstrap/ic-user-projects/
#bash create-projects-and-resources.bash
# oc wait
#cd ../../

oc new-project git
oc apply -f git.yaml -n git
while true; do oc get statefulset/git -n git 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "statefulset/git does not exist yet. waiting..."; sleep 3; continue; else break; fi; done
oc wait --for jsonpath='{.status.availableReplicas}'=1 --timeout 5m statefulset/git -n git

git_url="https://$(oc get route/git -n git -o jsonpath='{.spec.host}')/parasol-insurance"
git remote add demo ${git_url}
#git checkout -b transcription origin/transcription 2>/dev/null
while true; do git push demo translation-jp:main 2>/dev/null; if [ $? -eq 0 ]; then break; else sleep 3; fi; done

#oc apply -f pvc_processing-pipeline-storage.yaml -n ${USER}
#while true; do oc get pvc/processing-pipeline-storage -n ${USER} 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "pvc/processing-pipeline-storage does not exist yet. waiting..."; sleep 3; continue; else break; fi; done
#oc wait --for=jsonpath='{.status.phase}'=Bound --timeout 15m pvc/processing-pipeline-storage -n ${USER}
#oc wait --for=jsonpath='{.status.phase}'=Pending --timeout 15m pvc/processing-pipeline-storage -n ${USER}

#oc apply -f secret_aws-connection-shared-minio.yaml -n ${USER}
#while true; do oc get secret/aws-connection-shared-minio -n ${USER} 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "secret/aws-connection-shared-minio does not exist yet. waiting..."; sleep 3; continue; else break; fi; done

oc apply -f secret_aws-connection-shared-minio.yaml -n ic-shared-llm
oc apply -f job_setup_objectstorage.yaml -n ic-shared-llm
while true; do oc get job/setup-objectstorage -n ic-shared-llm 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "job/setup-objectstorage does not exist yet. waiting..."; sleep 3; continue; else break; fi; done
oc wait --for=jsonpath='{.status.ready}'=1 --timeout 20m job/setup-objectstorage -n ic-shared-llm
oc wait --for=jsonpath='{.status.active}'=1 --timeout 20m job/setup-objectstorage -n ic-shared-llm
oc logs -f job/setup-objectstorage -n ic-shared-llm
oc wait --for=jsonpath='{.status.succeeded}'=1 --timeout 20m job/setup-objectstorage -n ic-shared-llm

oc label namespace/ic-shared-llm modelmesh-enabled=false

oc apply -f servingruntime_llama-3-elyza-jp-8b-vllm.yaml -n ic-shared-llm
#oc apply -f servingruntime_accident-detect-kserve-ovms.yaml -n ${USER}
#oc apply -f servingruntime_faster-whisper-large-v3-faster-whisper.yaml -n ${USER}
oc apply -f inferenceservice_llama-3-elyza-jp-8b.yaml -n ic-shared-llm
#oc apply -f inferenceservice_accident-detect.yaml -n ${USER}
#oc apply -f inferenceservice_faster-whisper-large-v3.yaml -n ${USER}

#while true; do oc get inferenceservices/accident-detect -n ${USER} 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "inferenceservices/accident-detect does not exist yet. waiting..."; sleep 3; continue; else break; fi; done
#oc wait --for=jsonpath='{.status.modelStatus.transitionStatus}'=UpToDate --timeout 15m inferenceservices/accident-detect -n ${USER}
while true; do oc get inferenceservices/llama-3-elyza-jp-8b -n ic-shared-llm 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "inferenceservices/llama-3-elyza-jp-8b does not exist yet. waiting..."; sleep 3; continue; else break; fi; done
oc wait --for=jsonpath='{.status.modelStatus.transitionStatus}'=UpToDate --timeout 30m inferenceservices/llama-3-elyza-jp-8b -n ic-shared-llm
#while true; do oc get inferenceservices/faster-whisper-large-v3 -n ${USER} 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "inferenceservices/faster-whisper-large-v3 does not exist yet. waiting..."; sleep 3; continue; else break; fi; done
#oc wait --for=jsonpath='{.status.modelStatus.transitionStatus}'=UpToDate --timeout 30m inferenceservices/faster-whisper-large-v3 -n ${USER}

pwd=$(pwd)
cd /tmp
git clone ${git_url}
cd parasol-insurance
git checkout -b main 2>/dev/null
inference_url_llm="$(oc get inferenceservice/llama-3-elyza-jp-8b -o jsonpath='{.status.url}' -n ic-shared-llm)"
#inference_url_img_det="$(oc get inferenceservice/accident-detect -o jsonpath='{.status.url}' -n ${USER})"
#inference_url_transcription="$(oc get inferenceservice/faster-whisper-large-v3 -o jsonpath='{.status.url}' -n ${USER})"
find . -type f -exec sed -i "s|_INFERENCE_URL_LLM_|${inference_url_llm}|g" {} \;
#find . -type f -exec sed -i "s|_INFERENCE_URL_IMG_DET_|${inference_url_img_det}|g" {} \;
#find . -type f -exec sed -i "s|_INFERENCE_URL_TRANSCRIPTION_|${inference_url_transcription}|g" {} \;
git config --local user.name demo
git config --local user.email demo@example.com
git commit -m "Demo" .
git push origin main
cd ${pwd}



for USER in user{1..50}; do
  echo "Remove default directory for ${USER}..."
  
  oc exec pods/my-workbench-0 -c my-workbench -n ${USER} -- rm -rf parasol-insurance
  oc exec pods/my-workbench-0 -c my-workbench -n ${USER} -- git clone ${git_url}
  
  echo "Completed cloning Japanese instructions for ${USER}."
done



