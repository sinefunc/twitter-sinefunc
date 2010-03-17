require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class CustomReply
  include Twitter::Sinefunc::StatusUpdate
  
  attr_accessor :item

  body "@:username ", username: lambda { item.user.login }

  validates_body_has_added_content "must be FooBared"
end  

describe CustomReply do
  it { should validate_presence_of(:body) }
  it { should validate_length_of(:body, :within => 1..140) }
  it { should validate_presence_of(:sender) }
  
  context "its template" do
    subject { CustomReply.template }
    
    it { should == "@:username " }
  end
end

describe CustomReply, "with an item by a user named cyx" do
  subject do
    @user = stub("User")
    @user.stub!(:login => "cyx")

    @item = stub("Item")
    @item.stub!(:name => "iPhone 16GB", :user => @user)

    @custom_reply = CustomReply.new(:item => @item)
  end
  
  its(:item)     { subject.name.should === 'iPhone 16GB' }
  its(:username) { should == 'cyx' }
  its(:to_s)     { should == '@cyx ' }
  its(:body)     { should == '@cyx ' }
  
  it "should have an invalid body" do
    subject.valid? 
    subject.errors[:body].should_not be_nil
  end

  it "should have the foobar error message" do
    subject.valid?
    subject.errors.full_messages.should include("Body must be FooBared")
  end
end

describe CustomReply, "with an item by a user named cyx, body @cyx hi there" do
  subject do
    @user = stub("User")
    @user.stub!(:login => "cyx")

    @item = stub("Item")
    @item.stub!(:name => "iPhone 16GB", :user => @user)

    @custom_reply = CustomReply.new(:item => @item, :body => '@cyx hi there')
  end
  
  its(:body)     { should == '@cyx hi there' }
  
  it "should have a valid body" do
    subject.errors[:body].should be_empty
  end
end
