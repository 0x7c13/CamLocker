//
//  CLDataHandler.h
//  CamLocker
//
//  Created by FlyinGeek on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLMarker.h"
#import "AFNetworking.h"
#import <Foundation/Foundation.h>

@interface CLDataHandler : NSObject

+ (void)uploadMarker:(CLMarker *)marker;

@end
