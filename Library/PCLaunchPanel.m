/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2003-2004 Free Software Foundation

   Authors: Serg Stoyan

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

#include "PCProjectManager.h"
#include "PCProject.h"
#include "PCProjectLauncher.h"
#include "PCLaunchPanel.h"

#include "PCLogController.h"

@implementation PCLaunchPanel

- (id)initWithProjectManager:(PCProjectManager *)aManager
{
  PCProjectLauncher *projectLauncher = nil;
  PCProject         *activeProject = nil;
  
  projectManager = aManager;
  activeProject = [projectManager rootActiveProject];
  projectLauncher = [activeProject projectLauncher];

  projectLauncher = [[aManager activeProject] projectLauncher];

  self = [super initWithContentRect: NSMakeRect (0, 300, 480, 322)
                         styleMask: (NSTitledWindowMask 
		                    | NSClosableWindowMask
				    | NSResizableWindowMask)
			   backing: NSBackingStoreRetained
			     defer: YES];
  [self setMinSize: NSMakeSize(440, 222)];
  [self setFrameAutosaveName: @"ProjectLauncher"];
  [self setReleasedWhenClosed: NO];
  [self setHidesOnDeactivate: NO];
  [self setTitle: [NSString stringWithFormat: 
    @"%@ - Launch", [activeProject projectName]]];

  contentBox = [[NSBox alloc] init];
  [contentBox setContentViewMargins:NSMakeSize(8.0, 0.0)];
  [contentBox setTitlePosition:NSNoTitle];
  [contentBox setBorderType:NSNoBorder];
  [super setContentView:contentBox];
  
  // Empty content view of contentBox
  emptyBox = [[NSBox alloc] init];
  [emptyBox setContentViewMargins:NSMakeSize(0.0, 0.0)];
  [emptyBox setTitlePosition:NSNoTitle];
  [emptyBox setBorderType:NSLineBorder];
  [contentBox setContentView:emptyBox];

  // Track project switching
  [[NSNotificationCenter defaultCenter] 
    addObserver:self
       selector:@selector(activeProjectDidChange:)
           name:PCActiveProjectDidChangeNotification
         object:nil];

  if (![self setFrameUsingName: @"ProjectLauncher"])
    {
      [self center];
    }

  return self;
}

- (void)dealloc
{
#ifdef DEVELOPMENT
  NSLog (@"PCLaunchPanel: dealloc");
#endif
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [super dealloc];
}

- (void)orderFront:(id)sender
{
  PCProject *activeProject = [projectManager rootActiveProject];
  NSView    *launcherView = [[activeProject projectLauncher] componentView];

  if (!([contentBox contentView] == launcherView))
    {
      [contentBox setContentView:launcherView];
      [contentBox display];
    }

  PCLogInfo(self, @"orderFront: %@ -> %@", 
	    launcherView, [launcherView superview]);

  [super orderFront:self];
}

- (void)close
{
  PCLogInfo(self, @"close: %@", [contentBox contentView]);

  [contentBox setContentView:emptyBox];
  
  PCLogInfo(self, @"close: %@", [contentBox contentView]);

  [super close];
}

- (void)activeProjectDidChange:(NSNotification *)aNotif
{
  PCProject *rootProject = [projectManager rootActiveProject];

  if (rootProject == currentProject)
    {
      return;
    }

  currentProject = rootProject;

  if (!rootProject)
    {
      [contentBox setContentView:emptyBox];
    }
  else
    {
      [self setTitle: [NSString stringWithFormat:
	@"%@ - Launch", [rootProject projectName]]];

      [contentBox 
	setContentView:[[rootProject projectLauncher] componentView]];
    }
}

@end

