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
