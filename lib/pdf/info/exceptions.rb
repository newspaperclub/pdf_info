module PDF
  class Info
    class UnexpectedExitError < RuntimeError
      attr_accessor :exit_code
    end

    class UnknownError < RuntimeError; end
    class FileError < RuntimeError; end
    class OutputError < RuntimeError; end
    class BadPermissionsError < RuntimeError; end
  end
end
