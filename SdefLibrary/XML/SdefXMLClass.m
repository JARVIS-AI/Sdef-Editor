/*
 *  SdefXMLClass.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefXMLBase.h"
#import "SdefContents.h"
#import "SdefXMLNode.h"
#import "SdefClass.h"

NSArray *SdefXMLAccessorStringsFromFlag(NSUInteger flag) {
  NSMutableArray *strings = [NSMutableArray array];
  if (flag & kSdefAccessorIndex) [strings addObject:@"index"];
  if (flag & kSdefAccessorID) [strings addObject:@"id"];
  if (flag & kSdefAccessorName) [strings addObject:@"name"];
  if (flag & kSdefAccessorRange) [strings addObject:@"range"];
  if (flag & kSdefAccessorRelative) [strings addObject:@"relative"];
  if (flag & kSdefAccessorTest) [strings addObject:@"test"];
  return strings;
}

NSUInteger SdefXMLAccessorFlagFromString(NSString *str) {
  NSUInteger flag = 0;
  if (str && [str rangeOfString:@"index"].location != NSNotFound) {
    flag |= kSdefAccessorIndex;
  } else if (str && [str rangeOfString:@"name"].location != NSNotFound) {
    flag |= kSdefAccessorName;
  } else if (str && [str rangeOfString:@"id"].location != NSNotFound) {
    flag |= kSdefAccessorID;
  } else if (str && [str rangeOfString:@"range"].location != NSNotFound) {
    flag |= kSdefAccessorRange;
  } else if (str && [str rangeOfString:@"relative"].location != NSNotFound) {
    flag |= kSdefAccessorRelative;
  } else if (str && [str rangeOfString:@"test"].location != NSNotFound) {
    flag |= kSdefAccessorTest;
  }
  return flag;
}

#pragma mark -
@implementation SdefClass (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self isExtension]) {
    if ([self inherits]) {
      if (node = [super xmlNodeForVersion:version]) {
        [node removeAllAttributes];
        [node setAttribute:[[self inherits] stringByEscapingEntities:nil] forKey:@"extends"];
      }
    }
  } else if (node = [super xmlNodeForVersion:version]) {
    if ([self plural]) [node setAttribute:[[self plural] stringByEscapingEntities:nil] forKey:@"plural"];
    if ([self inherits]) [node setAttribute:[[self inherits] stringByEscapingEntities:nil] forKey:@"inherits"];
    if ([self type]) {
      id type = [SdefXMLNode nodeWithElementName:@"type"];
      [type setAttribute:[[self type] stringByEscapingEntities:nil] forKey:@"type"];
      [node appendChild:type];
    }
    id contents = [[self contents] xmlNodeForVersion:version];
    if (nil != contents) {
      if ([[[node firstChild] elementName] isEqualToString:@"documentation"]) {
        [node insertChild:contents atIndex:1];
      } else {
        [node prependChild:contents];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return [self isExtension] ? @"class-extension" : @"class";
}

#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  if ([attrs objectForKey:@"extends"]) {
    [self setExtension:YES];
    [self setInherits:[[attrs objectForKey:@"extends"] stringByUnescapingEntities:nil]];
  } else {
    [self setPlural:[[attrs objectForKey:@"plural"] stringByUnescapingEntities:nil]];
    [self setInherits:[[attrs objectForKey:@"inherits"] stringByUnescapingEntities:nil]];
  }
}

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[element methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  
  /* If a single type => Tiger */
  if (isEqual(element, cmd, @"type") ||
      isEqual(element, cmd, @"element") ||
      isEqual(element, cmd, @"property")) {
    return kSdefParserTigerVersion | kSdefParserLeopardVersion;
  } else if (isEqual(element, cmd, @"responds-to")) {
    return [attrs objectForKey:@"command"] ? kSdefParserLeopardVersion : kSdefParserTigerVersion;
  } else /* If a collection => Panther */
    if (isEqual(element, cmd, @"elements") || 
        isEqual(element, cmd, @"properties") || 
        isEqual(element, cmd, @"responds-to-commands") || 
        isEqual(element, cmd, @"responds-to-events")) {
      return kSdefParserPantherVersion;
    }
  return kSdefParserAllVersions;
}

@end

#pragma mark -
@implementation SdefContents (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if ([self hasType] && (node = [super xmlNodeForVersion:version])) {
    if (![self name]) [node setAttribute:@"contents" forKey:@"name"];
    
    id attr = SdefXMLAccessStringFromFlag([self access]);
    if (nil != attr) [node setAttribute:attr forKey:@"access"];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"contents";
}

#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  
  [self setAccess:SdefXMLAccessFlagFromString([attrs objectForKey:@"access"])];
}

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}

@end

#pragma mark -
@implementation SdefElement (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if (node = [super xmlNodeForVersion:version]) {
    [node removeAttributeForKey:@"name"];
    id attr = [self name];
    if (nil != attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"type"];
    
    attr = SdefXMLAccessStringFromFlag([self access]);
    if (nil != attr) [node setAttribute:attr forKey:@"access"];
    
    /* Accessors */
    id accessors = [SdefXMLAccessorStringsFromFlag([self accessors]) objectEnumerator];
    id acc;
    while (acc = [accessors nextObject]) {
      id accNode = [SdefXMLNode nodeWithElementName:@"accessor"];
      [accNode setAttribute:acc forKey:@"style"];
      [node appendChild:accNode];
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"element";
}

#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  
  [self setName:[[attrs objectForKey:@"type"] stringByUnescapingEntities:nil]];
  [self setAccess:SdefXMLAccessFlagFromString([attrs objectForKey:@"access"])];
}

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}

@end

#pragma mark -
@implementation SdefProperty (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if (node = [super xmlNodeForVersion:version]) {
    id attr = SdefXMLAccessStringFromFlag([self access]);
    if (nil != attr) [node setAttribute:attr forKey:@"access"];
    
    if ([self isNotInProperties]) {
      if (version >= kSdefTigerVersion) {
        [node setAttribute:@"no" forKey:@"in-properties"];
      } else {
        [node setAttribute:@"not-in-properties" forKey:@"not-in-properties"];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"property";
}

#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  
  [self setAccess:SdefXMLAccessFlagFromString([attrs objectForKey:@"access"])];
  if ([[attrs objectForKey:@"in-properties"] isEqualToString:@"no"] ||
      (nil != [attrs objectForKey:@"not-in-properties"])) {
    [self setNotInProperties:YES];
  }
}

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}

@end

#pragma mark -
@implementation SdefRespondsTo (SdefXMLManager)

#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if ([self name] && (node = [super xmlNodeForVersion:version])) {
    NSString *key = @"name";
    if (version >= kSdefLeopardVersion)
      key = @"command";
    [node setAttribute:[[self name] stringByEscapingEntities:nil] forKey:key];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"responds-to";
}

#pragma mark Parsing
- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  
  NSString *cmd = [attrs objectForKey:@"command"];
  if (cmd)
    [super setName:cmd];
}

@end
