#!/bin/bash
# ------------------------------------------------------------------------------ #
# Simple wrapper script to call in order of k8s deployment
version=0.2
# ------------------------------------------------------------------------------ #

# Input requires "module", "apply/delete"
# Assumptions
# - The module will be the namespace name
# - The module will contain order.list in ascending order to be executed

module=$1
action=$2

order_file="${module}/order.list"
if [ $# -ne 2 ]; then
    echo "Expected two arguments"
    echo "<script> <module_name> <action>"
    exit 10
fi

if [ ! -d "$module" ] || [ ! -f "$order_file" ]; then
    echo "Either Module Directory or the Order File did NOT exist"
    echo "Expected ${order_file}"
    exit 10
fi

case $action in
   apply)
      list=`cat ${order_file}| grep -v '#' `
      ;;
   delete)
      list=`cat ${order_file}| grep -v '#'| tac `
      ;;
   *)
     echo "Unable to identify action. Accepts only apply or delete"
     exit 1
     ;;
esac

if [ $action == "apply" ] ; then
    kubectl create ns ${module}
fi

for dir in `echo $list`
do
    for f in `ls -1 ${module}/${dir}/*.yaml`
    do
        echo "Executing => kubectl -n $module $action -f $f"
        kubectl -n $module $action -f $f
        echo "-----------------------------------------------"
    done
done

if [ $action == "delete" ] ; then
    kubectl delete ns ${module}
fi