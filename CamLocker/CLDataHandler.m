//
//  CLDataHandler.m
//  CamLocker
//
//  Created by FlyinGeek on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLAppAPIClient.h"
#import "CLDataHandler.h"
#import "CLKeyGenerator.h"
#import "CLTextMarker.h"
#import "CLImageMarker.h"
#import "CLAudioMarker.h"
#import "CLConstants.h"

#define kAFNetworkingEnabled 1

@implementation CLDataHandler 

+ (void)uploadMarker:(CLMarker *)marker completionBlock:(void (^)(CLDataHandlerOption option, NSURL *markerURL, NSError *error))completion;
{
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    
    [dataDic setObject:[CLKeyGenerator OpenUDID] forKey:PARAM_DEVICE_ID];
    [dataDic setObject:marker.cosName forKey:PARAM_MARKER_NAME];
    [dataDic setObject:[[NSData dataWithContentsOfFile:[marker.imagePath stringByAppendingString:@".camLocker"]] base64EncodedStringWithOptions:0] forKey:PARAM_MARKER_IMAGE];
    
    if ([marker isKindOfClass:[CLTextMarker class]]) {
        CLTextMarker *textMarker = (CLTextMarker *)marker;
        [dataDic setObject:[[NSKeyedArchiver archivedDataWithRootObject:textMarker] base64EncodedStringWithOptions:0] forKey:PARAM_MARKER_KEY];
        [dataDic setObject:@[[[NSData dataWithContentsOfFile:[textMarker.hiddenTextPath stringByAppendingString:@".camLocker"]] base64EncodedStringWithOptions:0]] forKey:PARAM_MARKER_HIDDEN_CONTENT];
        
    } else if ([marker isKindOfClass:[CLImageMarker class]]) {
        
        CLImageMarker *imageMarker = (CLImageMarker *)marker;
        [dataDic setObject:[[NSKeyedArchiver archivedDataWithRootObject:imageMarker] base64EncodedStringWithOptions:0] forKey:PARAM_MARKER_KEY];
        
        NSMutableArray *imageAry = [[NSMutableArray alloc] initWithCapacity:imageMarker.hiddenImagePaths.count];
        for (NSString *imagePath in imageMarker.hiddenImagePaths) {
            [imageAry addObject:[[NSData dataWithContentsOfFile:[imagePath stringByAppendingString:@".camLocker"]] base64EncodedStringWithOptions:0]];
        }
        [dataDic setObject:imageAry forKey:PARAM_MARKER_HIDDEN_CONTENT];
        
    } else if ([marker isKindOfClass:[CLAudioMarker class]]) {
        
        CLAudioMarker *audioMarker = (CLAudioMarker *)marker;
        [dataDic setObject:[[NSKeyedArchiver archivedDataWithRootObject:audioMarker] base64EncodedStringWithOptions:0] forKey:PARAM_MARKER_KEY];
        [dataDic setObject:@[[[NSData dataWithContentsOfFile:[audioMarker.hiddenAudioPath stringByAppendingString:@".camLocker"]] base64EncodedStringWithOptions:0]] forKey:PARAM_MARKER_HIDDEN_CONTENT];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDic options:kNilOptions error:nil];
    //NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSLog(@"%@", [NSByteCountFormatter stringFromByteCount:jsonData.length countStyle:NSByteCountFormatterCountStyleFile]);
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:PARAM_DATA];
    
    //NSLog(@"%@", postData);
    
    [[CLAppAPIClient sharedClient] POST:API_SHARE_MARKER
                             parameters:postData
                                success:^(NSURLSessionDataTask *task, id responseObject){
                                    
                                    NSURL *downloadURL = [NSURL URLWithString:[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]];
                                    
                                    completion(CLDataHandlerOptionSuccess,downloadURL, nil);
                                }
                                failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    
                                    completion(CLDataHandlerOptionFailure, nil, error);
                                }];
 
}


+ (void)downloadMarkerBy:(NSString *)identifier completionBlock:(void (^)(CLDataHandlerOption option, NSDictionary *markerData, NSError *error))completion
{
    
    [[CLAppAPIClient sharedClient] GET:[API_GET_MARKER stringByAppendingString:identifier]
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject){
    
                                   NSDictionary *markerDic = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                                   
                                   completion(CLDataHandlerOptionSuccess, markerDic, nil);
                               
                               }
                               failure:^(NSURLSessionDataTask *task, NSError *error) {
    
                                   completion(CLDataHandlerOptionFailure, nil, error);
                               }];
    
}

@end
