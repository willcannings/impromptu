module Impromptu
  class Folder
    attr_accessor :path, :files
    
    def initialize(path)
      @path   = File.expand_path(path)
      @files  = OrderedSet.new
      @implicitly_load_all_files = true
    end
    
    # Override eql? so ordered set can determine equality between folders
    # based on paths (since the path hash is defined as the folder's hash)
    def eql?(other)
      other.path == @path
    end
    
    # Override hash so two folders with the same path will result in the
    # same hash value. We need to override eql? as well to ensure folders
    # with the same path and 
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
        # TODO
      end
  end
end
