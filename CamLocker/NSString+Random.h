//
//  NSString+Random.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Random)

- (NSString *)hashValue;
+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length;

@end
