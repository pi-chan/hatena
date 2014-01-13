require 'spec_helper'
require 'active_support/all'

describe Hatena::Blog::Client do

  before do
    @hatena_id = "hatena_id"
    @blog_id = "blog_id.hatenablog.com"
    @endpoint = "https://blog.hatena.ne.jp/#{@hatena_id}/#{@blog_id}"
    @credentials = Hatena::Credentials.new(
      "consumer_key",
      "consumer_secret",
      "token",
      "token_secret"
    )
    
    @client = Hatena::Blog::Client.new(
      @credentials,
      @hatena_id,
      @blog_id
    )

    stub_request(:get, @endpoint+"/atom/entry").to_return(body: fixture("fetch_entries01.xml") )
    stub_request(:get, @endpoint+"/atom/entry?page=2").to_return(body: fixture("fetch_entries02.xml") )
    stub_request(:get, @endpoint+"/atom/entry?page=3").to_return(body: fixture("fetch_entries03.xml") )
  end
  
  describe ".new" do
    context "when arguments count is correct" do
      it "does not raise an exception" do
        expect do
          Hatena::Blog::Client.new(0,1,2)
        end.not_to raise_error
      end
    end

    context "when arguments count is not correct" do
      it "raises a exception" do
        expect do
          Hatena::Blog::Client.new()
        end.to raise_error
      end
    end
  end

  describe "#fetch_published" do
    context "when getting all published entries" do
      it "returns all published entries" do
        entries = @client.fetch_published()
        expect(entries.count).to eq(15)
      end
    end

    context "when getting published entries in time range" do
      it "returns entries in time range" do
        entries = @client.fetch_published(range:DateTime.parse("2013-09-01")..DateTime.parse("2013-09-10"))
        expect(entries.count).to eq(10)
      end

      it "returns entries in time range" do
        entries = @client.fetch_published(range:DateTime.parse("2013-01-01")..DateTime.parse("2013-01-10"))
        expect(entries.count).to eq(5)
      end

      it "returns entries in time range" do
        entries = @client.fetch_published(range:DateTime.parse("2013-01-01")..DateTime.parse("2013-12-31"))
        expect(entries.count).to eq(15)
      end

      it "returns entries in time range" do
        entries = @client.fetch_published(range:DateTime.parse("2014-01-01")..DateTime.parse("2014-12-31"))
        expect(entries.count).to eq(0)
      end
    end

    context "when getting [N] published entries" do
      it "returns [N] or all published entries" do
        entries = @client.fetch_published(limit:5)
        expect(entries.count).to eq(5)
      end

      it "returns [N] or all published entries" do
        entries = @client.fetch_published(limit:8)
        expect(entries.count).to eq(8)
      end

      it "returns [N] or all published entries" do
        entries = @client.fetch_published(limit:20)
        expect(entries.count).to eq(15)
      end
    end

    context "when getting [N] published entries in time range" do
      it "returns [N] of all published entries in time range" do
        entries = @client.fetch_published(
          range:DateTime.parse("2013-09-01")..DateTime.parse("2013-09-10"),
          limit:15
        )
        expect(entries.count).to eq(10)
      end

      it "returns [N] of all published entries in time range" do
        entries = @client.fetch_published(
          range:DateTime.parse("2013-09-01")..DateTime.parse("2013-09-10"),
          limit:3
        )
        expect(entries.count).to eq(3)
      end

      it "returns [N] of all published entries in time range" do
        entries = @client.fetch_published(
          range:DateTime.parse("2013-01-01")..DateTime.parse("2013-01-10"),
          limit:15
        )
        expect(entries.count).to eq(5)
      end
    end
  end

  describe "#fetch_drafts" do
    context "when getting all drafts" do
      it "returns all drafts" do
        entries = @client.fetch_drafts()
        expect(entries.count).to eq(6)
      end
    end

    context "when getting drafts in time range" do
      it "returns entries in time range" do
        entries = @client.fetch_drafts(range:DateTime.parse("2013-09-01")..DateTime.parse("2013-09-10"))
        expect(entries.count).to eq(4)
      end

      it "returns entries in time range" do
        entries = @client.fetch_drafts(range:DateTime.parse("2013-01-01")..DateTime.parse("2013-01-10"))
        expect(entries.count).to eq(2)
      end

      it "returns entries in time range" do
        entries = @client.fetch_drafts(range:DateTime.parse("2013-01-01")..DateTime.parse("2013-12-31"))
        expect(entries.count).to eq(6)
      end

      it "returns entries in time range" do
        entries = @client.fetch_drafts(range:DateTime.parse("2014-01-01")..DateTime.parse("2014-12-31"))
        expect(entries.count).to eq(0)
      end
    end

    context "when getting [N] drafts" do
      it "returns [N] or all drafts" do
        entries = @client.fetch_drafts(limit:5)
        expect(entries.count).to eq(5)
      end

      it "returns [N] or all drafts" do
        entries = @client.fetch_drafts(limit:8)
        expect(entries.count).to eq(6)
      end
    end

    context "when getting [N] drafts in time range" do
      it "returns [N] of all drafts in time range" do
        entries = @client.fetch_drafts(
          range:DateTime.parse("2013-09-01")..DateTime.parse("2013-09-10"),
          limit:10
        )
        expect(entries.count).to eq(4)
      end

      it "returns [N] of all drafts in time range" do
        entries = @client.fetch_drafts(
          range:DateTime.parse("2013-09-01")..DateTime.parse("2013-09-10"),
          limit:3
        )
        expect(entries.count).to eq(3)
      end

      it "returns [N] of all drafts in time range" do
        entries = @client.fetch_drafts(
          range:DateTime.parse("2013-01-01")..DateTime.parse("2013-01-10"),
          limit:5
        )
        expect(entries.count).to eq(2)
      end
    end
    
  end

  describe "#fetch_all" do

    context "when getting all entries" do
      it "returns all entries" do
        entries = @client.fetch_entries()
        expect(entries.count).to eq(21)
      end
    end

    context "when getting entries in time range" do
      it "returns entries in time range" do
        entries = @client.fetch_entries(range:DateTime.parse("2013-09-01")..DateTime.parse("2013-09-10"))
        expect(entries.count).to eq(14)
      end

      it "returns entries in time range" do
        entries = @client.fetch_entries(range:DateTime.parse("2013-01-01")..DateTime.parse("2013-01-10"))
        expect(entries.count).to eq(7)
      end

      it "returns entries in time range" do
        entries = @client.fetch_entries(range:DateTime.parse("2013-01-01")..DateTime.parse("2013-12-31"))
        expect(entries.count).to eq(21)
      end

      it "returns entries in time range" do
        entries = @client.fetch_entries(range:DateTime.parse("2014-01-01")..DateTime.parse("2014-12-31"))
        expect(entries.count).to eq(0)
      end
    end

    context "when getting [N] entries" do
      it "returns [N] or all entries" do
        entries = @client.fetch_entries(limit:5)
        expect(entries.count).to eq(5)
      end

      it "returns [N] or all entries" do
        entries = @client.fetch_entries(limit:10)
        expect(entries.count).to eq(10)
      end

      it "returns [N] or all entries" do
        entries = @client.fetch_entries(limit:30)
        expect(entries.count).to eq(21)
      end
    end

    context "when getting [N] entries in time range" do
      it "returns [N] of all entries in time range" do
        entries = @client.fetch_entries(
          range:DateTime.parse("2013-09-01")..DateTime.parse("2013-09-10"),
          limit:20
        )
        expect(entries.count).to eq(14)
      end

      it "returns [N] of all entries in time range" do
        entries = @client.fetch_entries(
          range:DateTime.parse("2013-09-01")..DateTime.parse("2013-09-10"),
          limit:3
        )
        expect(entries.count).to eq(3)
      end

      it "returns [N] of all entries in time range" do
        entries = @client.fetch_entries(
          range:DateTime.parse("2013-01-01")..DateTime.parse("2013-01-10"),
          limit:10
        )
        expect(entries.count).to eq(7)
      end

      it "returns [N] of all entries in time range" do
        entries = @client.fetch_entries(
          range:DateTime.parse("2013-01-01")..DateTime.parse("2013-01-10"),
          limit:3
        )
        expect(entries.count).to eq(3)
      end
    end
  end
end

