//
//  PaymentViewController.m
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 14/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import "PaymentViewController.h"
#import "UIView+Shake.h"
#import <MONActivityIndicatorView.h>
#import "APIClient.h"

@interface PaymentViewController ()

@property (nonatomic, strong) MONActivityIndicatorView *activityIndicator;

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // configure activity view
    self.activityIndicator = [[MONActivityIndicatorView alloc] init];
    self.activityIndicator.numberOfCircles = 3;
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self payApiCall:nil];
    return NO;
}

- (IBAction)payApiCall:(id)sender
{
    float amount =  [self.amountField.text floatValue];
    if (amount <= 0 || amount == HUGE_VAL) {
        [self.amountField shake];
        return;
    }
    
    [self.activityIndicator startAnimating];
    
    // hide keyboard
    [self dismissKeyboard:nil];
    
    [[APIClient sharedInstance] customerPaysAmount:amount success:^{
        [self.activityIndicator stopAnimating];
        CLS_LOG(@"Paid");
        [self showToast:@"Payment sent to the server!" onView:self.view];
    } failure:^(NSString *error) {
        [self.activityIndicator stopAnimating];
        [self showShortError:error];
    }];

}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
