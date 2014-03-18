//
//  CLMarkerManager.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLTextMarker.h"
#import "CLImageMarker.h"
#import "CLMarkerManager.h"
#define kMarkers @"Markers"


@implementation CLMarkerManager

- (instancetype)init
{
    if (self = [super init]) {
        NSData *markerData = [[NSUserDefaults standardUserDefaults] objectForKey:kMarkers];
        if (!(_markers = [NSKeyedUnarchiver unarchiveObjectWithData:markerData])) {
            NSLog(@"No markers are found");
            _markers = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (void)addTextMarkerWithMarkerImage:(UIImage *)image
                          hiddenText:(NSString *)hiddenText {
    
    [self.markers addObject:[[CLTextMarker alloc]initWithMarkerImage:image hiddenText:hiddenText]];
    NSData *markerData = [NSKeyedArchiver archivedDataWithRootObject:self.markers];
    [[NSUserDefaults standardUserDefaults] setObject:markerData forKey:kMarkers];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)addImageMarkerWithMarkerImage:(UIImage *)image
                        hiddenImages:(NSArray *)hiddenImages {
    
    [self.markers addObject:[[CLImageMarker alloc]initWithMarkerImage:image hiddenImages:hiddenImages]];

    NSData *markerData = [NSKeyedArchiver archivedDataWithRootObject:self.markers];
    [[NSUserDefaults standardUserDefaults] setObject:markerData forKey:kMarkers];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)deleteMarkerByCosName:(NSString *)cosName
{
    CLMarker *markerToBeDeleted;
    for (CLMarker *marker in self.markers) {
        if ([marker.cosName isEqualToString:cosName]) {
            markerToBeDeleted = marker;
            break;
        }
    }
    if (markerToBeDeleted) {
        if ([markerToBeDeleted isKindOfClass:[CLImageMarker class]]) {
            [(CLImageMarker *)markerToBeDeleted deleteHiddenImages];
        }
        [markerToBeDeleted deleteMarkerImage];
    }
}

@end
