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
#import "EZAudio.h"
#import "THProgressView.h"
#import "SIAlertView.h"
#import "JDStatusBarNotification.h"
#import <AVFoundation/AVFoundation.h>

#define kAudioFileName @"tmp.caf"

@interface CLHiddenVoiceViewController () <AVAudioPlayerDelegate, EZMicrophoneDelegate> {
    BOOL canPlayAudio;
    BOOL isEncrypting;
    BOOL audioCreated;
}

@property (weak, nonatomic) IBOutlet UIButton *voiceControlButton;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;

@property (nonatomic) BOOL isRecording;
@property (nonatomic) EZMicrophone *microphone;
@property (nonatomic) EZRecorder *recorder;
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
    
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    
    self.progressView.borderTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [UIColor whiteColor];
    
    canPlayAudio = NO;
    isEncrypting = NO;
    audioCreated = NO;
    self.progress = 0.05f;
    self.isRecording = NO;
    self.progressView.hidden = YES;

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
        [self.progressView setProgress:self.progress animated:NO];
        self.voiceControlButton.userInteractionEnabled = YES;
    }];
}

- (IBAction)doneButtonPressed:(id)sender {
    if (isEncrypting) return;
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
    
    [self.recorder closeAudioFile];
    
    
}

- (IBAction)voiceControlButtonPressed:(id)sender {
    
    if (self.isRecording) {
        if( self.audioPlayer ){
            if( self.audioPlayer.playing ) [self.audioPlayer stop];
            self.audioPlayer = nil;
        }
        self.isRecording = NO;
        [self.microphone stopFetchingAudio];
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
        [self.microphone stopFetchingAudio];
        self.isRecording = NO;
        NSError *err;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[CLFileManager voiceFilePathWithFileName:kAudioFileName]]
                                                                  error:&err];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
        [self.voiceControlButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updatePlayingProgress) userInfo:nil repeats:YES];
        [self showProgressView];
        
    } else {
        audioCreated = YES;
        canPlayAudio = YES;
        self.isRecording = YES;
        [self.microphone startFetchingAudio];
        self.voiceControlButton.titleLabel.font = [UIFont systemFontOfSize:55];
        [self.voiceControlButton setTitle:@"Stop" forState:UIControlStateNormal];
        
        [JDStatusBarNotification showWithStatus:@"Recording" styleName:JDStatusBarStyleError];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [self showProgressView];
    }
}

- (void)updatePlayingProgress
{
    self.progress = self.audioPlayer.currentTime / self.audioPlayer.duration + 0.05f;
    if (self.progress < 1.0f) {
        [self.progressView setProgress:self.progress animated:YES];
    } else {
        [self.progressView setProgress:1.0f animated:YES];
    }
}


- (void)updateProgress
{
    self.progress += (CGFloat)1.0/600;
    if (self.progress > 1.0f) {
        self.progress = 0.05f;
        [self voiceControlButtonPressed:nil];
        return;
    }
    [self.progressView setProgress:self.progress animated:YES];
}

#pragma mark - EZMicrophoneDelegate

-(void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    // The AudioStreamBasicDescription of the microphone stream. This is useful when configuring the EZRecorder or telling another component what audio format type to expect.
    
    // Here's a print function to allow you to inspect it a little easier
    [EZAudio printASBD:audioStreamBasicDescription];
    
    // We can initialize the recorder with this ASBD
    self.recorder = [EZRecorder recorderWithDestinationURL:[NSURL fileURLWithPath:[CLFileManager voiceFilePathWithFileName:kAudioFileName]]
                                           andSourceFormat:audioStreamBasicDescription];
    
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
    if( self.isRecording ){
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
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

@end
