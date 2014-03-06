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

const int numberOfImagePlanes = 6;

@interface CLScanViewController : MetaioSDKViewController <CLImageViewControllerDelegate, CLTextViewControllerDelegate>
{
    NSString *trackingConfigFile;
    metaio::IGeometry*	m_imagePlane[numberOfImagePlanes + 1];
}

@property (nonatomic, strong) IBOutlet EAGLView *glView;

@end

