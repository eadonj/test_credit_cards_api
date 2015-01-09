//
//  UIViewController+Dialogs.h
//  plannit_ios
//
//  Created by Andris Zalitis on 7/29/14.
//  Copyright (c) 2014 Plannit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Dialogs)

- (void)showShortError:(NSString *)error;
- (void)showError:(NSString *)error withTitle:(NSString *)title;
- (void)showToast:(NSString *)string onView:(UIView *)view;

@end
