module Pod
  class Command
    class Reopen < Command

      self.summary = 'Reopen the workspace'
      self.description = <<-DESC
        Close and opens the workspace in Xcode. If no workspace found in the current directory,
        looks up parent it finds one.
      DESC

      def initialize(argv)
        @workspace = find_workspace_in(Pathname.pwd)
        super
      end

      def validate!
        super
        raise Informative, "No xcode workspace found" unless @workspace
      end

      def run
        ascript = <<-STR.strip_heredoc
tell application "Xcode"
        set docs to (document of every window)
        repeat with doc in docs
            if class of doc is workspace document then
                set docPath to path of doc
                if docPath begins with "#{@workspace}" then
                    log docPath
                    return
                end if
            end if
        end repeat
end tell
STR
# puts ascript
        `osascript -e '#{ascript}'`
        # `open "#{@workspace}"`
      end

      private

      def find_workspace_in(path)
        path.children.find {|fn| fn.extname == '.xcworkspace'} || find_workspace_in_example(path)
      end

      def find_workspace_in_example(path)
        tofind = path + 'Example'
        find_workspace_in(tofind)
      end
    end
  end
end
