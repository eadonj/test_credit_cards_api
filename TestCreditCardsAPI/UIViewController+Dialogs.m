//
//  UIViewController+Dialogs.m
//  plannit_ios
//
//  Created by Andris Zalitis on 7/29/14.
//  Copyright (c) 2014 Plannit. All rights reserved.
//

#import "UIViewController+Dialogs.h"
#import <Toast/UIView+Toast.h>

@implementation UIViewController (Dialogs)


- (void)showShortError:(NSString *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    
    [alert show];
}


- (void)showError:(NSString *)error withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    
    [alert show];
}

- (void)showToast:(NSString *)string onView:(UIView *)view
{
    CGPoint toastPosition = view.center;
    toastPosition.y = view.frame.size.height - 100;
    [view makeToast:string duration:2 position:[NSValue valueWithCGPoint:toastPosition]];
}

@end
