#!/bin/bash

# scale-up default machineset
machineset=$(oc get machineset -n openshift-machine-api | grep -v NAME | head -n 1 | awk '{print $1}')
oc scale machineset/${machineset} -n openshift-machine-api --replicas=2
oc wait --for jsonpath='{.status.availableReplicas}'=2 --timeout 20m machineset/${machineset} -n openshift-machine-api
