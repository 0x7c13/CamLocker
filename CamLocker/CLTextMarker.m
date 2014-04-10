//
//  CLTextMarker.m
//  CamLocker
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "NSString+CLEncryption.h"
#import "CLFileManager.h"
#import "CLTextMarker.h"
#import "CLKeyGenerator.h"
#import "NSData+CLEncryption.h"

@interface CLTextMarker ()

@property (nonatomic, copy) NSString *hiddenTextPath;
@property (nonatomic, copy) NSString *keyOfHiddenText;

@end

@implementation CLTextMarker

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                         hiddenText:(NSString *)hiddenText {
    
    if (!(markerImage && hiddenText)) return nil;
    
    if ((self = [super initWithMarkerImage:markerImage])) {
        
        _keyOfHiddenText = [NSString randomAlphanumericStringWithLength:kLengthOfKey];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
        
        NSString *fileName = [[[hiddenText hashValue] stringByAppendingString:stringFromDate] stringByAppendingString:@".txt"];
        
        self.hiddenTextPath = [CLFileManager textFilePathWithFileName:fileName];
        
        [CLFileManager saveTextToDisk:hiddenText
                          withFileName:[fileName stringByAppendingString:@".camLocker"]
                   usingDataEncryption:YES
                               withKey:self.keyOfHiddenText];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_hiddenTextPath forKey:@"hiddenTextPath"];
    [encoder encodeObject:_keyOfHiddenText forKey:@"keyOfHiddenText"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _hiddenTextPath = [decoder decodeObjectForKey:@"hiddenTextPath"];
        _keyOfHiddenText = [decoder decodeObjectForKey:@"keyOfHiddenText"];
    }
    return self;
}

- (void)decryptHiddenTextWithCompletionBlock:(void (^)(NSString *hiddenText))completion
{
    NSData *hiddenTextData = [NSData dataWithContentsOfFile:[self.hiddenTextPath stringByAppendingString:@".camLocker"]];
    hiddenTextData = [hiddenTextData AES256DecryptWithKey:[CLKeyGenerator hiddenKeyForKey:self.keyOfHiddenText]];
    NSString *hiddenText = [[NSString alloc] initWithData:hiddenTextData encoding:NSUTF8StringEncoding];
    completion(hiddenText);
}

- (void)deleteContent
{
    [[NSFileManager defaultManager] removeItemAtPath:[self.hiddenTextPath stringByAppendingString:@".camLocker"] error:nil];
    [super deleteContent];
}

@end
