# FoodBank GCP ETL Project

Author - Will McIntosh

# Create VM in GCP
Create, configure and use a Google Cloud Platform (GCP) linux virtual machine (VM).
1. Go to https://console.cloud.google.com/ .
2. Create a new project.
3. I called mine uk-food-donation-vm.
4. Click Create a VM -> Enable the API.
    * Click “Create a VM” again if you’re not brought to the VM setup page.
    * Could also be “Create an Instance”
5. Set the region to a location nearest you geographically.
6. On the “Machine Configuration” tab set the Machine Type to e2-micro to save money.
    * You shouldn’t need more than 10GB for this project.
7. Does it need a container? (no)
8. Allow HTTPS traffic? (no)
9. Click Create.
10. Wait for it to spin up.

# Make a Bucket
1. Go to https://console.cloud.google.com/storage/browser 
2. Click Create next to Buckets
3. Make a globally unique name
4. Location Type: Region
5. Location: Nearest you geographically
6. Default Storage Class: Standard

# Create an IAM to connect your python code to your bucket:
1. Go to https://console.cloud.google.com/iam-admin/iam 
2. Click Service Accounts
3. Click Create Service Account
4. Name your service account and give it a description, I called mine uk-food-donation-storage
5. Click "Create and Continue".
6. Grant this service account access to the project: Choose a role "Storage Object Admin".
7. Click "Done" to finish creating the service account.

# Generate a Key for the Service Account
1. Find your new service account in the list and click on it.
2. Go to the "Keys" tab.
3. Click "Add Key" and choose "Create new key".
4. Choose "JSON" as the key type and click "Create".
5. Download the JSON key file.
    * This file contains your credentials and should be securely stored and never exposed publicly.

# Attach the Service Account to Your VM
1. Go to the Compute Engine section of the Google Cloud Console.
2. Find your VM instance and stop it if it's running (you need to stop it to change the service account).
3. Click on the name of the instance to go to its details tab.
4. Click "Edit" at the top of the page.
5. Scroll down to the "Service account" section.
6. Select the service account you just created from the dropdown list.
7. Save your changes
8. Start the VM again.

# Setup your VM
1. Go to https://console.cloud.google.com/compute/instances 
2. SSH into it from the VM Instances page.
3. You should see the command line interface.
4. Run the line:
    * `sudo apt update`.
    * `sudo apt install python3-venv python3-pip` and confirm with Y
    * `python3 -m venv myenv`
    * `source myenv/bin/activate`
    * `pip install requests pandas tqdm google-cloud-storage`
    * `vim {NAME_OF_IAM_JSON_KEY}.json`
        * or the name of your json key you downloaded earlier in the “Generate a Key for the Service Account” stage.
5. Copy and paste the information in there and :wqa to save

# Write Python Script
Develop a simple python program to gather the data programmatically.
1. Run the line vim data_downloader.py .
2. Paste the code from `data_downloader.py` but be sure to update the values above to yours:
    * bucket_name
    * folder_name
    * bucket_key
3. After pasting the code below, run `:wqa`.
4. Then run `python data_downloader.py`.

# Run Daily
Configure your VM running your gathering client to run daily. 
1. SSH into your VM again.
2. Run the line whoami and copy it. 
3. Run the line crontab -e .
4. Select vim, unless you hate yourself.
5. At the bottom write this line replacing wmm2 with your own VM username from above.
```
0 3 * * * /home/william_michael_mcintosh/myenv/bin/python3 /home/william_michael_mcintosh/data_downloader.py >> /home/william_michael_mcintosh/cron_output.log 2>&1
```
6. Confirm the timezone with `sudo timedatectl set-timezone America/Los_Angeles`.
7. Double check it with this `timedatectl .`

# Start / Stop VM Automatically
Schedule your VM to start and stop automatically.
Now that you have a publishing client and a receiving client that runs automatically to do their respective jobs, you might realize that your VM has to be running for these clients to run as well.  
Keeping your VM on continuously is a sure way to run out of GCP credits quickly, but it's a hassle to manually go to the GCP console to turn it on and off everyday.  If you're manually doing that, what's the point of all your previous work to automate with cron and systemd?  Not to mention that manual work leaves room for human errors, e.g. what if you forget one day or more days; what if you don't have access to your computer for a while (heaven forbids something were to happen to a student's computer!); or what if you're out of commission due to illness or sickness.  
1. GCP console -> Compute Engine -> VM Instances
2. Click the Instance schedules tab at the top of the page.
3. Click date_range Create schedule. The Create a schedule pane opens.
4. Give it a name, mine is foodbank-vm-schedule
5. Give a region
6. Give a start time, mine is 02:00 AM
    * One hour before the cron job
8. Give an end time, mine is 04:00 AM
    * One hour after the cron job
10. Select Repeat Daily.
11. Submit.

# Connect Snowflake to Your GCP Bucket

1. Go through the steps to get a snowflake account
2. Create a new database
    * I called mine `UK_FOOD_DONATION`
3. Create a new SQL worksheet.
4. Copy and paste the code from `GCP_STORAGE_INTEGRATION`.
5. Run both blocks of code individually by highlighting and pressing Command+Enter.
6. Once you run the `DESC ...` line, get the `property_value` for the `STORAGE_GCP_SERVICE_ACCOUNT` row and copy it.
7. Go to GCP -> Cloud Storage.
8. Check your bucket and click **Permissions** at the top.
9. Click Add Principle
10. Paste the `STORAGE_GCP_SERVICE_ACCOUNT` value.
11. Assign the role `Storage Admin`.
12. Save

# Download the Foodbanks
This creates a new table using the foodbanks data.
1. Create a new SQL worksheet.
2. Copy and paste the code from `CREATE_STAGE_FOODBANKS`.
3. Run the blocks individually.

# Download the Needs
This creates a new table using the needs data.
1. Create a new SQL worksheet.
2. Copy and paste the code from `CREATE_STAGE_NEEDS`.
3. Run the blocks individually.

# Parse Needs Table
This creates a new table for each individual item in the needs table instead of being in their long list format in a single table cell.
1. Create a new SQL worksheet.
2. Copy and paste the code from `PARSE_NEEDS_TABLE`.
3. Run the blocks individually.

# Match Foodbanks (Brute Force)
This creates a new table that merges the foodbanks with the needs and excess. But there's an issue here because the foodbanks can be very far apart (200+ km).
1. Create a new SQL worksheet.
2. Copy and paste the code from `MATCH_FOODBANKS_RAW`.
3. Run the blocks individually.

# Calculate Distances
This table calculates the distance between each foodbank from each other, a pair-wise comparison.
1. Create a new SQL worksheet.
2. Copy and paste the code from `MATCH_FOODBANKS_RAW`.
3. Run the blocks individually.

# Match Foodbanks (Brute Force)
This creates a new table that merges the foodbanks with the needs and excess. But there's an issue here because the foodbanks can be very far apart (200+ km).
1. Create a new SQL worksheet.
2. Copy and paste the code from `MATCHES_W_DISTANCES`.
3. Run the blocks individually.



