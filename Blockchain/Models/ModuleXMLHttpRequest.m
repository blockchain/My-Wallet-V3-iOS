#import "ModuleXMLHttpRequest.h"
#import "NSURLSession+SendSynchronousRequest.h"
#import "Blockchain-Swift.h"

@implementation ModuleXMLHttpRequest
{
    NSString* _method;
    NSString* _url;
    BOOL _async;
    JSManagedValue* _onLoad;
    JSManagedValue* _onError;
    NSMutableDictionary *_requestHeaders;
    NSDictionary *_responseHeaders;
}

@synthesize responseText;
@synthesize status;

-(void)open:(NSString*)httpMethod :(NSString*)url :(bool)async;
{
    _method = httpMethod;
    _url = url;
    _async = async;
}

-(void)setOnload:(JSValue *)onload
{
    _onLoad = [JSManagedValue managedValueWithValue:onload];
    [[[JSContext currentContext] virtualMachine] addManagedReference:_onLoad withOwner:self];
}

-(JSValue*)onload {
    return _onLoad.value;
}

-(void)setOnerror:(JSValue *)onerror
{
    _onError = [JSManagedValue managedValueWithValue:onerror];
    [[[JSContext currentContext] virtualMachine] addManagedReference:_onError withOwner:self];
}

-(JSValue*)onerror { return _onError.value; }

-(void)send:(id)inputData
{
    NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
    for (NSString *name in _requestHeaders) {
        [req setValue:_requestHeaders[name] forHTTPHeaderField:name];
    }
    if ([inputData isKindOfClass:[NSString class]]) {
        req.HTTPBody = [((NSString *) inputData) dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    req.HTTPMethod = _method;

    NSHTTPURLResponse* response;
    NSError* error;
    NSData* data = [NSURLSession sendSynchronousRequest:req session:[[NetworkManager sharedInstance] session] returningResponse:&response error:&error sessionDescription:req.URL.host];
    status = [response statusCode];
    self.responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _responseHeaders = response.allHeaderFields;
    
    if (!error && _onLoad)
        [[_onLoad.value invokeMethod:@"bind" withArguments:@[self]] callWithArguments:NULL];
    else if (error && _onError)
        [[_onError.value invokeMethod:@"bind" withArguments:@[self]] callWithArguments:@[[JSValue valueWithNewErrorFromMessage:error.localizedDescription inContext:[JSContext currentContext]]]];
}

- (void)setRequestHeader:(NSString *)name :(NSString *)value {
    if (!_requestHeaders) _requestHeaders = [NSMutableDictionary new];
    _requestHeaders[name] = value;
}

- (NSString *)getAllResponseHeaders {
    NSMutableString *responseHeaders = [NSMutableString new];
    for (NSString *key in _responseHeaders) {
        [responseHeaders appendString:key];
        [responseHeaders appendString:@": "];
        [responseHeaders appendString:_responseHeaders[key]];
        [responseHeaders appendString:@"\n"];
    }
    return responseHeaders;
}

- (NSString *)getReponseHeader:(NSString *)name {
    return _responseHeaders[name];
}

- (void)setAllResponseHeaders:(NSDictionary *)responseHeaders {
    _responseHeaders = responseHeaders;
}

@end
