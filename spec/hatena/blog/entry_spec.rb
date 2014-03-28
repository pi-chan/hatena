require 'spec_helper'

describe Hatena::Blog::Entry do
  describe ".new" do
    context "with no arguments" do
      it "not raise an exception" do
        expect do
          Hatena::Blog::Entry.new
        end.to raise_error
      end
    end

    context "with hash arguments" do
      before do
        client = test_client()
        @entry = client.fetch_published(limit:1).first
      end
      it { expect(@entry).not_to eq(nil) }
      it { expect(@entry.id).to eq("tag:blog.hatena.ne.jp,2013:blog-hatena_id-12300000000000-3000000000000000") }
      it { expect(@entry.link_edit).to eq("https://blog.hatena.ne.jp/hatena_id/blog_id.hatenablog.com/atom/edit/123456") }
      it { expect(@entry.title).to eq("hogehogehoge") }
      it { expect(@entry.updated).to eq("2013-09-02T11:28:23+09:00") }
      it { expect(@entry.published).to eq("2013-09-02T11:28:23+09:00") }
      it { expect(@entry.content).to eq("\n      hoge\n    ") }
      it { expect(@entry.author).to eq("hatena_id") }
      it { expect(@entry.draft).to eq(false) }
      it { expect(@entry.summary).to eq("hoge ") }
    end
  end

  
  
end


