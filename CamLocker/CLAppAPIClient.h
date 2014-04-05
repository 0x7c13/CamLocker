//
//  CLAppAPIClient.h
//  CamLocker
//
//  Created by FlyinGeek on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface CLAppAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
