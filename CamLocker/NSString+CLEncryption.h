//
//  NSString+CLEncryption.h
//  CamLocker
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CLEncryption)

- (NSString *)hashValue;
+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length;

@end
