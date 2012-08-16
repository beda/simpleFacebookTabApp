SimpleFacebookTabApp
====================
Create a simple Facebook Tab Application using node.js

Setup Facebook & Nodejitsu
-----------------------

### Local Development
Run npm install
gem install foreman
Install jitsu (npm install jitsu -g)

Create Facebook Application for Local Development https://developers.facebook.com/apps/
#### Basic Info
Sandbox Mode: Enabled
#### Page Tab
Page Tab Name: SimpleFacebookTabApp
Page Tab URL: http://127.0.0.1:8080

Add Facebook Application to Facebook Tab
    http://www.facebook.com/dialog/pagetab?app_id=YOUR_APP_ID&next=YOUR_URL

Create .env file
    LOCAL_FACEBOOK_APP_ID=yourAppID
    LOCAL_FACEBOOK_SECRET=yourAppSecret

foreman start

### Production