db=SQLite3::Database.new '/home/clemju/workspace/comptes-symfony/app/data/comptes-sym.db3',readonly: true

cp={}
mo={}
ca={}
db.execute( "SELECT cp_nam,id from compte") do |row|
  Compte.create name:row[0] unless Compte.exists? name:row[0]
  cp[row[1]]=Compte.find_by name:row[0]
end
db.execute( "SELECT m_nam,id from moyen") do |row|
  Moyen.create name:row[0] unless Moyen.exists? name:row[0]
  mo[row[1]]=Moyen.find_by name:row[0]
end
db.execute( "SELECT c_nam,id from category") do |row|
  Category.create name:row[0] unless Category.exists? name:row[0]
  ca[row[1]]=Category.find_by name:row[0]
end
puts cp

ent=[]
cnt=0
max=1000
db.execute( "SELECT date,cp_s,cp_d,moy,cat,pr,po_s,po_d,com from entree") do |row|

  hh={
    date: row[0],
    cpS: row[1]==nil ? nil : cp[row[1]] ,
    cpD: row[2]==nil ? nil : cp[row[2]] ,
    moyen: row[3]==nil ? nil : mo[row[3]] ,
    category: row[4]==nil ? nil : ca[row[4]] ,
    pr: row[5] ,
    poS: row[6] ,
    poD: row[7] ,
    com: row[8]
  }
  unless Entry.exists? hh
     ent.append Entry.new hh
     cnt+=1
  end
  if cnt> max
    Entry.transaction do
      ent.each do |entre|
        entre.save
      end
    end
    ent=[]
    cnt=0
  end
end
Entry.transaction do
  ent.each do |entre|
    entre.save
  end
end
