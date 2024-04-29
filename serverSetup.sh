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

      arrSoftware=$(echo ${arrResult} | jq -r .[${intCurrent}].softwarePackages)

      intNumInstall=$(echo ${arrSoftware} | jq 'length')

      intCountIns=0

      while [ ${intCountIns} -lt ${intNumInstall} ]; do

         strSoftInst=$(echo ${arrSoftware} | jq -r .[${intCountIns}].install)

         #echo ${strSoftInst}

         #sudo apt-get install ${strSoftInst}

      ((intCountIns++))
      done

      arrConf=$(echo ${arrResult} | jq -r .[${intCurrent}].additionalConfigs)

      intNumConf=$(echo ${arrConf} | jq 'length')

      intConfComp=0

      while [ ${intConfComp} -lt ${intNumConf} ]; do

         strConfCom=$(echo ${arrConf} | jq -r .[${intConfComp}].config)

         #echo ${strConfCom}

      ((intConfComp++))
      done

   fi


((intCurrent++))
done
