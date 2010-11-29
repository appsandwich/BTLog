//
//  BTLog.m
//  BTLog
//
//  Created by Vinny Coyne on 11/06/2010.
//  Copyright 2010 Vincent Coyne. All rights reserved.
//

#import "BTLog.h"

// THIS PORTION OF THE CODE WAS TAKEN FROM THE LAST.FM IPHONE APP: http://github.com/c99koder/lastfm-iphone/

/* MobileLastFM_Prefix.pch - Prefix header
 * 
 * Copyright 2009 Last.fm Ltd.
 *   - Primarily authored by Sam Steele <sam@last.fm>
 *
 * This file is part of MobileLastFM.
 *
 * MobileLastFM is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MobileLastFM is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MobileLastFM.  If not, see <http://www.gnu.org/licenses/>.
 */

// Override NSLog to output to a file as well as the console
void NSLog(NSString *format, ...) {
	va_list ap;
	NSMutableString *print;
	va_start(ap,format);
	print=[[NSMutableString alloc] initWithFormat:format arguments:ap];
	va_end(ap);
	
	if(![print hasSuffix:@"\n"])
		[print appendString:@"\n"];
	
	[[[UIApplication sharedApplication] delegate] logStringToRemoteDevice:print];
	fprintf(stderr, "%s %s", [[[NSDate date] description] UTF8String], [print UTF8String]);
	
	[print release];
}


@implementation BTLog

@synthesize gkSession, delegate, connected;

-(id)initWithDelegate:(id)btDelegate
{
	if (self = [super init])
	{
		self.gkSession = nil;
		self.delegate = btDelegate;
		self.connected = NO;
		
		[self startConnection];
	}
	
	return self;
}

-(id)init
{
	if (self = [super init])
	{
		self.connected = NO;
		self.gkSession = nil;
		self.delegate = nil;
	}
	
	return self;
}

-(void)dealloc
{
	[self.gkSession release];
	[gkPeerPicker release];
	[gkPeers release];
	[super dealloc];
}


#pragma mark -
#pragma mark GameKit

-(void)startConnection
{
	gkPeerPicker = [[GKPeerPickerController alloc] init];
	gkPeerPicker.delegate = self;
	gkPeerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
	
	gkPeers = [[NSMutableArray alloc] init];
	
	[gkPeerPicker show];
	
	[gkPeerPicker release];
	gkPeerPicker = nil;
	
}

-(void)stopConnection
{
	self.connected = NO;
	[self.gkSession disconnectFromAllPeers];
	self.gkSession = nil;
	
	[gkPeers removeAllObjects];
	[gkPeers release];
	gkPeers = nil;
}


/* Notifies delegate that a connection type was chosen by the user.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type
{
}

/* Notifies delegate that the connection type is requesting a GKSession object.
 
 You should return a valid GKSession object for use by the picker. If this method is not implemented or returns 'nil', a default GKSession is created on the delegate's behalf.
 */
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
	GKSession* _gkSession = [[GKSession alloc] initWithSessionID:@"btlog" displayName:[[UIDevice currentDevice] name] sessionMode:GKSessionModePeer];
	
	return [_gkSession autorelease];
}

/* Notifies delegate that the peer was connected to a GKSession.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
	self.gkSession = session;
	self.gkSession.delegate = self;
	[self.gkSession setDataReceiveHandler:self withContext:nil];
	
	self.connected = YES;
	
	[picker dismiss];
}

/* Notifies delegate that the user cancelled the picker.
 */
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
	self.connected = NO;
}

#pragma mark Peers

/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	switch (state)
	{
		case GKPeerStateConnected:
			
			if (gkPeers)
			{
				[gkPeers addObject:peerID];
				self.connected = YES;
			}
			
			break;
			
		case GKPeerStateUnavailable:
		case GKPeerStateDisconnected:
			
			if (gkPeers)
				[gkPeers removeObject:peerID];
			
			self.connected = NO;
			
			break;
	}
}

/* Indicates a connection request was received from another peer. 
 
 Accept by calling -acceptConnectionFromPeer:
 Deny by calling -denyConnectionFromPeer:
 */
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	//TODO: Change
	[session acceptConnectionFromPeer:peerID error:nil];
}

/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	self.connected = NO;
}

/* Indicates an error occurred with the session such as failing to make available.
 */
- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	self.connected = NO;
}

-(void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	self.connected = YES;
	
	NSString* _dataString = [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
	
	if ([_dataString compare:kBTLogCloseConnection] == NSOrderedSame)
	{
		[self stopConnection];
	}
	else
	{
		if (self.delegate)
		{
			if ([self.delegate respondsToSelector:@selector(didReceiveLogString:)])
			{
				[self.delegate performSelectorOnMainThread:@selector(didReceiveLogString:) withObject:_dataString waitUntilDone:YES];
			}
		}
	}
	
	[_dataString release];
}

-(void)logString:(NSString*)string
{
	NSError* error = nil;
	
	if ((self.gkSession) && (gkPeers) && ([gkPeers count] > 0))
	{
		[self.gkSession sendData:[string dataUsingEncoding:NSUnicodeStringEncoding] toPeers:gkPeers withDataMode:GKSendDataReliable error:&error];
	}
}

@end
