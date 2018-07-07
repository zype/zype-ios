# Zype iOS Recipe

This document outlines step-by-step instructions for creating and publishing an iOS app powered by Zype's Endpoint API service and app production software and SDK template.

## Requirements and Prerequisites

#### Technical Contact
IT or developer support strongly recommended. Completing app submission and publishing requires working with app bundles and IDE.

#### Mac with XCode installed
In order to compile, run, and package an app you need the latest version of XCode to be installed on your Mac computer. XCode can be downloaded from the [App Store](https://developer.apple.com/xcode/).

#### Mac with Cocoapods installed
You'll need to have Cocoapods installed in order to perform pod installs. To install them on your Mac, follow the [Cocoapods guide](https://guides.cocoapods.org/using/getting-started.html).

#### Enrollment in the Apple Developer Program
The Apple Developer Program can be enrolled in via [Apple's website](https://developer.apple.com/programs/).

## Creating a New App with the SDK Template

#### Generating the bundle and running the app

1. In order to generate an iOS bundle using this SDK, you must first pull the latest source code from Zype's github repository. This can be found at "https://github.com/zype/zype-ios".

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQbFh2YWxmUTRlSkE"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQbFh2YWxmUTRlSkE" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

Select the green __"Clone or download"__ button on the right.

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQRFdyalE4LWp2b00"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQRFdyalE4LWp2b00" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

From here, there are two options to copy the files:

a. Click the __"Download ZIP"__ button on the bottom right. Then pick a folder to save the zipped files to.

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQTTNITmV1a3UyY28"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQTTNITmV1a3UyY28" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQNlhWb3kzeU9tb2s"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQNlhWb3kzeU9tb2s" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

Once the ZIP file is downloaded, open the file to reveal the contents.

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQY3JEZjRaMzF1RTA"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQY3JEZjRaMzF1RTA" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

__OR__

b.  Click the __"Git web URL"__ to highlight it and copy the URL.

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQNG1WZ3pHaWhhZWc"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQNG1WZ3pHaWhhZWc" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

Open terminal and __"cd"__ into the folder you want to save the files to.

##### Helpful command line tips for Terminal

    ```
    ls  ---> shows folders in current directory
    cd Downloads  ---> goes into downloads if available (see ls)
    cd Downloads/myproject  ---> goes into downloads/myproject if available (see ls)
    cd ..  ---> goes back one directory level up
    ```
    Clone the files into this folder by using the command __"git clone ***"__ and replace the "***" with the copied url. Press enter.

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQUnJoV05yaENPMEU"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQUnJoV05yaENPMEU" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

2. Now you have the source code. Open the application folder and find the file named __"Podfile"__. Open this file in the text editor of your choice and update the target name to match the name of the application.

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQaERZcHl5T19lc1E"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQaERZcHl5T19lc1E" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

3. __"cd"__ into this application folder in terminal then enter the command __"pod install"__. This generates a workspace that can be opened in Xcode.

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQZllTQ05ITXFranM"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQZllTQ05ITXFranM" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

4. Open the application workspace in Xcode ([Your_app_name].xcworkspace - NOT [Your_app_name].xcodeproj).

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQM2E5TWU2MVF4b3c"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQM2E5TWU2MVF4b3c" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

Once the code is indexed, you can run a simulation of the app. Click the play button in the top left of the screen and choose what device to run or simulate the program on.

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQZVhTMVB6WXZGSk0"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQZVhTMVB6WXZGSk0" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

#### Required app changes

Navigate to the file __"ZypeCommon.h"__ from Zype>Zype>Utilities
1. Change App key to match your app property
2. Update Oath keys to use login functionality
3. Change root playlist id to the top level playlist in the
4. Insert social links to your facebook, website, instagram and twitter.

#### Optional app changes

App configuration, Theme color, native subscription, and enabling downloads are toggled/altered the same way. In Xcode, the left side has a folder directory. Navigate to the file __"ZypeCommon.h"__ from Zype>Zype>Utilities.

<a href="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQU0xPbW15M1dlUEU"><img src="https://drive.google.com/uc?export=view&id=0BzMPADAfOuPQU0xPbW15M1dlUEU" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

1. Changing overall color of the app

Light theme: `#define kAppColorLight YES`

Dark theme: `#define kAppColorLight NO`

2. Changing theme. Please feel free to try our theme that will match Apple TV layout

`#define kAppAppleTVLayout YES`

For Apple TV theme you can enable/disable titles on top of thumnails. It is useful to disable them in case that your thumnails already provide title of the movie.

`kAppAppleTVLayoutShowThumbanailTitle NO`

3. Configuring the way favorites works

`#define kFavoritesViaAPI NO`

setting favorites via api to no will keep favorites functionaliy local to the app. Recommended

`#define kFavoritesViaAPI YES`

setting to yes will synchronize favorites with users Zype account, so it is available across different devices.

4. Subscribe to watch ad free

`define kSubscribeToWatchAdFree YES` not recommended

seetting to yes will show an extra button where users would be able to login. If users are logged in and have subscription the ads will not be shown. Please consult with

Zype support on how to properly configure this feature in your property.

5. Downloads functionality for offline video playback

Enable downloading: `#define kDownloadsEnabled YES`

Will add an extra tab with downloaded videos.

You can disable download functionality for guests by setting following flag. So, only users who are logged in would be able to download videos.

`#define kDownloadsForAllUsersEnabled NO`

6. Native subscription. Make sure that you know how to configure native subscription.

Enable native subscription: `#define kNativeSubscriptionEnabled YES` Not recommended

Disable native subscription: `#define kNativeSubscriptionEnabled NO`

(Optional)Setting up OneSignal Push Notification

1. Create account and follow OneSignal setup for iOS https://documentation.onesignal.com/docs/setup
2. You would need a key which you would insert in kOneSignalNotificationsKey
3. You woud need to have valid Push Certificate from Apple
4. Make sure to toggle Notifiactions in App features in XCode

By linking your app with OneSignal you would be able to sent Push notifcations to your users via OneSignal portal.

(Optional)Setting up Google Analytics
1. Create new property in https://analytics.google.com/analytics/web
2. Insert key from Google Analytics in kGoogleAnalyticsTracker

By linking your app to Google Analytics you would be able to have insights on how users are browsing your app.


#### Submitting to the Apple App Store

(Optional) You can automate your app build and upload process by using Fastlane. For more information, [see here](FASTLANE.md)

1. Once you like the look of your app you can archive and export the app into iTunesConnect. Helpful documentation about archiving and exporting your app can be found in [Apple's distribution documentation](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/TestingYouriOSApp/TestingYouriOSApp.html).

2. Submit the app to Apple's App Store by following [Apple submission documentation](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/SubmittingYourApp/SubmittingYourApp.html).

3. Once submitted, Apple will review your app against their submission guidelines. If your app is approved, they will update the app status and iTunes Connect users are notified of the status change.
