//
//  UserMetrix_iclientTests.m
//  UserMetrix-iclientTests
//
//  Created by Clinton Freeman on 30/08/11.
/*
 * UserMetrix_iclientTests.m
 * UserMetrix-iclientTests
 *
 * Copyright (c) 2011 UserMetrix Pty Ltd. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
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

	[UserMetrix configure:1 canSendLogs:false];
	STAssertEquals([UserMetrix projectID], (NSUInteger) 1, @"Unable to configure logs.");
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
