
//! \file   ParseBlocked.h
//! \brief  Parse class containing data about a blocked user object.
//__________________________________________________________________________________________________

#import <Parse/Parse.h>

#import "Blocks.h"
#import "ParseUser.h"
//__________________________________________________________________________________________________

@class ParseBlocked;
//__________________________________________________________________________________________________

//! Type definition for blocks with 2 parameters, one ParseBlocked parameter and one NSError parameter.
typedef void (^BlockBlockedErrorAction)(ParseBlocked* blocked, NSError* error);
//__________________________________________________________________________________________________

//! Parse class containing data about a blocked user object.
@interface ParseBlocked : PFObject<PFSubclassing>
{
}
//____________________

@property NSString*   blockId;        //!< The ID of this block object.
@property NSString*   blockType;      //!< The type of blocking ("user" or "system").
@property ParseUser*  blockedUser;    //!< The user who is blocked.
@property NSInteger   blockedNumber;  //!< The number of this blocking object.
@property ParseUser*  blocker;        //!< The user that initiated this blocking object. Ignored if blockType is "system".
@property NSString*   reason;         //!< A string that explains the reason of the blocking.
//____________________

//! Add a friend to the blocked list.
+ (void)blockAFriend:(ParseUser*)friendToBlock
           forReason:(NSString*)reason
          completion:(BlockBoolErrorAction)completion;
//____________________

//! Remove a friend from the blocked list.
+ (void)unblockAFriend:(ParseUser*)blockedFriend
            completion:(BlockBoolErrorAction)completion;
//____________________

//! Check if a friend is blocked.
+ (void)isFriendBlocked:(ParseUser*)blockedFriend
             completion:(BlockBlockedErrorAction)completion;
//____________________

//! Check if a user is blocked.
+ (void)isUserBlocked:(ParseUser*)userToCheck
           completion:(BlockBlockedErrorAction)completion;
//____________________

//! Check if the current user is blocked by the specified user.
+ (void)didUserBlockedMe:(ParseUser*)userToCheck
           completion:(BlockBlockedErrorAction)completion;
//____________________

//! Load the list of users blocked by the specified user or by the system.
+ (void)loadBlockedUserList:(ParseUser*)blockingUser
                 completion:(BlockArrayErrorAction)completion;
//____________________

//! Load the list of users blocking the specified user.
+ (void)loadBlockingUserList:(ParseUser*)blockedUser
                  completion:(BlockArrayErrorAction)completion;
//____________________

@end
//__________________________________________________________________________________________________

BOOL IsUserBlocked(ParseUser* user, NSArray* blockedUsers);
//__________________________________________________________________________________________________

BOOL IsUserBlocking(ParseUser* user, NSArray* blockingUsers);
//__________________________________________________________________________________________________
