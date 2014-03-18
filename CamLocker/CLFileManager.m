//
//  CLFileManager.m
//  CamLocker
//
//  Created by FlyinGeek on 3/6/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "NSData+CLEncryption.h"
#import "CLFileManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CLFileManager

+ (NSString *)imageFilePathWithFileName:(NSString *)fileName
{
    return [[self class] documentsPathForFileName:fileName];
}

+ (void)saveImageToDisk:(UIImage *)image
           withFileName:(NSString *)fileName
    usingDataEncryption:(BOOL)yesOrNo
                withKey:(NSString *)key
{
    NSData *imageData = UIImagePNGRepresentation(image);
    
    if (yesOrNo) {
        if (!key) return;
        imageData = [imageData AES256EncryptWithKey:key];
    }
    
    NSString *filePath = [[self class] imageFilePathWithFileName:fileName];
    [imageData writeToFile:filePath atomically:YES];
}

+ (NSString *)saveXMLStringToDisk:(NSString *)xmlString
                     withFileName:(NSString *)fileName
{

    NSData *data = [NSData dataWithBytes: [xmlString UTF8String] length: [xmlString lengthOfBytesUsingEncoding: NSUTF8StringEncoding]];
    NSString *save = [NSString stringWithUTF8String: [data bytes]];
    NSString *filePath = [self documentsPathForFileName:fileName];
    [save writeToFile:filePath atomically: NO encoding: NSUTF8StringEncoding error: NULL];
    return filePath;
}

+ (NSString *)documentsPathForFileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:fileName];
}


@end
