
//! \file   PopParametricAnimationView.h
//! \brief  Base class that handle POP animated views using a generic parameter.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>

#import "Blocks.h"
#import "PopBaseView.h"
//__________________________________________________________________________________________________

#define kPopParametricAnimation @"PopParametricAnimation" //!< Parametric animation id.
//__________________________________________________________________________________________________

//! Base class that handle POP animated views using a generic parameter.
@interface PopParametricAnimationView : PopBaseView
{
}
//____________________

@property PopAnimParameters*      animParameters; //!< The animation parameters.

#if 0
// basic animation parameters.
@property CGFloat                 duration;       //!< Duration animation parameter.
@property CAMediaTimingFunction*  timingFunction; //!< Timing function for basic animations.
//____________________

// Spring animation parameters.
@property CGFloat bounciness;       //!< Bounciness animation parameter.
@property CGFloat velocity;         //!< Velocity animation parameter. Also used for decay animation.
@property CGFloat springSpeed;      //!< Sping speed animation parameter.
@property CGFloat dynamicsTension;  //!< Dynamics tension animation parameter.
@property CGFloat dynamicsFriction; //!< Dynamics friction animation parameter.
@property CGFloat dynamicsMass;     //!< Dynamics mass animation parameter.
//____________________

// Decay animation parameters.
@property CGFloat deceleration;     //!< Deceleration animation parameter.
//____________________
#endif

@property CGFloat animationValue;   //!< The current animation parameter value.
//____________________

//! Animate from the current animation value to the specified animation Value.
- (void)animateToValue:(CGFloat)animationValue
    withAnimationStyle:(PopAnimationStyle)style;
//____________________

//! Animate from the current animation value to the specified animation Value and block for animation steps.
- (void)animateToValue:(CGFloat)animationValue
    withAnimationStyle:(PopAnimationStyle)style
           animateStep:(BlockFloatAction)animateStepAction
            completion:(BlockAction)completionAction;
//____________________

//! Animate from the current animation value to the specified animation Value and block for animation steps.
- (void)animateToValue:(CGFloat)animationValue
           animateStep:(BlockFloatAction)animateStepAction
            completion:(BlockAction)completionAction;
//____________________

//! Stop the parametric animation.
- (void)stopAnimation;
//____________________

@end
//__________________________________________________________________________________________________

