//
//  Tokenizer.h
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 13/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ApiIndexBalanced,
    ApiIndexStripe,
    ApiIndexBraintree,
} APIIndexes;


@interface Tokenizer : NSObject

+ (instancetype)sharedInstance;

- (NSString *)apiTitleForIndex:(NSInteger)apiIndex;
- (NSInteger)selectedApiIndex;
- (NSString *)selectedApiLowercaseTitle;
- (void)setSelectedApiIndex:(NSInteger)index;

- (void)tokenizeCreditCardWithNumber:(NSString *)ccNumber
                     expirationMonth:(NSUInteger)expMonth
                      expirationYear:(NSUInteger)expYear
                                 cvc:(NSString *)cvc
                                name:(NSString *)nameOnCard
                         countryCode:(NSString *)countryCode
                          postalCode:(NSString *)postalCode
                             success:(void (^)(NSString *token))successBlock
                               error:(void (^)(NSError *error))errorBlock;

- (void)tokenizeBankAcccountWithNumber:(NSString *)accountNumber
                         routingNumber:(NSString *)routingNumber
                                  name:(NSString *)holdersName
                           countryCode:(NSString *)countryCode
                            postalCode:(NSString *)postalCode
                               success:(void (^)(NSString *token))successBlock
                                 error:(void (^)(NSError *error))errorBlock;

@end
