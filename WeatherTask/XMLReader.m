
#import "XMLReader.h"

@implementation XMLReader

@synthesize stringValue;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error
{
    XMLReader *reader = [[XMLReader alloc]init];
    NSDictionary *rootDictionary = [reader objectWithData:data];
    return rootDictionary;
}
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error
{
    NSArray* lines = [string componentsSeparatedByString:@"\n"];
    NSMutableString* strData = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < [lines count]; i++)
    {
        [strData appendString:[[lines objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    NSData *data = [strData dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data error:error];
}
- (NSDictionary *)objectWithData:(NSData *)data
{
    MainDictionary=[[NSMutableDictionary alloc]init];
    dictArray=[[NSMutableArray alloc]init];
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    // Return the stack's root dictionary on success
    if (success)
    {
        return (NSDictionary*)[dictArray objectAtIndex:0];
    }
    NSLog(@"Parsning failed");
    return nil;
}
#pragma mark -
#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    [dictArray addObject:MainDictionary];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSMutableDictionary *_newDict=[NSMutableDictionary dictionary];
    [dictArray addObject:_newDict];
    [_newDict addEntriesFromDictionary:attributeDict];
}
-(void)addToExistingParent:(NSMutableDictionary*)parentDict refArrayObject:(NSMutableArray*)referenceObject withElement:(NSString*)elementName withObject:(NSMutableArray*)Objects
{
    for (int i=0; i< [Objects count]; i++)
    {
        [referenceObject addObject:[Objects objectAtIndex:i]];
    }
    [parentDict setObject:referenceObject forKey:elementName];
}
-(void)checkForElement:(NSString*)elementName inDictionary:(NSMutableDictionary*)parentDict withObject:(id)Objects
{
    if ([[parentDict objectForKey:elementName] isKindOfClass:[NSMutableArray class]])
    {
        NSMutableArray *referenceObject=[parentDict objectForKey:elementName];
        [self addToExistingParent:parentDict refArrayObject:referenceObject withElement:elementName withObject:[[NSMutableArray alloc]initWithObjects:Objects, nil]];
    }
    else
    {
        NSString *existObject=[parentDict objectForKey:elementName];
        NSMutableArray *newDictArray=[NSMutableArray array];
        [self addToExistingParent:parentDict refArrayObject:newDictArray withElement:elementName withObject:[[NSMutableArray alloc]initWithObjects:existObject,Objects, nil]];
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (foundString)
    {
        NSDictionary *attributes;
        if ([[[dictArray lastObject] allKeys] count])
        {
            attributes=[dictArray lastObject];
        }
        [dictArray removeLastObject];
        NSMutableDictionary *parentDict=[dictArray lastObject];
        if ([parentDict objectForKey:elementName])
        {
            [self checkForElement:elementName inDictionary:parentDict withObject:self.stringValue];
            
        }
        else
        {
            [parentDict setObject:self.stringValue forKey:elementName];
        }
        if (attributes)
        {
            [self checkForElement:elementName inDictionary:parentDict withObject:attributes];
            
        }
        foundString =FALSE;
    }
    else
    {
        NSMutableDictionary *_lastDict=[dictArray lastObject];
        if ([[_lastDict allKeys] count])
        {
            [dictArray removeLastObject];
            NSMutableDictionary *parentDict=[dictArray lastObject];
            if ([parentDict objectForKey:elementName])
            {
                if ([[parentDict objectForKey:elementName] isKindOfClass:[NSMutableArray class]])
                {
                    NSMutableArray *referenceObject=[parentDict objectForKey:elementName];
                    [self addToExistingParent:parentDict refArrayObject:referenceObject withElement:elementName withObject:[[NSMutableArray alloc]initWithObjects:_lastDict, nil]];
                }
                else if ([[parentDict objectForKey:elementName] isKindOfClass:[NSMutableDictionary class]])
                {
                    NSMutableDictionary *existDict=[parentDict objectForKey:elementName];
                    NSMutableArray *newDictArray=[NSMutableArray array];
                    [self addToExistingParent:parentDict refArrayObject:newDictArray withElement:elementName withObject:[[NSMutableArray alloc]initWithObjects:existDict,_lastDict, nil]];
                }
            }
            else
            {
                [parentDict setObject:_lastDict forKey:elementName];
            }
        }
        else
        {
            [dictArray removeLastObject];
            NSMutableDictionary *parentDict=[dictArray lastObject];
            [parentDict setObject:@"" forKey:elementName];
        }
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.stringValue=string;
    foundString=TRUE;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Parsing error==%@",[parseError localizedDescription]);
}
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}
@end