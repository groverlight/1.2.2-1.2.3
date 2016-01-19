
//! \file   Blocks.h
//! \brief  Block related helper functions and definitions.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
//__________________________________________________________________________________________________

// Stuff to avoid retain cycles of self in the Objective C blocks.
#ifdef __OBJC__
#define set_myself  __weak typeof(self) weakSelf = self
#define get_myself  __strong typeof(self) myself = weakSelf
#endif
//__________________________________________________________________________________________________

typedef void    (^BlockAction)(void);                                         //!< Type definition for parameterless blocks.
typedef BOOL    (^BoolBlockAction)(void);                                     //!< Type definition for parameterless blocks with a BOOL return type.
typedef void    (^BlockBoolAction)(BOOL value);                               //!< Type definition for blocks with a single BOOL parameter.
typedef void    (^BlockIntAction)(NSInteger value);                           //!< Type definition for blocks with a single NSInteger parameter.
typedef void    (^BlockFloatAction)(CGFloat value);                           //!< Type definition for blocks with a single CGFloat parameter.
typedef void    (^BlockPointAction)(CGPoint point);                           //!< Type definition for blocks with a single CGPoint parameter.
typedef void    (^BlockStringAction)(NSString* value);                        //!< Type definition for blocks with a single NSString parameter.
typedef void    (^BlockPtrAction)(void* value);                               //!< Type definition for blocks with a single pointer parameter.
typedef CGFloat (^FloatBlockFloatAction)(CGFloat value);                      //!< Type definition for blocks with a single CGFloat parameter and a CGFloat return type.
typedef CGSize  (^SizeBlockFloatAction)(CGFloat value);                       //!< Type definition for blocks with a single CGFloat parameter and a CGSize return type.
typedef void    (^BlockIdAction)(id obj);                                     //!< Type definition for blocks with a single id parameter.
typedef void    (^BlockIdIdAction)(id obj1, id obj2);                         //!< Type definition for blocks with 2 id parameters.
typedef void    (^BlockIdIntAction)(id obj, NSInteger value);                 //!< Type definition for blocks with 2 parameters, one id parameter and one NSInteger parameter.
typedef void    (^BlockIdStringAction)(id obj, NSString* value);              //!< Type definition for blocks with 2 parameters, one id parameter and one NSString parameter.
typedef void    (^BlockPointIntAction)(CGPoint point, NSInteger value);       //!< Type definition for blocks with 2 parameters, one CGPoint parameter and one NSInteger parameter.
typedef void    (^BlockBoolErrorAction)(BOOL value, NSError* error);          //!< Type definition for blocks with 2 parameters, one BOOL parameter and one NSError parameter.
typedef void    (^BlockIdErrorAction)(id obj, NSError* error);                //!< Type definition for blocks with 2 parameters, one id parameter and one NSError parameter.
typedef void    (^BlockArrayErrorAction)(NSArray* array, NSError* error);     //!< Type definition for blocks with 2 parameters, one NSArray parameter and one NSError parameter.
typedef void    (^BlockBlockAction)(BlockAction action);                      //!< Type definition for blocks with a single block parameter.
typedef void    (^BlockFloatBlockAction)(CGFloat value, BlockAction action);  //!< Type definition for blocks with 2 parameters, one CGFloat parameter and one block parameter.
//__________________________________________________________________________________________________

