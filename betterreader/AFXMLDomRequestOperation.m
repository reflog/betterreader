#import "AFXMLDomRequestOperation.h"
#include <Availability.h>

static dispatch_queue_t af_xml_request_operation_processing_queue;
static dispatch_queue_t xml_request_operation_processing_queue() {
    if (af_xml_request_operation_processing_queue == NULL) {
        af_xml_request_operation_processing_queue = dispatch_queue_create("com.alamofire.networking.xml-request.processing", 0);
    }
    
    return af_xml_request_operation_processing_queue;
}

@interface AFXMLDomRequestOperation ()
@property (readwrite, nonatomic, retain) GDataXMLDocument *responseXMLDocument;
@property (readwrite, nonatomic, retain) NSError *XMLError;
@end

@implementation AFXMLDomRequestOperation
@synthesize responseXMLDocument = _responseXMLDocument;
@synthesize XMLError = _XMLError;


+ (AFXMLDomRequestOperation *)XMLDocumentRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, GDataXMLDocument *document))success
                                                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, GDataXMLDocument *document))failure
{
    AFXMLDomRequestOperation *requestOperation = [[[self alloc] initWithRequest:urlRequest] autorelease];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, __unused id responseObject) {
        if (success) {
            GDataXMLDocument *XMLDocument = [(AFXMLDomRequestOperation *)operation responseXMLDocument];            
            success(operation.request, operation.response, XMLDocument);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            GDataXMLDocument *XMLDocument = [(AFXMLDomRequestOperation *)operation responseXMLDocument];
            failure(operation.request, operation.response, error, XMLDocument);
        }
    }];
    
    return requestOperation;
}


- (void)dealloc {
    [_responseXMLDocument release];
    [_XMLError release];
    
    [super dealloc];
}
- (GDataXMLDocument *)responseXMLDocument {
    if (!_responseXMLDocument && [self.responseData length] > 0 && [self isFinished]) {
        NSError *error = nil;
        self.responseXMLDocument = [[[GDataXMLDocument alloc] initWithData:self.responseData options:0 error:&error] autorelease];
        self.XMLError = error;
    }
    
    return _responseXMLDocument;
}

- (NSError *)error {
    if (_XMLError) {
        return _XMLError;
    } else {
        return [super error];
    }
}

#pragma mark - AFHTTPRequestOperation

+ (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:@"application/xml", @"text/xml", nil];
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    return [[[request URL] pathExtension] isEqualToString:@"xml"] || [super canProcessRequest:request];
}


- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    self.completionBlock = ^ {
        if ([self isCancelled]) {
            return;
        }
        
        dispatch_async(xml_request_operation_processing_queue(), ^(void) {
            
            if (self.error) {
                if (failure) {
                    dispatch_async(self.failureCallbackQueue ? self.failureCallbackQueue : dispatch_get_main_queue(), ^{
                        failure(self, self.error);
                    });
                }
            } else {
                if (success) {
                    dispatch_async(self.successCallbackQueue ? self.successCallbackQueue : dispatch_get_main_queue(), ^{
                        success(self, [self responseXMLDocument]);
                    });
                } 
            }
        });
    };    
}

@end
