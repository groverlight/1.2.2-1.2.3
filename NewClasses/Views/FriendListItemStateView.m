
//! \file   FriendListItemStateView.m
//! \brief  View that display the current friend list item state.
//__________________________________________________________________________________________________

#import "FriendListItemStateView.h"
#import "Colors.h"
#import "GlobalParameters.h"
#import "Interpolation.h"
#import "PopBaseView.h"
//__________________________________________________________________________________________________

//! A view that draws the current friend list item state.
@interface FriendItemStateView : UIView
{
@public
  CGFloat         ProgressRadius;       //!< The radius of the displayed progress indicator.
  CGFloat         DiskRadius;           //!< Radius of the central disk.
  CGFloat         ProgressLineWidth;    //!< The width of the progress indicator line.
  UIColor*        ProgressColor;        //!< Color of the progress indicator.
  UIColor*        DiskColor;            //!< Color of the central disk.
}
//____________________

@property CGFloat progressValue;  //!< Current progress value.
//____________________

- (void)animateProgressToValue:(CGFloat)progressValue during:(CGFloat)duration completion:(BlockBoolAction)completion;
//____________________

- (void)stopAnimation;
//____________________
@end
//__________________________________________________________________________________________________

//! A view that draws the current friend list item state.
@implementation FriendItemStateView
{
  CGFloat         CurrentProgressValue; //!< Current progress value.
  CADisplayLink*  DisplayLink;          //!< Timer synchronized with display drawing frame rate.
  CFTimeInterval  StartTimeStamp;
  CFTimeInterval  PreviousTimeStamp;
  CGFloat         StartProgressValue;
  CGFloat         EndProgressValue;
  CFTimeInterval  AnimationDuration;
  CFTimeInterval  CummulatedTime;
  BlockBoolAction AnimationEnded;
}

- (instancetype)init
{
  self = [super init];
  if (self != nil)
  {
    DisplayLink               = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    DisplayLink.paused        = YES;
    DisplayLink.frameInterval = 1;
    [DisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    AnimationEnded = ^(BOOL completed)
    { // Default action: do nothing!
    };
  }
  return self;
}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [DisplayLink invalidate];
}
//__________________________________________________________________________________________________

- (void)animateProgressToValue:(CGFloat)progressValue during:(CGFloat)duration completion:(BlockBoolAction)completion
{
  AnimationEnded      = completion;
  AnimationDuration   = duration;
  StartTimeStamp      = 0;
  CummulatedTime      = 0;
  StartProgressValue  = CurrentProgressValue;
  EndProgressValue    = progressValue;
  DisplayLink.paused  = NO;
}
//__________________________________________________________________________________________________

- (void)stopAnimation
{
  bool completed      = DisplayLink.paused;
  DisplayLink.paused  = YES;
  AnimationEnded(completed);
  AnimationEnded = ^(BOOL dummy)
  { // Default action: do nothing!
  };
}
//__________________________________________________________________________________________________

- (void)renderMainThread
{
  CFTimeInterval parametricValue  = CummulatedTime / AnimationDuration;
//  NSLog(@"deltaTime: %f (%f, %f, %f, %f), ", parametricValue, DisplayLink.timestamp, StartTimeStamp, DisplayLink.timestamp - StartTimeStamp, AnimationDuration);
  self.progressValue = InterpolateFloat(parametricValue, StartProgressValue, EndProgressValue);
}
//__________________________________________________________________________________________________

- (void)render
{
  CFTimeInterval timestamp = DisplayLink.timestamp;
  if (StartTimeStamp == 0)
  {
    StartTimeStamp    = timestamp;
    PreviousTimeStamp = timestamp;
  }
  CummulatedTime           += (timestamp - PreviousTimeStamp) / AnimationDragCoefficient();
  PreviousTimeStamp         = timestamp;
  CFTimeInterval parametricValue  = CummulatedTime / AnimationDuration;
  if (parametricValue >= 1.0)
  {
    DisplayLink.paused = YES;
    AnimationEnded(YES);
    AnimationEnded = ^(BOOL completed)
    { // Default action: do nothing!
    };
  }
  [self performSelectorOnMainThread:@selector(renderMainThread) withObject:nil waitUntilDone:NO];
}
//__________________________________________________________________________________________________

- (void)setProgressValue:(CGFloat)progressValue
{
  CurrentProgressValue = progressValue;
  [self setNeedsDisplay];
}
//__________________________________________________________________________________________________

- (CGFloat)progressValue
{
  return CurrentProgressValue;
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  // TODO: Add some margin to take into account the width of the line.
  return CGSizeMake((ProgressRadius + ProgressLineWidth) * 2, (ProgressRadius + ProgressLineWidth) * 2);
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


  CGContextSetFillColorWithColor(context, DiskColor.CGColor);
  CGContextFillEllipseInRect(context, CGRectMake(center.x - DiskRadius, center.y - DiskRadius, 2 * DiskRadius, 2 * DiskRadius));

  CGContextSetLineCap(context, kCGLineCapRound);
  CGContextSetStrokeColorWithColor(context, ProgressColor.CGColor);
  CGContextSetLineWidth(context, ProgressLineWidth);
  CGFloat startAngle  = -2 * M_PI * CurrentProgressValue - M_PI_2;
  CGFloat endAngle    = -M_PI_2;
//  NSLog(@"CurrentProgressValue: %f, startAngle: %f, endAngle: %f", CurrentProgressValue, startAngle, endAngle);
  CGContextAddArc(context, center.x, center.y, ProgressRadius, startAngle, endAngle, 0);
  CGContextStrokePath(context);
}
//__________________________________________________________________________________________________

@end
//==================================================================================================

//! View that display the current friend list item state.
@interface FriendListItemStateView() <POPAnimationDelegate>
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! View that display the current friend list item state.
@implementation FriendListItemStateView
{
  FriendItemStateView*  Progress;                   //!< The view displaying the progress indicator.
  UIColor*              StartProgressValue;
  UIColor*              EndProgressValue;
  UIColor*              StartDiskColor;
  UIColor*              EndDiskColor;
  UIColor*              StartProgressColor;
  UIColor*              EndProgressColor;
  CGFloat               StartProgressRadius;
  CGFloat               EndProgressRadius;
  CGFloat               StartDiskRadius;
  CGFloat               EndDiskRadius;
  CGFloat               ProgressAnimDuration;       //!< Copy of the original progress animation duration.
  UIColor*              TransparentColor;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  GlobalParameters* parameters    = GetGlobalParameters();
  self.userInteractionEnabled     = NO;
  Progress                        = [FriendItemStateView new];
  AnimatedView                    = Progress;
  TransparentColor                = [parameters.friendStateViewColor colorWithAlphaComponent:0.0];
  Progress.backgroundColor        = Transparent;
  Progress->DiskColor             = TransparentColor;
  Progress->ProgressColor         = TransparentColor;
  Progress->ProgressLineWidth     = parameters.friendStateViewCircleLineWidth;
  Progress->ProgressRadius        = parameters.friendStateViewCircleRadius;
  Progress->DiskRadius            = parameters.friendStateViewDiskRadius;
  Progress.progressValue          = 1.0;
  ProgressAnimDuration            = parameters.friendStateViewProgressAnimationDuration;
  self.animParameters             = parameters.friendStateViewAnimParameters;
  self.state                      = E_FriendProgressState_Blank;
  UseBlankState                   = YES;
  [self addSubview:Progress];
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
    Progress.width  = self.width  * 1.25;
    Progress.height = self.height * 1.25;
    [Progress centerInSuperview];
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

- (void)setProgressValue:(CGFloat)progressValue
{
  Progress.progressValue = progressValue;
}
//__________________________________________________________________________________________________

- (CGFloat)progressValue
{
  return Progress.progressValue;
}
//__________________________________________________________________________________________________

- (void)setState:(FriendProgressStates)state
{
  [super setState:state];
  state = super.state;
  GlobalParameters* parameters  = GetGlobalParameters();
  if (state == E_FriendProgressState_Blank)
  {
    Progress->DiskColor           = TransparentColor;
    Progress->ProgressColor       = TransparentColor;
    Progress->ProgressRadius      = 0.0;
    Progress->DiskRadius          = 0.0;
  }
  else if (state == E_FriendProgressState_Unselected)
  {
    Progress->DiskColor           = TransparentColor;
    Progress->ProgressColor       = parameters.friendStateViewColor;
    Progress->DiskRadius          = 0.0;
    Progress->ProgressRadius      = parameters.friendStateViewCircleRadius;
  }
  else
  {
    Progress->DiskColor           = parameters.friendStateViewColor;
    Progress->ProgressColor       = parameters.friendStateViewColor;
    Progress->ProgressRadius      = (state == E_FriendProgressState_InProgress)? parameters.friendStateViewProgressCircleRadius: parameters.friendStateViewCircleRadius;
    Progress->DiskRadius          = (state == E_FriendProgressState_InProgress)? parameters.friendStateViewProgressDiskRadius  : parameters.friendStateViewDiskRadius;
  }
  Progress.progressValue = 1.0;
}
//__________________________________________________________________________________________________

- (void)setState:(FriendProgressStates)state animated:(BOOL)animated
{
  if (UseBlankState && (state == E_FriendProgressState_Unselected))
  {
    state = E_FriendProgressState_Blank;
  }
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
  if (UseBlankState && (state == E_FriendProgressState_Unselected))
  {
    state = E_FriendProgressState_Blank;
  }
//  [self stopAnimation];
  GlobalParameters* parameters  = GetGlobalParameters();
  StartDiskColor                = Progress->DiskColor;
  StartDiskRadius               = Progress->DiskRadius;
  StartProgressColor            = Progress->ProgressColor;
  StartProgressRadius           = Progress->ProgressRadius;
  Progress.progressValue        = 1.0;
  if (StartProgressRadius > 11)
  {
    StartProgressRadius = Progress->ProgressRadius;
  }
  switch (state)
  {
  case E_FriendProgressState_Blank:
    EndDiskColor        = TransparentColor;
    EndProgressColor    = TransparentColor;
    EndDiskRadius       = 0.0;
    EndProgressRadius   = 0.0;
    break;
  case E_FriendProgressState_Unselected:
    EndDiskColor        = TransparentColor;
    EndProgressColor    = parameters.friendStateViewColor;
    EndDiskRadius       = 0.0;
    EndProgressRadius   = parameters.friendStateViewCircleRadius;
    break;
  case E_FriendProgressState_Selected:
    EndDiskColor        = parameters.friendStateViewColor;
    EndProgressColor    = parameters.friendStateViewColor;
    EndDiskRadius       = parameters.friendStateViewDiskRadius;
    EndProgressRadius   = parameters.friendStateViewCircleRadius;
//    NSLog(@"animateToState: StartProgressRadius: %f, EndProgressRadius: %f, Progress->ProgressRadius: %f", StartProgressRadius, EndProgressRadius, Progress->ProgressRadius);
    break;
  case E_FriendProgressState_InProgress:
    EndDiskColor        = parameters.friendStateViewColor;
    EndProgressColor    = parameters.friendStateViewColor;
    EndDiskRadius       = parameters.friendStateViewProgressDiskRadius;
    EndProgressRadius   = parameters.friendStateViewProgressCircleRadius;
    {
      Progress.progressValue  = 1.0;
      [Progress animateProgressToValue:0.0 during:ProgressAnimDuration completion:^(BOOL completed)
      {
        if (completed)
        {
          AnimationDone();
        }
      }];
    }
    break;
  default:
    break;
  }
  [super animateToState:state completion:^
  {
    completionAction();
  }];
}
//__________________________________________________________________________________________________

- (void)stateAnimationStep:(CGFloat)animationValue
{
//  NSLog(@"stateAnimationStep: %f", animationValue);
  Progress->DiskColor       = InterpolateColor(animationValue, E_InterpolateRgb, StartDiskColor      , EndDiskColor);
  Progress->ProgressColor   = InterpolateColor(animationValue, E_InterpolateRgb, StartProgressColor  , EndProgressColor);
  Progress->ProgressRadius  = InterpolateFloat(animationValue                  , StartProgressRadius , EndProgressRadius);
  Progress->DiskRadius      = InterpolateFloat(animationValue                  , StartDiskRadius     , EndDiskRadius);
//  NSLog(@"CurrentState: %d, stateAnimationStep: StartProgressRadius: %6.2f, EndProgressRadius: %6.2f, Progress->ProgressRadius: %6.2f, ProgressValue: %6.2f", CurrentState, StartProgressRadius, EndProgressRadius, Progress->ProgressRadius, Progress->ProgressValue);
  [Progress setNeedsDisplay];
}
//__________________________________________________________________________________________________

- (void)cancelAnimation
{
  [Progress stopAnimation];
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________

