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
#import "CLDataHandler.h"
#import "CLUtilities.h"
#import "SIAlertView.h"
#import "PulsingHaloLayer.h"
#import "ANBlurredImageView.h"
#import "UIColor+MLPFlatColors.h"
#import "JDStatusBarNotification.h"
#import "URBAlertView.h"
#import "ETActivityIndicatorView.h"
#import "CircularProgressView.h"
#import "DCPathButton.h"

@interface CLHomeViewController () <DCPathButtonDelegate> {
    BOOL needsToDisplayLaunchAnimation;
}

@property (strong, nonatomic) IBOutlet ANBlurredImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (nonatomic) PulsingHaloLayer *halo;
@property (nonatomic) DCPathButton *dcPathButton;
@property (nonatomic) URBAlertView *alertView;
@property (nonatomic) CircularProgressView *circularProgressView;

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
                          initDCPathButtonWithSubButtons:6
                          totalRadius:110
                          centerRadius:45
                          subRadius:35
                          centerImage:@"circle"
                          centerBackground:nil
                          subImages:^(DCPathButton *dc){
                              [dc subButtonImage:@"locker_new" withTag:0];
                              [dc subButtonImage:@"camera_new" withTag:1];
                              [dc subButtonImage:@"download" withTag:2];
                              [dc subButtonImage:@"twitter_new" withTag:3];
                              [dc subButtonImage:@"settings_new" withTag:4];
                              [dc subButtonImage:@"facebook_new" withTag:5];
                          }
                          subImageBackground:nil
                          inLocationX:160 locationY:locationY toParentView:self.buttonView];
    self.dcPathButton.delegate = self;
    
    // Animation setup
    [self animationSetup];
    needsToDisplayLaunchAnimation = YES;
    
    
    self.circularProgressView = [[CircularProgressView alloc]initWithFrame:CGRectMake(160 - 42.5, 277.5, 85, 85)];
    
    self.circularProgressView.backColor = [UIColor whiteColor];
    self.circularProgressView.progressColor = [UIColor flatBlueColor];
    self.circularProgressView.lineWidth = 7.5;
    self.circularProgressView.alpha = 1.0f;
    self.circularProgressView.userInteractionEnabled = NO;
    [self.circularProgressView setProgress:0.0];
    self.circularProgressView.hidden = YES;
    [self.view addSubview:self.circularProgressView];
    

}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)animationSetup
{
    //CGFloat locationY = DEVICE_IS_4INCH_IPHONE ? 210 : 170;
    //self.camLockerLogoLabel.frame = CGRectMake(20, locationY, 280, 120);
    self.bottomLabel.frame = CGRectMake(-280, 510, 280, 40);
    self.camLockerLogoLabel.frame = CGRectMake(320 + 280, 45, 280, 120);
    self.camLockerLogoLabel.alpha = 0.0f;
    self.dcPathButton.alpha = 0.0f;
    self.dcPathButton.userInteractionEnabled = NO;
    self.bottomLabel.alpha = 0.0f;
    [self stopHaloAnimation];
}

- (void)startHaloAnimation
{
    [self stopHaloAnimation];
    if (!self.dcPathButton.userInteractionEnabled) return;

    CGFloat locationY = DEVICE_IS_4INCH_IPHONE ? 320 : 260;
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = CGPointMake(160, locationY);
    self.halo.radius = 130;
    self.halo.backgroundColor = [UIColor flatWhiteColor].CGColor;
    [self.buttonView.layer insertSublayer:self.halo atIndex:0];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(startSecondHalo) userInfo:nil repeats:NO];
}

- (void)startSecondHalo
{
    if (!self.imageView.hidden) return;

    CGFloat locationY = DEVICE_IS_4INCH_IPHONE ? 320 : 260;
    PulsingHaloLayer *halo = [PulsingHaloLayer layer];
    halo.position = CGPointMake(160, locationY);
    halo.radius = 130;
    halo.backgroundColor = [UIColor flatWhiteColor].CGColor;
    [self.buttonView.layer insertSublayer:halo atIndex:0];
}

- (void)stopHaloAnimation
{
    NSMutableArray *layersNeedToBeRemoved = [[NSMutableArray alloc]init];
    [self.buttonView.layer.sublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger index, BOOL *stop) {
        if ([layer isKindOfClass:[PulsingHaloLayer class]]) {
            [layersNeedToBeRemoved addObject:layer];
        }
    }];
    for (CALayer *layer in layersNeedToBeRemoved) {
        [layer removeFromSuperlayer];
    }
}

- (void)executeAnimation
{
    [self animationSetup];
    
    if (self.dcPathButton.isExpanded) {
        [self.dcPathButton close];
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        
        self.camLockerLogoLabel.alpha = 1.0f;
    } completion:^(BOOL finished){
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.camLockerLogoLabel.frame = CGRectMake(20, 45, 280, 120);
            self.bottomLabel.frame = CGRectMake(20, 510, 280, 40);
            self.bottomLabel.alpha = 1.0f;
        } completion:^(BOOL finished){
            
            if (!self.imageView.image) {
                self.imageView.image = [CLUtilities snapshotViewForView:self.masterView];
                self.imageView.baseImage = self.imageView.image;
                [self.imageView setBlurTintColor:[UIColor colorWithWhite:0.f alpha:0.5]];
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
    if (!self.alertView.isHidden) {
        [self.alertView hide];
    }
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
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Warning" andMessage:@"Are you sure? Everything will be removed!"];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - DCPathButton delegate

- (void)button_0_action:(DCSubButton *)sender {
    NSLog(@"Button Press Tag 0!!");
    [self executeSubButtonAnimationForButton:sender];
    [self.dcPathButton close];
    
    [self performSegueWithIdentifier:@"createMarkerSegue" sender:nil];
}

- (void)button_1_action:(DCSubButton *)sender {
    NSLog(@"Button Press Tag 1!!");
    [self executeSubButtonAnimationForButton:sender];
    
    [self.dcPathButton close];
    
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

- (void)button_2_action:(DCSubButton *)sender {
    NSLog(@"Button Press Tag 2!!");
    [self executeSubButtonAnimationForButton:sender];
    
    [self.dcPathButton close];
    __weak typeof(self) weakSelf = self;
    self.alertView = [URBAlertView dialogWithTitle:@"Download Code" message:@"Enter your CamLocker download code here:"];
    [self.alertView addButtonWithTitle:@"Cancel"];
    [self.alertView addButtonWithTitle:@"Confirm"];
    [self.alertView addTextFieldWithPlaceholder:@"Download code" secure:NO];
    [self.alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        if (buttonIndex == 1) {
            if ([alertView textForTextFieldAtIndex:0].length == 8) {
                
                CGFloat locationY = DEVICE_IS_4INCH_IPHONE ? 290 : 230;
                ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(weakSelf.view.frame.size.width/2 - 30, locationY, 60, 60)];
                etActivity.color = [UIColor flatBlueColor];
                [etActivity startAnimating];
                etActivity.tag = 6713;
                [weakSelf.view addSubview:etActivity];
                weakSelf.circularProgressView.hidden = NO;
                
                [JDStatusBarNotification showWithStatus:@"Downloading..." styleName:JDStatusBarStyleWarning];
                
                [CLDataHandler downloadMarkerByDownloadCode:[alertView textForTextFieldAtIndex:0]
                                                   progress:^(NSUInteger totalBytesRead, NSInteger totalBytesExpectedToRead){
                                                       
                                                       //NSLog(@"%.0f", (float)totalBytesRead/(float)totalBytesExpectedToRead);
                                                       if (totalBytesExpectedToRead != -1) {
                                                           [weakSelf.circularProgressView setProgress:(float)totalBytesRead/(float)totalBytesExpectedToRead];
                                                       }
                                                   }
                                            completionBlock:^(CLDataHandlerOption option, NSError *error){
                                                
                                                weakSelf.circularProgressView.hidden = YES;
                                                weakSelf.dcPathButton.userInteractionEnabled = YES;
                                                [[weakSelf.view viewWithTag:6713] removeFromSuperview];
                                                if (option == CLDataHandlerOptionSuccess) {
                                                    [JDStatusBarNotification showWithStatus:@"New marker added" dismissAfter:2.0f styleName:JDStatusBarStyleSuccess];
                                                } else if (option == CLDataHandlerOptionFailure) {
                                                    
                                                    if (error) {
                                                        [JDStatusBarNotification showWithStatus:error.localizedDescription dismissAfter:2.0f styleName:JDStatusBarStyleError];
                                                    } else {
                                                        [JDStatusBarNotification showWithStatus:@"Error occurs" dismissAfter:2.0f styleName:JDStatusBarStyleError];
                                                    }
                                                }
                                            }];
                
                weakSelf.dcPathButton.userInteractionEnabled = NO;
                [alertView hideWithAnimation:URBAlertAnimationDefault];
            } else {
                CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
                anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f) ] ] ;
                anim.autoreverses = YES ;
                anim.repeatCount = 2.0f ;
                anim.duration = 0.07f ;
                [alertView.layer addAnimation:anim forKey:nil] ;
            }
        } else if (buttonIndex == 0) {
            [alertView hideWithAnimation:URBAlertAnimationDefault];
        }
        
    }];
    [self.alertView showWithAnimation:URBAlertAnimationDefault];
}

- (void)button_3_action:(DCSubButton *)sender {
    NSLog(@"Button Press Tag 3!!");
    [self executeSubButtonAnimationForButton:sender];
    
    [self.dcPathButton close];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [controller setInitialText:@"Check out the CamLocker App! Hide and share your images, voice or text in seconds. http://www.camlockerapp.com"];
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

- (void)button_4_action:(DCSubButton *)sender {
    NSLog(@"Button Press Tag 4!!");
    [self executeSubButtonAnimationForButton:sender];
    
    [self.dcPathButton close];
    
    [self deleteAllDataButtonPressed:sender];
}

- (void)button_5_action:(DCSubButton *)sender {
    NSLog(@"Button Press Tag 5!!");
    [self executeSubButtonAnimationForButton:sender];
    
    [self.dcPathButton close];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Check out the CamLocker App! Hide and share your images, voice or text in seconds. http://www.camlockerapp.com"];
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

- (void)executeSubButtonAnimationForButton:(DCSubButton *)button
{
    if (button.layer.sublayers.count == 2) {
        [[button.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
    }
    PulsingHaloLayer *buttonHalo = [PulsingHaloLayer layer];
    buttonHalo.repeatCount = 0;
    buttonHalo.animationDuration = 1.0f;
    buttonHalo.position = CGPointMake(button.frame.size.width/2.0, button.frame.size.height/2.0);
    buttonHalo.radius = 80;
    buttonHalo.backgroundColor = [UIColor flatGrayColor].CGColor;
    [button.layer insertSublayer:buttonHalo atIndex:0];
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
