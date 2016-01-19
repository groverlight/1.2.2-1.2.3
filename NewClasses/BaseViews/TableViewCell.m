
//! \file   TableViewCell.m
//! \brief  Custom table view cell to be used in conjunction with the khTableView class.
//__________________________________________________________________________________________________

#import "TableViewCell.h"
#import "TableView.h"
#import "Colors.h"
//__________________________________________________________________________________________________

#define DISABLE_PAN_TRIGGER           5   //!< Max initial delta Y for panning.
//__________________________________________________________________________________________________

//==================================================================================================

//! UIView based class that reacts to single tap by calling a block.
@interface TapView : UIView
{
@public
  BlockAction       ViewTappedAction;   //!< Block called when the view has been tapped.
  BlockAction       ViewPanTouchAction; //!< Block called when the view touch started.
  BlockFloatAction  ViewPanStartAction; //!< Block called when the view panning started.
  BlockFloatAction  ViewPanningAction;  //!< Block called when the view is panning.
  BlockFloatAction  ViewPanEndAction;   //!< Block called when the view panning ended.
  CGRect            TouchRectangle;     //!< The touch actions ar clipped to this rectangle.
}
//____________________

//____________________

@end
//__________________________________________________________________________________________________

//! UIView based class that reacts to single tap by calling a block.
@implementation TapView
{
  CGPoint InitialPoint;
  BOOL    JustStarted;
  BOOL    IgnoreTouch;
  UIPanGestureRecognizer* PanGesture;
}
//____________________

- (void)Initialize
{
    
    TouchRectangle  = CGRectZero;
    IgnoreTouch     = YES;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    [self addGestureRecognizer:tapGesture];

  ViewTappedAction = ^
  { // Default action: do nothing!
  };
  ViewPanTouchAction = ^
  { // Default action: do nothing!
  };
  ViewPanStartAction = ^(CGFloat offset)
  { // Default action: do nothing!
  };
  ViewPanningAction = ^(CGFloat offset)
  { // Default action: do nothing!
  };
  ViewPanEndAction = ^(CGFloat offset)
  { // Default action: do nothing!
  };
}
//__________________________________________________________________________________________________

//! Initialize the object when it has been allocated programmatically.
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self)
  {
    [self Initialize];
  }
  return self;
}
//__________________________________________________________________________________________________

//! Initialize the object when it has been allocated from an UIBuilder file.
- (instancetype)initWithCoder:(NSCoder *)decoder
{
  self = [super initWithCoder:decoder];
  if (self)
  {
    [self Initialize];
  }
  return self;
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super layoutSubviews];
}
//__________________________________________________________________________________________________

- (void)tapRecognized:(UITapGestureRecognizer*)recognizer
{
    if(UIGestureRecognizerStateEnded){}
  //NSLog(@"1 tapRecognized");
  CGPoint pt = [recognizer locationInView:self];
  if ((TouchRectangle.size.width == 0) ||
      ((pt.x > TouchRectangle.origin.x) && (pt.x < TouchRectangle.origin.x + TouchRectangle.size.width) &&
       (pt.y > TouchRectangle.origin.y) && (pt.y < TouchRectangle.origin.y + TouchRectangle.size.height)))
  {
//    NSLog(@"2 tapRecognized");
    ViewTappedAction();
  }
}
//__________________________________________________________________________________________________

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
//  NSLog(@"1 touchesBegan");
  [super touchesBegan:touches withEvent:event];

  UITouch* touch  = [touches anyObject];
  InitialPoint    = [touch locationInView:nil];
  CGPoint pt      = [touch locationInView:self];
  if ((TouchRectangle.size.width == 0) ||
      ((pt.x > TouchRectangle.origin.x) && (pt.x < TouchRectangle.origin.x + TouchRectangle.size.width) &&
       (pt.y > TouchRectangle.origin.y) && (pt.y < TouchRectangle.origin.y + TouchRectangle.size.height)))
  {
//    NSLog(@"2 touchesBegan");
    JustStarted     = YES;
    IgnoreTouch     = NO;
    ViewPanTouchAction();
  }
}
//__________________________________________________________________________________________________

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
  if (IgnoreTouch)
  {
   // NSLog(@"touchesMoved ignored");
    [super touchesMoved:touches withEvent:event];
  }
  else
  {
   // NSLog(@"touchesMoved");
    UITouch* touch    = [touches anyObject];
    CGPoint location  = [touch locationInView:nil];
//    NSLog(@"%f, %f", fabs(location.y - InitialPoint.y), fabs(location.x - InitialPoint.x));
    if (JustStarted)
    {
      ViewPanStartAction(InitialPoint.x);
      JustStarted = NO;
    }
    ViewPanningAction(location.x);
  }
}
//__________________________________________________________________________________________________

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
//  NSLog(@"touchesEnded");
  if (IgnoreTouch)
  {
  //  NSLog(@"touchesEnded ignored");
    [super touchesEnded:touches withEvent:event];
  }
  else
  {
    UITouch* touch    = [touches anyObject];
    CGPoint location  = [touch locationInView:nil];
    ViewPanEndAction(location.x);
  }
  IgnoreTouch = YES;
}
//__________________________________________________________________________________________________

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
//  NSLog(@"touchesCancelled");
  [super touchesCancelled:touches withEvent:event];
 
  if (!IgnoreTouch)
  {
    UITouch* touch    = [touches anyObject];
    CGPoint location  = [touch locationInView:nil];
    ViewPanEndAction(location.x);
  }
  IgnoreTouch = YES;
}
//__________________________________________________________________________________________________

@end
//==================================================================================================

//! \brief  Custom table view cell to be used in conjunction with the khTableView class.
@interface TableViewCell()
{
  TapView*        MainContentView;          //!< The main content view.
  NSMutableArray* ContentRefs;              //!< Array of pointers to accessible items of the ContentView structure.
  CGFloat         StartPanningPos;
}
@end
//__________________________________________________________________________________________________

//! \brief  Custom table view cell to be used in conjunction with the khTableView class.
@implementation TableViewCell
{
}
@synthesize tableRow;
@synthesize tableSection;
@synthesize tableView;
@synthesize mainBundleView;
//__________________________________________________________________________________________________

// This method is overriden to workaround an issue that made the MainContentView not tested by the default implementation for some unknown reason.
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  UIView* hitView = [super hitTest:point withEvent:event];
  if (hitView == nil)
  {
    hitView = [MainContentView hitTest:point withEvent:event];
  }
  return hitView;
}
//__________________________________________________________________________________________________

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
  self = [super initWithStyle:style reuseIdentifier:identifier];
  if (self != nil)
  {
//    NSLog(@"initWithStyle: %p", self);
    ContentRefs               = [NSMutableArray arrayWithCapacity:3];
    MainContentView           = [TapView new];
    self.selectionStyle       = UITableViewCellSelectionStyleNone;
    self.accessoryView        = nil;
    self.textLabel.text       = @"";
    self.detailTextLabel.text = @"";
    self.backgroundColor      = Transparent;
    [self.contentView addSubview:MainContentView];
    set_myself;
    MainContentViewTapped = ^
    { // Default action: do nothing!
    };
    MainContentViewPanStartAction = ^(CGFloat offset)
    { // Default action: do nothing!
    };
    MainContentViewPanningAction = ^(CGFloat offset)
    { // Default action: do nothing!
    };
    MainContentViewPanEndAction = ^(CGFloat offset)
    { // Default action: do nothing!
    };
    MainContentView->ViewTappedAction = ^
    {
      get_myself;
      myself->MainContentViewTapped();
    };
    MainContentView->ViewPanTouchAction = ^
    {
      get_myself;
      myself->MainContentViewPanTouchAction();
    };
    MainContentView->ViewPanStartAction = ^(CGFloat offset)
    {
      get_myself;
      myself->MainContentViewPanStartAction(offset);
    };
    MainContentView->ViewPanningAction = ^(CGFloat offset)
    {
      get_myself;
      myself->MainContentViewPanningAction(offset);
    };
    MainContentView->ViewPanEndAction = ^(CGFloat offset)
    {
      get_myself;
      myself->MainContentViewPanEndAction(offset);
    };
    self.backgroundColor                  = Transparent;
    self.textLabel.backgroundColor        = Transparent;
    self.detailTextLabel.backgroundColor  = Transparent;
    self.clipsToBounds                    = YES;
  }
  return self;
}
//__________________________________________________________________________________________________

- (void)dealloc
{
}
//__________________________________________________________________________________________________

-(UIView*)mainContentView
{
  return MainContentView;
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
  [super layoutSubviews];
  CGRect frame                    = self.bounds;
  CGFloat width                   = frame.size.width;
  CGFloat height                  = tableView.rowHeight;
  frame.size.height               = height;
  frame.origin.x                  = 0;
  frame.origin.y                  = 0;
  frame.size.width                = width;
  MainContentView.frame           = frame;
  [self.tableView LayoutCell:(TableViewCell*)self];
}
//__________________________________________________________________________________________________

- (void)Draw:(UIView*)draw_view
{ // Do nothing in the base class.
}
//__________________________________________________________________________________________________

- (void)addCellItem:(UIView*)item
{
  [MainContentView addSubview:item];
  [ContentRefs addObject:item];
}
//__________________________________________________________________________________________________

- (id)getCellItemAtIndex:(NSInteger)index
{
  return [ContentRefs objectAtIndex:index];
}
//__________________________________________________________________________________________________

- (void)addBaseItem:(UIView*)item
{
  [self.contentView addSubview:item];
  [ContentRefs addObject:item];
}
//__________________________________________________________________________________________________

- (void)setMainContentViewLongPress:(BlockAction)mainContentViewLongPress
{
  MainContentViewTapped = mainContentViewLongPress;
}
//__________________________________________________________________________________________________

- (BlockAction)mainContentViewLongPress
{
  return MainContentViewTapped;
}
//__________________________________________________________________________________________________

- (void)setTouchRectangle:(CGRect)touchRectangle
{
  MainContentView->TouchRectangle = touchRectangle;
}
//__________________________________________________________________________________________________

- (CGRect)touchRectangle
{
  return MainContentView->TouchRectangle;
}
//__________________________________________________________________________________________________

@end
