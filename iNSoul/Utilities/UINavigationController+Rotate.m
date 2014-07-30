//
//  UINavigationController+Rotate.m
//  iNSoul
//
//  Created by Allan Barbato on 10/04/14.
//  Copyright (c) 2014 Allan Barbato. All rights reserved.
//

#import "UINavigationController+Rotate.h"

@implementation UINavigationController (Rotate)

- (BOOL) shouldAutorotate
{
    return [[self topViewController] shouldAutorotate];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return [[self topViewController] supportedInterfaceOrientations];
}

@end
