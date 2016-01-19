
//! \file   PseudoButtonView.h
//! \brief  View that is the base for the pseudo buttons.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "CameraPreview.h"
#import "Blocks.h"
#import "PopParametricAnimationView.h"
//__________________________________________________________________________________________________

//! The various possible states of the pseudo button objects.
typedef enum
{
  E_FriendProgressState_Blank,
  E_FriendProgressState_Unselected,
  E_FriendProgressState_Selected,
  E_FriendProgressState_InProgress,
  E_NumFriendProgressStates
} FriendProgressStates;
//__________________________________________________________________________________________________

//! View that display the current friend list item state.
@interface PseudoButtonView : PopParametricAnimationView
{
@public
  BlockAction AnimationDone;
  BOOL        UseBlankState;
}
//____________________

@property             FriendProgressStates  state;            //!< The current state.
@property             CGFloat               progressDuration; //!< The duration of the progress animation.
@property (readonly)  CGFloat               progressValue;    //!< The current progress value.
//____________________

- (void)setState:(FriendProgressStates)state animated:(BOOL)animated;
//____________________

- (void)animateToState:(FriendProgressStates)state completion:(BlockAction)completionAction;
//____________________

- (void)cancelAnimation;
//____________________

@end
//__________________________________________________________________________________________________

CGFloat AnimationDragCoefficient(void);
//__________________________________________________________________________________________________
