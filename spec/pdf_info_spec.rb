require 'spec_helper'

describe PDF::Info do

  describe "default #command_path" do
    subject { PDF::Info }
    its(:command_path) { should == "pdfinfo" }
  end

  describe "#command_path=" do
    subject { PDF::Info }
    before(:each) { subject.command_path = "/usr/bin/pdfinfo" }
    its(:command_path) { should == "/usr/bin/pdfinfo" }
  end

  describe ".metadata" do

    context "success" do
      before(:each) do
        @pdf_info = PDF::Info.new('test.pdf')
        @pdf_info.stub!(:command).and_return(output('successful.txt'))
      end
      subject { @pdf_info.metadata }
      its([:page_count]) { should == 12 }
      its([:pages]) { should have(12).items }

      it "should have the correct page size set" do
        subject[:pages].each do |page|
          page.should == [819.213, 1077.17]
        end
      end

      its([:version]) { should == 1.4 }
      its([:encrypted]) { should be_false }
    end

    context "error opening file" do
      before(:each) do 
        @pdf_info = PDF::Info.new('test.pdf')
        unexpected_error = PDF::Info::UnexpectedExitError.new
        unexpected_error.exit_code = 1
        @pdf_info.stub!(:command).and_raise(unexpected_error)
      end

      it "should raise an error" do
        lambda { @pdf_info.metadata }.should raise_error(PDF::Info::FileError)
      end
    end

    context "error opening output" do
      before(:each) do 
        @pdf_info = PDF::Info.new('test.pdf')
        unexpected_error = PDF::Info::UnexpectedExitError.new
        unexpected_error.exit_code = 2
        @pdf_info.stub!(:command).and_raise(unexpected_error)
      end

      it "should raise an error" do
        lambda { @pdf_info.metadata }.should raise_error(PDF::Info::OutputError)
      end
    end

    context "bad permissions" do
      before(:each) do 
        @pdf_info = PDF::Info.new('test.pdf')
        unexpected_error = PDF::Info::UnexpectedExitError.new
        unexpected_error.exit_code = 3
        @pdf_info.stub!(:command).and_raise(unexpected_error)
      end

      it "should raise an error" do
        lambda { @pdf_info.metadata }.should raise_error(PDF::Info::BadPermissionsError)
      end
    end

    context "unknown error" do
      before(:each) do 
        @pdf_info = PDF::Info.new('test.pdf')
        unexpected_error = PDF::Info::UnexpectedExitError.new
        unexpected_error.exit_code = 4
        @pdf_info.stub!(:command).and_raise(unexpected_error)
      end

      it "should raise an error" do
        lambda { @pdf_info.metadata }.should raise_error(PDF::Info::UnknownError)
      end
    end
  end

  describe ".process_output" do
    subject do
      PDF::Info.new('test.pdf')
    end

    it "symbolizes all keys" do
      output = "a:foo\nb:bar\nc:baz"
      [:a, :b, :c].each do |key|
        expect(subject.process_output(output)).to have_key key
        expect(subject.process_output(output)).to_not have_key key.to_s
      end
    end

    it "downcases key" do
      output = "I AM ALL CAPITAL:I STAY ALL CAPITAL"
      expected = {:'i_am_all_capital' => 'I STAY ALL CAPITAL'}
      expect(subject.process_output(output)).to include expected
    end

    it "replaces whitespace in key with underscore" do
      output = "key with space:value without underscore"
      expected = {:'key_with_space' => 'value without underscore'}
      expect(subject.process_output(output)).to include expected
    end

    it "strips whitespace from metadata pair" do
      output = "  key with space  :value without space\nkey without space:  value with space  "
      expected = {:'key_with_space' => 'value without space', :'key_without_space' => 'value with space'}
      expect(subject.process_output(output)).to include expected
    end
  end

  describe ".parse_datetime" do
    subject do
      pdf_info = PDF::Info.new('test.pdf')
      pdf_info.stub!(:command).and_return(output('successful.txt'))
      pdf_info
    end

    it 'parse standard datetime format' do
      expect(subject.send(:parse_datetime, '2001-02-03T04:05:06+07:00')).to be_kind_of DateTime
    end

    it 'parse american datetime format' do
      expect(subject.send(:parse_datetime, '4/23/2004 18:37:34')).to be_kind_of DateTime
    end

    it 'return nil if string can not be parsed' do
      expect(subject.send(:parse_datetime, 'asdf')).to be_nil
    end
  end

  describe "running on sample.pdf" do
    subject do
      PDF::Info.command_path = "pdfinfo"
      PDF::Info.new(File.join(File.dirname(__FILE__), 'assets', 'sample.pdf')).metadata
    end

    its([:page_count]) { should == 1 }
    its([:creator]) { should == "PScript5.dll Version 5.2.2" }
    its([:version]) { should == 1.4 }
    its([:title]) { should == "Microsoft Word - sample.pdf.docx" }
    its([:encrypted]) { should be_false }
    its([:optimized]) { should be_false }
    its([:producer]) { should == "GPL Ghostscript 8.15" }
    its([:subject]) { should be_nil }
    its([:author]) { should eq "carlos"}
    its([:creation_date]) { should eq DateTime.parse("2010-10-09T10:29:55+00:00")}
    its([:modification_date]) { should eq DateTime.parse("2010-10-09T10:29:55+00:00")}
    its([:tagged]) { should be_false }
    its([:file_size]) { should eq "218882 bytes" }
  end

end
