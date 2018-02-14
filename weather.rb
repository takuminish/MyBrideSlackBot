# coding: utf-8
require "json"
require "open-uri"

BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
def weather(token)
  res = open(BASE_URL + "?zip=769-2321,JP&units=metric&APPID=#{token}")
  return JSON.parse(res.read)
end

def weather_name_translation(name)
  case name
  when "Clouds" then jp_name = "曇り"
  when "Clear" then jp_name = "晴れ"
  when "rain" then jp_name = "雨"
  when "snow" then jp_name = "雪"
  end

  return jp_name
end
  
