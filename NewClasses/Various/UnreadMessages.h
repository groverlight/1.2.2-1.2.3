
//! \file   UnreadMessages.h
//! \brief  The class that contains all the currently unread messages.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Blocks.h"
//__________________________________________________________________________________________________

@class Message;
@class ParseUser;
//__________________________________________________________________________________________________

//! The class that contains all the currently unread messages.
@interface UnreadMessages: NSObject
{
@public
  NSMutableArray* Messages; //!< The array of unread messages.
}
//____________________

- (void)clear;
//____________________

- (void)load:(BlockAction)completion;
//____________________

- (Message*)getFirstMessageFromUser:(ParseUser*)fromUser;
//____________________

- (void)deleteMessage:(Message*)msg;
//____________________

@end
//__________________________________________________________________________________________________

//! Get the shared (singleton) UnreadMessages object.
UnreadMessages* GetSharedUnreadMessages(void);
//__________________________________________________________________________________________________

//! Get the shared (singleton) UnreadMessages object, wait until loaded.
void LoadUnreadMessages(BlockIdAction unreadMessages);
//__________________________________________________________________________________________________

void LocallySaveMessageArray(void);
//__________________________________________________________________________________________________
