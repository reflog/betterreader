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
//#define REQ_DEBUG


+ (AFXMLDomRequestOperation *)XMLDocumentRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, GDataXMLDocument *document))success
                                                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, GDataXMLDocument *document))failure
{
#ifdef REQ_DEBUG
    dispatch_async(xml_request_operation_processing_queue(), ^(void) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"req1" ofType:@""];
        NSData* d = [NSData dataWithContentsOfFile: filePath];
        
        success(nil,nil, [[GDataXMLDocument alloc] initWithData:d options:0 error:NULL] );
    });
    return nil;
#endif
    AFXMLDomRequestOperation *requestOperation = [[self alloc] initWithRequest:urlRequest] ;
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, __unused id responseObject) {
        if (success) {
            GDataXMLDocument *XMLDocument = [(AFXMLDomRequestOperation *)operation responseXMLDocument];   
            //NSLog(@"%@", [[NSString alloc]initWithData:XMLDocument.XMLData encoding:NSUTF8StringEncoding]);
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


- (GDataXMLDocument *)responseXMLDocument {
    if (!_responseXMLDocument && [self.responseData length] > 0 && [self isFinished]) {
        NSError *error = nil;
        self.responseXMLDocument = [[GDataXMLDocument alloc] initWithData:self.responseData options:0 error:&error] ;
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
    __block AFXMLDomRequestOperation* this = self;
    self.completionBlock = ^ {
        if ([this isCancelled]) {
            return;
        }
        
        dispatch_async(xml_request_operation_processing_queue(), ^(void) {
            
            if (this.error) {
                if (failure) {
                    dispatch_async(this.failureCallbackQueue ? this.failureCallbackQueue : dispatch_get_main_queue(), ^{
                        failure(this, this.error);
                    });
                }
            } else {
                if (success) {
                    dispatch_async(this.successCallbackQueue ? this.successCallbackQueue : dispatch_get_main_queue(), ^{
                        success(this, [this responseXMLDocument]);
                    });
                } 
            }
        });
    };    
}

@end
