
//! \file   ParseUser.h
//! \brief  Parse class containing data about an user object.
//__________________________________________________________________________________________________

#import <Parse/Parse.h>
#import "Blocks.h"
//__________________________________________________________________________________________________

@class ParseUser;
//__________________________________________________________________________________________________

typedef void (^BlockArrayErrorAction)(NSArray* array, NSError* error);                                    //!< Type definition for blocks with 2 parameters, one NSArray parameter and one NSError parameter.
typedef void (^BlockUserErrorAction)(ParseUser* user, NSError* error);                                    //!< Type definition for blocks with 2 parameters, one ParseUser parameter and one NSError parameter.
typedef void (^InitializationBlockAction)(ParseUser* user, BOOL successed, BOOL restart, NSError* error); //!< Type definition for blocks with 3 parameters, one ParseUser parameter, two BOOL parameters and one NSError parameter.
//__________________________________________________________________________________________________

//! Parse class containing data about an user object.
@interface ParseUser : PFUser
{
}
//____________________

@property NSString*       fullName;               //!< The full name of this user.
@property NSString*       phoneNumber;            //!< The phone number sssociated with this user.
@property NSTimeInterval  lastActivityTimestamp;  //!< The time of the last activity for this user.
@property NSArray*        friends;                //!< The list of friends of this user.

//____________________

//! Retrieve an user object given its objectId.
+ (void)findUserWithObjectId:(NSString*)objectId completion:(BlockUserErrorAction)completion;
//____________________

//! Retrieve all user objects given an username. The returned array should only contain a single element.
+ (void)findUsersWithUsername:(NSString*)username completion:(BlockArrayErrorAction)completion;
//____________________

//! Retrieve all user objects whose username starts with the specified string.
+ (void)findUsersWithUsernameStartingWith:(NSString*)string completion:(BlockArrayErrorAction)completion;
//____________________

//! Retrieve all user objects given a phone number. The returned array should only contain a single element.
+ (void)findUsersWithPhoneNumber:(NSString*)phoneNumber completion:(BlockArrayErrorAction)completion;
//____________________

//! Check the existence of a user with the specified username.
+ (void)testUserExistenceWithUsername:(NSString*)username completion:(BlockBoolErrorAction)completion;
//____________________

//! Check the existence of a user with the specified phone number.
+ (void)testUserExistenceWithPhoneNumber:(NSString*)phoneNumber completion:(BlockBoolErrorAction)completion;
//____________________

//! Signs up the user asynchronously. Make sure that password and username are set. This will also enforce that the username isn’t already taken. This will also cache the user locally so that calls to currentUser will use the latest logged in user.
+ (void)signUp:(NSString*)username password:(NSString*)password completion:(BlockBoolErrorAction)completion;
//____________________

//! Update the last activity timestamp of the user.
- (void)updateTimestamp:(BlockBoolErrorAction)completion;
//____________________

//! Load the friends list.
- (void)loadFriendsListWithCompletion:(BlockArrayErrorAction)completion;
//____________________

//! Retrieve the friends list from memory.
- (NSArray*)getFriendsList;
//____________________

//! Retrieve a loaded friend.
- (ParseUser*)getFriend:(NSString*)friendObjectId;
//____________________

//! Add a new friend to the friends list. Do nothing if the friend is already in the list.
- (void)addFriend:(ParseUser*)newFriend completion:(BlockBoolErrorAction)completion;
//____________________

//! Asynchronously remove a friend from the friends list.
- (void)removeFriend:(ParseUser*)friend completion:(BlockBoolErrorAction)completion;
//____________________

//! Synchronously remove a friend from the friends list.
- (void)removeFriend:(ParseUser*)friend;
//____________________

//! Test if a user is a friend.
- (BOOL)isFriend:(ParseUser*)user;
//____________________

@end
//__________________________________________________________________________________________________

ParseUser* GetCurrentParseUser(void);
//__________________________________________________________________________________________________

//! Get the shared (singleton) friends list object.
NSMutableArray* GetSharedFriendsList(void);
//__________________________________________________________________________________________________
