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
#import "CLKeyGenerator.h"
#import "CLMarkerManager.h"
#import "NSData+CLEncryption.h"

#define kAFNetworkingEnabled 1

@implementation CLDataHandler 

+ (void)uploadMarker:(CLMarker *)marker
            progress:(void (^)(NSUInteger, NSInteger))progress
     completionBlock:(void (^)(CLDataHandlerOption, NSURL *, NSError *))completion
{
    NSLog(@"Marker to upload is type of :%@", [marker class]);
    
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
    NSLog(@"File size to upload :%@", [NSByteCountFormatter stringFromByteCount:jsonData.length countStyle:NSByteCountFormatterCountStyleFile]);
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:PARAM_DATA];
    
    //NSLog(@"%@", postData);
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableURLRequest *request =
    [serializer requestWithMethod:@"POST"
                        URLString:[API_BASE_URL stringByAppendingString:API_SHARE_MARKER]
                       parameters:postData
                            error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         NSURL *downloadURL = [NSURL URLWithString:[[NSString alloc] initWithData:responseObject
                                                                                                         encoding:NSUTF8StringEncoding]];
                                    
                                         NSLog(@"Marker uploaded!");
                                         completion(CLDataHandlerOptionSuccess,downloadURL, nil);
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         NSLog(@"Error occurs during uploading!");
                                         completion(CLDataHandlerOptionFailure, nil, error);
                                     }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite){
        progress(totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation start];
}


+ (void)downloadMarkerByDownloadCode:(NSString *)downloadCode
                            progress:(void (^)(NSUInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                     completionBlock:(void (^)(CLDataHandlerOption option, NSError *error))completion
{
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];

    NSMutableURLRequest *request =
    [serializer requestWithMethod:@"GET"
                        URLString:[API_BASE_URL stringByAppendingString:[API_GET_MARKER stringByAppendingString:downloadCode]]
                       parameters:nil
                            error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                        NSDictionary *packetDic = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                                         //NSLog(@"%@", packetDic);
                                         
                                         [[self class] processMarkerDataWithAttribute:packetDic completion:^(CLDataHandlerOption option){
                                            
                                             if (option == CLDataHandlerOptionSuccess) {
                                                 NSLog(@"Marker downloaded!");
                                                 completion(CLDataHandlerOptionSuccess, nil);
                                             } else if (option == CLDataHandlerOptionFailure) {
                                                 NSLog(@"Error occurs during downloading!");
                                                 completion(CLDataHandlerOptionFailure, nil);
                                             }
                                         }];
                                        
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         completion(CLDataHandlerOptionFailure, error);
                                     }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead){

        progress(totalBytesRead, totalBytesExpectedToRead);
    }];
    
    [operation start];
}

+ (void)processMarkerDataWithAttribute:(NSDictionary *)packetDic completion:(void (^)(CLDataHandlerOption option))completion
{
    if (packetDic == nil) {
        completion(CLDataHandlerOptionFailure);
        return;
    }
    
    if ([packetDic objectForKey:PARAM_MARKER_KEY] == [NSNull null] || [packetDic objectForKey:PARAM_MARKER_KEY] == nil) {
        completion(CLDataHandlerOptionFailure);
        return;
    }
    
    CLMarker *marker = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithBase64EncodedString:(NSString *)[packetDic objectForKey:PARAM_MARKER_KEY] options:0]];\
    
    if (marker == nil) {
        completion(CLDataHandlerOptionFailure);
        return;
    }
    
    if ([packetDic objectForKey:PARAM_MARKER_IMAGE] == [NSNull null] || [packetDic objectForKey:PARAM_MARKER_IMAGE] == nil) {
        completion(CLDataHandlerOptionFailure);
        return;
    }
    
    UIImage *markerImage = [UIImage imageWithData:[[[NSData alloc] initWithBase64EncodedData:[packetDic objectForKey:PARAM_MARKER_IMAGE] options:0] AES256DecryptWithKey:[CLKeyGenerator hiddenKeyForKey:marker.key]]];
    if (markerImage == nil) {
        completion(CLDataHandlerOptionFailure);
        return;
    }
    
    if ([packetDic objectForKey:PARAM_MARKER_HIDDEN_CONTENT] == [NSNull null] || [packetDic objectForKey:PARAM_MARKER_HIDDEN_CONTENT] == nil) {
        completion(CLDataHandlerOptionFailure);
        return;
    }
    
    if ([marker isKindOfClass:[CLTextMarker class]]) {
        NSLog(@"Text Marker");
        NSString *hiddenText = [[NSString alloc] initWithData:[[[NSData alloc] initWithBase64EncodedString:[[packetDic objectForKey:PARAM_MARKER_HIDDEN_CONTENT] objectAtIndex:0] options:0] AES256DecryptWithKey:[CLKeyGenerator hiddenKeyForKey:((CLTextMarker *)marker).keyOfHiddenText]] encoding:NSUTF8StringEncoding];
        
        [[CLMarkerManager sharedManager] addTextMarkerWithMarkerImage:markerImage hiddenText:hiddenText withCompletionBlock:^{
            completion(CLDataHandlerOptionSuccess);
        }];
        
    } else if ([marker isKindOfClass:[CLAudioMarker class]]) {
        NSLog(@"Audio Marker");
        
        NSData *hiddenAudioData = [[[NSData alloc] initWithBase64EncodedString:[[packetDic objectForKey:PARAM_MARKER_HIDDEN_CONTENT] objectAtIndex:0] options:0] AES256DecryptWithKey:[CLKeyGenerator hiddenKeyForKey:((CLAudioMarker *)marker).keyOfHiddenAudio]];
        
        [[CLMarkerManager sharedManager] addAudioMarkerWithMarkerImage:markerImage hiddenAudioData:hiddenAudioData withCompletionBlock:^{
            completion(CLDataHandlerOptionSuccess);
        }];
        
    } else if ([marker isKindOfClass:[CLImageMarker class]]) {
        NSLog(@"Image Marker");
        
        NSMutableArray *hiddenImages = [[NSMutableArray alloc]init];
        
        NSArray *arrayOfBase64Data = [packetDic objectForKey:PARAM_MARKER_HIDDEN_CONTENT];
        
        for (NSInteger i = 0; i < arrayOfBase64Data.count; i++) {
            UIImage *hiddenImage = [UIImage imageWithData:[[[NSData alloc] initWithBase64EncodedString:arrayOfBase64Data[i] options:0] AES256DecryptWithKey:[CLKeyGenerator hiddenKeyForKey:((CLImageMarker *)marker).keyOfHiddenImages]]];
            [hiddenImages addObject:hiddenImage];
        }
        
        [[CLMarkerManager sharedManager] addImageMarkerWithMarkerImage:markerImage hiddenImages:hiddenImages withCompletionBlock:^{
            completion(CLDataHandlerOptionSuccess);
        }];
        
    }
}

@end


