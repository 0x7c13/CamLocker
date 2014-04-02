//
//  CLHomeViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import "CLTextMarker.h"
#import "CLImageMarker.h"
#import "CLFileManager.h"
#import "CLHomeViewController.h"
#import "CLMarkerManager.h"
#import "CLUtilities.h"
#import "SIAlertView.h"
#import "PulsingHaloLayer.h"
#import "ANBlurredImageView.h"
#import "UIColor+MLPFlatColors.h"
#import "JDStatusBarNotification.h"
#import "DCPathButton.h"

@interface CLHomeViewController () <DCPathButtonDelegate> {
    BOOL needsToDisplayLaunchAnimation;
}

@property (strong, nonatomic) IBOutlet ANBlurredImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (nonatomic) PulsingHaloLayer *halo;
@property (nonatomic) PulsingHaloLayer *buttonHalo;
@property (nonatomic) DCPathButton *dcPathButton;

@end

@implementation CLHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", [CLFileManager imageFilePathWithFileName:nil]);

    [CLUtilities addBackgroundImageToView:self.masterView withImageName:@"bg_4.jpg"];
    
    CGFloat locationY = DEVICE_IS_4INCH_IPHONE ? 320 : 260;
    
    self.camLockerLogoLabel.textColor = [UIColor flatWhiteColor];
    
    [_imageView setHidden:YES];
    [_imageView setFramesCount:10];
    [_imageView setBlurAmount:1];
    
    self.dcPathButton = [[DCPathButton alloc]
                          initDCPathButtonWithSubButtons:5
                          totalRadius:110
                          centerRadius:60
                          subRadius:37
                          centerImage:@"circle-2"
                          centerBackground:nil
                          subImages:^(DCPathButton *dc){
                              [dc subButtonImage:@"locker_new" withTag:0];
                              [dc subButtonImage:@"camera_new" withTag:1];
                              [dc subButtonImage:@"facebook_new" withTag:2];
                              [dc subButtonImage:@"twitter_new" withTag:3];
                              [dc subButtonImage:@"settings_new" withTag:4];
                          }
                          subImageBackground:nil
                          inLocationX:165 locationY:locationY toParentView:self.buttonView];
    self.dcPathButton.delegate = self;
    
    // Animation setup
    [self animationSetup];
    needsToDisplayLaunchAnimation = YES;

}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)animationSetup
{
    CGFloat locationY = DEVICE_IS_4INCH_IPHONE ? 210 : 170;
    self.camLockerLogoLabel.frame = CGRectMake(20, locationY, 280, 120);
    self.camLockerLogoLabel.alpha = 0.0f;
    self.dcPathButton.alpha = 0.0f;
    self.dcPathButton.userInteractionEnabled = NO;
    self.bottomLabel.alpha = 0.0f;
    [self stopHaloAnimation];
}

- (void)startHaloAnimation
{
    [self stopHaloAnimation];
    CGFloat locationY = DEVICE_IS_4INCH_IPHONE ? 320 : 260;
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = CGPointMake(160, locationY);
    self.halo.radius = 150;
    self.halo.backgroundColor = [UIColor flatWhiteColor].CGColor;
    [self.buttonView.layer insertSublayer:self.halo atIndex:0];
}

- (void)stopHaloAnimation
{
    if (self.buttonView.layer.sublayers.count == 2) {
        [[self.buttonView.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
    }
}

- (void)executeAnimation
{
    [self animationSetup];
    
    if (self.dcPathButton.isExpanded) {
        [self.dcPathButton close];
    }
    
    [UIView animateWithDuration:0.7f animations:^{
        
        self.camLockerLogoLabel.alpha = 1.0f;
    } completion:^(BOOL finished){
        
        [UIView animateWithDuration:0.7f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.camLockerLogoLabel.frame = CGRectMake(20, 45, 280, 120);
            self.bottomLabel.alpha = 1.0f;
        } completion:^(BOOL finished){
            
            if (!self.imageView.image) {
                self.imageView.image = [CLUtilities snapshotViewForView:self.masterView];
                self.imageView.baseImage = self.imageView.image;
                [self.imageView generateBlurFramesWithCompletion:^{}];
            }
            
            [UIView animateWithDuration:0.7f animations:^{
                
                self.dcPathButton.alpha = 1.0f;
            } completion:^(BOOL finished){
                
                self.dcPathButton.userInteractionEnabled = YES;
                [self startHaloAnimation];
            }];
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (needsToDisplayLaunchAnimation) {
        [self executeAnimation];
        needsToDisplayLaunchAnimation = NO;
    }
    
}

- (void)handleDidEnterBackground
{
    [self animationSetup];
    needsToDisplayLaunchAnimation = YES;
    if (self.dcPathButton.isExpanded) {
        [self.dcPathButton close];
    }
}

- (void)handleDidBecomeActive
{
    if (needsToDisplayLaunchAnimation) {
        [self executeAnimation];
        needsToDisplayLaunchAnimation = NO;
    }
}

- (IBAction)deleteAllDataButtonPressed:(id)sender {
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Warnning" andMessage:@"Are you sure? Everything will be removed!"];
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
  
                              [[CLMarkerManager sharedManager] deleteAllMarkers];
                              [JDStatusBarNotification showWithStatus:@"All markers have been removed!" dismissAfter:2 styleName:JDStatusBarStyleWarning];
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.dcPathButton close];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - DCPathButton delegate

- (void)button_0_action:(DCSubButton *)sender{
    NSLog(@"Button Press Tag 0!!");
    [self executeSubButtonAnimationForButton:sender];
    [self performSegueWithIdentifier:@"createMarkerSegue" sender:nil];
}

- (void)button_1_action:(DCSubButton *)sender{
    NSLog(@"Button Press Tag 1!!");
    [self executeSubButtonAnimationForButton:sender];
    
    if ([CLMarkerManager sharedManager].markers.count > 0) {
        [self performSegueWithIdentifier:@"metaioSegue" sender:nil];
    } else {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops" andMessage:@"No markers are found, please create one first!"];
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
}

- (void)button_2_action:(DCSubButton *)sender{
    NSLog(@"Button Press Tag 2!!");
    [self executeSubButtonAnimationForButton:sender];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Check out CamLocker! Hide and share your images, voice or text in seconds. http://www.camlockerapp.com"];
        [controller addImage:[UIImage imageNamed:@"icon.png"]];
        
        [self presentViewController:controller animated:YES completion:Nil];
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
}

- (void)button_3_action:(DCSubButton *)sender{
    NSLog(@"Button Press Tag 3!!");
    [self executeSubButtonAnimationForButton:sender];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [controller setInitialText:@"Check out CamLocker! Hide and share your images, voice or text in seconds. http://www.camlockerapp.com"];
        [controller addImage:[UIImage imageNamed:@"icon.png"]];
        
        [self presentViewController:controller animated:YES completion:Nil];
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
}

- (void)button_4_action:(DCSubButton *)sender{
    NSLog(@"Button Press Tag 4!!");

    [self executeSubButtonAnimationForButton:sender];
    [self deleteAllDataButtonPressed:sender];
}

- (void)executeSubButtonAnimationForButton:(DCSubButton *)button
{
    if (button.layer.sublayers.count == 2) {
        [[button.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
    }
    self.buttonHalo = [PulsingHaloLayer layer];
    self.buttonHalo.repeatCount = 0;
    self.buttonHalo.animationDuration = 1.0f;
    self.buttonHalo.position = CGPointMake(button.frame.size.width/2.0, button.frame.size.height/2.0);
    self.buttonHalo.radius = 80;
    self.buttonHalo.backgroundColor = [UIColor flatGrayColor].CGColor;
    [button.layer insertSublayer:self.buttonHalo atIndex:0];
}

- (void)pathButtonWillOpen
{
    self.imageView.hidden = NO;
    [self stopHaloAnimation];
    [self.imageView blurInAnimationWithDuration:0.25f];
}

- (void)pathButtonWillClose
{
    [self.imageView blurOutAnimationWithDuration:0.5f completion:^{
        self.imageView.hidden = YES;
        [self startHaloAnimation];
    }];
}

@end
