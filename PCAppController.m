/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2001 Free Software Foundation

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

#include "PCAppController.h"
#include "PCMenuController.h"

#include <ProjectCenter/ProjectCenter.h>

#define REL_LIB_PC @"Library/ApplicationSupport/ProjectCenter"
#define ABS_LIB_PC @"/usr/GNUstep/System/Library/ApplicationSupport/ProjectCenter"

@implementation PCAppController

//============================================================================
//==== Intialization & deallocation
//============================================================================

+ (void)initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  NSDictionary        *env = [[NSProcessInfo processInfo] environment];
  NSString            *prefix = [env objectForKey:@"GNUSTEP_SYSTEM_ROOT"];
  NSString            *_bundlePath;

  if (prefix && ![prefix isEqualToString:@""])
    {
      _bundlePath = [prefix stringByAppendingPathComponent:REL_LIB_PC];
    }
  else
    {
      _bundlePath = [NSString stringWithString:ABS_LIB_PC];
    }

  [defaults setObject:_bundlePath forKey:BundlePaths];

  [defaults setObject:@"/usr/bin/vim" forKey:Editor];
  [defaults setObject:@"/usr/bin/gdb" forKey:PDebugger];
  [defaults setObject:@"/usr/bin/gcc" forKey:Compiler];

  [defaults setObject:@"YES" forKey:ExternalEditor];
  [defaults setObject:@"YES" forKey:ExternalDebugger];

  [defaults setObject:[NSString stringWithFormat:@"%@/ProjectCenterBuildDir",NSTemporaryDirectory()] forKey:RootBuildDirectory];

  [defaults setObject:@"YES" forKey:SaveOnQuit];
  [defaults setObject:@"YES" forKey:PromptOnClean];
  [defaults setObject:@"YES" forKey:PromptOnQuit];
  [defaults setObject:@"YES" forKey:AutoSave];
  [defaults setObject:@"YES" forKey:KeepBackup];
  [defaults setObject:@"120" forKey:AutoSavePeriod];
  [defaults setObject:@"NO" forKey:DeleteCacheWhenQuitting];

  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
  if ((self = [super init]))
    {
      bundleLoader = [[PCBundleLoader alloc] init];
      [bundleLoader setDelegate:self];

      projectTypes = [[NSMutableDictionary alloc] init];

      prefController = [[PCPrefController alloc] init];
      finder         = [[PCFindController alloc] init];
      infoController = [[PCInfoController alloc] init];
      logger         = [[PCLogController alloc] init];
      projectManager = [[PCProjectManager alloc] init];
      menuController = [[PCMenuController alloc] init];

      [menuController setAppController:self];
      [menuController setProjectManager:projectManager];
    }

  return self;
}

- (void)dealloc
{
  [super dealloc];
}

//============================================================================
//==== Delegate
//============================================================================

- (id)delegate
{
  return delegate;
}

- (void)setDelegate:(id)aDelegate
{
  delegate = aDelegate;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  if (![super respondsToSelector:aSelector])
  {
    return [menuController respondsToSelector:aSelector];
  }
  else
  {
    return YES;
  }
}
                            
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
  SEL aSelector = [anInvocation selector];

  if ([menuController respondsToSelector: aSelector])
    {   
      [anInvocation invokeWithTarget:  menuController];
    }
  else
    {
      [super forwardInvocation: anInvocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
  NSMethodSignature *sig;

  sig = [super methodSignatureForSelector:aSelector];
  if (sig == nil)
  {
    sig = [menuController methodSignatureForSelector:aSelector];
  }

  return sig;
}

//============================================================================
//==== Bundle Management
//============================================================================

- (PCBundleLoader *)bundleLoader
{
  return bundleLoader;
}

- (PCProjectManager *)projectManager
{
  return projectManager;
}

- (PCInfoController *)infoController
{
  return infoController;
}

- (PCPrefController *)prefController
{
  return prefController;
}

- (PCMenuController *)menuController
{
  return menuController;
}

- (PCServer *)doServer
{
  return doServer;
}

- (PCFindController *)finder
{
  return finder;
}

- (PCLogController *)logger
{
  return logger;
}

- (NSDictionary *)projectTypes
{
  return projectTypes;
}

//============================================================================
//==== Misc...
//============================================================================

- (BOOL)application:(NSApplication *)application openFile:(NSString *)fileName
{
  if ([[fileName pathExtension] isEqualToString:@"pcproj"] == NO
      && [[fileName pathExtension] isEqualToString:@"project"] == NO) 
  {
    return NO;
  }

  [NSApp activateIgnoringOtherApps:YES];
  return [projectManager openProjectAt:fileName];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
  [bundleLoader loadBundles];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  NSString *h = [[NSProcessInfo processInfo] hostName];
  NSString *connectionName = [NSString stringWithFormat:@"ProjectCenter:%@",h];

  [logger logMessage:@"Loading additional subsystems..." tag:INFORMATION];

  doServer = [[PCServer alloc] init];
  
  NS_DURING
    
  doConnection = [[NSConnection alloc] init];
  [doConnection registerName:connectionName];
  
  NS_HANDLER
    
  NSRunAlertPanel(@"Warning!",@"Could not register the DO connection %@",
                  @"OK",nil,nil,nil,connectionName);
  NS_ENDHANDLER
    
  [[NSNotificationCenter defaultCenter] addObserver:doServer 
                                           selector:@selector(connectionDidDie:)
                                             name:NSConnectionDidDieNotification
                                            object:doConnection];
  
  [doConnection setDelegate:doServer];

  [[NSNotificationCenter defaultCenter] postNotificationName:PCAppDidInitNotification object:nil];
}

- (BOOL)applicationShouldTerminate:(id)sender
{
    NSString *poq = [[NSUserDefaults standardUserDefaults] objectForKey:PromptOnQuit];
    NSString *soq = [[NSUserDefaults standardUserDefaults] objectForKey:SaveOnQuit];

    if( [poq isEqualToString:@"YES"] )
    {
        if (NSRunAlertPanel(@"Quit!",
                            @"Do you really want to quit ProjectCenter?",
                            @"No", @"Yes", nil)) {
            return NO;
        }

    }

    if ( [soq isEqualToString:@"YES"] ) {
        [projectManager saveAllProjects];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:PCAppWillTerminateNotification object:nil];

    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
  NSLog (@"Applictaion will terminate");
  if ([[[NSUserDefaults standardUserDefaults] 
      stringForKey:DeleteCacheWhenQuitting] isEqualToString:@"YES"]) 
    {
      [[NSFileManager defaultManager] 
	removeFileAtPath:[projectManager rootBuildPath]
	         handler:nil];
    }

  [[NSUserDefaults standardUserDefaults] synchronize];

  //--- Cleanup
  if (doConnection)
  {
    [doConnection invalidate];
    RELEASE(doConnection);
  }

  NSLog (@"AppController close: PM RC: %i", [projectManager retainCount]);
  
  RELEASE(prefController);
  RELEASE(finder);
  RELEASE(infoController);
  RELEASE(logger);
  RELEASE(projectManager);
  RELEASE(menuController);
  
  RELEASE(bundleLoader);
  RELEASE(doServer);
  RELEASE(projectTypes);
}

//============================================================================
//==== Delegate stuff
//============================================================================

- (void)bundleLoader:(id)sender didLoadBundle:(NSBundle *)aBundle
{
  Class principalClass;

  NSAssert(aBundle,@"No valid bundle!");

  principalClass = [aBundle principalClass];
  NSString	*name = [[principalClass sharedCreator] projectTypeName];

  [logger logMessage: [NSString stringWithFormat:
    @"Project type %@ successfully loaded!",name] tag:INFORMATION];

  if ([self registerProjectCreator:NSStringFromClass(principalClass) forKey:name]) 
    {
      [menuController addProjectTypeNamed:name];
      [logger logMessage:[NSString stringWithFormat:
	@"Project type %@ successfully registered!",name] tag:INFORMATION];
    }
}

@end

@implementation PCAppController (ProjectRegistration)

- (BOOL)registerProjectCreator:(NSString *)className forKey:(NSString *)aKey
{
    if ([projectTypes objectForKey:aKey]) 
    {
        return NO;
    }

    [projectTypes setObject:className forKey:aKey];

    return YES;
}

@end
