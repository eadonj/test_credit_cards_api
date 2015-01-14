//
//  SettingsViewController.h
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 13/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@end
