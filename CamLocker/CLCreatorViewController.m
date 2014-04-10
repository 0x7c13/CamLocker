//
//  CLCreatorViewController.m
//  CamLocker
//
//  Created by Jiaqi Liu on 4/8/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLCreatorViewController.h"
#import "FBShimmeringView.h"
#import "CHTumblrMenuView.h"
#import "SIAlertView.h"
#import "UIColor+MLPFlatColors.h"
#import "JDStatusBarNotification.h"
#import "CLMarkerManager.h"
#import "MHNatGeoViewControllerTransition.h"

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

@interface CLCreatorViewController () <CHTumblrMenuViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation CLCreatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)showShareMenuWithDownloadURL:(NSURL *)markerURL
{
    NSString *downloadCode = [[[markerURL absoluteString] componentsSeparatedByString:@"/"] lastObject];
    
    CHTumblrMenuView *menuView;
    menuView = [[CHTumblrMenuView alloc] init];
    menuView.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    [menuView addMenuItemWithTitle:@"Text" andIcon:[UIImage imageNamed:@"sms.png"] andSelectedBlock:^{
        
        if([MFMessageComposeViewController canSendText])
        {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.body = [NSString stringWithFormat:@"I just created a marker using the #CamLocker App. The download code is: %@, check it out!", downloadCode];
            controller.messageComposeDelegate = weakSelf;
            [weakSelf presentViewController:controller animated:YES completion:nil];
        }
        
    }];
    [menuView addMenuItemWithTitle:@"Email" andIcon:[UIImage imageNamed:@"email.png"] andSelectedBlock:^{
        
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = weakSelf;
            [mailer setSubject:@"CamLocker Marker Sharing"];
            NSString *emailBody = [NSString stringWithFormat:@"Hi,\n\nI just created a marker using the #CamLocker App. The download code is: %@, check it out!\n\nSent from the CamLocker App.", downloadCode];
            [mailer setMessageBody:emailBody isHTML:NO];
            [weakSelf presentViewController:mailer animated:YES completion:nil];
        }
        
    }];
    [menuView addMenuItemWithTitle:@"Facebook" andIcon:[UIImage imageNamed:@"facebook_new.png"] andSelectedBlock:^{
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [controller setInitialText:[NSString stringWithFormat:@"I just created a marker using the #CamLocker App. The download code is: %@, check it out!", downloadCode]];
            [controller addImage:[UIImage imageNamed:@"icon.png"]];
            
            [weakSelf presentViewController:controller animated:YES completion:Nil];
        } else {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops" andMessage:@"Please login with your Facebook account in settings!"];
            [alertView addButtonWithTitle:@"OK"
                                     type:SIAlertViewButtonTypeDestructive
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
            alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
            alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
            
            [alertView show];
        }
        
    }];
    [menuView addMenuItemWithTitle:@"Twitter" andIcon:[UIImage imageNamed:@"twitter.png"] andSelectedBlock:^{
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            [controller setInitialText:[NSString stringWithFormat:@"I just created a marker using the #CamLocker App. The download code is: %@, check it out!", downloadCode]];
            [controller addImage:[UIImage imageNamed:@"icon.png"]];
            
            [weakSelf presentViewController:controller animated:YES completion:Nil];
        } else {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops" andMessage:@"Please login with your Twitter account in settings!"];
            [alertView addButtonWithTitle:@"OK"
                                     type:SIAlertViewButtonTypeDestructive
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
            alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
            alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
            
            [alertView show];
        }
    }];
    [menuView addMenuItemWithTitle:@"Google+" andIcon:[UIImage imageNamed:@"google_plus.png"] andSelectedBlock:^{
        
    }];
    [menuView addMenuItemWithTitle:@"Weibo" andIcon:[UIImage imageNamed:@"weibo.png"] andSelectedBlock:^{
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
            
            [controller setInitialText:[NSString stringWithFormat:@"I just created a marker using the #CamLocker App. The download code is: %@, check it out!", downloadCode]];
            [controller addImage:[UIImage imageNamed:@"icon.png"]];
            
            [weakSelf presentViewController:controller animated:YES completion:Nil];
        } else {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops" andMessage:@"Please login with your Weibo account in settings!"];
            [alertView addButtonWithTitle:@"OK"
                                     type:SIAlertViewButtonTypeDestructive
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
            alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
            alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
            
            [alertView show];
        }
    }];
    
    CGFloat yOffset = DEVICE_IS_4INCH_IPHONE ? 0 : -30;
    
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(20, 95 + yOffset, 280, 150)];
    UILabel *downloadCodeLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
    downloadCodeLabel.textAlignment = NSTextAlignmentCenter;
    downloadCodeLabel.font = [UIFont fontWithName:@"OpenSans" size:28];
    downloadCodeLabel.numberOfLines = 3;
    downloadCodeLabel.textColor = [UIColor flatWhiteColor];
    downloadCodeLabel.text = [@"Your CamLocker download code is:\n" stringByAppendingString:downloadCode];
    shimmeringView.contentView = downloadCodeLabel;
    shimmeringView.shimmering = YES;
    shimmeringView.alpha = 0.0f;
    [menuView addSubview:shimmeringView];
    
    [menuView showInView:self.view];
    
    [UIView animateWithDuration:0.7f animations:^{
        shimmeringView.alpha = 1.0f;
    }];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultSent:
            [JDStatusBarNotification showWithStatus:@"Message sent!" dismissAfter:1.5f styleName:JDStatusBarStyleSuccess];
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            [JDStatusBarNotification showWithStatus:@"Email sent!" dismissAfter:1.5f styleName:JDStatusBarStyleSuccess];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tumblrMenuViewDidDismiss
{
    [CLMarkerManager sharedManager].tempMarkerImage = nil;
    [self.navigationController dismissNatGeoViewController];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

@end
