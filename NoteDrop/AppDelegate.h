//
//  AppDelegate.h
//  NoteDrop
//
//  Created by JRamos on 5/27/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) EKEventStore *eventStore;

+ (AppDelegate *)sharedDelegate;

@end
