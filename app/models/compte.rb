class Compte < ApplicationRecord
  has_many :entriesS, class_name: "Entry", :inverse_of => :cpS
  has_many :entriesD, class_name: "Entry", :inverse_of => :cpD
end
