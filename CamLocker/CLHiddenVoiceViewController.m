//
//  CLHiddenVoiceViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/28/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLFileManager.h"
#import "CLHiddenVoiceViewController.h"
#import "UIColor+MLPFlatColors.h"
#import "THProgressView.h"
#import "SIAlertView.h"
#import "JDStatusBarNotification.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define kAudioFileName @"tmp.aac"

@interface CLHiddenVoiceViewController () <AVAudioPlayerDelegate, AVAudioRecorderDelegate> {
    BOOL canPlayAudio;
    BOOL isEncrypting;
    BOOL audioCreated;
}

@property (weak, nonatomic) IBOutlet UIButton *voiceControlButton;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;

@property (nonatomic) BOOL isRecording;
@property (nonatomic) AVAudioRecorder *voiceRecorder;
@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) CGFloat progress;

@end

@implementation CLHiddenVoiceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSFileManager defaultManager] removeItemAtPath:[CLFileManager voiceFilePathWithFileName:kAudioFileName] error:nil];
    
    [CLUtilities addBackgroundImageToView:self.view withImageName:@"bg_4.jpg"];

    self.voiceControlButton.layer.cornerRadius = 15;
    
    self.progressView.borderTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [UIColor whiteColor];
    
    canPlayAudio = NO;
    isEncrypting = NO;
    audioCreated = NO;
    self.progress = 0.05f;
    self.isRecording = NO;
    self.progressView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isRecording) {
        [self.voiceRecorder stop];
        [[NSFileManager defaultManager] removeItemAtPath:[CLFileManager voiceFilePathWithFileName:kAudioFileName] error:nil];
    }
    if( self.audioPlayer ){
        if( self.audioPlayer.playing ) [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    if ([JDStatusBarNotification isVisible]) {
        [JDStatusBarNotification dismissAnimated:YES];
    }
    [self.timer invalidate];
    [self stopRecording];
}

- (void)viewDidLayoutSubviews
{
    if (self.voiceControlButton.layer.sublayers.count != 2) {
        [self.voiceControlButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.voiceControlButton
                                                                    withColor:[UIColor flatWhiteColor].CGColor]];
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
    if (isEncrypting || self.isRecording) return;
    if (!audioCreated) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops" andMessage:@"Please add a voice record."];
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:nil];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
        alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
        alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
        
        [alertView show];
        return;
    }
    
    //[self.recorder closeAudioFile];
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

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


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
