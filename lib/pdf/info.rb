require 'date' unless defined? DateTime
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
      null_redirect = Gem.win_platform? ? 'nul' : '/dev/null'
      output = `#{self.class.command_path} -enc UTF-8 -f 1 -l -1 "#{@pdf_path}" 2> #{null_redirect}`
      exit_code = $?
      case exit_code
      when 0 || nil
        if !output.valid_encoding?
          # It's already UTF-8, so we need to convert to UTF-16 and back to
          # force the bad characters to be replaced.
          output.encode!('UTF-16', :undef => :replace, :invalid => :replace, :replace => "")
          output.encode!('UTF-8')
        end
        return output
      else
        exit_error = PDF::Info::UnexpectedExitError.new
        exit_error.exit_code = exit_code
        raise exit_error
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
          raise UnknownError
        end
      end
    end

    def process_output(output)
      rows = output.split("\n")
      metadata = {}
      rows.each do |row|
        pair = row.split(':', 2)
        pair.map!(&:strip)

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
          creation_date = parse_datetime(pair.last)
          metadata[:creation_date] = creation_date if creation_date
        when "ModDate"
          modification_date = parse_datetime(pair.last)
          metadata[:modification_date] = modification_date if modification_date
        when /^Page.*size$/
          metadata[:pages] ||= []
          metadata[:pages] << pair.last.scan(/[\d.]+/).map(&:to_f)
          metadata[:format] = pair.last.scan(/.*\(\w+\)$/).to_s
        when String
          metadata[pair.first.downcase.tr(" ", "_").to_sym] = pair.last.to_s.strip
        end
      end

      metadata
    end

    private

    def parse_datetime(value)
      DateTime.parse(value)
    rescue
      begin
        DateTime.strptime(value, '%m/%d/%Y %k:%M:%S')
      rescue
        nil
      end
    end

  end
end
