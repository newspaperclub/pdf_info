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

end
