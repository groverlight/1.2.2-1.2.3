
//! \file   AppViewController.h
//! \brief  The main ViewController of the application.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>

#import "Blocks.h"
//__________________________________________________________________________________________________

//! The main ViewController of the application.
@interface AppViewController : UIViewController
{
@public
  BOOL LoggedIn;
}
//____________________

- (void)loginDone:(BOOL)newUser;
//____________________

- (void)handleRemoteNotification:(NSString*)notificationMessage;
//____________________

//! The application did just become active.
- (void)applicationDidBecomeActive;
//____________________

//! The application wil become inactive.
- (void)applicationWillResignActive;
//____________________

//! Perform background data fetch.
- (void)performBackgroundFetch:(BlockBoolAction)completion;
//____________________

@end
//__________________________________________________________________________________________________

//! Present in a custom view the data contained in the remote notification userInfo dictionary.
void DidReceiveRemoteNotification(NSDictionary* userInfo, BlockBoolAction completion);
//__________________________________________________________________________________________________

//! The application did just become active.
void ApplicationDidBecomeActive(void);
//__________________________________________________________________________________________________

//! The application wil become inactive.
void ApplicationWillResignActive(void);
//__________________________________________________________________________________________________

//! Perform background data fetch.
void PerformBackgroundFetch(BlockBoolAction completion);
//__________________________________________________________________________________________________
