
//! \file   PopBaseView.h
//! \brief  Base for all Pop based classes.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>

#import "POP.h"
#import "POPCGUtils.h"

#import "BaseView.h"
#import "Blocks.h"
//__________________________________________________________________________________________________

#define kPopViewScaleAnimation                @"kPopViewScaleAnimation"               //!< Scale animation id.
#define kPopViewParamScaleAnimation           @"kPopViewParamScaleAnimation"          //!< Parameters based scale animation id.
#define kPopViewTransformAnimation            @"kPopViewTransformAnimation"           //!< Transform animation id.
#define kPopViewRotateTransformAnimation      @"kPopViewRotateTransformAnimation"     //!< Rotation transform animation id.
#define kPopViewScaleTransformAnimation       @"kPopViewScaleTransformAnimation"      //!< Scale transform animation id.
#define kPopViewTranslateTransformAnimation   @"kPopViewTranslateTransformAnimation"  //!< Translation transform animation id.
#define kPopCornerRadiusAnimation             @"kPopCornerRadiusAnimation"            //!< Corner radius animation id.
#define kPopPositionAnimation                 @"kPopPositionAnimation"                //!< View origin animation id.
#define kPopSizeAnimation                     @"kPopSizeAnimation"                    //!< View size animation id.
#define kPopFrameAnimation                    @"kPopFrameAnimation"                   //!< View frame animation id.
//__________________________________________________________________________________________________

//! Enumeration states for button emulating POP views.
typedef enum
{
  E_PopViewState_Invalid,           //!< The view is in an invalid state, could be initial state.
  E_PopViewState_Disabled,          //!< The view is disabled.
  E_PopViewState_Idle,              //!< The view is in the idle state.
  E_PopViewState_Highlighted,       //!< The view is highlighted.
  E_PopViewState_BounceToSelected,  //!< The view is in the selected state.
  E_PopViewState_Selected,          //!< The view is in the selected state.
  N_PopViewStates                   //!< Number of POP states.
} PopViewState;
//__________________________________________________________________________________________________

//!< Enumeration of the animation styles.
typedef enum
{
  E_PopAnimationStyle_Basic,    //!< Basic pop animation style.
  E_PopAnimationStyle_Spring,   //!< Spring pop animation style.
  E_PopAnimationStyle_Decay,    //!< Decay pop animation style.
  E_PopAnimationStyle_Linear,   //!< Linear variant of the Basic pop animation style.
//  E_PopAnimationStyle_Custom,
  N_PopAnimationStyles          //!< Number of animation styles.
} PopAnimationStyle;
//__________________________________________________________________________________________________

//! The parameters that define the animation.
@interface PopAnimParameters: NSObject
{
}
//____________________

@property PopAnimationStyle       animationStyle;   //!< The animation style.
// Common parameters.
@property CGFloat                 velocity;         //!< Velocity animation parameter. Used for spring and decay animation.
// Basic animation parameters.
@property CGFloat                 duration;         //!< Duration animation parameter.
@property CAMediaTimingFunction*  timingFunction;   //!< Timing function for basic animations.
// Spring animation parameters.
@property CGFloat                 bounciness;       //!< Bounciness animation parameter.
@property CGFloat                 springSpeed;      //!< Spring speed animation parameter.
@property CGFloat                 dynamicsTension;  //!< Dynamics tension animation parameter.
@property CGFloat                 dynamicsFriction; //!< Dynamics friction animation parameter.
@property CGFloat                 dynamicsMass;     //!< Dynamics mass animation parameter.
// Decay animation parameters.
@property CGFloat                 deceleration;     //!< Deceleration animation parameter.
//____________________

//! Get a copy of the current anim parameters.
- (instancetype)copy;
//____________________

@end
//==================================================================================================

//! Base for all Pop based view classes.
@interface PopBaseView : BaseView <POPAnimationDelegate>
{
@public
  BOOL      UseFontAnimation;       //!< YES if fonts are animated using font size instead of scale.
  BOOL      WasAnimating;           //!< YES if the animation has just ended.
  NSInteger NumAnimationInProgress; //!< Number of animations currently in progress.
  UIView*   AnimatedView;           //!< The view that will be animated.
}
//____________________

@property BlockIdAction animationCompleted;       //!< Block called when the animation has completed.
@property UIColor*      animatedBackgroundColor;  //!< background color of the animated view.
//____________________

//! Create a pop animation object with the specified animation style.
- (POPPropertyAnimation*)CreateAnimationWithStyle:(PopAnimationStyle)style;
//____________________

//! Set the view scale using the specified animation parameters.
- (void)setViewScale:(CGSize)scale
          parameters:(PopAnimParameters*)parameters
          completion:(BlockAction)completion;
//____________________

//! Set the view scale using basic animation. If duration == 0, no animation.
- (void)setViewScale:(CGSize)scale
  basicAnimateDuring:(CGFloat)seconds;
//____________________

//! Set the view scale using spring animation.
- (void)setViewScale:(CGSize)scale
springAnimateWithBounciness:(CGFloat)bounciness
         andVelocity:(CGFloat)velocity;
//____________________

//! Set the view scale using decay animation.
- (void)setViewScale:(CGSize)scale
decayAnimateWithDeceleration:(CGFloat)deceleration
         andVelocity:(CGFloat)velocity;
//____________________

//! Set the view transform using basic animation. If duration == 0, no animation.
- (void)setViewScale:(CGSize)scale
            rotation:(CGFloat)angle
         translation:(CGSize)translation
  basicAnimateDuring:(CGFloat)seconds;
//____________________

//! Set the view transform using spring animation.
- (void)setViewScale:(CGSize)scale
            rotation:(CGFloat)angle
         translation:(CGSize)translation
  springAnimateWithBounciness:(CGFloat)bounciness
                  andVelocity:(CGFloat)velocity;
//____________________

//! Set the view transform using decay animation.
- (void)setViewScale:(CGSize)scale
            rotation:(CGFloat)angle
         translation:(CGSize)translation
  decayAnimateWithDeceleration:(CGFloat)deceleration
                   andVelocity:(CGFloat)velocity;
//____________________

//! Set the view corner radius using basic animation. If duration == 0, no animation.
- (void)setCornerRadius:(CGFloat)cornerRadius basicAnimateDuring:(CGFloat)seconds;
//____________________

//! Set the view corner radius using spring animation. If velocity == 0, no animation.
- (void)setCornerRadius:(CGFloat)cornerRadius springAnimateWithBounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity;
//____________________

//! Set the view corner radius using decay animation. If velocity == 0, no animation.
- (void)setCornerRadius:(CGFloat)cornerRadius decayAnimateWithDeceleration:(CGFloat)bounciness andVelocity:(CGFloat)velocity;
//____________________

//! Set the view frame using basic animation. If duration == 0, no animation.
- (void)setViewFrame:(CGRect)frame basicAnimateDuring:(CGFloat)seconds;
//____________________

//! Set the bounds frame using spring animation. If velocity == 0, no animation.
- (void)setViewFrame:(CGRect)frame springAnimateWithBounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity;
//____________________

//! Set the view frame using decay animation. If velocity == 0, no animation.
- (void)setViewFrame:(CGRect)frame decayAnimateWithDeceleration:(CGFloat)bounciness andVelocity:(CGFloat)velocity;
//____________________

//! Stop the transform animations.
- (void)stopTransformAnimation;
//____________________

//! Stop the corner radius animation.
- (void)stopCornerRadiusAnimation;
//____________________

@end
//__________________________________________________________________________________________________
