# cf-ddns
A Dockerized Shell script for updating your DNS record when using a dynamically assigned public IP address with the [Cloudflare API](https://developers.cloudflare.com/api/operations/dns-records-for-a-zone-update-dns-record). The script can run in a Docker container or as-is. 
Ideal to use when you didn't receive a static IP address from your ISP.

This is a fork from [weberdak's cloudflare-ddns](https://github.com/weberdak/cloudflare-ddns) repo.


<br />


## Introduction
 The script compares your current public IP address with the one associated with your domain name at Cloudflare and updates your DNS record if they differ. It is the intention that the script runs periodically in the background to ensure that your DNS record is updated as soon as possible after your public IP address is changed by your ISP.

 The script checks your current IP address using https://ipv4.icanhazip.com/, and requests the IP address in your DNS record from the Cloudflare API afterwards. Depending on the match between the two, the script either updates your DNS record to your current IP address or leaves it alone. 

<br />

## Instructions

This script assumes that you have a registered domain set to Cloudflare DNS nameservers. The process first requires you to edit the cf_ddns script with your API credentials and A record details.

<br />

### Step 1: Setting CF_API_TOKEN
First, create an API token. On your Cloudflare account homepage sidebar:

1. go to 'Manage Account' then 'Account API Tokens'
2. click 'Create Token'
3. click 'Use template' for 'Edit zone DNS'
4. include your domain as a 'Specific zone' under 'Zone resources'
5. click 'Continue to summary'
6. click 'Create Token'
7. copy the token and assigned it to CF_API_TOKEN in the cf_ddns script.

### Step 2: Setting CF_ZONE_ID
On your Cloudflare account homepage, select your domain. Assign the hexadecimal string for 'Zone ID' under the 'API' header to CF_ZONE_ID in the cf_ddns script.

### Step 3: Setting CF_RECORD_ID, CF_RECORD_NAME and CF_RECORD_PROXIED
On Cloudflare and on your domain page, navigate to 'DNS' and 'Records' in the side bar, then:

1. click 'Edit' if you have an A record, else 'Add record'
2. set 'Name' to you domain (e.g., mydomain.com) and assign this to CF_RECORD_NAME in the cf_ddns script
3. set CF_RECORD_PROXIED to true or false in the cf_ddns script if you want your domain proxied by Cloudflare or not
4. make the following Cloudflare API call using your CF_ZONE_ID and CF_API_TOKEN

```shell
curl -X GET "https://api.cloudflare.com/client/v4/zones/CF_ZONE_ID/dns_records" \
    -H "Authorization: Bearer CF_API_TOKEN" \
    -H "Content-Type: application/json"
```

5. find the A record associated with your domain (CF_RECORD_NAME) and set the hexadecimal string "id" of this record as CF_RECORD_ID in the cf_ddns script.

<br />

## Running in a Docker container
After filling in the information from the first 3 steps, you can use `docker compose` to build and run your container immediately, or build your image first and run the Docker run command afterwards. The instructions below are irrelevant to the Docker method.  

<br />

## Running the script as-is
If you want to run the script on a machine without Docker, make sure to update the [Shebang](https://en.wikipedia.org/wiki/Shebang_%28Unix%29#Examples) in the `cf_ddns` file to the one for your environment, as it is currently set on `#!/bin/sh`.

### Step 1: Install dependencies
On Debian-based distro's:

```shell
sudo apt install curl jq
```

### Step 2: Run the script
Set the file as an executable and run:

```shell
chmod +x cf_ddns
./cf_ddns
```

The script prints a message indicating that either the IP address was updated, the IP address could not be updated or that the IP address is unchanged.

### Step 3: Run the script as a cron job
Edit your Cron Table file to run the script in the background every 10 min.

```shell
crontab -e
```

Add this line at the end of the file:

```shell
*/10 * * * * /path/to/cf_ddns >> /path/to/cf_ddns.log
```

(Currently set on an interval of 10 minutes). 
You may specify other intervals or a schedule using Crontab syntax (try using [crontab.guru](https://crontab.guru/)). Check the cf_ddns.log periodically to confirm that the script is running.
