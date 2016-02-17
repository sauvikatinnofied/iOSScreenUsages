//
//  DarwinNotifications.m
//  ScreenUsages
//
//  Created by Sauvik Dolui on 16/02/16.
//  Copyright © 2016 Innofied. All rights reserved.
//

#import "DarwinNotificationsManager.h"

@implementation DarwinNotificationsManager {
    NSMutableDictionary * handlers;
}

+ (instancetype)sharedInstance {
    static id instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback {
    handlers[name] = callback;
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(center, (__bridge const void *)(self), defaultNotificationCallback, (__bridge CFStringRef)name, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)postNotificationWithName:(NSString *)name {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, (__bridge CFStringRef)name, NULL, NULL, YES);
}

- (void)notificationCallbackReceivedWithName:(NSString *)name {
    void (^callback)(void) = handlers[name];
    callback();
}

void defaultNotificationCallback (CFNotificationCenterRef center,
                                  void *observer,
                                  CFStringRef name,
                                  const void *object,
                                  CFDictionaryRef userInfo)
{
    NSLog(@"name: %@", name);
    NSLog(@"userinfo: %@", userInfo);
    
    NSString *identifier = (__bridge NSString *)name;
    [[DarwinNotificationsManager sharedInstance] notificationCallbackReceivedWithName:identifier];
}

#define NotifName_LockComplete @"com.apple.springboard.lockcomplete"
#define NotifName_LockState    @"com.apple.springboard.lockstate"


//call back
static void lockStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef name_cf, const void *object, CFDictionaryRef userInfo){
    NSString *name = (__bridge NSString*)name_cf;
    if ([name isEqualToString:NotifName_LockComplete]) {
        NSLog(@"DEVICE LOCKED");
    } else if ([name isEqualToString:NotifName_LockState]) {
        NSLog(@"LOCK STATUS CHANGED");
    }
}


- (void)registerforDeviceLockNotif {
    //Screen lock notifications
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    lockStatusChanged,
                                    (__bridge CFStringRef)NotifName_LockComplete,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    lockStatusChanged,
                                    (__bridge CFStringRef)NotifName_LockState,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}
@end
