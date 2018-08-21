/*
 Original author: artemyarulin
 https://github.com/artemyarulin/JSCoreBom/blob/master/JSCoreBom/Modules/ModuleXMLHttpRequest.m

 The MIT License (MIT)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/
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
