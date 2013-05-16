module PDF
  class Info

    ENCRYPTED_FILE_RESPONSE = "Command Line Error: Incorrect password"
    
    class Error < RuntimeError; end
    class UnexpectedExitError < PDF::Info::Error
      attr_accessor :exit_code
    end

    class UnknownError < PDF::Info::Error; end
    class FileError < PDF::Info::Error; end
    class OutputError < PDF::Info::Error; end
    class BadPermissionsError < PDF::Info::Error; end
    class EncryptedFileError < PDF::Info::Error; end
  end
end
