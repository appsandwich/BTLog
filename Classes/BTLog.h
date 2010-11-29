//
//  BTLog.h
//  BTLog
//
//  Created by Vinny Coyne on 11/06/2010.
//  Copyright 2010 Vincent Coyne. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kBTLogCloseConnection		@"<BTLOG_FINISH>"


@interface BTLog : NSObject <GKSessionDelegate, GKPeerPickerControllerDelegate> {
	
	GKSession* gkSession;
	GKPeerPickerController* gkPeerPicker;
	NSMutableArray* gkPeers;
	
	id delegate;

	BOOL connected;
}

@property (retain) GKSession* gkSession;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL connected;

-(id)initWithDelegate:(id)btDelegate;
-(void)startConnection;
-(void)stopConnection;
-(void)logString:(NSString*)string;

@end
