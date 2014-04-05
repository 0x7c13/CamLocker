//
//  CLAppAPIClient.m
//  CamLocker
//
//  Created by FlyinGeek on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLAppAPIClient.h"

static NSString * const CLBaseURLString = @"http://coderhosting.com:8080/CamLockerApp/";

@implementation CLAppAPIClient

+ (instancetype)sharedClient {
    static CLAppAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[CLAppAPIClient alloc] initWithBaseURL:[NSURL URLWithString:CLBaseURLString]];
        //_sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    
    return _sharedClient;
}

@end
