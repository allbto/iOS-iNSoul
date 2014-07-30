//
//  UIImage+Utils.h
//  IGS Portal
//
//  Created by Allan Barbato on 8/10/12.
//  Copyright (c) 2012 BSOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+(void)imageWithURL:(NSURL*)URL receiveBlock:(void (^)(UIImage* image))receiveBlock errorBlock:(void (^)(void))errorBlock;

-(void)rotateImageTo:(UIImageOrientation)orientation;
-(void)resize;

- (UIImage *)applyEasyLightEffect;
- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
