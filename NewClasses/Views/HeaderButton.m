
//! \file   HeaderButton.m
//! \brief  Button with with dot and POP animation.
//__________________________________________________________________________________________________

#import "HeaderButton.h"
#import "Colors.h"
#import "GlobalParameters.h"
#import "Interpolation.h"
#import "PopLabel.h"
#import "StillImageCapture.h"
#import "Tools.h"
#import "TopBarView.h"
#import <AudioToolbox/AudioToolbox.h>


//__________________________________________________________________________________________________

@interface DotView : PopParametricAnimationView
{
   
}
//____________________

@property CGFloat   scale;
@property UIColor*  color;

- (void)bounceDot;

//____________________

@end
//__________________________________________________________________________________________________

@implementation DotView
{
  CGFloat DotRadius;
}
//____________________

- (void)Initialize
{
  [super Initialize];
  self.animParameters   = GetGlobalParameters().headerButtonDotAnimParameters;
  self.backgroundColor  = Transparent;
  self.opaque           = NO;
}
//__________________________________________________________________________________________________

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  CGSize        size          = self.bounds.size;
  CGPoint       center        = CGPointMake(size.width / 2, size.height / 2);
  CGContextRef  context       = UIGraphicsGetCurrentContext();

  CGContextSetFillColorWithColor(context, self.color.CGColor);
  CGRect circleRect = CGRectMake(center.x - DotRadius, center.y - DotRadius, 2 * DotRadius, 2 * DotRadius);
  CGContextFillEllipseInRect(context, circleRect);
}
//__________________________________________________________________________________________________

- (void)bounceDot
{
//  NSLog(@"1 bounceDot");
  [self stopAnimation];
//  NSLog(@"2 bounceDot");
  self.animationValue = 0.0;
  set_myself;
  [self animateToValue:1.0 animateStep:^(CGFloat parameterValue)
  {
    get_myself;
    if (myself != nil)
    {
//      CGFloat animationValue  = sin(parameterValue * M_PI);
      CGFloat animationValue  = parameterValue;
      CGFloat dotScale        = InterpolateFloat(animationValue, self.scale, 1.0);
//      NSLog(@"1 bounceDot: %f, dotScale: %f", animationValue, dotScale);
      myself->DotRadius       = myself.width / 2 * dotScale / 2;
//      NSLog(@"1 bounceDot: %f, dotScale: %6.2f, dotRadius: %6.2f", animationValue, dotScale, myself->DotRadius);
      [myself setNeedsDisplay];
    }
  } completion:^
  {
//    NSLog(@"3 bounceDot");
    [self animateToValue:0.0 animateStep:^(CGFloat parameterValue)
    {
      get_myself;
      if (myself != nil)
      {
        CGFloat animationValue  = parameterValue;
        CGFloat dotScale        = InterpolateFloat(animationValue, self.scale, 1.0);
        myself->DotRadius       = myself.width / 2 * dotScale / 2;
//        NSLog(@"2 bounceDot: %f, dotScale: %6.2f, dotRadius: %6.2f", animationValue, dotScale, myself->DotRadius);
        [myself setNeedsDisplay];
      }
    } completion:^
    {
//      NSLog(@"4 bounceDot");
//    NSLog(@"bounceDot done  (%f, %f, %f, %f)", self.left, self.top, self.width, self.height);
    }];
  }];
}
//__________________________________________________________________________________________________

@end
//==================================================================================================

//! Button with with dot and POP animation.
@implementation HeaderButton
{
  UILabel*      Label;
  BlockAction   HighlightedAction;
  BlockAction   PressedAction;
  DotView*      Dot;
  PopViewState  CurrentButtonState;
  PopViewState  SavedButtonState;
  CGFloat       IdleScale;
  CGFloat       LabelFontSize;
  CGFloat       UnderlineGap;
  CGFloat       LabelScale;
  CGFloat       HighlightedLabelScale;
  CGFloat       DotScale;
  UIColor*      LabelColor;
  UIColor*      HighlightedLabelColor;
  UIColor*      SelectedLabelColor;
  UIColor*      DisabledLabelColor;
  CGFloat       DotRadius;
  CGFloat       HighlightedDotRadius;
  UIColor*      DotColor;

  // Variables for animation.
  CGFloat       StartLabelScale;
  CGFloat       EndLabelScale;
  UIColor*      StartLabelColor;
  UIColor*      EndLabelColor;
  BOOL          NeverLayouted;
  BOOL          Animating;
  BOOL          Selected;
  BOOL          Bouncing;
  BOOL          DotVisible;
  BOOL          InitialSelection;
  BOOL          IsSpringAnimation;
  SystemSoundID           soundEffect;

}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  Bouncing                      = NO;
  NeverLayouted                 = YES;
  DotVisible                    = NO;
  InitialSelection              = YES;
  IsSpringAnimation             = (GetGlobalParameters().headerButtonAnimParameters.animationStyle == E_PopAnimationStyle_Spring);

  GlobalParameters* parameters  = GetGlobalParameters();
  self.animParameters           = parameters.headerButtonAnimParameters;
  LabelScale                    = IsSpringAnimation? 1.0: 1.0 / parameters.headerButtonBounceScaleFactor;
  HighlightedLabelScale         = 1.0;
  IdleScale                     = HighlightedLabelScale /  parameters.headerButtonBounceScaleFactor;
  LabelFontSize                 = floor(parameters.headerButtonFontSize / IdleScale);
  UnderlineGap                  = parameters.headerUnderlineGap;
  CurrentButtonState            = E_PopViewState_Invalid;
  SavedButtonState              = E_PopViewState_Invalid;
  EndLabelScale                 = LabelScale;
  LabelColor                    = parameters.headerButtonIdleColor;
  HighlightedLabelColor         = parameters.headerButtonHighlightedColor;
  SelectedLabelColor            = parameters.headerButtonSelectedColor;
  DisabledLabelColor            = parameters.headerButtonDisabledColor;
  DotRadius                     = parameters.headerButtonDotRadius;
  HighlightedDotRadius          = parameters.headerButtonHighlightedDotRadius;
  DotColor                      = parameters.headerButtonDotColor;
  DotScale                      = DotRadius / HighlightedDotRadius;

  StartLabelColor               = LabelColor;
  EndLabelColor                 = LabelColor;

  Label                         = [UILabel  new];
  Dot                           = [DotView  new];
  Label.font                    = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
  Label.textAlignment           = NSTextAlignmentCenter;
  Dot.bounds                    = CGRectMake(0, 0, 4 * HighlightedDotRadius, 4 * HighlightedDotRadius);
  Dot.center                    = CGPointZero;
  Dot.scale                     = DotScale;
  Dot.color                     = DotColor;
  [self addSubview:Label];
  [self addSubview:Dot];

  HighlightedAction = ^
  { // Default action: do nothing!
  };
  PressedAction = ^
  { // Default action: do nothing!
  };
  self.enabled = YES;
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

- (void)layout
{
  Label.transform       = CGAffineTransformMakeScale(LabelScale, LabelScale);
  Label.center          = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
  Label.bounds          = self.bounds;
  self.animationValue   = 1;
  Dot.center            = CGPointMake(self.width, 0);
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  // Do not call [super LayoutSubviews] for this class. It makes unwanted things.
  if (NeverLayouted || ((NumAnimationInProgress == 0) && (!WasAnimating) && !Animating))
  {
    [self layout];
    NeverLayouted = NO;
  }
}
//__________________________________________________________________________________________________

- (CGSize)scaledSizeThatFits:(CGSize)size
{
  CGSize fitSize  = [self sizeThatFits:size];
  fitSize.width  *= IdleScale;
  fitSize.height *= IdleScale;
  return fitSize;
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  CGSize fitSize  = CalculateTextSize(Label.text, size, [UIFont systemFontOfSize:LabelFontSize]);
  fitSize.height += UnderlineGap;// + UnderlineHeight;
  return fitSize;
}
//__________________________________________________________________________________________________

- (void)bounceDot
{
  if (!DotVisible)
  {
    self.dotVisible = YES;
  }
  else
  {
    [Dot bounceDot];
  }
}
//__________________________________________________________________________________________________

- (void)setTitle:(NSString *)title
{
  Label.text = title;
  [self setNeedsLayout];
}
//__________________________________________________________________________________________________

- (NSString*)title
{
  return Label.text;
}
//__________________________________________________________________________________________________

- (CGFloat)titleWidth
{
  return self.width * IdleScale;
}
//__________________________________________________________________________________________________

- (void)setEnabled:(BOOL)enabled
{
  if (!self.enabled && enabled)
  {
    self.userInteractionEnabled = YES;
    NSLog(@"1 HeaderButton setEnabled E_PopViewState_Idle");
    [self animateToState:E_PopViewState_Idle];
  }
  else if (!enabled)
  {
    NSLog(@"2 HeaderButton setEnabled E_PopViewState_Disabled");
    [self animateToState:E_PopViewState_Disabled];
  }
}
//__________________________________________________________________________________________________

- (BOOL)enabled
{
  return (CurrentButtonState != E_PopViewState_Disabled) && (CurrentButtonState != E_PopViewState_Invalid);
}
//__________________________________________________________________________________________________

- (void)setSelected:(BOOL)selected
{
  if (self.enabled)
  {
    if (!self.selected && selected)
    {
      BOOL doNotBounceToSelected = InitialSelection || (CurrentButtonState == E_PopViewState_Highlighted) || IsSpringAnimation;

      NSLog(@"1 %p HeaderButton setSelected doNotBounceToSelected: %d", self, doNotBounceToSelected);
      [self animateToState:doNotBounceToSelected? E_PopViewState_Selected: E_PopViewState_BounceToSelected];

        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"swipe25" ofType:@"aiff"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &soundEffect);

        AudioServicesPlaySystemSound(soundEffect);
    }
    else if (self.selected && !selected)
    {
      NSLog(@"2 %p HeaderButton setSelected: E_PopViewState_Idle", self);
      [self animateToState:E_PopViewState_Idle];
    }
    Selected = selected;
  }
  InitialSelection  = NO;
}
//__________________________________________________________________________________________________

- (BOOL)selected
{
  return Selected;
}
//__________________________________________________________________________________________________

- (void)setDotVisible:(BOOL)dotVisible
{
  BOOL needToBounce = (!DotVisible && dotVisible);
  if (DotVisible != dotVisible)
  {
    DotVisible = dotVisible;
    [UIView animateWithDuration:GetGlobalParameters().headerButtonDotFadeDuration animations:^
    {
      Dot.alpha = dotVisible? 1.0: 0.0;
    }];
  }
  if (needToBounce)
  {
    [self bounceDot];
  }
}
//__________________________________________________________________________________________________

- (BOOL)dotVisible
{
  return DotVisible;
}
//__________________________________________________________________________________________________

- (void)setHighlightedAction:(BlockAction)highlightedAction
{
  HighlightedAction = highlightedAction;
}
//__________________________________________________________________________________________________

- (BlockAction)highlightedAction
{
  return HighlightedAction;
}
//__________________________________________________________________________________________________

- (void)setPressedAction:(BlockAction)pressedAction
{
  PressedAction = pressedAction;
}
//__________________________________________________________________________________________________

- (BlockAction)pressedAction
{
  return PressedAction;
}
//__________________________________________________________________________________________________

- (void)animateToState:(PopViewState)state
{
  NSLog(@"1 %p HeaderButton animateToState: %d, CurrentButtonState: %d", self, state, CurrentButtonState);

  if ((state != CurrentButtonState) && (!IsSpringAnimation || !((state == E_PopViewState_Selected) && (CurrentButtonState == E_PopViewState_Highlighted))))
  {
    [self stopAnimation];
    CurrentButtonState    = state;
    StartLabelScale       = EndLabelScale;
    StartLabelColor       = EndLabelColor;
    switch (state)
    {
    case E_PopViewState_Idle:
      EndLabelScale       = IdleScale;
      EndLabelColor       = LabelColor;
      break;
    case E_PopViewState_Highlighted:
      EndLabelScale       = HighlightedLabelScale;
      EndLabelColor       = HighlightedLabelColor;
      break;
    case E_PopViewState_BounceToSelected:
      EndLabelScale       = HighlightedLabelScale;
      EndLabelColor       = HighlightedLabelColor;
      break;
    case E_PopViewState_Selected:
      EndLabelScale       = LabelScale;
      EndLabelColor       = SelectedLabelColor;
      break;
    case E_PopViewState_Disabled:
      EndLabelScale       = LabelScale;
      EndLabelColor       = DisabledLabelColor;
      break;
    default:
      break;
    }
    Animating           = YES;
    self.animationValue = 0.0;
    [self animateToValue:1.0 animateStep:^(CGFloat parameterValue)
    {
      [self stateAnimationStep:parameterValue];
    } completion:^
    {
      if (CurrentButtonState == E_PopViewState_BounceToSelected)
      {
        NSLog(@"2 HeaderButton animateToState: %d", state);
        [self animateToState:E_PopViewState_Selected];
      }
      else
      {
        if (CurrentButtonState == E_PopViewState_Disabled)
        {
          self.userInteractionEnabled = NO;
        }
        Animating = NO;
      }
    }];
  }
}
//__________________________________________________________________________________________________

- (void)stateAnimationStep:(CGFloat)animationValue
{
//  NSLog(@"setAnimationValue: %f", animationValue);
  GlobalParameters* parameters      = GetGlobalParameters();
  CGFloat scale                     = InterpolateFloat(animationValue, StartLabelScale, EndLabelScale);
  Label.transform                   = CGAffineTransformMakeScale(scale, scale);
  Label.textColor                   = InterpolateColor(min(1, animationValue), E_InterpolateRgb, StartLabelColor, EndLabelColor);
  Dot.center                        = CGPointMake((self.width + Label.width) / 2 + parameters.headerButtonDotHorizontalOffset, Label.center.y - Label.bounds.size.height * scale / 2 + parameters.headerButtonDotVerticalOffset);
//  NSLog(@"Dot.Center: %f, %f", Dot.center.x, Dot.center.y);
}
//__________________________________________________________________________________________________

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
  SavedButtonState  = CurrentButtonState;
  UITouch*  touch   = [touches anyObject];
  CGPoint   pt      = [touch locationInView:self];
//  NSLog(@"Began %f, %f", pt.x, pt.y);
  if ([self pointInside:pt withEvent:event])
  {
    if (CurrentButtonState != E_PopViewState_Highlighted)
    {
      NSLog(@"1 HeaderButton touchesBegan E_PopViewState_Highlighted");
      [self animateToState:E_PopViewState_Highlighted];
    }
  }
  else
  {
    NSLog(@"Began out!!!!");
  }
}
//__________________________________________________________________________________________________

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
  UITouch*  touch = [touches anyObject];
  CGPoint   pt    = [touch locationInView:self];
//  NSLog(@"Moved %f, %f", pt.x, pt.y);
  if ([self pointInside:pt withEvent:event])
  {
    if (CurrentButtonState != E_PopViewState_Highlighted)
    {
      NSLog(@"1 HeaderButton touchesMoved E_PopViewState_Highlighted");
      [self animateToState:E_PopViewState_Highlighted];
    }
  }
  else
  {
    if (CurrentButtonState != SavedButtonState)
    {
      [self animateToState:SavedButtonState];
    }
  }
}
//__________________________________________________________________________________________________

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
  UITouch*  touch = [touches anyObject];
  CGPoint   pt    = [touch locationInView:self];
//  NSLog(@"End %f, %f", pt.x, pt.y);
  if ([self pointInside:pt withEvent:event])
  {
    PressedAction();
    NSLog(@"1 %p HeaderButton touchesEnded E_PopViewState_Selected", self);
    if (!IsSpringAnimation || ((CurrentButtonState != E_PopViewState_Highlighted) && (CurrentButtonState != E_PopViewState_Selected)))
    {
      [self animateToState:E_PopViewState_Selected];
    }
  }
  else
  {
    [self animateToState:SavedButtonState];
  }
}
//__________________________________________________________________________________________________

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
//  NSLog(@"Cancel");
  NSLog(@"1 HeaderButton touchesCancelled SavedButtonState");
  [self animateToState:SavedButtonState];
}
//__________________________________________________________________________________________________

@end
