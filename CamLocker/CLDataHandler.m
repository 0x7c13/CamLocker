//
//  CLDataHandler.m
//  CamLocker
//
//  Created by FlyinGeek on 3/6/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLDataHandler.h"

@implementation CLDataHandler

+ (NSString *)saveImageToDisk:(UIImage *)image
          withFileName:(NSString *)filename
   usingRepresentation:(ImageFormatOption)option
{
    NSData *imageData;
    
    if (option == ImageFormatOptionPNG) {
        imageData = UIImagePNGRepresentation(image);
    } else if (option == ImageFormatOptionJPG) {
        imageData = UIImageJPEGRepresentation(image, 1);
    }
    
    NSString *filePath = [[self class] documentsPathForFileName:filename];
    [imageData writeToFile:filePath atomically:YES]; //Write the file
    return filePath;
}

+ (NSString *)saveXMLStringToDisk: (NSString *)xmlString
               withFileName: (NSString *)filename
{

    NSData *data = [NSData dataWithBytes: [xmlString UTF8String] length: [xmlString lengthOfBytesUsingEncoding: NSUTF8StringEncoding]];
    NSString *save = [NSString stringWithUTF8String: [data bytes]];
    NSString *filePath = [self documentsPathForFileName:filename];
    [save writeToFile:filePath atomically: NO encoding: NSUTF8StringEncoding error: NULL];
    return filePath;
}

+ (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

@end
