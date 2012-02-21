# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pdf/info/version"

Gem::Specification.new do |s|
  s.name = %q{pdf_info}
  s.version = PDF::Info::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Tom Taylor"]
  s.email = ["tom@tomtaylor.co.uk"]
  s.homepage = "https://github.com/newspaperclub/pdf_info"
  s.summary = %q{Wraps the pdfinfo command line tool to provide a hash of metadata}
  s.licenses = ["MIT"]

  s.rubyforge_project = "pdf_info"

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")  
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
