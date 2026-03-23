require "rails_helper"

RSpec.describe AuthSerializer do
  let(:user)          { create(:user) }
  let(:access_token)  { "access.token.here" }
  let(:refresh_token) { "refresh.token.here" }

  subject(:json) do
    described_class.new(
      access_token:  access_token,
      refresh_token: refresh_token,
      user:          user
    ).as_json
  end

  it "includes tokens and user" do
    expect(json.keys).to contain_exactly(:access_token, :refresh_token, :user)
  end

  it "delegates user rendering to UserSerializer" do
    expect(json[:user]).to eq(UserSerializer.new(user).as_json)
  end

  it "never exposes password_digest inside user" do
    expect(json[:user].keys).not_to include(:password_digest)
  end

  it "includes the access and refresh tokens" do
    expect(json[:access_token]).to eq(access_token)
    expect(json[:refresh_token]).to eq(refresh_token)
  end
end
