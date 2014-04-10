//
//  CLDataHandler.h
//  CamLocker
//
//  Created by Jiaqi Liu on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import "AFNetworking.h"
#import <Foundation/Foundation.h>

typedef enum {
    CLDataHandlerOptionSuccess,
    CLDataHandlerOptionFailure
}CLDataHandlerOption;

@interface CLDataHandler : NSObject

+ (void)uploadMarker:(CLMarker *)marker
            progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten))progress
     completionBlock:(void (^)(CLDataHandlerOption option, NSURL *markerURL, NSError *error))completion;

+ (void)downloadMarkerByDownloadCode:(NSString *)downloadCode
                            progress:(void (^)(NSUInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                     completionBlock:(void (^)(CLDataHandlerOption option, NSError *error))completion;

@end
