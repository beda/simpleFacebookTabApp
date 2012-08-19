SimpleFacebookTabApp
====================
Create a simple Facebook Tab Application using node.js

## Local Development
### Install dependencies
    npm install

    gem install foreman

    npm install jitsu -g

### Create Facebook Application for Local Development https://developers.facebook.com/apps/
#### Basic Info
    Sandbox Mode: Enabled
#### Page Tab
    Page Tab Name: SimpleFacebookTabApp Local
    Page Tab URL: http://127.0.0.1:8080

### Add Facebook Application to Facebook Tab
    http://www.facebook.com/dialog/pagetab?app_id=YOUR_APP_ID&next=YOUR_URL

### Set environment variables for foreman. Create .env file with the following content:
    LOCAL_FACEBOOK_APP_ID=yourAppID
    LOCAL_FACEBOOK_SECRET=yourAppSecret

### Start app
    foreman start

## Production
###Create Facebook Application for Production https://developers.facebook.com/apps/
#### Basic Info
    App Domains: nodejitsu.com
    Sandbox Mode: Enabled
#### Page Tab
    Page Tab Name: SimpleFacebookTabApp
    Page Tab URL: http://yoursubdomain.nodejitsu.com
    Secure Page Tab URL: https://yoursubdomain.nodejitsu.com
    comment: you need to use *.nodejitsu.com to be able to use https
#### Website with Facebook Login
    http://yoursubdomain.nodejitsu.com

### Set environment variables for nodejitsu
    jitsu env set FACEBOOK_APP_ID yourAppID
    jitsu env set FACEBOOK_SECRET yourAppSecret

### Add Facebook Application to Facebook Tab:
    http://www.facebook.com/dialog/pagetab?app_id=yourappID&next=http://yoursubdomain.nodejitsu.com

### Deploy app to nodejitsu
    jitsu deploy

## User Management with Kinvey http://www.kinvey.com/

### Create an account and add an app

### Add the keys to your .env file:
    KINVEY_APP_KEY=yourAppKey
    KINVEY_APPSECRET=yourAppSecret
    KINVEY_MASTERSECRET=yourMastersecret

### Set environment variables for nodejitsu
    jitsu env set KINVEY_APP_KEY yourAppKey
    jitsu env set KINVEY_APPSECRET yourAppSecret
    jitsu env set MASTERSECRET yourMastersecret