//
//  DarwinNotifications.h
//  ScreenUsages
//
//  Created by Sauvik Dolui on 16/02/16.
//  Copyright © 2016 Innofied. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DarwinNotificationsManager : NSObject
@property (strong, nonatomic) id someProperty;

+ (instancetype)sharedInstance;

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback;
- (void)postNotificationWithName:(NSString *)name;


- (void)registerforDeviceLockNotif;
@end
