
//! \file   FriendListItemStateView.h
//! \brief  View that display the current friend list item state.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "CameraPreview.h"
#import "Blocks.h"
#import "PseudoButtonView.h"
//__________________________________________________________________________________________________

//! View that display the current friend list item state.
@interface FriendListItemStateView : PseudoButtonView
{

}
//____________________
- (void)setState:(FriendProgressStates)state;

@end
//__________________________________________________________________________________________________

