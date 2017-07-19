class Moyen < ApplicationRecord
  has_many :entries
  has_many :periodics
end
