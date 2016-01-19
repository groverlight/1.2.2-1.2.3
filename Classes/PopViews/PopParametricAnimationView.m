
//! \file   PopParametricAnimationView.m
//! \brief  Base class that handle POP animated views using a generic parameter.
//__________________________________________________________________________________________________

#import "PopParametricAnimationView.h"
#import "Tools.h"
//__________________________________________________________________________________________________

//! Base class that handle POP animated views using a generic parameter.
@interface PopParametricAnimationView()
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! Base class that handle POP animated views using a generic parameter.
@implementation PopParametricAnimationView
{
  CGFloat           AnimationFromValue; //!< Parametric animation value at the start of the animation.
  CGFloat           AnimationToValue;   //!< Parametric animation value at the end of the animation.
  CGFloat           AnimationValue;     //!< Current parametric animation value.
  BlockFloatAction  AnimateAction;
  BlockFloatAction  DefaultAnimateAction;
}
@synthesize animParameters;
#if 0
@synthesize duration;
@synthesize timingFunction;
@synthesize bounciness;
@synthesize velocity;
@synthesize springSpeed;
@synthesize dynamicsTension;
@synthesize dynamicsFriction;
@synthesize dynamicsMass;
@synthesize deceleration;
#endif
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  animParameters    = [PopAnimParameters new];
  AnimationValue    = 0.0;
  AnimationToValue  = 0.0;
  AnimatedView      = self;
  DefaultAnimateAction = ^(CGFloat parameterValue)
  { // Default action: do nothing!
  };
  AnimateAction = DefaultAnimateAction;
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

- (void)basicAnimate
{
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  anim.property               = [self prepareParametricAnimationProperty];
  anim.toValue                = [NSNumber numberWithFloat:AnimationToValue];
  anim.name                   = kPopParametricAnimation;
  anim.delegate               = self;
  ((POPBasicAnimation*)anim).duration       = animParameters.duration;
  ((POPBasicAnimation*)anim).timingFunction = animParameters.timingFunction;
  [AnimatedView pop_addAnimation:anim forKey:kPopParametricAnimation];
}
//__________________________________________________________________________________________________

- (void)springAnimate
{
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  anim.property               = [self prepareParametricAnimationProperty];
  anim.toValue                = [NSNumber numberWithFloat:AnimationToValue];
  anim.name                   = kPopParametricAnimation;
  anim.delegate               = self;
  ((POPSpringAnimation*)anim).springBounciness  = animParameters.bounciness;
  ((POPSpringAnimation*)anim).velocity          = [NSNumber numberWithFloat:animParameters.velocity];
  ((POPSpringAnimation*)anim).springSpeed       = animParameters.springSpeed;
  ((POPSpringAnimation*)anim).dynamicsTension   = animParameters.dynamicsTension;
  ((POPSpringAnimation*)anim).dynamicsFriction  = animParameters.dynamicsFriction;
  ((POPSpringAnimation*)anim).dynamicsMass      = animParameters.dynamicsMass;
  [AnimatedView pop_addAnimation:anim forKey:kPopParametricAnimation];
}
//__________________________________________________________________________________________________

- (void)decayAnimate
{
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  anim.property               = [self prepareParametricAnimationProperty];
  anim.toValue                = [NSNumber numberWithFloat:AnimationToValue];
  anim.name                   = kPopParametricAnimation;
  anim.delegate               = self;
  ((POPDecayAnimation*)anim).deceleration   = animParameters.deceleration;
  ((POPDecayAnimation*)anim).velocity       = [NSNumber numberWithFloat:animParameters.velocity];
  [AnimatedView pop_addAnimation:anim forKey:kPopParametricAnimation];
}
//__________________________________________________________________________________________________

- (void)linearAnimate
{
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Linear];
  anim.property               = [self prepareParametricAnimationProperty];
  anim.toValue                = [NSNumber numberWithFloat:AnimationToValue];
  anim.name                   = kPopParametricAnimation;
  anim.delegate               = self;
  ((POPBasicAnimation*)anim).duration = animParameters.duration;
  [AnimatedView pop_addAnimation:anim forKey:kPopParametricAnimation];
}
//__________________________________________________________________________________________________

- (void)stopAnimation
{
  [AnimatedView pop_removeAnimationForKey:kPopParametricAnimation];
}
//__________________________________________________________________________________________________

- (POPAnimatableProperty*)prepareParametricAnimationProperty
{
  POPAnimatableProperty* prop = [POPAnimatableProperty propertyWithName:@"ParametricAnimProp" initializer:^(POPMutableAnimatableProperty* blockProp)
  {
    // Read value.
    blockProp.readBlock = ^(PopParametricAnimationView* view, CGFloat values[])
    {
      values[0] = AnimationFromValue;
    };
    // Write value.
    blockProp.writeBlock = ^(PopParametricAnimationView* view, const CGFloat values[])
    {
      self.animationValue = values[0];
    };
    // Dynamics threshold.
    blockProp.threshold = 0.01;
  }];

  return prop;
}
//__________________________________________________________________________________________________

- (void)setAnimationValue:(CGFloat)animationValue
{
  AnimationValue = animationValue;
  AnimateAction(animationValue);
}
//__________________________________________________________________________________________________

- (CGFloat)animationValue
{
  return AnimationValue;
}
//__________________________________________________________________________________________________

- (void)animateToValue:(CGFloat)animationValue
    withAnimationStyle:(PopAnimationStyle)style
{
  AnimateAction = DefaultAnimateAction;
  AnimationFromValue = AnimationValue;
  AnimationToValue = animationValue;
  switch (style)
  {
  case E_PopAnimationStyle_Basic:
    [self basicAnimate];
    break;
  case E_PopAnimationStyle_Spring:
    [self springAnimate];
    break;
  case E_PopAnimationStyle_Decay:
    [self decayAnimate];
    break;
  case E_PopAnimationStyle_Linear:
    [self linearAnimate];
    break;
  default:
    break;
  }
}
//__________________________________________________________________________________________________

//! Animate from the current animation value to the specified animation Value and block for animation steps.
- (void)animateToValue:(CGFloat)animationValue
    withAnimationStyle:(PopAnimationStyle)style
           animateStep:(BlockFloatAction)animateStepAction
            completion:(BlockAction)completionAction
{
  AnimateAction = animateStepAction;
  self.animationCompleted = ^(id caller)
  {
    AnimateAction = DefaultAnimateAction;
    completionAction();
  };
  AnimationFromValue = AnimationValue;
  AnimationToValue = animationValue;
  switch (style)
  {
  case E_PopAnimationStyle_Basic:
    [self basicAnimate];
    break;
  case E_PopAnimationStyle_Spring:
    [self springAnimate];
    break;
  case E_PopAnimationStyle_Decay:
    [self decayAnimate];
    break;
  case E_PopAnimationStyle_Linear:
    [self linearAnimate];
    break;
  default:
    break;
  }
}
//__________________________________________________________________________________________________

//! Animate from the current animation value to the specified animation Value and block for animation steps.
- (void)animateToValue:(CGFloat)animationValue
           animateStep:(BlockFloatAction)animateStepAction
            completion:(BlockAction)completionAction
{
  AnimateAction = animateStepAction;
  self.animationCompleted = ^(id caller)
  {
    AnimateAction = DefaultAnimateAction;
    completionAction();
  };
  AnimationFromValue = AnimationValue;
  AnimationToValue = animationValue;
  switch (self.animParameters.animationStyle)
  {
  case E_PopAnimationStyle_Basic:
    [self basicAnimate];
    break;
  case E_PopAnimationStyle_Spring:
    [self springAnimate];
    break;
  case E_PopAnimationStyle_Decay:
    [self decayAnimate];
    break;
  case E_PopAnimationStyle_Linear:
    [self linearAnimate];
    break;
  default:
    break;
  }
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
