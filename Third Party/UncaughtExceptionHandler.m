//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "UncaughtExceptionHandler.h"
//#import "DeviceIdentifier.h"
#include <libkern/OSAtomic.h>
#include <sys/sysctl.h>
#import "KeychainItemWrapper+Credentials.h"
#include <execinfo.h>
#import "NSString+URLEncode.h"
#import "NSURLSession+SendSynchronousRequest.h"
#import "Blockchain-Swift.h"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace
{
	 void* callstack[128];
	 int frames = backtrace(callstack, 128);
	 char **strs = backtrace_symbols(callstack, frames);
	 
	 int i;
	 NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
	 for (
	 	i = UncaughtExceptionHandlerSkipAddressCount;
	 	i < UncaughtExceptionHandlerSkipAddressCount +
			UncaughtExceptionHandlerReportAddressCount;
		i++)
	 {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
	 }
	 free(strs);
	 
	 return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
	if (anIndex == 0) {
		dismissed = YES;
	}
}

+ (NSString *)osVersionBuild {
    int mib[2] = {CTL_KERN, KERN_OSVERSION};
    u_int namelen = sizeof(mib) / sizeof(mib[0]);
    size_t bufferSize = 0;
    
    NSString *osBuildVersion = nil;
    
    // Get the size for the buffer
    sysctl(mib, namelen, NULL, &bufferSize, NULL, 0);
    
    u_char buildBuffer[bufferSize];
    int result = sysctl(mib, namelen, buildBuffer, &bufferSize, NULL, 0);
    
    if (result >= 0) {
        osBuildVersion = [[NSString alloc] initWithBytes:buildBuffer length:bufferSize encoding:NSUTF8StringEncoding]; 
    }
    
    return osBuildVersion;   
}

+ (NSString *)appNameAndVersionNumberDisplayString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"%@, Version %@ (%@)",
            appDisplayName, majorVersion, minorVersion];
}

+ (void)logException:(NSException*)exception walletIsLoaded:(BOOL)walletIsLoaded walletIsInitialized:(BOOL)walletIsInitialized
{
    TabControllerManager *tabControllerManager = [AppCoordinator sharedInstance].tabControllerManager;
    NSString * message = [NSString stringWithFormat:@"<pre>App Version: %@\nSystem Name: %@ -  System Version : %@\nActive View Controller: %@\nWallet State: JSLoaded = %@, isInitialized = %@\nDevice: %@ Language: %@\nGUID Hash: %@\n\nReason: %@\n\nStacktrace:%@</pre>",
                          [self appNameAndVersionNumberDisplayString],
                          [[UIDevice currentDevice] systemName],
                          [[UIDevice currentDevice] systemVersion],
                          [tabControllerManager.tabViewController.activeViewController class],
                          walletIsLoaded ? @"TRUE" : @"FALSE",
                          walletIsInitialized? @"TRUE" : @"FALSE",
                          @"",//[DeviceIdentifier deviceName],
                          [[NSLocale preferredLanguages] firstObject],
                          [KeychainItemWrapper hashedGuid],
                          [exception reason],
                          [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]
                          ];
    
    DLog(@"Logging exception: %@", message);

    message =  [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
	NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"https://blockchain.info/exception_log?device=iphone&message=%@", message]];
        
    NSHTTPURLResponse * repsonse = NULL;
    NSError * error = NULL;
    
    [NSURLSession sendSynchronousRequest:[NSURLRequest requestWithURL:url] session:[[NetworkManager sharedInstance] session] returningResponse:&repsonse error:&error sessionDescription:nil];
}

- (void)handleException:(NSException *)exception
{
    BOOL walletIsLoaded = NO;
    BOOL walletIsInitialized = [WalletManager.sharedInstance.wallet isInitialized];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        [UncaughtExceptionHandler logException:exception walletIsLoaded:walletIsLoaded walletIsInitialized:walletIsInitialized];
    });
	
    NSString * message = [NSString stringWithFormat:NSLocalizedString(
                                                                      @"The application encountered a fatal error and will close shortly.\n\n"
                                                                      @"Debug details follow:\n%@\n%@", nil),
                          [exception reason],
                          [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    
	UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:NSLocalizedString(@"Unhandled exception", nil)
     message:message
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:nil];
	[alert show];
	
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
	
    NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
	while (!dismissed) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

		for (NSString *mode in (__bridge NSArray *)allModes) {
			CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
		}
        
        if (now - start > 20.0f) {
            break;
        }
	}
	
	CFRelease(allModes);
}

@end

void HandleException(NSException *exception)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	NSMutableDictionary *userInfo =
		[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[[UncaughtExceptionHandler alloc] init]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:[exception name]
				reason:[exception reason]
				userInfo:userInfo]
        waitUntilDone:YES];
}

void SignalHandler(int signal)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSMutableDictionary *userInfo =
		[NSMutableDictionary
			dictionaryWithObject:[NSNumber numberWithInt:signal]
			forKey:UncaughtExceptionHandlerSignalKey];

	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[[UncaughtExceptionHandler alloc] init]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
				reason:
					[NSString stringWithFormat:
						NSLocalizedString(@"Signal %d was raised.", nil),
						signal]
				userInfo:
					[NSDictionary
						dictionaryWithObject:[NSNumber numberWithInt:signal]
						forKey:UncaughtExceptionHandlerSignalKey]]
		waitUntilDone:YES];
}
