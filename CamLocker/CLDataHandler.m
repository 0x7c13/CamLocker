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

@implementation CLDataHandler 

+ (void)uploadMarker:(CLMarker *)marker
{
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    
    [dataDic setObject:[CLKeyGenerator OpenUDID] forKey:@"deviceId"];
    [dataDic setObject:marker.cosName forKey:@"markerName"];
    [dataDic setObject:[[NSData dataWithContentsOfFile:[marker.imagePath stringByAppendingString:@".camLocker"]] base64EncodedStringWithOptions:0] forKey:@"markerImage"];
    
    if ([marker isKindOfClass:[CLTextMarker class]]) {
        CLTextMarker *textMarker = (CLTextMarker *)marker;
        [dataDic setObject:[[NSKeyedArchiver archivedDataWithRootObject:textMarker] base64EncodedStringWithOptions:0] forKey:@"markerKey"];
        [dataDic setObject:@[[[NSData dataWithContentsOfFile:[textMarker.hiddenTextPath stringByAppendingString:@".camLocker"]] base64EncodedStringWithOptions:0]] forKey:@"hiddenContent"];
        
    } else if ([marker isKindOfClass:[CLImageMarker class]]) {
        
        CLImageMarker *imageMarker = (CLImageMarker *)marker;
        [dataDic setObject:[[NSKeyedArchiver archivedDataWithRootObject:imageMarker] base64EncodedStringWithOptions:0] forKey:@"markerKey"];
        
        NSMutableArray *imageAry = [[NSMutableArray alloc] initWithCapacity:imageMarker.hiddenImagePaths.count];
        for (NSString *imagePath in imageMarker.hiddenImagePaths) {
            [imageAry addObject:[[NSData dataWithContentsOfFile:[imagePath stringByAppendingString:@".camLocker"]] base64EncodedStringWithOptions:0]];
        }
        [dataDic setObject:imageAry forKey:@"hiddenContent"];
        
    } else if ([marker isKindOfClass:[CLAudioMarker class]]) {
        
        CLAudioMarker *audioMarker = (CLAudioMarker *)marker;
        [dataDic setObject:[[NSKeyedArchiver archivedDataWithRootObject:audioMarker] base64EncodedStringWithOptions:0] forKey:@"markerKey"];
        [dataDic setObject:@[[[NSData dataWithContentsOfFile:[audioMarker.hiddenAudioPath stringByAppendingString:@".camLocker"]] base64EncodedStringWithOptions:0]] forKey:@"hiddenContent"];
    }
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:dataDic forKey:@"Data"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:postData options:kNilOptions error:nil];
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"%@", [NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile]);

    
    [[CLAppAPIClient sharedClient] POST:@"ShareMarker"
                             parameters:postData
                                success:^(NSURLSessionDataTask *task, id responseObject){
                                    NSLog(@"%@", responseObject);
                                    
                                }
                                failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    
                                    NSLog(@"%@", error.localizedDescription);
                                    
                                }];
     

}


@end
