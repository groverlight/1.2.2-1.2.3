
//! \file   Menu.h
//! \brief  Class that handles a menu with a simplified interface.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Blocks.h"
//__________________________________________________________________________________________________

//! Class that handles a menu with a simplified interface.
@interface Menu : NSObject
{
}
//____________________

+ (Menu*)menuWithTitle:(NSString*)title andMessage:(NSString*)message;
//____________________

+ (Menu*)menuWithButtonTitles:(NSArray*)titles;
//____________________

- (NSInteger)addMenuButtonWithTitle:(NSString*)title;
//____________________

- (NSInteger)addDestructiveMenuButtonWithTitle:(NSString*)title;
//____________________

- (NSInteger)addCancelMenuButton:(NSString*)title;
//____________________

- (void)showWithCompletion:(BlockIntAction)completion;
//____________________

@end
//__________________________________________________________________________________________________
