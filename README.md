# SwollenHippo_ServerSetup
Contains the automation script for SwollenHippo Tech. Servers and manuel of use for the automation script.

Step 1: Log onto GCP

Step 2: In the search bar, enter in Compute Engine to go the list of servers and machines

Step 3: Find the linux-workstation which is where the script is hosted from.

Step 4: Log into the workstation using either your ssh on the gcp or ssh from your local machine

Step 5: Once you have logged into the machine, navigate to the repository in which the script is hosted. In the workstation case the repo is called SwollenHippo_ServerSetup

Step 6: Find the ticketID that you need to work

Step 7: Next find the external IP of the server in need of work. You can do this by looking through the GCP servers in the compute engine

Step 8: Finally have your username for the machine on hand for the script initiation

Step 9: Now that all the information is obtained, enter ./copy.sh ticketID externalIP username into the terminal, where ticketID externalIP and username
        refer to the information you obtained above

step 10:The Script will prompt you for your ssh passphrase in order to continue.

Step 11: Once the passphrase is entered, the script will ask if you wish to add the new ID, enter y

Step 12: The script will begin execution and may prompt approval for installation packages. Enter y

Step 13: Once this process is complete, the script will terminate and proper installation and logging should have taken place
