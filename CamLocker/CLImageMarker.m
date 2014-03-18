//
//  CLImageMarker.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLDataHandler.h"
#import "CLImageMarker.h"

@implementation CLImageMarker

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
                       hiddenImages:(NSArray *)hiddenImages {

    if (!(markerImage && hiddenImages)) return nil;

    if (self = [super initWithMarkerImage:markerImage]) {
        
        _hiddenImagePaths = [[NSMutableArray alloc] initWithCapacity:hiddenImages.count];
        for (UIImage *image in hiddenImages) {
            NSString *fileName = [[CLDataHandler hashValueOfUIImage:image] stringByAppendingString:@".png"];
            [self.hiddenImagePaths addObject:[CLDataHandler saveImageToDisk:image withFileName:fileName usingRepresentation:ImageFormatOptionPNG]];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_hiddenImagePaths forKey:@"hiddenImagePaths"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _hiddenImagePaths = [decoder decodeObjectForKey:@"hiddenImagePaths"];
    }
    return self;
}

- (void)deleteHiddenImages
{
    for (NSString *imagePath in self.hiddenImagePaths) {
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
}
@end
