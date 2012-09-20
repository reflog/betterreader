#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "GDataXMLNode.h"
#import <Availability.h>

/**
 `AFXMLDomRequestOperation` is a subclass of `AFHTTPRequestOperation` for downloading and working with XML response data.
 
 ## Acceptable Content Types
 
 By default, `AFXMLRequestOperation` accepts the following MIME types, which includes the official standard, `application/xml`, as well as other commonly-used types:
 
 - `application/xml`
 - `text/xml`
 
 ## Use With AFHTTPClient
 
 When `AFXMLRequestOperation` is registered with `AFHTTPClient`, the response object in the success callback of `HTTPRequestOperationWithRequest:success:failure:` will be an instance of `GDataXMLDocument`.
 */
@interface AFXMLDomRequestOperation : AFHTTPRequestOperation

///----------------------------
/// @name Getting Response Data
///----------------------------

@property (readonly, nonatomic, retain) GDataXMLDocument *responseXMLDocument;

/**
 Creates and returns an `AFXMLRequestOperation` object and sets the specified success and failure callbacks.
 
 @param urlRequest The request object to be loaded asynchronously during execution of the operation
 @param success A block object to be executed when the operation finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the XML document created from the response data of request.
 @param failure A block object to be executed when the operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data as XML. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error describing the network or parsing error that occurred.
 
 @return A new XML request operation
 */
+ (AFXMLDomRequestOperation *)XMLDocumentRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, GDataXMLDocument *document))success
                                                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, GDataXMLDocument *document))failure;


@end
