#!/usr/bin/ruby

require 'osx/cocoa'

$issues = [
  {
    'pattern'=>'self\.((\w|\d|_)+)\s*=\s*\[\s*\[\s*((\w|\d|_)+)\s*alloc\s*\]\s*(.*)\]\s*',
    'message'=>'Assigning an ivar with an Objective-C object with a +1 retain count (owning reference)'
  }
]

# =========================================
# = Creates a plist from the project file =
# =========================================
def xcodePlist(xcodeproj)
  pbxproj = "#{xcodeproj}/project.pbxproj"
  data = OSX::NSData.dataWithContentsOfFile(pbxproj)
  return OSX::NSPropertyListSerialization.propertyListFromData_mutabilityOption_format_errorDescription(data, 0, nil, nil)
end

# ==========================================================================
# = Returns the object for the object ID.  If nil, returns the rootObject. =
# ==========================================================================
def xcodeObject(plist, objectID)
  objects = plist['objects']
  if objectID
    return objects[objectID]
  end
  return objects[plist['rootObject']]
end

# =================================================
# = Returns an array of source IDs for the target =
# =================================================
def targetSourceIDs(plist, targetName)
  root = xcodeObject(plist, nil)
  targetIDs = root['targets']
  
  # Get the target by name, if no name get the first one
  if targetName
    for targetID in targetIDs
      target = xcodeObject(plist, targetID)
      if target['name'] == targetName
        break
      end
      target = nil
    end
  else
    targetID = targetIDs[0]
    target = xcodeObject(plist, targetID)
  end
  
  # Just return nil if we didn't find a target
  if target.nil?
    return nil
  end
  
  # Get the sources from the source build phase
  for phaseID in target['buildPhases']
    phase = xcodeObject(plist, phaseID)
    if phase['isa'] == "PBXSourcesBuildPhase"
      return phase['files']
    end
  end
  
  return nil
end

# ================================================================
# = Gets the path. May be relative to the group, or the target.  =
# = Returns a hash with the path and a boolean indicating which. =
# ================================================================
def pathForObjectInGroup(plist, groupID, objectID)
  if groupID == objectID
    object = xcodeObject(plist, objectID)
    done = (object['sourceTree'] == "SOURCE_ROOT")
    return { "path" => object['path'], "done" => done }
  end
  
  group = xcodeObject(plist, groupID)
  children = group['children']
  if children
    for childID in children
      result = pathForObjectInGroup(plist, childID, objectID)
      if result
        path = result['path']
        done = result['done']
        
        if done
          return result
        end
        
        groupPath = group['path']
        if groupPath
          path = groupPath + '/' + path
        end
        
        done = (group['sourceTree'] == "SOURCE_ROOT")
        return { "path" => path, "done" => done }
        
      end
    end
  end
  
  return nil
end

# ==========================================================
# = Returns the path of the object relative to the project =
# ==========================================================
def pathForObject(plist, objectID)
  object = xcodeObject(plist, objectID)
  fileRef = object['fileRef']
  rootObject = xcodeObject(plist, nil)
  mainGroup = rootObject['mainGroup']
  pathObj = pathForObjectInGroup(plist, mainGroup, fileRef)
  return pathObj['path']
end

# ================
# = Finds issues =
# ================
def findIssues(path)
  for issue in $issues
    regex = Regexp.new(issue['pattern'])
    File.open(path, 'r') do |file|
      i = 1
      while(line = file.gets)
        matches = line.scan regex
        puts "#{path}:#{i}: warning: #{issue['message']}" unless matches.empty?
        i = i + 1
      end
    end
  end
end

# ========
# = Main =
# ========
def main()
  xcodeproj = ARGV[0]
  plist = xcodePlist(xcodeproj)
  sourceIDs = targetSourceIDs(plist, ARGV[1])
  dir = File.dirname(xcodeproj)
  for sourceID in sourceIDs
    path = pathForObject(plist, sourceID)
    findIssues(dir + "/" + path)
  end
end

main() # Run main
