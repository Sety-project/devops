#!/bin/bash
source ~/.bashrc

declare -A LINUX_TO_GIT_USER
LINUX_TO_GIT_USER=(["vic"]="mol86" ["david"]="daviidarr")

WEIGHT=1

while getopts 'n:a:p:t:d:w:l:' flag; do
  echo "in the loop ${flag}"
  case "${flag}" in  
    n) NAMESPACE=${OPTARG} ;;
    p) PROJECT=${OPTARG} ;;
    t) TICKET=${OPTARG} ;;
    a) ASSIGNEE=${OPTARG} ;;
    d) DESCRIPTION=${OPTARG} ;;
    w) WEIGHT=${OPTARG} ;;
    l) LABELS=${OPTARG} ;;
  esac
done



if [ -z ${TICKET} ] ; then
    echo "Assign the ticket. Usage: -t ticket"
    # exit 1
fi

if [ -z ${PROJECT} ] ; then
    PROJECT=`pwd | sed 's#.*/##'`
fi

if [ -z ${NAMESPACE} ] ; then
    NAMESPACE=`pwd | awk -F '/' {'print $(NF-1)'}`
fi

#param2=123
#echo ${param:-toto1}
#echo ${param}
#echo ${param2:+toto2}
#echo ${param2}
#echo ${param3:-toto3}
#echo ${param3}
#echo TICKET=$TICKET


echo "Project: $NAMESPACE/$PROJECT"

PROJECT_ID=`get_git_project_id $PROJECT $NAMESPACE`

if [ "$PROJECT_ID" = "null" ] ; then
    echo "Cannot resolve project. You can select another project using -p project, and specify the namespace using -n namespace"
    #exit 1
fi

echo PROJECT_ID=$PROJECT_ID

if [ -z ${ASSIGNEE+x} ] ; then
    ASSIGNEE=$USERNAME
fi

ASSIGNEE_ID=`get_git_user_id $ASSIGNEE`
ASSIGNEE_PAYLOAD=", \"assignee_ids\":[$ASSIGNEE_ID]"
DESCRIPTION_PAYLOAD=", \"description\":\"$DESCRIPTION\""
LABELS_PAYLOAD=", \"labels\":\"$LABELS\""

if [ "$ASSIGNEE_ID" == "null" ] ; then
    echo "Couldn't find the assignee. Verify that this username exists."
    exit 1
fi

if [ "$PROJECT_ID" == "null" ] ; then
    echo "Couldn't find the project. Verify that this project exists."
    exit 1
fi

echo NAMESPACE=$NAMESPACE
echo PROJECT=$PROJECT
echo TICKET=$TICKET
echo ASSIGNEE_ID=$ASSIGNEE_ID
echo PROJECT_ID=$PROJECT_ID
#echo DESCRIPTION=$DESCRIPTION
#echo WEIGHT=$WEIGHT
#echo LABELS=$LABELS


curl -X POST -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Sety-project/pylibs/issues -d '{"title":"GitHub REST API","body":"Testing GitHub API","assignees":["mol86"],"milestone":1,"labels":["test"]}'



echo "done"



