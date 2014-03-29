//
//  CLHiddenVoiceViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/28/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLUtilities.h"
#import "CLHiddenVoiceViewController.h"
#import "UIColor+MLPFlatColors.h"
#import "EZAudio.h"

@interface CLHiddenVoiceViewController () <AVAudioPlayerDelegate, EZMicrophoneDelegate>

@property (weak, nonatomic) IBOutlet UIButton *voiceControlButton;
@property (weak, nonatomic) IBOutlet UIView *waveView;

@end

@implementation CLHiddenVoiceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [CLUtilities addBackgroundImageToView:self.view];

}

- (void)viewDidLayoutSubviews
{
    if (self.voiceControlButton.layer.sublayers.count != 2) {
        [self.voiceControlButton.layer addSublayer:[CLUtilities addDashedBorderToView:self.voiceControlButton
                                                                    withColor:[UIColor flatWhiteColor].CGColor]];
    }
}

@end
