//
//  ZypeCommon.h
//  Zype
//
//  Created by ZypeTech on 1/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//
#ifndef Zype_ZypeCommon_h
#define Zype_ZypeCommon_h

#pragma mark - Client Settings

//Main app configuration for connecting to Zype property

#define kOAuth_ClientId @"0abb1362496c02161c538bcb00d1759a7dd62e72682fbc02c1dbdd7b67b89f68"
#define kAppKey @"1Z97ps2R0GRR20nEAUcup_QodI6dlLVGwRuoC3OVmS2kS1qFgap7E3uOkHBJWHft"
#define kRootPlaylistId @"5bb26bf5849e2d10af00d2ac"
#define kZypeAppId @"5bb79ff7676a1f143700034b"
#define kZypeSiteId @"5bace0565d3c1916b9000c45"

//OneSignal configuration for Push notifications
#define kOneSignalNotificationsKey @"" // Leave empty to not use One Signal
//Google Analytics configuration
#define kGoogleAnalyticsTracker @""
// AWS Pinpoint (Push Notifications)
//     Replace Zype/awsconfiguration.json before enabling.
//     App crashes when not configuration file is not valid
#define kEnableAwsPinpoint NO

//Social links on settings screen
#define kACFacebook @"https://www.facebook.com/<your_branch>"
#define kACWeb @"http://www.<your_branch>/"
#define kACInstagram @"http://www.instagram.com/<your_branch>"
#define kACTwitter @"https://twitter.com/<your_branch>"

#define kAutoplay YES

// Customizable Player Controls <BETA> (not recommended for use)
//  Feature still under development. Player may behave unexpectedly when enabled
#define kCustomPlayerControls NO

//Overall look of the app; selecting YES the app will be white, selecting NO the app will be dark
#define kAppColorLight NO

//Enable Gallery layout
#define kAppAppleTVLayout NO

//Show/Hide titles on thumbnails for playlist views on iPhone
#define kHidePlaylistTitles NO
#define kAppAppleTVLayoutShowThumbanailTitle NO

//Features Configuration
#define kFavoritesViaAPI NO
#define kSubscribeToWatchAdFree NO
#define kLibraryForPurchasesEnabled NO

// For sites that support EPG (Electronic Program Guide)
#define kEPGEnabled NO

// For downloads to function properly the video has to be transcoded with mp4 preset
#define kDownloadsEnabled NO
// Set to No to enforce downloads for only users that are signed in
#define kDownloadsForAllUsersEnabled NO

// Enable Zype Marketplace Connect
// NOTE: This is a gated feature that REQUIRES Zype to configure. Please reach out to Zype Support for help on setting up this feature.
#define kNativeSubscriptionEnabled NO
// Provide the Zype Plan IDs linked to native purchases
#define kZypeSubscriptionIds [NSArray arrayWithObjects: @"monthly_plan_id", @"yearly_plan_id", nil]

// If the Video is a ZypeLive video enable status polling
#define kLiveEventPolling NO

// Enable Video Sharing <BETA> (not recommended for use)
#define kShareVideoEnabled NO

// Enable to display playlist and video titles underneath each thumbnail image
#define kInlineTitleTextDisplay NO

// Enable to add live menu item
#define kLiveItemEnabled NO
#define kLiveVideoID @"5c8faa021d1f4314dd006203"

// Enable to show Publish At Date
#define kShowPublishedAtDate YES

// if enabled,make sure kSegmentAccountID is having correct value
#define kSegmentAnalyticsEnabled YES
#define kSegmentAnalyticsWriteKey @"N1ybwfgbQz2nSTPhVfKPAS8Py4jV6Agd"
// must have some value if kSegmentAnalytics is enabled
#define kSegmentAccountID @"test"

#define kClientColor    [UIUtil colorWithHex:0xF75532];
#define kTextPlaceholderColor [UIColor colorWithRed:0.72 green:0.72 blue:0.75 alpha:1.00]
#define kLightTintColor [UIColor colorWithRed:1.00 green:0.11 blue:0.38 alpha:1.00]
#define kLightLineColor [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:1.00]
#define kDarkTintColor [UIColor colorWithRed:0.20 green:0.43 blue:0.98 alpha:1.00]
#define kDarkLineColor [UIColor colorWithRed:0.30 green:0.30 blue:0.30 alpha:1.00]
#define kDarkThemeBackgroundColor [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.00]
#define kUniversalGray [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.00]
#define kCurrentAppColor (kAppColorLight) ? kLightTintColor : kDarkTintColor

// EPG Colors
#define kEPGDateViewColor (kAppColorLight) ? [UIColor whiteColor] : [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0]
#define kEPGTimeViewColor (kAppColorLight) ? [UIColor whiteColor] : [UIColor colorWithRed:44/255.0 green:44/255.0 blue:44/255.0 alpha:1.0]
#define kEPGChannelBackColor (kAppColorLight) ? kLightLineColor : [UIColor colorWithRed:49/255.0 green:49/255.0 blue:49/255.0 alpha:1.0]
#define kEPGChannelSeperatorColor (kAppColorLight) ? kLightLineColor : [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0]
#define kEPGCellColor (kAppColorLight) ? [UIColor whiteColor] : [UIColor blackColor]

#define kEPGHighlightColor [UIColor colorWithRed:238/255.0 green:150/255.0 blue:45/255.0 alpha:1.00]
#define kEPGAiringColor [UIColor colorWithRed:0.04 green:0.23 blue:0.30 alpha:1.00]

// colors of lock & unlock image
#define kLockColor      [UIUtil colorWithHex:0xFF0000]
#define kUnlockColor    [UIUtil colorWithHex:0x0000FF]

#define kUnlockTransparentEnabled NO

#define kViewCornerRounded 2.0f

#define kZypeTemplateVersion @"1.6.5.2"

#pragma mark - Base settings

#pragma mark MACROS
#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   -[startTime timeIntervalSinceNow]
#define kLoadTime @"Load Time"

#pragma mark analytics - Screen Names
#define kAnalyticsScreenNameLatest          @"Latest View"
#define kAnalyticsScreenNameHome            @"Home View"
#define kAnalyticsScreenNamePlaylist        @"Playlist: %@"
#define kAnalyticsScreenNameDownloads       @"Downloads View"
#define kAnalyticsScreenNameFavorites       @"Favorites View"
#define kAnalyticsScreenNameFavoritesDetail @"Favorites Detail"
#define kAnalyticsScreenNameHighlights      @"Highlights View"
#define kAnalyticsScreenNameMore            @"More View"
#define kAnalyticsScreenNameSettings        @"Settings View"
#define kAnalyticsScreenNameSettingsDetail  @"Settings Detail View"
#define kAnalyticsScreenNameSearchResults   @"Search Results View"
#define kAnalyticsScreenNameVideoDetail     @"Video Detail View"
#define kAnalyticsScreenNameSignIn          @"Sign In View"

#pragma mark analytics - Category
#define kAnalyticsCategoryButtonPressed     @"Button Press"
#define kAnalyticsCategoryVideoPlayed       @"Video Played"

#pragma mark analytics - Action
#define kAnalyticsActShareMenu              @"Share Menu"
#define kAnalyticsActFavorited              @"Favorited"
#define kAnalyticsActUnFavorited            @"Unfavorited"
#define kAnalyticsActDetailPressed          @"More Details"
#define kAnalyticsActSwitchPressed          @"Switch Pressed"
#define kAnalyticsActSearchString           @"Search String"

#pragma mark analytics - Label
#define kAnalyticsEventLabelShareMenu       @"Share Menu Opened"
#define kAnalyticsEventLabelTwit            @"Twitter Tapped"
#define kAnalyticsEventLabelFB              @"Facebook Tapped"
#define kAnalyticsEventLabelEMail           @"Email Tapped"
#define kAnalyticsEventLabelSMS             @"Message Tapped"
#define kAnalyticsEventLabelSMSSent         @"Shared Via SMS"
#define kAnalyticsEventLabelDetails         @"Content Details"
#define kAnalyticsCancelButtonLabel         @"Cancel Tapped"
#define kAnalyticsEventLabelAutoDLOn        @"Auto Download On"
#define kAnalyticsEventLabelAutoDLOff       @"Auto Download Off"
#define kAnalyticsEventLabelPushNoteOn      @"Push Notifications On"
#define kAnalyticsEventLabelPushNoteOff     @"Push Notifications Off"
#define kAnalyticsEventLabelWiFiOn          @"Download over WiFi On"
#define kAnalyticsEventLabelWiFiOff         @"Download over WiFi Off"
#define kAnalyticsEventLabelDLAudio         @"Download audio"
#define kAnalyticsEventLabelDLVideo         @"Download video"

// Category -> Action -> Label
// UI_Action
// Button Press
// Play

static const CGSize IphoneLayoutSize = {180, 100};
static const CGSize IpadLayoutSize = {225, 120};

static const CGSize IphonePosterLayoutSize = {90, 160};
static const CGSize IpadPosterLayoutSize = {126, 208};

#define kYellowColor    [UIUtil colorWithHex:0xEAA824]
#define kBlueColor      [UIColor colorWithRed:0.02 green:0.32 blue:0.64 alpha:1.0]
#define kLinkColor      [UIUtil colorWithHex:0x007AFF]
#define kSystemWhite    [UIUtil colorWithHex:0xE3E2DF]
#define kSystemBlue     [UIUtil colorWithHex:0x0091ff]
#define kDismissButtonColor [UIUtil colorWithHex:0x000000 alpha:0.5]
#define kFontRegular @"OpenSans"
#define kFontSemibold @"OpenSans-Semibold"
#define kFontBold @"OpenSans-Bold"
#define kFilterHeight 42
#define kFilterViewHeight 250
#define kFilterButtonMargin 25
#define kFilterButtonMarginTop 10
#define kActionButtonHeight 54
#define kWeekInterval (7 * 24 * 60 * 60)
#define kMidWeekInterval (3 * 24 * 60 * 60)
#define kDayInterval (24 * 60 * 60)
#define kSettingsHeaderHeight 45
#define kSettingsHeaderMargin 16
#define kKeyboardHeight 216
#define kKeyboardMargin 15
#define kPlayerControlHeight 40
#define kProgressViewMarginLeft 130
#define kProgressViewMarginRight 25
#define kProgressViewHeight 2
#define kWebPlayerDidEnterFullscreenNotification @"UIMoviePlayerControllerDidEnterFullscreenNotification"
#define kWebPlayerDidExitFullscreenNotification @"UIMoviePlayerControllerDidExitFullscreenNotification"
#define kMediaType_Audio @"mediaTypeAudio"
#define kMediaType_Video @"mediaTypeVideo"
#define kEntityVideo @"Video"
#define kEntityPlaylist @"Playlist"
#define kEntityPresentableObject @"PresentableObject"
#define kEntityZObject @"ZObject"
#define kEntityPager @"Pager"
#define kEntityPlaylistVideo @"PlaylistVideo"
#define kEntityGuest @"Guest"
#define kEntityFavorite @"Favorite"
#define kEntityLibrary @"LibraryVideo"
#define kEntityNotification @"Notification"
#define kEntityUserPreferences @"UserPreferences"
#define kNotificationStatus_New @"new"
#define kNotificationStatus_Updated @"updated"
#define kNotificationStatus_Removed @"removed"
#define kNotificationStatus_Scheduled @"scheduled"
#define kZypeURL @"http://www.zype.com"
#define kLiveStream @"http://www.zype.com/archive.html"
#define kToSPolicyHTML @"<html><body style=\"color:black;font-family:'Open Sans';\">%@</body></html>"

#define kNotificationNameLiveStreamUpdated @"kNotificationNameLiveStreamUpdated"

#pragma mark - NSUserDefault setting
#define kSettingKey_SignInStatus @"signInStatus"
#define kSettingKey_ConsumerId @"consumerId"
#define kSettingKey_VideoIdNowPlaying @"videoIdNowPlaying"
#define kSettingKey_AutoDownloadContent @"autoDownloadContent"
#define kSettingKey_LiveShowNotification @"liveShowNotification"
#define kSettingKey_DownloadWifiOnly @"downloadWifiOnly"
#define kSettingKey_AutoRemoveWatchedContent @"autoRemoveWatchedContent"
#define kSettingKey_DownloadPreferences @"downloadPreferences"
#define kSettingKey_DownloadAudio @"downloadAudio"
#define kSettingKey_DownloadVideo @"downloadVideo"
#define kSettingKey_SubscribeUrl @"settingSubscribeUrl"
#define kSettingKey_SubscribeMessage @"Please subscribe to get full access to the video!"
#define kSettingKey_SubscribeButtontitle @"Subscribe"
#define kSettingKey_SubscribeCancelButtonTitle @"Not Now"
#define kSettingKey_SubscribeTitleMessage @"Please Subscribe"
#define kSettingKey_HelpUrl @"settingHelpUrl"
#define kSettingKey_NoDownloadsMessage @"settingNoDownloadsMessage"
#define kSettingKey_NoFavoritesMessage @"settingNoFavoritesMessage"
#define kSettingKey_ShareSubject @"shareSubject"
#define kSettingKey_ShareMessage @"shareMessage"
#define kSettingKey_Terms @"Terms & Conditions and Statement of Privacy"//terms
#define kSettingKey_PrivacyPolicy @"privacy_policy"
#define kSettingKey_NotSubscribed @"not-subscribed"
#define kSettingKey_OnAir @"on-air"
#define kSettingKey_OffAir @"off-air"
#define kSettingKey_IsOnAir @"isOnAir"
#define kSettingKey_LiveStreamId @"liveStreamId"
#define kSettingKey_DownloadsFeature @"downloadFeature"
#define kSettingKey_Subscriptions @"subscriptionNames"

// Used for Marketplace Connect - Required for iTunes Connect Paid Applications Guideline 3.1.2
// Note: If you modify the disclaimer language, make sure it complies with iTunes requirements and provides the appropriate info to the user
#define kString_SubscriptionDisclaimer @"Payment will be charged to your iTunes Account after confirming your purchase. Your subscription will renew automatically unless it is turned off at least 24 hours before the end of the period. <br><br> Your subscription can be managed in the Account Settings of the App Store. For more info, please check our %@ and %@" // %@ include privacy and terms links
#define kPrivacyPolicyUrl @"privacy_policy_url"
#define kTermsOfServiceUrl @"terms_of_service_url"

#pragma mark - Strings
#define kString_SigningIn @"Signing In..."
#define kString_ErrorUsername @"Your email must be provided."
#define kString_ErrorPassword @"Your password must be provided."
#define kString_TitleSignInFail @"Authentication Failed"
#define kString_MessageSignInFail @"Please ensure your credentials are correct and try again."
#define kString_MessageRegisterFail @"We're sorry, that email address already belongs to an account. Please click \"Sign in\" below if you'd like to sign into your existing account."
#define kString_TitleResetPasswordFail @"Reset Password Failed"
#define kString_DownloadAudio @"Download Audio"
#define kString_DownloadVideo @"Download Video"
#define kString_DownloadingAudio @"Downloading Audio..."
#define kString_DownloadingVideo @"Downloading Video..."
#define kString_AlreadyDownloaded @"Already downloaded"
#define kString_TitleDownloadFail @"Download Failed"
#define kString_MessageDownloadFail @"Downloading is only supported on wifi. Please connect your device to wifi and try again."
#define kString_MessageNoDownloadFile @"We were not able to retrieve the file."
#define kString_TitleStreamFail @"Streaming Failed"
#define kString_TitleStreamFail @"Streaming Failed"
#define kString_MessageNoAudioStream @"There's no audio streaming."
#define kString_MessageNoVideoStream @"There's no video streaming."
#define kString_TitleShareFail @"Sharing Failed"
#define kString_MessageNoEmail @"Your device doesn't support email."
#define kString_MessageNoSms @"Your device doesn't support SMS."
#define kString_MessageSmsFail @"Failed to send SMS."
#define kString_TitleNoConnection @"No Connection Detected"
#define kString_MessageNoConnection @"Your device's internet connection isn't working. Please check your connection and try again."

#pragma mark - OAuth 2
//#define KOAuth_GetTokenDomain @"login.uat.zype.com"
#define KOAuth_GetTokenDomain @"login.zype.com"
#define KOAuth_RegisterDomain @"https://api.zype.com/consumers?app_key=%@"
#define KOAuth_ForgotPasswordDomain @"https://api.zype.com/consumers/forgot_password?app_key=%@"
#define kOAuth_GetToken @"https://%@/oauth/token"
#define kOAuth_GetTokenInfo @"https://%@/oauth/token/info?access_token=%@"

#define kOAuth_GrantType @"password"
#define kOAuth_GrantTypeRefresh @"refresh_token"
#define kOAuthProperty_Username @"username"
#define kOAuthProperty_Password @"password"
#define kOAuthProperty_Email @"email"
#define kOAuthProperty_Consumer @"consumer"
#define kOAuthProperty_ClientId @"client_id"
#define kOAuthProperty_GrantType @"grant_type"
#define kOAuthProperty_RefreshToken @"refresh_token"
#define kOAuthProperty_Subscription @"subscription_count"

#pragma mark - Zype API
//#define kApiDomain @"api.uat.zype.com"
#define kApiDomain @"api.zype.com"

//#define kApiPlayerDomain @"player.uat.zype.com"
#define kApiPlayerDomain @"player.zype.com"


#define kDeviceId @"5429b1c769702d2f7c120000"
#define kGetVideos @"https://%@/videos/?app_key=%@&page=%@"

#define kGetPlaylist @"https://%@/playlists/%@?app_key=%@"
#define kGetPlaylists @"https://%@/playlists/?app_key=%@&parent_id=%@&per_page=500"
//#define kGetPlaylists @"https://%@/playlists/?app_key=%@"

#define kGetConsumer @"https://%@/consumers/?app_key=%@&id=%@"

#define kGetVideosWithFilter @"https://%@/videos/?app_key=%@%@&page=%@"
#define kGetVideosFromPlaylist @"https://%@/playlists/%@/videos?app_key=%@&page=%@"

#define kGetPlayer @"https://%@/embed/%@?access_token=%@&uuid=[uuid]&app_name=[app_name]&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=[device_type]&device_make=[device_make]&device_model=[device_model]&device_ifa=[device_ifa]&vpi=[vpi]&app_id=[app_id]&device_ua=[device_ua]"
#define kGetPlayerForGuest @"https://%@/embed/%@?app_key=%@&uuid=[uuid]&app_name=[app_name]&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=[device_type]&device_make=[device_make]&device_model=[device_model]&device_ifa=[device_ifa]&vpi=[vpi]&app_id=[app_id]&device_ua=[device_ua]"
#define kGetPlayerForHighlight @"https://%@/embed/%@?access_token=%@&uuid=[uuid]&app_name=[app_name]&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=[device_type]&device_make=[device_make]&device_model=[device_model]&device_ifa=[device_ifa]&vpi=[vpi]&app_id=[app_id]&device_ua=[device_ua]"
#define kGetDownloadVideoUrl @"https://%@/embed/%@?download=true&access_token=%@&uuid=[uuid]&app_name=[app_name]&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=[device_type]&device_make=[device_make]&device_model=[device_model]&device_ifa=[device_ifa]&vpi=[vpi]&app_id=[app_id]&device_ua=[device_ua]"
#define kGetDownloadVideoUrlForGuest @"https://%@/embed/%@?download=true&app_key=%@&uuid=[uuid]&app_name=[app_name]&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=[device_type]&device_make=[device_make]&device_model=[device_model]&device_ifa=[device_ifa]&vpi=[vpi]&app_id=[app_id]&device_ua=[device_ua]"
#define kGetDownloadAudioUrl @"https://%@/embed/%@.json?access_token=%@&download=true&uuid=[uuid]&app_name=[app_name]&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=[device_type]&device_make=[device_make]&device_model=[device_model]&device_ifa=[device_ifa]&vpi=[vpi]&app_id=[app_id]&device_ua=[device_ua]"
#define kGetDownloadAudioUrlForGuest @"https://%@/embed/%@.json?app_key=%@&download=true&uuid=[uuid]&app_name=[app_name]&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=[device_type]&device_make=[device_make]&device_model=[device_model]&device_ifa=[device_ifa]&vpi=[vpi]&app_id=[app_id]&device_ua=[device_ua]"
#define kGetPlayerAudioUrl @"https://%@/embed/%@.json?access_token=%@&audio=true&uuid=[uuid]&app_name=[app_name]&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=[device_type]&device_make=[device_make]&device_model=[device_model]&device_ifa=[device_ifa]&vpi=[vpi]&app_id=[app_id]&device_ua=[device_ua]"
#define kGetPlayerAudioUrlForGuest @"https://%@/embed/%@.json?app_key=%@&audio=true&uuid=[uuid]&app_name=[app_name]&app_bundle=[app_bundle]&app_domain=[app_domain]&device_type=[device_type]&device_make=[device_make]&device_model=[device_model]&device_ifa=[device_ifa]&vpi=[vpi]&app_id=[app_id]&device_ua=[device_ua]"
//#define kGetDownloadAudioUrl @"https://%@/embed/%@?audio=true&access_token=%@"
//
//#define kGetStreamAudioUrl @"https://%@/livestream/%@?autoplay=true&api_key=%@&audio=true"

#define kGetStreamAudioUrl @"https://%@/manifest/live/%@.m3u8?access_token=%@&type=audio"
#define kGetGuests @"https://%@/zobjects?zobject_type=guest&app_key=%@&video_id=%@&page=%@"
#define kGetHighlights @"https://%@/videos?app_key=%@&category[Highlight]=true&page=%@"
#define kGetVideoById @"https://%@/videos/?app_key=%@&id=%@"
#define kLibraryGetVideoById @"https://%@/videos/?access_token=%@&id=%@"


#define kGetFavorites    @"https://%@/consumers/%@/video_favorites/?access_token=%@&page=%@"
#define kGetLibrary      @"https://%@/consumer/videos?access_token=%@&page=%@"

#define kConsumerByIdURL @"https://%@/consumer/%@/?acccess_token=%@"


#define kPostFavorite @"https://%@/consumers/%@/video_favorites/?access_token=%@&video_id=%@"
#define kDeleteFavorite @"https://%@/consumers/%@/video_favorites/%@/?access_token=%@"
#define kGetSearchedVideos @"https://%@/videos?app_key=%@&q=%@&page=%@&playlist_id.inclusive=%@"
#define kGetAppSetting @"https://%@/zobjects?zobject_type=iphone_settings&app_key=%@"
#define kGetAppLiveStreamSettings @"https://%@/zobjects?zobject_type=limit_livestream&app_key=%@"
#define kGetAppContent @"https://%@/zobjects?zobject_type=content&app_key=%@"
#define kGetNotifications @"https://%@/zobjects?zobject_type=notifications&app_key=%@&page=%@"
#define kGetLiveStream @"https://%@/videos?on_air=true&app_key=%@&sort=created_at&order=desc"
#define kGetLiveStreamPlayer @"https://%@/manifest/live/%@.m3u8?app_key=%@"
#define kBackgroundSession @"backgroundSession"
#define kZObjectContent @"https://%@/zobjects/?app_key=%@&zobject_type=%@&page=1&per_page=500&keywords=&sort=priority&order=desc"
//#define kZObjectContent @"https://api.zype.com/zobjects/?app_key=%@&zobject_type=tvos_settings&page=1&per_page=500&keywords="
//IKuC8xERY-oYRxQfE6c1HSeRrxKcpCwcsPr614RfaxCkYsJLgwpBkpkEo88EsyWr&zobject_type=top_playlists&page=1&per_page=500&keywords=&sort=priority&order=desc

#define kGetGuides @"https://%@/program_guides?app_key=%@&per_page=%d"
#define kGetGuidePrograms @"https://%@/program_guides/%@/entries?app_key=%@&per_page=500&sort=%@&order=%@&start_time.gte=%@&end_time.lte=%@"

#define kApiConsumerURL            @"https://api.zype.com/consumers/?app_key=%@&id=%@"
#define kApiSubscriptionPlanURL    @"https://api.zype.com/plans/"
#define kApiMarketPlaceURL         @"https://mkt.zype.com/v1/itunes/"

#define kAppKey_AccessToken        @"access_token"
#define kAppKey_RefreshToken       @"refresh_token"
#define kAppKey_ConsumerId         @"resource_owner_id"
#define kAppKey_Id                 @"_id"
#define kAppKey_VideoId            @"video_id"
#define kAppKey_VideoTitle         @"video_title"
#define kAppKey_Video_ConsumerId   @"consumer_id"
#define kAppKey_TransactionType    @"transaction_type"
#define kAppKey_SiteId             @"site_id"
#define kAppKey_Pagination         @"pagination"
#define kAppKey_Pages              @"pages"
#define kAppKey_NextPage           @"next"
#define kAppKey_CurrentPage        @"current"
#define kAppKey_Response           @"response"
#define kAppKey_Body               @"body"
#define kAppKey_Files              @"files"
#define kAppKey_Advertising        @"advertising"
#define kAppKey_Analytics          @"analytics"
#define kAppKey_Beacon             @"beacon"
#define kAppKey_Dimensions         @"dimensions"
#define kAppKey_Schedule           @"schedule"
#define kAppKey_Outputs            @"outputs"
#define kAppKey_Url                @"url"
#define kAppKey_Name               @"name"
#define kAppKey_Player             @"player"
#define kApiKey_PlayerWeb          @"web"
#define kAppKey_CreatedAt          @"created_at"
#define kAppKey_PublishedAt        @"published_at"
#define kAppKey_UpdatedAt          @"updated_at"
#define kAppKey_Priority           @"priority"
#define kAppKey_Type               @"type"
#define kAppKey_Description        @"description"
#define kAppKey_Thumbnails         @"thumbnails"
#define kAppKey_Pictures           @"pictures"
#define kAppKey_Images             @"images"
#define kAppKey_Width              @"width"
#define kAppKey_At                 @"_at"
#define kAppKey_Time               @"time"
#define kAppKey_Categories         @"categories"
#define kAppKey_Title              @"title"
#define kAppKey_Layout             @"layout"
#define kAppKey_Value              @"value"
#define kAppKey_Keywords           @"keywords"
#define kAppKey_ZobjectIds         @"zobject_ids"
#define kAppKey_SubscribeUrl       @"subscribe_url"
#define kAppKey_HelpUrl            @"help_url"
#define kAppKey_NoDownloadsMessage @"no_downloads_message"
#define kAppKey_NoFavoritesMessage @"no_favorites_message"
#define kAppKey_DownloadedUrl      @"downloaded_url"
#define kAppKey_Type               @"type"
#define kAppKey_ShareSubject       @"share_subject"
#define kAppKey_ShareMessage       @"share_message"

#endif

