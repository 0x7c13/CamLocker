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
#import "CLTextMarker.h"

@interface CLHomeViewController ()

@end

@implementation CLHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([CLMarkerManager sharedManager].markers.count != 0) {
    NSArray *hiddenImages = @[[UIImage imageNamed:@"Markers/target_6.jpg"]];
        [[CLMarkerManager sharedManager] addImageMarkerWithMarkerImage:[UIImage imageNamed:@"Markers/target_1.jpg"] hiddenImages:hiddenImages];
        [[CLMarkerManager sharedManager] addTextMarkerWithMarkerImage:[UIImage imageNamed:@"Markers/target_2.jpg"] hiddenText:@"hello"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
