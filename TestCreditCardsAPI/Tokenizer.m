//
//  Tokenizer.m
//  TestCreditCardsAPI
//
//  Created by Andris Zalitis on 13/01/15.
//  Copyright (c) 2015 Plannit. All rights reserved.
//

#import "Tokenizer.h"
#import <Stripe.h>
#import "Balanced.h"

@implementation Tokenizer
{
    NSArray *_apiTitles;
}

+ (instancetype)sharedInstance
{
    static Tokenizer *tokenizer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tokenizer = [[Tokenizer alloc] init];
    });
    return tokenizer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _apiTitles = @[@"Balanced", @"Stripe", @"Braintree"];
    }
    return self;
}


- (NSString *)apiTitleForIndex:(NSInteger)apiIndex
{
    return _apiTitles[apiIndex];
}

- (NSInteger)selectedApiIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:DefaultsKeyForAPIProvider];
}

- (NSString *)selectedApiLowercaseTitle
{
    NSString *title = [self apiTitleForIndex:[self selectedApiIndex]];
    return [title lowercaseString];
}

- (void)setSelectedApiIndex:(NSInteger)index
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:index forKey:DefaultsKeyForAPIProvider];
    [defaults synchronize];
}


#pragma mark - api calls

- (void)tokenizeCreditCardWithNumber:(NSString *)ccNumber
                     expirationMonth:(NSUInteger)expMonth
                      expirationYear:(NSUInteger)expYear
                                 cvc:(NSString *)cvc
                                name:(NSString *)nameOnCard
                         countryCode:(NSString *)countryCode
                          postalCode:(NSString *)postalCode
                             success:(void (^)(NSString *token))successBlock
                               error:(void (^)(NSError *error))errorBlock
{
    if ([self selectedApiIndex] == ApiIndexStripe) {
        [self stripeTokenizeCreditCardWithNumber:ccNumber
                                 expirationMonth:expMonth
                                  expirationYear:expYear
                                             cvc:cvc
                                            name:nameOnCard
                                     countryCode:countryCode
                                      postalCode:postalCode
                                         success:successBlock
                                           error:errorBlock];
    } else if ([self selectedApiIndex] == ApiIndexBalanced) {
        [self balancedTokenizeCreditCardWithNumber:ccNumber
                                   expirationMonth:expMonth
                                    expirationYear:expYear
                                               cvc:cvc
                                              name:nameOnCard
                                       countryCode:countryCode
                                        postalCode:postalCode
                                           success:successBlock
                                             error:errorBlock];
    }
}

- (void)stripeTokenizeCreditCardWithNumber:(NSString *)ccNumber
                           expirationMonth:(NSUInteger)expMonth
                            expirationYear:(NSUInteger)expYear
                                       cvc:(NSString *)cvc
                                      name:(NSString *)nameOnCard
                               countryCode:(NSString *)countryCode
                                postalCode:(NSString *)postalCode
                                   success:(void (^) (NSString *token))successBlock
                                     error:(void (^)(NSError *error))errorBlock
{
    STPCard *card = [[STPCard alloc] init];
    card.number = ccNumber;
    card.expMonth = expMonth;
    card.expYear = expYear;
    card.cvc = cvc;
    // optional
    card.name = nameOnCard;
    card.addressCountry = countryCode;
    card.addressZip = postalCode;
    
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  if (errorBlock) {
                                                      errorBlock(error);
                                                  }
                                              } else {
                                                  CLS_LOG(@"Success: %@", token);
                                                  if (successBlock) {
                                                      successBlock(token.tokenId);
                                                  }
                                              }
                                          }];
    
}


- (void)balancedTokenizeCreditCardWithNumber:(NSString *)ccNumber
                             expirationMonth:(NSUInteger)expMonth
                              expirationYear:(NSUInteger)expYear
                                         cvc:(NSString *)cvc
                                        name:(NSString *)nameOnCard
                                 countryCode:(NSString *)countryCode
                                  postalCode:(NSString *)postalCode
                                     success:(void (^) (NSString *token))successBlock
                                       error:(void (^)(NSError *error))errorBlock
{
    // Don't use API Keys defined by SDK because they are outdated (like BPCardOptionalParamSecurityCodeKey and Address related keys)
    NSMutableDictionary *optionalFields = [NSMutableDictionary dictionaryWithObject:cvc forKey:@"cvv"];
    if (nameOnCard) {
        [optionalFields setValue:nameOnCard forKey:@"name"];
    }
    if (countryCode) {
        NSMutableDictionary *address = [NSMutableDictionary dictionaryWithObject:countryCode forKey:@"country_code"];
        if (postalCode) {
            [address setValue:postalCode forKey:@"postal_code"];
        }
        [optionalFields setValue:address forKey:@"address"];
    }
    
    Balanced *balanced = [[Balanced alloc] init];
    [balanced createCardWithNumber:ccNumber
                   expirationMonth:expMonth
                    expirationYear:expYear
                         onSuccess:^(NSDictionary *response) {
                             CLS_LOG(@"Success: %@", response);
                             if (successBlock) {
                                 successBlock(response[@"cards"][0][@"id"]);
                             }
                         }
                           onError:errorBlock
                    optionalFields:optionalFields];
    
}



- (void)tokenizeBankAcccountWithNumber:(NSString *)accountNumber
                         routingNumber:(NSString *)routingNumber
                                  name:(NSString *)holdersName
                           countryCode:(NSString *)countryCode
                            postalCode:(NSString *)postalCode
                               success:(void (^)(NSString *token))successBlock
                                 error:(void (^)(NSError *error))errorBlock
{
    if ([self selectedApiIndex] == ApiIndexStripe) {
        [self stripeTokenizeBankAcccountWithNumber:accountNumber
                                     routingNumber:routingNumber
                                              name:(NSString *)holdersName
                                       countryCode:countryCode
                                        postalCode:postalCode
                                           success:successBlock
                                             error:errorBlock];
    } else if ([self selectedApiIndex] == ApiIndexBalanced) {
        [self balancedTokenizeBankAcccountWithNumber:accountNumber
                                       routingNumber:routingNumber
                                                name:(NSString *)holdersName
                                         countryCode:countryCode
                                          postalCode:postalCode
                                             success:successBlock
                                               error:errorBlock];
    }
}


- (void)stripeTokenizeBankAcccountWithNumber:(NSString *)accountNumber
                               routingNumber:(NSString *)routingNumber
                                        name:(NSString *)holdersName
                                 countryCode:(NSString *)countryCode
                                  postalCode:(NSString *)postalCode
                                     success:(void (^)(NSString *token))successBlock
                                       error:(void (^)(NSError *error))errorBlock
{
    STPBankAccount *bankAccount = [[STPBankAccount alloc] init];
    bankAccount.routingNumber = routingNumber;
    bankAccount.accountNumber = accountNumber;
    NSAssert(countryCode == nil || [countryCode isEqualToString:@"US"], @"Stripe supports only US country code");
    // Stripe supports only US country code
    bankAccount.country = @"US";
    
    // Stripe does not support postalCode
    // Stripe does not use bank account holder's name
    
    [[STPAPIClient sharedClient] createTokenWithBankAccount:bankAccount
                                                 completion:^(STPToken *token, NSError *error) {
                                                     if (error) {
                                                         if (errorBlock) {
                                                             errorBlock(error);
                                                         }
                                                     } else {
                                                         CLS_LOG(@"Success: %@", token);
                                                         if (successBlock) {
                                                             successBlock(token.tokenId);
                                                         }
                                                     }
                                                 }];
}


- (void)balancedTokenizeBankAcccountWithNumber:(NSString *)accountNumber
                                 routingNumber:(NSString *)routingNumber
                                          name:(NSString *)holdersName
                                   countryCode:(NSString *)countryCode
                                    postalCode:(NSString *)postalCode
                                       success:(void (^)(NSString *token))successBlock
                                         error:(void (^)(NSError *error))errorBlock
{
    NSMutableDictionary *optionalFields = [NSMutableDictionary dictionary];
    if (countryCode) {
        NSMutableDictionary *address = [NSMutableDictionary dictionaryWithObject:countryCode forKey:@"country_code"];
        if (postalCode) {
            [address setValue:postalCode forKey:@"postal_code"];
        }
        [optionalFields setValue:address forKey:@"address"];
    }
    
    Balanced *balanced = [[Balanced alloc] init];
    [balanced createBankAccountWithRoutingNumber:routingNumber
                                   accountNumber:accountNumber
                                     accountType:BPBankAccountTypeChecking
                                            name:holdersName
                                       onSuccess:^(NSDictionary *responseParams) {
                                            CLS_LOG(@"Success: %@", responseParams);
                                            if (successBlock) {
                                                successBlock(responseParams[@"bank_accounts"][0][@"id"]);
                                            }
                                        }
                                         onError:errorBlock
                                  optionalFields:optionalFields];
    
}

@end
