//
//  NSData+CLEncryption.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import <Foundation/Foundation.h>

@interface NSData (CLEncryption)

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
