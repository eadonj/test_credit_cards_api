//
//  UIView+Shake.m
//  Photogram
//
//  Created by Andris on 3/6/14.
//  Copyright (c) 2014 POLLEO. All rights reserved.
//

#import "UIView+Shake.h"

@implementation UIView (Shake)

- (void)shake
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
    anim.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-10.0f, 0.0f, 0.0f)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(10.0f, 0.0f, 0.0f)]];
    anim.autoreverses = YES;
    anim.repeatCount = 2.0f;
    anim.duration = 0.07f;
    
    [self.layer addAnimation:anim forKey:nil];
}


@end
