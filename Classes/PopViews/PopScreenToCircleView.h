
//! \file   PopScreenToCircleView.h
//! \brief  Class that handle a POP animations between a full screen view and a circled view.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "CameraPreview.h"
#import "Blocks.h"
#import "PopParametricAnimationView.h"
//__________________________________________________________________________________________________

#define kPopScreenToCircleAnimation @"PopScreenToCircleAnimation" //!< ScreenToCircle animation id.
//__________________________________________________________________________________________________

//! Class that handle a POP animations between a full screen view and a circled view.
@interface PopScreenToCircleView : PopParametricAnimationView
{
}
//____________________

@property CGFloat circleRadius; //!< Circle radius when in circle state.
@property CGPoint circleCenter; //!< Circle center when in circle state.
//____________________

@property UIView* contentView; //!< The animation content view.
//____________________

//! Animate to fill the whole screen.
- (void)animateToScreenWithCompletion:(BlockIdAction)completion;
//____________________

//! Animate to reduce in a circle.
- (void)animateToCircleWithCompletion:(BlockIdAction)completion;
//____________________

@end
//__________________________________________________________________________________________________

