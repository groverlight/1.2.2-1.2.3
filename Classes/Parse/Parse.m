
//! \file   Parse.m
//! \brief  Entry points for all Parse related stuff.
//__________________________________________________________________________________________________

#import <Bolts/Bolts.h>
#import "FriendRecord.h"
#import "GlobalParameters.h"
#import "Parse.h"
#import "ParseAppIdAndClientKey.h"
#import "ParseBlocked.h"
#import "ParseMessage.h"
#import "Tools.h"
#import "UnreadMessages.h"
#import "Mixpanel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "FriendSelectionView.h"

//__________________________________________________________________________________________________

#define PARSE_USER_TOKEN_DEFAULTS_KEY @"ParseUserToken" //!< The key to retrieve the Parse token in the user defaults.
#define PARSE_LOGGED_IN_DEFAULTS_KEY  @"ParseLoggedIn"  //!< The key to verify if the user is already successuflly logged in.

#define LOGIN_STATE_DEFAULTS_KEY              @"LoginState"             //!< The key to retrieve the login state in the user defaults.
#define LOGIN_COUNTRY_NAME_DEFAULTS_KEY       @"LoginCountryName"       //!< The key to retrieve the country prefix in the user defaults.
#define LOGIN_PHONE_NUMBER_DEFAULTS_KEY       @"LoginPhoneNumber"       //!< The key to retrieve the phone number in the user defaults.
#define LOGIN_VERIFICATION_CODE_DEFAULTS_KEY  @"LoginVerificationCode"  //!< The key to retrieve the verification code in the user defaults.
#define LOGIN_USER_NAME_DEFAULTS_KEY          @"LoginUsername"          //!< The key to retrieve the username in the user defaults.
#define LOGIN_FULL_NAME_DEFAULTS_KEY          @"LoginFullName"          //!< The key to retrieve the user's full name in the user defaults.

#define PARSE_REMOVE_FRIEND_ACTION            @"removeFriend"           //!< The action to ask a user to remove another user from its friends list.
//__________________________________________________________________________________________________

static BOOL             FirstRun = YES;
static BlockBoolAction  RegisterCompletionAction;
//__________________________________________________________________________________________________

//==================================================================================================

// This is workaround for a Parse bug introduced in the version 1.7.4.
@interface NSData (PFData)
+ (NSData *) PF_dataFromBase64String: (NSString *) base64;
- (NSString *) PF_base64EncodedString;
@end
//__________________________________________________________________________________________________

@implementation NSData (PFData)

+ (NSData *) PF_dataFromBase64String: (NSString *) base64
{
  return [NSData.alloc initWithBase64EncodedString: base64 options: 0];
} // +PF_dataFromBase64String:

- (NSString *) PF_base64EncodedString
{
  return [self base64EncodedStringWithOptions: 0];
} // -PF_base64EncodedString

 SystemSoundID           soundEffect;

@end
//==================================================================================================

//! Reset all the login saved data.
void ResetLoginDefaults(void)
{
  NSUserDefaults* defaults  = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:PARSE_LOGGED_IN_DEFAULTS_KEY];
  [defaults removeObjectForKey:LOGIN_STATE_DEFAULTS_KEY];
  [defaults removeObjectForKey:LOGIN_COUNTRY_NAME_DEFAULTS_KEY];
  [defaults removeObjectForKey:LOGIN_PHONE_NUMBER_DEFAULTS_KEY];
  [defaults removeObjectForKey:LOGIN_VERIFICATION_CODE_DEFAULTS_KEY];
  [defaults removeObjectForKey:LOGIN_USER_NAME_DEFAULTS_KEY];
  [defaults removeObjectForKey:LOGIN_FULL_NAME_DEFAULTS_KEY];
}
//__________________________________________________________________________________________________

//! Perform the primary Parse initialization stuff.
void ParseAppDelegateInitialization(NSDictionary* launchOptions)
{
  NSLog(@"ParseAppDelegateInitialization");
  [Parse setApplicationId:PARSE_APPLICATION_ID clientKey:PARSE_CLIENT_KEY];
  // Parse Analytics initialization.
  [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

  RegisterCompletionAction = ^(BOOL result)
  { // Default action: do nothing!
  };
}
//__________________________________________________________________________________________________

//! Log in with an anonymous account.
static void LogInAnonymously
(
  InitializationBlockAction completion, //!< The block to call when initialization has completed.
  BOOL                      restart     //!< The value to set to the restart parameter of the completion block.
)
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  [PFAnonymousUtils logInWithBlock:^(PFUser* user, NSError* error)
  {
    if (([error.domain isEqualToString:@"Parse"]) && (error.code != 101))
    {
      NSLog(@"Anonymous login failed.");
    }
    else
    {
      NSLog(@"Anonymous user logged in : %@.", user.sessionToken);
      [defaults setObject:user.sessionToken forKey:PARSE_USER_TOKEN_DEFAULTS_KEY];
    }
    completion((ParseUser*)user, YES, restart, error);
  }];
}
//__________________________________________________________________________________________________

//! \brief  Setup the Parse stuff by eventually creating an anonymous user and making it current if already existing.
//! \return YES if the aApp has never been run before.
BOOL ParseInitialization
(
  InitializationBlockAction completion //!< The block to call when initialization has completed.
)
{
    NSLog(@"ParseInitialization");
    //look for friends you're not friends with
        // load up sendlist
    if ([PFUser currentUser] != nil)
    {
        PFQuery *friendquery = [PFUser query];
        
        [friendquery whereKey:@"friends" equalTo:[PFUser currentUser].objectId];
        [friendquery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects != nil)
                for (PFUser *user in objects)
                {
                    [[PFUser currentUser] addUniqueObject:user.objectId  forKey:@"friends"];
                }
        }];
    }
    PFQuery *query = [PFQuery queryWithClassName:@"localDatastore"];

    [query fromLocalDatastore];
    PFObject *temp = [query getFirstObject];
    //NSLog(@"temp %@", temp);
    
    if( recentListUsers == nil)
    {
        recentListUsers = [[NSMutableArray alloc]init];
    }
    if ([recentListUsers count] == 0)
    {


       NSArray* friends = [PFUser currentUser][@"friends"];
        //NSLog(@"friends: %@", friends);
            for (NSMutableDictionary *person in temp[@"FriendsList"])
            {
               
                FriendRecord* tempRecord    = [FriendRecord new];
                tempRecord.phoneNumber = [person objectForKey:@"phoneNumber"];
                tempRecord.fullName = [person objectForKey:@"fullName"];
                tempRecord.lastActivityTime = [[person objectForKey:@"lastActivityTime"] doubleValue];
                //tempRecord.user = [person objectForKey:@"user"];
                //NSLog(@"tempRecord: %@", tempRecord);
                [recentListUsers addObject:tempRecord];
            }
        for (NSString * objectId in friends)
            {
                //NSLog(@"hi");
                [ParseUser findUserWithObjectId:objectId completion:^(ParseUser* user, NSError* error)
                 {
                
               // NSLog(@"%@", user);
                FriendRecord *record = [FriendRecord new];
                record.fullName = user.fullName;
                record.phoneNumber = user.phoneNumber;
                record.user = user;
                NSInteger flag = 0;
                for (NSInteger i = 0; i < [recentListUsers count]; i++)
                {
                    FriendRecord *friend =  recentListUsers[i];
                   // NSLog(@"friend: %@ record: %@", friend.phoneNumber, record.phoneNumber);
                    if ([friend.phoneNumber isEqualToString: record.phoneNumber])
                    {
                       // NSLog(@"found");
                        record.lastActivityTime = friend.lastActivityTime;
                        recentListUsers[i] = record;
                        //NSLog(@"record:%@",record.user);
                    }
                    else{
                        flag++;
                    }
                    
                }
                     if (flag == [recentListUsers count])
                     {
                         [recentListUsers addObject:record];
                     }
                 }];
            }
        
        
        

        [recentListUsers sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             FriendRecord* record1 = (FriendRecord*)obj1;
             FriendRecord* record2 = (FriendRecord*)obj2;
             
             return ([record1.fullName caseInsensitiveCompare:record2.fullName]);
         }];
        
    //  NSLog(@"recentListUsers udpated: %@", recentListUsers);

    }

  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSString* parseUserToken = [defaults stringForKey:PARSE_USER_TOKEN_DEFAULTS_KEY];
  FirstRun = (parseUserToken == nil);
  if (FirstRun)
  {
    LogInAnonymously(completion, NO);
  }
  else
  {
      
// NSLog(@"--- currentUser: %p", GetCurrentParseUser());
    [ParseUser becomeInBackground:parseUserToken block:^(PFUser* user, NSError* error)
    {
//      NSLog(@"--- user: %p", user);
//      NSLog(@"user: %@, error: %@", user, error);
      GlobalParameters* globalParams = GetGlobalParameters();
      if (error == nil)
      {
        if (![defaults boolForKey:PARSE_LOGGED_IN_DEFAULTS_KEY])
        {
          completion((ParseUser*)user, YES, NO, error);
        }
        else
        {
          [ParseBlocked isUserBlocked:(ParseUser*)user completion:^(ParseBlocked* blocked, NSError* blocked_error)
          {
            if (blocked_error != nil)
            {
              completion((ParseUser*)user, NO, NO, blocked_error);
            }
            else if ((blocked == nil) || ([blocked[@"blockType"] isEqual:@"user"]))
            {
              completion((ParseUser*)user, NO, NO, error);
            }
            else
            {
              globalParams.userIsBlocked(blocked[@"reason"]);
              completion(nil, YES, NO, error);
            }
          }];
        }
      }
      else if (error.code == 100)
      {
        globalParams.missingInternetConnection(^
        {
          ParseInitialization(completion);
        });
      }
      else
      {
        // The Parse user token is invalid. Remove it, delete the login defaults, notify the App and restart the initialization process.
        [PFUser logOut];
        [defaults removeObjectForKey:PARSE_USER_TOKEN_DEFAULTS_KEY];
        ResetLoginDefaults();
        globalParams.invalidParseSessionToken();
//        ParseInitialization(completion);
        LogInAnonymously(completion, YES);
      }
    }];
  }
  return FirstRun;
}
//__________________________________________________________________________________________________

//! Check if a username is already used.
void ParseIsUsernameAlreadyInUse
(
  NSString*             username,   //!< The username to test.
  BlockBoolErrorAction  completion  //!< The block to call when test has completed.
)
{
  [ParseUser testUserExistenceWithUsername:username completion:^(BOOL exists, NSError *error)
  {
    completion(exists, error);
  }];
}
//__________________________________________________________________________________________________

//! Find the user linked to the specified phone number.
void ParseFindUserByPhoneNumber
(
  NSString*             phoneNumber,  //!< The phone number to find.
  BlockUserErrorAction  completion    //!< The block to call when search has completed.
)
{
  [ParseUser findUsersWithPhoneNumber:phoneNumber completion:^(NSArray* users, NSError *error)
  {
#if 0
    NSLog(@"Num users with same phone number: %d", (int)users.count);
    for (PFObject* obj in users)
    {
      NSLog(@"Obj: %@", obj);
    }
#endif
    if (users.count > 0)
    {
      completion([users objectAtIndex:0], error);
    }
    else
    {
      completion(nil, error);
    }
  }];
}
//__________________________________________________________________________________________________

//! Finalize the login process.
void ParseFinalizeLogIn(void)
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSString* parseUserToken = GetCurrentParseUser().sessionToken;
  [defaults setObject:parseUserToken forKey:PARSE_USER_TOKEN_DEFAULTS_KEY];
  [defaults setBool:YES forKey:PARSE_LOGGED_IN_DEFAULTS_KEY];
}
//__________________________________________________________________________________________________

//! Extract the real Parse error code.
NSInteger ParseExtractErrorCode
(
  NSError* error
)
{
  NSString* errorString = [error.userInfo objectForKey:@"error"];
  NSRange range = [errorString rangeOfString:@",\"data\":"];
  NSLog(@"ParseExtractErrorCode: '%@'", errorString);
  if (range.location == NSNotFound)
  {
    range = [errorString rangeOfString:@",\"Code=\":"];
    if (range.location != NSNotFound)
    {
      range.location += range.length;
      range.length = 5;
    }
    else
    {
      return 0;
    }
  }
  else
  {
    range.location += range.length;
    range.length = 5;
  }
  errorString = [errorString substringWithRange:range];
  return [errorString integerValue];
}
//__________________________________________________________________________________________________

//! Save to Parse storage the specified message.
static void ParseSendMessageBody
(
  Message*              msg,            //!< The message to send.
  NSMutableArray*       snapshotsData,  //!< The array containing the snapshot objects.
  BlockBoolErrorAction  completion      //!< The block to call when the message has been sent.
)
{

  NSLog(@"1 ParseSendMessageBody");
  ParseMessage* parse_message           = [ParseMessage object];
  parse_message.time                    = msg->Timestamp;
  parse_message.texts                   = msg->Texts;
  parse_message.snapshots               = snapshotsData;
  parse_message.fromUser                = msg->FromUser;
  parse_message.toUser                  = msg->ToUser;
  parse_message.action                  = @"";
  parse_message.placeHolder             = msg->placeHolder;
  //    [parse_message pinInBackground];
    NSLog(@"%@", parse_message.placeHolder);
  NSLog(@"2 ParseSendMessageBody");
  [parse_message saveInBackgroundWithBlock:^(BOOL success, NSError* error)
   {
     NSLog(@"3 ParseSendMessageBody");
     [parse_message unpinInBackground];
     if (error == nil)
     {
       NSLog(@"4 ParseSendMessageBody");
       completion(success, error);
     }
     else
     {
       NSLog(@"2 Error: %@ %@", error, [error userInfo]);
       completion(success, error);
     }
     NSLog(@"5 ParseSendMessageBody end");
   }];
  NSLog(@"6 ParseSendMessageBody");
}
//__________________________________________________________________________________________________

//! Save to Parse storage the specified message.
static void ParseSendMessageSnapshots
(
  Message*      msg,        //!< The message to send.
  BlockIdAction completion  //!< The block to call when the message has been sent.
)
{
  NSLog(@"1 ParseSendMessageSnapshots");
  NSMutableArray* snapshotsData = nil;
  if (!IsSimulator())
  {
    __block NSInteger pendingCount = msg->Snapshots.count;
    NSLog(@"2 ParseSendMessageSnapshots");
    snapshotsData = [NSMutableArray arrayWithCapacity:msg->Snapshots.count];
    for (UIImage* image in msg->Snapshots)
    {
      CGFloat jpegCompressionQuality = MIN(0.9, GetGlobalParameters().jpegCompressionQuality);
      NSData* imageData = UIImageJPEGRepresentation(image, jpegCompressionQuality);
      NSLog(@"3 ParseSendMessageSnapshots -> jpeg quality: %6.2f, imageData size: %d bytes", jpegCompressionQuality, (int)imageData.length);
      PFObject* parse_image = [PFObject objectWithClassName:@"Image"];
      parse_image[@"imageData"] = imageData;
      //        [parse_image pinInBackground];
      [parse_image saveInBackgroundWithBlock:^(BOOL success, NSError* error)
      {
        [parse_image unpinInBackground];
        --pendingCount;
        if (pendingCount == 0)
        {
          completion(snapshotsData);
        }
      }];
      [snapshotsData addObject:parse_image];
    }
  }
  else
  {
    completion(snapshotsData);
  }
}
//__________________________________________________________________________________________________

//! Save to Parse storage the specified message.
void ParseSendMessage
(
  Message*              msg,        //!< The message to send. 
  BlockBoolErrorAction  completion  //!< The block to call when the message has been sent.
)
{

  NSLog(@"1 ParseSendMessage start");

    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel track:@"messages sent"];

    [mixpanel identify:mixpanel.distinctId];

    [mixpanel.people increment:@"messages sent" by:[NSNumber numberWithInt:1]];



  if (msg == nil)
  {
    NSLog(@"2 ParseSendMessage");
    completion(NO, [NSError errorWithDomain:@"Typeface" code:-1 userInfo:nil]);
  }
  else
  {
    // Send the message to parse.
    NSLog(@"3 ParseSendMessage");
    ParseSendMessageSnapshots(msg, ^(id snapshotsData)
    {
      ParseSendMessageBody(msg, snapshotsData, completion);
    });
  }
}
//__________________________________________________________________________________________________


//! Delete all the messages with specified from user ids.
void ParseDeleteParseMessagesFromUsers
(
  NSMutableArray* messages,   //!< The message to check for deletion.
  NSMutableArray* fromUserIds //!< The from users to check for message deletion.
)
{
  for (NSInteger i = messages.count - 1; i >= 0; --i)
  {
    ParseMessage* msg = [messages objectAtIndex:i];
    for (NSString* fromUser in fromUserIds)
    {
      if ([fromUser isEqualToString:msg.fromUser.objectId])
      {
        ParseDeleteParseMessage(msg, ^(BOOL value, NSError *error)
        {
        });
        [messages removeObject:msg];
      }
    }
  }
}
//__________________________________________________________________________________________________

//! Delete all the messages from users that are not our friends.
void ParseDeleteMessagesFromNoFriend
(
  UnreadMessages* unreadMsgs  //!< The messages to check for deletion.
)
{
  for (NSInteger i = unreadMsgs->Messages.count - 1; i >= 0; --i)
  {
    Message* msg = [unreadMsgs->Messages objectAtIndex:i];
    if ([GetCurrentParseUser() getFriend:msg->FromObjectId] == nil)
    {
      ParseDeleteMessage(msg, ^(BOOL value, NSError *error)
      {
      });
      [unreadMsgs->Messages removeObject:msg];
    }
  }
}
//__________________________________________________________________________________________________

//! Delete the specified message from Parse storage.
void ParseDeleteParseMessage
(
  ParseMessage*         parseMsg,        //!< The message to delete.
  BlockBoolErrorAction  completion  //!< The block to call when deletion has completed.
)
{
  NSMutableArray* snapshotsData = parseMsg[@"snapshots"];
  for (PFObject* parseImage in snapshotsData)
  {
    [parseImage deleteInBackground];
  }
  [parseMsg deleteInBackgroundWithBlock:^(BOOL succeeded, NSError* error)
  {
      completion(succeeded, error);
  }];
}
//__________________________________________________________________________________________________

//! Delete the specified message from Parse storage.
void ParseDeleteMessage
(
  Message*              msg,        //!< The message to delete.
  BlockBoolErrorAction  completion  //!< The block to call when deletion has completed.
)
{
//  NSLog(@"ParseDeleteMessage start");
  if ((msg == nil) || (msg->ParseObjectId == nil))
  { // The message doesn't exists. This could happen only if this is an outgoing message.
    completion(NO, [NSError errorWithDomain:@"Typeface" code:-5 userInfo:nil]);
  }
  else
  {
    PFQuery* query = [PFQuery queryWithClassName:@"ParseMessage"];
//    NSLog(@"ParseDeleteMessage msg->ParseObjectId: %@", msg->ParseObjectId);
    [query getObjectInBackgroundWithId:msg->ParseObjectId block:^(PFObject* parse_message, NSError* query_error)
    {
      if ((query_error == nil) && (parse_message != nil))
      {
        ParseDeleteParseMessage((ParseMessage*)parse_message, completion);
      }
      else
      {
        completion(NO, query_error);
      }
    }];
  }
}
//__________________________________________________________________________________________________

//! Ask another user to remove the current user from its friends list.
void ParseRemoveFriend
(
  ParseUser*            friendToBeRemovedFrom,  //!< The user to be asked to remove the current user from its friends list.
  BlockBoolErrorAction  completion              //!< The block to call when the message has been sent.
)
{

    NSLog(@"ParseRemoveFriend start");

    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"remove15"ofType:@"aiff"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);

    AudioServicesPlaySystemSound(soundEffect);


    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel track:@"friends removed"];

    [mixpanel identify:mixpanel.distinctId];

    [mixpanel.people increment:@"friends removed" by:[NSNumber numberWithInt:1]];


  // Send the message to parse.
  ParseMessage* parse_message           = [ParseMessage object];
  parse_message.time                    = [[NSDate date] timeIntervalSince1970];
  parse_message.texts                   = @[@""];
  parse_message.snapshots               = nil;
  parse_message.fromUser                = GetCurrentParseUser();
  parse_message.toUser                  = friendToBeRemovedFrom;
  parse_message.action                  = PARSE_REMOVE_FRIEND_ACTION;
  //    [parse_message pinInBackground];
  [parse_message saveInBackgroundWithBlock:^(BOOL save_success, NSError* save_error)
  {
    [parse_message unpinInBackground];
    if (save_error == nil)
    {
      completion(save_success, save_error);
    }
    else
    {
      NSLog(@"2 Error: %@ %@", save_error, [save_error userInfo]);
      completion(save_success, save_error);
    }
    NSLog(@"ParseRemoveFriend end");
  }];
}
//__________________________________________________________________________________________________

static BOOL             Changed;
static NSMutableArray*  FetchedSnapshots          = nil;
static NSInteger        PendingSnapshotQueryCount = 0;
static NSInteger        PendingUserQueryCount     = 0;
static NSInteger        PendingParseMsgCount      = 0;

static void HandleSnapshot(NSArray* objects, PFObject* parseImage, BlockBoolErrorAction completion)
{
  UnreadMessages* unreadMsgs = GetSharedUnreadMessages();
  [FetchedSnapshots addObject:parseImage];
  --PendingSnapshotQueryCount;
  NSLog(@"13 ParseLoadMessageArray: %d, %p, PendingQueryCount: %3d", (int)FetchedSnapshots.count, parseImage, (int)PendingSnapshotQueryCount);
  if (PendingSnapshotQueryCount == 0)
  { // All the existing messages have been loaded. We can now build the snapshot array and notify completion to the caller.
    NSLog(@"14 ParseLoadMessageArray: %d", (int)unreadMsgs->Messages.count);
    for (int i = 0; i < unreadMsgs->Messages.count; ++i)
    {
      ParseMessage* parseMess = [objects              objectAtIndex:i];
      Message*      mess      = [unreadMsgs->Messages objectAtIndex:i];
      NSLog(@"15 ParseLoadMessageArray: %d", (int)parseMess.snapshots.count);
      for (PFObject* parseImg in parseMess.snapshots)
      {
        NSLog(@"16 ParseLoadMessageArray");
        for (PFObject* snap in FetchedSnapshots)
        {
          NSLog(@"16.1 ParseLoadMessageArray");
          if ([snap.objectId isEqualToString:parseImg.objectId])
          {
            NSLog(@"16.2 ParseLoadMessageArray");
            id obj = [snap objectForKey:@"imageData"];
            if (obj != nil)
            {
              NSLog(@"17 ParseLoadMessageArray");
              NSData* imageData = snap[@"imageData"];
              NSLog(@"18 ParseLoadMessageArray imageData size: %d bytes", (int)imageData.length);
              UIImage* image = [UIImage imageWithData:imageData];
              [mess->Snapshots addObject:image];
            }
          }
        }
      }
    }
    [unreadMsgs->Messages sortUsingComparator:^NSComparisonResult(Message* msg1, Message* msg2)
    { // Sort with oldest message first.
//      NSLog(@"18 ParseLoadMessageArray");
      if (msg1->Timestamp < msg2->Timestamp)
      {
        return NSOrderedAscending;
      }
      else if (msg1->Timestamp > msg2->Timestamp)
      {
        return NSOrderedDescending;
      }
      else
      {
        return NSOrderedSame;
      }
    }];
//    NSLog(@"19 ParseLoadMessageArray ---- END ----");
    completion(Changed, nil);
    FetchedSnapshots = nil;
  }
}
//__________________________________________________________________________________________________

//! Load all the unknown users in the unread messages.
void ParseLoadUsersForMessages(UnreadMessages* unreadMsgs, BlockAction completion)
{
  PendingUserQueryCount = 0;
//  NSLog(@"1 ParseLoadUsersForMessages: PendingUserQueryCount: %d", (int)PendingUserQueryCount);
  for (__block Message* msg in unreadMsgs->Messages)
  {
    if (msg->FromUser == nil)
    {
      ++PendingUserQueryCount;
//      NSLog(@"2 ParseLoadUsersForMessages: PendingUserQueryCount: %d", (int)PendingUserQueryCount);
      [ParseUser findUserWithObjectId:msg->FromObjectId completion:^(ParseUser* user, NSError* error)
      {
//        NSLog(@"3 ParseLoadUsersForMessages: PendingUserQueryCount: %d", (int)PendingUserQueryCount);
        msg->FromUser = user;
        if (--PendingUserQueryCount == 0)
        {
//          NSLog(@"4 ParseLoadUsersForMessages: PendingUserQueryCount: %d", (int)PendingUserQueryCount);
          completion();
        }
      }];
    }
    if (msg->ToUser == nil)
    {
      ++PendingUserQueryCount;
//      NSLog(@"5 ParseLoadUsersForMessages: PendingUserQueryCount: %d", (int)PendingUserQueryCount);
      [ParseUser findUserWithObjectId:msg->ToObjectId completion:^(ParseUser* user, NSError* error)
      {
//        NSLog(@"6 ParseLoadUsersForMessages: PendingUserQueryCount: %d", (int)PendingUserQueryCount);
        msg->ToUser = user;
        if (--PendingUserQueryCount == 0)
        {
//          NSLog(@"7 ParseLoadUsersForMessages: PendingUserQueryCount: %d", (int)PendingUserQueryCount);
          completion();
        }
      }];
    }
  }
  if (PendingUserQueryCount == 0)
  {
//    NSLog(@"8 ParseLoadUsersForMessages: PendingUserQueryCount: %d", (int)PendingUserQueryCount);
    completion();
  }
}
//__________________________________________________________________________________________________

//! Load all the unplayed messages for the current user from the Parse storage.
void ParseLoadMessageArray
(
  BlockAction           loadedStartProcessing,  //!< Called once the messages have been loaded and before processing them. Typically used to start an activity indicator.
  BlockBoolErrorAction  completion              //!< The block to call when the messages array has been completely loaded. The BOOL Parameter tells if the array has changed.
)
{
  Changed = NO;
//  NSLog(@"-- ParseLoadMessageArray");
  ParseUser* user = GetCurrentParseUser();
  PFQuery* query = [PFQuery queryWithClassName:@"ParseMessage"];
  [query whereKey:@"toUser" equalTo:user];
  [query orderByAscending:@"time"];
  [query findObjectsInBackgroundWithBlock:^(NSArray* parseMessages, NSError* query_error)
  {
//    NSLog(@"00 ParseLoadMessageArray");
    if (query_error == nil)
    {
//      NSLog(@"01 ParseLoadMessageArray");
      // The find succeeded.
      NSLog(@"Successfully retrieved %d messages.", (int)parseMessages.count);
      LoadUnreadMessages(^(UnreadMessages* unreadMsgs)
      {
        if (parseMessages.count == 0)
        {
//          NSLog(@"02 ParseLoadMessageArray");
          Changed = unreadMsgs->Messages.count > 0;
          [unreadMsgs clear];
          completion(Changed, nil);
        }
        else
        {

            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"new20"ofType:@"aiff"];
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);

            AudioServicesPlaySystemSound(soundEffect);
            
          NSMutableArray* objects = [NSMutableArray arrayWithArray:parseMessages];
          // First process action messages.
          NSMutableArray* removedFriendIds = [NSMutableArray arrayWithCapacity:1];
          for (NSInteger i = objects.count - 1; i >= 0; --i)
          {
              // being add friend
            ParseMessage* parseMsg = objects[i];
              NSArray *friends = [PFUser currentUser][@"friends"];
             // NSLog(@"friends: %@", friends);
              if (![friends containsObject:parseMsg.fromUser])
              {
                  [[PFUser currentUser] addUniqueObject:parseMsg.fromUser.objectId forKey:@"friends"];
              }
             
            if (![parseMsg.action isEqualToString:@""])
            {
              if ([parseMsg.action isEqualToString:PARSE_REMOVE_FRIEND_ACTION])
              { // Remove the sender from the friends list.
                [removedFriendIds addObject:parseMsg.fromUser.objectId];
                [GetCurrentParseUser() removeFriend:(ParseUser*)[parseMsg.fromUser fetchIfNeeded]];
                NSLog(@"friends after delete friend: %@", GetCurrentParseUser().friends);
              }
              // Remove the action message from the message list and from Parse storage.
              [objects removeObject:parseMsg];
              [parseMsg delete];
            }
          }
          // Then, delete messages from removed friends.
          ParseDeleteParseMessagesFromUsers(objects, removedFriendIds);

          PendingSnapshotQueryCount = 0;
          for (ParseMessage* parseMsg in objects)
          {
            PendingSnapshotQueryCount += parseMsg.snapshots.count;
          }
          NSLog(@"03 ParseLoadMessageArray PendingQueryCount: %d", (int)PendingSnapshotQueryCount);
          // Then, look for obsolete messages. May happen if some user removed us as friend.
          for (NSInteger i = unreadMsgs->Messages.count - 1; i >= 0; --i)
          {
            Message* msg = [unreadMsgs->Messages objectAtIndex:i];
            NSLog(@"04 ParseLoadMessageArray: '%@', '%@', %p, %p", msg->FromObjectId, msg->ToObjectId, msg->FromUser, msg->ToUser);
            BOOL found = NO;
            for (ParseMessage* parseMsg in objects)
            {
//              NSLog(@"05 ParseLoadMessageArray '%@', '%@'", msg->ParseObjectId, parseMsg.objectId);
              if ([msg->ParseObjectId isEqualToString:parseMsg.objectId])
              {
//                NSLog(@"06 ParseLoadMessageArray");
                found = YES;
                break;
              }
            }
            if (!found)
            {
//              NSLog(@"07 ParseLoadMessageArray");
              [unreadMsgs->Messages removeObject:msg];
              Changed = YES;
            }
          }

          if (unreadMsgs->Messages.count == objects.count)
          { // The two lists contain the same number of messages, therefore, they are identical. Work is complete.
//            NSLog(@"8.1 ParseLoadMessageArray");
            completion(Changed, nil);
          }
          else
          {
            NSLog(@"08.2 ParseLoadMessageArray");
            loadedStartProcessing();
            PendingSnapshotQueryCount = 0;
            PendingParseMsgCount      = 0;
            // Then, add the missing messages and fetch the related snapshots.
            for (ParseMessage* parseMsg in objects)
            {
//              NSLog(@"08 ParseLoadMessageArray");
              BOOL found = NO;
              for (Message* msg in unreadMsgs->Messages)
              {
//                NSLog(@"09 ParseLoadMessageArray");
                if ([msg->ParseObjectId isEqualToString:parseMsg.objectId])
                {
//                  NSLog(@"10 ParseLoadMessageArray");
                  found = YES;
                  break;
                }
              }
              if (!found)
              {
                ++PendingParseMsgCount;
                Changed = YES;
                NSLog(@"11 ParseLoadMessageArray: %d", (int)parseMsg.snapshots.count);
                FetchedSnapshots    = [NSMutableArray arrayWithCapacity:50];
                Message* msg        = [Message new];
                msg->ToUser         = parseMsg.toUser;
                msg->FromUser       = parseMsg.fromUser;
                msg->Timestamp      = parseMsg.time;
                msg->Texts          = parseMsg.texts;
                msg->ParseObjectId  = parseMsg.objectId;
                msg->FromObjectId   = parseMsg.fromUser.objectId;
                msg->ToObjectId     = parseMsg.toUser.objectId;
                [unreadMsgs->Messages addObject:msg];
                [msg loadUsers:^
                {
                  --PendingParseMsgCount;
                  ParseUser* currentUser = GetCurrentParseUser();
//                  NSLog(@"11.1 ParseLoadMessageArray: %d", (int)parseMsg.snapshots.count);
                  if (![currentUser isFriend:msg->FromUser])
                  {
                    [currentUser addFriend:msg->FromUser completion:^(BOOL value, NSError *error)
                    { // Do nothing;
                    }];
                  }
                  if (parseMsg.snapshots.count > 0)
                  {
                    for (PFObject* parseImage in parseMsg.snapshots)
                    {
                      PendingSnapshotQueryCount++;
//                      NSLog(@"12 ParseLoadMessageArray %@, Count: %d", parseImage.objectId, (int)PendingSnapshotQueryCount);
                      if (parseImage.isDataAvailable)
                      {
//                        NSLog(@"12.2 ParseLoadMessageArray %p", parseImage);
                        HandleSnapshot(objects, parseImage, completion);
                      }
                      else
                      {
//                        NSLog(@"12.3 ParseLoadMessageArray %p", parseImage);
                        [parseImage fetchIfNeededInBackgroundWithBlock:^(PFObject* fetchedImage, NSError* error)
                        {
                          NSLog(@"12.4 ParseLoadMessageArray %p", parseImage);
                          HandleSnapshot(objects, fetchedImage, completion);
                        }];
                      }
                    }
                  }
                  NSLog(@"20 ParseLoadMessageArray PendingParseMsgCount: %d, parseMsg.snapshots.count: %d, PendingSnapshotQueryCount: %d", (int)PendingParseMsgCount, (int)parseMsg.snapshots.count, (int)PendingSnapshotQueryCount);
                  if ((PendingParseMsgCount == 0)  && ((parseMsg.snapshots.count == 0) || (PendingSnapshotQueryCount == 0)))
                  {
                    NSLog(@"20.1 ParseLoadMessageArray ---- END ----");
                    completion(Changed, nil);
                    FetchedSnapshots = nil;
                  }
                }];
              }
            }
            NSLog(@"21 ParseLoadMessageArray Changed: %d", Changed);
            if (!Changed)
            {
              NSLog(@"21.1 ParseLoadMessageArray ---- END ----");
              completion(NO, nil);
              FetchedSnapshots = nil;
            }
          }
        }
      });
    }
    else
    {
      // Log details of the failure
      NSLog(@"Error: %@ %@", query_error, [query_error userInfo]);
      completion(NO, query_error);
    }
  }];
}
//__________________________________________________________________________________________________

//! Start the phone number verification process.
void ParseStartVerification
(
  NSString*             phoneNumber,  //!< The phone number to verify.
  BlockBoolErrorAction  completion    //!< The block to call when the first verification step has completed. Parameter is YES in case of success.
)
{
  [PFCloud callFunctionInBackground:@"sendVerificationCode"
                     withParameters:@{@"phoneNumber": phoneNumber}
                              block:^(NSString* success, NSError* error)
  {
    if (error != nil)
    {
      completion(NO, error);
    }
    else
    {
      completion([success isEqualToString:@"Success"], nil);
    }
  }];
}
//__________________________________________________________________________________________________

//! Complete the phone number verification process.
void ParseCompleteVerification
(
  NSString*             verificationCode, //!< The verification code to validate.
  BlockBoolErrorAction  completion        //!< The block to call when the second verification step has completed. Parameter is YES in case of success.
)
{
  [PFCloud callFunctionInBackground:@"verifyPhoneNumber"
                     withParameters:@{@"phoneVerificationCode": verificationCode}
                              block:^(NSString* success, NSError* error)
   {
     if (error != nil)
     {
       completion(NO, error);
     }
     else
     {
       [GetCurrentParseUser() updateTimestamp:^(BOOL update_success, NSError* update_error)
       {
         completion([success isEqualToString:@"Success"] && update_success, update_error);
       }];
     }
   }];
}
//__________________________________________________________________________________________________

//=============================== Remote Push notifications stuff ==================================

//! Check if remote notifications have been allowed by the user.
BOOL ParseCheckPermissionForRemoteNotifications(void)
{
  NSLog(@"ParseCheckPermissionForRemoteNotifications");
  UIApplication* application = [UIApplication sharedApplication];
  // Get remote notifications types, if running iOS 8.
  if ([application respondsToSelector:@selector(currentUserNotificationSettings)])
  {
    UIUserNotificationSettings* settings = [application currentUserNotificationSettings];
    UIUserNotificationType types = settings.types;
    return (types != UIUserNotificationTypeNone);
  }
  else
  {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    // Get remote notifications types before iOS 8.
    return ([application enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone);
#pragma GCC diagnostic pop
  }
}
//__________________________________________________________________________________________________

//! Register the App for remote notifications.
void ParseRegisterForRemoteNotifications(BlockBoolAction completion)
{
  RegisterCompletionAction = completion;
  NSLog(@"ParseRegisterForRemoteNotifications");
  UIApplication* application = [UIApplication sharedApplication];
  // Register for Push Notitications, if running iOS 8.
  if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
  {
    NSLog(@"Registering for push notifications under iOS 8");
    UIUserNotificationType      userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings* settings              = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
  }
  else
  {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    NSLog(@"Registering for push notifications under iOS 7");
    // Get remote notifications types before iOS 8.
    UIRemoteNotificationType types = [application enabledRemoteNotificationTypes];
    if (types == UIRemoteNotificationTypeNone)
    {
      RegisterCompletionAction(NO);
    }
    // Register for Push Notifications before iOS 8.
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
#pragma GCC diagnostic pop
  }
}
//__________________________________________________________________________________________________

//! Callback after successful registering for remote notifications (< iOS 8).
void ParseDidRegisterForRemoteNotificationsWithDeviceToken(NSData* deviceToken)
{
  NSLog(@"ParseDidRegisterForRemoteNotificationsWithDeviceToken");
  // Store the deviceToken in the current installation and save it to Parse.
  PFInstallation* currentInstallation = [PFInstallation currentInstallation];
  [currentInstallation setDeviceTokenFromData:deviceToken];
  currentInstallation.channels = @[@"global"];
  [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
  [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
  {
//     NSLog(@"succeeded: %d, error: %@", succeeded, error);
  }];
}
//__________________________________________________________________________________________________

//! Callback after failed registering for remote notifications.
void ParseDidFailToRegisterForRemoteNotificationsWithError(NSError* error)
{
  NSLog(@"ParseDidFailToRegisterForRemoteNotificationsWithError: %@", error);
}
//__________________________________________________________________________________________________

//! Callback when receiving a remote notification.
void ParseDidReceiveRemoteNotification(NSDictionary* userInfo)
{

    
    NSLog(@"%@",userInfo);
   
  [PFPush handlePush:userInfo];
}
//__________________________________________________________________________________________________

//! Callback when a remote notification requires an action.
void ParseHandleActionWithIdentifier(NSString* identifier, NSDictionary* userInfo, BlockAction completionHandler)
{
  NSLog(@"ParseHandleActionWithIdentifier");
  completionHandler();
}
//__________________________________________________________________________________________________

//! Callback after successful registering for remote notifications (>= iOS 8).
void ParseDidRegisterUserNotificationSettings(UIUserNotificationSettings* notificationSettings)
{
  UIApplication* application = [UIApplication sharedApplication];
  UIUserNotificationSettings* settings = [application currentUserNotificationSettings];
  UIUserNotificationType types = settings.types;
  RegisterCompletionAction(types != UIUserNotificationTypeNone);
  NSLog(@"ParseDidRegisterUserNotificationSettings: %X", (unsigned int)notificationSettings.types);
}
//__________________________________________________________________________________________________

//! Send a remote notification to the specified user.
void ParseSendPushNotificationToUser(NSString* destUserObjectId, NSString* text)
{
  [ParseUser findUserWithObjectId:destUserObjectId completion:^(ParseUser* user, NSError* error)
  {
    // Find devices associated with the targeted user.
    PFQuery* pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];

    // Prepare the data dictionnary.
    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
                          text, @"alert",
                          @"Increment", @"badge",
                          @"zap_future.aif", @"sound",
                          @"1", @"content-available",
                          nil];

    // Send push notification to query.
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query.
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *sendError)
    {
      NSLog(@"succeeded: %d, error: %@", succeeded, sendError);
    }];
  }];
}
//__________________________________________________________________________________________________

//! Send a silent remote notification to the specified user.
void ParseSendSilentPushNotificationToUser(NSString* destUserObjectId)
{
  [ParseUser findUserWithObjectId:destUserObjectId completion:^(ParseUser* user, NSError* error)
  {
    // Find devices associated with the targeted user.
    PFQuery* pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];

    // Prepare the data dictionnary.
    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"", @"sound",
                          @"1", @"content-available",
                          nil];

    // Send push notification to query.
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query.
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *sendError)
    {
      //      NSLog(@"succeeded: %d, error: %@", succeeded, sendError);
    }];
  }];
}
//__________________________________________________________________________________________________

//! Set the App icon badge number to the specified value.
void ParseSetBadge(NSInteger badgeNumber)
{
//  NSLog(@"1 ParseSetBadge: %d", (int)badgeNumber);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
    PFInstallation* currentInstallation = [PFInstallation currentInstallation];
    if (badgeNumber == 0 )
    {
        currentInstallation.badge = 0;
    }
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    { // Use the block version of the saveInBackground call is a workaround for a Parse bug.
    }];
    NSLog(@"Old badge bumber: %ld", (long)badgeNumber);
    NSLog(@"New badge bumber: %ld", (long)currentInstallation.badge);
  if (currentInstallation.badge != badgeNumber)
  {
//    NSLog(@"2 ParseSetBadge: %d, %d", (int)currentInstallation.badge, (int)badgeNumber);
    currentInstallation.badge = badgeNumber;
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    { // Use the block version of the saveInBackground call is a workaround for a Parse bug.
    }];
  }
}
//__________________________________________________________________________________________________

//! Clear the App icon badge number.
void ParseClearBadge(void)
{
  ParseSetBadge(0);
}
//__________________________________________________________________________________________________
