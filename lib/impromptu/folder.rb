module Impromptu
  class Folder
    attr_accessor :path, :files
    
    def initialize(path, options={})
      @path   = path
      @files  = OrderedSet.new
      @implicitly_load_all_files = true
    end
    
    # Override eql? so two folders with the same path will be
    # considered equal by ordered set.
    def eql?(other)
      other.path == @path
    end
    
    # Override hash so two folders with the same path will result
    # in the same hash value.
    def hash
      @path.hash
    end
    
    # Explicitly include a file from this folder. If you
    # use this method, only files included by this method
    # will be loaded. If you do not use this method, all
    # files within this folder will be accessible.
    def file(name, options={})
      @implicitly_load_all_files = false
      @files << Impromptu::File.new(File.join(@path, name), options[:provides])
    end
    
    # Reload the files provided by this folder. If the folder
    # is tracking a specific set of files, only those files
    # will be reloaded. Otherwise, the folder is scanned again
    # and any previously unseen files loaded, existing files
    # reloaded, and removed files unloaded.
    def reload
      reload_file_set if @implicitly_load_all_files
      @files.each {|file| file.reload}
    end
    
    private
      # Determine changes between the set of files this folder knows
      # about, and the set of files existing on disk. Any files which
      # have been removed are unloaded (and their resources reloaded
      # if other files define the resources as well).
      def reload_file_set
        # collect all the files currently in this folder
        paths = Dir.entries(@path).collect {|file_name| File.join(@path, file_name)}
        paths.reject! {|path| !File.file?(path)}
        files = Set.new(paths.collect {|path| Impromptu::File.new(path)})
        
        # ignore any files that have already been loaded, and remove
        # files which used to exist but don't anymore
        @files.each do |file|
          unless files.include?(file)
            @files.delete(file)
            file.remove
          end
          files.delete(file)
        end
        
        # any files left are new to this folder
        @files.merge(files.to_a)
      end
  end
end
