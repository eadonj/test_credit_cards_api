//
//  MerchantViewController.h
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 09/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PTKView.h>

@interface MerchantViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *verticalScrollView;

@property (nonatomic, weak) IBOutlet UIView *topScrollHandle;
@property (nonatomic, weak) IBOutlet UISegmentedControl *personTypeSegmentedControl;

@property (nonatomic, weak) IBOutlet UIScrollView *identificationScrollView;

@property (nonatomic, weak) IBOutlet UILabel *individualNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *individualNameField;
@property (nonatomic, weak) IBOutlet UILabel *corporationNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *corporationNameField;

@property (nonatomic, weak) IBOutlet UILabel *individualTaxIdLabel;
@property (nonatomic, weak) IBOutlet UITextField *individualTaxIdField;
@property (nonatomic, weak) IBOutlet UILabel *corporationTaxIdLabel;
@property (nonatomic, weak) IBOutlet UITextField *corporationTaxIdField;


@property (nonatomic, weak) IBOutlet UISegmentedControl *paymentTypeSegmentedControl;

@property (nonatomic, weak) IBOutlet UIScrollView *paymentScrollView;

@property (nonatomic, weak) IBOutlet UILabel *routingNoLabel;
@property (nonatomic, weak) IBOutlet UITextField *routingNoField;
@property (nonatomic, weak) IBOutlet UILabel *accountNoLabel;
@property (nonatomic, weak) IBOutlet UITextField *accountNoField;

@property (nonatomic, weak) IBOutlet PTKView *debitCardView;
@property (nonatomic, weak) IBOutlet UILabel *cardHolderNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *cardHolderNameField;

@end
