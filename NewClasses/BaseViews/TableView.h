
//! \file   TableView.h
//! \brief  Custom view that integrate the UITableView into the khView edifice.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "TableViewCell.h"
//__________________________________________________________________________________________________

//! Custom view that integrate the UITableView into the khView edifice.
@interface TableView : UITableView
{
}
//____________________

@property NSInteger lastScrolledRow;  //!< The row index of the last row to have been scrolled horizontally.
//____________________

//! Handle the basic initialization of the class.
- (void)Initialize;
//! Handle the basic initialization of the class with the specified style.
- (void)Initialize:(UITableViewStyle)style;

// To be implemented by derived classes.
- (NSString*)GetCellIdentifier:(NSIndexPath*)indexPath;                                                     //!< Retrieve the cell identifier for the cell at specified index path.
- (TableViewCell*)RetrieveCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath;     //!< Specialize this method in the derived class to retrieve an existing desired table view cell object. Return nil if not found.
- (TableViewCell*)CreateCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath;       //!< Specialize this method in the derived class to create the desired table view cell object.
- (TableViewCell*)GetCellForTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath;          //!< Specialize this method in the derived class to get the desired table view cell object.
- (void)BuildCellContent:(TableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;                          //!< Specialize this method in the derived class to build the cell content.
- (void)InitCell:(TableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;                                  //!< Specialize this method in the derived class to init the cell content.
- (void)LayoutCell:(TableViewCell*)cell;                                                                    //!< Specialize this method in the derived class to layout the cell content.
- (bool)CanMoveRowAtIndexPath:(NSIndexPath*)indexPath;                                                      //!< Specialize this method in the derived class to determine if the cell can be moved.
- (void)MovedRowAtIndexPath:(NSIndexPath*)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;  //!< Specialize this method in the derived class to react when a cell has been moved.
- (void)DidSelectRow:(NSIndexPath*)indexPath;                                                               //!< Specialize this method in the derived class to react when a cell has been selected.

//! Force refresh of the table data.
- (void)ReloadTableData;
//____________________

@end
//__________________________________________________________________________________________________
