//
//  BTLogAppDelegate.h
//  BTLog
//
//  Created by Vinny Coyne on 11/06/2010.
//  Copyright Vincent Coyne 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BTLog.h"

@interface BTLogAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
	BTLog* btLogger;

@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, assign) BTLog* btLogger;

- (NSString *)applicationDocumentsDirectory;
-(BOOL)isBTLogConnected;
-(void)btLogConnect;
-(void)btLogDisconnect;

@end

