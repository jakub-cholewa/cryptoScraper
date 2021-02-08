class Feeling

  attr_reader :coin, :success, :danger

  def initialize(coin, success, danger)
    @coin = coin
    @success = success
    @danger = danger
  end
end