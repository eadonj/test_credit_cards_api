//
//  APIClient.h
//  Webproof
//
//  Created by Andris Zalitis on 7/4/14.
//  Copyright (c) 2014 POLLEO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIClient : NSObject

//@property (nonatomic, readonly) APISession *session;

+ (instancetype)sharedInstance;

- (void)saveCardToken:(NSString *)cardToken
          withSuccess:(void (^) (void))successBlock
              failure:(void (^) (NSString *error))errorBlock;

@end
