//
//  CLAudioViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 4/8/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLAudioViewController.h"
#import "THProgressView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface CLAudioViewController () <AVAudioPlayerDelegate>

@property (nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSTimer *playbackTimer;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *voiceControlButton;

@end

@implementation CLAudioViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:toolbarBackground];
    [self.view sendSubviewToBack:toolbarBackground];
    
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:self.hiddenAudioData error:&error];
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    } else {
        [self.audioPlayer prepareToPlay];
        self.audioPlayer.delegate = self;
    }
    
    [self.voiceControlButton setTitle:@"▶︎" forState:UIControlStateNormal];
    
    self.progressView.borderTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [UIColor whiteColor];
    self.progressView.hidden = YES;
    self.progressView.userInteractionEnabled = NO;
}

- (IBAction)voiceControlButtonPressed:(id)sender {
    
    if (self.audioPlayer.isPlaying) {
        [self.playbackTimer invalidate];
        [self.audioPlayer stop];
        [self.voiceControlButton setTitle:@"▶︎" forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.5f animations:^{
            self.progressView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.progressView.hidden = YES;
        }];
    } else {
        self.progressView.alpha = 0.0f;
        self.progressView.hidden = NO;
        [UIView animateWithDuration:0.5f animations:^{
            self.progressView.alpha = 1.0f;
        } completion:^(BOOL finished) {
        }];
        
        [self.audioPlayer play];
        [self.voiceControlButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f
                                                       target:self
                                                     selector:@selector(updateProgress)
                                                     userInfo:nil
                                                      repeats:YES];
        
    }
}

- (void)updateProgress {

    if (self.audioPlayer.isPlaying) {

        float f = self.audioPlayer.currentTime / self.audioPlayer.duration;
        [self.progressView setProgress:f animated:YES];
    }
}

#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {

    [self.playbackTimer invalidate];
    [self.voiceControlButton setTitle:@"▶︎" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5f animations:^{
        self.progressView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.progressView setProgress:0.0f animated:NO];
        self.progressView.hidden = YES;
    }];
}

- (IBAction)quitButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate dismissViewController];
    }
}


@end
