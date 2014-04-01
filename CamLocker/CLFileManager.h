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
+ (NSString *)textFilePathWithFileName:(NSString *)fileName;
+ (NSString *)voiceFilePathWithFileName:(NSString *)fileName;

+ (void)saveImageToDisk:(UIImage *)image
           withFileName:(NSString *)fileName
    usingDataEncryption:(BOOL)yesOrNo
                withKey:(NSString *)key;

+ (void)saveTextToDisk:(NSString *)text
          withFileName:(NSString *)fileName
   usingDataEncryption:(BOOL)yesOrNo
               withKey:(NSString *)key;

+ (void)saveAudioToDisk:(NSData *)audioData
           withFileName:(NSString *)fileName
    usingDataEncryption:(BOOL)yesOrNo
                withKey:(NSString *)key;

+ (NSString *)saveXMLStringToDisk: (NSString *)xmlString
                     withFileName: (NSString *)fileName;

+ (NSString *)documentsPath;
+ (NSString *)documentsPathForFileName:(NSString *)fileName;

+ (NSInteger) getFileSize:(NSString*) path;

@end
