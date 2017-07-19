class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def self.to_select
    self.order(name: :asc).all.collect{ |p| [p.name,p.id]}
  end
  def as_json(options=nil)
    json=super(options)
    json["date"]=I18n.l(json["date"]) if json["date"]
    json
  end  
end
