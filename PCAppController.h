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

#ifndef _PCAPPCONTROLLER_H
#define _PCAPPCONTROLLER_H

#include <AppKit/AppKit.h>

#include "PCInfoController.h"
#include "PCPrefController.h"
#include "PCLogController.h"

@class PCServer;
@class PCProjectManager;
@class PCFileManager;
@class PCMenuController;

@interface PCAppController : NSObject
{
  id		   delegate;

  PCProjectManager *projectManager;
  IBOutlet id      menuController;
  
  PCInfoController *infoController;
  PCPrefController *prefController;
  PCLogController  *logController;

  PCServer         *doServer;
  NSConnection     *doConnection;
}

//============================================================================
//==== Intialization & deallocation
//============================================================================

+ (void)initialize;

- (id)init;
- (void)dealloc;

//============================================================================
//==== Delegate
//============================================================================

- (id)delegate;
- (void)setDelegate:(id)aDelegate;

//============================================================================
//==== Accessory methods
//============================================================================

- (PCProjectManager *)projectManager;
- (PCMenuController *)menuController;
- (PCInfoController *)infoController;
- (PCPrefController *)prefController;
- (PCLogController *)logController;
- (PCServer *)doServer;

//============================================================================
//==== Application
//============================================================================

- (BOOL)application:(NSApplication *)application openFile:(NSString *)fileName;

- (void)applicationWillFinishLaunching:(NSNotification *)notification;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

- (BOOL)applicationShouldTerminate:(id)sender;
- (void)applicationWillTerminate:(NSNotification *)notification;

@end

#endif
