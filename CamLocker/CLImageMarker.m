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
#import "CLKeyGenerator.h"

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
            
            NSString *fileName = [[image hashValue] stringByAppendingString:@".jpg"];
            [self.hiddenImagePaths addObject:[CLFileManager imageFilePathWithFileName:fileName]];
             
            [CLFileManager saveImageToDisk:image
                              withFileName:[fileName stringByAppendingString:@".camLocker"]
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

- (void)decryptHiddenImagesWithCompletionBlock:(void (^)(NSArray *images))block
{
    NSMutableArray *hiddenImages = [[NSMutableArray alloc] initWithCapacity:self.hiddenImagePaths.count];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSString *imagePath in self.hiddenImagePaths) {
            
            NSData *hiddenImageData = [NSData dataWithContentsOfFile:[imagePath stringByAppendingString:@".camLocker"]];
            hiddenImageData = [hiddenImageData AES256DecryptWithKey:[CLKeyGenerator hiddenKeyForKey:self.keyOfHiddenImages]];
            [hiddenImages addObject:[UIImage imageWithData:hiddenImageData]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            block(hiddenImages);
        });
    });
}

- (void)deleteContent
{
    for (NSString *imagePath in self.hiddenImagePaths) {
        [[NSFileManager defaultManager] removeItemAtPath:[imagePath stringByAppendingString:@".camLocker"] error:nil];
    }
    [super deleteContent];
}

@end
