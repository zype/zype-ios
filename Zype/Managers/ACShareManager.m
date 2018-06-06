//
//  ACShareManager.m
//
//  Created by ZypeTech on 5/29/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "ACShareManager.h"
#import "Video.h"

@implementation ACShareManager

+ (SLComposeViewController *)facebookControllerForVideo:(Video *)video{
    
    NSString *shareMessage = [NSString stringWithFormat:@"%@: ""%@""", [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ShareMessage], video.title];
    
    SLComposeViewController *facebookController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookController setInitialText:shareMessage];
    
    return facebookController;
}

+ (SLComposeViewController *)twitterControllerForVideo:(Video *)video{
    
    NSString *shareMessage = [NSString stringWithFormat:@"%@: ""%@""", [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ShareMessage], video.title];
    
    SLComposeViewController *twitterController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterController setInitialText:shareMessage];
    
    return twitterController;
    
}

+ (MFMailComposeViewController *)mailControllerForVideo:(Video *)video{
    
    NSString *shareSubject = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ShareSubject];
    NSString *shareMessage = [NSString stringWithFormat:@"%@: ""%@""", [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ShareMessage], video.title];
    
    if (![MFMailComposeViewController canSendMail]) {
        
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:kString_TitleShareFail message:kString_MessageNoEmail delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return nil;
        
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setSubject:shareSubject];
    [mailController setToRecipients:@[]];
    [mailController setMessageBody:shareMessage isHTML:NO];
    
    return mailController;
    
}

+ (MFMessageComposeViewController *)messageControllerForVideo:(Video *)video{
    
    NSString *shareMessage = [NSString stringWithFormat:@"%@: ""%@""", [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ShareMessage], video.title];
    
    if(![MFMessageComposeViewController canSendText]) {
        
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:kString_TitleShareFail message:kString_MessageNoSms delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return nil;
        
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [messageController setRecipients:@[]];
    [messageController setBody:shareMessage];
    
    return messageController;
    
}

@end
