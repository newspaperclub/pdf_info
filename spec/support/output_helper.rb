module OutputHelper

  def output(filename)
    File.read(File.join(File.dirname(__FILE__), '..', 'output', filename))
  end

end
