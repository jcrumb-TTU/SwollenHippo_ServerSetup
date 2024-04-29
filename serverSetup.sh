#! /bin/bash
#Author: Jacob Crumb
#
#Creation date: 4-28-2024
#
#Description: This program is meant to take parameters passed from the copy.sh
#script and resolve tickets from a webserver by finding the ticket, installing and/or
#configuring the server with the elements in the json packages and configurations.
#Unfortunately, while the installation of packages occurs fine, it doesn't work on the
#database server and also creates the configurations rather sloppy. Finally, it fails to
#Capture the proper version of the software it installs, and I have unfortunately run out
#of time to dedicate responsibly and maintain my other obligations. I have commented
#thoroughly to ensure logic and process was captured clearly.

mkdir configurationLogs

sudo apt-get install jq

#testTicket=17065

strIP=$1

strTicketID=$2

strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

arrResult=$(curl ${strURL})

#echo ${arrResult}

intLength=$(echo ${arrResult} | jq 'length')

intCurrent=0

while [ ${intCurrent} -lt ${intLength} ]; do

   strJSONTicket=$(echo ${arrResult} | jq -r .[${intCurrent}].ticketID)


   if [ "${strJSONTicket}" == "${strTicketID}" ]; then

      #echo ${strJSONTicket}

      currTime=$(date +"%d-%b-%Y %H:%M")

      strHostname=$(hostname)

      strRequestor=$(echo ${arrResult} | jq -r .[${intCurrent}].requestor)

      strStanConf=$(echo ${arrResult} | jq -r .[${intCurrent}].standardConfig)

      echo "TicketID: ${strJSONTicket}" >> configurationLogs/TicketID.log
      echo "Start DateTime: ${currTime}" >> configurationLogs/TicketID.log
      echo "Requestor: ${strRequestor}" >> configurationLogs/TicketID.log
      echo "External IP Address: ${strIP}" >> configurationLogs/TicketID.log
      echo "Hostname: ${strHostname}" >> configurationLogs/TicketID.log
      echo "Standard Configuration: ${strStanConf}" >> configurationLogs/TicketID.log
      echo "" >> configurationLogs/TicketID.log

      arrSoftware=$(echo ${arrResult} | jq -r .[${intCurrent}].softwarePackages)

      #echo ${arrSoftware}

      intNumInstall=$(echo ${arrSoftware} | jq 'length')

      intCountIns=0

      while [ ${intCountIns} -lt ${intNumInstall} ]; do

         strTimeStamp=$(date +%s)

         #echo ${strTimeStamp}

         strSoftwName=$(echo ${arrSoftware} | jq -r .[${intCountIns}].name)

         #echo ${strSoftwName}

         strSoftInst=$(echo ${arrSoftware} | jq -r .[${intCountIns}].install)

         #echo ${strSoftInst}
         sudo apt-get install ${strSoftInst}

         echo "softwarePackage - ${strSoftwName} - ${strTimeStamp}" >> configurationLogs/TicketID.log

      ((intCountIns++))
      done

      echo "" >> configurationLogs/TicketID.log

      arrConf=$(echo ${arrResult} | jq -r .[${intCurrent}].additionalConfigs)

      intNumConf=$(echo ${arrConf} | jq 'length')

      intConfComp=0

      while [ ${intConfComp} -lt ${intNumConf} ]; do

         strConfName=$(echo ${arrConf} | jq -r .[${intConfComp}].name)

         #echo ${strConfName}

         strConfCom=$(echo ${arrConf} | jq -r .[${intConfComp}].config)

         #echo ${strConfCom}

         if [[ ${strConfCom} == *"touch"* ]]; then

            strTimeStamp=$(date +%s)

            strConfCom=$(echo ${strConfCom} | sed  -e 's/touch /~/g')

            #echo ${strConfCom}

            strConfCom=$(echo ${strConfCom} | sed  -e 's/index.html//g')

            #echo ${strConfCom}

            mkdir -p ${strConfCom}

            strConfCom=$(echo ${arrConf} | jq -r .[${intConfComp}].config)

            strConfCom=$(echo ${strConfCom} | sed  -e 's/touch /touch ~/g')

            ${strConfCom}

            echo "additionalConfig - ${strConfName} - ${strTimeStamp}" >> configurationLogs/TicketID.log

         elif [[ ${strConfCom} == *"mkdir"* ]]; then

            strTimeStamp=$(date +%s)

            strConfCom=$(echo ${strConfCom} | sed 's/mkdir /mkdir ~/g')

            #echo ${strConfCom}

            ${strConfCom}

            echo "additionalConfig - ${strConfName} - ${strTimeStamp}" >> configurationLogs/TicketID.log

         elif [[ ${strConfCom} == *"chmod"* ]]; then

            strTimeStamp=$(date +%s)

            strConfCom=$(echo ${strConfCom} | sed 's/777 /777 ~/g')

            #echo ${strConfCom}

            ${strConfCom}

            echo "additionalConfig - ${strConfName} - ${strTimeStamp}" >> configurationLogs/TicketID.log

         fi

      ((intConfComp++))
      done

   echo "" >> configurationLogs/TicketID.log

   arrSoftPack=$(echo ${arrResult} | jq -r .[${intCurrent}].softwarePackages)

   intNumCheck=$(echo ${arrSoftware} | jq 'length')

   if [ ${intNumCheck} -ne 0 ]; then

      intCountVer=0

      while [ ${intCountVer} -lt ${intNumCheck} ]; do

         strName=$(echo ${arrSoftPack} | jq -r .[${intCountVer}].name)

         strSoftCheck=$(echo ${arrSoftware} | jq -r .[${intCountIns}].install)

         #echo ${strSoftCheck}

         strSoftVersion=$(sudo apt show ${strSoftCheck} | grep Version | sed 's/Version: //g')

         echo "Version Check - ${strName} - ${strSoftVersion}" >> configurationLogs/TicketID.log

      ((intCountVer++))
      done

   fi

   fi

((intCurrent++))
done

echo "" >> configurationLogs/TicketID.log

strTicketURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets/completed.php?TicketID=${testTicket}"

arrOutcome=$(curl ${strTicketURL})

strOutcome=$(echo ${arrOutcome} | jq -r .outcome)

echo ${strOutcome} >> configurationLogs/TicketID.log

echo "" >> configurationLogs/TicketID.log

echo "Completed: $(date +"%d-%b-%Y %H:%M")" >> configurationLogs/TicketID.log
