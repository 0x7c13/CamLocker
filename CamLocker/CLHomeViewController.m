//
//  CLHomeViewController.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import "CLTextMarker.h"
#import "CLImageMarker.h"
#import "CLFileManager.h"
#import "CLHomeViewController.h"
#import "CLMarkerManager.h"

@interface CLHomeViewController ()

@end

@implementation CLHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", [CLFileManager imageFilePathWithFileName:nil]);
}

- (IBAction)deleteAllDataButtonPressed:(id)sender {
    
    [[CLMarkerManager sharedManager] deleteAllMarkers];
}

@end
