//
//  SdefSymbolBrowser.h
//  Sdef Editor
//
//  Created by Grayfox on 22/03/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  kSdefSearchAll,
  kSdefSearchCode,
  kSdefSearchSuite,
  kSdefSearchSymbol,
  kSdefSearchSymbolType
} SdefSearchField;

@class SdefSuite;
@class SKTableDataSource;
@interface SdefSymbolBrowser : NSWindowController {
  SdefSearchField sd_filter;
  NSSearchField *searchField;
  IBOutlet id symbolTable;
  IBOutlet NSDrawer *editDrawer;
  IBOutlet SKTableDataSource *symbols;
}

- (void)createToolbar;

- (void)loadSymbols;
- (void)addSuite:(SdefSuite *)aSuite;
- (void)removeSuite:(SdefSuite *)aSuite;

@end
