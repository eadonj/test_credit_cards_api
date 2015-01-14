//
//  SettingsViewController.m
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 13/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import "SettingsViewController.h"
#import "Tokenizer.h"


@interface SettingsViewController ()

@end

@implementation SettingsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.pickerView selectRow:[[Tokenizer sharedInstance] selectedApiIndex] inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[Tokenizer sharedInstance] apiTitleForIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [[Tokenizer sharedInstance] setSelectedApiIndex:row];
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
