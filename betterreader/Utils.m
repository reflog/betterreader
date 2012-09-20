#import "Utils.h"

NSString * descriptionForRequest(NSURLRequest* request)
{
    __block NSMutableString *displayString = [NSMutableString stringWithFormat:@"%@\nRequest\n-------\ncurl -X %@", 
                                              [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]],
                                              [request HTTPMethod]];
    
    [[request allHTTPHeaderFields] enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop)
     {
         [displayString appendFormat:@" -H \"%@: %@\"", key, val];
     }];
    
    [displayString appendFormat:@" \"%@\"",  [request.URL absoluteString]];
    
    if ([[request HTTPMethod] isEqualToString:@"POST"]) {
        NSString *bodyString = [[NSString alloc] initWithData:[request HTTPBody]
                                                     encoding:NSUTF8StringEncoding] ;
        [displayString appendFormat:@" -d \"%@\"", bodyString];        
    }
    
    return displayString;
}


void ShowMessage(NSString * title, NSString* message)
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}