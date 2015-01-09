//
//  ViewController.h
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 08/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTKView.h"

@interface ViewController : UIViewController<PTKViewDelegate>

@property (nonatomic, weak) IBOutlet PTKView *paymentView;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;

@end

