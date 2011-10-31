/*
 * UserMetrix.h
 * UserMetrix-iclient
 *
 * VERSION: 1.0.1
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
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define UM_LOG_VERSION 1
#define UM_LOG_SOURCE [NSString stringWithUTF8String:__FILE__]

///
/// The main UserMetrix logging object
///
@interface UserMetrix : NSObject {
	BOOL canSendLogs;
	NSUInteger projectID;	
	NSString *tmpLog;
	NSFileHandle *logHandle;
	double startTime;
}

///
/// Call this method when your application starts, supply your usermetrix ID as the parameter.
///
+ (void) configure:(NSUInteger)newProjectID canSendLogs:(BOOL)canSendLogs;

///
/// Call this method when your application resumes, supply your userMetrix ID as the paramter.
///
+ (void) resume:(NSUInteger)newProjectID canSendLogs:(BOOL)canSendLogs;

///
/// Call this method when your application closes, it packages up all the relevant usage information
/// and fires it off to the UserMetrix server.
///
+ (void) shutdown;

///
/// Use this method to track when a view is presented to the end-user.
/// @param message The description of the view that is presented to the user, i.e. something like
/// 'compose email', 'configure screen', etc.
/// @param source The source code that triggers this view, pass UM_LOG_SOURCE to have the
/// pre-processor automatically figure it out.
///
+ (void) view:(NSString *)message source:(NSString *)source;

///
/// Use this method to track when an event is triggered by the end-user.
/// @param message The description of the event the user is triggering, i.e. something like 'send',
/// 'purchase', 'save', etc.
/// @param source The source code that triggers this event, pass UM_LOG_SOURCE to have the
/// pre-processor automatically figure it out.
///
+ (void) event:(NSString *)message source:(NSString *)source;

///
/// Use this method to track when an end-user is frustrated, this could be bound to a button press,
/// or seamlessly integrated into a gesture (like when the end-user shakes his device).
/// @param message You can also accept written descriptions of what is frustrating the end-user,
/// simply pass in what they are saying into the message parameter.
/// @param source The source code that triggers this frustration, pass UM_LOG_SOURCE to have the
/// pre-processor automatically figure it out.
///
+ (void) frustration:(NSString *)message source:(NSString *)source;

///
/// Use this method to track when an exception or error is encountered by yoru application.
/// @param srcError The originating exception that you have trapped.
/// @param source The source code that caught this error, pass UM_LOG_SOURCE to have the
/// pre-processor automatically figure it out.
///
+ (void) errorWithException:(NSException *)srcError source:(NSString *)source;

///
/// Use this method to track when an error without source exception.
/// @param message Written details of the error message that you want capture.
/// @param source The source code that caught this error, pass UM_LOG_SOURCE to have the
/// pre-processor automatically figure it out.
///
+ (void) errorWithMessage:(NSString *)message source:(NSString *)source;

///
/// @return the projectID configured for this project.
///
+ (NSUInteger) projectID;

///
/// @return TRUE if the end-user has aggreed to transmit, error, frustration and usage information
/// back to UserMetrix. FALSE Otherwise.
///
+ (BOOL) canSendLogs;

///
/// Set to TRUE if the end-user has aggreed to transmit error, frustration and usage information
/// back to UserMetrix. FALSE if they have not aggreeed.
///
+ (void) setCanSendLogs:(BOOL)canSend;
	
@end
