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
