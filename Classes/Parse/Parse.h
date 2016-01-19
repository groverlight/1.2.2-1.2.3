
//! \file   Parse.h
//! \brief  Entry points for all Parse related stuff.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "Blocks.h"
#import "Message.h"
#import "ParseUser.h"
//__________________________________________________________________________________________________

@class UnreadMessages;
@class ParseMessage;
//__________________________________________________________________________________________________

//! Perform the primary Parse initialization stuff.
void ParseAppDelegateInitialization(NSDictionary* launchOptions);
//__________________________________________________________________________________________________

//! \brief  Setup the Parse stuff by eventually creating an anonymous user and making it current if already existing.
//! \return YES if the aApp has never been run before.
BOOL ParseInitialization
(
  InitializationBlockAction completion //!< The block to call when initialization has completed.
);
//__________________________________________________________________________________________________

//! Check if a username is already used.
void ParseIsUsernameAlreadyInUse
(
  NSString*             username,   //!< The username to test.
  BlockBoolErrorAction  completion  //!< The block to call when test has completed.
);
//__________________________________________________________________________________________________

//! Find the user linked to the specified phone number.
void ParseFindUserByPhoneNumber
(
  NSString*             phoneNumber,  //!< The phone number to find.
  BlockUserErrorAction  completion    //!< The block to call when search has completed.
);
//__________________________________________________________________________________________________

//! Finalize the login process.
void ParseFinalizeLogIn(void);
//__________________________________________________________________________________________________

//! Extract the real Parse error code.
NSInteger ParseExtractErrorCode
(
  NSError* error
);
//__________________________________________________________________________________________________

//! Delete all the messages from users that are not our friends.
void ParseDeleteMessagesFromNoFriend
(
  UnreadMessages* unreadMsgs  //!< The message to check for deletion.
);
//__________________________________________________________________________________________________

//! Delete all the messages with specified from user ids.
void ParseDeleteParseMessagesFromUsers
(
  NSMutableArray* messages,   //!< The message to check for deletion.
  NSMutableArray* fromUserIds //!< The from users to check for message deletion.
);
//__________________________________________________________________________________________________

//! Delete the specified message from Parse storage.
void ParseDeleteParseMessage
(
  ParseMessage*         msg,        //!< The message to delete.
  BlockBoolErrorAction  completion  //!< The block to call when deletion has completed.
);
//__________________________________________________________________________________________________

//! Save to Parse storage the specified message.
void ParseSendMessage
(
  Message*              msg,        //!< The message to send.
  BlockBoolErrorAction  completion  //!< The block to call when the message has been sent.
);
//__________________________________________________________________________________________________

//! Delete the specified message from Parse storage.
void ParseDeleteMessage
(
  Message*              msg,        //!< The message to delete.
  BlockBoolErrorAction  completion  //!< The block to call when deletion has completed.
);
//__________________________________________________________________________________________________

//! Ask another user to remove the current user from its friends list.
void ParseRemoveFriend
(
  ParseUser*            friendToBeRemovedFrom,  //!< The user to be asked to remove the current user from its friends list.
  BlockBoolErrorAction  completion              //!< The block to call when the message has been sent.
);
//__________________________________________________________________________________________________

//! Load all the unplayed messages for the current user from the Parse storage.
void ParseLoadMessageArray
(
  BlockAction           loadedStartProcessing,  //!< Called once the messages have been loaded and before processing them. Typically used to start an activity indicator.
  BlockBoolErrorAction  completion              //!< The block to call when the messages array has been completely loaded. The BOOL Parameter tells if the array has changed.
);
//__________________________________________________________________________________________________

//! Load all the unknown users in the unread messages.
void ParseLoadUsersForMessages(UnreadMessages* unreadMsgs, BlockAction completion);
//__________________________________________________________________________________________________

//! Start the phone number verification process.
void ParseStartVerification
(
  NSString*             phoneNumber,  //!< The phone number to verify.
  BlockBoolErrorAction  completion    //!< The block to call when the first verification step has completed. Parameter is YES in case of success.
);
//__________________________________________________________________________________________________

//! Complete the phone number verification process.
void ParseCompleteVerification
(
  NSString*             verificationCode, //!< The verification code to validate.
  BlockBoolErrorAction  completion        //!< The block to call when the second verification step has completed. Parameter is YES in case of success.
);
//__________________________________________________________________________________________________

//=============================== Remote Push notifications stuff ==================================

//! Check if remote notifications have been allowed by the user.
BOOL ParseCheckPermissionForRemoteNotifications(void);
//__________________________________________________________________________________________________

//! Register the App for remote notifications.
void ParseRegisterForRemoteNotifications(BlockBoolAction completion);
//__________________________________________________________________________________________________

//! Callback after successful registering for remote notifications (< iOS 8).
void ParseDidRegisterForRemoteNotificationsWithDeviceToken(NSData* deviceToken);
//__________________________________________________________________________________________________

//! Callback after failed registering for remote notifications.
void ParseDidFailToRegisterForRemoteNotificationsWithError(NSError* error);
//__________________________________________________________________________________________________

//! Callback when receiving a remote notification.
void ParseDidReceiveRemoteNotification(NSDictionary* userInfo);
//__________________________________________________________________________________________________

//! Callback when a remote notification requires an action.
void ParseHandleActionWithIdentifier(NSString* identifier, NSDictionary* userInfo, BlockAction completionHandler);
//__________________________________________________________________________________________________

//! Callback after successful registering for remote notifications (>= iOS 8).
void ParseDidRegisterUserNotificationSettings(UIUserNotificationSettings* notificationSettings);
//__________________________________________________________________________________________________

//! Send a remote notification to the specified user.
void ParseSendPushNotificationToUser(NSString* destUserObjectId, NSString* text);
//__________________________________________________________________________________________________

//! Send a silent remote notification to the specified user.
void ParseSendSilentPushNotificationToUser(NSString* destUserObjectId);
//__________________________________________________________________________________________________

//! Set the App icon badge number to the specified value.
void ParseSetBadge(NSInteger badgeNumber);
//__________________________________________________________________________________________________

//! Clear the App icon badge number.
void ParseClearBadge(void);
//__________________________________________________________________________________________________
