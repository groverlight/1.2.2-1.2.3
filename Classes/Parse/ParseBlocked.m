
//! \file   ParseBlocked.m
//! \brief  Parse class containing data about a blocked user object.
//__________________________________________________________________________________________________

#import <Parse/PFObject+Subclass.h>

#import "ParseBlocked.h"
//__________________________________________________________________________________________________

//! Parse class containing data about a blocked user object.
@implementation ParseBlocked
{
}
@dynamic blockId;
@dynamic blockType;
@dynamic blockedUser;
@dynamic blockedNumber;
@dynamic blocker;
@dynamic reason;
//____________________

+ (void)load
{
  [self registerSubclass];
}
//__________________________________________________________________________________________________

//! Get the Parse class name.
+ (NSString *)parseClassName
{
  return @"ParseBlocked";
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

//! Add a friend to the blocked list.
+ (void)blockAFriend:(ParseUser*)friendToBlock forReason:(NSString*)reason completion:(BlockBoolErrorAction)completion
{
  [ParseBlocked isFriendBlocked:friendToBlock completion:^(ParseBlocked* blocked, NSError* error)
  {
    if (blocked == nil)
    {
      [PFCloud callFunctionInBackground:@"blockAFriend"
                         withParameters:@{@"blockedUser": friendToBlock.objectId, @"blocker": GetCurrentParseUser().objectId, @"reason": reason, @"blockType": @"user"}
                                  block:^(NSString* success, NSError* blockError)
       {
         completion([success isEqualToString:@"Success"], nil);
       }];
    }
    else
    {
      completion(NO, error);
    }
  }];
}
//__________________________________________________________________________________________________

//! Remove a friend from the blocked list.
+ (void)unblockAFriend:(ParseUser*)blockedFriend completion:(BlockBoolErrorAction)completion
{
  [PFCloud callFunctionInBackground:@"unblockAFriend"
                     withParameters:@{@"blockedUser": blockedFriend.objectId, @"blocker": GetCurrentParseUser().objectId}
                              block:^(NSString* success, NSError* error)
  {
    completion([success isEqualToString:@"Success"], nil);
  }];
}
//__________________________________________________________________________________________________

//! Check if a friend is blocked.
+ (void)isFriendBlocked:(ParseUser*)blockedFriend completion:(BlockBlockedErrorAction)completion
{
  PFQuery* query = [ParseBlocked query];
  [query whereKey:@"blockedUser"  equalTo:blockedFriend];
  [query whereKey:@"blocker"      equalTo:GetCurrentParseUser()];
  [query findObjectsInBackgroundWithBlock:^(NSArray* blocked, NSError *error)
  {
#if 0
    NSLog(@"Num blocked records for this friend: %d", (int)blocked.count);
    for (PFObject* obj in blocked)
    {
      NSLog(@"Obj: %@", obj);
    }
#endif
    completion((blocked.count == 0)? nil: [blocked objectAtIndex:0], error);
  }];
}
//__________________________________________________________________________________________________

//! Check if a user is blocked.
+ (void)isUserBlocked:(ParseUser*)userToCheck
           completion:(BlockBlockedErrorAction)completion
{
  PFQuery* query = [ParseBlocked query];
  [query whereKey:@"blockedUser" equalTo:userToCheck];
  [query findObjectsInBackgroundWithBlock:^(NSArray* blocked, NSError *error)
  {
#if 0
    NSLog(@"Num blocked records for this user: %d", (int)blocked.count);
    for (PFObject* obj in blocked)
    {
      NSLog(@"Obj: %@", obj);
    }
#endif
    completion((blocked.count == 0)? nil: [blocked objectAtIndex:0], error);
  }];
}
//__________________________________________________________________________________________________

//! Check if the current user is blocked by the specified user.
+ (void)didUserBlockedMe:(ParseUser*)userToCheck
              completion:(BlockBlockedErrorAction)completion
{
  PFQuery* query = [ParseBlocked query];
  [query whereKey:@"blockType"    equalTo:@"user"];
  [query whereKey:@"blockedUser"  equalTo:GetCurrentParseUser()];
  [query whereKey:@"blocker"      equalTo:userToCheck];
  [query findObjectsInBackgroundWithBlock:^(NSArray* blocked, NSError *error)
  {
#if 0
    NSLog(@"Num blocked records for this user: %d", (int)blocked.count);
    for (PFObject* obj in blocked)
    {
      NSLog(@"Obj: %@", obj);
    }
#endif
    completion((blocked.count == 0)? nil: [blocked objectAtIndex:0], error);
  }];
}
//__________________________________________________________________________________________________

//! Load the list of users blocked by the specified user or by the system.
+ (void)loadBlockedUserList:(ParseUser*)blockingUser
                 completion:(BlockArrayErrorAction)completion
{
  PFQuery* userQuery = [ParseBlocked query];
  [userQuery whereKey:@"blockType"  equalTo:@"user"];
  [userQuery whereKey:@"blocker"    equalTo:blockingUser];
  [userQuery findObjectsInBackgroundWithBlock:^(NSArray* userBlocked, NSError* userError)
  {
    PFQuery* systemQuery = [ParseBlocked query];
    [systemQuery whereKey:@"blockType" notEqualTo:@"user"];
    [systemQuery findObjectsInBackgroundWithBlock:^(NSArray* systemBlocked, NSError* systemError)
    {
      NSArray* blocked;
      if ((userBlocked == nil) && (systemBlocked == nil))
      {
        blocked = @[];
      }
      else if (userBlocked == nil)
      {
        blocked = systemBlocked;
      }
      else if (systemBlocked == nil)
      {
        blocked = userBlocked;
      }
      else
      {
        blocked = [userBlocked arrayByAddingObjectsFromArray:systemBlocked];
      }
#if 0
      NSLog(@"Num blocked records for this friend: %d", (int)blocked.count);
      for (PFObject* obj in blocked)
      {
        NSLog(@"Obj: %@", obj);
      }
#endif
      NSError* error = (userError != nil)? userError: (systemError != nil)? systemError: nil;
      completion(blocked, error);
    }];
  }];
}
//__________________________________________________________________________________________________

//! Load the list of users blocking the specified user.
+ (void)loadBlockingUserList:(ParseUser*)blockedUser
                  completion:(BlockArrayErrorAction)completion
{
  PFQuery* userQuery = [ParseBlocked query];
  [userQuery whereKey:@"blockType"    equalTo:@"user"];
  [userQuery whereKey:@"blockedUser"  equalTo:blockedUser];
  [userQuery findObjectsInBackgroundWithBlock:^(NSArray* blocked, NSError* error)
  {
#if 0
    NSLog(@"Num blocking records for this user: %d", (int)blocked.count);
    for (PFObject* obj in blocked)
    {
      NSLog(@"Obj: %@", obj);
    }
#endif
    completion(blocked, error);
  }];
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________

BOOL IsUserBlocked(ParseUser* user, NSArray* blockedUsers)
{
  for (ParseBlocked* blocked in blockedUsers)
  {
    if ([blocked.blockedUser.objectId isEqualToString:user.objectId])
    {
      return YES;
    }
  }
  return NO;
}
//__________________________________________________________________________________________________

BOOL IsUserBlocking(ParseUser* user, NSArray* blockingUsers)
{
  for (ParseBlocked* blocked in blockingUsers)
  {
    if ([blocked.blocker.objectId isEqualToString:user.objectId])
    {
      return YES;
    }
  }
  return NO;
}
//__________________________________________________________________________________________________
