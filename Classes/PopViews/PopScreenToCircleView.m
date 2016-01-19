
//! \file   PopScreenToCircleView.m
//! \brief  Class that handle a POP animations between a full screen view and a circled view.
//__________________________________________________________________________________________________

#import "Colors.h"
#import "PopScreenToCircleView.h"
#import "Tools.h"
//__________________________________________________________________________________________________

//! Class that handle a POP animations between a full screen view and a circled view.
@interface PopScreenToCircleView()
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! Class that handle a POP animations between a full screen view and a circled view.
@implementation PopScreenToCircleView
{
  UIView*   ContainerView;          //!< Intermediate container view.
  BaseView* ContentView;            //!< Content view. Set by the application.
  CGPoint   ScreenCenter;           //!< Center of the view bounds when in screen state.
  CGSize    ScreenSize;             //!< Size of the view bounds when in screen state.
  CGFloat   CircleRadius;           //!< Circle radius when in circle state.
  CGPoint   CircleCenter;           //!< Circle center when in circle state.
  UIColor*  FadingBackgroundColor;  //!< background color that is opaque when in screen state and transparent in circle state.
  CGFloat   FadingBackgroundColorAlpha;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  ContainerView         = [UIView new];
  FadingBackgroundColor = Black;
  [self addSubview:ContainerView];
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
  if ((NumAnimationInProgress == 0) && (!WasAnimating))
  {
    CGRect frame       = self.frame;
//    NSLog(@"PopScreenToCircleView frame: %8.3f, %8.3f %8.3f, %8.3f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    frame.origin.x = 0;
    frame.origin.y = 0;
    ContainerView.frame = frame;
    ContentView.frame   = frame;
    ScreenSize          = frame.size;
    ScreenCenter        = CGPointMake(frame.size.width / 2, frame.size.height / 2);
  }
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  return [ContentView sizeThatFits:size];
}
//__________________________________________________________________________________________________

- (void)setBackgroundColor:(UIColor*)backgroundColor
{
  FadingBackgroundColor = backgroundColor;
  CGFloat red,green,blue;
  [backgroundColor getRed:&red green:&green blue:&blue alpha:&FadingBackgroundColorAlpha];
  super.backgroundColor = [FadingBackgroundColor colorWithAlphaComponent:1.0 - self.animationValue];
}
//__________________________________________________________________________________________________

- (UIColor*)backgroundColor
{
  return FadingBackgroundColor;
}
//__________________________________________________________________________________________________

- (void)setCircleRadius:(CGFloat)circleRadius
{
  CircleRadius = circleRadius;
}
//__________________________________________________________________________________________________

- (CGFloat)circleRadius
{
  return CircleRadius;
}
//__________________________________________________________________________________________________

- (void)setCircleCenter:(CGPoint)circleCenter
{
  CircleCenter = circleCenter;
}
//__________________________________________________________________________________________________

- (CGPoint)circleCenter
{
  return  CircleCenter;
}
//__________________________________________________________________________________________________

- (void)setContentView:(BaseView *)contentView
{
  ContentView       = contentView;
  ContentView.frame = ContainerView.bounds;
  AnimatedView      = ContentView;
  [ContainerView addSubview:ContentView];
  ContentView.backgroundColor = IsSimulator()? Brown: Transparent;
}
//__________________________________________________________________________________________________

- (BaseView*)contentView
{
  return ContentView;
}
//__________________________________________________________________________________________________

- (void)setAnimationValue:(CGFloat)animationValue
{
  super.animationValue = animationValue;
  CGFloat counterAnimationValue = 1.0 - animationValue;
  CGPoint center;
  center.x = ScreenCenter.x * counterAnimationValue + CircleCenter.x * (animationValue);
  center.y = ScreenCenter.y * counterAnimationValue + CircleCenter.y * (animationValue);
  CGRect bounds;
  bounds.origin.x = 0;
  bounds.origin.y = 0;
  CGFloat diameter  =  2 * CircleRadius;
  CGFloat width   = (ScreenSize.width  - diameter) * counterAnimationValue;
  CGFloat height  = (ScreenSize.height - diameter) * counterAnimationValue;
  if (animationValue > 1.0)
  {
    width   = (width + height) / 2;
    height  = width;
  }
  bounds.size.width               = diameter + width;
  bounds.size.height              = diameter + height;
  CGFloat radius                  = (minmax(0.0, animationValue, 1.0)) * min(bounds.size.width, bounds.size.height) / 2;
  AnimatedView.center             = center;
  AnimatedView.bounds             = bounds;
  AnimatedView.layer.cornerRadius = radius;
  super.backgroundColor           = [FadingBackgroundColor colorWithAlphaComponent:(1.0 - self.animationValue) * FadingBackgroundColorAlpha];
//  NSLog(@"layer: %p, animValue: %7.3f, x: %8.3f, y: %8.3f, w: %8.3f, h: %8.3f, r: %8.3f", AnimatedView.layer, animationValue, self.center.x, self.center.y, self.bounds.size.width, self.bounds.size.height, radius);
}
//__________________________________________________________________________________________________

- (void)animateToScreenWithCompletion:(BlockIdAction)completion
{
  self.animationCompleted = completion;
  [self animateToValue:0.0 withAnimationStyle:E_PopAnimationStyle_Spring];
}
//__________________________________________________________________________________________________

- (void)animateToCircleWithCompletion:(BlockIdAction)completion
{
  self.animationCompleted = completion;
  [self animateToValue:1.0 withAnimationStyle:E_PopAnimationStyle_Spring];
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________
