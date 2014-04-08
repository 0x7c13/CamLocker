//
//  CLHiddenVoiceViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/28/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLFileManager.h"
#import "CLMarkerManager.h"
#import "CLDataHandler.h"
#import "CLHiddenVoiceViewController.h"
#import "UIColor+MLPFlatColors.h"
#import "THProgressView.h"
#import "SIAlertView.h"
#import "JDStatusBarNotification.h"
#import "ETActivityIndicatorView.h"
#import "ANBlurredImageView.h"
#import "MHNatGeoViewControllerTransition.h"
#import "TSMessage.h"
#import "CHTumblrMenuView.h"
#import "FBShimmeringView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

#define kAudioFileName @"tmp.aac"

@interface CLHiddenVoiceViewController () <AVAudioPlayerDelegate, AVAudioRecorderDelegate, CHTumblrMenuViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    BOOL canPlayAudio;
    BOOL isEncrypting;
    BOOL audioCreated;
    BOOL canExit;
}

@property (weak, nonatomic) IBOutlet UIButton *voiceControlButton;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;
@property (weak, nonatomic) IBOutlet ANBlurredImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic) BOOL isRecording;
@property (nonatomic) AVAudioRecorder *voiceRecorder;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) CGFloat progress;
@property (nonatomic) CHTumblrMenuView *menuView;

@end

@implementation CLHiddenVoiceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSFileManager defaultManager] removeItemAtPath:[CLFileManager voiceFilePathWithFileName:kAudioFileName] error:nil];
    
    [CLUtilities addBackgroundImageToView:self.masterView withImageName:@"bg_4.jpg"];

    self.voiceControlButton.layer.cornerRadius = 15;
    
    self.progressView.borderTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [UIColor whiteColor];
    
    canExit = NO;
    canPlayAudio = NO;
    isEncrypting = NO;
    audioCreated = NO;
    self.progress = 0.05f;
    self.isRecording = NO;
    self.progressView.hidden = YES;
    
    [_imageView setHidden:YES];
    [_imageView setFramesCount:8];
    [_imageView setBlurAmount:1];
    
    self.voiceControlButton.layer.cornerRadius = 15;
    if (!DEVICE_IS_4INCH_IPHONE) {
        self.voiceControlButton.frame = CGRectMake(50, 160, 220, 237);
    }
    [self.voiceControlButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.voiceControlButton
                                                                    withColor:[UIColor flatWhiteColor].CGColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([JDStatusBarNotification isVisible] && !isEncrypting) {
        [self.timer invalidate];
        [self voiceControlButtonPressed:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)handleDidEnterBackground
{
    if ([JDStatusBarNotification isVisible]) {
        [self.timer invalidate];
        [self voiceControlButtonPressed:nil];
    }
}

- (void)showProgressView
{
    self.progressView.alpha = 0.0f;
    self.progressView.hidden = NO;
    self.voiceControlButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.7f animations:^{
        self.progressView.alpha = 0.8f;
    }completion:^(BOOL finished){
        self.voiceControlButton.userInteractionEnabled = YES;
    }];
}

- (void)dismissProgressView
{
    [self.timer invalidate];
    self.voiceControlButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.progressView.alpha = 0.0f;
    }completion:^(BOOL finished){
        self.progressView.hidden = YES;
        self.progress = 0.05f;
        self.voiceControlButton.userInteractionEnabled = YES;
    }];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    if (canExit) {
        [CLMarkerManager sharedManager].tempMarkerImage = nil;
        [self.navigationController dismissNatGeoViewController];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        return;
    }
    
    if (isEncrypting || self.isRecording) return;
    
    if( self.audioPlayer ){
        if( self.audioPlayer.playing ) {
            [self.audioPlayer stop];
            [self.voiceControlButton setTitle:@"▶︎" forState:UIControlStateNormal];
        }
        self.audioPlayer = nil;
    }
    if ([JDStatusBarNotification isVisible]) {
        [JDStatusBarNotification dismissAnimated:NO];
    }
    if (!self.progressView.hidden) {
        self.progressView.hidden = YES;
    }
    
    if (!audioCreated) {
        [TSMessage showNotificationInViewController:self title:@"Oops"
                                           subtitle:@"Please add a voice record!"
                                               type:TSMessageNotificationTypeError
                                           duration:1.5f
                               canBeDismissedByUser:YES];
        return;
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Almost there" andMessage:@"Are you ready to create this marker?"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                                  self.navigationController.interactivePopGestureRecognizer.enabled = NO;
                              }
                              self.navigationController.navigationBar.userInteractionEnabled = NO;
                              self.doneButton.enabled = NO;
                              isEncrypting = YES;
                              
                              [JDStatusBarNotification showWithStatus:@"Encrypting Data..." styleName:JDStatusBarStyleError];
                              
                              self.imageView.hidden = NO;
                              self.imageView.image = [CLUtilities snapshotViewForView:self.masterView];
                              self.imageView.baseImage = self.imageView.image;
                              [self.imageView setBlurTintColor:[UIColor colorWithWhite:0.f alpha:0.5]];
                              [self.imageView generateBlurFramesWithCompletionBlock:^{
                               
                                  [self.imageView blurInAnimationWithDuration:0.3f];
                                  self.voiceControlButton.userInteractionEnabled = NO;
                                  ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                                  etActivity.color = [UIColor flatWhiteColor];
                                  [etActivity startAnimating];
                                  [self.view addSubview:etActivity];
                              
                                  NSData *audioData = [NSData dataWithContentsOfFile:[CLFileManager voiceFilePathWithFileName:kAudioFileName]];
                              
                                  [[CLMarkerManager sharedManager] addAudioMarkerWithMarkerImage:[CLMarkerManager sharedManager].tempMarkerImage
                                                                                 hiddenAudioData:audioData
                                                                             withCompletionBlock:^{
                                                                                 
                                                                                 [JDStatusBarNotification dismiss];
                                                                                 [self uploadMarker];
                                                                                 [etActivity removeFromSuperview];
  
                                                                             }];
                              
                              }];
                              
                              
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (void)uploadMarker
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Share" andMessage:@"Would you like to share this marker with your friends? You can upload it to our server and share it with your friends!"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                              [JDStatusBarNotification showWithStatus:@"New marker created!" dismissAfter:1.5f styleName:JDStatusBarStyleSuccess];
                              [CLMarkerManager sharedManager].tempMarkerImage = nil;
                              [self.navigationController dismissNatGeoViewController];
                              self.navigationController.navigationBar.userInteractionEnabled = YES;
                              
                          }];
    [alertView addButtonWithTitle:@"Upload"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                              etActivity.color = [UIColor flatWhiteColor];
                              [etActivity startAnimating];
                              [self.view addSubview:etActivity];
                              
                              self.progressView.progress = 0.0f;
                              [self.progressView setProgress:0.0f animated:NO];
                              self.progressView.alpha = 0.0f;
                              self.progressView.hidden = NO;
                              [UIView animateWithDuration:0.5f animations:^{
                                  self.progressView.alpha = 1.0f;
                              }];
                              
                              [JDStatusBarNotification showWithStatus:@"Uploading marker..." styleName:JDStatusBarStyleError];
                              
                              self.progressView.progress = 0.0f;
                              self.progressView.alpha = 0.0f;
                              self.progressView.hidden = NO;
                              [UIView animateWithDuration:0.3f animations:^{
                                  self.progressView.alpha = 1.0f;
                              }];
                              
                              [CLDataHandler uploadMarker:[[CLMarkerManager sharedManager].markers lastObject]
                                                 progress:^(NSUInteger bytesWritten, NSInteger totalBytesWritten){
                                                     [self.progressView setProgress:(double)bytesWritten/(double)totalBytesWritten animated:YES];
                                                 }
                                          completionBlock:^(CLDataHandlerOption option, NSURL *markerURL, NSError *error){
                                              
                                              [etActivity removeFromSuperview];
                                              [JDStatusBarNotification showWithStatus:@"Marker uploaded!" dismissAfter:2.0f styleName:JDStatusBarStyleSuccess];
                                              
                                              [UIView animateWithDuration:0.3f animations:^{
                                                  self.progressView.alpha = 0.0f;
                                                  self.progressView.hidden = YES;
                                              }];
                                              
                                              if (option == CLDataHandlerOptionSuccess) {
                                                  
                                                  NSLog(@"%@", markerURL);
                                              } else {
                                                  NSLog(@"%@", error.localizedDescription);
                                              }
                                              
                                              [self showShareMenu:markerURL];
                                          }];
                              
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (void)showShareMenu:(NSURL *)markerURL
{
    canExit = YES;
    self.doneButton.enabled = YES;
    
    NSString *downloadCode = [[[markerURL absoluteString] componentsSeparatedByString:@"/"] lastObject];
    
    self.menuView = [[CHTumblrMenuView alloc] init];
    self.menuView.delegate = self;
    self.menuView.backgroundImgView.image = self.imageView.image;
    
    __weak typeof(self) weakSelf = self;
    [self.menuView addMenuItemWithTitle:@"Text" andIcon:[UIImage imageNamed:@"sms.png"] andSelectedBlock:^{
        
        if([MFMessageComposeViewController canSendText])
        {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.body = [NSString stringWithFormat:@"I just created a marker using the CamLocker App. The download code is: %@, check it out!", downloadCode];
            controller.messageComposeDelegate = weakSelf;
            [weakSelf presentViewController:controller animated:YES completion:nil];
        }
        
    }];
    [self.menuView addMenuItemWithTitle:@"Email" andIcon:[UIImage imageNamed:@"email.png"] andSelectedBlock:^{
        
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = weakSelf;
            [mailer setSubject:@"CamLocker Marker Sharing"];
            NSString *emailBody = [NSString stringWithFormat:@"Hi,\n\nI just created a marker using the CamLocker App. The download code is: %@, check it out!\n\nSent from the CamLocker App.", downloadCode];
            [mailer setMessageBody:emailBody isHTML:NO];
            [weakSelf presentViewController:mailer animated:YES completion:nil];
        }
        
    }];
    [self.menuView addMenuItemWithTitle:@"Facebook" andIcon:[UIImage imageNamed:@"facebook_new.png"] andSelectedBlock:^{
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [controller setInitialText:[NSString stringWithFormat:@"I just created a marker using the CamLocker App. The download code is: %@, check it out!", downloadCode]];
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
    [self.menuView addMenuItemWithTitle:@"Twitter" andIcon:[UIImage imageNamed:@"twitter.png"] andSelectedBlock:^{
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            [controller setInitialText:[NSString stringWithFormat:@"I just created a marker using the CamLocker App. The download code is: %@, check it out!", downloadCode]];
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
    [self.menuView addMenuItemWithTitle:@"Google+" andIcon:[UIImage imageNamed:@"google_plus.png"] andSelectedBlock:^{
        
    }];
    [self.menuView addMenuItemWithTitle:@"Weibo" andIcon:[UIImage imageNamed:@"weibo.png"] andSelectedBlock:^{
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
            
            [controller setInitialText:[NSString stringWithFormat:@"I just created a marker using the CamLocker App. The download code is: %@, check it out!", downloadCode]];
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
    
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(20, 95, 280, 150)];
    UILabel *downloadCodeLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
    downloadCodeLabel.textAlignment = NSTextAlignmentCenter;
    downloadCodeLabel.font = [UIFont fontWithName:@"OpenSans" size:28];
    downloadCodeLabel.numberOfLines = 3;
    downloadCodeLabel.textColor = [UIColor flatWhiteColor];
    downloadCodeLabel.text = [@"Your CamLocker download code is:\n" stringByAppendingString:downloadCode];
    shimmeringView.contentView = downloadCodeLabel;
    shimmeringView.shimmering = YES;
    shimmeringView.alpha = 0.0f;
    [self.menuView addSubview:shimmeringView];
    
    [self.menuView showInView:self.imageView];
    
    [UIView animateWithDuration:0.7f animations:^{
        shimmeringView.alpha = 1.0f;
    }];
}

- (void)tumblrMenuViewDidDismiss
{
    [CLMarkerManager sharedManager].tempMarkerImage = nil;
    [self.navigationController dismissNatGeoViewController];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (IBAction)voiceControlButtonPressed:(id)sender {
    
    if (self.isRecording) {
        if( self.audioPlayer ){
            if( self.audioPlayer.playing ) [self.audioPlayer stop];
            self.audioPlayer = nil;
        }
        self.isRecording = NO;
        [self stopRecording];
        canPlayAudio = YES;

        if ([JDStatusBarNotification isVisible]) {
            [JDStatusBarNotification dismissAnimated:YES];
        }
        [self.voiceControlButton setTitle:@"▶︎" forState:UIControlStateNormal];
        [self dismissProgressView];
        return;
    }
    
    if( self.audioPlayer ){
        if ([JDStatusBarNotification isVisible]) {
            [JDStatusBarNotification dismissAnimated:YES];
        }
        if( self.audioPlayer.playing ) [self.audioPlayer stop];
        self.audioPlayer = nil;
        canPlayAudio = YES;
        [self.voiceControlButton setTitle:@"▶︎" forState:UIControlStateNormal];
        [self dismissProgressView];
        return;
    }
    
    if (canPlayAudio) {
        
        [JDStatusBarNotification showWithStatus:@"Playing" styleName:JDStatusBarStyleSuccess];
        [self stopRecording];
        self.isRecording = NO;
        NSError *err;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[CLFileManager voiceFilePathWithFileName:kAudioFileName]]
                                                                  error:&err];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
        [self.voiceControlButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updatePlayingProgress) userInfo:nil repeats:YES];
        self.progress = 0.05f;
        [self.progressView setProgress:self.progress animated:NO];
        [self showProgressView];
        
    } else {
        audioCreated = YES;
        canPlayAudio = YES;
        self.isRecording = YES;
        [self startRecording];
        self.voiceControlButton.titleLabel.font = [UIFont systemFontOfSize:55];
        [self.voiceControlButton setTitle:@"Stop" forState:UIControlStateNormal];
        
        [JDStatusBarNotification showWithStatus:@"Recording" styleName:JDStatusBarStyleError];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        self.progress = 0.05f;
        [self.progressView setProgress:self.progress animated:NO];
        [self showProgressView];
    }
}

- (void)updatePlayingProgress
{
    if (!self.timer.isValid) return;

    self.progress = self.audioPlayer.currentTime / self.audioPlayer.duration + 0.05f;
    if (self.progress < 1.0f) {
        [self.progressView setProgress:self.progress animated:YES];
    } else {
        self.progress = 1.0f;
        [self.progressView setProgress:self.progress animated:NO];
    }
}


- (void)updateProgress
{
    if (!self.timer.isValid) return;
    
    self.progress += (CGFloat)1.0/600;
    if (self.progress > 1.0f) {
        self.progress = 1.0f;
        [self.progressView setProgress:self.progress animated:YES];
        [self voiceControlButtonPressed:nil];
        return;
    }
    [self.progressView setProgress:self.progress animated:YES];
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

#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if ([JDStatusBarNotification isVisible]) {
        [JDStatusBarNotification dismissAnimated:YES];
    }
    [self dismissProgressView];
    
    canPlayAudio = YES;
    self.audioPlayer = nil;
    [self.voiceControlButton setTitle:@"▶︎" forState:UIControlStateNormal];
}

//**********


- (void) startRecording{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }

    /*
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    */
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:32] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    NSURL *url = [NSURL fileURLWithPath:[CLFileManager voiceFilePathWithFileName:kAudioFileName]];
    err = nil;
    self.voiceRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!self.voiceRecorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [self.voiceRecorder setDelegate:self];
    [self.voiceRecorder prepareToRecord];
    self.voiceRecorder.meteringEnabled = YES;
    
    // start recording
    [self.voiceRecorder record];
    
}

- (void)stopRecording{
    
    [self.voiceRecorder stop];
    
}


@end
