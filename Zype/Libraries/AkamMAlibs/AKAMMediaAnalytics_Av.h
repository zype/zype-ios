/*
 * AKAMMediaAnalytics_Av.h
 * Version - 01.17.3
 *
 *  This file is part of the Media Analytics, http://www.akamai.com
 * Media Analytics is a proprietary Akamai software that you may use and modify per the license agreement here:
 * http://www.akamai.com/product/licenses/mediaanalytics.html
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *
 *
 * Created by Tank, Um3sh on 10/29/12.
 *
 */

#import <Foundation/Foundation.h>

enum ParamType{
    EDGEAUTH=1
};

@interface AKAMMediaAnalytics_Av : NSObject

/*!
 * @function initWithConfigURL
 *
 * @abstract initWithConfigURL is MANDATORY
 *
 * @param
 *  1. url :    Instance of NSURL. This is a configuration URL that
 *              will be used by the plugin for generating and logging
 *              analytics data. This must not be nil
 *
 * @return void
 *
 * @discussion
 *      intWithConfigURL is Mandatory. App must call this API
 *      and this must be the first call to the Plugin
 *
 * @see https://control.akamai.com/dl/customers/PERF/Akamai_Media_Analytics_Plugin_Integration_Guide_IPhone_AVPlayer.pdf
 */
+ (void)initWithConfigURL:(NSURL*)url;
+ (void)iniConfigURLWithParams:(NSDictionary*)params paramTypes:(int)type;


/*!
 * @function setMADebugLogging
 *
 * @abstract setMADebugLogging is optional
 *
 * @param
 *  1. turnOn  :   A bool (YES / NO) value. setting YES turns on deubg logging
 *                  and setting NO turns off debug logging
 *
 * @return void
 *
 * @discussion
 *      Use this API to control debug logging of MA plugin.
 *      By default debug logging is on for debug build and off for release build.
 *      To turn off debug logs for debug build just set NO to this API.
 *
 */
+ (void)setDebugLogging:(BOOL)turnOn;


/*!
 * @function processWithAVPlayer
 *
 * @abstract processWithAVPlayer is MANDATORY
 *
 * @param
 *  1. player  :   Valid instance of AVPlayer or AVQueuePlayer
 *                      This must not be nil.
 *
 * @return void
 *
 * @discussion
 *      processWithAVPlayer is Mandatory. App must call this API after
 *      initializing plugin (with initWithConfigURL)
 *
 */
+ (void)processWithAVPlayer:(id)player;


/*!
 * @function setData
 *
 * @abstract setData is important for custom dimensions
 *
 * @param
 *  1. name         :   Dimension name to be set
 *  2. value        :   Value to be reported for the dimension (name param)
 *
 * @return void
 *
 * @discussion
 *      setData is really important when app wants set custome dimensions. Though it is
 *      not mandatory but it is always good to set custome dimensions for the possible
 *      values; which will give more insight in to the Analytics
 *
 */
+ (void)setData:(NSString*)name value:(NSString*)val;

/*!
 * @function setViewerId
 *
 * @abstract setViewerId is important
 *
 * @param
 *  1. viewerId :   Valid NSString to set viewerId. This must not be nil
 *
 * @return void
 *
 * @discussion
 *      setViewerId is not mandatory but really important when it comes to capture
 *      unique viewer
 *
 */
+ (void)setViewerId:(NSString*)viewerId;

/*!
 * @function getViewerId
 *
 * @abstract getViewerId is just a helper function
 *
 * @param
 *  none
 *
 * @return Returns a NSString pointer pointing to viewerId.
 *
 * @discussion
 *      getViewerId is not mandatory but it can provide viewerId
 * that plugin is using in the beacon. Return value can be nil.
 * App should check the validity of the viewerId
 *
 */
+ (NSString*)getViewerId;

/*!
 * @function setViewerDiagnosticId
 *
 * @abstract setViewerDiagnosticId is important for viewer diagnostic feature
 *
 * @param
 *  1. viewerDiagnosticsId  :   Valid instance of NSString.
 *
 * @return void
 *
 * @discussion
 *      setViewerDiagnosticId is not mandatory but really very important for
 *      viewer diagnostics feature
 *
 */
+ (void)setViewerDiagnosticId:(NSString *)viewerDiagnosticsId;

/*!
 * @function setSocialShareData
 *
 * @abstract setSocialShareData is important for social sharing feature
 *
 * @param
 *  1. name     :   Valid instance of NSString. Represents key
 *  2. value    :   Valid instance of NSString. Value for Key
 * @return void
 *
 * @discussion
 *      setSocialShareData is not mandatory but really very important for
 *      social sharing feature which captures social sharing
 *
 */
+ (void)setSocialShareData:(NSString*)name value:(NSString*)val;


/*!
 * @function setupAIS
 *
 * @abstract setupAIS is not madatory but used for identity servieces
 *
 * @param
 *  1. platform         :   Valid instance of NSString which represents platform to be used for query
 *  2. aisVersion       :   Valid instance of NSString represents ais version
 *  3. customDimensions :   This is optional can be nil or custom dimensions which needs to be fetched from AIS.
 *                          For more information on what can be set as part of customDimensions, please refer to 
 *                          integration guide
 *
 * @return void
 *
 * @discussion
 *      This API is mandaotry only if player is using AIS (Akamai Identity Services)
 *      plugin retrieves required values from AIS for analytics
 *
 */
+ (void)setupAIS:(NSString*)platform
      aisVersion:(NSString*)version
customDimensions:(NSDictionary*)custDimensions;


//AVPlayer seek / scrub API
/*!
 * @function beginScrub
 *
 * @abstract beginScrub is Not MANDATORY
 *
 * @param
 *  1. None
 *
 * @return void
 *
 * @discussion
 *      This API is mandaotry only if player is not manipulating
 *      rate property of AVPlayer whenever seek begins. For further
 *      information on manipulation of rate property check this out-
 *      http://developer.apple.com/library/ios/#samplecode/AVPlayerDemo/Introduction/Intro.html
 */
+ (void)beginScrub;


/*!
 * @function endScrub
 *
 * @abstract endScrub is Not MANDATORY
 *
 * @param
 *  1. None
 *
 * @return void
 *
 * @discussion
 *      This API is mandaotry only if player is not manipulating
 *      rate property of AVPlayer whenever seek ends. For further
 *      information on manipulation of rate property check this out-
 *      http://developer.apple.com/library/ios/#samplecode/AVPlayerDemo/Introduction/Intro.html
 *
 */
+ (void)endScrub;

/*!
 * @function handleTitleSwitch
 *
 * @abstract handleTitleSwitch is NOT MANDATORY
 *
 * @param
 *  1. customData: A dictionary object containing custom data key-value pair
 *  2. player: A valid player instance which plays the video.
 *
 * @return void
 *
 * @discussion
 *      For live stream there are use cases when title for the program
 *      is different then the currently playing title. When this needs to 
 *      be capured as a different session this API should be called.
 *
 */
+ (void)handleTitleSwitch:(NSDictionary*)customData
       withPlayerInstance:(id)palyer;


/*!
 * @function AVPlayerPlaybackCompleted
 *
 * @abstract AVPlayerPlaybackCompleted is MANDATORY
 *
 * @param
 *  1. None
 *
 * @return void
 *
 * @discussion
 *      Call this api when playback is completed either beacuse of
 *      error condition or video played completely
 *
 */
+ (void)AVPlayerPlaybackCompleted;

/*!
 * @function AVPlayerPlaybackCompleted
 *
 * @abstract AVPlayerPlaybackCompleted is MANDATORY
 *
 * @param
 *  1. error : error string if playback ended due to error, nil otherwise
 *
 * @return void
 *
 * @discussion
 *      Call this api when playback is completed either beacuse of
 *      error condition or video played completely. If playback completed
 *      due to error, please pass error as part of the parameters else 
 *      set nil
 *
 */
+ (void)AVPlayerPlaybackCompleted:(NSString*)error;


//Ad-integration APIs
/*!
 * @function handleAdLoaded
 *
 * @abstract It is important for ad-related metrics
 *
 * @param
 *  1. adLoadParams :   Valid instance of NSMutableDictionary. This must
 *                      not be nil. Refer to the integration guide for
 *                      valid key-value pairs.
 *
 * @return void
 *
 * @discussion
 *      handleAdLoaded should be invoked when ad loads. This method should
 *      be called with valid key-value paris in adLoadParams dictionary
 *
 *
 */
+ (void) handleAdLoaded:(NSMutableDictionary*)adLoadParams;

/*!
 * @function handleAdStarted
 *
 * @abstract It is important for ad-related metrics
 *
 * @param
 *  1. adStartParams    :   Valid instance of NSMutableDictionary.
 *                          Refer to the integration guide for valid key-value pairs.
 *
 * @return void
 *
 * @discussion
 *      handleAdStarted should be invoked when ad started. This method should
 *      be called with valid key-value paris in adStartParams dictionary
 *
 *
 */
+ (void) handleAdStarted:(NSMutableDictionary*)adStartParams;

/*!
 * @function handleAdFirstQuartile
 *
 * @abstract It is important for ad-related metrics
 *
 * @param
 *  1. adFirstQuartileParams    :   Valid instance of NSMutableDictionary.
 *                                  Refer to the integration guide for valid key-value pairs.
 *
 * @return void
 *
 * @discussion
 *      handleAdFirstQuartile should be invoked when ad completes first quartile.
 *      This method should be called with valid key-value paris in
 *      adFirstQuartileParams dictionary
 *
 *
 */
+ (void) handleAdFirstQuartile:(NSMutableDictionary*)adFirstQuartileParams;

/*!
 * @function handleAdMidpoint
 *
 * @abstract It is important for ad-related metrics
 *
 * @param
 *  1. adMidPointParams :   Valid instance of NSMutableDictionary.
 *                          Refer to the integration guide for valid key-value pairs.
 *
 * @return void
 *
 * @discussion
 *      handleAdMidpoint should be invoked when ad completes 50%. This method should
 *      be called with valid key-value paris in adMidPointParams dictionary
 *
 *
 */
+ (void) handleAdMidpoint:(NSMutableDictionary*)adMidPointParams;

/*!
 * @function handleAdThirdQuartile
 *
 * @abstract It is important for ad-related metrics
 *
 * @param
 *  1. adThirdQuartileParams    :   Valid instance of NSMutableDictionary.
 *                                  Refer to the integration guide for valid key-value pairs
 *
 * @return void
 *
 * @discussion
 *      handleAdThirdQuartile should be invoked when ad completes 75%. This method should
 *      be called with valid key-value paris in adThirdQuartileParams dictionary
 *
 *
 */
+ (void) handleAdThirdQuartile:(NSMutableDictionary*)adThirdQuartileParams;

/*!
 * @function handleAdComplete
 *
 * @abstract It is important for ad-related metrics
 *
 * @param
 *  1. adCompleteParams :   Valid instance of NSMutableDictionary.
 *                          Refer to the integration guide for valid key-value pairs
 *
 * @return void
 *
 * @discussion
 *      handleAdComplete should be invoked when ad complete 100%. This method should
 *      be called with valid key-value paris in adCompleteParams dictionary
 *
 *
 */
+ (void) handleAdComplete:(NSMutableDictionary*)adCompleteParams;

/*!
 * @function handleAdStopped
 *
 * @abstract It is important for ad-related metrics
 *
 * @param
 *  1. adStoppedParams :    Valid instance of NSMutableDictionary.
 *                          Refer to the integration guide for valid key-value pairs
 *
 * @return void
 *
 * @discussion
 *      handleAdStopped should be invoked when ad stopped or closed by user.
 *      This method should be called with valid key-value paris in adStoppedParams dictionary
 *
 *
 */
+ (void) handleAdStopped:(NSMutableDictionary*)adStoppedParams;

/*!
 * @function handleAdEnd
 *
 * @abstract It is important for ad-related metrics
 *
 * @param
 *  1. adEndParams :    Valid instance of NSMutableDictionary.
 *                      Refer to the integration guide for valid key-value pairs
 *
 * @return void
 *
 * @discussion
 *      handleAdLoaded should be invoked when ad ends (handleAdComplete + handleAdStopped).
 *       This method should be called with valid key-value paris in adEndParams dictionary
 *
 *
 */
+ (void) handleAdEnd:(NSMutableDictionary*)adEndParams;

/*!
 * @function handleAdError
 *
 * @abstract It is important for ad-related metrics
 *
 * @param
 *  1. adErrorParams :   Valid instance of NSMutableDictionary. This must
 *                      not be nil. Refer to the integration guide for
 *                      valid key-value pairs
 *
 * @return void
 *
 * @discussion
 *      handleAdError should be invoked when ad received error. This method should
 *      be called with valid key-value paris in adErrorParams dictionary
 *
 *
 */
+ (void) handleAdError:(NSMutableDictionary*)adErrorParams;


/*!
 * @function deinitMASDK
 *
 * @abstract deinitMASDK is MANDATORY
 *
 * @param
 *  1. None
 *
 * @return void
 *
 * @discussion
 *      deinitMASDK is mandatory API and App must call this without fail;
 *      this will terminat the plugin instance created and releases all
 *      allocated objcets / resources
 *
 */
+ (void)deinitMASDK;
@end


