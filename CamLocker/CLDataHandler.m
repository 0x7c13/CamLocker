//
//  CLDataHandler.m
//  CamLocker
//
//  Created by FlyinGeek on 3/6/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLDataHandler.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CLDataHandler

+ (NSString *)imageFilePathWithFileName:(NSString *)fileName
{
    return [[self class] documentsPathForFileName:fileName];
}

+ (NSString *)saveImageToDisk:(UIImage *)image
                 withFileName:(NSString *)fileName
          usingRepresentation:(ImageFormatOption)option
{
    NSData *imageData;
    
    if (option == ImageFormatOptionPNG) {
        imageData = UIImagePNGRepresentation(image);
    } else if (option == ImageFormatOptionJPG) {
        imageData = UIImageJPEGRepresentation(image, 1);
    }
    
    NSString *filePath = [[self class] imageFilePathWithFileName:fileName];
    [imageData writeToFile:filePath atomically:YES];
    return filePath;
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

+ (NSString *)hashValueOfUIImage:(UIImage *)image
{
    unsigned char result[16];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    CC_MD5([imageData bytes], [imageData length], result);
    NSString *hashString = [NSString stringWithFormat:
                           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    NSLog(@"%@", hashString);
    return hashString;
}

@end
