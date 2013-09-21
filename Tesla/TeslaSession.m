//
//  TeslaSession.m
//  Tesla Example
//
//  Created by Cory D. Wiles on 9/10/13.
//  Copyright (c) 2013 Mattt Thompson. All rights reserved.
//

#import "TeslaSession.h"
#import "Tesla.h"

@interface TeslaSession()

@property (nonatomic, weak) NSOperationQueue *sessionQueue;
@property (nonatomic, weak) id <NSURLSessionDelegate> delegate;

@end

@implementation TeslaSession

+ (instancetype)backgroundSessionWithDelegate:(id <NSURLSessionDelegate>)delegate {
  
  static TeslaSession * session = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfiguration:@"tesla.backgroundsession"];
    session = [[self alloc] initWithDelegate:delegate withQueue:nil configuration:config];
  });
  
  return session;
}

+ (instancetype)sharedSessionWithDelegate:(id <NSURLSessionDelegate>)delegate
                                    queue:(NSOperationQueue *)aQueue {

  static TeslaSession *__sharedSession = nil;
  static dispatch_once_t oncePredicate;
  
  dispatch_once(&oncePredicate, ^{
    __sharedSession = [[self alloc] initWithDelegate:delegate withQueue:aQueue];
  });
  
  return __sharedSession;
}

- (instancetype)initWithDelegate:(id <NSURLSessionDelegate>)delegate withQueue:(NSOperationQueue *)queue {
  
  self = [super init];
  
  if (self) {
    
    _delegate     = delegate;
    _sessionQueue = queue;
    
    /**
     * Basic implementation of saving log information to backend using NSURLSession
     * This is setup for localhost at the moment but will be configurable at a
     * later date.
     */
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    /**
     * NSURLSession retains it's delegate. Not sure if our property should be 
     * weak (normal pattern) or strong. Currently it is weak.
     */
    
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                             delegate:self.delegate
                                        delegateQueue:self.sessionQueue];
    
    _session.sessionDescription = @"Testing upload of logging information";

  }
  
  return self;
}


- (instancetype)initWithDelegate:(id <NSURLSessionDelegate>)delegate
                       withQueue:(NSOperationQueue *)queue
                   configuration:(NSURLSessionConfiguration *)config {
  
  self = [super init];
  
  if (self) {
    
    _delegate     = delegate;
    _sessionQueue = queue;
    
    _session = [NSURLSession sessionWithConfiguration:config
                                             delegate:self.delegate
                                        delegateQueue:nil];
    
    _session.sessionDescription = @"Testing upload of logging information";
  }
  
  return self;
}

- (void)sendFilesInBackground:(NSArray *)files {

  BOOL goodSetup = [self.apiKey length] && [self.urlString length];

  NSAssert(goodSetup, @"Error: TeslaSession must have an api key & url string!");
  
  for (NSString *path in files) {
    
    if ([path rangeOfString:TeslaLogFilePrefix].location == NSNotFound && path != nil) {
      continue;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.apiKey forHTTPHeaderField:@"api_key"];
    
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request
                                                                    fromFile:[NSURL fileURLWithPath:path]];
    uploadTask.taskDescription = path;
    [uploadTask resume];
  }
  
  /**
   * Below code throws random expections. Not sure why.
   */

//  [files enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop){
//  
//    if ([path rangeOfString:TeslaLogFilePrefix].location != NSNotFound && path) {
//      
//      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
//      
//      request.HTTPMethod = @"POST";
//      
//      [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
//      [request setValue:self.apiKey forHTTPHeaderField:@"api_key"];
//      
//      NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request
//                                                                      fromFile:[NSURL fileURLWithPath:path]];
//      uploadTask.taskDescription = path;
//      [uploadTask resume];
//    }
//  }];
}
@end
