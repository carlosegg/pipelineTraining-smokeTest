#!/bin/bash
# Mas info: http://develenv.softwaresano.com/deploymentPipeline/libtest.html y
#           http://develenv.softwaresano.com/deploymentPipeline/index.html#Smoke_Test

# import libtest
source $(dirname $(readlink -f $0))/libtest.sh

function smokeTestIndex(){
   httpOK "$URL_SERVER/index.html"
   return $?
}


main $*
exit $?

##################### DEPLOYMENT TABLE ############################
#--------------+--------------------------------------------------------------
# Enviroment   | URL 
#--------------+--------------------------------------------------------------
ci             | http://ci-pipeline.hi.inet/pipelineTraining
qa             | http://pruebas-develenv2.hi.inet/pipelineTraining
thirdparty     | http://ci-yarnottap.hi.inet/pipelineTraining
demo           | http://ci-rmtest.hi.inet/pipelineTraining

