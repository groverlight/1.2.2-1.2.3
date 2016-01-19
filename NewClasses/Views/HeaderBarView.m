
//! \file   HeaderBarView.mm
//! \brief  Pop View that implements the labels on the top of the screen.
//__________________________________________________________________________________________________

#import "HeaderBarView.h"
#import "GlobalParameters.h"
#import "HeaderButton.h"
#import "Interpolation.h"
#import "Tools.h"
//__________________________________________________________________________________________________

//! Pop View that implements the labels on the top of the screen.
@implementation HeaderBarView
{
  HeaderButton* LeftItem;
  HeaderButton* CenterItem;
  HeaderButton* RightItem;
  UIView*       UnderlineView;
  UIView*       Separator;
  HeaderButton* ActiveItem;
  NSInteger     ActiveItemIndex;
  CGFloat       BarHeight;
  CGFloat       TopMargin;
  CGFloat       LeftMargin;
  CGFloat       RightMargin;
  CGFloat       UnderlineHeight;
  CGFloat       UnderlineGap;
  CGFloat       StartUnderlineCenterX;
  CGFloat       EndUnderlineCenterX;
  CGFloat       StartUnderlineWidth;
  CGFloat       EndUnderlineWidth;
  BOOL          NeverLayouted;
}
//____________________

//! Initialize the object however it has been created.
- (void)Initialize
{
  [super Initialize];
  ActiveItemIndex                   = NSNotFound;
  self.smartUserInteractionEnabled  = YES;
  NeverLayouted                     = YES;
  GlobalParameters* parameters      = GetGlobalParameters();
  Separator                         = [UIView       new];
  LeftItem                          = [HeaderButton new];
  CenterItem                        = [HeaderButton new];
  RightItem                         = [HeaderButton new];
  UnderlineView                     = [UIView       new];
  self.animParameters               = parameters.headerUnderlineAnimParameters;
  LeftItem.title                    = parameters.headerLeftLabelTitle;
  CenterItem.title                  = parameters.headerCenterLabelTitle;
  RightItem.title                   = parameters.headerRightLabelTitle;
  BarHeight                         = parameters.headerHeight;
  TopMargin                         = parameters.headerTopMargin;
  LeftMargin                        = parameters.headerSideMargin;
  RightMargin                       = parameters.headerSideMargin;
  UnderlineHeight                   = parameters.headerUnderlineHeight;
  UnderlineGap                      = parameters.headerUnderlineGap;
  EndUnderlineCenterX               = 0;
  EndUnderlineWidth                 = 0;
  [self addSubview:Separator];
  [self addSubview:UnderlineView];
  [self addSubview:LeftItem];
  [self addSubview:CenterItem];
  [self addSubview:RightItem];

  Separator.backgroundColor     = parameters.separatorLineColor;
  UnderlineView.backgroundColor = parameters.headerUnderlineColor;

//  LeftItem.dotVisible = YES;

  ItemSelectedAction = ^(NSInteger index)
  { // Default action: do nothing!
  };
  set_myself;
  LeftItem.pressedAction = ^
  {
    get_myself;
    myself->LeftItem.selected   = YES;
    myself->CenterItem.selected = NO;
    myself->RightItem.selected  = NO;
    myself->ItemSelectedAction(0);
    [myself animateUnderlineToIndex:0];
  };
  CenterItem.pressedAction = ^
  {
    get_myself;
    myself->LeftItem.selected   = NO;
    myself->CenterItem.selected = YES;
    myself->RightItem.selected  = NO;
    myself->ItemSelectedAction(1);
    [myself animateUnderlineToIndex:1];
  };
  RightItem.pressedAction = ^
  {
    get_myself;
    myself->LeftItem.selected   = NO;
    myself->CenterItem.selected = NO;
    myself->RightItem.selected  = YES;
    myself->ItemSelectedAction(2);
    [myself animateUnderlineToIndex:2];
  };
  LeftItem.highlightedAction = ^
  {
    get_myself;
    myself->CenterItem.selected = NO;
    myself->RightItem.selected  = NO;
  };
  CenterItem.highlightedAction = ^
  {
    get_myself;
    myself->LeftItem.selected   = NO;
    myself->RightItem.selected  = NO;
  };
  RightItem.highlightedAction = ^
  {
    get_myself;
    myself->LeftItem.selected   = NO;
    myself->CenterItem.selected = NO;
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

- (void)layout
{
  [Separator centerHorizontally];
  GlobalParameters* parameters      = GetGlobalParameters();
  Separator.height                  = parameters.separatorLineWidth;
  Separator.width                   = self.width - 2 * parameters.separatorLineSideMargin;
  Separator.centerY                 = LeftItem.bottom - parameters.headerUnderlineHeight / 2;
  LeftItem.size                     = [LeftItem sizeThatFits:self.size];
  LeftItem.center                   = CGPointMake(LeftMargin + [LeftItem scaledSizeThatFits:self.size].width / 2, TopMargin + LeftItem.height / 2);
  CenterItem.size                   = [CenterItem sizeThatFits:self.size];
  CenterItem.center                 = CGPointMake(self.width / 2, TopMargin + CenterItem.height / 2);
  RightItem.size                    = [RightItem sizeThatFits:self.size];
  RightItem.center                  = CGPointMake(self.width - RightMargin - [RightItem scaledSizeThatFits:self.size].width / 2, TopMargin + RightItem.height / 2);
  UnderlineView.centerX             = ActiveItem.width / 2;
  UnderlineView.centerY             = Separator.centerY;
  UnderlineView.width               = ActiveItem.titleWidth;
  UnderlineView.layer.cornerRadius  = UnderlineHeight / 2;
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  // Do not call [super LayoutSubviews] for this class. It makes unwanted things.
  if (NeverLayouted || ((NumAnimationInProgress == 0) && (!WasAnimating)))
  {
    [self layout];
    NeverLayouted = NO;
  }
  if (WasAnimating)
  {
    WasAnimating = NO;
  }
}
//__________________________________________________________________________________________________

- (CGSize)sizeThatFits:(CGSize)size
{
  return CGSizeMake(size.width, BarHeight);
}
//__________________________________________________________________________________________________

- (void)SelectItemAtIndex:(NSInteger)index
{
  [self animateUnderlineToIndex:index];
}
//__________________________________________________________________________________________________

- (void)animateUnderlineToIndex:(NSInteger)index
{
  if (ActiveItemIndex != index)
  {
    switch (index)
    {
      case 0:
        ActiveItem          = LeftItem;
        LeftItem.selected   = YES;
        CenterItem.selected = NO;
        RightItem.selected  = NO;
        break;
      case 1:
        ActiveItem          = CenterItem;
        LeftItem.selected   = NO;
        CenterItem.selected = YES;
        RightItem.selected  = NO;
        break;
      case 2:
        ActiveItem          = RightItem;
        LeftItem.selected   = NO;
        CenterItem.selected = NO;
        RightItem.selected  = YES;
        break;
      default:
        break;
    }
    [self stopAnimation];
    [self animateUnderline];
    ActiveItemIndex = index;
  }
}
//__________________________________________________________________________________________________

- (void)bounceLeftItemDot
{
  [LeftItem bounceDot];
}
//__________________________________________________________________________________________________

- (void)hideLeftItemDot;
{
  LeftItem.dotVisible = NO;
}
//__________________________________________________________________________________________________

- (void)scrollUnderlineByFactor:(CGFloat)factor
{
  if (NumAnimationInProgress == 0)
  {
//    NSLog(@"scrollUnderlineByFactor: %f", factor);
    CGFloat value = factor;
    if (value >= 1.0)
    {
      value = value - 1.0;
      StartUnderlineWidth   = CenterItem.titleWidth;
      EndUnderlineWidth     = RightItem.titleWidth;
      StartUnderlineCenterX = CenterItem.centerX;
      EndUnderlineCenterX   = RightItem.centerX;
    }
    else
    {
      StartUnderlineWidth   = LeftItem.titleWidth;
      EndUnderlineWidth     = CenterItem.titleWidth;
      StartUnderlineCenterX = LeftItem.centerX;
      EndUnderlineCenterX   = CenterItem.centerX;
    }
    [self animateUnderlineStep:value];
    EndUnderlineWidth   = UnderlineView.width;
    EndUnderlineCenterX = UnderlineView.centerX;
    WasAnimating        = YES;
  }
}
//__________________________________________________________________________________________________


- (void)animateUnderlineStep:(CGFloat)animationValue
{
  //  NSLog(@"animateUnderlineStep: %f", animationValue);
  CGFloat underlineWidth            = InterpolateFloat(animationValue, StartUnderlineWidth  , EndUnderlineWidth);
  CGFloat underlineCenterX          = InterpolateFloat(animationValue, StartUnderlineCenterX, EndUnderlineCenterX);
  UnderlineView.centerX             = underlineCenterX;
  UnderlineView.bounds              = CGRectMake(0, 0, underlineWidth, UnderlineHeight);
//  NSLog(@"UnderlineView.centerX: %f, width: %f", UnderlineView.centerX, UnderlineView.width);
}
//__________________________________________________________________________________________________

- (void)animateUnderline
{
  StartUnderlineCenterX = (ActiveItemIndex != NSNotFound)? EndUnderlineCenterX: ActiveItem.centerX;
  EndUnderlineCenterX   = ActiveItem.centerX;
  StartUnderlineWidth   = EndUnderlineWidth;
  EndUnderlineWidth     = ActiveItem.titleWidth;
  self.animationValue   = 0.0;
  [self animateToValue:1.0 animateStep:^(CGFloat parameterValue)
  {
    [self animateUnderlineStep:parameterValue];
  } completion:^
  {
    EndUnderlineWidth   = UnderlineView.width;
    EndUnderlineCenterX = UnderlineView.centerX;
  }];
}
//__________________________________________________________________________________________________

//! Show the login view.
- (void)showAnimated:(BOOL)animated
{
  if (animated)
  {
    self.alpha  = 0.0;
    self.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^
    {
      self.alpha = 1.0;
    } completion:^(BOOL finished)
    {
    }];
  }
  else
  {
    self.hidden = NO;
    self.alpha  = 1.0;
  }
}
//__________________________________________________________________________________________________

//! Hide the login view.
- (void)hideAnimated:(BOOL)animated
{
  if (animated)
  {
    [UIView animateWithDuration:0.5 animations:^
    {
      self.alpha = 0.0;
    } completion:^(BOOL finished)
    {
      self.hidden = YES;
    }];
  }
  else
  {
    self.hidden = YES;
    self.alpha  = 0.0;
  }
}
//__________________________________________________________________________________________________

@end
