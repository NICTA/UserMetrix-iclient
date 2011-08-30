//
//  UserMetrix.h
//  UserMetrix-iclient
//
//  Created by Clinton Freeman on 2011/08/01.
//  Copyright 2011 UserMetrix Pty Ltd. All rights reserved.
//
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
