
//! \file   Menu.m
//! \brief  Class that handles a menu with a simplified interface.
//__________________________________________________________________________________________________

#import "Menu.h"
#import "Tools.h"
//__________________________________________________________________________________________________

@interface Menu () <UIActionSheetDelegate>
{
}
//____________________

@end
//__________________________________________________________________________________________________

//! Class that handles a menu with a simplified interface.
@implementation Menu
{
  UIAlertController*  AlertCtrl;
  BlockIntAction      ButtonSelectedAction;
  NSInteger           ActionCounter;
}
//____________________

//! Initialize the object however it has been created.
-(instancetype)initWithTitle:(NSString*)title andMessage:(NSString*)message
{
  self = [super init];
  if (self != nil)
  {
    ActionCounter = 0;
    AlertCtrl = [UIAlertController alertControllerWithTitle:title
                                                    message:message
                                             preferredStyle:UIAlertControllerStyleActionSheet];
#if 0
    ActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];
#endif
    ButtonSelectedAction = ^(NSInteger buttonIndex)
    { // Default action: do nothing!
    };
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

+ (Menu*)menuWithTitle:(NSString*)title andMessage:(NSString*)message
{
  Menu* menu = [[Menu alloc] initWithTitle:title andMessage:message];
  return menu;
}
//__________________________________________________________________________________________________

+ (Menu*)menuWithButtonTitles:(NSArray*)titles
{
  Menu* menu = [[Menu alloc] initWithTitle:@"My Alert" andMessage:@"This is an alert."];
  for (NSString* title in titles)
  {
    [menu addMenuButtonWithTitle:title];
  }
  return menu;
}
//__________________________________________________________________________________________________

- (NSInteger)addMenuButtonWithTitle:(NSString*)title
{
  NSInteger actionIndex = ActionCounter++;
  UIAlertAction* newAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
  {
    ButtonSelectedAction(actionIndex);
  }];
  [AlertCtrl addAction:newAction];
  return actionIndex;
}
//__________________________________________________________________________________________________

- (NSInteger)addDestructiveMenuButtonWithTitle:(NSString*)title
{
  NSInteger actionIndex = ActionCounter++;
  UIAlertAction* newAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action)
  {
    ButtonSelectedAction(actionIndex);
  }];
  [AlertCtrl addAction:newAction];
  return actionIndex;
}
//__________________________________________________________________________________________________

- (NSInteger)addCancelMenuButton:(NSString*)title
{
  NSInteger actionIndex = ActionCounter++;
  UIAlertAction* newAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction* action)
  {
    ButtonSelectedAction(actionIndex);
  }];
  [AlertCtrl addAction:newAction];
  return actionIndex;
}
//__________________________________________________________________________________________________

- (void)showWithCompletion:(BlockIntAction)completion
{
  ButtonSelectedAction = completion;
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:AlertCtrl animated:YES completion:^
  {
  }];
}
//__________________________________________________________________________________________________

@end
