//
//  CLMarker.m
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "CLDataHandler.h"
#import "CLMarker.h"

@implementation CLMarker

- (instancetype)initWithMarkerImage:(UIImage *)markerImage
{
    if (!markerImage) return nil;
    
    if ((self = [super init])) {
        _cosName = [CLDataHandler hashValueOfUIImage:markerImage];
        _markerImageFileName = [self.cosName stringByAppendingString:@".png"];
        _markerImagePath = [CLDataHandler saveImageToDisk:markerImage
                                            withFileName:self.markerImageFileName
                                     usingRepresentation:ImageFormatOptionPNG];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_markerImageFileName forKey:@"markerImageFileName"];
    [encoder encodeObject:_markerImagePath forKey:@"markerImagePath"];
    [encoder encodeObject:_cosName forKey:@"cosName"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _markerImageFileName = [decoder decodeObjectForKey:@"markerImageFileName"];
        _markerImagePath = [decoder decodeObjectForKey:@"markerImagePath"];
        _cosName = [decoder decodeObjectForKey:@"cosName"];
    }
    return self;
}

-(void)deleteMarkerImage
{
    [[NSFileManager defaultManager] removeItemAtPath:self.markerImagePath error:nil];
}

@end
