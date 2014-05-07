require 'spec_helper'

describe AllSuffixes do

  include AllSuffixes

  it "should return all suffixes and a string itself" do
    all_suffixes("foo bar baz").should == ["foo bar baz", "bar baz", "baz"]
  end

end
