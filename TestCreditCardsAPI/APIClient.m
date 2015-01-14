//
//  APIClient.m
//  Webproof
//
//  Created by Andris Zalitis on 7/4/14.
//  Copyright (c) 2014 POLLEO. All rights reserved.
//

#import "APIClient.h"
#import <AFNetworking.h>
//#import "ResponseSerializer.h"
#import <MapKit/MapKit.h>
#import <Stripe.h>
#import "Tokenizer.h"

//#define P(params) [self authParamsWithParams:params]

//#ifndef DEBUG
//static NSString * const BaseAddress = @"https://plannit-backend.herokuapp.com/api/";
//#else
//static NSString * const BaseAddress = @"https://staging-plannit-backend.herokuapp.com/api/";
//#endif

static NSString * const BaseAddress = @"https://immense-badlands-7273.herokuapp.com/";

@interface APIClient ()

@property (nonatomic, readwrite, strong) NSString *accessToken;

@end

@implementation APIClient
{
    AFHTTPRequestOperationManager *_operationManager;
    NSInteger _temp;
}

+ (instancetype)sharedInstance
{
    static APIClient *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[APIClient alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BaseAddress]];
        // run operations in a new queue, callbacks will go in main queue by default
        _operationManager.operationQueue = [[NSOperationQueue alloc] init];
        // use our response serializer to get rid of null keys
//        _operationManager.responseSerializer = [[ResponseSerializer alloc] init];
        
//        _session = [APISession sharedInstance];
    }
    return self;
}

- (NSNumber *)currentTimeZone
{
    static NSTimeZone *zone;
    if (! zone) {
        // use localTimeZone so that even if we use setDefaultTimeZone someday in this app,
        // the zone variable will be up to date also after that call
        zone = [NSTimeZone localTimeZone];
    }
    
    return [NSNumber numberWithInteger:[zone secondsFromGMT]];
}



#pragma mark -

- (NSString *)errorTextForOperation:(AFHTTPRequestOperation *)operation
{
    // return localized error based on the status code
    
//    if (operation.response.statusCode == 403) {
//        int errorCode = [[operation.responseObject objectForKey:@"error_code"] intValue];
//        switch (errorCode) {
//            default:
//                return NSLocalizedString(@"The request couldn't be completed", nil);
//        }
//    } else if (operation.response.statusCode == 401) {
//        return NSLocalizedString(@"Your sign in credentials are not correct", nil);
//    } else {
//        return NSLocalizedString(@"The request couldn't be completed", nil);
//    }
    
    
    if (operation.responseObject[@"error_code"]) {
        NSInteger errorCode = [operation.responseObject[@"error_code"] integerValue];
        
        if (errorCode == 102) {
            return NSLocalizedString(@"Incorrect access token.", nil);
        } else if (errorCode == 105) {
            return NSLocalizedString(@"Wrong authentication code.", nil);
        } else if (errorCode == 106) {
            return NSLocalizedString(@"This authentication code has been expired, ask for a new one.", nil);
        }
    }
    
    // temporary solution
    if (operation.responseObject[@"message"]) {
        return operation.responseObject[@"message"];
    } else {
        return NSLocalizedString(@"The request couldn't be completed", nil);
    }
}


#pragma mark -

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^) (NSString *error))errorBlock
{
    return [self POST:URLString parameters:parameters success:success failure:errorBlock allowAuthFail:NO];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^) (NSString *error))errorBlock allowAuthFail:(BOOL)allowAuthFail
{
    AFHTTPRequestOperation *operation = [_operationManager POST:URLString parameters:parameters success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // we could check here if this was because of expired token, and then re-authenticate
        
        [self logRequest:operation.request error:error responseObject:operation.responseObject];

        // if the error happened because the operation got cancelled then it's actually not an error
        if (errorBlock && !operation.isCancelled) {
            errorBlock([self errorTextForOperation:operation]);
        }
        
        // if we are not logging in, then on authentication errors, log out of the app (close views)
        if (! allowAuthFail && operation.responseObject[@"error_code"]) {
            NSInteger errorCode = [operation.responseObject[@"error_code"] integerValue];
//            if (errorCode == 102) {
//                [self clearOnLogout];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NotifyLogOff object:self];
//            }
        }
    }];
    return operation;
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^) (NSString *error))errorBlock
{
    return [self DELETE:URLString parameters:parameters success:success failure:errorBlock allowAuthFail:NO];
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^) (NSString *error))errorBlock allowAuthFail:(BOOL)allowAuthFail
{
    AFHTTPRequestOperation *operation = [_operationManager DELETE:URLString parameters:parameters success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // we could check here if this was because of expired token, and then re-authenticate
        
        [self logRequest:operation.request error:error responseObject:operation.responseObject];

        // if the error happened because the operation got cancelled then it's actually not an error
        if (errorBlock && !operation.isCancelled) {
            errorBlock([self errorTextForOperation:operation]);
        }
        
        // on authentication errors, log out of the app (close views)
        if (! allowAuthFail && operation.responseObject[@"error_code"]) {
            NSInteger errorCode = [operation.responseObject[@"error_code"] integerValue];
//            if (errorCode == 102) {
//                [self clearOnLogout];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NotifyLogOff object:self];
//            }
        }
    }];
    return operation;
}


- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^) (NSString *error))errorBlock
{
    return [self GET:URLString parameters:parameters success:success failure:errorBlock allowAuthFail:NO];
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^) (NSString *error))errorBlock allowAuthFail:(BOOL)allowAuthFail
{
    AFHTTPRequestOperation *operation = [_operationManager GET:URLString parameters:parameters success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // we could check here if this was because of expired token, and then re-authenticate
        
        [self logRequest:operation.request error:error responseObject:operation.responseObject];
        
        // if the error happened because the operation got cancelled then it's actually not an error
        if (errorBlock && !operation.isCancelled) {
            errorBlock([self errorTextForOperation:operation]);
        }
        
        // if we are not logging in, then on authentication errors, log out of the app (close views)
        if (! allowAuthFail && operation.responseObject[@"error_code"]) {
            NSInteger errorCode = [operation.responseObject[@"error_code"] integerValue];
//            if (errorCode == 102) {
//                [self clearOnLogout];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NotifyLogOff object:self];
//            }
        }
    }];
    return operation;
}


- (AFHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^) (NSString *error))errorBlock
{
    return [self PUT:URLString parameters:parameters success:success failure:errorBlock allowAuthFail:NO];
}
                                         
- (AFHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^) (NSString *error))errorBlock  allowAuthFail:(BOOL)allowAuthFail
{
    AFHTTPRequestOperation *operation = [_operationManager PUT:URLString parameters:parameters success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // we could check here if this was because of expired token, and then re-authenticate
        
        [self logRequest:operation.request error:error responseObject:operation.responseObject];
        
        // if the error happened because the operation got cancelled then it's actually not an error
        if (errorBlock && !operation.isCancelled) {
            errorBlock([self errorTextForOperation:operation]);
        }
    
        // if we are not logging in, then on authentication errors, log out of the app (close views)
        if (! allowAuthFail && operation.responseObject[@"error_code"]) {
            NSInteger errorCode = [operation.responseObject[@"error_code"] integerValue];
//            if (errorCode == 102) {
//                [self clearOnLogout];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NotifyLogOff object:self];
//            }
        }
    }];
    return operation;
}


- (void)logRequest:(NSURLRequest *)request error:(NSError *)error responseObject:(id)responseObject
{
    NSString *body;
    if ([request.HTTPBody length] < 1024) {
        body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    } else {
        body = @"<Too Big To Show>";
    }
    CLS_LOG(@"%@ error: %@\n\nRequest URL:\n%@\n\nRequest Headers:\n%@\n\nRequest Body:\n%@\n\nResponse Data:\n%@\n\n", request.HTTPMethod, error, request.URL, request.allHTTPHeaderFields, body, responseObject);
}

#pragma mark - API Calls

- (void)saveCardToken:(NSString *)cardToken
          withSuccess:(void (^) (void))successBlock
              failure:(void (^) (NSString *error))errorBlock
{
    static NSString *clientMobileNo = @"9876";
    
    [self PUT:@"users" parameters:@{@"cc_token" : cardToken,
                                    @"mobile_no" : clientMobileNo,
                                    @"api_provider" : [[Tokenizer sharedInstance] selectedApiLowercaseTitle]
                                    }
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock();
        }
    } failure:errorBlock];
}

- (void)saveMerchantWithName:(NSString *)name
                       taxId:(NSString *)taxId
                isIndividual:(BOOL)isIndividual
            bankAccountToken:(NSString *)bankAccountToken
              debitCardToken:(NSString *)debitCardToken
                 withSuccess:(void (^) (void))successBlock
                     failure:(void (^) (NSString *error))errorBlock
{
    static NSString *merchantMobileNo = @"1234";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:merchantMobileNo forKey:@"mobile_no"];
    params[@"name"] = name;
    params[@"tax_id"] = taxId;
    params[@"type"] = isIndividual ? @"individual" : @"corporation";
    if (bankAccountToken) {
        params[@"bank_account_token"] = bankAccountToken;
    }
    if (debitCardToken) {
        params[@"debit_card_token"] = debitCardToken;
    }
    
    params[@"api_provider"] = [[Tokenizer sharedInstance] selectedApiLowercaseTitle];
    
    [self PUT:@"users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlock) {
            successBlock();
        }
    } failure:errorBlock];
}


- (void)customerPaysAmount:(float)amount
                   success:(void (^) (void))successBlock
                   failure:(void (^) (NSString *error))errorBlock
{
    static NSString *clientMobileNo = @"9876";
    
    [self POST:@"payment" parameters:@{@"mobile_no" : clientMobileNo,
                                       @"amount" : [NSNumber numberWithFloat:amount],
                                       @"api_provider" : [[Tokenizer sharedInstance] selectedApiLowercaseTitle]
                                       }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           if (successBlock) {
               successBlock();
           }
       } failure:errorBlock];
}

@end
