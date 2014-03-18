//
//  CLTrackingXMLGenerator.h
//  CamLocker
//
//  Created by FlyinGeek on 3/17/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLTrackingXMLGenerator : NSObject

+ (NSString *)generateTrackingXMLStringUsingMarkerImageFileNames:(NSArray *)markerImageFileNames
                                                        cosNames:(NSArray *)cosNames;

@end
