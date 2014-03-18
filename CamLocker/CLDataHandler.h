//
//  CLDataHandler.h
//  CamLocker
//
//  Created by FlyinGeek on 3/6/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ImageFormatOptionPNG = 0,
    ImageFormatOptionJPG
}ImageFormatOption;

@interface CLDataHandler : NSObject

+ (NSString *)imageFilePathWithFileName:(NSString *)fileName;

+ (NSString *)saveImageToDisk:(UIImage *)image
          withFileName:(NSString *)fileName
   usingRepresentation:(ImageFormatOption)option;

+ (NSString *)saveXMLStringToDisk: (NSString *)xmlString
                     withFileName: (NSString *)fileName;

+ (NSString *)hashValueOfUIImage:(UIImage *)image;

@end
