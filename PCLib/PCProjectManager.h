/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2000-2002 Free Software Foundation

   Author: Philippe C.D. Robert <probert@siggraph.org>

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

   $Id$
*/

#ifndef _PCProjectManager_h_
#define _PCProjectManager_h_

#include <AppKit/AppKit.h>

@class PCProject;
@class PCProjectInspector;
@class PCProjectBuilder;
@class PCProjectLauncher;
@class PCProjectHistory;
@class PCProjectFinder;

#ifndef GNUSTEP_BASE_VERSION
@protocol ProjectBuilder;
@protocol ProjectDelegate;
#else
#include <ProjectCenter/ProjectBuilder.h>
#include <ProjectCenter/ProjectDelegate.h>
#endif

extern NSString *ActiveProjectDidChangeNotification;

@interface PCProjectManager : NSObject <ProjectBuilder>
{
  id                  delegate;

  PCProjectInspector  *projectInspector;
  
  NSPanel             *buildPanel;
  NSPanel             *launchPanel;
  NSPanel             *historyPanel;
  NSPanel             *findPanel;
  
  NSMutableDictionary *loadedProjects;
  PCProject           *activeProject;
  
  NSString            *rootBuildPath;

  NSTimer             *saveTimer;

  @private
    BOOL _needsReleasing;
}

// ============================================================================
// ==== Intialization & deallocation
// ============================================================================

- (id)init;
- (void)dealloc;

// ============================================================================
// ==== Timer handling
// ============================================================================

- (void)resetSaveTimer:(NSNotification *)notif;

// ============================================================================
// ==== Accessory methods
// ============================================================================
- (PCProjectInspector *)projectInspector;
- (void)showProjectInspector:(id)sender;
- (NSPanel *)historyPanel;
- (NSPanel *)buildPanel;
- (NSPanel *)launchPanel;
- (NSPanel *)projectFinderPanel;

// ============================================================================
// ==== Project management
// ============================================================================

// Returns all currently loaded projects. They are stored with their absolut
// paths as the keys.
- (NSMutableDictionary *)loadedProjects;

// Returns the currently active project
- (PCProject *)activeProject;

// Sets the new currently active project
- (void)setActiveProject:(PCProject *)aProject;

// Gets set while initialising!
- (NSString *)rootBuildPath;

// Returns active project's path
- (NSString *)projectPath;

// Returns name of file selected in browser (and visible in internal editor)
- (NSString *)selectedFileName;

// ============================================================================
// ==== Project actions
// ============================================================================

// Returns the loaded project if the builder class is known, nil else.
- (PCProject *)loadProjectAt:(NSString *)aPath;

// Invokes loadProjectAt to load the project properly.
- (BOOL)openProjectAt:(NSString *)aPath;

// projectType is exactly the name of the class to be invoked to create the
// project!
- (BOOL)createProjectOfType:(NSString *)projectType path:(NSString *)aPath;

// Saves the current project
- (BOOL)saveProject;

// Calls saveAllProjects if the preferences are setup accordingly.
- (void)saveAllProjectsIfNeeded;

// Saves all projects if needed.
- (void)saveAllProjects;

- (BOOL)saveProjectAs:(NSString *)projName;

// Reverts the currently active project
- (void)revertToSaved;

- (BOOL)newSubproject;
- (BOOL)addSubprojectAt:(NSString *)path;
- (void)removeSubproject;

- (void)closeProject:(PCProject *)aProject;
// Closes the currently active project
- (void)closeProject;

// ============================================================================
// ==== File actions
// ============================================================================

- (BOOL)saveAllFiles;
- (BOOL)saveFile;
- (BOOL)saveFileAs:(NSString *)path;
- (BOOL)saveFileTo:(NSString *)path;
- (BOOL)revertFileToSaved;
- (void)closeFile;

- (BOOL)renameFileTo:(NSString *)path;
- (BOOL)removeFilesPermanently:(BOOL)yn;

@end

@interface  PCProjectManager (FileManagerDelegates)

// Returns the full path if the type is valid, nil else.
- (NSString *)fileManager:(id)sender 
           willCreateFile:(NSString *)aFile
	          withKey:(NSString *)key;

// Adds the file to the project and updates the makefile!
- (void)fileManager:(id)sender 
      didCreateFile:(NSString *)aFile
            withKey:(NSString *)key;

// Returns the active project
- (id)fileManagerWillAddFiles:(id)sender;

- (BOOL)fileManager:(id)sender 
      shouldAddFile:(NSString *)file
             forKey:(NSString *)key;

// Adds the file to the project and update the makefile!
- (void)fileManager:(id)sender 
         didAddFile:(NSString *)file
	     forKey:(NSString *)key;

@end

@interface NSObject (PCProjectManagerDelegates)

- (void)projectManager:(id)sender willCloseProject:(PCProject *)aProject;
- (void)projectManager:(id)sender didCloseProject:(PCProject *)aProject;
- (void)projectManager:(id)sender didOpenProject:(PCProject *)aProject;
- (BOOL)projectManager:(id)sender shouldOpenProject:(PCProject *)aProject;

@end

#endif
