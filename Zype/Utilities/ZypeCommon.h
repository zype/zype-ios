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

#define kOAuth_ClientId @"efff34ee145c7bdc8a8408a339571005f8bcdf2fb0ae5dfd0dbb248188daaf54"
#define kOAuth_ClientSecret @"0fdedb3cf72afa6b37fabfbe100e2a2db5d6f4ecdbfe71eb53c223d722201a1d"
#define kAppKey @"HQokZlmb_bsw1uYYCEVP5UQis08D9tDJgRrCtAStwJ7HmjBovVAMNz1WjpNJE-KU"

#define kRootPlaylistId @"577e65c85577de0d1000c1ee"
#define kOneSignalNotificationsKey @""
#define kGoogleAnalyticsTracker @""

#define kACFacebook @"https://www.facebook.com/<your_branch>"
#define kACWeb @"http://www.<your_branch>/"
#define kACInstagram @"http://www.instagram.com/<your_branch>"
#define kACTwitter @"https://twitter.com/<your_branch>"

#define kMonthlySubscription @"monthly_subscription"
#define kYearlySubscription @"yearly_subscription"

#define kAppColorLight NO
#define kAppAppleTVLayout YES
#define kAppAppleTVLayoutShowThumbanailTitle NO

#define kClientColor    [UIUtil colorWithHex:0xF75532];
#define kTextPlaceholderColor [UIColor colorWithRed:0.72 green:0.72 blue:0.75 alpha:1.00]
#define kLightTintColor [UIColor colorWithRed:1.00 green:0.11 blue:0.38 alpha:1.00]
#define kLightLineColor [UIColor colorWithRed:0.70 green:0.70 blue:0.70 alpha:1.00]
#define kDarkTintColor [UIColor colorWithRed:0.20 green:0.43 blue:0.98 alpha:1.00]
#define kDarkLineColor [UIColor colorWithRed:0.30 green:0.30 blue:0.30 alpha:1.00]
#define kDarkThemeBackgroundColor [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:1.00]
#define kUniversalGray [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.00]
#define kCurrentAppColor (kAppColorLight) ? kLightTintColor : kDarkTintColor

#define kViewCornerRounded 2.0f

#define kFavoritesViaAPI NO
#define kSubscribeToWatchAdFree NO
#define kDownloadsEnabled YES
#define kNativeSubscriptionEnabled NO
#define kDownloadsForAllUsersEnabled NO
#define kShareVideoEnabled NO

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

static const CGSize IphonePosterLayoutSize = {100, 150};
static const CGSize IpadPosterLayoutSize = {120, 180};

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
#define kEntityNotification @"Notification"
#define kNotificationStatus_New @"new"
#define kNotificationStatus_Updated @"updated"
#define kNotificationStatus_Removed @"removed"
#define kNotificationStatus_Scheduled @"scheduled"
#define kZypeURL @"http://www.zype.com"
#define kLiveStream @"http://tacs.zype.com/archive.html"
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
#define kSettingKey_SubscribeMessage @"Please subscribe to get full access to the Luis Show!"
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

#pragma mark - Strings
#define kString_SigningIn @"Signing In..."
#define kString_ErrorUsername @"Your email must be provided."
#define kString_ErrorPassword @"Your password must be provided."
#define kString_TitleSignInFail @"Authentication Failed"
#define kString_MessageSignInFail @"Please ensure your credentials are correct and try again."
#define kString_DownloadAudio @"Download Audio"
#define kString_DownloadVideo @"Download Video"
#define kString_DownloadingAudio @"Downloading Audio..."
#define kString_DownloadingVideo @"Downloading Video..."
#define kString_AlreadyDownloaded @"Already downloaded"
#define kString_TitleDownloadFail @"Download Failed"
#define kString_MessageDownloadFail @"Downloading is set to Wifi only. Please go to settings if you want to change it."
#define kString_MessageNoDownloadFile @"We were not able to retrieve the file."
#define kString_TitleStreamFail @"Streaming Failed"
#define kString_TitleStreamFail @"Streaming Failed"
#define kString_MessageNoAudioStream @"There's no audio streaming."
#define kString_MessageNoVideoStream @"There's no video streaming."
#define kString_TitleShareFail @"Sharing Failed"
#define kString_MessageNoEmail @"Your device doesn't support email."
#define kString_MessageNoSms @"Your device doesn't support SMS."
#define kString_MessageSmsFail @"Failed to send SMS."

#pragma mark - OAuth 2
//#define KOAuth_GetTokenDomain @"login.uat.zype.com"
#define KOAuth_GetTokenDomain @"login.zype.com"
#define KOAuth_RegisterDomain @"https://api.zype.com/consumers?app_key=%@"
#define kOAuth_GetToken @"https://%@/oauth/token"
#define kOAuth_GetTokenInfo @"https://%@/oauth/token/info?access_token=%@"

#define kOAuth_GrantType @"password"
#define kOAuth_GrantTypeRefresh @"refresh_token"
#define kOAuthProperty_Username @"username"
#define kOAuthProperty_Password @"password"
#define kOAuthProperty_Email @"email"
#define kOAuthProperty_Consumer @"consumer"
#define kOAuthProperty_ClientId @"client_id"
#define kOAuthProperty_ClientSecret @"client_secret"
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
#define kGetPlayer @"https://%@/embed/%@?access_token=%@"
#define kGetPlayerForGuest @"https://%@/embed/%@?app_key=%@"
#define kGetPlayerForHighlight @"https://%@/embed/%@?access_token=%@"
#define kGetDownloadVideoUrl @"https://%@/embed/%@?download=true&access_token=%@"
#define kGetDownloadVideoUrlForGuest @"https://%@/embed/%@?download=true&app_key=%@"
#define kGetDownloadAudioUrl @"https://%@/embed/%@.json?access_token=%@&download=true"
#define kGetDownloadAudioUrlForGuest @"https://%@/embed/%@.json?app_key=%@&download=true"
#define kGetPlayerAudioUrl @"https://%@/embed/%@.json?access_token=%@&audio=true"
//#define kGetDownloadAudioUrl @"https://%@/embed/%@?audio=true&access_token=%@"
//
//#define kGetStreamAudioUrl @"https://%@/livestream/%@?autoplay=true&api_key=%@&audio=true"

#define kGetStreamAudioUrl @"https://%@/manifest/live/%@.m3u8?access_token=%@&type=audio"
#define kGetGuests @"https://%@/zobjects?zobject_type=guest&app_key=%@&video_id=%@&page=%@"
#define kGetHighlights @"https://%@/videos?app_key=%@&category[Highlight]=true&page=%@"
#define kGetVideoById @"https://%@/videos/?app_key=%@&id=%@"


#define kGetFavorites    @"https://%@/consumers/%@/video_favorites/?access_token=%@&page=%@"


#define kConsumerByIdURL @"https://%@/consumer/%@/?acccess_token=%@"


#define kPostFavorite @"https://%@/consumers/%@/video_favorites/?access_token=%@&video_id=%@"
#define kDeleteFavorite @"https://%@/consumers/%@/video_favorites/%@/?access_token=%@"
#define kGetSearchedVideos @"https://%@/videos?app_key=%@&q=%@&page=%@"
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

#define kApiConsumerURL            @"https://api.zype.com/consumers/?app_key=%@&id=%@"

#define kAppKey_AccessToken        @"access_token"
#define kAppKey_RefreshToken       @"refresh_token"
#define kAppKey_ConsumerId         @"resource_owner_id"
#define kAppKey_Id                 @"_id"
#define kAppKey_VideoId            @"video_id"
#define kAppKey_Pagination         @"pagination"
#define kAppKey_Pages              @"pages"
#define kAppKey_NextPage           @"next"
#define kAppKey_CurrentPage        @"current"
#define kAppKey_Response           @"response"
#define kAppKey_Body               @"body"
#define kAppKey_Files              @"files"
#define kAppKey_Advertising        @"advertising"
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
