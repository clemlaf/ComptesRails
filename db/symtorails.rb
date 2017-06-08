db=SQLite3::Database.new '/home/clemju/workspace/comptes-symfony/app/data/comptes-sym.db3',readonly: true


db.execute( "SELECT cp_nam from compte") do |row|
  Compte.create name:row[0] unless Compte.exists? name:row[0]
end
db.execute( "SELECT m_nam from moyen") do |row|
  Moyen.create name:row[0] unless Moyen.exists? name:row[0]
end
db.execute( "SELECT c_nam from category") do |row|
  Category.create name:row[0] unless Category.exists? name:row[0]
end
