# frozen_string_literal: true

# This class implements all required interaction with Slack service
# Some methods are used during new member onboarding, others are required
# for new project kick-off.
class SlackService
  def initialize(token)
    @token = token
  end

  # We invite new registred member to our Slack
  def invite(user, channels)
    SlackIntegration::InviteUser.new(
      user:      user,
      channels:  id_channels(channels),
      token:     token
    ).call
  end

  # When the new idea is submitted we notify developers through Slack
  def post_to_channel(channel, message)
    client.chat_postMessage(channel: channel, text: message, as_user: false, username: 'Idea Bot')
  end

  # At the moment of new project kick-off we invite all interested members to its channel
  def invite_to_channel(channel_name, email)
    user = user_by_email(email)
    raise SlackIntegration::FailedApiCallException, "User with email '#{email}' was not found" unless user
    channel = channel_by_name(channel_name)
    raise SlackIntegration::FailedApiCallException, "Channel with name '#{channel}' was not found" unless channel
    client.conversations_invite(channel: channel['id'], users: user['id'])
  end

  # For each new project we create a separate channel
  def create_channel(channel_name)
    client.conversations_create(name: channel_name, is_private: false)
  end

  private

  attr_reader :token
  # :nocov:
  def client
    @client ||= ::Slack::Web::Client.new(token: token)
  end
  # :nocov:

  def channel_by_name(channel)
    client.conversations_list['channels'].find do |entry|
      entry['name'] == channel
    end
  end

  def user_by_email(email)
    client.users_list['members'].find do |entry|
      entry['profile']['email'] == email
    end
  end

  def id_channels(channels)
    channels.map { |channel| channel_by_name(channel)['id'] }.join(',')
  end
end
