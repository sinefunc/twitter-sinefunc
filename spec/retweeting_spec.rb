require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class CustomRetweeting
  include Twitter::Sinefunc::StatusUpdate
  
  attr_accessor :item

  body "RT @:username: %.54s :url #boughtstuff",
    username: lambda { item.user.login },
    url:      lambda { "http://me.com/#{item.user.login}/#{item.to_param}" }
end

describe CustomRetweeting do
  it { should validate_presence_of(:body) }
  it { should validate_length_of(:body, :within => 1..140) }
  it { should respond_to(:url) }
  it { should respond_to(:username) }

  context "its template" do
    subject { CustomRetweeting.template }

    it { should == "RT @:username: %.54s :url #boughtstuff" }
  end

  context "given an item with a user login of cyx and to_param of 101" do
    subject do
      @user = stub("User")
      @user.stub!(:login => "cyx")

      @item = stub("Item")
      @item.stub!(:to_s => "iPhone 16GB", :user => @user, :to_param => 101)

      @custom_retweet = CustomRetweeting.new(:item => @item)
    end

    its(:username) { should == 'cyx' }
    its(:url) { should == "http://me.com/cyx/101" }
    its(:to_s) { should == "RT @cyx: iPhone 16GB http://me.com/cyx/101 #boughtstuff" }
  end
end
