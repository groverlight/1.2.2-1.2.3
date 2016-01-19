
//! \file   ParseMessage.h
//! \brief  Parse class containing data about a message object.
//__________________________________________________________________________________________________

#import <Parse/Parse.h>

#import "Blocks.h"
#import "ParseUser.h"
//__________________________________________________________________________________________________

//! Parse class containing data about a message object.
@interface ParseMessage : PFObject<PFSubclassing>
{
}
//____________________

@property NSTimeInterval  time;                   //!< The timestamp associated with this message.
@property NSArray*        texts;                  //!< The texts to display in this message.
@property NSArray*        snapshots;              //!< The photo snapshots linked to this message.
@property ParseUser*      fromUser;               //!< The user who sent this message.
@property ParseUser*      toUser;                 //!< The user to which this message is sent.
@property NSString*       action;                 //!< Command to execute special action, ie: @"removeFriend" to remove the sender from the friend list.
@property NSString*       placeHolder;
//____________________

//! Request the list of all unplayed messages for the current user.
+ (void)QueryUnplayedMessagesWithCompletion:(BlockArrayErrorAction)completion;
//____________________

@end
//__________________________________________________________________________________________________
