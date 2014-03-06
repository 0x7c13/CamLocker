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

+ (NSString *)saveImageOnDisk:(UIImage *)image
          withFileName:(NSString *)filename
   usingRepresentation:(ImageFormatOption)option;

+ (NSString *)saveXMLStringOnDisk: (NSString *)xmlString
                     withFileName: (NSString *)filename;
@end
