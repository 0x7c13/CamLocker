//
//  CLMarker.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//


#import "UIImage+CLEncryption.h"
#import "NSData+CLEncryption.h"
#import "NSString+CLEncryption.h"
#import "CLKeyGenerator.h"
#import "CLFileManager.h"
#import "CLUtilities.h"
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
        _imageFileName = [self.cosName stringByAppendingString:@".jpg"];
        _imagePath = [CLFileManager imageFilePathWithFileName:self.imageFileName];
        
        // scale down the image for better performance
        markerImage = [CLUtilities imageWithImage:markerImage scaledToWidth:kMarkerDefaultWidth];
        [CLFileManager saveImageToDisk:markerImage
                          withFileName:[self.imageFileName stringByAppendingString:@".camLocker"]
                   usingDataEncryption:YES
                               withKey:self.key];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_imageFileName forKey:@"markerImageFileName"];
    [encoder encodeObject:_imagePath forKey:@"markerImagePath"];
    [encoder encodeObject:_cosName forKey:@"markerCosName"];
    [encoder encodeObject:_key forKey:@"markerkey"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _imageFileName = [decoder decodeObjectForKey:@"markerImageFileName"];
        _imagePath = [decoder decodeObjectForKey:@"markerImagePath"];
        _cosName = [decoder decodeObjectForKey:@"markerCosName"];
        _key = [decoder decodeObjectForKey:@"markerkey"];
    }
    return self;
}

- (void)activate
{
    NSData *markerImageData = [NSData dataWithContentsOfFile:[self.imagePath stringByAppendingString:@".camLocker"]];
    markerImageData = [markerImageData AES256DecryptWithKey:[CLKeyGenerator hiddenKeyForKey:self.key]];
    UIImage *markerImage = [UIImage imageWithData:markerImageData];
    [CLFileManager saveImageToDisk:markerImage
                      withFileName:self.imageFileName
               usingDataEncryption:NO
                           withKey:nil];
}

- (void)deactivate
{
    [[NSFileManager defaultManager] removeItemAtPath:self.imagePath error:nil];
}

-(void)deleteContent
{
    // delete encrypted marker image
    [[NSFileManager defaultManager] removeItemAtPath:[self.imagePath stringByAppendingString:@".camLocker"] error:nil];
}

@end
