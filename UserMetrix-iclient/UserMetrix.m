//
//  UserMetrix.m
//  UserMetrix-iclient
//
//  Created by Clinton Freeman on 2011/08/01.
//  Copyright 2011 UserMetrix Pty Ltd. All rights reserved.
//
#import "UserMetrix.h"
#import <UIKit/UIDevice.h>

@implementation UserMetrix

///
/// Destructor.
///
- (void) dealloc {
	[tmpLog release];
	[super dealloc];
}

///
/// projectID setter.
/// @param The new project ID to use with UserMetrix.
///
- (void) setProjectID:(NSUInteger)newProjectID {
	projectID = newProjectID;
}

///
/// projectID getter.
/// @return The ID for the project.
///
- (NSUInteger) projectID {
	return projectID;
}

///
/// canSendLogs setter
/// @param canSend
///
- (void) setCanSendLogs:(BOOL)canSend {
	canSendLogs = canSend;
}

///
/// canSendLogs getter.
/// @return True if the end-user has permitted the transmission of logs.
///
- (BOOL) canSendLogs {
	return canSendLogs;
}

///
/// This method will close the temporary log file on disk.
///
- (void) closeLog {
	[logHandle closeFile];
	[logHandle release];
}

///
/// This will send the temporary log to the UserMetrix server if it exists and the end-user has
/// granted permission to send usage, error and frustration logs. This method will remove the
/// temporary log file from disk on completion.
///
- (void) sendMessage {
	// Only send the file if it exists, and we have permission from the end-user to transmit usage,
	// error and frustration information.
	if (canSendLogs && [[NSFileManager defaultManager] fileExistsAtPath:tmpLog]) {
		// Build the URL to transmit the log file too.
		NSURL *usermetrixURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://usermetrix.com/projects/%i/log", projectID]];
		NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:usermetrixURL];
		[postRequest setHTTPMethod:@"POST"];

		// Set the header for the message.
		NSString *boundary = [NSString stringWithString:@"--0xKhTmLbOuNdArY"];
		NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;boundary=%@", boundary];
		[postRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];

		// Set the body for the message.
		NSMutableData *postBody = [NSMutableData data];
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"upload\"; filename=\"usermetrix.log\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[NSData dataWithContentsOfFile:tmpLog]];
		[postBody appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postRequest setHTTPBody:postBody];

		// If the request is looking decently formed. Send it off.
		if ([NSURLConnection canHandleRequest:postRequest]) {
			[NSURLConnection sendSynchronousRequest:postRequest returningResponse:nil error:nil];
		}

		// Remove the log file after we have transmitted it.
		[[NSFileManager defaultManager] removeItemAtPath:tmpLog error:nil];
	}
}

///
/// Writes a message to the temporary log.
///
/// @param type The type of message we are writing to the log, can be either usage, view, error or
/// frustration.
/// @param message The content of the message to add to the log, this is a developer defined
/// message.
/// @param source The source of the message in the source code.
///
- (void) writeMessageType:(NSString *)type message:(NSString *)message source:(NSString *)source {
	long currentTime = (long)((CACurrentMediaTime() - startTime) * 1000.0f);
	[logHandle writeData:[[NSString stringWithFormat:@"  - type: %@\n", type] dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];

	[logHandle writeData:[[NSString stringWithFormat:@"    time: %i\n", currentTime] dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];

	// Only include the file of the whole source path.
	NSString *srcFile = [source lastPathComponent];
	[logHandle writeData:[[NSString stringWithFormat:@"    source: %@\n", srcFile] dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];
	
	[logHandle	writeData:[[NSString stringWithFormat:@"    message: %@\n", message] dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];
}

///
/// Generates the UUID for the user. If this is the first time the UserMetrix client has been
/// initialised on the end-user machine, it will generate a fresh UUID and save it to disk.
/// Otherwise It will load the UUID from disk.
///
/// @return The UUID that represents a single user interaction with an application.
///
- (NSString *) generateUUID {
	NSString *result;

	// Generate the path to the UserMetrix ID on disk.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask, YES);
	NSString *docsDirectory = [paths objectAtIndex:0];
	NSString *uuidFile = [docsDirectory stringByAppendingPathComponent:@"usermetrix.id"];

	// UUID file already exists, we want our existing UUID.
	if ([[NSFileManager defaultManager] fileExistsAtPath:uuidFile]) {
		// Load the existing UUID from disk.
		result = [NSString stringWithContentsOfFile:uuidFile encoding:NSUTF8StringEncoding error:NULL];

	// UUID does not yet exist - create a new one.
	} else {
		CFUUIDRef theUUID = CFUUIDCreate(NULL);
		CFStringRef uuid = CFUUIDCreateString(NULL, theUUID);
		CFRelease(theUUID);
		result = [(NSString *) uuid autorelease];
		
		// Create UUID file and save it.
		[result writeToFile:uuidFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	}

	return result;	
}

///
/// Initalises the temporary log on disk.
/// @param newLog the absolute path to the temporary file on disk.
///
- (void) setTmpLog:(NSString *)newLog {
	// Determine the start time.
	NSDate *now = [NSDate date];
	startTime = CACurrentMediaTime();

	[tmpLog autorelease];
	tmpLog = [newLog retain];

	// Attempt to send the log if it already exists.
	[self sendMessage];

	// Intalise the log file.
	[@"---\n" writeToFile:tmpLog atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	logHandle = [[NSFileHandle fileHandleForWritingAtPath:tmpLog] retain];
	[logHandle seekToEndOfFile];
	
	// Write the version of the log schema to disk.
	[logHandle writeData:[[NSString stringWithFormat:@"v: %u\n", UM_LOG_VERSION] dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];

	// Push the system block and UUID to disk
	[logHandle writeData:[@"system:\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];
	[logHandle writeData:[[NSString stringWithFormat:@"  id: %@\n", [self generateUUID]] dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];

	// Push the operating system version to disk.
	NSString *operatingSystem = [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName],
                                                                     [[UIDevice currentDevice] systemVersion]];
	[logHandle writeData:[[NSString stringWithFormat:@"  os: %@\n", operatingSystem] dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];

	// Pust the start time of the application to disk.
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ'"];
	[dateFormatter setLocale:locale];
	NSString *date = [dateFormatter stringFromDate:now];
	[logHandle writeData:[[NSString stringWithFormat:@"  start: %@\n", date] dataUsingEncoding:NSUTF8StringEncoding]];
    [dateFormatter release];
    [locale release];
    
    
	[logHandle seekToEndOfFile];
	
	// Mark the start of the log
	[logHandle writeData:[@"meta:\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];
	[logHandle writeData:[@"log:\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[logHandle seekToEndOfFile];
}

+ (UserMetrix *) instance {
	static UserMetrix *instance;
	
	@synchronized(self) {
		if (instance == nil) {
			instance = [[UserMetrix alloc] init];
		}
		
		return instance;
	}
}

+ (void) configure:(NSUInteger)newProjectID canSendLogs:(BOOL)canSendLogs {
	[[UserMetrix instance] setProjectID:newProjectID];
	[[UserMetrix instance] setCanSendLogs:canSendLogs];

	// Determine the log we are about to initalise.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	[[UserMetrix instance] setTmpLog:[documentsDirectory stringByAppendingPathComponent:@"usermetrix.log"]];	
}

+ (void) shutdown {
	[[UserMetrix instance] closeLog];
	[[UserMetrix instance] sendMessage];
}

+ (void) view:(NSString *)message source:(NSString *)source {
	[[UserMetrix instance] writeMessageType:@"view" message:message source:source];
}

+ (void) event:(NSString *)message source:(NSString *)source {
	[[UserMetrix instance] writeMessageType:@"usage" message:message source:source];
}

+ (void) frustration:(NSString *)message source:(NSString *)source {
	[[UserMetrix instance] writeMessageType:@"frustration" message:message source:source];
}

+ (void) errorWithException:(NSException *)srcError source:(NSString *)source {
	[[UserMetrix instance] writeMessageType:@"error" message:[srcError reason] source:source];
}

+ (void) errorWithMessage:(NSString *)message source:(NSString *)source {
	[[UserMetrix instance] writeMessageType:@"error" message:message source:source];
}

+ (NSUInteger) projectID {
	return [[UserMetrix instance] projectID];
}

+ (BOOL) canSendLogs {
	return [[UserMetrix instance] canSendLogs];
}

+ (void) setCanSendLogs:(BOOL)canSend {
	[[UserMetrix instance] setCanSendLogs:canSend];
}


@end
