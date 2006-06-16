/*
 *  SdefSuiteView.h
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefViewController.h"

@interface SdefSuiteView : SdefViewController {
  IBOutlet NSTabView *tab;
  IBOutlet id typeTable;
  IBOutlet id classTable;
  IBOutlet id commandTable;
  IBOutlet id eventTable;
  IBOutlet NSArrayController *types;
@private
  int sd_idx;
  NSMenu *sd_typeMenu;
}

@end
