
//! \file   BlurView.m
//! \brief  UIView based class that implement blurred snapshots.
//__________________________________________________________________________________________________

#import "BlurView.h"
//__________________________________________________________________________________________________

//! \brief  UIView based class that displays an UIDynamics scene as background.
@interface BlurView()
{
  UIView*             BlurableView;         //!< The view that will be blurred.
  BlurAction          WillBlurAction;       //!< The cached copy of the block to call before starting the blur operation.
  BlurAction          WillUnblurAction;     //!< The cached copy of the block to call before starting the unblur operation.
  BlurAction          DidBlurAction;        //!< The cached copy of the block to call after ending the blur operation.
  BlurAction          DidUnblurAction;      //!< The cached copy of the block to call after ending the unblur operation.
  BOOL                Blurred;              //!< YES when the view is blurred.
  UIVisualEffectView* VisualEffectView;
}
@end
//__________________________________________________________________________________________________

//! \brief  UIView based class that displays an UIDynamics scene as background.
@implementation BlurView
@synthesize transitionDuration;
@synthesize tintColor;
@synthesize blurRadius;
@synthesize saturationDeltaFactor;
//__________________________________________________________________________________________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  Blurred               = YES;  // Simulate an initial blurred mode.
  self.opaque           = NO;
  self.backgroundColor  = [UIColor clearColor];
  transitionDuration    = 1.0;
  tintColor             = [UIColor colorWithWhite:1.0 alpha:0.3];
  blurRadius            = 5;
  saturationDeltaFactor = 1.8;

  UIVisualEffect *blurEffect;
  blurEffect        = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
  VisualEffectView  = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  [self addSubview:VisualEffectView];
}
//__________________________________________________________________________________________________

//! Initialize the object when it has been allocated programmatically.
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
    [self Initialize];
	}
	return self;
}
//__________________________________________________________________________________________________

//! Initialize the object when it has been allocated from an UIBuilder file.
- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self)
	{
    [self Initialize];
	}
	return self;
}
//__________________________________________________________________________________________________

//! If some cleanup should be done when the object is deallocated, do it here.
- (void)dealloc
{
}
//__________________________________________________________________________________________________

//! Adjust the bounds of the subviews to those of the view.
- (void)layoutSubviews
{
  [super layoutSubviews];
  CGRect frame            = self.bounds;
  BlurableView.frame      = frame;
  VisualEffectView.frame  = frame;
}
//__________________________________________________________________________________________________

- (void)SetBlurableView:(UIView*)view
{
  BlurableView = view;
}
//__________________________________________________________________________________________________

- (void)setWillBlurAction:(BlurAction)action
{
  WillBlurAction = action;
}
//__________________________________________________________________________________________________

- (void)setWillUnblurAction:(BlurAction)action
{
  WillUnblurAction = action;
}
//__________________________________________________________________________________________________

//! Specify the block to call after ending the blur operation.
- (void)setDidBlurAction:(BlurAction)action
{
  DidBlurAction = action;
}
//__________________________________________________________________________________________________

//! Specify the block to call after ending the unblur operation.
- (void)setDidUnblurAction:(BlurAction)action
{
  DidUnblurAction = action;
}
//__________________________________________________________________________________________________

//! Hold the animation and blur the view.
- (void)holdAndBlur:(BOOL)animate
{
  if (!Blurred)
  {
    Blurred = YES;
    if (WillBlurAction != NULL)
    {
      WillBlurAction();
    }
    if (animate)
    {
      self.alpha = 0.0;
      [UIView animateWithDuration:transitionDuration animations:^
      {
        self.alpha = 1.0;
      } completion:^(BOOL finished)
      {
        if (DidBlurAction != NULL)
        {
          DidBlurAction();
        }
//        NSLog(@"Blur finished");
      }];
    }
    else
    {
      self.alpha = 1.0;
      if (DidBlurAction != NULL)
      {
        DidBlurAction();
      }
    }
  }
}
//__________________________________________________________________________________________________

//! When hold, restart the animation at the start of the current timeline. Otherwise, do nothing.
- (void)unholdAndUnblur:(BOOL)animate
{
  if (Blurred)
  {
    Blurred = NO;
    if (WillUnblurAction != NULL)
    {
      WillUnblurAction();
    }
    if (animate)
    {
      [UIView animateWithDuration:transitionDuration animations:^
      {
        self.alpha = 0.0;
      } completion:^(BOOL finished)
      {
        if (DidUnblurAction != NULL)
        {
          DidUnblurAction();
        }
//        NSLog(@"Unblur finished");
      }];
    }
    else
    {
      self.alpha = 0.0;
      if (DidUnblurAction != NULL)
      {
        DidUnblurAction();
      }
    }
  }
}
//__________________________________________________________________________________________________

- (void)blurWithFactor:(CGFloat)blurFactor
{
  self.alpha = blurFactor;
}
//__________________________________________________________________________________________________


@end
//__________________________________________________________________________________________________
