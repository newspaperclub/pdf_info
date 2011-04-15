module PDF
  class Info
    class Error < RuntimeError; end
    class UnexpectedExitError < PDF::Info::Error
      attr_accessor :exit_code
    end

    class UnknownError < PDF::Info::Error; end
    class FileError < PDF::Info::Error; end
    class OutputError < PDF::Info::Error; end
    class BadPermissionsError < PDF::Info::Error; end
  end
end
