require File.dirname(__FILE__) + '/spec_helper'

describe Fill do

  before  do
    Output.output = []
  end

  describe "the the internal workings of db.produce" do

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
          stub(Project).delete_all { 123456789 }
          stub(Project).count      { 987654321 }
          produce!
        end

        subject { Output.output.first }

        it { should =~ /Time: ([0-9.]+)/ }
        it { should include("Before: 123456789") }
        it { should include("After: 987654321") }
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

  describe "arguments for db.produce" do

    describe "multiple models" do

      after do
        produce! :projects, :users, :memberships do
          User.create
        end
      end

      it "calls delete_all on all models" do
        mock(Project).delete_all
        mock(User).delete_all
        mock(Membership).delete_all
      end

      it "calls count on all models" do
        mock(Project).count
        mock(User).count
        mock(Membership).count
      end

      it "calls human_name on all models" do
        mock(Project).human_name
        mock(User).human_name
        mock(Membership).human_name
      end

      it "should only execute the procedure once" do
        mock(User).create.times(1)
      end

    end

    describe "dependencies" do

      it "should run dependencies first" do
        # This works because the dont_allow should be executed AFTER
        # the call was actually done! Similarly, the mock should be
        # defined BEFORE it was done.
        Fill.database do |db|
          db.produce :users, :needs => :projects do
            dont_allow(Project).create
            User.create
          end
          db.produce :projects do
            Project.create
            mock(User).create
          end
        end
      end

      it "should execute once, even with multiple dependencies" do
        mock(User).create.times(1)
        Fill.database do |db|
          db.produce(:memberships, :needs => :users) {}
          db.produce(:projects, :needs => :users) {}
          db.produce(:users) { User.create }
        end
      end

      it "should handle multiple dependencies" do
        Fill.database do |db|
          db.produce(:memberships, :needs => [:users, :projects]) do
            # Again, don't allow, because these should already have
            # been executed before this block is executed.
            dont_allow(Project).create
            dont_allow(User).create
            Membership.create # twice because mocked twice
            Membership.create
          end
          db.produce(:projects, :needs => :users) do
            Project.create
            mock(Membership).create
            dont_allow(User).create
          end
          db.produce(:users) do
            User.create
            mock(Project).create
            mock(Membership).create
          end
        end
      end

      context "without hirb" do

        before { stub(Fill::Presenter).hirb? { false } }

        it "should join model names" do
          mock(Project).human_name  { "Projects" }
          mock(User).human_name     { "Accounts" }
          produce! :projects, :users
          Output.output.first.should include("Models: Projects, Accounts")
        end

        it "should join before counts" do
          mock(Project).delete_all { 1234 }
          mock(User).delete_all    { 4321 }
          produce! :projects, :users
          Output.output.first.should include("Before: 1234, 4321")
        end

        it "should join before counts" do
          mock(Project).count { 789 }
          mock(User).count    { 456 }
          produce! :projects, :users
          Output.output.first.should include("After: 789, 456")
        end

        it "should add up times" do
          produce! :projects, :users
          Output.output.first.should =~ /Time: [0-9.][^,]/ # no comma, no join(',')
        end

      end

    end

    describe "names" do

      before { stub(Fill::Presenter).hirb? { false } }

      it "should override name" do
        name = ":::MYNAME:::"
        dont_allow(Project).human_name
        produce! :projects, :name => name
        Output.output.first.should include("Models: #{name}")
      end

      it "should override name with multiple models" do
        name = ":::FOOBAR:::"
        dont_allow(Project).human_name
        dont_allow(User).human_name
        dont_allow(Membership).human_name
        produce! :projects, :users, :memberships, :name => name
        Output.output.first.should include("Models: #{name}")
      end

    end

    describe "delete option" do

      it "should not delete with delete option to false" do
        dont_allow(Project).delete_all
        dont_allow(User).delete_all
        mock(Project).count.times(2) # before and after
        mock(User).count.times(2) # before and after
        produce! :users, :projects, :delete => false
      end

    end

  end

  describe "the db.fill method" do

    it "should call create! on the model" do
      mock(Project).create!(:name => "A")
      mock(Project).create!(:name => "B")
      Fill.database do |db|
        db.fill :projects, :name, "A", "B"
      end
    end

    it "should have the needs option" do
      Fill.database do |db|
        db.fill :projects, :name, "A", :needs => :users
        db.produce(:users) do
          mock(Project).create!(:name => "A")
        end
      end
    end

    it "should have the name option" do
      mock(Project).create!(:name => "A")
      Fill.database do |db|
        db.fill :projects, :name, "A", :name => "AWESOME"
      end
      Output.output.first.should include("AWESOME")
    end

    it "should delete too" do
      mock(Project).delete_all
      mock(Project).create!(:name => "A")
      Fill.database do |db|
        db.fill :projects, :name, "A"
      end
    end

    it "should not delete when delete option is false" do
      dont_allow(Project).delete_all
      mock(Project).create!(:name => "A")
      Fill.database do |db|
        db.fill :projects, :name, "A", :delete => false
      end
    end

  end

  describe "the db.invoke method" do

    before { stub(Rake::Task)["some:task"].stub!.invoke }

    it "should invoke a task" do
      mock(Rake::Task)["some:task"].mock!.invoke
      Fill.database do |db|
        db.invoke "some:task", :projects
      end
    end

    it "should delete the model" do
      mock(Project).delete_all
      Fill.database do |db|
        db.invoke "some:task", :projects
      end
    end

    it "should accept the need option" do
      Fill.database do |db|
        db.invoke "some:task", :projects, :needs => :users
        db.produce(:users) do
          mock(Project).delete_all
        end
      end
    end

    it "should accept the name option" do
      Fill.database do |db|
        db.invoke "some:task", :projects, :name => "MYNAME"
      end
      Output.output.first.should include("MYNAME")
    end

    it "should not delete when delete option is false" do
      dont_allow(Project).delete_all
      Fill.database do |db|
        db.invoke "some:task", :projects, :delete => false
      end
    end


  end

end
