# FoodBank GCP ETL Project

Author - Will McIntosh

# Data Origin

This data comes from GiveFood which maintains the largest publicly available database of food banks in the UK and currently cover nearly 3000 locations. Their data is used by governments, councils, universities, supermarkets, political parties, the NHS, food manufacturers, hundreds of national & local news websites, apps & the Trussell Trust.

https://github.com/givefood/data/

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

# Match Foodbanks (By Distance)
This creates a new table that merges the foodbanks with the needs and excess. But there's an issue here because the foodbanks can be very far apart (200+ km).
1. Create a new SQL worksheet.
2. Copy and paste the code from `MATCHES_W_DISTANCES`.
3. Run the blocks individually.

# --- New Challenge! ---

![New Challenger Approaches](https://drive.google.com/uc?export=view&id=1KDa0y1yRwhsXmXAhfpt3IdcE6LRecWFU)

Let's do everything in GCP! Who needs Snowflake!?

# VM Permissions
You need to give your VM permissions to access the SQL database.
1. Go to Virtual Machines in GCP.
2. Stop the virtual machine.
3. Go to the specific VM instance details -> edit.
4. Check under “Cloud API access scopes”.
5. Set this to “Allow full access to all Cloud APIs”.

# Cloud Run Functions Permissions
You need to add the code to Cloud Run Functions which will allow you to grab a secret from Google Secrets API and pass that information into your html or js code without writing in sensitive information.
1. Go to Google Cloud Run Functions.
2. Enable.
3. Write a new one, I called mine google-maps-api-key.

# Allow Full Access First, Then Limit By Domain
Open the terminal anywhere from GCP in the top right and type this in:
```
gcloud functions add-invoker-policy-binding [NAME_OF_YOUR_GOOGLE_CLOUD_RUN_FUNCTION \
      --region="australia-southeast1" \
      --member="allUsers"
```
Make sure to change the name of you function.

# Set Invoker Permissions for Cloud Run
Since Cloud Run manages permissions slightly differently than Cloud Functions, follow these steps if your function is listed under Cloud Run:
1. Click on the service in the Cloud Run interface.
2. Go to the Permissions tab.
3. Click Add principal.
4. Enter allUsers in the principal field.
5. Select the role Cloud Run Invoker.
6. Click Save to apply the permissions.

# Address the Secret Manager Access Issue
Grant Secret Manager Access: Since your function now triggers without permission issues but fails due to Secret Manager access, ensure the correct permissions are set.
1. Navigate to Secret Manager in the Google Cloud Console.
2. Click on the secret that needs to be accessed.
3. Click Permissions.
4. Click Add principal.
5. Enter the email of the service account used by your Cloud Run service, which you can find under the Details or Permissions tab of your Cloud Run service.
6. Select the role Secret Manager Secret Accessor and save.

# Test If It Works
Let's make sure the Cloud Run Function does what we want.
1. Go to Google Cloud Run Function.
2. Click on your Function.
3. Click on the Trigger tab.
4. Find the url copy it.
5. paste it in a browser.
6. You should see the result of your secret info.

# Limit To Just Your Domain
Now that we know it works we will limit to just our specific domain, in my case it's 'https://ahead.nz*'. This means that only requests coming from that domain will be permitted access to collect that api information.
1. Go to Google Cloud Run Function.
2. Click on your Function.
3. Edit the function, go to the code.
4. Change the cors:
    ```
    const corsOptions = {
       origin: '*', // This should allow all origins for now
       // origin: ['https://ahead.nz', 'https://www.ahead.nz', 'http://ahead.nz', 'http://www.ahead.nz'],
       optionsSuccessStatus: 200 // some legacy browsers (IE11, various SmartTVs) choke on 204
    };
    ```
5. Change The origin to your domains.
6. Update the functions.http just below this:
   ```
   functions.http('getdbcreds', (req, res) => {
    corsHandler(req, res, async () => {
    // Check referer header
    const allowedDomains = ['https://ahead.nz', 'https://www.ahead.nz'];
    const referer = req.headers.referer;

    if (!allowedDomains.some(domain => referer.startsWith(domain))) {
      res.status(403).send('Access denied');
      return;
    }
   
    try {
      const [version] = await client.accessSecretVersion({
        name: 'projects/uk-food-donation/secrets/sql-dbname/versions/latest'
      });

      const dbname = version.payload.data.toString('utf8');
      res.status(200).send({ dbname });
    } catch (error) {
      res.status(500).send(`Error retrieving the API key: ${error.message}`);
    }
     });
   });
   ```
7. Remove the other functions.https that was there before.

I followed all the steps from these two tutorials was not able to connect my GCP Cloud Run Function with GCP Postgresql:
    * https://cloud.google.com/sql/docs/postgres/connect-instance-cloud-functions
    * https://cloud.google.com/sql/docs/postgres/connect-functions#python_1
When I would run the url in the browser from the Cloud Run Function it would just read "upstream request timeout" as well as the logs saying the same thing. Maybe it's possible.

# Concluding Thoughts

I spent a week on this project hoping to visualize the data in a cool way, a solid 40 hours with no result. I need to stop this project. Initially it was to keep myself sharp on these topics so that when I'd interview I would have something, a project to point to. I envisioned myself posting on LinkedIn "hey look at this cool thing I made! It visualizes the route for excess items at foodbanks that they could deliver to nearby foodbanks that need those particular items! If someone was willing to drive around a bit it would practically help the people of UK" but it never happened. The conversation won't happen and the post won't happen. I have 300 applications out over the past six months, five interviews, 4 of which said or will say "no", 1 said "yes" and then fired me within a month of working there for being too slow. My ship has sailed and I'm okay with it. It's a saturated market. At this point in my career I was anticipating grinding through Leetcode problems, failing some teachnical problem-solving interviews but passing one - stacking interviews one after another and solving technical problems like it was my full time job, but I can't even get an interview. The statistics are that I have a 0.016% chance of getting an interview after applying for any entry-level, developer or data related position. I'm just accepting what is.

I will instead pivot careers, one more time, and hopefully for the last time in a long time. I will become a teacher. I think I'll enjoy it. I like high school aged people. They're great. I feel like I am permitted to be goofy around youth and have fun. I think math and coding are great skills and would love to teach not just math but resilience. Sticking with a problem until it's completed. The math and the code are just the avenues to get there, they are not themselves the utlimate goal. The goal is hard work, perserverance for yourself because you envision the final product and are excited about it. It's interesting as I'm writing this because I'm realizing I'm not completing a project, but it's more. It's more than just not completing a project I'm severing that particular hope - after six years of university I will not become a developer. I'm going through the greving process but I am okay with it. I will enjoy this new path. It will be challenging but it will also be rewarding.

There might be a chance that I can get a part-time developer related position from the states while I'm studying and receiving my teaching credential. Maybe a data-related consulting position? I actually got to consult for someone recently on a language model they're building. Who knows. But as far as the career goes, it's dead. 🫡 
