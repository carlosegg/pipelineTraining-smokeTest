#!/bin/bash
function help(){
   echo "
Ejecución de un smokeTest
Uso:
    $0 <enviromentId> [deploymentTableFile] [--help]


PARÁMETROS:
    <enviromentId>  Entorno sobre el que se ejecutará el smokeTest
    [deploymentTableFile]  Fichero con la definición de los entornos y las urls

EJEMPLO:
    $0 qa
"
}


function testParameters(){
   help=`echo $*|grep "\-\-help"`
   if [ -n "$help" ]; then
       help
       exit 0
   fi
   if [ "$#" == "1" ]; then
      enviromentId=$1
      rm -Rf target
      mkdir -p target
      TEST_DEPLOYMENT_FILE="target/deployment"
      lineSeparator=`grep -n "##################### DEPLOYMENT TABLE ############################" $0\
                     |grep -v "grep" |sed s:"\:##################### DEPLOYMENT TABLE ############################":"":g`
      sed 1,${lineSeparator}d $0 > $TEST_DEPLOYMENT_FILE
      deploymentTableFile=$TEST_DEPLOYMENT_FILE
    else
       if [ "$#" == "2" ]; then
          enviromentId=$1
          if [ -f "$2" ]; then
             deploymentTableFile=$2
          else
             echo "[ERROR] No se encuentra el fichero [$2]"
             return 1
          fi
       else
            echo "[ERROR] Número de parámetros incorrectos"
            help
            return 1
       fi
    fi
    return 0
}

function getUrl(){
  URL_SERVER=`cat ${deploymentTableFile} |grep "^$enviromentId"|cut -d'|' -f2\
              |sed s:"^ *":"":g|sed s:" *$":"":g`
}

function init(){
   PAUSE_SECONDS="1"
   testParameters $*
   errorCode=$?
   if [ "$errorCode" != "0" ]; then
      return $errorCode
   fi
}



function httpOK(){
   wget_test_result=`wget -q -S "$1" -O /dev/null 2>&1|grep "HTTP/"\
                    |head -1|grep "OK"|awk '{ print $2}'`
   case $wget_test_result in
      200)
         return 0
      ;;
      *)
         return 1 
      ;;
   esac
}

function smokeTestIndex(){
   httpOK "$URL_SERVER/index.html"
   return $?
}

function executeTest(){
   failed=false
   for smokeTest in `cat $0|grep "^function smokeTest.*()"\
                          |awk '{ print $2 }'|sed s:"(.*":"":g`;do
      $smokeTest
      errorCode=$?
      if [ "$errorCode" == "0" ]; then
         echo "smokeTest[$smokeTest]  Success"
      else 
         echo "smokeTest[$smokeTest]  Fail"
         failed=true
      fi
   done;
   if [ "$failed" == "false" ]; then
      return 0
   else
      return 1
   fi
}

function main(){
   init $*
   errorCode=$?
   if [ "$errorCode" != "0" ]; then
      return $errorCode
   fi
   # Esperamos a que esté desplegado el servicio

   echo "Esperando $PAUSE_SECONDS segundos para que se inicialice la aplicación"
   sleep $PAUSE_SECONDS
   getUrl
   if [ "$URL_SERVER" == "" ]; then
      echo "[ERROR] No hay una url definida para el entorno [$enviromentId]"
      return 1
   fi
   executeTest
   return $?
}

main $*
exit $?

##################### DEPLOYMENT TABLE ############################
#--------------+------------------------------------
# Enviroment   | URLS                               
#--------------+------------------------------------
ci             | http://ci-yarnottap/docs/

