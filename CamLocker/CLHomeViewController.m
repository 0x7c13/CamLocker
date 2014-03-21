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
#import "UIColor+MLPFlatColors.h"
#import "JDStatusBarNotification.h"
#import "DCPathButton.h"

@interface CLHomeViewController () <DCPathButtonDelegate> {
    BOOL needsToDisplayStarupAnimation;
}

@property (nonatomic) PulsingHaloLayer *halo;
@property (nonatomic) DCPathButton *dcPathButton;

@end

@implementation CLHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", [CLFileManager imageFilePathWithFileName:nil]);

    [CLUtilities addBackgroundImageToView:self.view];
    
    CGFloat locationY = DEVICE_IS_4INCH_IPHONE ? 320 : 260;
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = CGPointMake(160, locationY);
    self.halo.radius = 170;
    self.halo.backgroundColor = [UIColor flatWhiteColor].CGColor;
    [self.view.layer insertSublayer:self.halo atIndex:1];
    
    self.camLockerLogoLabel.textColor = [UIColor flatWhiteColor];
    self.hideInfoButton.backgroundColor = [UIColor flatDarkGrayColor];
    self.unlockButton.backgroundColor = [UIColor flatDarkGrayColor];
    self.deleteDataButton.tintColor = [UIColor flatRedColor];
    
    //self.camLockerLogoLabel.font = [UIFont fontWithName:@"OpenSans" size:50.0];
    self.hideInfoButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:30.0];
    self.unlockButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:30.0];
    self.deleteDataButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:20.0];
    
    [CLUtilities addShadowToUIView:self.hideInfoButton];
    [CLUtilities addShadowToUIView:self.unlockButton];
    
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
                          inLocationX:165 locationY:locationY toParentView:self.view];
    self.dcPathButton.delegate = self;
    
    // Animation setup
    [self animationSetup];
    needsToDisplayStarupAnimation = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)animationSetup
{
    CGFloat locationY = DEVICE_IS_4INCH_IPHONE ? 210 : 170;
    self.camLockerLogoLabel.frame = CGRectMake(20, locationY, 280, 120);
    self.camLockerLogoLabel.alpha = 0.0f;
    self.dcPathButton.alpha = 0.0f;
    self.dcPathButton.userInteractionEnabled = NO;
    self.bottomLabel.alpha = 0.0f;
    self.halo.hidden = YES;
}

- (void)executeAnimation
{
    [self animationSetup];
    if (self.dcPathButton.isExpanded) {
        [self.dcPathButton close];
    }
    
    [UIView animateWithDuration:1.0f animations:^{
        
        self.camLockerLogoLabel.alpha = 1.0f;
    } completion:^(BOOL finished){
        
        [UIView animateWithDuration:0.7f animations:^{
            
            self.camLockerLogoLabel.frame = CGRectMake(20, 45, 280, 120);
            self.bottomLabel.alpha = 1.0f;
        } completion:^(BOOL finished){
            
            [UIView animateWithDuration:0.7f animations:^{
                
                self.dcPathButton.alpha = 1.0f;
            } completion:^(BOOL finished){
                
                self.dcPathButton.userInteractionEnabled = YES;
                self.halo.hidden = NO;
            }];
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (needsToDisplayStarupAnimation) {
        [self executeAnimation];
        needsToDisplayStarupAnimation = NO;
    }
    
}

- (void)handleDidEnterBackground
{
    [self animationSetup];
    needsToDisplayStarupAnimation = YES;
    if (self.dcPathButton.isExpanded) {
        [self.dcPathButton close];
    }
}

- (void)handleDidBecomeActive
{
    if (needsToDisplayStarupAnimation) {
        [self executeAnimation];
        needsToDisplayStarupAnimation = NO;
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

- (void)button_0_action{
    NSLog(@"Button Press Tag 0!!");
    [self performSegueWithIdentifier:@"createMarkerSegue" sender:nil];
}

- (void)button_1_action{
    NSLog(@"Button Press Tag 1!!");
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

- (void)button_2_action{
    NSLog(@"Button Press Tag 2!!");
}

- (void)button_3_action{
    NSLog(@"Button Press Tag 3!!");
}

- (void)button_4_action{
    NSLog(@"Button Press Tag 4!!");
    [self deleteAllDataButtonPressed:nil];
}

- (void)pathButtonWillOpen
{
    self.halo.hidden = YES;
}

- (void)pathButtonWillClose
{
    self.halo.hidden = NO;
}

@end
