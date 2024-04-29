#! /bin/bash
#Author: Jacob Crumb
#
#Creation date:
#
#Description:

testTicket=17065

#strIP=$1

#strTicketID=$2

strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

arrResult=$(curl ${strURL})

#echo ${arrResult}

intLength=$(echo ${arrResult} | jq 'length')

intCurrent=0

while [ ${intCurrent} -lt ${intLength} ]; do

   strJSONTicket=$(echo ${arrResult} | jq -r .[${intCurrent}].ticketID)


   if [ "${strJSONTicket}" == "${testTicket}" ]; then

      #echo ${strJSONTicket}

      currTime=$(date +"%d-%b-%Y %H-%M")

      strHostname=$(hostname)

      strRequestor=$(echo ${arrResult} | jq -r .[${intCurrent}].requestor)

      strStanConf=$(echo ${arrResult} | jq -r .[${intCurrent}].standardConfig)

      echo "TicketID: ${strJSONTicket}"
      echo "Start DateTime: ${currTime}"
      echo "Requestor: ${strRequestor}"
      echo "External IP Address: "
      echo "Hostname: ${strHostname}"
      echo "Standard Configuration: ${strStanConf}"
      echo ""

      arrSoftware=$(echo ${arrResult} | jq -r .[${intCurrent}].softwarePackages)

      #echo ${arrSoftware}

      intNumInstall=$(echo ${arrSoftware} | jq 'length')

      intCountIns=0

      while [ ${intCountIns} -lt ${intNumInstall} ]; do

         strSoftwName=$(echo ${arrSoftware} | jq -r .[${intCountIns}].name)

         echo ${strSoftwName}

         strSoftInst=$(echo ${arrSoftware} | jq -r .[${intCountIns}].install)

         #echo ${strSoftInst}
         echo "sudo apt-get install ${strSoftInst}"

         echo "softwarePackage - ${strSoftwName} - version check info"

      ((intCountIns++))
      done

      echo ""

      arrConf=$(echo ${arrResult} | jq -r .[${intCurrent}].additionalConfigs)

      intNumConf=$(echo ${arrConf} | jq 'length')

      intConfComp=0

      while [ ${intConfComp} -lt ${intNumConf} ]; do

         strConfName=$(echo ${arrConf} | jq -r .[${intConfComp}].name)

         echo ${strConfName}

         strConfCom=$(echo ${arrConf} | jq -r .[${intConfComp}].config)

         echo ${strConfCom}

         if [[ ${strConfCom} == *"touch"* ]]; then

            strConfCom=$(echo ${strConfCom} | sed  -e 's/touch //g')

            echo ${strConfCom}

            strConfCom=$(echo ${strConfCom} | sed  -e 's/index.html//g')

            echo ${strConfCom}

            #mkdir ${strConfCom}

            strConfCom=$(echo ${arrConf} | jq -r .[${intConfComp}].config)

            echo ${strConfCom}

         elif [[ ${strConfCom} == *"mkdir"* ]]; then

            strConfCom=$(echo ${strConfCom} | sed 's/mkdir /mkdir ~/g')

            echo ${strConfCom}

            #${strConfCom}

         elif [[ ${strConfCom} == *"chmod"* ]]; then

            strConfCom=$(echo ${strConfCom} | sed 's/777 /777 ~/g')

            echo ${strConfCom}

            #${strConfCom}

         fi

         echo "additionalConfig - ${strConfName} - version check info"

      ((intConfComp++))
      done

      strTicketURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets/completed.php?TicketID=${testTicket}"

      strOutcome=$(curl ${strTicketURL} | jq -r .outcome)

      echo ${strOutcome}

   fi


((intCurrent++))
done
