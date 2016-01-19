
//! \file   FriendRecord.h
//! \brief  A class that manages lists of friend records.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Blocks.h"
#import "UnreadMessages.h"
//__________________________________________________________________________________________________

@class ParseUser;
//__________________________________________________________________________________________________

@interface FriendRecord : NSObject <NSCoding>
{
}
//____________________

@property ParseUser*      user;
@property NSString*       objectId;
@property NSString*       fullName;
@property NSString*       phoneNumber;
@property NSArray*        PFArray;
@property NSTimeInterval  lastActivityTime;
@property NSInteger       numUnreadMessages;
//____________________

- (instancetype)initWithUser:(ParseUser*)user andTime:(NSTimeInterval)time; 
//____________________

@end
//==================================================================================================

//! Add a friendRecord in the Activity and SendTo lists if not currently present. Update the list otherwise.
void UpdateFriendRecordListForUser(ParseUser* user, NSTimeInterval time);
void UpdateFriendRecordListForRecord(FriendRecord* user, NSTimeInterval time);
//__________________________________________________________________________________________________

//! Add friendRecord entries in the Activity and SendTo lists for the specified messages.
void UpdateFriendRecordListForMessages(UnreadMessages* messages, BlockBoolAction completion);
//__________________________________________________________________________________________________

//! Update the friendRecord entries for users that are added to or removed from all lists.
void UpdateFriendRecordListForFriends(NSArray* friends);
//__________________________________________________________________________________________________

//! Return the list of time sorted friendRecords.
NSArray* GetTimeSortedFriendRecords(void);
//__________________________________________________________________________________________________

//! Return the list of name sorted friendRecords.
NSArray* GetNameSortedFriendRecords(void);
//__________________________________________________________________________________________________

//! Refresh the list of friends to be displayed in all lists.
void RefreshAllFriends(BlockAction completion);
//__________________________________________________________________________________________________
