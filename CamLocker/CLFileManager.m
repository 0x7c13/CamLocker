//
//  CLFileManager.m
//  CamLocker
//
//  Created by Jiaqi Liu on 3/6/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLFileManager.h"
#import "CLKeyGenerator.h"
#import "NSString+CLEncryption.h"
#import "NSData+CLEncryption.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CLFileManager

+ (NSString *)imageFilePathWithFileName:(NSString *)fileName
{
    return [[self class] documentsPathForFileName:fileName];
}

+ (NSString *)textFilePathWithFileName:(NSString *)fileName
{
    return [[self class] documentsPathForFileName:fileName];
}

+ (NSString *)voiceFilePathWithFileName:(NSString *)fileName
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

+ (void)saveTextToDisk:(NSString *)text
          withFileName:(NSString *)fileName
   usingDataEncryption:(BOOL)yesOrNo
               withKey:(NSString *)key {
    
    NSData *textData = [NSData dataWithBytes: [text UTF8String] length: [text lengthOfBytesUsingEncoding: NSUTF8StringEncoding]];
    
    if (yesOrNo) {
        if (!key) return;
        textData = [textData AES256EncryptWithKey:[CLKeyGenerator hiddenKeyForKey:key]];
    }
    
    NSString *filePath = [[self class] imageFilePathWithFileName:fileName];
    [textData writeToFile:filePath atomically:YES];
}

+ (void)saveAudioToDisk:(NSData *)audioData
           withFileName:(NSString *)fileName
    usingDataEncryption:(BOOL)yesOrNo
                withKey:(NSString *)key {
    
    if (yesOrNo) {
        if (!key) return;
        audioData = [audioData AES256EncryptWithKey:[CLKeyGenerator hiddenKeyForKey:key]];
    }
    
    NSString *filePath = [[self class] imageFilePathWithFileName:fileName];
    [audioData writeToFile:filePath atomically:YES];
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
    return [[self documentsPath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSInteger) getFileSize:(NSString*) path
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

@end
