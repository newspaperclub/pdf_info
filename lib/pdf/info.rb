require 'pdf/info/exceptions'

module PDF
  class Info
    @@command_path = "pdfinfo"

    def self.command_path=(path)
      @@command_path = path
    end

    def self.command_path
      @@command_path
    end

    def initialize(pdf_path)
      @pdf_path = pdf_path
    end

    def command
      cmd = "#{self.class.command_path} #{Shellwords.escape(@pdf_path)} -f 1 -l -1"
      output = `#{cmd} 2>&1`.chomp
      exit_code = $? 
      case exit_code
      when 0 || nil
        return output
      else
        if (output == PDF::Info::ENCRYPTED_FILE_RESPONSE)
          raise PDF::Info::EncryptedFileError
        else
          exit_error = PDF::Info::UnexpectedExitError.new(output)
          exit_error.exit_code = exit_code
          raise exit_error
        end
      end
    end

    def metadata
      begin
        process_output(command)
      rescue UnexpectedExitError => e
        case e.exit_code
        when 1
          raise FileError
        when 2
          raise OutputError
        when 3
          raise BadPermissionsError
        else
          raise
        end
      end
    end

    def process_output(output)
      rows = output.split("\n")
      metadata = {}
      rows.each do |row|
        pair = row.split(':', 2)
        case pair.first
        when "Pages"
          metadata[:page_count] = pair.last.to_i
        when "Encrypted"
          metadata[:encrypted] = pair.last == 'yes'
        when "Optimized"
          metadata[:optimized] = pair.last == 'yes'
        when "Tagged"
          metadata[:tagged] = pair.last == 'yes'
        when "PDF version"
          metadata[:version] = pair.last.to_f
        when "CreationDate"
          metadata[:creation_date] = DateTime.parse(pair.last)
        when "ModDate"
          metadata[:modification_date] = DateTime.parse(pair.last)
        when /^Page.*size$/
          metadata[:pages] ||= []
          # Subtract 1 because pdfinfo has pdfs with page 1 at start but arrays are 0 based
          page_number = pair.first.split(' ')[1].to_i - 1
          metadata[:pages][page_number] ||= {}
          metadata[:pages][page_number][:size] = pair.last.scan(/[\d.]+/).map(&:to_f)
          format = pair.last.scan(/\(.*\)$/)
          metadata[:pages][page_number][:format] = format[0][1...format[0].length-1] unless format.nil? || format.length == 0
        when /^Page.*rot$/
          metadata[:pages] ||= []
          page_number = pair.first.split(' ')[1].to_i - 1
          metadata[:pages][page_number] ||= {}
          metadata[:pages][page_number][:rot] = pair.last.to_f
        when String
          metadata[pair.first.downcase.tr(" ", "_").to_sym] = pair.last.to_s.strip
        end
      end

      metadata
    end

  end

  class TestInfo

    def initialize(page_count)
      @page_count = page_count
    end

    def metadata
      md = {}
      md[:creation_date] = DateTime.now
      md[:modification_date] = DateTime.now
      md[:version] = 1.4
      md[:tagged] = false
      md[:optimized] = false
      md[:encrypted] = false
      md[:pages] = []
      md[:page_count] = @page_count
      0.upto(@page_count - 1) do |idx|
        md[:pages][idx] = {:size => [612, 792], :format => 'letter', :rot => 0.0}
      end
      md
    end
  end


end
