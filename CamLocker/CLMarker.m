//
//  CLMarker.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "UIImage+CLEncryption.h"
#import "NSData+CLEncryption.h"
#import "NSString+Random.h"
#import "CLFileManager.h"
#import "CLMarker.h"

@interface CLMarker ()

@property (nonatomic, copy) NSString *key;

@end

@implementation CLMarker

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
{
    if (!markerImage) return nil;
    
    if ((self = [super init])) {
        
        _key = [NSString randomAlphanumericStringWithLength:kLengthOfKey];
        _cosName = [markerImage hashValue];
        _markerImageFileName = [self.cosName stringByAppendingString:@".png"];
        _markerImagePath = [CLFileManager imageFilePathWithFileName:self.markerImageFileName];
        
        [CLFileManager saveImageToDisk:markerImage
                          withFileName:[self.markerImageFileName stringByAppendingString:@".cl"]
                   usingDataEncryption:YES
                               withKey:self.key];
        NSLog(@"%@", self.markerImagePath);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_markerImageFileName forKey:@"markerImageFileName"];
    [encoder encodeObject:_markerImagePath forKey:@"markerImagePath"];
    [encoder encodeObject:_cosName forKey:@"cosName"];
    [encoder encodeObject:_key forKey:@"key"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _markerImageFileName = [decoder decodeObjectForKey:@"markerImageFileName"];
        _markerImagePath = [decoder decodeObjectForKey:@"markerImagePath"];
        _cosName = [decoder decodeObjectForKey:@"cosName"];
        _key = [decoder decodeObjectForKey:@"key"];
    }
    return self;
}

- (void)activate
{
    NSData *markerImageData = [NSData dataWithContentsOfFile:[self.markerImagePath stringByAppendingString:@".cl"]];
    markerImageData = [markerImageData AES256DecryptWithKey:self.key];
    UIImage *markerImage = [UIImage imageWithData:markerImageData];
    [CLFileManager saveImageToDisk:markerImage
                      withFileName:self.markerImageFileName
               usingDataEncryption:NO
                           withKey:nil];
    
}

- (void)deactivate
{
    [[NSFileManager defaultManager] removeItemAtPath:self.markerImagePath error:nil];
}

-(void)deleteContent
{
    // delete encrypted marker image
    [[NSFileManager defaultManager] removeItemAtPath:[self.markerImagePath stringByAppendingString:@".cl"] error:nil];
}

@end
