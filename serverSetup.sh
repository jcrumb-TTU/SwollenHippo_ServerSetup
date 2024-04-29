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


#Creates the log for our configuration log
mkdir configurationLogs

#installs jq on remote server
sudo apt-get install jq

#Debugging statement to test code prior to going live
#testTicket=17065

#IP address passed to script from copy.sh
strIP=$1

#TicketID passed to script from copy.sh
strTicketID=$2

#captures URL into variable for future curl
strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

#reads curled URL into an array
arrResult=$(curl ${strURL})

#Debugging statement
#echo ${arrResult}

#Gets the length of the array from the web service
intLength=$(echo ${arrResult} | jq 'length')

#Sets an integer to zero to iterate through array
intCurrent=0

#While loop iterates through the json array to parse
#for ticketID
while [ ${intCurrent} -lt ${intLength} ]; do

   #reads in the ticketID from json array and stores it in the string
   strJSONTicket=$(echo ${arrResult} | jq -r .[${intCurrent}].ticketID)

   #checks the retrieved json ticket to the ticket provided to the
   #script from copy.sh. If the ticket does not match, code jumps to count++
   if [ "${strJSONTicket}" == "${strTicketID}" ]; then

      #debugging statement
      #echo ${strJSONTicket}

      #gets the start time that the ticket began to be processed
      currTime=$(date +"%d-%b-%Y %H:%M")

      #gets hostname of the local server
      strHostname=$(hostname)

      #gets the name of the individual requesting the modifications on the
      #server
      strRequestor=$(echo ${arrResult} | jq -r .[${intCurrent}].requestor)

      #Gets the configureation of the server in question
      strStanConf=$(echo ${arrResult} | jq -r .[${intCurrent}].standardConfig)

      #Echos the required information for the logfile and uses file redirection
      #to both create and append to the file in the proper directory
      echo "TicketID: ${strJSONTicket}" >> configurationLogs/TicketID.log
      echo "Start DateTime: ${currTime}" >> configurationLogs/TicketID.log
      echo "Requestor: ${strRequestor}" >> configurationLogs/TicketID.log
      echo "External IP Address: ${strIP}" >> configurationLogs/TicketID.log
      echo "Hostname: ${strHostname}" >> configurationLogs/TicketID.log
      echo "Standard Configuration: ${strStanConf}" >> configurationLogs/TicketID.log
      echo "" >> configurationLogs/TicketID.log

      #Gets the software packages to be installed and reads them into an array
      #using jq
      arrSoftware=$(echo ${arrResult} | jq -r .[${intCurrent}].softwarePackages)

      #debugging statement
      #echo ${arrSoftware}

      #Reads in the number of software packages to be installed on the server
      intNumInstall=$(echo ${arrSoftware} | jq 'length')

      #variable to count the iterations and parse the json subarray
      intCountIns=0

      #While loop to iterate through the software packages to install.
      #If there are no software packages, the code below is skipped
      while [ ${intCountIns} -lt ${intNumInstall} ]; do

         #Gets the time stamp at the start of package installation
         strTimeStamp=$(date +%s)

         #Debugging statement
         #echo ${strTimeStamp}

         #Gets the name of the installation needed from the json array using jq
         strSoftwName=$(echo ${arrSoftware} | jq -r .[${intCountIns}].name)

         #debuggingstatement
         #echo ${strSoftwName}

         #gets the install command name from the json array and reads into variable
         strSoftInst=$(echo ${arrSoftware} | jq -r .[${intCountIns}].install)

         #Debugging statement
         #echo ${strSoftInst}

         #Installs package onto remote server using the sudo apt-get command
         sudo apt-get install ${strSoftInst}

         #Echos information of what software was installed and the timestamp into the logfile
         echo "softwarePackage - ${strSoftwName} - ${strTimeStamp}" >> configurationLogs/TicketID.log

      #increments the count variable above
      ((intCountIns++))
      done

      #Creates a space for readability in the logfile as requested
      echo "" >> configurationLogs/TicketID.log

      #gets the configurations from the json object and reads them to an array variable
      arrConf=$(echo ${arrResult} | jq -r .[${intCurrent}].additionalConfigs)

      #Gets the number of configurations needed for the server that the script is running on
      intNumConf=$(echo ${arrConf} | jq 'length')

      #Iterating variable set to zero to parse the array
      intConfComp=0

      #While statement to iterate through the json subarray to get the required configurations
      while [ ${intConfComp} -lt ${intNumConf} ]; do

         #Gets the name of the configuration required for the server
         strConfName=$(echo ${arrConf} | jq -r .[${intConfComp}].name)

         #debugging statement
         #echo ${strConfName}

         #gets the configuration command from the json array and reads it into
         #the variable below
         strConfCom=$(echo ${arrConf} | jq -r .[${intConfComp}].config)

         #debugging statement
         #echo ${strConfCom}

         #This is part of where things begin to fall apart. I got stuck on how
         #to parse the commands properly in the json array to ensure the correct
         #operations were carried out. The commands work inconsistently and sloppily
         #and I have tried to debug them to be less so and have had no such luck in doing
         #so. Comments in this section will be slightly more detailed
         if [[ ${strConfCom} == *"touch"* ]]; then

            #Gets the timestamp similar to above in the software packages
            strTimeStamp=$(date +%s)

            #This was an attempt to remove touch from the command as the directories
            #did not exist and would crash the program as a result. So I deliberately
            #removed the touch and the space in front of it and replaced it with a ~
            #so that the mkdir would function from the home directory. This did not
            #work in practice
            strConfCom=$(echo ${strConfCom} | sed  -e 's/touch /~/g')

            #Debugging statement
            #echo ${strConfCom}

            #This was again an attempt to remove information we did not want from the
            #json array to create the directories that we needed
            strConfCom=$(echo ${strConfCom} | sed  -e 's/index.html//g')

            #debugging statement
            #echo ${strConfCom}

            #This is where I tried to make the directories needed using -p to
            #create the directories all in a row. While it did work to some extent
            #it creates a new directory *single quote*~*singlequote* instead of going from
            #the home directory on the server itself. Numerous attemps to debug this error have
            #failed.
            mkdir -p ${strConfCom}

            #Resets the command back to the original command in the json array
            strConfCom=$(echo ${arrConf} | jq -r .[${intConfComp}].config)

            #This was again to create a pathway for touch from the home directory
            #and create the file in the proper location.
            strConfCom=$(echo ${strConfCom} | sed  -e 's/touch /touch ~/g')

            #This is the executed command
            ${strConfCom}

            #Echos the configurations and timestamp into the logfile
            echo "additionalConfig - ${strConfName} - ${strTimeStamp}" >> configurationLogs/TicketID.log

         #The same logic above of making something highly specific for the json array was followed
         #and this is where the program will simply not work as intended in the server it is meant to work on
         elif [[ ${strConfCom} == *"mkdir"* ]]; then

            #Timestamp created for the beginning of execution
            strTimeStamp=$(date +%s)

            #An attemept again to start from the home directory using ~
            strConfCom=$(echo ${strConfCom} | sed 's/mkdir /mkdir ~/g')

            #Debugging statement
            #echo ${strConfCom}

            #executing command
            ${strConfCom}

            #Reads the above informations of the configuration into the logfile
            echo "additionalConfig - ${strConfName} - ${strTimeStamp}" >> configurationLogs/TicketID.log

         #Same logic, specific targeting of variable in the configuration. Same result as above
         elif [[ ${strConfCom} == *"chmod"* ]]; then

            #Timestamp of start
            strTimeStamp=$(date +%s)

            #Adds a ~ to try and start from home directory for the chmod
            strConfCom=$(echo ${strConfCom} | sed 's/777 /777 ~/g')

            #Debugging statement
            #echo ${strConfCom}

            #Executing command
            ${strConfCom}

            #Echos configuration data into logfile
            echo "additionalConfig - ${strConfName} - ${strTimeStamp}" >> configurationLogs/TicketID.log

         #End of if statements for configurations
         fi

      #Increments through configurations subarray
      ((intConfComp++))
      done

   #Creates space in logfile for readability
   echo "" >> configurationLogs/TicketID.log

   #Retrieves software packages array again, this time to iterate and get versions
   #of software installed and append them to the logfile
   arrSoftPack=$(echo ${arrResult} | jq -r .[${intCurrent}].softwarePackages)

   #gets the length of the array to get the number of versions checks to perform
   intNumCheck=$(echo ${arrSoftware} | jq 'length')

   #Checks if any software packages are part of ticket in JSON
   if [ ${intNumCheck} -ne 0 ]; then

      #Creates a count to increment as iteration through array occurs
      intCountVer=0

      #While loop occurs to read through the array and perform version checks. Again this is where
      #Things break
      while [ ${intCountVer} -lt ${intNumCheck} ]; do

         #Gets the name of the software that has been installed
         strName=$(echo ${arrSoftPack} | jq -r .[${intCountVer}].name)

         #Gets the software command to perform version check
         strSoftCheck=$(echo ${arrSoftware} | jq -r .[${intCountIns}].install)

         #Debugging statement
         #echo ${strSoftCheck}

         #This is the attempt to get the version of the software, but always through an error
         #And failed to read the version into the variable below
         strSoftVersion=$(apt show ${strSoftCheck} | grep Version | sed 's/Version: //g')

          #Prints the required data to the log file
         echo "Version Check - ${strName} - ${strSoftVersion}" >> configurationLogs/TicketID.log

      #Increments while loop
      ((intCountVer++))
      done

   #end of checking if statement for software packages
   fi

   #end of ticket ID check if statement
   fi
#Increments for iteration in json array
((intCurrent++))
done

#Creates white space for readability in log file
echo "" >> configurationLogs/TicketID.log

#gets the ticket URL for completed ticket and adds the ticketID passed into the script from copy.sh to the end
strTicketURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets/completed.php?TicketID=${strTicketID}"

#Gets the curl of the ticketURL
arrOutcome=$(curl ${strTicketURL})

#Gets the ticket completion status
strOutcome=$(echo ${arrOutcome} | jq -r .outcome)

#Appends ticket completion to the log file
echo ${strOutcome} >> configurationLogs/TicketID.log

#creates white space for readability
echo "" >> configurationLogs/TicketID.log

#Shows date and time of ticket resolution
echo "Completed: $(date +"%d-%b-%Y %H:%M")" >> configurationLogs/TicketID.log
