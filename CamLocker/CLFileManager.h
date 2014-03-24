//
//  CLFileManager.h
//  CamLocker
//
//  Created by FlyinGeek on 3/6/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLFileManager : NSObject

+ (NSString *)imageFilePathWithFileName:(NSString *)fileName;

+ (void)saveImageToDisk:(UIImage *)image
           withFileName:(NSString *)fileName
    usingDataEncryption:(BOOL)yesOrNo
                withKey:(NSString *)key;

+ (NSString *)saveXMLStringToDisk: (NSString *)xmlString
                     withFileName: (NSString *)fileName;

+ (NSString *)documentsPath;
+ (NSString *)documentsPathForFileName:(NSString *)fileName;

+ (void)saveMainKeyStringToDisk:(NSString *)string;

+ (NSString *)mainKeyString;

@end
