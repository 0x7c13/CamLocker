//
//  CLUtilities.h
//  CamLocker
//
//  Created by FlyinGeek on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLUtilities : NSObject

+ (void)addShadowToUIView: (UIView *)view;
+ (void)addShadowToUIImageView: (UIImageView *)view;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToWidth:(float)i_width;

+ (UIFont *)textFieldFont;
+ (UIFont *)descriptionTextFont;
+ (UIFont *)titleFont;
+ (UIFont *)swipeToContinueFont;
+ (UIFont *)tosLabelFont;
+ (UIFont *)tosLabelSmallerFont;
+ (UIFont *)confirmationLabelFont;

@end
