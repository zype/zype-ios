/*
 * AKAMMediaAnalytics_Astraeus.h
 * AKAMMediaExtensions
 *
 *  This file is part of the Media Analytics, http://www.akamai.com
 * Media Analytics is a proprietary Akamai software that you may use and modify per the license agreement here:
 * http://www.akamai.com/product/licenses/mediaanalytics.html
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *
 *
 * Created by Tank, Umesh on 7/3/13.
 *
 */


#import "AKAMMediaAnalytics_Av.h"

@interface AKAMMediaAnalytics_Av ()

/*!
 * @function setURLDeliveryDetails
 *
 * @abstract setURLDeliveryDetails is added to capture metrics & dimensions
 *             for Astraeus (CAD)
 *
 * @param
 *  1. isPlayingCAD :   A BOOl value which specifies if it is playing
 *                      Astraeus contents. Set YES if contents are
 *                      served through Astraeus
 *  2. streamURL    :   A valid instance of NSString. This must be a
 *                      stream URL
 *
 * @return void
 *
 * @discussion
 *
 *
 */
+ (void)setURLDeliveryDetails:(NSString*)isDeliveredOverCad withURL:(NSString*)streamURL;

@end
