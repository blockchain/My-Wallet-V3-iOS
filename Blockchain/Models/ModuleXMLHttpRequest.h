#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol ExportXMLHttpRequest <JSExport>

@property NSString* responseText;
@property JSValue* onload;
@property JSValue* onerror;
@property NSInteger status;

-(instancetype)init;

-(void)open:(NSString*)httpMethod :(NSString*)url :(bool)async;
-(void)send:(id)data;
-(void)setRequestHeader: (NSString *)name :(NSString *)value;
-(NSString *)getAllResponseHeaders;
-(NSString *)getReponseHeader:(NSString *)name;

@end

@interface ModuleXMLHttpRequest: NSObject <ExportXMLHttpRequest>

@end
