//
//  SdefXMLObject.h
//  Sdef Editor
//
//  Created by Grayfox on 01/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefBase.h"
#import "SdefType.h"
#import "SdefSynonym.h"
#import "SdefXMLParser.h"

@class SdefXMLNode;
@interface SdefObject (SdefXMLManager)
#pragma mark Parser
- (id)initWithAttributes:(NSDictionary *)attributes;
- (void)setAttributes:(NSDictionary *)attrs;

- (int)acceptXMLElement:(NSString *)element;

#pragma mark Generator
- (NSString *)xmlElementName;
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;

@end

@interface SdefType (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;
@end

#pragma mark -
@interface SdefSynonym (SdefXMLManager)
#pragma mark Parser
- (void)setAttributes:(NSDictionary *)attrs;
- (int)acceptXMLElement:(NSString *)element;

#pragma mark Generator
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version;
@end
