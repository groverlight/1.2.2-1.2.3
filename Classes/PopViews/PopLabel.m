
//! \file   PopLabel.m
//! \brief  Class that implements an animated label using the POP library.
//__________________________________________________________________________________________________

#import "PopLabel.h"
#import "Colors.h"
//__________________________________________________________________________________________________

//! Class that implements an animated label using the POP library.
@interface PopLabel() <POPAnimationDelegate>
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! Class that implements an animated label using the POP library.
@implementation PopLabel
{
  NSString*   Text;       //!< Label text string.
  UIFont*     Font;       //!< Label font.
  UILabel*    Label;      //!< Label object.
  UIColor*    TextColor;  //!< Cached color of the label text.
  BOOL        Outline;
  BlockAction TextColorAnimCompletionAction;
  BlockAction TextFontSizeAnimCompletionAction;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  TextColor           = Black;
  Outline             = NO;
  Text                = @"";
  Label               = [UILabel new];
  Label.textAlignment = NSTextAlignmentCenter;
  Font                = Label.font;
  AnimatedView        = Label;
  [self addSubview:Label];
  TextColorAnimCompletionAction = ^
  { // Default action: Do nothing!
  };
  TextFontSizeAnimCompletionAction = ^
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

- (void)layoutSubviews
{
  [super layoutSubviews];
  if ((NumAnimationInProgress == 0) && (!WasAnimating || UseFontAnimation))
  {
    if ((self.bounds.size.width > 0) && (self.bounds.size.height > 0))
    {
      Label.bounds = self.bounds;
      Label.centerX = self.width  / 2;
      Label.centerY = self.height / 2;
    }
  }
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  CGSize labelSize = [Label sizeThatFits:size];
  labelSize.width   = ceil(labelSize.width  * 1.25);
  labelSize.height  = ceil(labelSize.height * 1.25);
  return labelSize;
}
//__________________________________________________________________________________________________

- (void)updateAttributedText
{
  NSDictionary* attributesDict = @{NSKernAttributeName            : @0.0,
                                   NSBaselineOffsetAttributeName  : @0.1,
                                   NSFontAttributeName            : Font,
                                   NSForegroundColorAttributeName : (Outline? Transparent: TextColor),
                                   NSStrokeColorAttributeName     : TextColor,
                                   NSStrokeWidthAttributeName     : (Outline? @-3: @-0.001)};
  // Make the attributed string.
  NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:Text attributes:attributesDict];
  Label.attributedText = attrString;
}
//__________________________________________________________________________________________________

- (void)setText:(NSString*)text
{
  Text = text;
  [self updateAttributedText];
}
//__________________________________________________________________________________________________

- (NSString*)text
{
  return Text;
}
//__________________________________________________________________________________________________

- (void)setTextColor:(UIColor *)textColor
{
  TextColor = textColor;
  [self updateAttributedText];
}
//__________________________________________________________________________________________________

- (UIColor*)textColor
{
  return TextColor;
}
//__________________________________________________________________________________________________

- (void)setOutline:(BOOL)outline
{
  Outline = outline;
  [self updateAttributedText];
}
//__________________________________________________________________________________________________

- (BOOL)outline
{
  return Outline;
}
//__________________________________________________________________________________________________

- (void)setTextColor:(UIColor *)textColor
      animationStyle:(PopAnimationStyle)style
       animateDuring:(CGFloat)seconds
{
  if (seconds > 0)
  {
    [self animateTextToColor:textColor
              animationStyle:style
                      during:seconds];
  }
  else
  {
    TextColor = textColor;
    [self updateAttributedText];
  }
}
//__________________________________________________________________________________________________

- (void)pop_animationDidStop:(POPAnimation*)anim finished:(BOOL)finished
{
  if ([anim.name isEqual:kPopLabelFontSizeAnimation])
  {
    TextFontSizeAnimCompletionAction();
  }
  else if ([anim.name isEqual:kPopLabelTextColorAnimation])
  {
    TextColorAnimCompletionAction();
  }
  else
  {
    [super pop_animationDidStop:anim finished:finished];
  }
}
//__________________________________________________________________________________________________

//! Set the label font size using the specified animation parameters.
- (void)setFontSize:(CGFloat)fontSize
         parameters:(PopAnimParameters*)parameters
         completion:(BlockAction)completion
{
  TextFontSizeAnimCompletionAction  = completion;
  POPPropertyAnimation* anim        = [self CreateAnimationWithStyle:parameters.animationStyle];
  anim.property                     = [self prepareFontAnimationProperty];
  anim.toValue                      = [NSNumber numberWithFloat:fontSize];
  anim.name                         = kPopLabelFontSizeAnimation;
  anim.delegate                     = self;
  switch (parameters.animationStyle)
  {
  case E_PopAnimationStyle_Basic:
    ((POPBasicAnimation*)anim).duration = parameters.duration;
    break;
  case E_PopAnimationStyle_Spring:
    ((POPSpringAnimation*)anim).springBounciness  = parameters.bounciness;
    ((POPSpringAnimation*)anim).velocity          = [NSNumber numberWithFloat:parameters.velocity];
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
  [Label pop_addAnimation:anim forKey:kPopLabelFontSizeAnimation];
}
//__________________________________________________________________________________________________

//! Set the label text color color using the specified animation parameters.
- (void)setTextColor:(UIColor*)textColor
          parameters:(PopAnimParameters*)parameters
          completion:(BlockAction)completion
{
  TextColorAnimCompletionAction = completion;
  POPPropertyAnimation* anim    = [self CreateAnimationWithStyle:parameters.animationStyle];
  anim.property                 = [self prepareTextColorAnimationProperty];
  anim.toValue                  = textColor;
  anim.name                     = kPopLabelTextColorAnimation;
  anim.delegate                 = self;
  switch (parameters.animationStyle)
  {
  case E_PopAnimationStyle_Basic:
    ((POPBasicAnimation*)anim).duration = parameters.duration;
    break;
  case E_PopAnimationStyle_Spring:
    ((POPSpringAnimation*)anim).springBounciness  = parameters.bounciness;
    ((POPSpringAnimation*)anim).velocity          = [NSNumber numberWithFloat:parameters.velocity];
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
  [Label pop_addAnimation:anim forKey:kPopLabelTextColorAnimation];
}
//__________________________________________________________________________________________________

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
  Label.textAlignment = textAlignment;
}
//__________________________________________________________________________________________________

- (NSTextAlignment)textAlignment
{
  return Label.textAlignment;
}
//__________________________________________________________________________________________________

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
  Label.numberOfLines = numberOfLines;
}
//__________________________________________________________________________________________________

- (NSInteger)numberOfLines
{
  return Label.numberOfLines;
}
//__________________________________________________________________________________________________

- (void)setFont:(UIFont *)font
{
  Font = font;
  [self updateAttributedText];
}
//__________________________________________________________________________________________________

- (UIFont*)font
{
  return Label.font;
}
//__________________________________________________________________________________________________

- (void)setFontSize:(CGFloat)fontSize basicAnimateDuring:(CGFloat)seconds
{
  if (seconds > 0)
  {
    [self basicAnimateFontToSize:fontSize during:seconds];
  }
  else
  {
    self.font = [self.font fontWithSize:fontSize];
  }
}
//__________________________________________________________________________________________________

- (void)setFontSize:(CGFloat)fontSize springAnimateWithBounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity
{
  if (velocity > 0)
  {
    [self springAnimateFontToSize:fontSize bounciness:bounciness andVelocity:velocity];
  }
  else
  {
    self.font = [self.font fontWithSize:fontSize];
  }
}
//__________________________________________________________________________________________________

- (void)setFontSize:(CGFloat)fontSize decayAnimateWithDeceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity
{
  if (velocity != 0)
  {
    [self decayAnimateFontToSize:fontSize deceleration:deceleration andVelocity:velocity];
  }
  else
  {
    self.font = [self.font fontWithSize:fontSize];
  }
}
//__________________________________________________________________________________________________

- (void)basicAnimateFontToSize:(CGFloat)fontSize during:(CGFloat)seconds
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Basic];
  anim.property               = [self prepareFontAnimationProperty];
  anim.toValue                = [NSNumber numberWithFloat:fontSize];
  anim.name                   = kPopLabelFontSizeAnimation;
  anim.delegate               = self;
  ((POPBasicAnimation*)anim).duration = seconds;
  [Label pop_addAnimation:anim forKey:kPopLabelFontSizeAnimation];
}
//__________________________________________________________________________________________________

- (void)springAnimateFontToSize:(CGFloat)fontSize bounciness:(CGFloat)bounciness andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Spring];
  anim.property               = [self prepareFontAnimationProperty];
  anim.toValue                = [NSNumber numberWithFloat:fontSize];
  anim.name                   = kPopLabelFontSizeAnimation;
  anim.delegate               = self;
  ((POPSpringAnimation*)anim).springBounciness  = bounciness;
  ((POPSpringAnimation*)anim).velocity          = [NSNumber numberWithFloat:velocity];
  [Label pop_addAnimation:anim forKey:kPopLabelFontSizeAnimation];
}
//__________________________________________________________________________________________________

- (void)decayAnimateFontToSize:(CGFloat)fontSize deceleration:(CGFloat)deceleration andVelocity:(CGFloat)velocity
{
  UseFontAnimation            = YES;
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:E_PopAnimationStyle_Decay];
  anim.property               = [self prepareFontAnimationProperty];
  anim.toValue                = [NSNumber numberWithFloat:fontSize];
  anim.name                   = kPopLabelFontSizeAnimation;
  anim.delegate               = self;
  ((POPDecayAnimation*)anim).deceleration = deceleration;
  ((POPDecayAnimation*)anim).velocity     = [NSNumber numberWithFloat:velocity];
  [Label pop_addAnimation:anim forKey:kPopLabelFontSizeAnimation];
}
//__________________________________________________________________________________________________

- (void)animateTextToColor:(UIColor*)color
            animationStyle:(PopAnimationStyle)style
                    during:(CGFloat)seconds
{
  POPPropertyAnimation* anim  = [self CreateAnimationWithStyle:style];
  anim.property               = [self prepareTextColorAnimationProperty];
  anim.toValue                = color;
  anim.name                   = kPopLabelTextColorAnimation;
  anim.delegate               = self;
  switch (style)
  {
  case E_PopAnimationStyle_Basic:
    ((POPBasicAnimation*)anim).duration = seconds;
    break;
  default:
    break;
  }
  [Label pop_addAnimation:anim forKey:kPopLabelTextColorAnimation];
}
//__________________________________________________________________________________________________

- (void)stopTextColorAnimation
{
  [Label pop_removeAnimationForKey:kPopLabelTextColorAnimation];
}
//__________________________________________________________________________________________________

- (void)stopFontSizeAnimation
{
  [Label pop_removeAnimationForKey:kPopLabelFontSizeAnimation];
}
//__________________________________________________________________________________________________

- (POPAnimatableProperty*)prepareFontAnimationProperty
{
  POPAnimatableProperty* fontProp = [POPAnimatableProperty propertyWithName:@"labelFontAnimProp" initializer:^(POPMutableAnimatableProperty* prop)
  {
    // Read value
    prop.readBlock = ^(PopLabel* label, CGFloat values[])
    {
      values[0] = label.font.pointSize;
    };
    // Write value
    prop.writeBlock = ^(PopLabel* label, const CGFloat values[])
    {
      label.font = [label.font fontWithSize:values[0]];
    };
    // dynamics threshold
    prop.threshold = 0.01;
  }];

  return fontProp;
}
//__________________________________________________________________________________________________

- (POPAnimatableProperty*)prepareTextColorAnimationProperty
{
  POPAnimatableProperty* colorProp = [POPAnimatableProperty propertyWithName:@"LabelTextColorAnimProp" initializer:^(POPMutableAnimatableProperty* prop)
  {
    // Read value.
    prop.readBlock = ^(PopLabel* label, CGFloat values[])
    {
      POPUIColorGetRGBAComponents(label.textColor, values);
    };
    // Write value.
    prop.writeBlock = ^(PopLabel* label, const CGFloat values[])
    {
      label.textColor = POPUIColorRGBACreate(values);
    };
    // Dynamics threshold.
    prop.threshold = 0.01;
  }];

  return colorProp;
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
