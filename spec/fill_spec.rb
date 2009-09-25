require File.dirname(__FILE__) + '/spec_helper'

describe Fill do

  before  do
    Fill.out = Output
    Output.output = []
  end

  describe "the the internal workings of the produce method" do

    it "should perform the content only after the block is closed" do
      # This is so that all dependencies can be initialized
      # before anything is executed.
      lambda {
        Fill.database do |db|
          lambda {
            db.produce :projects do
              throw :fill_executed
            end
          }.should_not throw_symbol(:fill_executed)
        end
      }.should throw_symbol(:fill_executed)
    end

    it "should count the records" do
      mock(Project).count
      produce!
    end

    it "should delete all the records" do
      mock(Project).delete_all
      produce!
    end

    it "should get the human name of a model" do
      mock(Project).human_name
      produce!
    end

    it "should report the total time" do
      produce!
      Output.output.last.should =~ /\ADatabase filled in (.*) seconds\Z/
    end

    context "without hirb" do

      before { mock(Fill::Presenter).hirb? { false } }

      describe "output per model" do

        before do
          stub(Project).human_name { "FOOBAR" }
          produce!
        end

        subject { Output.output.first }

        it { should =~ /Time: ([0-9.]+)/ }
        it { should include("Before: 1") }
        it { should include("After: 2") }
        it { should include("Models: FOOBAR") }

      end

      it "should count the time of the block" do

        # Fill itself shouldn't take up more than 1 second
        # so this test should return just about 1 second
        # I _am_ sorry about this crude example ;)

        produce! { sleep 1 } # zzzzzzzzzz

        Output.output.first =~ /Time: ([0-9.]+)/
        $1.to_i.should == 1

        # Test total time, not in a seperate example to shorten testrun
        Output.output.last =~ /([0-9.]+) seconds/
        $1.to_i.should == 1
      end

    end

    it "should use hirb when possible" do
      out = "---HIRB OUTPUT---"
      mock(Fill::Presenter).hirb? { true }
      mock(Hirb::Helpers::Table).render(is_a(Array), :description => false) { out }
      produce!
      Output.output.first.should == out
    end

  end

  describe "usage of paramaters" do

    it "should accept multiple parameters" do
      mock(Project).delete_all
      mock(User).delete_all
      produce! :projects, :users
    end

  end

end
