
//! \file   BaseView.m
//! \brief  UIView based class that contain additions common to many views in the project.
//__________________________________________________________________________________________________

#import "BaseView.h"
//__________________________________________________________________________________________________

static __weak id currentFirstResponder;

@implementation UIResponder (FirstResponder)

+(id)currentFirstResponder
{
  currentFirstResponder = nil;
  [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
  return currentFirstResponder;
}
//__________________________________________________________________________________________________

-(void)findFirstResponder:(id)sender
{
  currentFirstResponder = self;
}
//__________________________________________________________________________________________________

@end

//==================================================================================================

@implementation UIView (FrameHelper)

- (void)setLeft:(CGFloat)x
{
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}
//__________________________________________________________________________________________________

- (CGFloat)left
{
  return self.frame.origin.x;
}
//__________________________________________________________________________________________________

- (void)setTop:(CGFloat)y
{
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
}
//__________________________________________________________________________________________________

- (CGFloat)top
{
  return self.frame.origin.y;
}
//__________________________________________________________________________________________________

- (void)setRight:(CGFloat)right
{
  CGRect frame = self.frame;
  frame.origin.x = right - frame.size.width;
  self.frame = frame;
}
//__________________________________________________________________________________________________

- (CGFloat)right
{
  return self.frame.origin.x + self.frame.size.width;
}
//__________________________________________________________________________________________________

- (void)setBottom:(CGFloat)bottom
{
  CGRect frame = self.frame;
  frame.origin.y = bottom - frame.size.height;
  self.frame = frame;
}
//__________________________________________________________________________________________________

- (CGFloat)bottom
{
  return self.frame.origin.y + self.frame.size.height;
}
//__________________________________________________________________________________________________

- (void)setWidth:(CGFloat)width
{
  CGRect bounds = self.bounds;
  bounds.size.width = width;
  self.bounds = bounds;
}
//__________________________________________________________________________________________________

- (CGFloat)width
{
  return self.frame.size.width;
}
//__________________________________________________________________________________________________

- (void)setHeight:(CGFloat)height
{
  CGRect bounds = self.bounds;
  bounds.size.height = height;
  self.bounds = bounds;
}
//__________________________________________________________________________________________________

- (CGFloat)height
{
  return self.frame.size.height;
}
//__________________________________________________________________________________________________

- (void)setOrigin:(CGPoint)origin
{
  CGRect frame = self.frame;
  frame.origin = origin;
  self.frame = frame;
}
//__________________________________________________________________________________________________

- (CGPoint)origin
{
  return self.frame.origin;
}
//__________________________________________________________________________________________________

- (void)setSize:(CGSize)size
{
  CGRect bounds = self.bounds;
  bounds.size = size;
  self.bounds = bounds;
}
//__________________________________________________________________________________________________

- (CGSize)size
{
  return self.frame.size;
}
//__________________________________________________________________________________________________

- (void)setCenterX:(CGFloat)centerX
{
  CGPoint point = self.center;
  point.x = centerX;
  self.center = point;
}
//__________________________________________________________________________________________________

- (CGFloat)centerX
{
  return self.center.x;
}
//__________________________________________________________________________________________________

- (void)setCenterY:(CGFloat)centerY
{
  CGPoint point = self.center;
  point.y = centerY;
  self.center = point;
}
//__________________________________________________________________________________________________

- (CGFloat)centerY
{
  return self.center.y;
}
//__________________________________________________________________________________________________

- (void)centerHorizontally
{
  CGPoint center  = self.center;
  center.x        = self.superview.width / 2;
  self.center     = center;
//  [self setLeft:floor((self.superview.width/2)-(self.width/2))];
}
//__________________________________________________________________________________________________

- (void)centerVertically
{
  CGPoint center  = self.center;
  center.y        = self.superview.height / 2;
  self.center     = center;
//  [self setTop:floor((self.superview.height/2)-(self.height/2))];
}
//__________________________________________________________________________________________________

- (void)centerInSuperview
{
  CGPoint center  = self.center;
  center.x        = self.superview.width / 2;
  center.y        = self.superview.height / 2;
  self.center     = center;
//  [self centerHorizontally];
//  [self centerVertically];
}
//__________________________________________________________________________________________________
@end
//==================================================================================================

//! UIView based class that contain additions common to many views in the project.
@implementation BaseView
{
}
@synthesize smartUserInteractionEnabled;
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  smartUserInteractionEnabled = NO;
}
//__________________________________________________________________________________________________

//! Initialize the object when it has been allocated programmatically.
- (id)init
{
  self = [super init];
  if (self)
  {
    [self Initialize];
  }
  return self;
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

//! Recalculate view layout independently of the system layout process.
- (void)layout
{
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super layoutSubviews];
  [self layout];
}
//__________________________________________________________________________________________________

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
  UIView* hit_view = [super hitTest:point withEvent:event];
  if (smartUserInteractionEnabled && (hit_view == self))
  {
    return nil;
  }
  return hit_view;
}
//__________________________________________________________________________________________________

//! Perform some class specific activation action.
- (void)activate
{
}
//__________________________________________________________________________________________________

@end
