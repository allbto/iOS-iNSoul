//
//  UINavigationItem+Utils.h
//  IGS Portal
//
//  Created by Allan Barbato on 8/13/12.
//  Copyright (c) 2012 BSOM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (Utils)

- (void)setBackBarButtonWithTitle:(NSString*)title image:(UIImage*)image target:(id)target selector:(SEL)selector;

@end
