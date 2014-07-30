//
//  UINavigationBar+Utils.m
//  IGS Portal
//
//  Created by Allan Barbato on 8/13/12.
//  Copyright (c) 2012 BSOM. All rights reserved.
//

#import "UINavigationBar+Utils.h"

#define BACKGROUND_IMAGEVIEW_TAG 151

@implementation UINavigationBar (Utils)

- (void) setBackgroundImage:(UIImage*)image
{
    if (image == NULL) return;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.bounds;
    imageView.tag = BACKGROUND_IMAGEVIEW_TAG;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self insertSubview:imageView atIndex:1];
    [imageView release];
}

- (void) clearBackgroundImage
{
    NSArray *subviews = [self subviews];
    
    for (UIView* subview in subviews)
    {
        if (subview.tag == BACKGROUND_IMAGEVIEW_TAG && [subview isMemberOfClass:[UIImageView class]])
            [subview removeFromSuperview];
    }
}

@end
