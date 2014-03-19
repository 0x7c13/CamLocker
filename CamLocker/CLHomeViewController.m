//
//  CLHomeViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLHomeViewController.h"
#import "CLMarkerManager.h"
#import "CLMarker.h"
#import "CLImageMarker.h"
#import "CLFileManager.h"
#import "CLTextMarker.h"

@interface CLHomeViewController ()

@end

@implementation CLHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", [CLFileManager imageFilePathWithFileName:nil]);
    
}

@end
