//
//  MerchantViewController.m
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 09/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import "MerchantViewController.h"
#import <MONActivityIndicatorView.h>
#import <Stripe.h>
#import "APIClient.h"
#import "UIView+Shake.h"

@interface MerchantViewController ()

@property (nonatomic, strong) MONActivityIndicatorView *activityIndicator;

@end

@implementation MerchantViewController
{
    UIEdgeInsets _insetsWithoutKeyboard;
    BOOL _paymentsIsActive;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupPageWidthForScrollView:self.identificationScrollView];
    [self setupPageWidthForScrollView:self.paymentScrollView];
    
    // we need these two controls to be invisible when individual is selected but in UI builder it's more convenient to use hidden than alpha 0
    // because in this case alpha 0 will make the controls completely invisible in the UI builder
    // we need to use alpha though, because that's what we'll animate
    self.cardHolderNameField.alpha = 0;
    self.cardHolderNameLabel.alpha = 0;
    self.cardHolderNameField.hidden = NO;
    self.cardHolderNameLabel.hidden = NO;
    
    
    // configure activity view
    self.activityIndicator = [[MONActivityIndicatorView alloc] init];
    self.activityIndicator.numberOfCircles = 3;
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)setupPageWidthForScrollView:(UIScrollView *)scrollView
{
    for (UIView *scrollPage in scrollView.subviews) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:scrollPage
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1
                                                               constant:1]];
    }
    
}

- (IBAction)selectPersonType:(id)sender
{
    [self showIdentification];

    CGFloat width = self.identificationScrollView.frame.size.width;
    CGFloat height = self.identificationScrollView.frame.size.height;
    if (self.personTypeSegmentedControl.selectedSegmentIndex == 0) {
        [self.identificationScrollView scrollRectToVisible:CGRectMake(0, 0, width, height) animated:YES];
        self.corporationNameField.text = nil;
        self.corporationTaxIdField.text = nil;
        [self.individualNameField becomeFirstResponder];
        // no need for cardholder name if merchant is individual
        [UIView animateWithDuration:0.3 animations:^{
            self.cardHolderNameField.alpha = 0;
            self.cardHolderNameLabel.alpha = 0;
        }];
    } else {
        [self.identificationScrollView scrollRectToVisible:CGRectMake(width, 0, width, height) animated:YES];
        self.individualNameField.text = nil;
        self.individualTaxIdField.text = nil;
        [self.corporationNameField becomeFirstResponder];
        // gotta know the cardholder name if merchant is corporation
        [UIView animateWithDuration:0.3 animations:^{
            self.cardHolderNameField.alpha = 1;
            self.cardHolderNameLabel.alpha = 1;
        }];
    }
}

- (IBAction)selectPaymentType:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.paymentScrollView.alpha = 1;
    }];

    [self showPayments];
    
    CGFloat width = self.identificationScrollView.frame.size.width;
    CGFloat height = self.identificationScrollView.frame.size.height;
    if (self.paymentTypeSegmentedControl.selectedSegmentIndex == 0) {
        [self.paymentScrollView scrollRectToVisible:CGRectMake(0, 0, width, height) animated:YES];
        //[self.debitCardView clear];
        self.cardHolderNameField.text = nil;
        [self.routingNoField becomeFirstResponder];
    } else {
        [self.paymentScrollView scrollRectToVisible:CGRectMake(width, 0, width, height) animated:YES];
        self.routingNoField.text = nil;
        self.accountNoField.text = nil;
        [self.debitCardView becomeFirstResponder];
    }
}

- (void)showPayments
{
    [self.verticalScrollView scrollRectToVisible:self.paymentScrollView.frame animated:YES];
    _paymentsIsActive = YES;
}

- (void)showIdentification
{
    [self.verticalScrollView scrollRectToVisible:self.topScrollHandle.frame animated:YES];
    _paymentsIsActive = NO;
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isDescendantOfView:self.paymentScrollView]) {
        [self showPayments];
    } else {
        [self showIdentification];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.individualNameField) {
        [self.individualTaxIdField becomeFirstResponder];
    } else if (textField == self.individualTaxIdField) {
        [self hideKeyboard];
    } else if (textField == self.corporationNameField) {
        [self.corporationTaxIdField becomeFirstResponder];
    } else if (textField == self.corporationTaxIdField) {
        [self hideKeyboard];
    } else if (textField == self.routingNoField) {
        [self.accountNoField becomeFirstResponder];
    } else if (textField == self.accountNoField) {
        [self hideKeyboard];
    } else if (textField == self.cardHolderNameField) {
        [self hideKeyboard];
    }
    return NO;
}

#pragma mark - Keyboard

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

/**
 When keyboard shows adjust the scrollview insets so that text fields would be accessible
 */
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    
    // getting the keyboard height that's right for the orientation is quite complex...
    CGRect screenKBRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect windowKBRect = [self.view.window convertRect:screenKBRect fromWindow:nil];
    CGRect viewKBRect = [self.view convertRect:windowKBRect fromView:nil];
    float keyboardHeightConstant = viewKBRect.size.height;
    
    _insetsWithoutKeyboard = self.verticalScrollView.contentInset;
    
    UIEdgeInsets insets = _insetsWithoutKeyboard;
    insets.bottom = keyboardHeightConstant;
    self.verticalScrollView.contentInset = insets;
    
    // might be that we activated payments while the keyboard was not on screen,
    // so we need to apply scrolling if payments are active
    if (_paymentsIsActive) {
        [self showPayments];
    }
}

/**
 When keyboard is hidden, remove the bottom inset for the scrollview
 */
- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    self.verticalScrollView.contentInset = _insetsWithoutKeyboard;
}

#pragma mark - API Calls

- (void)ifEmptyAddTextField:(UITextField *)textField toArray:(NSMutableArray *)array
{
    if ([textField.text length] == 0) {
        [array addObject:textField];
    }
}

- (BOOL)validateData
{
    NSMutableArray *emptyViews = [NSMutableArray array];
    
    if (self.personTypeSegmentedControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        [emptyViews addObject:self.personTypeSegmentedControl];
    } else if (self.personTypeSegmentedControl.selectedSegmentIndex == 0) {
        [self ifEmptyAddTextField:self.individualNameField toArray:emptyViews];
        [self ifEmptyAddTextField:self.individualTaxIdField toArray:emptyViews];
    } else {
        [self ifEmptyAddTextField:self.corporationNameField toArray:emptyViews];
        [self ifEmptyAddTextField:self.corporationTaxIdField toArray:emptyViews];
    }
    
    if (self.paymentTypeSegmentedControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        [emptyViews addObject:self.paymentTypeSegmentedControl];
    } else if (self.paymentTypeSegmentedControl.selectedSegmentIndex == 0) {
        [self ifEmptyAddTextField:self.routingNoField toArray:emptyViews];
        [self ifEmptyAddTextField:self.accountNoField toArray:emptyViews];
    } else {
        if (! [self.debitCardView isValid]) {
            [emptyViews addObject:self.debitCardView];
        }
        if (self.personTypeSegmentedControl.selectedSegmentIndex == 1) {
            [self ifEmptyAddTextField:self.cardHolderNameField toArray:emptyViews];
        }
    }
    
    if ([emptyViews count] > 0) {
        [emptyViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            [view shake];
        }];
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)registerMerchant:(id)sender
{
    if (! [self validateData]) {
        return;
    }

    [self hideKeyboard];
    [self.activityIndicator startAnimating];
    
    
    if (self.paymentTypeSegmentedControl.selectedSegmentIndex == 0) {
        
        STPBankAccount *bankAccount = [[STPBankAccount alloc] init];
        bankAccount.routingNumber = self.routingNoField.text;
        bankAccount.accountNumber = self.accountNoField.text;
        bankAccount.country = @"US";
        
        [[STPAPIClient sharedClient] createTokenWithBankAccount:bankAccount
                                                     completion:^(STPToken *token, NSError *error) {
            if (error) {
                [self.activityIndicator stopAnimating];
                NSLog(@"error : %@", error);
                [self showShortError:error.description];
            } else {
                NSLog(@"account token : %@", token);
                [self postMerchantToServerWithBankAccountToken:token.tokenId debitCardToken:nil];
            }
        }];
    } else {
        STPCard *debitCard = [[STPCard alloc] init];
        debitCard.number = self.debitCardView.card.number;
        debitCard.expMonth = self.debitCardView.card.expMonth;
        debitCard.expYear = self.debitCardView.card.expYear;
        debitCard.cvc = self.debitCardView.card.cvc;
        [[STPAPIClient sharedClient] createTokenWithCard:debitCard
                                              completion:^(STPToken *token, NSError *error) {
                                                  if (error) {
                                                      [self.activityIndicator stopAnimating];
                                                      NSLog(@"error : %@", error);
                                                      [self showShortError:error.description];
                                                  } else {
                                                      NSLog(@"token : %@", token);
                                                      [self postMerchantToServerWithBankAccountToken:nil debitCardToken:token.tokenId];
                                                  }
                                              }];

    }
}

- (void)postMerchantToServerWithBankAccountToken:(NSString *)bankAccountToken debitCardToken:(NSString *)debitCardToken
{
    BOOL isIndividual = self.personTypeSegmentedControl.selectedSegmentIndex == 0;
    [[APIClient sharedInstance] saveMerchantWithName:isIndividual ? self.individualNameField.text : self.corporationNameField.text
                                               taxId:isIndividual ? self.individualTaxIdField.text : self.corporationNameField.text
                                        isIndividual:isIndividual
                                    bankAccountToken:bankAccountToken
                                      debitCardToken:debitCardToken
                                      cardHolderName:isIndividual ? nil : self.cardHolderNameField.text
                                         withSuccess:^{
                                             [self.activityIndicator stopAnimating];
                                             CLS_LOG(@"Saved");
                                             [self showToast:@"Saved on Server!" onView:self.view];
                                         }
                                             failure:^(NSString *error) {
                                                 [self.activityIndicator stopAnimating];
                                                 [self showShortError:error];
                                             }];
    
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
