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
#import "DCPathButton.h"

@interface CLHomeViewController () <DCPathButtonDelegate>

@property (nonatomic) PulsingHaloLayer *halo;

@end

@implementation CLHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", [CLFileManager imageFilePathWithFileName:nil]);

    self.view.backgroundColor = [UIColor flatDarkBlackColor];
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.frame];
    background.image = [UIImage imageNamed:@"bg_3.jpg"];
    [self.view insertSubview:background atIndex:0];
    
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = CGPointMake(160, 320);
    self.halo.radius = 300;
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
    
    DCPathButton *dcPathButton = [[DCPathButton alloc]
                                  initDCPathButtonWithSubButtons:5
                                  totalRadius:110
                                  centerRadius:60
                                  subRadius:40
                                  centerImage:@"circle-2"
                                  centerBackground:nil
                                  subImages:^(DCPathButton *dc){
                                      [dc subButtonImage:@"locker" withTag:0];
                                      [dc subButtonImage:@"camera" withTag:1];
                                      [dc subButtonImage:@"facebook" withTag:2];
                                      [dc subButtonImage:@"twitter" withTag:3];
                                      [dc subButtonImage:@"settings" withTag:4];
                                  }
                                  subImageBackground:nil
                                  inLocationX:165 locationY:320 toParentView:self.view];
    dcPathButton.delegate = self;
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
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
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
    [self performSegueWithIdentifier:@"metaioSegue" sender:nil];
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

- (void)open
{
    self.halo.hidden = YES;
}

- (void)close
{
    self.halo.hidden = NO;
}

@end
