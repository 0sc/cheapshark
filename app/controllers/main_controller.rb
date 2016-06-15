require "json"
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

    return unless msg
    
    msg_id = msg["mid"]
    msg_txt = msg["text"]
    msg_attch = msg["attachments"]

    list_opts = msg_txt.match(/list\sdeals?(?:\son page\s)?(\d+)?/)
    single_opts = msg_txt.match(/deal\sinfo\s(?:mation)?(?:\sfor\s)?(.+)/)
    search_opts = msg_txt.match(/search(?:\sfor\s)?(\w+)/)

    if list_opts
      pgNum = list_opts[1]
      rply_msg = prepare_message(Cheapshark.get_deals(pageNumber: pgNum), msg_txt)
    elsif single_opts
      rply_msg = prepare_message(Cheapshark.get_deal_info(single_opts[1]), msg_txt)
    elsif search_opts
      rply_msg = prepare_message(Cheapshark.get_deals(title: search_opts[1]), msg_txt)
    else
      # TODO: show help
      rply_msg = prepare_message([], msg_txt)
    end

    send_text_message(sender_id, rply_msg)
  end

  def prepare_message(package, query)
    if package.empty?
      { text: "Nothing found for query: #{query}\nTry: list deals\n
      list deals on page [page number]\n
      deal info [deal id]\n
      search for [item title]"}
    else
      {
        attachment: {
          type: "template",
          payload: {
            "template_type": "generic",
            "elements": package
          }
        }
      }
    end
  end

  def send_text_message(recipient_id, msg)
    message = {
      recipient: {
        id: recipient_id
      },
      message: msg
    }

    call_send_api(message)
  end


  def call_send_api(message)
    token = ENV["facebook_token"]
    uri = 'https://graph.facebook.com/v2.6/me/messages'
    uri += '?access_token=' + token

    Faraday.new(url: uri).post do |req|
      req.body = message.to_json
      req.headers['Content-Type'] = 'application/json'
    end
  end

end
