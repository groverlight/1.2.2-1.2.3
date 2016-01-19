
//! \file   WhiteButton.m
//! \brief  Button with with dot, underlined label and POP animation.
//__________________________________________________________________________________________________

#import "WhiteButton.h"
#import "Colors.h"
#import "GlobalParameters.h"
#import "Interpolation.h"
#import "PopLabel.h"
#import "Tools.h"
#import "TopBarView.h"
//__________________________________________________________________________________________________

//! Button with with dot, underlined label and POP animation.
@implementation WhiteButton
{
  UILabel*      Label;
  BlockAction   HighlightedAction;
  BlockAction   PressedAction;
  PopViewState  CurrentButtonState;
  PopViewState  SavedButtonState;
  CGFloat       IdleScale;
  CGFloat       LabelFontSize;
  CGFloat       LabelScale;
  CGFloat       HighlightedLabelScale;
  UIColor*      LabelColor;
  UIColor*      HighlightedLabelColor;
  UIColor*      SelectedLabelColor;
  UIColor*      DisabledLabelColor;

  // Variables for animation.
  CGFloat       StartLabelScale;
  CGFloat       EndLabelScale;
  UIColor*      StartLabelColor;
  UIColor*      EndLabelColor;
  BOOL          NeverLayouted;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  NeverLayouted                 = YES;

  GlobalParameters* parameters  = GetGlobalParameters();
  self.animParameters           = parameters.whiteButtonAnimParameters;
  LabelScale                    = 1 / parameters.whiteButtonBounceScaleFactor;
  HighlightedLabelScale         = 1.0;
  IdleScale                     = HighlightedLabelScale /  parameters.headerButtonBounceScaleFactor;
  LabelFontSize                 = floor(parameters.headerButtonFontSize / IdleScale);
  CurrentButtonState            = E_PopViewState_Invalid;
  SavedButtonState              = E_PopViewState_Invalid;
  EndLabelScale                 = LabelScale;
  LabelColor                    = parameters.whiteButtonIdleColor;
  HighlightedLabelColor         = parameters.whiteButtonHighlightedColor;
  DisabledLabelColor            = parameters.whiteButtonDisabledColor;

  StartLabelColor               = LabelColor;
  EndLabelColor                 = LabelColor;

  self.backgroundColor          = TypePink;
  Label                         = [UILabel  new];
  Label.font                    = [UIFont fontWithName:@"AvenirNext-Bold" size:parameters.whiteButtonFontSize];;
  Label.textAlignment           = NSTextAlignmentCenter;
  Label.textColor               = LabelColor;
  [self addSubview:Label];

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
  Label.transform         = CGAffineTransformMakeScale(LabelScale, LabelScale);
  Label.bounds            = self.bounds;
  Label.center            = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
  self.animationValue     = 1;
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  // Do not call [super LayoutSubviews] for this class. It makes unwanted things.
  self.layer.cornerRadius = self.height / 2;
//  NSLog(@"1 WhiteButton layoutSubviews");
  if (NeverLayouted || ((NumAnimationInProgress == 0) && !WasAnimating))
  {
//    NSLog(@"2 WhiteButton layoutSubviews");
    [self layout];
    NeverLayouted = NO;
  }
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  CGSize fitSize;
  fitSize.width   = CalculateTextSize(Label.text, size, [UIFont systemFontOfSize:LabelFontSize]).width;
  fitSize.height  = GetGlobalParameters().whiteButtonHeight;
  return fitSize;
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

- (void)setEnabled:(BOOL)enabled
{
  self.userInteractionEnabled = enabled;
 //  NSLog(@"WhiteButton: setEnabled: %d", self.userInteractionEnabled);
  if (!self.enabled && enabled)
  {
    [self animateToState:E_PopViewState_Idle completion:^
    {
      self.userInteractionEnabled = YES;
    }];
  }
  else if (!enabled)
  {
    [self animateToState:E_PopViewState_Disabled completion:^
    {
      self.userInteractionEnabled = NO;
    }];
  }
}
//__________________________________________________________________________________________________

- (BOOL)enabled
{
  return CurrentButtonState != E_PopViewState_Disabled;
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

- (void)animateToState:(PopViewState)state completion:(BlockAction)completion
{
  if (state != CurrentButtonState)
  {
    [self stopAnimation];
  //  NSLog(@"animateToState %@", Label.text);
    CurrentButtonState    = state;
    StartLabelScale       = EndLabelScale;
    StartLabelColor       = EndLabelColor;
    switch (state)
    {
    case E_PopViewState_Idle:
      EndLabelScale       = LabelScale;
      EndLabelColor       = LabelColor;
            
      break;
    case E_PopViewState_Highlighted:
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
    self.animationValue = 0.0;
    [self animateToValue:1.0 animateStep:^(CGFloat parameterValue)
    {
      [self stateAnimationStep:parameterValue];
    } completion:^
    {
      completion();
    }];
  }
}
//__________________________________________________________________________________________________

- (void)stateAnimationStep:(CGFloat)animationValue
{
//  NSLog(@"setAnimationValue: %f", animationValue);
//  GlobalParameters* parameters      = GetGlobalParameters();
  CGFloat scale                     = InterpolateFloat(animationValue, StartLabelScale, EndLabelScale);
  Label.transform                   = CGAffineTransformMakeScale(scale, scale);
  Label.textColor                   = InterpolateColor(min(1, animationValue), E_InterpolateRgb, StartLabelColor, EndLabelColor);
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
      [self animateToState:E_PopViewState_Highlighted completion:^
      { // Do nothing!
      }];
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
      [self animateToState:E_PopViewState_Highlighted completion:^
      { // Do nothing!
      }];
    }
  }
  else
  {
    [self animateToState:SavedButtonState completion:^
    { // Do nothing!
    }];
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
    [self animateToState:self.enabled? E_PopViewState_Idle: E_PopViewState_Disabled completion:^
    { // Do nothing!
    }];
  }
  else
  {
    [self animateToState:SavedButtonState completion:^
    { // Do nothing!
    }];
  }
}
//__________________________________________________________________________________________________

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
//  NSLog(@"Cancel");
  [self animateToState:SavedButtonState completion:^
  { // Do nothing!
  }];
}
//__________________________________________________________________________________________________

@end
