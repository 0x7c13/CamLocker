//
//  UIImage+CLEncryption.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "UIImage+CLEncryption.h"

@implementation UIImage (CLEncryption)

- (NSString *)hashValue
{
    unsigned char result[16];
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(self, 1)];
    CC_MD5([imageData bytes], [imageData length], result);
    NSString *hashString = [NSString stringWithFormat:
                            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                            result[0], result[1], result[2], result[3],
                            result[4], result[5], result[6], result[7],
                            result[8], result[9], result[10], result[11],
                            result[12], result[13], result[14], result[15]
                            ];
    return hashString;
}


@end
