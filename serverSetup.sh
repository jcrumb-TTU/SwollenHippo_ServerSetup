#! /bin/bash
#Author: Jacob Crumb
#
#Creation date:
#
#Description:

#strIP=$1

#strTicketID=$2

strURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"

arrResult=$(curl ${strURL})

echo ${arrResult}

intLength=$(echo ${arrResult} | jq 'length'

intCurrent=0

while [ "$intCurrent" -lt "$intLength" ];do

   strJSONTicket=$(echo ${arrResult} | jq -r .[intCurrent].ticketID)


   if


((intCurrent++))
done
