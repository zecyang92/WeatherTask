//
//  XMLReader.h
//
//

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject<NSXMLParserDelegate>
{
    NSMutableDictionary *MainDictionary;
    NSMutableArray *dictArray;
    BOOL foundString;
}
@property(strong)NSString *stringValue;
- (NSDictionary *)objectWithData:(NSData *)data;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
@end
