//
//  PaymentViewController.h
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 14/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *amountField;

@end
