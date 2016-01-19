
//! \file   FriendListItemStateView.m
//! \brief  View that display the current friend list item state.
//__________________________________________________________________________________________________

#import "ThreeDotsPseudoButtonView.h"
#import "Colors.h"
#import "GlobalParameters.h"
#import "Interpolation.h"
#import "PopBaseView.h"
//__________________________________________________________________________________________________

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN float UIAnimationDragCoefficient(); // UIKit private drag coeffient, use judiciously!
#endif

CGFloat AnimationDragCoefficient(void)
{
#if TARGET_IPHONE_SIMULATOR
  float k = UIAnimationDragCoefficient();
  return k;
#else
  return 1.0;
#endif
}
//__________________________________________________________________________________________________

//! View that display the current friend list item state.
@interface PseudoButtonView() <POPAnimationDelegate>
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! View that display the current friend list item state.
@implementation PseudoButtonView
{
  BlockIdAction         ProgressAnimationCompleted; //!< The block to call when the progress animation has completed.
  UIColor*              StartProgressValue;
  UIColor*              EndProgressValue;
  FriendProgressStates  CurrentState;
  CGFloat               ProgressAnimDuration;       //!< Copy of the original progress animation duration.
  UIColor*              TransparentColor;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  self.userInteractionEnabled = NO;
  CurrentState                = E_FriendProgressState_Blank;
  UseBlankState               = YES;
  AnimationDone = ^
  { // Default action: do nothing!
  };
  super.animationCompleted = ^(id obj)
  {
    ProgressAnimationCompleted(obj);
  };
}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self cleanup];
}
//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________

- (void)setAnimationCompleted:(BlockIdAction)animationCompleted
{
  ProgressAnimationCompleted = animationCompleted;
}
//__________________________________________________________________________________________________

- (BlockIdAction)animationCompleted
{
  return ProgressAnimationCompleted;
}
//__________________________________________________________________________________________________

- (void)setProgressValue:(CGFloat)progressValue
{
}
//__________________________________________________________________________________________________

- (CGFloat)progressValue
{
  return 0.0;
}
//__________________________________________________________________________________________________

- (void)setState:(FriendProgressStates)state
{
  if (UseBlankState && (state == E_FriendProgressState_Unselected))
  {
    state = E_FriendProgressState_Blank;
  }
  CurrentState = state;
}
//__________________________________________________________________________________________________

- (FriendProgressStates)state
{
  return CurrentState;
}
//__________________________________________________________________________________________________

- (void)setState:(FriendProgressStates)state animated:(BOOL)animated
{
  if (UseBlankState && (state == E_FriendProgressState_Unselected))
  {
    state = E_FriendProgressState_Blank;
  }
  if (animated)
  {
    [self animateToState:state completion:^
    {
    }];
  }
  else
  {
    [self setState:state];
  }
}
//__________________________________________________________________________________________________

- (void)animateToState:(FriendProgressStates)state completion:(BlockAction)completionAction
{
  [self stopAnimation];
  CurrentState = state;
  self.animationValue = 0.0;
  [self animateToValue:1.0 animateStep:^(CGFloat parameterValue)
  {
    [self stateAnimationStep:parameterValue];
  } completion:^
  {
    completionAction();
//    NSLog(@"animateToState completed!");
  }];
}
//__________________________________________________________________________________________________

- (void)stateAnimationStep:(CGFloat)animationValue
{
}
//__________________________________________________________________________________________________

- (void)cancelAnimation
{
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________

