//
//  CLFileManager.m
//  CamLocker
//
//  Created by FlyinGeek on 3/6/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLFileManager.h"
#import "CLKeyGenerator.h"
#import "NSString+Random.h"
#import "NSData+CLEncryption.h"
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
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    if (yesOrNo) {
        if (!key) return;
        imageData = [imageData AES256EncryptWithKey:[CLKeyGenerator hiddenKeyForKey:key]];
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

+ (void)saveMainKeyStringToDisk:(NSString *)string
{
    NSString *filePath = [self documentsPathForFileName:[@"I Love Vicky! ~.~!" hashValue]];
    NSData *keyData = [[filePath dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:@"I Love CJ! ^.^!"];
    [keyData writeToFile:filePath atomically:YES];
}

+ (NSString *)mainKeyString
{
    NSString *filePath = [self documentsPathForFileName:[@"I Love Vicky! ~.~!" hashValue]];
    NSData *keyData = [[NSData dataWithContentsOfFile:filePath] AES256DecryptWithKey:@"I Love CJ! ^.^!"];
    return [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
}

+ (NSString *)documentsPathForFileName:(NSString *)fileName
{
    return [[self documentsPath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

@end
