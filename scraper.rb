require 'nokogiri'
require 'httparty'
require 'byebug'
require 'pry'
require './currency'
require './feeling'

class Scraper
  attr_reader :url
  
  def initialize()
    @url = 'https://www.coingecko.com/pl'
  end

  def parse_url(url)
    unparsed_page = HTTParty.get(url)
    Nokogiri::HTML(unparsed_page)
  end

  def scrapeTable(limit)
    parsed_page = parse_url(@url)
    currencies = scrapeCurrencies(parsed_page, limit)

    exportToCSV(currencies)
  end

  def scrapeCurrencies(parsed_page, limit)
    table = parsed_page.css('table[data-target="gecko-table.table"]')
    rows = table.css('tbody').css('tr')
    scrapeCurrenciesFromRows(rows, limit)
  end

  def scrapeCurrenciesFromRows(rows, limit)
    currencies = []
    names = []
    counter = 0

    rows.each { |row|
      nameField = row.css('td.coin-name')
      name = nameField.css('a.d-none').children[0].text.strip
      symbol = nameField.css('span').children[0].text.strip

      price = row.css('td.td-price').css('span').children[0].text
      change1h = row.css('td.td-change1h').css('span').children[0]
      change24h = row.css('td.td-change24h').css('span').children[0]
      change7d = row.css('td.td-change7d').css('span').children[0]
      volume = row.css('td.td-liquidity_score').css('span').children[0]
      mktCaps = row.css('td.td-market_cap').css('span').children[0]

      currencies.push(Currency.new(name, symbol, price, change1h, change24h, change7d, volume, mktCaps))

      if counter < limit
        names.push(name.gsub(" ", "-"))
        counter += 1
      end
    }
    puts(names)
    scrapeDetails(names)
    currencies
  end

  def exportToCSV(currencies)
    CSV.open('currencies.csv', 'wb') do |csv|
      csv << ['Name', 'Symbol', 'Price', 'Change 1h', 'Change 24h', 'Change 7d', 'Volume', 'Mkt Cap']
      currencies.each { |cur|
        csv << [cur.name, cur.symbol, cur.price, cur.change1h, cur.change24h, cur.change7d, cur.volume, cur.mktCap]
      }
    end
  end

  def exportFeelingsToCSV(feelings)
    CSV.open('feelings.csv', 'wb') do |csv|
      csv << ['Coin', 'Success', 'Danger']
      feelings.each { |feel|
        csv << [feel.coin, feel.success, feel.danger]
      }
    end
  end

  def scrapeDetails(coins)
    feelings = []
    coins.each do |coin|
      parsed_page = parse_url("https://www.coingecko.com/pl/coins/#{coin.downcase}")
      feeling = scrapeDetailsFromPage(coin, parsed_page)
      feelings.push(feeling)
    end
    exportFeelingsToCSV(feelings)
  end

  def scrapeDetailsFromPage(coin, parsed_page)
    unless parsed_page.css('div.progress-bar.bg-success').children[0].nil? and parsed_page.css('div.progress-bar.bg-danger').children[0].nil?
    success = parsed_page.css('div.progress-bar.bg-success').children[0].text.strip
    danger = parsed_page.css('div.progress-bar.bg-danger').children[0].text.strip
    Feeling.new(coin.strip, success, danger)
    end
  end
end

scraper = Scraper.new
limit = ARGV[0].to_i
scraper.scrapeTable(limit)