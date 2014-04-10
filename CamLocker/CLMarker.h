//
//  CLMarker.h
//  CamLocker
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLMarker : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSString *imageFileName;
@property (nonatomic, copy, readonly) NSString *imagePath;
@property (nonatomic, copy, readonly) NSString *cosName;
@property (nonatomic, copy, readonly) NSString *key;

- (instancetype) init __attribute__((unavailable("init not available")));
- (instancetype)initWithMarkerImage:(UIImage *)markerImage;

- (void)activate;
- (void)deactivate;

- (void)deleteContent;

@end
