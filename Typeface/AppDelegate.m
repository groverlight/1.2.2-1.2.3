
//! \file   AppDelegate.m
//! \brief  The App delegate.
//__________________________________________________________________________________________________

#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "AppViewController.h"
#import "Parse.h"
#import "Mixpanel.h"

//__________________________________________________________________________________________________

typedef void(^BlockBfrAction)(UIBackgroundFetchResult result);
//__________________________________________________________________________________________________

//! Application delegate.
@interface AppDelegate () <UIApplicationDelegate>
{
  AppViewController*  RootViewController;
  BlockBfrAction      NotificationCompletionHandler;
}

@end
//__________________________________________________________________________________________________

@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [Parse enableLocalDatastore];

    #define MIXPANEL_TOKEN @"bfcb77fdbcaaa747ac994c1bdba999aa"


    // Initialize the library with your
    // Mixpanel project token, MIXPANEL_TOKEN
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    /*NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
     NSLog(@"notificationpayload: %@", notificationPayload);
    NSString *objectid = [notificationPayload objectForKey:@"p"];
    [[PFUser currentUser] addUniqueObject:objectid forKey:@"friends"];
    [[PFUser currentUser] saveInBackground];*/
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

  // Parse initialization.
  ParseAppDelegateInitialization(launchOptions);
   


    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd MMM YYYY HH:mm:ss";
    NSString *string = [formatter stringFromDate:[NSDate date]];

    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel track:@"last seen"];

    [mixpanel identify:mixpanel.distinctId];

    [mixpanel.people set:@{@"$last_seen": string}];

    [mixpanel flush];

    NSLog(@"app launched from quit");

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  RootViewController = [[AppViewController alloc] init];
  [self.window setRootViewController:RootViewController];
  [self.window makeKeyAndVisible];
  return YES;



}
//__________________________________________________________________________________________________

- (void)application:(UIApplication*)application performFetchWithCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler
{
//ac  NSLog(@"\n\nperformFetchWithCompletionHandler Start");
  PerformBackgroundFetch(^(BOOL hasNewData)
  {
//    NSLog(@"performFetchWithCompletionHandler End");
    // Code to be called in a completion handler.
    completionHandler(hasNewData? UIBackgroundFetchResultNewData: UIBackgroundFetchResultNoData);
  });
}
//__________________________________________________________________________________________________

- (void)applicationWillResignActive:(UIApplication*)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  ApplicationWillResignActive();
}
//__________________________________________________________________________________________________

- (void)applicationDidEnterBackground:(UIApplication*)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
//__________________________________________________________________________________________________

- (void)applicationWillEnterForeground:(UIApplication*)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
//__________________________________________________________________________________________________

- (void)applicationDidBecomeActive:(UIApplication*)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  ApplicationDidBecomeActive();
}
//__________________________________________________________________________________________________

- (void)applicationWillTerminate:(UIApplication*)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//__________________________________________________________________________________________________

//=============================== Remote Push notifications stuff ==================================

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
  ParseDidRegisterForRemoteNotificationsWithDeviceToken(deviceToken);
}
//__________________________________________________________________________________________________

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
  ParseDidFailToRegisterForRemoteNotificationsWithError(error);
}
//__________________________________________________________________________________________________

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    NotificationCompletionHandler = handler;
    NSLog(@"\n\n");
    NSLog(@"didReceiveRemoteNotification Start: %p", NotificationCompletionHandler);
    DidReceiveRemoteNotification(userInfo, ^(BOOL hasNewData)
                                 {
                                     NSLog(@"%@", userInfo);
                                     NSLog(@"didReceiveRemoteNotification End: %p", NotificationCompletionHandler);
                                     if (NotificationCompletionHandler != nil)
                                     {
                                         NotificationCompletionHandler(hasNewData? UIBackgroundFetchResultNewData: UIBackgroundFetchResultNoData);
                                         NotificationCompletionHandler = NULL;
                                     }
                                 });
    NSLog(@"hi");
    if ([userInfo objectForKey:@"p"] != nil)
        {
            ParseLoadMessageArray(^{
                
            }, ^(BOOL value, NSError *error) {
                
            });
            NSLog(@"userInfo: %@", userInfo);
            NSString *objectid = [userInfo objectForKey:@"p"];
            NSString *stop = [userInfo objectForKey:@"stop"];
            //NSString *phoneNumber = [userInfo objectForKey:@"t"];
            NSLog(@"objectid: %@", objectid);
            if ([objectid length] != 0)
            {
            [[PFUser currentUser] addUniqueObject:objectid forKey:@"friends"];
            [[PFUser currentUser] saveInBackground];
            }
            
            if (stop == nil)
            {
                PFQuery *pushQuery = [PFInstallation query];
                PFUser * user = [PFQuery getUserObjectWithId:objectid];
                [pushQuery whereKey:@"user" equalTo:user];
                
                // Send push notification to query
                NSDictionary *data = @{
                                       
                                       
                                       @"content-available": @"1",
                                       @"sound": @"",
                                       @"alert": @"",
                                       @"p" :[PFUser currentUser].objectId,
                                       @"t" :[PFUser currentUser][@"phoneNumber"],
                                       @"stop": @"1",
                                      
                            
                                       };
                
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                [push setMessage:@"this works"];
                [push setData:data];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *sendError)
                 {
                     NSLog(@"Sending Push");
                 }];
            }

        }
    

    
}
//__________________________________________________________________________________________________

- (void)application:(UIApplication*)application handleActionWithIdentifier:(NSString*)identifier forRemoteNotification:(NSDictionary*)userInfo completionHandler:(void(^)())completionHandler;
{
    
  ParseHandleActionWithIdentifier(identifier, userInfo, ^
  {
    completionHandler();
  });
}
//__________________________________________________________________________________________________

- (void)application:(UIApplication*)application didRegisterUserNotificationSettings:(UIUserNotificationSettings*)notificationSettings
{
  ParseDidRegisterUserNotificationSettings(notificationSettings);
}
//__________________________________________________________________________________________________
@end
//__________________________________________________________________________________________________
