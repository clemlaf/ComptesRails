class Compte < ApplicationRecord
  belongs_to :parent, class_name: "Compte", foreign_key: :parent_id
  has_many :entriesS, class_name: "Entry", foreign_key: :cpS_id, :inverse_of => :cpS
  has_many :entriesD, class_name: "Entry", foreign_key: :cpD_id, :inverse_of => :cpD
  has_many :periodicsS, class_name: "Periodic", foreign_key: :cpS_id, :inverse_of => :cpS
  has_many :periodicsD, class_name: "Periodic", foreign_key: :cpD_id, :inverse_of => :cpD
  has_many :children, class_name: "Compte", foreign_key: :parent_id, :inverse_of => :parent
  def self.to_select
    out=[]
    self.where(parent: nil).order(name: :asc).each do |p|
      puts p.name
      out << [p.name,p.id]
      out+=p.children_select(">")
    end
    out
  end

  def children_select(pref)
    out=[]
    self.children.each do |c|
      out << [pref+" "+c.name,c.id]
      out+=c.children_select(pref+pref)
    end
    out
  end
  def self.get_first_parent(cptab)
    return nil if cptab.empty?
    c=Compte.find(cptab.first)
    c=c.parent unless c.parent_id==nil
    c.id
  end
end
