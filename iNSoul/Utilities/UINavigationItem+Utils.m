//
//  UINavigationItem+Utils.m
//  IGS Portal
//
//  Created by Allan Barbato on 8/13/12.
//  Copyright (c) 2012 BSOM. All rights reserved.
//

#import "UINavigationItem+Utils.h"

@implementation UINavigationItem (Utils)

- (void)setBackBarButtonWithTitle:(NSString*)title image:(UIImage*)image target:(id)target selector:(SEL)selector
{
    UIButton*   backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIFont*     font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    
    image = [image stretchableImageWithLeftCapWidth:14.0f topCapHeight:0.0f];
    
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton setTitle:[@" " stringByAppendingString:title] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:font];
    
    
    [backButton setFrame:CGRectMake(0, 0, (55 * [[@" " stringByAppendingString:title] sizeWithFont:font].width / [@" Back" sizeWithFont:font].width), 30)];
    [backButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem*    item = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.leftBarButtonItem = item;
}

@end
