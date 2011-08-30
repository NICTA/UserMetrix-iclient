//
//  UserMetrix_iclientTests.m
//  UserMetrix-iclientTests
//
//  Created by Clinton Freeman on 30/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserMetrix_iclientTests.h"
#import "UserMetrix.h"


@implementation UserMetrix_iclientTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSLog(@"************ Test Message");

	[UserMetrix configure:3 canSendLogs:false];
	STAssertEquals([UserMetrix projectID], (NSUInteger) 3, @"Unable to configure logs.");
	STAssertFalse([UserMetrix canSendLogs], @"Sending logs should be false by default.");
    
	[UserMetrix setCanSendLogs:true];
	STAssertTrue([UserMetrix canSendLogs], @"Unable to set can send logs.");
    
	[UserMetrix event:@"first event" source:UM_LOG_SOURCE];
	[UserMetrix view:@"first view" source:UM_LOG_SOURCE];
	[UserMetrix frustration:@"first frustration" source:UM_LOG_SOURCE];
	
	@try {
		[NSException raise:@"Test" format:@"We gone and done bad"];
	} @catch (NSException *exception) {		
		[UserMetrix errorWithException:exception source:UM_LOG_SOURCE];
	}
	[UserMetrix errorWithMessage:@"first error message" source:UM_LOG_SOURCE];
	[UserMetrix shutdown];

//    STFail(@"Unit tests are not implemented yet in UserMetrix-iclientTests");
}

@end
