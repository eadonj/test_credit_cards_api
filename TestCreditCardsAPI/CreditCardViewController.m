//
//  ViewController.m
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 08/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import "CreditCardViewController.h"
#import <Stripe.h>
#import <MONActivityIndicatorView.h>
#import "APIClient.h"
#import "Tokenizer.h"

@interface CreditCardViewController ()

@property (nonatomic, strong) MONActivityIndicatorView *activityIndicator;

@end

@implementation CreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // can't set it in UI builder
    self.paymentView.delegate = self;
    
    // configure activity view
    self.activityIndicator = [[MONActivityIndicatorView alloc] init];
    self.activityIndicator.numberOfCircles = 3;
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];

}

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"card %@ is valid %d", card, valid);
    self.registerButton.enabled = valid;
}

- (IBAction)registerCC:(id)sender {
    if (![self.paymentView isValid]) {
        return;
    }
    
    [self.activityIndicator startAnimating];
    
    // hide keyboard
    [self.view endEditing:YES];

    [[Tokenizer sharedInstance] tokenizeCreditCardWithNumber:self.paymentView.card.number
                                             expirationMonth:self.paymentView.card.expMonth
                                              expirationYear:self.paymentView.card.expYear
                                                         cvc:self.paymentView.card.cvc
                                                        name:nil
                                                 countryCode:nil
                                                  postalCode:nil
                                                     success:^(NSString *token) {
                                                         NSLog(@"token : %@", token);
                                                         [[APIClient sharedInstance] saveCardToken:token withSuccess:^{
                                                             [self.activityIndicator stopAnimating];
                                                             CLS_LOG(@"Saved");
                                                             [self showToast:@"Saved on Server!" onView:self.view];
                                                         } failure:^(NSString *error) {
                                                             [self.activityIndicator stopAnimating];
                                                             [self showShortError:error];
                                                         }];
                                                     } error:^(NSError *error) {
                                                         [self.activityIndicator stopAnimating];
                                                         NSLog(@"error : %@", error);
                                                         [self showShortError:error.description];
                                                     }];
    
//    if (![Stripe defaultPublishableKey]) {
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Publishable Key"
//                                                          message:@"Please specify a Stripe Publishable Key in Constants.m"
//                                                         delegate:nil
//                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
//                                                otherButtonTitles:nil];
//        [message show];
//        return;
//    }
    
}


- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}
@end
