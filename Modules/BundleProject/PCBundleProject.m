/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2001 Free Software Foundation

   Author: Philippe C.D. Robert <phr@3dkit.org>

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

#include "PCBundleProj.h"
#include "PCBundleProject.h"

#include <ProjectCenter/PCMakefileFactory.h>
#include <ProjectCenter/ProjectCenter.h>

@implementation PCBundleProject

//----------------------------------------------------------------------------
// Init and free
//----------------------------------------------------------------------------

- (id)init
{
  if ((self = [super init]))
    {
      rootObjects = [[NSArray arrayWithObjects: PCClasses,
						PCHeaders,
						PCOtherSources,
						PCInterfaces,
						PCImages,
						PCOtherResources,
						PCSubprojects,
						PCDocuFiles,
						PCSupportingFiles,
						PCLibraries,
						PCNonProject,
						nil] retain];

      rootKeys = [[NSArray arrayWithObjects: @"Classes",
					     @"Headers",
					     @"Other Sources",
					     @"Interfaces",
					     @"Images",
					     @"Other Resources",
					     @"Subprojects",
					     @"Documentation",
					     @"Supporting Files",
					     @"Libraries",
					     @"Non Project Files",
					     nil] retain];

      rootCategories = [[NSDictionary 
	dictionaryWithObjects:rootObjects forKeys:rootKeys] retain];

    }

  return self;
}

- (void)dealloc
{
  [rootCategories release];
  [rootObjects release];
  [rootKeys release];
  [projectAttributesView release];

  [super dealloc];
}

//----------------------------------------------------------------------------
// Project
//----------------------------------------------------------------------------

- (Class)builderClass
{
  return [PCBundleProj class];
}

- (NSString *)projectDescription
{
  return @"GNUstep Objective-C bundle project";
}

- (BOOL)isExecutable
{
  return NO;
}

- (NSString *)execToolName
{
  return nil;
}

- (NSArray *)fileTypesForCategory:(NSString *)category
{
  if ([category isEqualToString:PCClasses])
    {
      return [NSArray arrayWithObjects:@"m",nil];
    }
  else if ([category isEqualToString:PCHeaders])
    {
      return [NSArray arrayWithObjects:@"h",nil];
    }
  else if ([category isEqualToString:PCOtherSources])
    {
      return [NSArray arrayWithObjects:@"c",@"C",nil];
    }
  else if ([category isEqualToString:PCInterfaces])
    {
      return [NSArray arrayWithObjects:@"gmodel",@"gorm",nil];
    }
  else if ([category isEqualToString:PCImages])
    {
      return [NSImage imageFileTypes];
    }
  else if ([category isEqualToString:PCSubprojects])
    {
      return [NSArray arrayWithObjects:@"subproj",nil];
    }
  else if ([category isEqualToString:PCLibraries])
    {
      return [NSArray arrayWithObjects:@"so",@"a",@"lib",nil];
    }

  return nil;
}

- (NSString *)dirForCategory:(NSString *)category
{
  if ([category isEqualToString:PCImages])
    {
      return [projectPath stringByAppendingPathComponent:@"Images"];
    }
  else if ([category isEqualToString:PCDocuFiles])
    {
      return [projectPath stringByAppendingPathComponent:@"Documentation"];
    }

  return projectPath;
}

- (NSArray *)buildTargets
{
  return [NSArray arrayWithObjects:
    @"bundle", @"debug", @"profile", @"dist", nil];
}

- (NSArray *)sourceFileKeys
{
  return [NSArray arrayWithObjects:PCClasses,PCOtherSources,nil];
}

- (NSArray *)resourceFileKeys
{
  return [NSArray arrayWithObjects:PCInterfaces,PCOtherResources,PCImages,nil];
}

- (NSArray *)otherKeys
{
  return [NSArray arrayWithObjects:PCDocuFiles,PCSupportingFiles,nil];
}

- (NSArray *)allowableSubprojectTypes
{
  return [NSArray arrayWithObjects:
    @"Bundle", @"Tool", @"Framework", @"Library", @"Palette", nil];
}

- (NSArray *)defaultLocalizableKeys
{
  return [NSArray arrayWithObjects:PCInterfaces, nil];
}

- (NSArray *)localizableKeys
{
  return [NSArray arrayWithObjects: 
    PCInterfaces, PCImages, PCOtherResources, PCDocuFiles, nil];
}

@end

@implementation PCBundleProject (GeneratedFiles)

- (BOOL)writeMakefile
{
  PCMakefileFactory *mf = [PCMakefileFactory sharedFactory];
  int               i,j; 
  NSString          *mfl = nil;
  NSData            *mfd = nil;

  // Save the GNUmakefile backup
  [super writeMakefile];

  // Save GNUmakefile.preamble
  [mf createPreambleForProject:self];

  // Create the new file
  [mf createMakefileForProject:projectName];

  // Head
  [self appendHead:mf];

  // Libraries
  [self appendLibraries:mf];

  // Subprojects
  if ([[projectDict objectForKey:PCSubprojects] count] > 0)
    {
      [mf appendSubprojects:[projectDict objectForKey:PCSubprojects]];
    }

  // Resources
  [mf appendResources];
  for (i = 0; i < [[self resourceFileKeys] count]; i++)
    {
      NSString       *k = [[self resourceFileKeys] objectAtIndex:i];
      NSMutableArray *resources = [[projectDict objectForKey:k] mutableCopy];

      if ([k isEqualToString:PCImages])
	{
	  for (j=0; j<[resources count]; j++)
	    {
	      [resources replaceObjectAtIndex:j 
		withObject:[NSString stringWithFormat:@"Images/%@", 
		[resources objectAtIndex:j]]];
	    }
	}

      [mf appendResourceItems:resources];
      [resources release];
    }

  [mf appendHeaders:[projectDict objectForKey:PCHeaders]];
  [mf appendClasses:[projectDict objectForKey:PCClasses]];
  [mf appendOtherSources:[projectDict objectForKey:PCOtherSources]];

  // Tail
  [self appendTail:mf];

  // Write the new file to disc!
  mfl = [projectPath stringByAppendingPathComponent:@"GNUmakefile"];
  if ((mfd = [mf encodedMakefile])) 
    {
      if ([mfd writeToFile:mfl atomically:YES]) 
	{
	  return YES;
	}
    }

  return NO;
}

- (void)appendHead:(PCMakefileFactory *)mff
{
  [mff appendString:@"\n#\n# Bundle\n#\n"];
  [mff appendString:[NSString stringWithFormat:@"PACKAGE_NAME = %@\n",
    projectName]];
  [mff appendString:[NSString stringWithFormat:@"BUNDLE_NAME = %@\n",
    projectName]];
  [mff appendString:[NSString stringWithFormat:@"BUNDLE_EXTENSION = %@\n",
   [projectDict objectForKey:PCBundleExtension]]];
  [mff appendString:[NSString stringWithFormat:@"BUNDLE_INSTALL_DIR = %@\n",
    [projectDict objectForKey:PCInstallDir]]];
  [mff appendString:[NSString stringWithFormat:@"%@_PRINCIPAL_CLASS = %@\n",
    projectName, [projectDict objectForKey:PCPrincipalClass]]];
}

- (void)appendLibraries:(PCMakefileFactory *)mff
{
  NSArray *libs = [projectDict objectForKey:PCLibraries];

  [mff appendString:@"\n#\n# Libraries\n#\n"];

  [mff appendString:
    [NSString stringWithFormat:@"%@_LIBRARIES_DEPEND_UPON += ",projectName]];

  if (libs && [libs count])
    {
      NSString     *tmp;
      NSEnumerator *enumerator = [libs objectEnumerator];

      while ((tmp = [enumerator nextObject])) 
	{
	  if (![tmp isEqualToString:@"gnustep-base"] &&
	      ![tmp isEqualToString:@"gnustep-gui"]) 
	    {
	      [mff appendString:[NSString stringWithFormat:@"-l%@ ",tmp]];
	    }
	}
    }
}

- (void)appendTail:(PCMakefileFactory *)mff
{
  [mff appendString:@"\n\n#\n# Makefiles\n#\n"];
  [mff appendString:@"-include GNUmakefile.preamble\n"];
  [mff appendString:@"include $(GNUSTEP_MAKEFILES)/aggregate.make\n"];
  [mff appendString:@"include $(GNUSTEP_MAKEFILES)/bundle.make\n"];
  [mff appendString:@"-include GNUmakefile.postamble\n"];
}

@end

@implementation PCBundleProject (Inspector)

- (NSView *)projectAttributesView
{
  if (projectAttributesView == nil)
    {
      if ([NSBundle loadNibNamed:@"Inspector" owner:self] == NO)
	{
	  NSLog(@"PCBundleProject: error loading Inspector NIB!");
	  return nil;
	}
      [projectAttributesView retain];
      [self updateInspectorValues:nil];
    }

  return projectAttributesView;
}

- (void)updateInspectorValues:(NSNotification *)aNotif 
{
  [projectTypeField setStringValue:@"Bundle"];
  [projectNameField setStringValue:projectName];
  [projectLanguageField
    setStringValue:[projectDict objectForKey:@"LANGUAGE"]];
  [principalClassField 
    setStringValue:[projectDict objectForKey:PCPrincipalClass]];
  [bundleExtensionField 
    setStringValue:[projectDict objectForKey:PCBundleExtension]];
}

- (void)setPrincipalClass:(id)sender
{
  [self setProjectDictObject:[principalClassField stringValue]
                      forKey:PCPrincipalClass];
}

- (void)setBundleExtension:(id)sender
{
  [self setProjectDictObject:[bundleExtensionField stringValue]
                      forKey:PCBundleExtension];
}

@end

