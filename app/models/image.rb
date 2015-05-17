class Image < ActiveRecord::Base
  serialize :alikes, JSON

  scope :weird, -> { where(id: all.select {|d| d.alikes.count > 0 }.map(&:id)) }
end
