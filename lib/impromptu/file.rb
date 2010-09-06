module Impromptu
  class File
    attr_reader :path, :resources, :related_resources, :related_files, :modified_time, :loaded
    
    def initialize(path, provides=[])
      @path               = path
      @resources          = OrderedSet.new
      @related_resources  = Set.new
      @related_files      = Set.new
      @frozen             = false
      @modified_time      = nil
      @loaded             = false
      
      if provides.empty?
        @resources << module_symbol_from_path
      else
        @resources.merge(provides)
      end
    end
    
    def eql?(other)
      other.path == @path
    end
    alias :== :eql?
    
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
    
    # Load (or reload) all of the resources provided by this
    # file. If a resource is provided by multiple files, those
    # files will also be reloaded (and the resources provided
    # in those files reloaded). For this reason it's advisable
    # to declare a single resource per file, otherwise the
    # dependencies between files and resources can cause large
    # subsections of the component graph to be reloaded together.
    def reload
      @related_resources.each {|resource| resource.unload}
      @related_files.each {|file| Kernel.load file.path}
      @modified_time = File.mtime(@path)
      @loaded = true
    end
    
    # Unload all of the resources provided by this file. This
    # doesn't just unload the parts of a resource defined by
    # this file, but the entire resource itself. i.e if there
    # are two files defining a resource, unloading one file
    # will unload the resource completely.
    def unload
      resources.each {|resource| resource.unload}
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
