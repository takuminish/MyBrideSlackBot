# coding: utf-8
require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'
require './weather.rb'

OpenWeatherMap_Token = ENV['OPENWEATHERMAP_TOKEN']
response = HTTP.post("https://slack.com/api/rtm.start", 
                     params: { token: ENV['TOKEN'],
                             }
                    )
rc =  JSON.parse(response.body)
url =  rc['url']

EM.run do
  # Web Socketインスタンスの立ち上げ
  ws = Faye::WebSocket::Client.new(url)

  # 接続完了時の処理
  ws.on :open do
    p [:open]
  end

  # RTM APIから情報を受け取った時の処理
  ws.on :message do |event|
    data = JSON.parse(event.data)
    p [:message, data]
    if /よ[ー-]*し[ー-]*こ[ー-]*/ === data['text'] || /ヨ[ー-]*シ[ー-]*コ[ー-]*/ === data['text'] || /善[ー-]*子[ー-]*/ === data['text']
    res  =  {
          type: 'message',
          text: 'ヨハネ!!',
          channel: data['channel']
      }.to_json
        ws.send(res)

    
  elsif /よ[ー-]*は[ー-]*ね[ー-]*/ === data['text'] || /ヨ[ー-]*ハ[ー-]*ネ[ー-]*/ === data['text']
      res  =  {
        type: 'message',
        text: '善子!!',
        channel: data['channel']
    }.to_json
      ws.send(res)
  elsif /天気/=== data['text']
    weather = weather(OpenWeatherMap_Token)
    jp_weather_name = weather_name_translation(weather['weather'][0]['main'])
    temp = weather['main']['temp']
    res = {
      type: 'message',
      text: "今の天気は#{jp_weather_name}\n気温は#{temp}度よ",
      channel: data['channel']
    }.to_json
    ws.send(res)
    
  elsif /.*/ === data['text']
     res  =  {
      type: 'message',
      text: 'なにをいってるの?',
      channel: data['channel']
    }.to_json
    ws.send(res)
    end
  end

  # 接続が切断した時の処理
  ws.on :close do
    ws = nil
    EM.stop
  end
end
