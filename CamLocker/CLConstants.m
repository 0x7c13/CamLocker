//
//  CLConstants.m
//  CamLocker
//
//  Created by FlyinGeek on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLConstants.h"

@implementation CLConstants

NSString * const VERSION = @"1.0";

/* API PATHS */
NSString * const API_BASE_URL = @"http://camlockerapp.com";

NSString * const API_SHARE_MARKER = @"/ShareMarker";
NSString * const API_GET_MARKER = @"/Get/";

/* PARAMS */
NSString * const PARAM_DATA = @"Data";

/* JSON PARAMS */
NSString * const PARAM_DEVICE_ID = @"deviceId";
NSString * const PARAM_MARKER_NAME = @"markerName";
NSString * const PARAM_MARKER_IMAGE = @"markerImage";
NSString * const PARAM_MARKER_KEY = @"markerKey";
NSString * const PARAM_MARKER_HIDDEN_CONTENT = @"hiddenContent";

@end
