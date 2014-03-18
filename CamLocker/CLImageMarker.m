//
//  CLImageMarker.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "NSString+Random.h"
#import "NSData+CLEncryption.h"
#import "UIImage+CLEncryption.h"
#import "CLFileManager.h"
#import "CLImageMarker.h"

#define kLengthOfKey 20

@interface CLImageMarker ()

@property (nonatomic, copy) NSMutableArray *hiddenImagePaths;
@property (nonatomic, copy) NSString *keyOfHiddenImages;

@end

@implementation CLImageMarker

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                       hiddenImages:(NSArray *)hiddenImages {

    if (!(markerImage && hiddenImages)) return nil;

    if (self = [super initWithMarkerImage:markerImage]) {
        
        _keyOfHiddenImages = [NSString randomAlphanumericStringWithLength:kLengthOfKey];
        _hiddenImagePaths = [[NSMutableArray alloc] initWithCapacity:hiddenImages.count];
        
        for (UIImage *image in hiddenImages) {
            
            NSString *fileName = [[image hashValue] stringByAppendingString:@".png"];
            [self.hiddenImagePaths addObject:[CLFileManager imageFilePathWithFileName:fileName]];
             
            [CLFileManager saveImageToDisk:image
                              withFileName:[fileName stringByAppendingString:@".cl"]
                       usingDataEncryption:YES
                                   withKey:self.keyOfHiddenImages];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_hiddenImagePaths forKey:@"hiddenImagePaths"];
    [encoder encodeObject:_keyOfHiddenImages forKey:@"keyOfHiddenImages"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _hiddenImagePaths = [decoder decodeObjectForKey:@"hiddenImagePaths"];
        _keyOfHiddenImages = [decoder decodeObjectForKey:@"keyOfHiddenImages"];
    }
    return self;
}

- (NSArray *)hiddenImages
{
    NSMutableArray *hiddenImages = [[NSMutableArray alloc] initWithCapacity:self.hiddenImagePaths.count];
    for (NSString *imagePath in self.hiddenImagePaths) {
        NSData *hiddenImageData = [NSData dataWithContentsOfFile:[imagePath stringByAppendingString:@".cl"]];
        hiddenImageData = [hiddenImageData AES256DecryptWithKey:self.keyOfHiddenImages];
        [hiddenImages addObject:[UIImage imageWithData:hiddenImageData]];
    }
    return hiddenImages;
}

- (void)deleteContent
{
    for (NSString *imagePath in self.hiddenImagePaths) {
        [[NSFileManager defaultManager] removeItemAtPath:[imagePath stringByAppendingString:@".cl"] error:nil];
    }
    [super deleteContent];
}
@end
