# cloudflare-ddns
Bash script and instructions to automatically update a DNS record for a dynamically assigned public IP address using the Cloudflare API.

## Introduction
This script assumes that you have a registered domain set to Cloudflare DNS nameservers. The process first requires you to edit the cloudflare_ddns script with your API credentials and A record details. The script compares your current public IP address with the one associated with your domain name and updates your DNS A record if they differ. Periodically running this script in the background on your server ensures that that your DNS record is updated as soon as possible after your public IP address is changed by your ISP.

## Instructions

### Step 1: Setting CF_API_TOKEN
First create an API token. On your Cloudflare account homepage sidebar:

1. go to 'Manage Account' then 'Account API Tokens'
2. click 'Create Token'
3. click 'Use template' for 'Edit zone DNS'
4. include your domain as a 'Specific zone' under 'Zone resources'
5. click 'Continue to summary'
6. click 'Create Token'
7. copy the token and assigned it to CF_API_TOKEN in the cloudflare_ddns script.

### Step 2: Setting CF_ZONE_ID
On your Cloudflare account homepage, select your domain. Assign the hexadecimal string for 'Zone ID' under the 'API' header to CF_ZONE_ID in the cloudflare_ddns script.

### Step 3: Setting CF_RECORD_ID, CF_RECORD_NAME and CF_RECORD_PROXIED
On Cloudflare and on your domain page, navigate to 'DNS' and 'Records' in the side bar, then:

1. click 'Edit' if you have an A record, else 'Add record'
2. set 'Name' to you domain (e.g., mydomain.com) and assign this to CF_RECORD_NAME in the cloudflare_ddns script
3. set CF_RECORD_PROXIED to true or false in the cloudflare_ddns script if you want your domain proxied by Cloudflare or not
4. make the following Cloudflare API call using your CF_ZONE_ID and CF_API_TOKEN
```shell
curl -X GET "https://api.cloudflare.com/client/v4/zones/CF_ZONE_ID/dns_records" \
    -H "Authorization: Bearer CF_API_TOKEN" \
    -H "Content-Type: application/json"
```
5. find the A record associated with your domain (CF_RECORD_NAME) and set the hexadecimal string "id" of this record as CF_RECORD_ID in the cloudflare_ddns script.

### Step 4: Install cloudflare_ddns dependencies
```shell
sudo apt install curl jq
```

### Step 5: Run the script
Set the file as an executable and run:
```shell
chmod +x cloudflare_ddns
./cloudflare_ddns
```
The script prints a message indicating that either the IP address was updated, the IP address could not be updated or that the IP address is unchanged.

### Step 6: Run the script as a cron job
Edit your Cron Table file to run the script in the background every 10 min.
```shell
crontab -e
```
Add this line at the end of the file:
```shell
*/10 * * * * /path/to/cloudflare_ddns >> /path/to/cloudflare_ddns.log
```
You may specify other intervals or a schedule using Crontab syntax. Check the cloudflare_ddns.log periodically to confirm that the script is running.
