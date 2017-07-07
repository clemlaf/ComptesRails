class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def self.to_select
    self.order(name: :asc).all.collect{ |p| [p.name,p.id]}
  end
end
