require "spec_helper"

describe Exchange do

  # Create the first admin user
  before { create(:user) }

  let(:exchange)         { create(:exchange, :title => 'This is my Discussion', :body => 'First post!') }
  let(:nsfw_exchange)    { create(:exchange, :nsfw => true) }
  let(:user)             { create(:user) }
  let(:trusted_user)     { create(:trusted_user) }
  let(:moderator)        { create(:moderator) }
  let(:user_admin)       { create(:user_admin) }
  let(:admin)            { create(:admin) }

  specify { Exchange.table_name.should == "discussions" }

  it { should belong_to(:poster).class_name("User") }
  it { should belong_to(:closer).class_name("User") }
  it { should belong_to(:last_poster).class_name("User") }
  it { should have_many(:posts).dependent(:destroy) }
  it { should have_many(:discussion_views).dependent(:destroy) }

  it { should validate_presence_of(:title)}
  it { should ensure_length_of(:title).is_at_most(100) }
  it { should validate_presence_of(:body)}

  describe "#updated_by" do
    it 'changes closer when updating' do
      expect {
        exchange.update_attributes(closed: true, updated_by: moderator)
      }.to change{ exchange.closer }.from(nil).to(moderator)
    end
  end

  describe "#last_page" do

    before do
      3.times { create(:post, exchange: exchange) }
      exchange.reload
    end

    context "without arguments" do
      subject { exchange.last_page }
      it { should == 1 }
    end

    context "with argument" do
      subject { exchange.last_page(2) }
      it { should == 2 }
    end

  end

  describe "#labels?" do
    specify { Exchange.new.labels?.should be_false }
    specify { Exchange.new(trusted: true).labels?.should be_true }
    specify { Exchange.new(sticky: true).labels?.should be_true }
    specify { Exchange.new(closed: true).labels?.should be_true }
    specify { Exchange.new(nsfw: true).labels?.should be_true }
  end

  describe "#labels" do
    specify { Exchange.new.labels.should == [] }
    specify { Exchange.new(trusted: true).labels.should == ["Trusted"] }
    specify { Exchange.new(sticky: true).labels.should == ["Sticky"] }
    specify { Exchange.new(closed: true).labels.should == ["Closed"] }
    specify { Exchange.new(nsfw: true).labels.should == ["NSFW"] }
    specify {
      Exchange.new(trusted: true, sticky: true, closed: true, nsfw: true)
        .labels.should == ["Trusted", "Sticky", "Closed", "NSFW"]
    }
  end

  describe "#to_param" do
    subject { exchange.to_param }
    it { should =~ /^[\d]+;This\-is\-my\-Discussion$/ }
  end

  describe "#closeable_by?" do

    specify { exchange.closeable_by?(user).should be_false }

    context "when not closed" do
      specify { exchange.closeable_by?(exchange.poster).should be_true }
      specify { exchange.closeable_by?(moderator).should be_true }
    end

    context "when closed by the poster" do
      subject { exchange }
      before { exchange.update_attributes(closed: true, updated_by: exchange.poster) }
      specify { exchange.closeable_by?(exchange.poster).should be_true }
      specify { exchange.closeable_by?(moderator).should be_true }
      its(:closer) { should == exchange.poster }
    end

    context "closed by moderator" do
      subject { exchange }
      before { exchange.update_attributes(closed: true, updated_by: moderator) }
      specify { exchange.closeable_by?(exchange.poster).should be_false }
      specify { exchange.closeable_by?(moderator).should be_true }
      its(:closer) { should == moderator }
    end

  end

  describe "#validate_closed" do

    before do
      exchange.update_attributes(closed: true, updated_by: moderator)
    end

    subject { exchange }

    context "with no updated_by" do
      before { exchange.update_attributes(closed: false) }
      it { should be_valid }
      it { should have(0).errors_on(:closed) }
    end

    context "with updated_by poster" do
      before { exchange.update_attributes(closed: false, updated_by: exchange.poster) }
      it { should_not be_valid }
      it { should have(1).errors_on(:closed) }
    end

    context "with updated_by moderator" do
      before { exchange.update_attributes(closed: false, updated_by: moderator) }
      it { should be_valid }
      it { should have(0).errors_on(:closed) }
    end

  end

  describe "#create_first_post" do
    subject { exchange.posts.first }
    its(:body) { should == "First post!" }
    its(:user) { should == exchange.poster }
  end

  describe "#update_post_body" do
    before { exchange.update_attributes(:body => 'changed post') }
    subject { exchange.posts.first }
    its(:body) { should == "changed post" }
  end

end