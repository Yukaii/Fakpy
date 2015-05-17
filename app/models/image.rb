class Image < ActiveRecord::Base
  serialize :alikes, JSON

  def weird
    all.select {|d| d.alikes.count > 0 }
  end
end
