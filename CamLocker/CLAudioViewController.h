//
//  CLAudioViewController.h
//  CamLocker
//
//  Created by FlyinGeek on 4/8/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLAudioViewControllerDelegate;

@interface CLAudioViewController : UIViewController

@property (nonatomic, weak) id<CLAudioViewControllerDelegate> delegate;
@property (nonatomic) NSData *hiddenAudioData;

@end


@protocol CLAudioViewControllerDelegate <NSObject>

@required
- (void) dismissViewController;

@end