class SymtoRails
  attr_accessor :db, :cp, :mo, :ca, :notincluded, :incl, :doubl
  def initialize
    @db=SQLite3::Database.new '/home/clemju/workspace/comptes-symfony/app/data/comptes-sym.db3',readonly: true
  end
  def getparams
    @cp={}
    @mo={}
    @ca={}
    Compte.transaction do
      @db.execute( "SELECT cp_nam,id from compte") do |row|
        Compte.create name:row[0] unless Compte.exists? name:row[0]
        @cp[row[1]]=Compte.find_by name:row[0]
      end
    end
    Moyen.transaction do
      @db.execute( "SELECT m_nam,id from moyen") do |row|
        Moyen.create name:row[0] unless Moyen.exists? name:row[0]
        @mo[row[1]]=Moyen.find_by name:row[0]
      end
    end
    Category.transaction do
      @db.execute( "SELECT c_nam,id from category") do |row|
        Category.create name:row[0] unless Category.exists? name:row[0]
        @ca[row[1]]=Category.find_by name:row[0]
      end
    end
    puts @cp
  end

  def getentries
    if @cp==nil
      getparams
    end
    ent=[]
    cnt=0
    @notincluded=[]
    @incl=[]
    Entry.transaction do
      @db.execute( "SELECT date,cp_s,cp_d,moy,cat,pr,po_s,po_d,com,id from entree") do |row|

        hh={
          date: row[0],
          cpS: row[1]==nil ? nil : @cp[row[1]] ,
          cpD: row[2]==nil ? nil : @cp[row[2]] ,
          moyen: row[3]==nil ? nil : @mo[row[3]] ,
          category: row[4]==nil ? nil : @ca[row[4]] ,
          pr: row[5] ,
          poS: row[6]==1 ,
          poD: row[7]==1 ,
          com: row[8]
        }
        @incl.append(hh.merge({id:row[9]}))
        #unless Entry.exists? hh
          begin
            Entry.create! hh
            cnt+=1
          rescue
            @notincluded.append(hh.merge({id:row[9], cpst: row[1]}))
          end
        #else
        #  @notincluded.append(hh.merge({id:row[9], cpst: row[1]}))
        #end
      end
    end
    puts cnt
  end
  def finddoub
    @doubl=[]
    indd=[]
    for i in 0..(@incl.length() -2)
      unless indd.include? i
      for j in i+1..(@incl.length() -1)
        id=true
        [:date, :cpS, :cpD, :moyen, :category,:pr, :poS, :poD, :com].each do |k|
          id &=(@incl[i][k]== @incl[j][k])
        end
        if id
        @doubl.append({ind: i, sind: @incl[i][:id], jnd: j, sjnd: @incl[j][:id] })
        indd.append j
        end
      end
      else
        puts i, indd
      end
    end
  end
end
