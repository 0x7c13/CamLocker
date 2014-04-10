//
//  CLScanViewController.h
//  CamLocker
//
//  Created by Jiaqi Liu on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "MetaioSDKViewController.h"
#import "UIViewController+CWPopup.h"
#import "CLImageViewController.h"
#import "CLTextViewController.h"
#import "CLAudioViewController.h"

@interface CLScanViewController : MetaioSDKViewController <CLImageViewControllerDelegate, CLTextViewControllerDelegate, CLAudioViewControllerDelegate>
{
    NSString *trackingConfigFile;
    metaio::IGeometry *imagePlane;
}

@property (nonatomic, strong) IBOutlet EAGLView *glView;

@end

