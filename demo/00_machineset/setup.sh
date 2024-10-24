#!/bin/bash

# scale-up default machineset
machineset=$(oc get machineset -n openshift-machine-api | grep -v NAME | head -n 1 | awk '{print $1}')
oc scale machineset/${machineset} -n openshift-machine-api --replicas=3
oc wait --for jsonpath='{.status.availableReplicas}'=3 --timeout 20m machineset/${machineset} -n openshift-machine-api

# create GPU machineset
oc get machineset/${machineset} -o yaml -n openshift-machine-api > /tmp/gpu_machineset.yaml
sed -i "s/${machineset}/${machineset}g/g" /tmp/gpu_machineset.yaml
sed -i "s/instanceType: .*/instanceType: g5.xlarge/g" /tmp/gpu_machineset.yaml
sed -i "s/replicas: .*/replicas: 2/g" /tmp/gpu_machineset.yaml

oc apply -f /tmp/gpu_machineset.yaml
rm -f /tmp/gpu_machineset.yaml

while true; do oc get machineset/${machineset}g -n openshift-machine-api 2>&1 | grep "not found" 1>/dev/null 2>&1; if [ $? -eq 0 ]; then echo "machineset/${machineset}g does not exist yet. waiting..."; sleep 3; continue; else break; fi; done
oc wait --for jsonpath='{.status.availableReplicas}'=2 --timeout 30m machineset/${machineset}g -n openshift-machine-api

