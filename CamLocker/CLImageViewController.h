//
//  CLImageViewController.h
//  CamLocker
//
//  Created by FlyinGeek on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLImageViewControllerDelegate;

@interface CLImageViewController : UIViewController

@property (nonatomic, weak) id<CLImageViewControllerDelegate> delegate;
@property (nonatomic) NSArray *hiddenImages;

@end

@protocol CLImageViewControllerDelegate <NSObject>

@required
- (void) dismissViewController;

@end