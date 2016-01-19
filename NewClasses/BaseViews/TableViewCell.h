
//! \file   TableViewCell.h
//! \brief  Custom table view cell to be used in conjunction with the khTableView class.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Blocks.h"
//__________________________________________________________________________________________________

@class TableView;
@class TableViewCell;
//__________________________________________________________________________________________________

typedef void (^BlockCellAction)(TableViewCell* cell); //!< Type definition for blocks with a single TableViewCell* parameter.
//__________________________________________________________________________________________________

//! \brief  Custom table view cell to be used in conjunction with the khTableView class.
@interface TableViewCell : UITableViewCell
{
@public
  BlockAction       MainContentViewTapped;          //!< The block called when the main content view has been pressed.
  BlockAction       MainContentViewPanTouchAction;  //!< Block called when the view touch started.
  BlockFloatAction  MainContentViewPanStartAction;  //!< Block called when the view panning started.
  BlockFloatAction  MainContentViewPanningAction;   //!< Block called when the view is panning.
  BlockFloatAction  MainContentViewPanEndAction;    //!< Block called when the view panning ended.
}
//____________________

@property             NSInteger       tableRow;         //!< The row index of this cell in the parent table view.
@property             NSInteger       tableSection;     //!< The section index of this cell in the parent table view.
@property             TableView*      tableView;        //!< The parent table view.
@property (readonly)  UIView*         mainContentView;  //!< The main content view.
@property (readonly)  UIView*         mainBundleView;   //!< The view that bundle the main contentview and the parallax background.
@property             CGRect          touchRectangle;   //!< The touch actions ar clipped to this rectangle.
//____________________

//! Get the item view at the specified index.
- (id)getCellItemAtIndex:(NSInteger)index;
//____________________

//! Add an item view.
- (void)addCellItem:(UIView*)item;

//! Add an item to the base content view.
- (void)addBaseItem:(UIView*)item;
//____________________

@end
