//
//  KRBReachabilityProvider.m
//  ReachabilityTestObjC
//
//  Created by Daniel Ilchishyn on 4/5/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

#import "KRBReachabilityProvider.h"
#import <SystemConfiguration/SystemConfiguration.h>


#pragma mark - HELPER FUNCTIONS
/**
 Converts the given flags to ReachabilityStatus enum constant.
 Implementation is taken from https://developer.apple.com/library/content/samplecode/Reachability/Listings/Reachability_Reachability_m.html#//apple_ref/doc/uid/DTS40007324-Reachability_Reachability_m-DontLinkElementID_9

 @param flags Provided SCNetworkReachabilityFlags
 @return An appropriate ReachabilityStatus enum constant
 */
ReachabilityStatus reachabilityStatusFromFlags(SCNetworkReachabilityFlags flags)
{
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        return ReachabilityStatusNotReachable; // The target host is not reachable.
    }
    ReachabilityStatus returnValue = ReachabilityStatusNotReachable;
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         * If the target host is reachable and no connection is required
         * then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = ReachabilityStatusReachableViaWiFi;
    }
    if (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)
    {
        /*
         * ... and the connection is on-demand (or on-traffic) if the calling
         * application is using the CFSocketStream or higher APIs...
         */
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            returnValue = ReachabilityStatusReachableViaWiFi; // ... and no [user] intervention is needed...
        }
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         * ... but WWAN connections are OK if the calling
         * application is using the CFNetwork APIs.
         */
        returnValue = ReachabilityStatusReachaleViaWWAN;
    }
    return returnValue;
}


#pragma mark - REACHABILITY CHANGE CALLBACK FUNCTION AND NOTIFICATION NAME CONSTANT
NSString * kReachabilityChangedNotificationName = @"kReachabilityChangedNotification";

/**
 A function to use as a reachability status change callback.

 @param target Network reachabilty ref that triggered this function call
 @param flags Reachability flags containing info about connection status
 @param info Optional info object
 */
void reachabilityCallbackFunc(SCNetworkReachabilityRef target,
                              SCNetworkReachabilityFlags flags,
                              void * __nullable info)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotificationName
                                                        object:nil
                                                      userInfo:@{@"status": @(reachabilityStatusFromFlags(flags))}];
}
#pragma mark -


#pragma mark - PRIVATE PROPERTIES
@interface KRBReachabilityProvider ()

@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;

@end
#pragma mark -


@implementation KRBReachabilityProvider

#pragma mark - INITIALIZATION/DEALLOCATION
/**
 Initializes reachability provider with a given host name.

 @param host A host to use for reachability status changes
 @return Initialized reachability provider
 */
- (instancetype)initWithHostName:(NSString *)host
{
    if (self = [super init]) {
        _currentReachabilityStatus = ReachabilityStatusUnknown;
        _reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [host cStringUsingEncoding:NSASCIIStringEncoding]);
        [self setupReachabilityListener];
    }
    return self;
}

- (void)dealloc
{
    /*
     * Unschedule reachability ref from current run loop
     */
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef,
                                               CFRunLoopGetCurrent(),
                                               kCFRunLoopDefaultMode);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - REACHABILITY LISTENER SETUP
- (void)setupReachabilityListener
{
    /*
     * Schedule initialized reachability ref in current run loop
     */
    if (!SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef,
                                                  CFRunLoopGetCurrent(),
                                                  kCFRunLoopDefaultMode)) {
        return;
    }
    /*
     * Set callback function
     */
    SCNetworkReachabilitySetCallback(self.reachabilityRef,
                                     reachabilityCallbackFunc,
                                     NULL);
    /*
     * Subscribe to reachability status change notifications
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processReachabilityChangeNotification:)
                                                 name:kReachabilityChangedNotificationName
                                               object:nil];
}

/**
 Processes incoming reachability change notification and sets the self.currentReachabilityStatus.

 @param notification Incoming reachability change notification
 */
- (void)processReachabilityChangeNotification:(NSNotification *)notification
{
    /*
     * Check the userInfo dictionary and fetch reachability status
     */
    if (!notification.userInfo) {
        return;
    }
    id statusObj = [notification.userInfo objectForKey:@"status"];
    if (!statusObj) {
        return;
    }
    ReachabilityStatus status = [statusObj intValue];
    /*
     * Notify the delegate if new status is not the same 
     * as previous and update self.currentReachabilityStatus
     */
    if (status != self.currentReachabilityStatus) {
        if (self.delegate) {
            [self.delegate reachabilityStatusDidChange:status];
        }
    }
    self.currentReachabilityStatus = status;
}

@end
