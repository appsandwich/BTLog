//
//  RootViewController.h
//  BTLog
//
//  Created by Vinny Coyne on 11/06/2010.
//  Copyright Vincent Coyne 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate> {
	
	IBOutlet UISearchBar* logSearchBar;

@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


-(IBAction)clear:(id)sender;
-(IBAction)toggleConnection:(id)sender;

@end
