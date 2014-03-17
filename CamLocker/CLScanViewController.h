//
//  CLScanViewController.h
//  CamLocker
//
//  Created by FlyinGeek on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "MetaioSDKViewController.h"
#import "UIViewController+CWPopup.h"
#import "CLImageViewController.h"
#import "CLTextViewController.h"

@interface CLScanViewController : MetaioSDKViewController <CLImageViewControllerDelegate, CLTextViewControllerDelegate>
{
    NSString *trackingConfigFile;
}

@property (nonatomic, strong) IBOutlet EAGLView *glView;

@end

