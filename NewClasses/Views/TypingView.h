
//! \file   TypingView.h
//! \brief  UIView based class that contains an editor to create the falling texts.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Message.h"
#import "ViewStackView.h"
#import "EditView.h"
//__________________________________________________________________________________________________

//! UIView based class that contains an editor to create the falling texts.
@interface TypingView : BaseView
{
@public
  BlockAction           GoButtonPressed;
  BlockFloatBlockAction PleaseFlashForDuration;
  EditView*             TextView; 
}
//____________________

@property (readonly)  NSMutableArray* snapshots;          //!< The array that contains the snapshots for the currently edited text.
@property (readonly)  NSArray*        textRecords;        //!< Array of the edited texts;
@property             NSInteger       numUnreadMessages;
//____________________

//! Clear the editing string.
- (void)clearText;
//____________________

//! Build a message from currently edited texts and snapshots.
- (Message*)buildTheMessage;
- (void)registerForKeyboardNotifications;
- (void)reset;
//____________________

@end
//__________________________________________________________________________________________________
