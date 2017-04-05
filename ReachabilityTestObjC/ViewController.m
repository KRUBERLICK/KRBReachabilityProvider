//
//  ViewController.m
//  ReachabilityTestObjC
//
//  Created by Daniel Ilchishyn on 4/5/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

#import "ViewController.h"

#pragma mark - PRIVATE PROPERTIES
@interface ViewController ()

@property (nonatomic) UILabel * reachabilityStatusLabel;
@property (nonatomic) KRBReachabilityProvider * reachabilityProvider;

@end
#pragma mark -


@implementation ViewController

#pragma mark - INITIALIZATION
- (instancetype)init
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.view.backgroundColor = [UIColor whiteColor];
        _reachabilityProvider = [[KRBReachabilityProvider alloc] initWithHostName:@"www.apple.com"];
        _reachabilityProvider.delegate = self;
        _reachabilityStatusLabel = [[UILabel alloc] init];
        _reachabilityStatusLabel.text = @"Updating reachability status";
        [self setupSubviews];
    }
    return self;
}

#pragma mark - SUBVIEWS SETUP
- (void)setupSubviews
{
    self.reachabilityStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.reachabilityStatusLabel];
    [self.reachabilityStatusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.reachabilityStatusLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void)reachabilityStatusDidChange:(ReachabilityStatus)status
{
    switch (status) {
        case ReachabilityStatusUnknown:
            self.reachabilityStatusLabel.text = @"Status: Unknown";
            break;
        case ReachabilityStatusNotReachable:
            self.reachabilityStatusLabel.text = @"Status: Not reachable";
            break;
        case ReachabilityStatusReachaleViaWWAN:
            self.reachabilityStatusLabel.text = @"Status: Reachable via WWAN";
            break;
        case ReachabilityStatusReachableViaWiFi:
            self.reachabilityStatusLabel.text = @"Status: Reachable via WiFi";
            break;
    }
}

@end
