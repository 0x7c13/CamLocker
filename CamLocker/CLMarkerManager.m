//
//  CLMarkerManager.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import "CLTextMarker.h"
#import "CLImageMarker.h"
#import "CLAudioMarker.h"
#import "CLMarkerManager.h"
#import "CLFileManager.h"
#import "CLKeyGenerator.h"
#import "CLTrackingXMLGenerator.h"
#import "NSData+CLEncryption.h"

#define kMarkers @"CamLockerMarkers"
#define kTrackingFileName @"CamLockerTrackingFile.xml"

@interface CLMarkerManager ()

@end

@implementation CLMarkerManager

- (instancetype)init
{
    if (self = [super init]) {
        
        NSData *markerData = [[NSUserDefaults standardUserDefaults] objectForKey:kMarkers];
        markerData = [markerData AES256DecryptWithKey:[CLKeyGenerator mainKeyForKey:[CLKeyGenerator mainKeyString]]];
        if (!(_markers = [NSKeyedUnarchiver unarchiveObjectWithData:markerData])) {
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

- (CLMarker *)markerByCosName:(NSString *)cosName
{
    for (CLMarker *marker in self.markers) {
        if ([marker.cosName isEqualToString:cosName]) {
            return marker;
        }
    }
    return nil;
}

- (void)addTextMarkerWithMarkerImage:(UIImage *)image
                          hiddenText:(NSString *)hiddenText
                 withCompletionBlock:(void (^)())completion
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.markers addObject:[[CLTextMarker alloc]initWithMarkerImage:image hiddenText:hiddenText]];
        NSData *markerData = [NSKeyedArchiver archivedDataWithRootObject:self.markers];
        markerData = [markerData AES256EncryptWithKey:[CLKeyGenerator mainKeyForKey:[CLKeyGenerator mainKeyString]]];
        [[NSUserDefaults standardUserDefaults] setObject:markerData forKey:kMarkers];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

-(void)addImageMarkerWithMarkerImage:(UIImage *)image
                        hiddenImages:(NSArray *)hiddenImages
                 withCompletionBlock:(void (^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.markers addObject:[[CLImageMarker alloc]initWithMarkerImage:image hiddenImages:hiddenImages]];
        
        NSData *markerData = [NSKeyedArchiver archivedDataWithRootObject:self.markers];
        markerData = [markerData AES256EncryptWithKey:[CLKeyGenerator mainKeyForKey:[CLKeyGenerator mainKeyString]]];
        [[NSUserDefaults standardUserDefaults] setObject:markerData forKey:kMarkers];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

-(void)addAudioMarkerWithMarkerImage:(UIImage *)image
                     hiddenAudioData:(NSData *)hiddenAudioData
                 withCompletionBlock:(void (^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.markers addObject:[[CLAudioMarker alloc]initWithMarkerImage:image hiddenAudio:hiddenAudioData]];
        
        NSData *markerData = [NSKeyedArchiver archivedDataWithRootObject:self.markers];
        markerData = [markerData AES256EncryptWithKey:[CLKeyGenerator mainKeyForKey:[CLKeyGenerator mainKeyString]]];
        [[NSUserDefaults standardUserDefaults] setObject:markerData forKey:kMarkers];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
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
            [(CLImageMarker *)markerToBeDeleted deleteContent];
        } else if ([markerToBeDeleted isKindOfClass:[CLTextMarker class]]) {
            [(CLTextMarker *)markerToBeDeleted deleteContent];
        } else if ([markerToBeDeleted isKindOfClass:[CLAudioMarker class]]) {
            [(CLAudioMarker *)markerToBeDeleted deleteContent];
        }
    }
}

-(void)deleteAllMarkers
{
    for (CLMarker *marker in self.markers) {
        if ([marker isKindOfClass:[CLImageMarker class]]) {
            [(CLImageMarker *)marker deleteContent];
        } else if ([marker isKindOfClass:[CLTextMarker class]]) {
            [(CLTextMarker *)marker deleteContent];
        } else if ([marker isKindOfClass:[CLAudioMarker class]]) {
            [(CLAudioMarker *)marker deleteContent];
        }
    }
    [self.markers removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMarkers];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)trackingFilePath
{
    return [CLFileManager saveXMLStringToDisk:[self trackingXMLString] withFileName:kTrackingFileName];
}

- (NSString *)trackingXMLString
{
    NSMutableArray *imageMarkerNames = [[NSMutableArray alloc] initWithCapacity:self.markers.count];
    NSMutableArray *cosNames = [[NSMutableArray alloc] initWithCapacity:self.markers.count];
    
    for (CLMarker *marker in self.markers) {
        [imageMarkerNames addObject:marker.imageFileName];
        [cosNames addObject:marker.cosName];
    }
    return [CLTrackingXMLGenerator generateTrackingXMLStringUsingMarkerImageFileNames:imageMarkerNames cosNames:cosNames];
}

- (void)activateMarkersWithCompletionBlock:(void (^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (CLMarker *marker in self.markers) {
            [marker activate];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (void)deactivateMarkers
{
    for (CLMarker *marker in self.markers) {
        [marker deactivate];
    }
    [[NSFileManager defaultManager] removeItemAtPath:[CLFileManager documentsPathForFileName:kTrackingFileName] error:nil];
}

@end
