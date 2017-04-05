//
//  KRBReachabilityProvider.h
//  ReachabilityTestObjC
//
//  Created by Daniel Ilchishyn on 4/5/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - ReachabilityStatus CONSTANTS
typedef NS_ENUM(NSInteger, ReachabilityStatus) {
    ReachabilityStatusReachableViaWiFi,
    ReachabilityStatusReachaleViaWWAN,
    ReachabilityStatusNotReachable,
    ReachabilityStatusUnknown
};
#pragma mark -

#pragma mark - KRBReachabilityProviderDelegate
@protocol KRBReachabilityProviderDelegate <NSObject>

- (void)reachabilityStatusDidChange:(ReachabilityStatus)status;

@end
#pragma mark -


@interface KRBReachabilityProvider : NSObject

@property (nonatomic) ReachabilityStatus currentReachabilityStatus;
@property (nonatomic, weak) id<KRBReachabilityProviderDelegate> delegate;

- (instancetype)initWithHostName:(NSString *)host;

@end
