
//! \file   GradientView.m
//! A UIView class that adds some common features.
//__________________________________________________________________________________________________

#import "GradientView.h"
#import "Colors.h"
#import "HsvGradient.h"
//__________________________________________________________________________________________________

GradientView* AppGradientBackgroundView = nil;
//__________________________________________________________________________________________________

GradientView* GetAppGradientBackgroundView(void)
{
  if (AppGradientBackgroundView == nil)
  {
    AppGradientBackgroundView = [[GradientView alloc] initWithFrame:CGRectZero];
  }
  return AppGradientBackgroundView;
}
//__________________________________________________________________________________________________

//! A UIView class that adds some common features.
@interface GradientView()
{
  UIColor*      BackColor;
  UIColor*      Color1;
  UIColor*      Color2;
  BOOL          HorizontalGradient;
  HsvGradient*  Gradient;
}
//____________________

//____________________

@end
//__________________________________________________________________________________________________

//! A UIView class that add some common features.
@implementation GradientView

//! Initialize the object however it has been created.
-(void)Initialize
{
  self.backgroundColor  = Black;
  self.defaultColor1    = LightGrey;
  self.defaultColor2    = White;
  self.color1           = self.defaultColor1;
  self.color2           = self.defaultColor2;
  HorizontalGradient    = false;
  Gradient              = [[HsvGradient alloc] init];
  self.gradientType     = E_GradientType_RGB;
  self.mode             = E_InterpolateHueUp;
}
//__________________________________________________________________________________________________

//! Draw the custom content of the view.
- (void)drawRect:(CGRect)rect
{
  [Gradient SetGradientColorModel:self.gradientType];
  [super drawRect:rect];
  CGContextRef context = UIGraphicsGetCurrentContext();

  Gradient->StartColor  = self.color1;
  Gradient->EndColor    = self.color2;
  Gradient->Mode        = self.mode;

  CGPoint start_point;
  CGPoint end_point;
  if (HorizontalGradient)
  {
    start_point = CGPointMake(rect.origin.x                   , rect.size.height / 2);
    end_point   = CGPointMake(rect.origin.x + rect.size.width , rect.size.height / 2);
  }
  else
  {
    start_point = CGPointMake(rect.size.width / 2, rect.origin.y);
    end_point   = CGPointMake(rect.size.width / 2, rect.origin.y + rect.size.height);
  }
  [Gradient DrawLinearGradientInContext:context :start_point :end_point :0];
}
//__________________________________________________________________________________________________

- (void)setBackgroundColor:(UIColor*)backgroundColor
{
  BackColor             = backgroundColor;
  Color1                = backgroundColor;
  Color2                = backgroundColor;
  super.backgroundColor = Transparent;
  [self setNeedsDisplay];
}
//__________________________________________________________________________________________________

- (UIColor*)backgroundColor
{
  return BackColor;
}
//__________________________________________________________________________________________________

- (void)setColor1:(UIColor*)color1
{
  Color1 = color1;
  [self setNeedsDisplay];
}
//__________________________________________________________________________________________________

- (UIColor*)color1
{
  return Color1;
}
//__________________________________________________________________________________________________

- (void)setColor2:(UIColor*)color2
{
  Color2 = color2;
  [self setNeedsDisplay];
}
//__________________________________________________________________________________________________

- (UIColor*)color2
{
  return Color2;
}
//__________________________________________________________________________________________________

- (void)setHorizontal:(BOOL)horizontal
{
  HorizontalGradient = horizontal;
  [self setNeedsDisplay];
}
//__________________________________________________________________________________________________

- (BOOL)horizontal
{
  return HorizontalGradient;
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
