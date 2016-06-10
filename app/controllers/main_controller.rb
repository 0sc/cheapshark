class MainController < ApplicationController
  def verify
    if params["object"] == "page"
      params["entry"].each do |field|
        page_id = field["id"]
        event_time = field["time"]

        field["messaging"].each do |message|
          received_message(message)
        end
      end
    end

    head 200
  end

  private

  def received_message(message)
    sender_id = message["sender"]["id"]
    recipient_id = message["sender"]["id"]
    timestamp = message["timestamp"]
    msg = message["message"]

    msg_id = msg["mid"]
    msg_txt = msg["text"]
    msg_attch = msg["attachments"]

    if msg_txt
      send_text_message(sender_id, msg_txt)
    end
  end

  def send_text_message(recipient_id, msg)
    message = {
      recipient: {
        id: recipient_id
      },
      message: {
        text: msg
      }
    }

    call_send_api(message)
  end


  def call_send_api(message)

    token = "EAADkEQodtFYBALiChq6qekWHHzv1oNBdnU0GMfZAQ1FiFJqeB6ZA8GZAZB0PM3aE8q0J5jnmaO4CuKKEEXNToUd1YSZAEk8OpmjSgtBMlmaaVmOA5v0HIzknW7QMfTiXgSW3U3eD0tMKWNWCqncF8P3xhvKM8G1oimPv9U2YpxQZDZD"
    uri = 'https://graph.facebook.com/v2.6/me/messages'
    uri += '?access_token=' + token

    r = Faraday.new(url: uri).post{|p| p.body = message}
    p r
  end

end
