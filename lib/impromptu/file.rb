module Impromptu
  class File
    attr_reader :path, :folder, :resources, :related_resources, :related_files, :modified_time
    RELOADABLE_EXTENSIONS = %w{rb}
    
    def initialize(path, folder, provides=[])
      @path               = path
      @folder             = folder
      @resources          = OrderedSet.new
      @related_resources  = Set.new
      @related_files      = Set.new
      @frozen             = false
      @modified_time      = nil
      
      if provides.empty?
        @resources << module_symbol_from_path
      else
        @resources.merge(provides)
      end
    end
    
    # Override eql? so two files with the same path will be
    # considered equal by ordered set.
    def eql?(other)
      other.path == @path
    end
    
    # Override hash so two files with the same path will result
    # in the same hash value.
    def hash
      @path.hash
    end
    
    # Traverse the file/resource graph to determine which total
    # set of files and resources are related to this file. For
    # instance, if a resource provided by this file is also
    # defined in another, both files, and the total set of
    # resources provided by these files, are included. If
    # further resources are provided, those resources along
    # with any other files defining them, are also included.
    def freeze
      return if @frozen
      remaining_resources = @provides.to_a
      remaining_files = [self]
      
      while remaining_resources.size > 0 || remaining_files.size > 0
        if resource = remaining_resources.shift
          @related_resources << resource
          resource.files.each do |file|
            remaining_files << file unless @related_files.include?(file)
          end
        end
        
        if file = remaining_files.shift
          @related_files << file
          file.resources.each do |resource|
            remaining_resources << resource unless @related_resources.include?(resource)
          end
        end
      end
      
      @frozen = true
    end
    
    # Unfreeze this file by clearing the related files and
    # resources lists.
    def unfreeze
      @related_resources = nil
      @related_files = nil
      @frozen = false
    end
    
    # Load (or reload) all of the resources provided by this
    # file. If a resource is provided by multiple files, those
    # files will also be reloaded (and the resources provided
    # in those files reloaded). For this reason it's advisable
    # to declare a single resource per file, otherwise the
    # dependencies between files and resources can cause large
    # subsections of the component graph to be reloaded together.
    def reload
      @related_resources.each {|resource| resource.unload}
      @related_files.each {|file| Kernel.load file.path if file.reloadable?}
      @modified_time = File.mtime(@path)
    end
    
    # Unload all of the resources provided by this file. This
    # doesn't just unload the parts of a resource defined by
    # this file, but the entire resource itself. i.e if there
    # are two files defining a resource, unloading one file
    # will unload the resource completely.
    def unload
      resources.each {|resource| resource.unload}
      @modified_time = nil
    end
    
    # Returns true if the current modification time of the
    # underlying file is greater than the modified_time of
    # the file when we last loaded it.
    def modified?
      return true if @modified_time.nil?
      File.mtime(@path) > @modified_time
    end
    
    # Reloads the associated resources only if the underlying
    # file has been modified since the last time it was loaded.
    def reload_if_modified
      reload if modified?
    end
    
    # Indicates if this file is currently loaded
    def loaded?
      !@modified_time.nil?
    end
    
    # Remove a file from the list of files related to this file.
    def remove_related_file(file)
      @related_files.delete(file)
    end
    
    # Delete references to this file from any resources or other
    # files. This does not unload the resource, so if loaded, the
    # resource will be defined by a file which is no longer tracked.
    def remove
      @related_files.each {|file| file.remove_related_file(self)}
      @resources.each do |resource|
        if resource.files.length == 1
          resource.remove
        else
          resource.remove_file(self)
        end
      end
    end
    
    def add_resource_definition
      # TODO
    end
    
    # True if the file has never been loaded before, or if the
    # file is of a type that can be reloaded (i.e ruby source
    # as opposed to C extensions).
    def reloadable?
      return true if !loaded?
      RELOADABLE_EXTENSIONS.include?(@path.extname)
    end
    
    
    private
      # Turn the path of this file into a module name. e.g:
      # /folder/klass_one.rb => :KlassOne
      def module_symbol_from_path
        # remove any directory names from the path, and the file extension
        extension = File.extname(@path)
        name = File.basename(@path)[0..-(extension.length + 1)]
      
        # upcase the first character, and any characters following an underscore
        name.gsub(/(?:^|_)(.)/) {|character| character.upcase}.to_sym
      end
  end
end
