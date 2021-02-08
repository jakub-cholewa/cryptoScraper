class Currency
  attr_reader :name, :symbol, :price, :change1h, :change24h, :change7d, :volume, :mktCap

  def initialize(name, symbol, price, change1h, change24h, change7d, volume, mktCap)
    @name = name
    @symbol = symbol
    @price = price
    @change1h = change1h
    @change24h = change24h
    @change7d = change7d
    @volume = volume
    @mktCap = mktCap
  end
end