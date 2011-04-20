#!/usr/bin/env ruby
require "./scripts/yateby.rb"

log "woah, call started"

install "chan.dtmf"

our_call_id = "fony/#{uuid}"

while event = next_message
  case event.name
  when "call.execute" then
    party_id = event["id"]

    reply = Yateby::Response.new
    reply.id = event.id
    reply.processed = true
    reply.retvalue = event.retvalue
    reply["targetid"] = our_call_id
    transmit(reply)

    answer = Yateby::Request.new
    answer.time = now
    answer.name = "call.answered"
    answer["id"] = our_call_id
    answer["targetid"] = party_id
    transmit(answer)

    play = Yateby::Request.new
    play.time = now
    play.name = "chan.attach"
    play["source"] = "tone/busy"
    play["autorepeat"] = "true"
    transmit(play)
  else
    if event.is_a? Yateby::Request
      log event.name
      reply = Yateby::Response.new
      reply.id = event.id
      reply.processed = false
      reply.retvalue = event.retvalue
      reply.params = event.params
      reply.name = event.name
      transmit(reply)
    end
  end
end
