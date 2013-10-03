//
//  AppDelegate.m
//  ttocr
//
//  Created by mengxipeng on 21/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import "AppDelegate.h"

#define TAG_SERVERNAME @"servername"
#define TAG_CHARACTER_CATEGORY @"characterCategory"
#define TAG_UPLOAD_SERVER @"uploadServer"
 
@implementation AppDelegate

-(void)setUploadServer:(BOOL)uploadServer
{
  [[NSUserDefaults standardUserDefaults]setBool:uploadServer forKey:TAG_UPLOAD_SERVER];
  [[NSUserDefaults standardUserDefaults]synchronize];
}

-(BOOL)uploadServer
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:TAG_UPLOAD_SERVER];
}

-(void)setCharacterCategory:(int)characterCategory
{
  [[NSUserDefaults standardUserDefaults]setInteger:characterCategory forKey:TAG_CHARACTER_CATEGORY];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

-(int)characterCategory
{
  return [[NSUserDefaults standardUserDefaults] integerForKey:TAG_CHARACTER_CATEGORY];
}

-(void)setServername:(NSString *)servername
{
  [[NSUserDefaults standardUserDefaults] setObject:servername forKey:TAG_SERVERNAME];
  [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSString*)servername
{
  return [[NSUserDefaults standardUserDefaults]objectForKey:TAG_SERVERNAME];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
  
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                           (unsigned long)NULL), ^(void) {
    [self uploadImgFiles];
  });
     return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)uploadImgFiles
{
  while (TRUE) {
    
  
    NSString *imgDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/imgs"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imgDir]) {
      [[NSFileManager defaultManager] createDirectoryAtPath:imgDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSArray* imgFiles =  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imgDir error:nil];
    
    for (NSString* fileName in imgFiles) {
      NSLog(@"%@", fileName);
      
      if (self.uploadServer) {
        [self sendImageToServerAndDeleteIt:[[imgDir stringByAppendingString:@"/"] stringByAppendingString:fileName]];
      }
    }
  
    [NSThread sleepForTimeInterval:1.0];
  }

}


-(void)sendImageToServerAndDeleteIt:(NSString*)fullFileName
{
  if ([[NSFileManager defaultManager] fileExistsAtPath:fullFileName])
  {
    NSString* boundary = @"=======&&=======";
    NSString* requestURL = [NSString stringWithFormat: @"http://%@/~mengxipeng/uploadimage.php", self.servername];
    NSLog(@"%@", requestURL);
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSString* FileParamConstant = [fullFileName lastPathComponent];
    //NSLog(@"FileParamConstant %@", FileParamConstant);
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    
    // add image data
    NSData *imageData = [[NSFileManager defaultManager ]contentsAtPath:fullFileName];
    if (imageData) {
      [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
      
      // NSLog(@"body %@", [[NSString alloc]initWithData:body encoding:NSUTF8StringEncoding]);
      
      [body appendData:imageData];
      [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    [request setURL:[NSURL URLWithString:requestURL]];
    
    // send request
    NSURLConnection* connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (connection) {
      //NSLog(@"send ok");
      [connection start];
      NSError* error;
      [[NSFileManager defaultManager] removeItemAtPath:fullFileName error:&error];

    }
    else
      NSLog(@"send failed");
    
   
    }
  
}

@end
