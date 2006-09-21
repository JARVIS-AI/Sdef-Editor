/*
 *  AeteClass.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "AeteObject.h"
#import "SdefClass.h"
#import <ShadowKit/SKFunctions.h>

@implementation SdefClass (AeteResource)

- (UInt32)parseData:(Byte *)data {
  unsigned length;
  BytePtr bytes = data;
  
  StringPtr pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  CFStringRef str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setName:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (long)bytes % 2;
  
  /* Identifier */
  OSType *identifier = (OSType *)bytes;
  [self setCode:SKStringForOSType(*identifier)];
  bytes += 4;
  
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (long)bytes % 2;
  
  /* Properties */
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      SdefProperty *prop = [[SdefProperty allocWithZone:[self zone]] init];
      bytes += [prop parseData:bytes];
      [[self properties] appendChild:prop];
      [prop release];
    }
  }
  
  val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      SdefElement *elt = [[SdefElement allocWithZone:[self zone]] init];
      bytes += [elt parseData:bytes];
      [[self elements] appendChild:elt];
      [elt release];
    }
  }
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end

#pragma mark -
@implementation SdefProperty (AeteResource)

- (UInt32)parseData:(Byte *)data {
  unsigned length;
  BytePtr bytes = data;
  
  StringPtr pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  CFStringRef str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setName:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (long)bytes % 2;
  
  /* Identifier */
  OSType *identifier = (OSType *)bytes;
  [self setCode:SKStringForOSType(*identifier)];
  bytes += 4;
  
  /* Type */
  identifier = (UInt32 *)bytes;
  [self setType:SKStringForOSType(*identifier)];
  bytes += 4;
  
  /* Description */
  pStr = (StringPtr)bytes;
  length = StrLength(pStr);
  str = (length) ? CFStringCreateWithPascalString(kCFAllocatorDefault, pStr, kCFStringEncodingMacRoman) : nil;
  [self setDesc:(id)str];
  bytes += length + 1;
  if (str) CFRelease(str);
  
  /* Alignement */
  bytes += (long)bytes % 2;
  
  /* Result flags */
  UInt16 *val = (UInt16 *)bytes;
  if ((1 << kAEUTlistOfItems) & *val) {
    [self setType:[@"list of " stringByAppendingString:[self type]]];
  }
  if ((1 << kAEUTPlural) & *val) {
    [self setName:@"<Plural>"];
  }
  unsigned access = kSdefAccessRead;
  if ((1 << kAEUTReadWrite) & *val) {
    access |= kSdefAccessWrite;
  }
  [self setAccess:access];
  bytes += 2;
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end

#pragma mark -
@implementation SdefElement (AeteResource)

- (UInt32)parseData:(Byte *)data {
  BytePtr bytes = data;
  
  /* Type */
  OSType *identifier = (OSType *)bytes;
  [self setType:SKStringForOSType(*identifier)];
  bytes += 4;
  
  /* Accessors */
  UInt16 *val = (UInt16 *)bytes;
  bytes += 2;
  if (*val > 0) {
    unsigned idx = 0;
    for (idx=0; idx<*val; idx++) {
      identifier = (OSType *)bytes;
      switch (*identifier) {
        case formAbsolutePosition:
          [self setAccIndex:YES];
          break;
        case formRelativePosition:
          [self setAccRelative:YES];
          break;
        case formTest:
          [self setAccTest:YES];
          break;
        case formRange:
          [self setAccRange:YES];
          break;
        case formUniqueID:
        case formPropertyID:
          [self setAccId:YES];
          break;
        case formName:
          [self setAccName:YES];
          break;
      }
      bytes += 4;
    }
  }
  
  long total = (long)bytes;
  total -= (long)data;
  return total;
}

@end

