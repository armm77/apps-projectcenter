/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2000-2004 Free Software Foundation

   Authors: Philippe C.D. Robert
            Serg Stoyan

   This file is part of GNUstep.

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#include "PCDefines.h"
#include "PCProject.h"
#include "PCProjectEditor.h"
#include "PCEditor.h"

#include "PCPrefController.h"
#include "PCLogController.h"

#include "PCProjectLoadedFiles.h"

@implementation PCProjectLoadedFiles

- (id)initWithProject:(PCProject *)aProj 
{
  NSAssert(aProj, @"Project is mandatory!");

  PCLogStatus(self, @"init");
  
  if ((self = [super init]))
    {
      project = aProj;
      editedFiles = [[NSMutableArray alloc] init];

      // Column
      filesColumn = [(NSTableColumn *)[NSTableColumn alloc] 
	initWithIdentifier:@"Files List"];
      [filesColumn setEditable:NO];

      // Table
      filesList = [[NSTableView alloc] 
	initWithFrame:NSMakeRect(0,0,160,128)];
      [filesList setAllowsMultipleSelection:NO];
      [filesList setAllowsColumnReordering:NO];
      [filesList setAllowsColumnResizing:NO];
      [filesList setAllowsEmptySelection:YES];
      [filesList setAllowsColumnSelection:NO];
      [filesList setCornerView:nil];
      [filesList setHeaderView:nil];
      [filesList addTableColumn:filesColumn];
      [filesList setDataSource:self];
/*      [filesList setBackgroundColor: [NSColor colorWithDeviceRed:0.88
                                                           green:0.76 
                                                            blue:0.60 
                                                           alpha:1.0]];*/
      // Hack! Should be [filesList setDrawsGrid:NO]
      [filesList setGridColor: [NSColor lightGrayColor]];
      [filesList setTarget:self];
      [filesList setDoubleAction:@selector(doubleClick:)];
      [filesList setAction:@selector(click:)];

      // Scrollview
      filesScroll = [[NSScrollView alloc] initWithFrame:
	NSMakeRect (0, 0, 80, 128)];
      [filesScroll setDocumentView:filesList];
      [filesScroll setHasHorizontalScroller:NO];
      [filesScroll setHasVerticalScroller:YES];
      if ([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]
  	  objectForKey: SeparateLoadedFiles] isEqualToString: @"NO"])
	{
	  [filesScroll setBorderType:NSBezelBorder];
	}

      sortType = PHSortByTime;

      [filesList reloadData];

      [[NSNotificationCenter defaultCenter]
	addObserver:self 
	   selector:@selector(fileDidOpen:)
	       name:PCEditorDidOpenNotification
	     object:nil];

      [[NSNotificationCenter defaultCenter]
	addObserver:self 
	   selector:@selector(fileDidClose:)
	       name:PCEditorDidCloseNotification
	     object:nil];
	     
      [[NSNotificationCenter defaultCenter]
	addObserver:self 
	   selector:@selector(editorDidBecomeActive:)
	       name:PCEditorDidBecomeActiveNotification
	     object:nil];
	     
      [[NSNotificationCenter defaultCenter]
	addObserver:self 
	   selector:@selector(editorDidChangeFileName:)
	       name:PCEditorDidChangeFileNameNotification
	     object:nil];
    }

  return self;
}

- (void)dealloc
{
#ifdef DEVELOPMENT
  NSLog (@"PCProjectLoadedFiles: dealloc");
#endif

  [[NSNotificationCenter defaultCenter] removeObserver:self];

  RELEASE(filesColumn);
  RELEASE(filesList);
  RELEASE(filesScroll);
  RELEASE(editedFiles);

  [super dealloc];
}

- (NSView *)componentView
{
  return filesScroll;
}

- (NSArray *)editedFilesRep
{
  if (sortType == PHSortByName)
    {
      NSArray *sortedArray = nil;

      sortedArray = [editedFiles 
	sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

      return sortedArray;
    }

  return editedFiles;
}

- (void)setSortType:(PHSortType)type
{
  int      row;
  NSString *filePath = nil;
  
  if ([editedFiles count] > 0)
    {
      row = [filesList selectedRow];
      filePath = [[self editedFilesRep] objectAtIndex:row];
    }

  sortType = type;
  [filesList reloadData];

  
  if ([editedFiles count] > 0)
    {
      row = [[self editedFilesRep] indexOfObject:filePath];
      [filesList selectRow:row byExtendingSelection:NO];
    }
}

- (void)setSortByTime
{
  [self setSortType:PHSortByTime];
}

- (void)setSortByName
{
  [self setSortType:PHSortByName];
}

- (void)selectNextFile
{
  int row = [filesList selectedRow];

  if (row == ([filesList numberOfRows]-1))
    {
      [filesList selectRow:0 byExtendingSelection:NO];
    }
  else
    {
      [filesList selectRow:row+1 byExtendingSelection:NO];
    }
  [self click:self];
}

- (void)selectPreviousFile
{
  int row = [filesList selectedRow];

  if (row == 0)
    {
      [filesList selectRow:[filesList numberOfRows]-1 byExtendingSelection:NO];
    }
  else
    {
      [filesList selectRow:row-1 byExtendingSelection:NO];
    }
  [self click:self];
}

- (void)click:(id)sender
{
  int       row = [filesList selectedRow];
  NSString  *path = [[self editedFilesRep] objectAtIndex:row];

  [[project projectEditor] orderFrontEditorForFile:path];
}

- (void)doubleClick:(id)sender
{
  // TODO: Open separate editor window for file
  PCLogInfo(self, @"ProjectLoadedFiles doubleClick received");
}

// ===========================================================================
// ==== Notifications
// ===========================================================================

- (void)fileDidOpen:(NSNotification *)aNotif
{
  PCEditor *editor = [aNotif object];
  NSString *filePath = nil;
  int      row;

  if ([editor projectEditor] != [project projectEditor])
    {
      PCLogWarning(self, @"File opened from other project");
      return;
    }

  PCLogInfo(self, @"File did open in project %@", [project projectName]);

  filePath = [editor path];
  
  if ([editedFiles containsObject:filePath] == YES)
    {
      [editedFiles removeObject:filePath];
    }

  [editedFiles insertObject:filePath atIndex:0];
  [filesList reloadData];
 
  row = [[self editedFilesRep] indexOfObject:filePath];
  [filesList selectRow:row byExtendingSelection:NO];
  
  PCLogInfo(self, @"fileDidOpen.END");
}

- (void)fileDidClose:(NSNotification *)aNotif
{
  PCEditor *editor = [aNotif object];
  NSString *filePath = [editor path];

  if ([editor projectEditor] != [project projectEditor])
    {
      PCLogWarning(self, @"File from other project closed");
      return;
    }

  if ([editedFiles containsObject:filePath] == YES)
    {
      [editedFiles removeObject:filePath];
      [filesList reloadData];

      if ([editedFiles count] > 0)
	{
	  unsigned row;

	  filePath = [editedFiles objectAtIndex:0];
	  row = [[self editedFilesRep] indexOfObject:filePath];
	  [filesList selectRow:row byExtendingSelection:NO];
	}
    }
}

- (void)editorDidBecomeActive:(NSNotification *)aNotif
{
  PCEditor *editor = [aNotif object];
  NSString *filePath = nil;
  unsigned index;
  unsigned filesCount;
  
  if ([editor projectEditor] != [project projectEditor])
    {
      return;
    }

  if ((filesCount = [editedFiles count]) > 0)
    {
      filePath = [editor path];
      index = [[self editedFilesRep] indexOfObject:filePath];
      if (index >=0 && index < filesCount)
	{
	  [filesList selectRow:index byExtendingSelection:NO];
	}
    }
}

- (void)editorDidChangeFileName:(NSNotification *)aNotif
{
  NSDictionary *_editorDict = [aNotif object];
  PCEditor     *_editor = [_editorDict objectForKey:@"Editor"];
  NSString     *_oldFileName = nil;
  NSString     *_newFileName = nil;
  unsigned     index;

  if ([_editor projectEditor] != [project projectEditor])
    {
      return;
    }
    
  _oldFileName = [_editorDict objectForKey:@"OldFile"];
  _newFileName = [_editorDict objectForKey:@"NewFile"];
  if ([editedFiles count] > 0)
    {
      index = [editedFiles indexOfObject:_oldFileName];
      [editedFiles replaceObjectAtIndex:index withObject:_newFileName];
      [filesList reloadData];
      [filesList selectRow:index byExtendingSelection:NO];
    }
}

@end

@implementation PCProjectLoadedFiles (LoadedFilesTableDelegate)

- (int)numberOfRowsInTableView: (NSTableView *)aTableView
{
  if (aTableView != filesList)
    {
      return 0;
    }
  
  return [editedFiles count];
}

- (id)            tableView: (NSTableView *)aTableView
  objectValueForTableColumn: (NSTableColumn *)aTableColumn
                        row: (int)rowIndex
{
  if (aTableView != filesList)
    {
      return nil;
    }

  if (sortType == PHSortByName)
    {
      NSArray *sortedArray = nil;

      sortedArray = [editedFiles
	sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

      return [[sortedArray objectAtIndex:rowIndex] lastPathComponent];
    }

  return [[editedFiles objectAtIndex:rowIndex] lastPathComponent];
}

- (void) tableView:(NSTableView *)aTableView
    setObjectValue:anObject
    forTableColumn:(NSTableColumn *)aTableColumn
               row:(int)rowIndex
{
/*  NSString *path = nil;
  NSParameterAssert (rowIndex >= 0 && rowIndex < [editedFiles count]);

  [editedFiles removeObjectAtIndex:rowIndex];
  [editedFiles insertObject:anObject atIndex:rowIndex];

  path = 
  [filesPath removeObjectAtIndex:rowIndex];
  [filesPath insertObject:[editor path] atIndex:rowIndex];*/
}

@end

