
//! \file   PopBaseView.m
//! \brief  Base for all Pop based view classes.
//__________________________________________________________________________________________________

#import "PopBaseView.h"
//__________________________________________________________________________________________________

@implementation PopAnimParameters

- (instancetype)init
{
  self = [super init];
  if (self != nil)
  {
    self.animationStyle   = E_PopAnimationStyle_Basic;
    self.duration         = 0.5;
    self.timingFunction   = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    self.bounciness       = 5;
    self.velocity         = 1;
    self.springSpeed      = 12;
    self.dynamicsTension  = 342;
    self.dynamicsFriction = 29;
    self.dynamicsMass     = 1.0;
  }
  return self;
}
//__________________________________________________________________________________________________

- (instancetype)copy
{
  PopAnimParameters* parameters = [PopAnimParameters new];
  parameters.animationStyle     = self.animationStyle;
  parameters.duration           = self.duration;
  parameters.timingFunction     = self.timingFunction;
  parameters.bounciness         = self.bounciness;
  parameters.velocity           = self.velocity;
  parameters.springSpeed        = self.springSpeed;
  parameters.dynamicsTension    = self.dynamicsTension;
  parameters.dynamicsFriction   = self.dynamicsFriction;
  parameters.dynamicsMass       = self.dynamicsMass;
  return parameters;
}
//__________________________________________________________________________________________________

@end
//==================================================================================================

//! Base for all Pop based view classes.
@interface PopBaseView()
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! Base for all Pop based view classes.
@implementation PopBaseView
{
  BlockIdAction AnimationCompleted;       //!< Block called when the animation has completed.
  NSInteger     TransformAnimationCount;  //!< Number of currently running transform animations.
  CGSize        ViewScale;                //!< Current view scale.
  BlockAction   ParamScaleAnimCompletionAction;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  ViewScale               = CGSizeMake(1, 1);
  UseFontAnimation        = NO;
  NumAnimationInProgress  = 0;
  TransformAnimationCount = 0;
  WasAnimating            = NO;
  AnimationCompleted = ^(id obj)
  { // Default action: Do nothing!
  };
  ParamScaleAnimCompletionAction = ^
  { // Default action: Do nothing!
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
  AnimationCompleted = animationCompleted;
}
//__________________________________________________________________________________________________

- (BlockIdAction)animationCompleted
{
  return AnimationCompleted;
}
//__________________________________________________________________________________________________

- (POPPropertyAnimation*)CreateAnimationWithStyle:(PopAnimationStyle)style
{
  switch (style)
  {
  case E_PopAnimationStyle_Basic:
    return [POPBasicAnimation animation];
  case E_PopAnimationStyle_Spring:
    return [POPSpringAnimation animation];
  case E_PopAnimationStyle_Decay:
    return [POPDecayAnimation animation];
  case E_PopAnimationStyle_Linear:
    return [POPBasicAnimation linearAnimation];
  default:
    return nil;
  }
}
//__________________________________________________________________________________________________

- (CGRect)scaleBounds
{
  CGSize size       = self.bounds.size;
  CGSize animatedViewSize  = [self sizeThatFits:size];
  animatedViewSize.width  *= ViewScale.width;
  animatedViewSize.height *= ViewScale.height;
  CGRect bounds;
  bounds.origin.x    = 0;
  bounds.origin.y    = 0;
  bounds.size        = animatedViewSize;
//  NSLog(@"scaleBounds: %f, %f, %f, %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
  return bounds;
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super layoutSubviews];
  if ((NumAnimationInProgress == 0) && (!WasAnimating) && (AnimatedView != self))
  {
//    NSLog(@"layoutSubviews");
    [CATransaction begin];
    AnimatedView.bounds = [self scaleBounds];
    AnimatedView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    [CATransaction commit];
  }
  if (WasAnimating)
  {
    WasAnimating = NO;
  }
}
//__________________________________________________________________________________________________

- (void)setAnimatedBackgroundColor:(UIColor*)animatedBackgroundColor
{
  AnimatedView.layer.backgroundColor = animatedBackgroundColor.CGColor;
}
//__________________________________________________________________________________________________

- (UIColor*)animatedBackgroundColor
{
  return AnimatedView.backgroundColor;
}
//__________________________________________________________________________________________________

- (void)setFrame:(CGRect)frame
{
  [CATransaction begin];
  CGPoint origin  = frame.origin;
  CGSize  size    = frame.size;
  CGPoint center  = CGPointMake(origin.x + size.width / 2, origin.y + size.height / 2);
  CGRect  bounds  = CGRectMake(0, 0, size.width, size.height);
  self.bounds     = bounds;
  self.center     = center;
  [CATransaction commit];
}
//__________________________________________________________________________________________________

- (void)ApplyTransformScale:(CGSize)scale rotation:(CGFloat)rotation translation:(CGSize)translation
{
  ViewScale                     = scale;
  CATransform3D transform       = CATransform3DIdentity;
  transform                     = CATransform3DScale(transform, scale.width, scale.height, 1.0);
  transform                     = CATransform3DTranslate(transform, translation.width, translation.height, 0.0);
  transform                     = CATransform3DRotate(transform, rotation * M_PI / 180, 0.0, 0.0, -1.0);
  AnimatedView.layer.transform  = transform;
}
//__________________________________________________________________________________________________

- (void)ApplyScale:(CGSize)scale
{
  ViewScale                     = scale;
  CATransform3D transform       = CATransform3DIdentity;
  transform                     = CATransform3DScale(transform, scale.width, scale.height, 1.0);
  AnimatedView.layer.transform  = transform;
}
//__________________________________________________________________________________________________

//! Set the view scale using the specified animation parameters.
- (void)setViewScale:(CGSize)scale
          parameters:(PopAnimParameters*)parameters
          completion:(BlockAction)completion
{
  ParamScaleAnimCompletionAction  = completion;
  POPPropertyAnimation* anim     = [self CreateAnimationWithStyle:parameters.animationStyle];
  anim.property                  = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
  anim.toValue                   = [NSValue valueWithCGSize:scale];
  anim.name                      = kPopViewParamScaleAnimation;
  anim.delegate                  = self;
  switch (parameters.animationStyle)
  {
    case E_PopAnimationStyle_Basic:
      ((POPBasicAnimation*)anim).duration = parameters.duration;
      break;
    case E_PopAnimationStyle_Spring:
      ((POPSpringAnimation*)anim).springBounciness  = parameters.bounciness;
      ((POPSpringAnimation*)anim).velocity          = [NSValue valueWithCGSize:CGSizeMake(parameters.velocity, parameters.velocity)];
      ((POPSpringAnimation*)anim).springBounciness  = parameters.springSpeed;
      ((POPSpringAnimation*)anim).dynamicsTension   = parameters.dynamicsTension;
      ((POPSpringAnimation*)anim).dynamicsFriction  = parameters.dynamicsFriction;
      ((POPSpringAnimation*)anim).dynamicsMass      = parameters.dynamicsMass;
      break;
    case E_PopAnimationStyle_Decay:
      ((POPDecayAnimation*)anim).deceleration     = parameters.deceleration;
      ((POPDecayAnimation*)anim).velocity         = [NSNumber numberWithFloat:parameters.velocity];
      break;
    default:
      break;
  }
  [AnimatedView.layer pop_addAnimation:anim forKey:kPopViewParamScaleAnimation];
}
//__________________________________________________________________________________________________

//! Set the view transform using basic animation. If duration == 0, no animation.
- (void)setViewScale:(CGSize)scale basicAnimateDuring:(CGFloat)seconds
{
  if (seconds > 0)
  {
    [self basicAnimateToScale:scale during:seconds];
  }
  else
  {
    [self ApplyScale:scale];
  }
}
//__________________________________________________________________________________________________

//! Set the view transform using spring animation.
- (void)setViewScale:(CGSize)scale springAnimateWithBounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity
{
  if (velocity > 0)
  {
    [self springAnimateToScale:scale withBounciness:bounciness andVelocity:velocity];
  }
  else
  {
    [self ApplyScale:scale];
  }
}
//__________________________________________________________________________________________________

//! Set the view transform using decay animation.
- (void)setViewScale:(CGSize)scale decayAnimateWithDeceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity;
{
  if (velocity > 0)
  {
    [self decayAnimateToScale:scale withDeceleration:deceleration andVelocity:velocity];
  }
  else
  {
    [self ApplyScale:scale];
  }
}
//__________________________________________________________________________________________________

//! Set the view transform using basic animation. If duration == 0, no animation.
- (void)setViewScale:(CGSize)scale
            rotation:(CGFloat)angle
         translation:(CGSize)translation
  basicAnimateDuring:(CGFloat)seconds
{
  if (seconds > 0)
  {
    [self basicAnimateTransformToScale:scale
                              rotation:angle
                           translation:translation
                                during:seconds];
  }
  else
  {
    [self ApplyTransformScale:scale rotation:angle translation:translation];
  }
}
//__________________________________________________________________________________________________

//! Set the view transform using spring animation.
- (void)setViewScale:(CGSize)scale
            rotation:(CGFloat)angle
         translation:(CGSize)translation
  springAnimateWithBounciness:(CGFloat)bounciness
                  andVelocity:(CGFloat)velocity
{
  if (velocity > 0)
  {
    [self springAnimateTransformToScale:scale
                               rotation:angle
                            translation:translation
                         withBounciness:bounciness
                            andVelocity:velocity];
  }
  else
  {
    [self ApplyTransformScale:scale rotation:angle translation:translation];
  }
}
//__________________________________________________________________________________________________

//! Set the view transform using decay animation.
- (void)setViewScale:(CGSize)scale
            rotation:(CGFloat)angle
         translation:(CGSize)translation
  decayAnimateWithDeceleration:(CGFloat)deceleration
                   andVelocity:(CGFloat)velocity;
{
  if (velocity > 0)
  {
    [self decayAnimateTransformToScale:scale
                              rotation:angle
                           translation:translation
                      withDeceleration:deceleration
                           andVelocity:velocity];
  }
  else
  {
    [self ApplyTransformScale:scale rotation:angle translation:translation];
  }
}
//__________________________________________________________________________________________________

- (void)basicAnimateToScale:(CGSize)scale
                              during:(CGFloat)seconds
{
  UseFontAnimation                      = NO;

  POPPropertyAnimation* scaleXYAnim     = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  scaleXYAnim.property                  = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
  scaleXYAnim.toValue                   = [NSValue valueWithCGSize:scale];
  scaleXYAnim.name                      = kPopViewScaleAnimation;
  scaleXYAnim.delegate                  = self;

  ((POPBasicAnimation*)scaleXYAnim    ).duration = seconds;
  [AnimatedView.layer pop_addAnimation:scaleXYAnim     forKey:kPopViewScaleAnimation];
}
//__________________________________________________________________________________________________

- (void)springAnimateToScale:(CGSize)scale
                       withBounciness:(CGFloat)bounciness
                          andVelocity:(CGFloat)velocity
{
  UseFontAnimation                      = NO;

  POPPropertyAnimation* scaleXYAnim     = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  scaleXYAnim.property                  = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
  scaleXYAnim.toValue                   = [NSValue valueWithCGSize:scale];
  scaleXYAnim.name                      = kPopViewScaleAnimation;
  scaleXYAnim.delegate                  = self;

  ((POPSpringAnimation*)scaleXYAnim    ).springBounciness = bounciness;
  ((POPSpringAnimation*)scaleXYAnim    ).velocity = [NSValue valueWithCGSize:CGSizeMake(velocity, velocity)];
  [AnimatedView.layer pop_addAnimation:scaleXYAnim     forKey:kPopViewScaleAnimation];
}
//__________________________________________________________________________________________________

- (void)decayAnimateToScale:(CGSize)scale
                    withDeceleration:(CGFloat)deceleration
                         andVelocity:(CGFloat)velocity
{
  UseFontAnimation                      = NO;

  POPPropertyAnimation* scaleXYAnim     = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  scaleXYAnim.property                  = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
  scaleXYAnim.toValue                   = [NSValue valueWithCGSize:scale];
  scaleXYAnim.name                      = kPopViewScaleAnimation;
  scaleXYAnim.delegate                  = self;

  ((POPDecayAnimation*)scaleXYAnim    ).deceleration = deceleration;
  ((POPDecayAnimation*)scaleXYAnim    ).velocity = [NSNumber numberWithDouble:velocity];
  [AnimatedView.layer pop_addAnimation:scaleXYAnim     forKey:kPopViewScaleAnimation];
}
//__________________________________________________________________________________________________

- (void)basicAnimateTransformToScale:(CGSize)scale
                            rotation:(CGFloat)angle
                         translation:(CGSize)translation
                              during:(CGFloat)seconds
{
  UseFontAnimation                      = NO;

  POPPropertyAnimation* rotateAnim      = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  rotateAnim.property                   = [POPAnimatableProperty propertyWithName:kPOPLayerRotation];
  rotateAnim.toValue                    = @(angle * M_PI / 180);
  rotateAnim.name                       = kPopViewRotateTransformAnimation;
  rotateAnim.delegate                   = self;

  POPPropertyAnimation* scaleXYAnim     = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  scaleXYAnim.property                  = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
  scaleXYAnim.toValue                   = [NSValue valueWithCGSize:scale];
  scaleXYAnim.name                      = kPopViewScaleTransformAnimation;
  scaleXYAnim.delegate                  = self;

  POPPropertyAnimation* translateXYAnim = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  translateXYAnim.property              = [POPAnimatableProperty propertyWithName:kPOPLayerTranslationXY];
  translateXYAnim.toValue               = [NSValue valueWithCGSize:translation];
  translateXYAnim.name                  = kPopViewTranslateTransformAnimation;
  translateXYAnim.delegate              = self;

  ((POPBasicAnimation*)rotateAnim     ).duration = seconds;
  ((POPBasicAnimation*)scaleXYAnim    ).duration = seconds;
  ((POPBasicAnimation*)translateXYAnim).duration = seconds;
  [AnimatedView.layer pop_addAnimation:scaleXYAnim     forKey:kPopViewScaleTransformAnimation];
  [AnimatedView.layer pop_addAnimation:rotateAnim      forKey:kPopViewRotateTransformAnimation];
  [AnimatedView.layer pop_addAnimation:translateXYAnim forKey:kPopViewTranslateTransformAnimation];
}
//__________________________________________________________________________________________________

- (void)springAnimateTransformToScale:(CGSize)scale
                             rotation:(CGFloat)angle
                          translation:(CGSize)translation
                       withBounciness:(CGFloat)bounciness
                          andVelocity:(CGFloat)velocity
{
  UseFontAnimation                      = NO;

  POPPropertyAnimation* rotateAnim      = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  rotateAnim.property                   = [POPAnimatableProperty propertyWithName:kPOPLayerRotation];
  rotateAnim.toValue                    = @(angle * M_PI / 180);
  rotateAnim.name                       = kPopViewRotateTransformAnimation;
  rotateAnim.delegate                   = self;

  POPPropertyAnimation* scaleXYAnim     = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  scaleXYAnim.property                  = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
  scaleXYAnim.toValue                   = [NSValue valueWithCGSize:scale];
  scaleXYAnim.name                      = kPopViewScaleTransformAnimation;
  scaleXYAnim.delegate                  = self;

  POPPropertyAnimation* translateXYAnim = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  translateXYAnim.property              = [POPAnimatableProperty propertyWithName:kPOPLayerTranslationXY];
  translateXYAnim.toValue               = [NSValue valueWithCGSize:translation];
  translateXYAnim.name                  = kPopViewTranslateTransformAnimation;
  translateXYAnim.delegate              = self;

  ((POPSpringAnimation*)rotateAnim     ).springBounciness = bounciness;
  ((POPSpringAnimation*)scaleXYAnim    ).springBounciness = bounciness;
  ((POPSpringAnimation*)translateXYAnim).springBounciness = bounciness;
  ((POPSpringAnimation*)rotateAnim     ).velocity = [NSNumber numberWithDouble:velocity];
  ((POPSpringAnimation*)scaleXYAnim    ).velocity = [NSValue valueWithCGSize:CGSizeMake(velocity, velocity)];
  ((POPSpringAnimation*)translateXYAnim).velocity = [NSValue valueWithCGSize:CGSizeMake(velocity, velocity)];
  [AnimatedView.layer pop_addAnimation:scaleXYAnim     forKey:kPopViewScaleTransformAnimation];
  [AnimatedView.layer pop_addAnimation:translateXYAnim forKey:kPopViewTranslateTransformAnimation];
  [AnimatedView.layer pop_addAnimation:rotateAnim      forKey:kPopViewRotateTransformAnimation];
}
//__________________________________________________________________________________________________

- (void)decayAnimateTransformToScale:(CGSize)scale
                            rotation:(CGFloat)angle
                         translation:(CGSize)translation
                    withDeceleration:(CGFloat)deceleration
                         andVelocity:(CGFloat)velocity
{
  UseFontAnimation                      = NO;

  POPPropertyAnimation* rotateAnim      = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  rotateAnim.property                   = [POPAnimatableProperty propertyWithName:kPOPLayerRotation];
  rotateAnim.toValue                    = @(angle * M_PI / 180);
  rotateAnim.name                       = kPopViewRotateTransformAnimation;
  rotateAnim.delegate                   = self;

  POPPropertyAnimation* scaleXYAnim     = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  scaleXYAnim.property                  = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
  scaleXYAnim.toValue                   = [NSValue valueWithCGSize:scale];
  scaleXYAnim.name                      = kPopViewScaleTransformAnimation;
  scaleXYAnim.delegate                  = self;

  POPPropertyAnimation* translateXYAnim = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  translateXYAnim.property              = [POPAnimatableProperty propertyWithName:kPOPLayerTranslationXY];
  translateXYAnim.toValue               = [NSValue valueWithCGSize:translation];
  translateXYAnim.name                  = kPopViewTranslateTransformAnimation;
  translateXYAnim.delegate              = self;

  ((POPDecayAnimation*)rotateAnim     ).deceleration = deceleration;
  ((POPDecayAnimation*)scaleXYAnim    ).deceleration = deceleration;
  ((POPDecayAnimation*)translateXYAnim).deceleration = deceleration;
  ((POPDecayAnimation*)rotateAnim     ).velocity = [NSNumber numberWithDouble:velocity];
  ((POPDecayAnimation*)scaleXYAnim    ).velocity = [NSNumber numberWithDouble:velocity];
  ((POPDecayAnimation*)translateXYAnim).velocity = [NSNumber numberWithDouble:velocity];
  [AnimatedView.layer pop_addAnimation:scaleXYAnim     forKey:kPopViewScaleTransformAnimation];
  [AnimatedView.layer pop_addAnimation:translateXYAnim forKey:kPopViewTranslateTransformAnimation];
  [AnimatedView.layer pop_addAnimation:rotateAnim      forKey:kPopViewRotateTransformAnimation];
}
//__________________________________________________________________________________________________

- (void)stopTransformAnimation
{
  WasAnimating = YES;
  [AnimatedView.layer pop_removeAnimationForKey:kPopViewRotateTransformAnimation];
  [AnimatedView.layer pop_removeAnimationForKey:kPopViewScaleTransformAnimation];
  [AnimatedView.layer pop_removeAnimationForKey:kPopViewTranslateTransformAnimation];
}
//__________________________________________________________________________________________________

//! Set the view corner radius using basic animation. If duration == 0, no animation.
- (void)setCornerRadius:(CGFloat)cornerRadius basicAnimateDuring:(CGFloat)seconds
{
  if (seconds > 0)
  {
    [self basicAnimateCornerRadiusToSize:cornerRadius during:seconds];
  }
  else
  {
    AnimatedView.layer.cornerRadius = cornerRadius;
  }
}
//__________________________________________________________________________________________________

//! Set the view corner radius using spring animation. If velocity == 0, no animation.
- (void)setCornerRadius:(CGFloat)cornerRadius springAnimateWithBounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity;
{
  if (velocity > 0)
  {
    [self springAnimateCornerRadiusToSize:cornerRadius bounciness:bounciness andVelocity:velocity];
  }
  else
  {
    AnimatedView.layer.cornerRadius = cornerRadius;
  }
}
//__________________________________________________________________________________________________

//! Set the view corner radius using decay animation. If velocity == 0, no animation.
- (void)setCornerRadius:(CGFloat)cornerRadius decayAnimateWithDeceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity;
{
  if (velocity != 0)
  {
    [self decayAnimateCornerRadiusToSize:cornerRadius deceleration:deceleration andVelocity:velocity];
  }
  else
  {
    AnimatedView.layer.cornerRadius = cornerRadius;
  }
}
//__________________________________________________________________________________________________

- (void)basicAnimateCornerRadiusToSize:(CGFloat)cornerRadius during:(CGFloat)seconds
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPLayerCornerRadius];
  anim.toValue                = [NSNumber numberWithFloat:cornerRadius];
  anim.name                   = kPopCornerRadiusAnimation;
  anim.delegate               = self;
  ((POPBasicAnimation*)anim).duration = seconds;
  [AnimatedView.layer pop_addAnimation:anim forKey:kPopCornerRadiusAnimation];
}
//__________________________________________________________________________________________________

- (void)springAnimateCornerRadiusToSize:(CGFloat)cornerRadius bounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPLayerCornerRadius];
  anim.toValue                = [NSNumber numberWithFloat:cornerRadius];
  anim.name                   = kPopCornerRadiusAnimation;
  anim.delegate               = self;
  ((POPSpringAnimation*)anim).springBounciness  = bounciness;
//  ((POPSpringAnimation*)anim).velocity          = [NSNumber numberWithFloat:velocity];
  ((POPSpringAnimation*)anim).springSpeed       = velocity;
  [AnimatedView.layer pop_addAnimation:anim forKey:kPopCornerRadiusAnimation];
}
//__________________________________________________________________________________________________

- (void)decayAnimateCornerRadiusToSize:(CGFloat)cornerRadius deceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPLayerCornerRadius];
  anim.toValue                = [NSNumber numberWithFloat:cornerRadius];
  anim.name                   = kPopCornerRadiusAnimation;
  anim.delegate               = self;
  ((POPDecayAnimation*)anim).deceleration = deceleration;
  ((POPDecayAnimation*)anim).velocity     = [NSNumber numberWithFloat:velocity];
  [AnimatedView.layer pop_addAnimation:anim forKey:kPopCornerRadiusAnimation];
}
//__________________________________________________________________________________________________

- (void)stopCornerRadiusAnimation
{
  [AnimatedView.layer pop_removeAnimationForKey:kPopCornerRadiusAnimation];
}
//__________________________________________________________________________________________________

//! Set the view frame using basic animation. If duration == 0, no animation.
- (void)setViewFrame:(CGRect)frame basicAnimateDuring:(CGFloat)seconds
{
  CGPoint origin  = frame.origin;
  CGSize  size    = frame.size;
  if (seconds > 0)
  {
    [self basicAnimateViewToSize:size       during:seconds];
    [self basicAnimateViewToPosition:origin during:seconds];
  }
  else
  {
    self.size   = size;
    self.origin = origin;
  }
}
//__________________________________________________________________________________________________

//! Set the view frame using spring animation. If velocity == 0, no animation.
- (void)setViewFrame:(CGRect)frame springAnimateWithBounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity;
{
  CGPoint origin  = frame.origin;
  CGSize  size    = frame.size;
  if (velocity > 0)
  {
    [self springAnimateViewToSize:size        bounciness:bounciness andVelocity:velocity];
    [self springAnimateViewToPosition:origin  bounciness:bounciness andVelocity:velocity];
  }
  else
  {
    self.size   = size;
    self.origin = origin;
  }
}
//__________________________________________________________________________________________________

//! Set the view frame using decay animation. If velocity == 0, no animation.
- (void)setViewFrame:(CGRect)frame decayAnimateWithDeceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity;
{
  CGPoint origin  = frame.origin;
  CGSize  size    = frame.size;
  if (velocity != 0)
  {
    [self decayAnimateViewToSize:size       deceleration:deceleration andVelocity:velocity];
    [self decayAnimateViewToPosition:origin deceleration:deceleration andVelocity:velocity];
  }
  else
  {
    self.size   = size;
    self.origin = origin;
  }
}
//__________________________________________________________________________________________________

- (void)basicAnimateViewToFrame:(CGRect)frame during:(CGFloat)seconds
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
  anim.toValue                = [NSValue valueWithCGRect:frame];
  anim.name                   = kPopFrameAnimation;
  anim.delegate               = self;
  ((POPBasicAnimation*)anim).duration = seconds;
  [self pop_addAnimation:anim forKey:kPopFrameAnimation];
}
//__________________________________________________________________________________________________

- (void)springAnimateViewToFrame:(CGRect)frame bounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
  anim.toValue                = [NSValue valueWithCGRect:frame];
  anim.name                   = kPopFrameAnimation;
  anim.delegate               = self;
  ((POPSpringAnimation*)anim).springBounciness  = bounciness;
  //  ((POPSpringAnimation*)anim).velocity          = [NSNumber numberWithFloat:velocity];
  ((POPSpringAnimation*)anim).springSpeed       = velocity;
  [self pop_addAnimation:anim forKey:kPopFrameAnimation];
}
//__________________________________________________________________________________________________

- (void)decayAnimateViewToFrame:(CGRect)frame deceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
  anim.toValue                = [NSValue valueWithCGRect:frame];
  anim.name                   = kPopFrameAnimation;
  anim.delegate               = self;
  ((POPDecayAnimation*)anim).deceleration = deceleration;
  ((POPDecayAnimation*)anim).velocity     = [NSNumber numberWithFloat:velocity];
  [self pop_addAnimation:anim forKey:kPopFrameAnimation];
}
//__________________________________________________________________________________________________

- (void)basicAnimateViewToSize:(CGSize)size during:(CGFloat)seconds
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPViewSize];
  anim.toValue                = [NSValue valueWithCGSize:size];
  anim.name                   = kPopSizeAnimation;
  anim.delegate               = self;
  ((POPBasicAnimation*)anim).duration = seconds;
  [self pop_addAnimation:anim forKey:kPopSizeAnimation];
}
//__________________________________________________________________________________________________

- (void)springAnimateViewToSize:(CGSize)size bounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPViewSize];
  anim.toValue                = [NSValue valueWithCGSize:size];
  anim.name                   = kPopSizeAnimation;
  anim.delegate               = self;
  ((POPSpringAnimation*)anim).springBounciness  = bounciness;
  //  ((POPSpringAnimation*)anim).velocity          = [NSNumber numberWithFloat:velocity];
  ((POPSpringAnimation*)anim).springSpeed       = velocity;
  [self pop_addAnimation:anim forKey:kPopSizeAnimation];
}
//__________________________________________________________________________________________________

- (void)decayAnimateViewToSize:(CGSize)size deceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPViewSize];
  anim.toValue                = [NSValue valueWithCGSize:size];
  anim.name                   = kPopSizeAnimation;
  anim.delegate               = self;
  ((POPDecayAnimation*)anim).deceleration = deceleration;
  ((POPDecayAnimation*)anim).velocity     = [NSNumber numberWithFloat:velocity];
  [self pop_addAnimation:anim forKey:kPopSizeAnimation];
}
//__________________________________________________________________________________________________

- (void)basicAnimateViewToPosition:(CGPoint)position during:(CGFloat)seconds
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPLayerPosition];
  anim.toValue                = [NSValue valueWithCGPoint:position];
  anim.name                   = kPopPositionAnimation;
  anim.delegate               = self;
  ((POPBasicAnimation*)anim).duration = seconds;
  [self pop_addAnimation:anim forKey:kPopPositionAnimation];
}
//__________________________________________________________________________________________________

- (void)springAnimateViewToPosition:(CGPoint)position bounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPLayerPosition];
  anim.toValue                = [NSValue valueWithCGPoint:position];
  anim.name                   = kPopPositionAnimation;
  anim.delegate               = self;
  ((POPSpringAnimation*)anim).springBounciness  = bounciness;
  //  ((POPSpringAnimation*)anim).velocity          = [NSNumber numberWithFloat:velocity];
  ((POPSpringAnimation*)anim).springSpeed       = velocity;
  [self pop_addAnimation:anim forKey:kPopPositionAnimation];
}
//__________________________________________________________________________________________________

- (void)decayAnimateViewToPosition:(CGPoint)position deceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  anim.property               = [POPAnimatableProperty propertyWithName:kPOPLayerPosition];
  anim.toValue                = [NSValue valueWithCGPoint:position];
  anim.name                   = kPopPositionAnimation;
  anim.delegate               = self;
  ((POPDecayAnimation*)anim).deceleration = deceleration;
  ((POPDecayAnimation*)anim).velocity     = [NSNumber numberWithFloat:velocity];
  [self pop_addAnimation:anim forKey:kPopPositionAnimation];
}
//__________________________________________________________________________________________________

//! Called on each frame before animation application.
- (void)animatorWillAnimate:(POPAnimator*)animator
{
//  NSLog(@"PopBaseView animatorWillAnimate");
}
//__________________________________________________________________________________________________

//! Called on each frame after animation application.
- (void)animatorDidAnimate:(POPAnimator*)animator
{
//  NSLog(@"PopBaseView animatorDidAnimate");
}
//__________________________________________________________________________________________________

- (void)pop_animationDidStart:(POPAnimation*)anim
{
//  NSLog(@"PopBaseView pop_animationDidStart: %@", anim.name);
  if (([anim.name isEqual:kPopViewRotateTransformAnimation]) ||
      ([anim.name isEqual:kPopViewScaleTransformAnimation]) ||
      ([anim.name isEqual:kPopViewTranslateTransformAnimation]))
  {
    TransformAnimationCount++;
  }
  else
  {
    NumAnimationInProgress++;
  }
}
//__________________________________________________________________________________________________

- (void)pop_animationDidReachToValue:(POPAnimation*)anim
{
//  NSLog(@"PopBaseView pop_animationDidReachToValue: %@", anim.name);
}
//__________________________________________________________________________________________________

- (void)pop_animationDidStop:(POPAnimation*)anim finished:(BOOL)finished
{
//  NSLog(@"PopBaseView pop_animationDidStop: %ld, %@", (long)NumAnimationInProgress, anim.name);
  if ([anim.name isEqual:kPopViewParamScaleAnimation])
  {
    ParamScaleAnimCompletionAction();
  }
  else if (([anim.name isEqual:kPopViewRotateTransformAnimation]) ||
           ([anim.name isEqual:kPopViewScaleTransformAnimation]) ||
           ([anim.name isEqual:kPopViewTranslateTransformAnimation]))
  {
    TransformAnimationCount--;
    if (TransformAnimationCount == 0)
    {
      AnimationCompleted(anim);
    }
  }
  else
  {
    NumAnimationInProgress--;
    if (NumAnimationInProgress == 0)
    {
      WasAnimating = YES;
      AnimationCompleted(anim);
    }
  }
}
//__________________________________________________________________________________________________

- (void)pop_animationDidApply:(POPAnimation*)anim
{
//  NSLog(@"PopBaseView pop_animationDidApply:  cornerRadius: %6.3f, %@", AnimatedView.layer.cornerRadius, anim.name);
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
