
//! \file   ThreeDotsPseudoButtonView.m
//! \brief  View that display the current friend list item state.
//__________________________________________________________________________________________________

#import "ThreeDotsPseudoButtonView.h"
#import "Colors.h"
#import "GlobalParameters.h"
#import "Interpolation.h"
#import "PopBaseView.h"
//__________________________________________________________________________________________________

//! A view that draws the current friend list item state.
@interface ThreeDotsView : UIView
{
@public
  CGFloat         DotRadius;    //!< Radius of a dot.
  CGFloat         DotInterval;  //!< The distance between successive dot centers.
  UIColor*        DotColor;     //!< Color of the dots.
}
//____________________
@end
//__________________________________________________________________________________________________

//! A view that draws the current friend list item state.
@implementation ThreeDotsView
{
}

- (instancetype)init
{
  self = [super init];
  if (self != nil)
  {
  }
  return self;
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  GlobalParameters* parameters = GetGlobalParameters();
  // TODO: Add some margin to take into account the width of the line.
  return CGSizeMake(2 * (parameters.threeDotsPseudoButtonDotRadius + parameters.threeDotsPseudoButtonDotInterval) * parameters.threeDotsPseudoButtonHighlightedScaleFactor,
                    2 * parameters.threeDotsPseudoButtonDotRadius * parameters.threeDotsPseudoButtonHighlightedScaleFactor);
}
//__________________________________________________________________________________________________

//! Draw the custom content of the view.
- (void)drawRect:(CGRect)rect
{
  //  NSLog(@"ProgressRadius: %6.2f, DiskRadius: %6.2f, ProgressLineWidth: %6.2f, ProgressValue: %6.2f", ProgressRadius, DiskRadius, ProgressLineWidth, ProgressValue);
  [super drawRect:rect];
  CGSize        size          = self.bounds.size;
  CGPoint       center        = CGPointMake(size.width / 2, size.height / 2);
  CGContextRef  context       = UIGraphicsGetCurrentContext();

  CGContextSetFillColorWithColor(context, DotColor.CGColor);
  CGContextFillEllipseInRect(context, CGRectMake(center.x - DotInterval - DotRadius, center.y - DotRadius, 2 * DotRadius, 2 * DotRadius));
  CGContextFillEllipseInRect(context, CGRectMake(center.x               - DotRadius, center.y - DotRadius, 2 * DotRadius, 2 * DotRadius));
  CGContextFillEllipseInRect(context, CGRectMake(center.x + DotInterval - DotRadius, center.y - DotRadius, 2 * DotRadius, 2 * DotRadius));
}
//__________________________________________________________________________________________________

@end
//==================================================================================================

//! View that display the current friend list item state.
@interface ThreeDotsPseudoButtonView() <POPAnimationDelegate>
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! View that display the current friend list item state.
@implementation ThreeDotsPseudoButtonView
{
  ThreeDotsView*  ThreeDots;                   //!< The view displaying the three dots.
  CGFloat         StartDotRadius;
  CGFloat         EndDotRadius;
  CGFloat         StartDotInterval;
  CGFloat         EndDotInterval;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  GlobalParameters* parameters  = GetGlobalParameters();
  self.userInteractionEnabled   = NO;
  ThreeDots                     = [ThreeDotsView new];
  AnimatedView                  = ThreeDots;
  ThreeDots.backgroundColor     = Transparent;
  ThreeDots->DotColor           = parameters.threeDotsPseudoButtonColor;
  ThreeDots->DotInterval        = parameters.threeDotsPseudoButtonDotInterval;
  self.animParameters           = parameters.ThreeDotsPseudoButtonAnimParameters;
  self.state                    = E_FriendProgressState_Unselected;
  [self addSubview:ThreeDots];
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
    ThreeDots.width  = self.width  * 1.25;
    ThreeDots.height = self.height * 1.25;
    [ThreeDots centerInSuperview];
  }
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  GlobalParameters* parameters = GetGlobalParameters();
  CGSize fitSize;
  fitSize.width   = 2 * (parameters.friendStateViewProgressCircleRadius + parameters.friendStateViewCircleLineWidth);
  fitSize.height  = 2 * (parameters.friendStateViewProgressCircleRadius + parameters.friendStateViewCircleLineWidth);
  //  NSLog(@"sizeThatFits: %f, %f", fitSize.width, fitSize.height);
  return fitSize;
}
//__________________________________________________________________________________________________

- (void)setState:(FriendProgressStates)state
{
  [super setState:state];
  state = super.state;
  GlobalParameters* parameters  = GetGlobalParameters();
  if ((state == E_FriendProgressState_InProgress) || (state == E_FriendProgressState_Selected))
  {
    ThreeDots->DotRadius    = parameters.threeDotsPseudoButtonDotRadius   * parameters.threeDotsPseudoButtonHighlightedScaleFactor;
    ThreeDots->DotInterval  = parameters.threeDotsPseudoButtonDotInterval * parameters.threeDotsPseudoButtonHighlightedScaleFactor;
  }
  else
  {
    ThreeDots->DotRadius    = parameters.threeDotsPseudoButtonDotRadius;
    ThreeDots->DotInterval  = parameters.threeDotsPseudoButtonDotInterval;
  }
}
//__________________________________________________________________________________________________

- (void)setState:(FriendProgressStates)state animated:(BOOL)animated
{
  if (animated)
  {
    [self animateToState:state completion:^
    {
    }];
  }
  else
  {
    [self setState:state];
  }
}
//__________________________________________________________________________________________________

- (void)animateToState:(FriendProgressStates)state completion:(BlockAction)completionAction
{
  //  [self stopAnimation];
  GlobalParameters* parameters  = GetGlobalParameters();
  StartDotRadius                = ThreeDots->DotRadius;
  StartDotInterval              = ThreeDots->DotInterval;
  if ((state == E_FriendProgressState_InProgress) || (state == E_FriendProgressState_Selected))
  {
    EndDotRadius    = parameters.threeDotsPseudoButtonDotRadius   * parameters.threeDotsPseudoButtonHighlightedScaleFactor;
    EndDotInterval  = parameters.threeDotsPseudoButtonDotInterval * parameters.threeDotsPseudoButtonHighlightedScaleFactor;
  }
  else
  {
    EndDotRadius    = parameters.threeDotsPseudoButtonDotRadius;
    EndDotInterval  = parameters.threeDotsPseudoButtonDotInterval;
  }
  [super animateToState:state completion:^
  {
    if (state == E_FriendProgressState_Selected)
    {
      [self animateToState:E_FriendProgressState_Unselected completion:^
      {
        completionAction();
      }];
    }
    else
    {
      completionAction();
    }
  }];
}
//__________________________________________________________________________________________________

- (void)stateAnimationStep:(CGFloat)animationValue
{
  ThreeDots->DotRadius    = InterpolateFloat(animationValue, StartDotRadius   , EndDotRadius);
  ThreeDots->DotInterval  = InterpolateFloat(animationValue, StartDotInterval , EndDotInterval);
//  NSLog(@"stateAnimationStep: %f, radius: %6.2f, interval: %6.2f", animationValue, ThreeDots->DotRadius, ThreeDots->DotInterval);
  [ThreeDots setNeedsDisplay];
}
//__________________________________________________________________________________________________

- (void)cancelAnimation
{
  [self stopAnimation];
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________

