//
//  CLAudioMarker.m
//  CamLocker
//
//  Created by FlyinGeek on 3/31/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "NSString+Random.h"
#import "CLFileManager.h"
#import "CLAudioMarker.h"
#import "CLKeyGenerator.h"
#import "NSData+CLEncryption.h"

@interface CLAudioMarker ()

@property (nonatomic, copy) NSString *hiddenAudioPath;
@property (nonatomic, copy) NSString *keyOfHiddenAudio;

@end

@implementation CLAudioMarker

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                        hiddenAudio:(NSData *)hiddenAudioData
{
    if (!(markerImage && hiddenAudioData)) return nil;
    
    if ((self = [super initWithMarkerImage:markerImage])) {
        
        _keyOfHiddenAudio = [NSString randomAlphanumericStringWithLength:kLengthOfKey];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
        
        NSString *fileName = [[[hiddenAudioData hashValue] stringByAppendingString:stringFromDate] stringByAppendingString:@".aac"];
        
        self.hiddenAudioPath = [CLFileManager textFilePathWithFileName:fileName];
        
        [CLFileManager saveAudioToDisk:hiddenAudioData
                          withFileName:[fileName stringByAppendingString:@".camLocker"]
                   usingDataEncryption:YES
                               withKey:self.keyOfHiddenAudio];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_hiddenAudioPath forKey:@"hiddenAudioPath"];
    [encoder encodeObject:_keyOfHiddenAudio forKey:@"keyOfHiddenAudio"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _hiddenAudioPath = [decoder decodeObjectForKey:@"hiddenAudioPath"];
        _keyOfHiddenAudio = [decoder decodeObjectForKey:@"keyOfHiddenAudio"];
    }
    return self;
}

- (void)decryptHiddenAudioWithCompletionBlock:(void (^)(NSData *hiddenAudioData))completion
{
    NSData *hiddenAudioData = [NSData dataWithContentsOfFile:[self.hiddenAudioPath stringByAppendingString:@".camLocker"]];
    hiddenAudioData = [hiddenAudioData AES256DecryptWithKey:[CLKeyGenerator hiddenKeyForKey:self.keyOfHiddenAudio]];
    completion(hiddenAudioData);
}

- (void)deleteContent
{
    [[NSFileManager defaultManager] removeItemAtPath:[self.hiddenAudioPath stringByAppendingString:@".camLocker"] error:nil];
    [super deleteContent];
}

@end