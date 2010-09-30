module Impromptu
  class Folder
    attr_accessor :folder, :files, :component, :namespace
    DEFAULT_OPTIONS   = {nested_namespaces: true, reloadable: true}
    SOURCE_EXTENSIONS = %w{rb so bundle}
    
    # Register a new folder containing source files for a
    # component. Path is a Pathname object representing the
    # folder, and options may be:
    # * nested_namespaces: true by default. If true, sub-
    #   folders indicate a new namespace for resources. For
    #   instance, a folder with a root of 'src', containing
    #   a folder called 'plugins' which has a file 'klass.rb'
    #   would define the resource Plugins::Klass. When false,
    #   the file would simply represent Klass.
    # * reloadable: true by default. If true, this folder
    #   will be reloaded every time Impromptu.update is
    #   called, and any modified files will be reloaded,
    #   removed files unloaded, and new files tracked.
    def initialize(path, component, options={}, block)
      @folder     = path.realpath
      @component  = component
      @options    = DEFAULT_OPTIONS.merge(options)
      @block      = block
      @files      = OrderedSet.new
      @implicitly_load_all_files = true
    end
    
    # Override eql? so two folders with the same path will be
    # considered equal by ordered set.
    def eql?(other)
      other.folder == @folder
    end
    
    # Override hash so two folders with the same path will result
    # in the same hash value.
    def hash
      @folder.hash
    end
    
    # Load a folders definition and files after the set of components
    # has been defined. For folders provided a block, the block is
    # run in the context of this folder (allowing 'file' to be called).
    # Otherwise the folder is scanned to produce an initial set of files
    # and resources provided by this folder.
    def load
      if @block.nil?
        self.reload_file_set
      else
        instance_eval &@block
        @block = nil # prevent the block from being run twice
      end
    end
    
    # True if the folder uses nested namespaces
    def nested_namespaces?
      @options[:nested_namespaces]
    end
    
    # True if the folder is reloadable
    def reloadable?
      @options[:reloadable]
    end
    
    # Return the 'base' folder for a file contained within this
    # folder. For instance, a folder with nested namespaces would
    # return the path to a file from the root folder. Without
    # namespaces, the relative path to a file would be the enclosing
    # folder of the file. i.e relative path to framework/a/b.rb (where
    # framework is the root folder) would return 'a/b.rb' for a
    # nested namespace folder, or just 'b.rb' for a non nested
    # namespace folder.
    def relative_path_to(path)
      if nested_namespaces?
        path.relative_path_from(@folder)
      else
        path.basename
      end
    end
    
    # Explicitly include a file from this folder. If you use this
    # method, only files included by this method will be loaded.
    # If you do not use this method, all files within this folder
    # will be accessible. For this reason, you probably want to
    # separate out files which need to be defined this way into a
    # folder separate to the majority of your source files. Options
    # may be:
    # * provides (required): an array of symbols, or a symbol
    #   inidicating the name of the resource(s) provided by the file
    def file(name, options={})
      @implicitly_load_all_files = false
      file = Impromptu::File.new(@folder.join(*name).realpath, self, options[:provides])
      @files.push(file).add_resource_definition
    end
    
    # Reload the files provided by this folder. If the folder
    # is tracking a specific set of files, only those files
    # will be reloaded. Otherwise, the folder is scanned again
    # and any previously unseen files loaded, existing files
    # reloaded, and removed files unloaded.
    def reload
      reload_file_set if @implicitly_load_all_files
      @files.each {|file| file.reload_if_modified}
    end
    
    # Determine changes between the set of files this folder
    # knows about, and the set of files existing on disk. Any
    # files which have been removed are unloaded (and their
    # resources reloaded if other files define the resources
    # as well), and any new files insert their resources in to
    # the known resources tree.
    def reload_file_set
      return unless @implicitly_load_all_files
      old_file_set = @files.to_a
      new_file_set = []
      changes = false
      
      # find all current files and add them if necessary
      @folder.find do |path|
        next unless source_file?(path)
        file = Impromptu::File.new(path.realpath, self)
        new_file_set << file
        unless @files.include?(file)
          changes = true
          @files.push(file).add_resource_definition
        end
      end

      # remove any files which have been deleted
      deleted_files = old_file_set - new_file_set
      deleted_files.each {|file| @files.delete(file).remove}
      changes = true if deleted_files.size > 0
      
      # refreeze each files association lists if the set of
      # files has changed
      if changes
        @files.each do |file|
          file.refreeze
        end
      end
    end
    
    
    private
      # True if the path represents a file with an extension known to
      # implement resources.
      def source_file?(path)
        path.file? && SOURCE_EXTENSIONS.include?(path.extname[1..-1])
      end
  end
end
