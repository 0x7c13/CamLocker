//
//  CLAppAPIClient.m
//  CamLocker
//
//  Created by FlyinGeek on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLAppAPIClient.h"
#import "CLConstants.h"

@implementation CLAppAPIClient

+ (instancetype)sharedClient {
    static CLAppAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[CLAppAPIClient alloc] initWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
        _sharedClient.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        //_sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    });
    
    return _sharedClient;
}

@end
