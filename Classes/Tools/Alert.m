
//! \file   Alert.m
//! \brief  Display an alert on the screen.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>

#import "Alert.h"
//__________________________________________________________________________________________________

@interface AlertView: UIAlertView <UIAlertViewDelegate>
{
    BlockIntAction ClickedButtonAction; //!< The block to call when a button is pressed.
}

@property BlockIntAction clickedButtonBlock; //!< The block to call when a button is pressed.

//! Initialize the object.
- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)additional_button_title, ...;

@end
//__________________________________________________________________________________________________

@implementation AlertView

- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)additional_button_title, ...
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if (self != nil)
    {
        self.delegate = self;
        va_list ap;
        va_start(ap, additional_button_title);
        while (additional_button_title != nil)
        {
            [self addButtonWithTitle:additional_button_title];
            additional_button_title = va_arg(ap, NSString*);
        }
        ClickedButtonAction = ^(NSInteger clickedButton)
        { // Default action: do nothing!
        };
    }
    return self;
}
//__________________________________________________________________________________________________

- (void)setClickedButtonBlock:(BlockIntAction)clickedButtonBlock
{
    ClickedButtonAction = clickedButtonBlock;
}
//__________________________________________________________________________________________________

- (BlockIntAction)clickedButtonBlock
{
    return ClickedButtonAction;
}
//__________________________________________________________________________________________________

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ClickedButtonAction(buttonIndex);
}
//__________________________________________________________________________________________________

@end
//__________________________________________________________________________________________________

//! Display an alert with the specified title and message. Show up to two buttons.
id Alert
(
 NSString*       title,                //!< The title of the alert to display.
 NSString*       message,              //!< The message of the the alert to display.
 NSString*       ok_button_title,      //!< The title of the OK button, or nil if not used.
 NSString*       cancel_button_title,  //!< The title of the Cancel button, or nil if not used.
 BlockIntAction  clicked_button_block  //!< The block to call when a button is pressed.
)
{
    AlertView* alert = [[AlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancel_button_title otherButtonTitles:ok_button_title, nil];
    alert.clickedButtonBlock = clicked_button_block;
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    return alert;
}
//__________________________________________________________________________________________________
