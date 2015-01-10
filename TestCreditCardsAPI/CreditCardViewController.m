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
    if (![Stripe defaultPublishableKey]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Publishable Key"
                                                          message:@"Please specify a Stripe Publishable Key in Constants.m"
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    
    [self.activityIndicator startAnimating];
    
    // hide keyboard
    [self.view endEditing:YES];
    
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  [self.activityIndicator stopAnimating];
                                                  NSLog(@"error : %@", error);
                                                  [self showShortError:error.description];
//                                                  [self hasError:error];
                                              } else {
//                                                  [self hasToken:token];
                                                  NSLog(@"token : %@", token);
                                                  [[APIClient sharedInstance] saveCardToken:token.tokenId withSuccess:^{
                                                      [self.activityIndicator stopAnimating];
                                                      CLS_LOG(@"Saved");
                                                      [self showToast:@"Saved on Server!" onView:self.view];
                                                  } failure:^(NSString *error) {
                                                      [self.activityIndicator stopAnimating];
                                                      [self showShortError:error];
                                                  }];
                                              }
                                          }];
}
@end
