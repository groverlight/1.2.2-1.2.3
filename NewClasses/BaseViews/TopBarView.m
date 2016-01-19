
//! \file   TopBarView.mm
//! \brief  UIView based class that implements the labels on the top of the screen.
//__________________________________________________________________________________________________

#import "TopBarView.h"
#import "Tools.h"
//__________________________________________________________________________________________________

#define BAR_HEIGHT    75  //!< Default height of the bar.
#define BORDER_OFFSET 42  //!< Default distance from the lateral border for the center of the left and right item.
//__________________________________________________________________________________________________


//! UIView based class that implements the labels on the top of the screen.
@implementation TopBarView
{
  UIView* LeftItem;
  UIView* CenterItem;
  UIView* RightItem;
}
@synthesize leftItemOffset;
@synthesize centerItemOffset;
@synthesize rightItemOffset;
@synthesize barHeight;
@synthesize borderOffset;
//____________________

//! Initialize the object however it has been created.
- (void)Initialize
{
  [super Initialize];
  barHeight     = BAR_HEIGHT;
  borderOffset  = BORDER_OFFSET;
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
  if (LeftItem != nil)
  {
    LeftItem.size   = [LeftItem sizeThatFits:self.size];
    LeftItem.center = CGPointMake(borderOffset + leftItemOffset.x, self.height / 2 + leftItemOffset.y);
  }
  if (CenterItem != nil)
  {
    CGRect bounds = self.bounds;
    bounds.size = [LeftItem sizeThatFits:self.size];
    CenterItem.bounds = bounds;
    CenterItem.center = CGPointMake(self.width / 2 + centerItemOffset.x, self.height / 2 + centerItemOffset.y);
  }
  if (RightItem != nil)
  {
    RightItem.size    = [RightItem sizeThatFits:self.size];
    RightItem.center  = CGPointMake(self.width - borderOffset + rightItemOffset.x, self.height / 2 + rightItemOffset.y);
  }
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super  layoutSubviews];
  [self   layout];
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  return CGSizeMake(size.width, barHeight);
}
//__________________________________________________________________________________________________

- (void)setLeftItem:(UIView *)leftItem
{
  [LeftItem removeFromSuperview];
  LeftItem = leftItem;
  [self addSubview:LeftItem];
}
//__________________________________________________________________________________________________

- (UIView*)leftItem
{
  return LeftItem;
}
//__________________________________________________________________________________________________

- (void)setCenterItem:(UIView *)centerItem
{
  [CenterItem removeFromSuperview];
  CenterItem = centerItem;
  [self addSubview:CenterItem];
}
//__________________________________________________________________________________________________

- (UIView*)centerItem
{
  return CenterItem;
}
//__________________________________________________________________________________________________

- (void)setRightItem:(UIView *)rightItem
{
  [RightItem removeFromSuperview];
  RightItem = rightItem;
  [self addSubview:RightItem];
}
//__________________________________________________________________________________________________

- (UIView*)rightItem
{
  return RightItem;
}
//__________________________________________________________________________________________________

@end
