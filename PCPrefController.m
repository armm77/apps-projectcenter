/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2001 Free Software Foundation

   Authors: Philippe C.D. Robert <probert@siggraph.org>
            Serg Stoyan <stoyan@on.com.ua>

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

#include "PCPrefController.h"
#include <ProjectCenter/ProjectCenter.h>

#include "PCLogController.h"

NSString *SavePeriodDidChangeNotification = @"SavePeriodDidChangeNotification";

@implementation PCPrefController

// ===========================================================================
// ==== Class methods
// ===========================================================================

static PCPrefController *_prefCtrllr = nil;
  
+ (PCPrefController *)sharedPCPreferences
{
  if (!_prefCtrllr)
    {
      _prefCtrllr = [[PCPrefController alloc] init];
    }
  
  return _prefCtrllr;
}

//
- (id)init
{
  NSDictionary *prefs = nil;

  if (!(self = [super init]))
    {
      return nil;
    }
    
  // The prefs from the defaults
  prefs = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
  preferencesDict = [[NSMutableDictionary alloc] initWithDictionary:prefs];

  return self;
}

- (void)dealloc
{
  NSLog(@"PCPrefController: dealloc");
  
  RELEASE(preferencesDict);
  
  RELEASE(panel);

  RELEASE(buildingView);
  RELEASE(savingView);
  RELEASE(keyBindingsView);
  RELEASE(miscView);

  [[NSUserDefaults standardUserDefaults] synchronize];

  [super dealloc];
}

- (void)loadPrefernces
{
  NSDictionary *prefs = nil;
  NSString     *val = nil;

  prefs = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
  [preferencesDict addEntriesFromDictionary: prefs];
  
  // Fill in the defaults

  // Building
  [successField setStringValue: 
    (val = [preferencesDict objectForKey: SuccessSound]) ? val : @""];

  [failureField setStringValue: 
    (val = [preferencesDict objectForKey: FailureSound]) ? val : @""];

  [promptOnClean setState:
    ([[preferencesDict objectForKey: PromptOnClean] 
     isEqualToString: @"YES"]) ? NSOnState : NSOffState];

  [rootBuildDirField setStringValue: 
    (val = [preferencesDict objectForKey:RootBuildDirectory]) ? val : @""];

  // Saving
  [saveOnQuit setState:
    ([[preferencesDict objectForKey: SaveOnQuit] 
     isEqualToString: @"YES"]) ? NSOnState : NSOffState];
     
  [keepBackup setState:
    ([[preferencesDict objectForKey: KeepBackup] 
     isEqualToString: @"YES"]) ? NSOnState : NSOffState];

  [autosaveField setStringValue:
    (val = [preferencesDict objectForKey: AutoSavePeriod]) ? val : @"120"];
  [autosaveSlider setFloatValue:[[autosaveField stringValue] floatValue]];

  // Key Bindings
  val = [preferencesDict objectForKey:TabBehaviour];
  [tabMatrix deselectAllCells];
  if ([val isEqualToString:@"Tab"])
    {
      [tabMatrix selectCellAtRow:0 column:0];
    }
  else if ([val isEqualToString:@"IndentAlways"])
    {
      [tabMatrix selectCellAtRow:1 column:0];
    }
  else if ([val isEqualToString:@"IndentAtBeginning"])
    {
      [tabMatrix selectCellAtRow:2 column:0];
    }
  else if ([val isEqualToString:@"Spaces"])
    {
      [tabMatrix selectCellAtRow:3 column:0];
    }

  // Miscellaneous
  [promptWhenQuit setState:
    ([[preferencesDict objectForKey: PromptOnQuit] 
     isEqualToString:@"YES"]) ? NSOnState : NSOffState];
  [deleteCache setState:
    ([[preferencesDict objectForKey: DeleteCacheWhenQuitting] 
     isEqualToString:@"YES"]) ? NSOnState : NSOffState];
  [fullPathInFilePanels setState:
    ([[preferencesDict objectForKey: FullPathInFilePanels] 
     isEqualToString:@"YES"]) ? NSOnState : NSOffState];

  [debuggerField setStringValue:
    (val = [preferencesDict objectForKey: Debugger]) ? val : @"/usr/bin/gdb"];
  [editorField setStringValue:
    (val = [preferencesDict objectForKey: Editor]) ? val : @"ProjectCenter"];
 
  // Interface
  [separateBuilder setState:
    ([[preferencesDict objectForKey: SeparateBuilder] 
     isEqualToString:@"YES"]) ? NSOnState : NSOffState];
  [separateLauncher setState:
    ([[preferencesDict objectForKey: SeparateLauncher] 
     isEqualToString:@"YES"]) ? NSOnState : NSOffState];
  [separateEditor setState:
    ([[preferencesDict objectForKey: SeparateEditor] 
     isEqualToString:@"YES"]) ? NSOnState : NSOffState];
  [separateLoadedFiles setState:
    ([[preferencesDict objectForKey: SeparateLoadedFiles] 
     isEqualToString:@"YES"]) ? NSOnState : NSOffState];
     
  [editorLinesField setStringValue:
    (val = [preferencesDict objectForKey: EditorLines]) ? val : @"30"];
  [editorColumnsField setStringValue:
    (val = [preferencesDict objectForKey: EditorColumns]) ? val : @"80"];
  if ([separateEditor state] == NSOffState)
    {
      [editorLinesField setEditable:NO];
      [editorColumnsField setEditable:NO];
    }
     
  [rememberWindows setState:
    ([[preferencesDict objectForKey: RememberWindows] 
     isEqualToString:@"YES"]) ? NSOnState : NSOffState];
  [displayLog setState:
    ([[preferencesDict objectForKey:DisplayLog] 
     isEqualToString:@"YES"]) ? NSOnState : NSOffState];

  // Bundles
/*  [bundlePathField setStringValue:
    (val = [preferencesDict objectForKey: BundlePaths]) ? val : @""];*/
}

- (void)awakeFromNib
{
  NSArray *tabMatrixCells = nil;
  int     i;
  
  [promptOnClean setRefusesFirstResponder:YES];
  
  [saveOnQuit setRefusesFirstResponder:YES];
  [keepBackup setRefusesFirstResponder:YES];

  tabMatrixCells = [tabMatrix cells];

  for (i = 0; i < [tabMatrixCells count]; i++)
    {
      [[tabMatrixCells objectAtIndex:i] setRefusesFirstResponder:YES];
    }

  [promptWhenQuit setRefusesFirstResponder:YES];
  [deleteCache setRefusesFirstResponder:YES];
  [fullPathInFilePanels setRefusesFirstResponder:YES];

  [separateBuilder setRefusesFirstResponder:YES];
  [separateLauncher setRefusesFirstResponder:YES];
  [separateEditor setRefusesFirstResponder:YES];
  [separateLoadedFiles setRefusesFirstResponder:YES];

  [rememberWindows setRefusesFirstResponder:YES];
  [displayLog setRefusesFirstResponder:YES];
}

// Accessory
- (NSDictionary *)preferencesDict
{
  return preferencesDict;
}

- (id)objectForKey:(NSString *)key
{
  return [preferencesDict objectForKey:key];
}

- (NSString *)selectFileWithTypes:(NSArray *)types
{
  NSUserDefaults   *def = [NSUserDefaults standardUserDefaults];
  NSString 	   *file = nil;
  NSOpenPanel	   *openPanel;
  int		    retval;

  openPanel = [NSOpenPanel openPanel];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:YES];

  retval = [openPanel 
    runModalForDirectory:[def objectForKey:@"LastOpenDirectory"]
                    file:nil
		   types:types];

  if (retval == NSOKButton) 
    {
      [def setObject:[openPanel directory] forKey:@"LastOpenDirectory"];
      file = [[openPanel filenames] objectAtIndex:0];

    }

  return file;
}

- (void)showPanel:(id)sender
{
  if (panel == nil 
      && [NSBundle loadNibNamed:@"Preferences" owner:self] == NO)
    {
      PCLogError(self, @"error loading NIB file!");
      return;
    }

  [panel setFrameAutosaveName:@"Preferences"];
  if (![panel setFrameUsingName: @"Preferences"])
    {
      [panel center];
    }
  RETAIN(buildingView);
  RETAIN(savingView);
  RETAIN(keyBindingsView);
  RETAIN(miscView);
  RETAIN(interfaceView);

  // The popup and selected view
  [popupButton removeAllItems];
  [popupButton addItemWithTitle:@"Building"];
  [popupButton addItemWithTitle:@"Saving"];
  [popupButton addItemWithTitle:@"Key Bindings"];
  [popupButton addItemWithTitle:@"Miscellaneous"];
  [popupButton addItemWithTitle:@"Interface"];

  [popupButton selectItemWithTitle:@"Building"];
  [self popupChanged:popupButton];

  // Load saved prefs
  [self loadPrefernces];

  [panel orderFront:self];
}

//
- (void)popupChanged:(id)sender
{
  NSView *view = nil;

  switch ([sender indexOfSelectedItem]) 
    {
    case 0:
      view = buildingView;
      break;
    case 1:
      view = savingView;
      break;
    case 2:
      view = keyBindingsView;
      break;
    case 3:
      view = miscView;
      break;
    case 4:
      view = interfaceView;
      break;
    }

  [sectionsView setContentView:view];
  [sectionsView display];
}

// Building
- (void)setSuccessSound:(id)sender
{
  NSArray *types = [NSArray arrayWithObjects:@"snd",@"au",@"wav",nil];
  NSString *path = [self selectFileWithTypes:types];

  if (path)
    {
      [successField setStringValue: path];

      [[NSUserDefaults standardUserDefaults] setObject:path
	                                        forKey:SuccessSound];
      [preferencesDict setObject:path forKey:SuccessSound];
    }
}

- (void)setFailureSound:(id)sender
{
  NSArray  *types = [NSArray arrayWithObjects:@"snd",@"au",@"wav",nil];
  NSString *path = [self selectFileWithTypes:types];

  if (path)
    {
      [failureField setStringValue:path];

      [[NSUserDefaults standardUserDefaults] setObject:path
	                                        forKey:FailureSound];
      [preferencesDict setObject:path forKey:FailureSound];
    }
}

- (void)setRootBuildDir:(id)sender
{
  NSArray  *types = nil;
  NSString *path = [self selectFileWithTypes:types];

  if (path)
    {
      [rootBuildDirField setStringValue:path];
      [[NSUserDefaults standardUserDefaults] setObject:path
	                                        forKey:RootBuildDirectory];
      [preferencesDict setObject:path forKey:RootBuildDirectory];
    }
}

- (void)setPromptOnClean:(id)sender
{
  NSUserDefaults *def = nil;

  if (promptOnClean == nil)
    {// HACK!!! need to be fixed in GNUstep
      promptOnClean = sender;
      return;
    }

  def = [NSUserDefaults standardUserDefaults];
  switch ([sender state])
    {
    case NSOffState:
      [def setObject:@"NO" forKey:PromptOnClean];
      break;
    case NSOnState:
      [def setObject:@"YES" forKey:PromptOnClean];
      break;
    }
  [def synchronize];

  [preferencesDict setObject:[def objectForKey:PromptOnClean] 
                      forKey:PromptOnClean];
}

// Saving
- (void)setSaveOnQuit:(id)sender
{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

  if (saveOnQuit == nil)
    { // HACK!!!
      saveOnQuit = sender;
      return;
    }

  switch ([sender state])
    {
    case 0:
      [def setObject:@"NO" forKey:SaveOnQuit];
      break;
    case 1:
      [def setObject:@"YES" forKey:SaveOnQuit];
      break;
    }
  [def synchronize];

  [preferencesDict setObject:[def objectForKey:SaveOnQuit] 
                      forKey:SaveOnQuit];
}

- (void)setKeepBackup:(id)sender
{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

  if (keepBackup == nil)
    { // HACK!!!
      keepBackup = sender;
      return;
    }
    
  switch ([[sender selectedCell] state])
    {
    case 0:
      [def setObject:@"NO" forKey:KeepBackup];
      break;
    case 1:
      [def setObject:@"YES" forKey:KeepBackup];
      break;
    }
  [def synchronize];

  [preferencesDict setObject:[def objectForKey:KeepBackup] 
                      forKey:KeepBackup];
}

- (void)setSavePeriod:(id)sender
{
  NSString *periodString = nil;
  
  if (sender == autosaveSlider)
    {
      [autosaveField setIntValue:[sender intValue]];
    }
  else if (sender == autosaveField)
    {
      if ([autosaveField floatValue] < [autosaveSlider minValue])
	{
	  [autosaveField setFloatValue:[autosaveSlider minValue]];
	}
      else if ([autosaveField floatValue] > [autosaveSlider maxValue])
	{
	  [autosaveField setFloatValue:[autosaveSlider maxValue]];
	}
      [autosaveSlider setFloatValue:[autosaveField floatValue]];
    }

  periodString = [autosaveField stringValue];

  [[NSUserDefaults standardUserDefaults] setObject:periodString 
                                            forKey:AutoSavePeriod];
  [preferencesDict setObject:periodString forKey:AutoSavePeriod];

  [[NSNotificationCenter defaultCenter] 
    postNotificationName:SavePeriodDidChangeNotification
                  object:periodString];
}

// Key bindings
- (void)setTabBehaviour:(id)sender
{
  id       cell = [sender selectedCell];
  NSString *tabBehaviour = nil;

  PCLogInfo(self, @"setTabBehaviour: %@", [cell title]);

  if ([[cell title] isEqualToString:@"Insert Tab"])
    {
      tabBehaviour = [NSString stringWithString:@"Tab"];
    }
  else if ([[cell title] isEqualToString:@"Indent only at beginning of line"])
    {
      tabBehaviour = [NSString stringWithString:@"IndentAtBeginning"];
    }
  else if ([[cell title] isEqualToString:@"Indent always"])
    {
      tabBehaviour = [NSString stringWithString:@"IndentAlways"];
    }
  else if ([[cell title] isEqualToString:@"Insert spaces"])
    {
      tabBehaviour = [NSString stringWithString:@"Spaces"];
      [tabSpacesField setEnabled:YES];
      [tabSpacesField becomeFirstResponder];
    }
    
  [[NSUserDefaults standardUserDefaults] setObject:tabBehaviour
                                            forKey:TabBehaviour];
  [preferencesDict setObject:tabBehaviour forKey:TabBehaviour];
}

- (void)setTabSpaces:(id)sender
{
  if ([[tabSpacesField stringValue] isEqualToString:@""])
    {
      [tabSpacesField setStringValue:@"2"];
    }
    
  [[NSUserDefaults standardUserDefaults] 
      setObject:[tabSpacesField stringValue]
         forKey:TabSpaces];
  [preferencesDict setObject:[tabSpacesField stringValue] forKey:TabSpaces];
}

// Miscellaneous
- (void)setPromptWhenQuit:(id)sender
{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

  if (promptWhenQuit == nil)
    {
      promptWhenQuit = sender;
      return;
    }

  switch ([sender state])
    {
    case 0:
      [def setObject:@"NO" forKey:PromptOnQuit];
      break;
    case 1:
      [def setObject:@"YES" forKey:PromptOnQuit];
      break;
    }
  [def synchronize];

  [preferencesDict setObject:[def objectForKey:PromptOnQuit] 
                      forKey:PromptOnQuit];
}

- (void)setDeleteCache:(id)sender
{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

  if (deleteCache == nil)
    {
      deleteCache = sender;
      return;
    }

  switch ([sender state])
    {
    case 0:
      [def setObject:@"NO" forKey:DeleteCacheWhenQuitting];
      break;
    case 1:
      [def setObject:@"YES" forKey:DeleteCacheWhenQuitting];
      break;
    }
  [def synchronize];

  [preferencesDict setObject:[def objectForKey:DeleteCacheWhenQuitting] 
                      forKey:DeleteCacheWhenQuitting];
}

- (void)setFullPathInFilePanels:(id)sender
{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

  if (fullPathInFilePanels == nil)
    {
      fullPathInFilePanels = sender;
      return;
    }

  switch ([sender state])
    {
    case 0:
      [def setObject:@"NO" forKey:FullPathInFilePanels];
      break;
    case 1:
      [def setObject:@"YES" forKey:FullPathInFilePanels];
      break;
    }
  [def synchronize];

  [preferencesDict setObject:[def objectForKey:FullPathInFilePanels] 
                      forKey:FullPathInFilePanels];
}

- (void)setDebugger:(id)sender
{
  NSString *path = [debuggerField stringValue];
  
  if (path)
    {
      [[NSUserDefaults standardUserDefaults] setObject:path forKey:Debugger];
      [preferencesDict setObject:path forKey:Debugger];
    }
}

- (void)setEditor:(id)sender
{
  NSString *path = [editorField stringValue];
  
  if (path)
    {
      [[NSUserDefaults standardUserDefaults] setObject:path forKey:Editor];
      [preferencesDict setObject:path forKey:Editor];
    }
}

// Interface
- (void)setDisplayPanels:(id)sender
{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  NSString       *key = nil;

  if (sender == separateBuilder)
    {
      key = [NSString stringWithString: SeparateBuilder];
    }
  else if (sender == separateLauncher)
    {
      key = [NSString stringWithString: SeparateLauncher];
    }
  else if (sender == separateEditor)
    {
      key = [NSString stringWithString: SeparateEditor];
    }
  else if (sender == separateLoadedFiles)
    {
      key = [NSString stringWithString: SeparateLoadedFiles];
    }

  switch ([sender state])
    {
    case NSOffState:
      [def setObject: @"NO" forKey: key];
      break;
    case NSOnState:
      [def setObject:@"YES" forKey: key];
      break;
    }
  [def synchronize];

  if (sender == separateEditor)
    {
      if ([sender state] == NSOffState)
	{
	  [editorLinesField setEditable:NO];
	  [editorColumnsField setEditable:NO];
	}
      else
	{
	  [editorLinesField setEditable:YES];
	  [editorColumnsField setEditable:YES];
	}
      [sender becomeFirstResponder];
    }

  [preferencesDict setObject:[def objectForKey:key] 
                      forKey:key];
}

- (void)setEditorSize:(id)sender
{
  NSString *val = nil;
  NSString *key = nil;
  
  if (sender == editorLinesField)
    {
      key = EditorLines;
      val = [editorLinesField stringValue];
    }
  else if (sender == editorColumnsField)
    {
      key = EditorColumns;
      val = [editorColumnsField stringValue];
    }
  [[NSUserDefaults standardUserDefaults] setObject:val forKey:key];
  [preferencesDict setObject:val forKey:key];
}

- (void)setRememberWindows:(id)sender
{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

  if (rememberWindows == nil)
    {
      rememberWindows = sender;
      return;
    }

  switch ([sender state])
    {
    case 0:
      [def setObject:@"NO" forKey:RememberWindows];
      break;
    case 1:
      [def setObject:@"YES" forKey:RememberWindows];
      break;
    }
  [def synchronize];

  [preferencesDict setObject:[def objectForKey:RememberWindows] 
                      forKey:RememberWindows];
}

- (void)setDisplayLog:(id)sender
{
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

  if (displayLog == nil)
    {
      displayLog = sender;
      return;
    }

  switch ([sender state])
    {
    case 0:
      [def setObject:@"NO" forKey:DisplayLog];
      break;
    case 1:
      [def setObject:@"YES" forKey:DisplayLog];
      break;
    }
  [def synchronize];

  [preferencesDict setObject:[def objectForKey:DisplayLog] 
                      forKey:DisplayLog];
}

// Bundles
- (void)setBundlePath:(id)sender
{
  NSString *path = [bundlePathField stringValue];

  if (path)
    {
      [[NSUserDefaults standardUserDefaults] setObject:path forKey:BundlePaths];
      [preferencesDict setObject:path forKey:BundlePaths];
    }
}

@end

